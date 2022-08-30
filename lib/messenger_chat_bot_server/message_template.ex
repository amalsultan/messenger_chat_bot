defmodule MessengerChatBotServer.MessageTemplate do
  alias MessengerChatBotServer.Message
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

  def quick_response(event, template_title, responses) do
    quick_responses = Enum.map(responses, &prepare_button/1)
    payload = %{
      "template_type" => "button",
      "text" => template_title,
      "quick_replies" => quick_responses
    }
    recipient = recipient(event)
    message = %{
      "quick_replies" => attachment("template", payload)
    }
    template(recipient, message)
  end

  def prepare_button({message_type, title, payload}) do
    %{
      "type" => "#{message_type}",
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
  def text(event, text) do
   %{
     "recipient" => recipient(event),
      "message" => %{"text" => text }
     }
  end
end