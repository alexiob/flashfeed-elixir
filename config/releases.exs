import(Config)

config :flashfeed, Flashfeed.Repo,
  database: System.fetch_env!("FLASHFEED_DB_DATABASE"),
  username: System.fetch_env!("FLASHFEED_DB_USERNAME"),
  password: System.fetch_env!("FLASHFEED_DB_PASSWORD"),
  hostname: System.fetch_env!("FLASHFEED_DB_HOSTNAME"),
  port: System.fetch_env!("FLASHFEED_DB_PORT")

config :flashfeed, FlashfeedWeb.Endpoint,
  http: [
    url: System.fetch_env!("FLASHFEED_ENDPOINT_URL"),
    port: System.fetch_env!("FLASHFEED_ENDPOINT_PORT")
  ],
  secret_key_base: System.fetch_env!("FLASHFEED_ENDPOINT_SECRET_KEY_BASE"),
  live_view: [
    signing_salt: System.fetch_env!("FLASHFEED_ENDPOINT_LIVEVIEW_SIGNING_SALT")
  ]

config :mnesia, dir: System.fetch_env!("FLASHFEED_MNESIA_FOLDER")
