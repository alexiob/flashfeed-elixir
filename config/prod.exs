use Mix.Config

config :flashfeed,
  crawler_news_outlets_config_path: "priv/news_outlets.json"

config :flashfeed, FlashfeedWeb.Endpoint,
  server: true,
  http: [port: 41_384],
  url: [port: 41_384],
  cache_static_manifest: "priv/static/cache_manifest.json",
  debug_errors: false,
  code_reloader: false,
  check_origin: false,
  # render_errors: [view: FlashfeedWeb.ErrorView, accepts: ~w(html json)],
  watchers: []

config :phoenix,
  persistent: true

config :logger, level: :info

# config :mnesia, dir: '/mnt/mnesia'
config :mnesia, dir: './tmp/mnesia'
