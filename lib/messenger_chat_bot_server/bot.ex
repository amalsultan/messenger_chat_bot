defmodule MessengerChatBotServer.Bot do
  @moduledoc false

  require Logger

  def verify_webhook(params) do
    facebook_chat_bot = Application.get_env(:messenger_chat_bot_server, :facebook_chat_bot)
    mode = params["hub.mode"]
    token = params["hub.verify_token"]
    mode == "subscribe" && token == facebook_chat_bot.webhook_verify_token
  end

  def bot_endpoint() do
    facebook_chat_bot = Application.get_env(:messenger_chat_bot_server, :facebook_chat_bot)
    token = facebook_chat_bot.page_access_token
    message_url = facebook_chat_bot.message_url
    base_url = facebook_chat_bot.base_url
    version = facebook_chat_bot.api_version
    token_path = "?access_token=#{token}"
    Path.join([base_url, version, message_url, token_path])
  end

  def send_message(msg_template) do
    endpoint = bot_endpoint()
    http_poison_message = Poison.encode!(msg_template)
    header = [{"Content-Type", "application/json"}]

    case HTTPoison.post(endpoint, http_poison_message, header) do
      {:ok, _response} ->
        :ok
        Logger.info("Message Sent to Bot")

      {:error, reason} ->
        Logger.error("Error in sending message to bot, #{inspect(reason)}")
        :error
    end
  end
end
