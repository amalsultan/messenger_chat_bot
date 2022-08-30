defmodule MessengerChatBotServer do
  @moduledoc """
  MessengerChatBotServer keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias MessengerChatBotServer.{Message, MessageHandler}

  require Logger

  defp get_messenger_profile_endpoint() do
    facebook_chat_bot = Application.get_env(:messenger_chat_bot_server, :facebook_chat_bot)
    token = facebook_chat_bot.page_access_token
    message_url = facebook_chat_bot.profile_url
    base_url = facebook_chat_bot.base_url
    version = facebook_chat_bot.api_version
    token_path = "?access_token=#{token}"
    Path.join([base_url, version, message_url, token_path])
  end

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
    endpoint = get_messenger_profile_endpoint()

    case HTTPoison.post(endpoint, http_poison_message, header) do
      {:ok, _response} ->
        :ok
        Logger.info("Message Sent")

      {:error, reason} ->
        Logger.error("Error in sending message, #{inspect(reason)}")
        :error
    end
  end

  def handle_event(event) do
    case Message.get_messaging(event) do
      %{"message" => message} ->
        MessageHandler.handle_message(message, event)

      %{"postback" => %{"payload" => payload}} ->
        MessageHandler.handle_message(payload, event)

      _ ->
        error_template =
          MessengerChatBotServer.MessageTemplate.text(
            event,
            "Something went wrong. We are working on it."
          )

        MessengerChatBotServer.Bot.send_message(event, error_template)
    end
  end
end
