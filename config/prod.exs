use Mix.Config

config :flashfeed,
  crawler_news_outlets_config_path: "priv/news_outlets.json"

config :flashfeed, FlashfeedWeb.Endpoint,
  server: true,
  http: [port: 41384],
  # cache_static_manifest: "priv/static/cache_manifest.json",
  debug_errors: false,
  code_reloader: false,
  check_origin: false,
  watchers: []

config :phoenix,
  # plug_init_mode: :runtime,
  persistent: true
