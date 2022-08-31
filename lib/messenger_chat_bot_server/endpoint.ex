defmodule MessengerChatBotServer.Endpoint do
  @moduledoc """
  Endpoint is helper module which provides api endpoints.
  """

  @spec get_messenger_profile_endpoint :: binary
  def get_messenger_profile_endpoint() do
    facebook_chat_bot = Application.get_env(:messenger_chat_bot_server, :facebook_chat_bot)
    token = facebook_chat_bot.page_access_token
    message_url = facebook_chat_bot.profile_url
    base_url = facebook_chat_bot.base_url
    version = facebook_chat_bot.api_version
    token_path = "?access_token=#{token}"
    Path.join([base_url, version, message_url, token_path])
  end

  @spec bot_endpoint :: binary
  def bot_endpoint() do
    facebook_chat_bot = Application.get_env(:messenger_chat_bot_server, :facebook_chat_bot)
    token = facebook_chat_bot.page_access_token
    message_url = facebook_chat_bot.message_url
    base_url = facebook_chat_bot.base_url
    version = facebook_chat_bot.api_version
    token_path = "?access_token=#{token}"
    Path.join([base_url, version, message_url, token_path])
  end
end
