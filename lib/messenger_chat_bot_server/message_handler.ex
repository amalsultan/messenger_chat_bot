defmodule MessengerChatBotServer.MessageHandler do
  @moduledoc """
  MessageHandler handles the messages coming from chatbot user and responds with appropriate response.
  """

  alias MessengerChatBotServer.{Bot, Message, MessageTemplate, GeckoCoin}

  defp format_coin_data(acc, price) do
    formatted_price = Float.round(price, 10)
    "#{acc} \n #{Float.to_string(formatted_price)}"
  end

  defp transform_coin_data(%{"prices" => prices}),
    do: Enum.reduce(prices, "", fn [_timestamp, price], acc -> format_coin_data(acc, price) end)

  defp send_search_options(event) do
    buttons = [
      {:postback, "By ID", "SEARCH_BY_ID"},
      {:postback, "By Name", "SEARCH_BY_NAME"}
    ]

    template_title = "Would you like to search coin by name or by id?"
    button_template = MessageTemplate.buttons(event, template_title, buttons)
    Bot.send_message(button_template)
  end

  defp get_coin_names(coins) do
    Enum.reduce(coins, [], fn %{"name" => coin_name, "id" => coin_id}, acc ->
      acc ++ [{:text, coin_name, coin_id}]
    end)
  end

  defp retrieve_coin_data(coin_id, event) do
    message_template =
      %{id: coin_id}
      |> GeckoCoin.get_coin_data()
      |> transform_coin_data()
      |> case do
        {:error, reason} ->
          MessageTemplate.text(event, reason)

        search_result ->
          title = "Last 14 days prices in USD"
          message = title <> "\n" <> search_result
          MessageTemplate.text(event, message)
      end

    Bot.send_message(message_template)
  end

  @spec handle_message(any, nil | maybe_improper_list | map) :: :error | :ok
  def handle_message("GET_STARTED", event) do
    {:ok, profile} = Message.get_profile(event)
    {:ok, first_name} = Map.fetch(profile, "first_name")

    message = """
    Hello #{first_name}! Welcome to Crypto Mind.
    """

    resp_template = MessageTemplate.text(event, message)
    Bot.send_message(resp_template)
    send_search_options(event)
  end

  def handle_message("SEARCH_BY_ID", event) do
    message = """
    Enter Coin id as "id=124367"
    """

    resp_template = MessageTemplate.text(event, message)
    Bot.send_message(resp_template)
  end

  def handle_message("SEARCH_BY_NAME", event) do
    message = """
    Please Enter Coin name as "name=bitcoin"
    """

    resp_template = MessageTemplate.text(event, message)
    Bot.send_message(resp_template)
  end

  def handle_message(%{"quick_reply" => %{"payload" => coin_id}}, event),
    do: retrieve_coin_data(coin_id, event)

  def handle_message(%{"text" => "id=" <> coin_id}, event), do: retrieve_coin_data(coin_id, event)

  def handle_message(%{"text" => "name=" <> coin_name}, event) do
    message_template =
      %{name: coin_name}
      |> GeckoCoin.get_coin_data()
      |> transform_coin_data()
      |> case do
        {:error, reason} ->
          MessageTemplate.text(event, reason)

        search_result ->
          coin_names = get_coin_names(search_result)
          template_title = "Select the coin to get data"
          MessageTemplate.quick_response(event, template_title, coin_names)
      end

    Bot.send_message(message_template)
  end

  def handle_message(%{"text" => "hi"}, event) do
    {:ok, profile} = Message.get_profile(event)
    {:ok, first_name} = Map.fetch(profile, "first_name")
    message = "Hello #{first_name}!"
    resp_template = MessageTemplate.text(event, message)
    Bot.send_message(resp_template)
  end

  def handle_message(_message, event) do
    message = """
    Unknown Message Received
    """

    msg_template = MessageTemplate.text(event, message)
    Bot.send_message(msg_template)
  end
end
