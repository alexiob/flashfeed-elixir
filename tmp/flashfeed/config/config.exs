# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :flashfeed,
  ecto_repos: [Flashfeed.Repo]

# Configures the endpoint
config :flashfeed, FlashfeedWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "HdiRX3eQXDSvyt+mzCVtq0mrRha0VI/MW5dyPJleMuMjvzrAskMku68+k9YnfvHq",
  render_errors: [view: FlashfeedWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Flashfeed.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
