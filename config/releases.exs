import(Config)

config :tzdata, :data_dir, System.get_env("FLASHFEED_TZDATA", "/tmp/elixir_tzdata_data")

config :mnesia, dir: String.to_charlist(System.get_env("FLASHFEED_MNESIA", "/mnt/mnesia"))

config :flashfeed, Flashfeed.Repo,
  database: System.get_env("FLASHFEED_DB_DATABASE", "flashfeed"),
  username: System.fetch_env!("FLASHFEED_DB_USERNAME"),
  password: System.fetch_env!("FLASHFEED_DB_PASSWORD"),
  hostname: System.fetch_env!("FLASHFEED_DB_HOSTNAME"),
  port: System.get_env("FLASHFEED_DB_PORT", "5432")

config :flashfeed, FlashfeedWeb.Endpoint,
  server: true,
  http: [port: System.get_env("FLASHFEED_PORT", "80")],
  url: [port: System.get_env("FLASHFEED_PORT", "80")],
  cache_static_manifest: "priv/static/cache_manifest.json",
  debug_errors: false,
  code_reloader: false,
  check_origin: false,
  watchers: []
