# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :flashfeed, ecto_repos: [Flashfeed.Repo]

config :flashfeed, Flashfeed.Repo,
  database: "flashfeed",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"

config :flashfeed,
  env: Mix.env(),
  crawler_every_seconds: 3600,
  crawler_news_outlets_config_path: "priv/news_outlets.json",
  request: Flashfeed.News.Crawler.Request,
  supported_media_types: ["audio", "video"]

# Configures the endpoint
config :flashfeed, FlashfeedWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "HdiRX3eQXDSvyt+mzCVtq0mrRha0VI/MW5dyPJleMuMjvzrAskMku68+k9YnfvHq",
  render_errors: [view: FlashfeedWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Flashfeed.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "yxk+Z71c1eFJhk38fbQz3lqGxQRbQNDG"
  ]

config :flashfeed, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      # phoenix routes will be converted to swagger paths
      router: FlashfeedWeb.Router,
      # (optional) endpoint config used to set host, port and https schemes.
      endpoint: FlashfeedWeb.Endpoint
    ]
  }

config :phoenix_swagger, json_library: Jason

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :phoenix, :template_engines, leex: Phoenix.LiveView.Engine

config :cors_plug,
  origin: ["*"]

config :flashfeed, :pow,
  user: Flashfeed.Auth.User,
  repo: Flashfeed.Repo,
  web_module: FlashfeedWeb,
  controller_callbacks: FlashfeedWeb.UserAuthenticationCallbacks
  # extensions: [FlashfeedWeb.UserAuthenticationCallbacks]

#
# and access this configuration in your application as:
#
#     Application.get_env(:flashfeed, :key)
#
# You can also configure a third-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#

import_config "#{Mix.env()}.exs"
