defmodule MessengerChatBotServer.Bot do
  @moduledoc false

  alias MessengerChatBotServer.Endpoint

  require Logger

  def get_started() do
    msg_template = %{
      "get_started" => %{"payload" => "GET_STARTED"},
      "persistent_menu" => [
        %{
          "locale" => "default",
          "composer_input_disabled" => false,
          "call_to_actions" => [
            %{
              "type" => "postback",
              "title" => "Talk to an agent",
              "payload" => "CARE_HELP"
            },
            %{
              "type" => "postback",
              "title" => "Get Started again",
              "payload" => "CURATION"
            }
          ]
        }
      ]
    }

    http_poison_message = Poison.encode!(msg_template)
    header = [{"Content-Type", "application/json"}]
    endpoint = Endpoint.get_messenger_profile_endpoint()

    case HTTPoison.post(endpoint, http_poison_message, header) do
      {:ok, _response} ->
        :ok
        Logger.info("Message Sent")

      {:error, reason} ->
        Logger.error("Error in sending message, #{inspect(reason)}")
        :error
    end
  end

  def verify_webhook(params) do
    facebook_chat_bot = Application.get_env(:messenger_chat_bot_server, :facebook_chat_bot)
    mode = params["hub.mode"]
    token = params["hub.verify_token"]
    mode == "subscribe" && token == facebook_chat_bot.webhook_verify_token
  end

  def send_message(msg_template) do
    endpoint = Endpoint.bot_endpoint()
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
