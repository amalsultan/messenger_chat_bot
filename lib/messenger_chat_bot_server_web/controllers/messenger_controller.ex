defmodule MessengerChatBotServerWeb.MessengerController do
  use MessengerChatBotServerWeb, :controller

  require Logger

  @spec verify_webhook_token(Plug.Conn.t(), nil | list() | map) :: Plug.Conn.t()
  def verify_webhook_token(conn, params) do
    verified? = MessengerChatBotServer.Bot.verify_webhook(params)

    if verified? do
      conn
      |> put_resp_content_type("application/json")
      |> resp(200, params["hub.challenge"])
      |> send_resp()
    else
      conn
      |> put_resp_content_type("application/json")
      |> resp(403, Jason.encode!(%{status: "error", message: "unauthorized"}))
    end
  end

  def handle_event(conn, event_data) do
    MessengerChatBotServer.handle_event(event_data)

    conn
    |> put_resp_content_type("application/json")
    |> resp(200, Jason.encode!(%{status: "ok"}))
  end
end
