defmodule MessengerChatBotServer do
  @moduledoc """
  MessengerChatBotServer handles the messages coming from chatbot user.
  """

  alias MessengerChatBotServer.{Bot, Message, MessageHandler}

  require Logger

  @spec get_started :: :error | :ok
  def get_started(), do: Bot.get_started()

  @spec handle_event(nil | maybe_improper_list | map) :: :error | :ok
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

        Bot.send_message(error_template)
    end
  end
end
