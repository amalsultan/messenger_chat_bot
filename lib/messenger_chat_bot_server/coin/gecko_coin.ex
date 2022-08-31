defmodule MessengerChatBotServer.GeckoCoin do
  @moduledoc """
  GeckoCoin interacts with gecko coin api to fetch coin data and convert it in required format.
  """

  require Logger

  defp filter_coin_list(%{"coins" => coins}), do: Enum.slice(coins, 0..4)

  defp format_coin_data(acc, price) do
    formatted_price = Float.round(price, 10)
    "#{acc} \n #{Float.to_string(formatted_price)}"
  end

  defp transform_coin_data(%{"prices" => prices}),
    do: Enum.reduce(prices, "", fn [_timestamp, price], acc -> format_coin_data(acc, price) end)

  @spec get_coin_data(%{
          optional(:id) =>
            binary
            | maybe_improper_list(
                binary | maybe_improper_list(any, binary | []) | char,
                binary | []
              ),
          optional(any) => any
        }) :: any
  def get_coin_data(%{id: coin_id}) do
    endpoint =
      Path.join([
        Application.get_env(:messenger_chat_bot_server, :coin_gecko_api_base_url),
        "coins",
        coin_id,
        "market_chart"
      ])

    options = [params: [vs_currency: "usd", days: 14, interval: "daily"]]
    header = [{"Content-Type", "application/json"}]

    case HTTPoison.get(endpoint, header, options) do
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        message = "Coin with the id #{coin_id} not found"
        Logger.error(message)
        {:error, message}

      {:ok, %HTTPoison.Response{body: body}} ->
        body
        |> Jason.decode!()
        |> transform_coin_data()

      {:error, reason} ->
        Logger.error("Error in getting the coin data, #{inspect(reason)}")
        {:error, reason}
    end
  end

  def get_coin_data(%{name: coin_name}) do
    endpoint =
      Path.join(
        Application.get_env(:messenger_chat_bot_server, :coin_gecko_api_base_url),
        "search"
      )

    header = [{"Content-Type", "application/json"}]
    options = [params: [query: coin_name]]

    case HTTPoison.get(endpoint, header, options) do
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        message = "Coin with the name #{coin_name} not found"
        Logger.error(message)
        {:error, message}

      {:ok, %HTTPoison.Response{body: body}} ->
        body
        |> Jason.decode!()
        |> filter_coin_list()

      {:error, reason} ->
        Logger.error("Error in getting the coin data, #{inspect(reason)}")
        {:error, reason}
    end
  end
end
