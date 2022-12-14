# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :messenger_chat_bot_server, MessengerChatBotServerWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: MessengerChatBotServerWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: MessengerChatBotServer.PubSub,
  live_view: [signing_salt: "wc0I2Qu4"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :messenger_chat_bot_server, MessengerChatBotServer.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :messenger_chat_bot_server,
  facebook_chat_bot: %{
    message_url: "me/messages",
    api_version: "v14.0",
    base_url: "https://graph.facebook.com",
    page_access_token: System.get_env("PAGE_ACCESS_TOKEN"),
    profile_url: "me/messenger_profile",
    webhook_verify_token: System.get_env("VERIFY_TOKEN")
  },
  coin_gecko_api_base_url: "https://api.coingecko.com/api/v3/"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
