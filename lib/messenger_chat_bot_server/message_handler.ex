defmodule MessengerChatBotServer.MessageHandler do
  alias MessengerChatBotServer.{Bot, Message, MessageTemplate, Coin}


  defp send_search_options(event) do
    buttons = [
      {:postback, "By ID", "SEARCH_BY_ID"},
      {:postback, "By Name", "SEARCH_BY_NAME"}
    ]
    template_title = "Would you like to search coin by name or by id?"
    button_template = MessageTemplate.buttons(event, template_title, buttons)
    Bot.send_message(button_template)
end

def get_coin_names(coins) do
  Enum.reduce(coins, [], fn %{"name" => coin_name}, acc -> acc ++ [coin_name] end)
end

  def handle_message("GET_STARTED", event) do
    {:ok, profile} = Message.get_profile(event)
    {:ok, first_name} = Map.fetch(profile, "first_name")
    message = """
    Hello #{first_name}! Welcome to Crypto Mind.
    """
    resp_template = MessageTemplate.text(event, message) |> IO.inspect
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

  def handle_message(%{"text" => "id="<>coin_id}, event) do
    title = "Last 14 days prices in USD"
    search_result = title <> "\n" <> Coin.get_coin_data(%{id: coin_id})
    resp_template = MessageTemplate.text(event, search_result)
    Bot.send_message(resp_template)
  end


  def handle_message(%{"text" => "name="<>coin_name}, event) do
    search_result =
      %{name: coin_name}
      |> Coin.get_coin_data()
      |> get_coin_names()
    template_title = "Select the coin to get data"
    quick_response_template = MessageTemplate.quick_response(event, template_title, search_result)
    Bot.send_message(quick_response_template)
  end

  def handle_message(%{"text" => "hi"}, event) do
    {:ok, profile} = Message.get_profile(event)
    {:ok, first_name} = Map.fetch(profile, "first_name")
    message = "Hello #{first_name}!"
    resp_template = MessageTemplate.text(event, message)
    Bot.send_message(resp_template)
  end

  def handle_message(_message, event) do
    greetings = Message.greet()

    message = """
    #{greetings}
    Unknown Message Received
    """

    msg_template = MessageTemplate.text(event, message)
    Bot.send_message(msg_template)
  end
end
