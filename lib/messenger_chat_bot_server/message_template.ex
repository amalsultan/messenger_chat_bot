defmodule MessengerChatBotServer.MessageTemplate do
  @moduledoc """
  MessengerTemplate create the templates to display appropriate formatted messages
  """
  alias MessengerChatBotServer.Message

  defp prepare_button({message_type, title, payload}) do
    %{
      "type" => "#{message_type}",
      "title" => title,
      "payload" => payload
    }
  end

  defp prepare_quick_reply({message_type, title, payload}) do
    %{
      "content_type" => "#{message_type}",
      "title" => title,
      "payload" => payload
    }
  end

  defp recipient(event) do
    %{"id" => Message.get_sender(event)["id"]}
  end

  defp attachment(type, payload) do
    %{
      "type" => type,
      "payload" => payload
    }
  end

  defp template(recipient, message) do
    %{
      "message" => message,
      "recipient" => recipient
    }
  end

  @spec text(nil | maybe_improper_list | map, String.t()) :: map()
  def text(event, text) do
    %{
      "recipient" => recipient(event),
      "message" => %{"text" => text}
    }
  end

  @spec buttons(nil | maybe_improper_list | map, String.t(), list()) :: map()
  def buttons(event, template_title, buttons) do
    buttons = Enum.map(buttons, &prepare_button/1)

    payload = %{
      "template_type" => "button",
      "text" => template_title,
      "buttons" => buttons
    }

    recipient = recipient(event)

    message = %{
      "attachment" => attachment("template", payload)
    }

    template(recipient, message)
  end

  @spec quick_response(nil | maybe_improper_list | map, String.t(), list()) :: map()
  def quick_response(event, template_title, replies) do
    quick_responses = Enum.map(replies, &prepare_quick_reply/1)

    payload = %{
      "text" => template_title,
      "quick_replies" => quick_responses
    }

    recipient = recipient(event)
    message = payload
    template(recipient, message)
  end
end
