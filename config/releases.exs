import(Config)

config :flashfeed, Flashfeed.Repo,
  database: System.get_env("FLASHFEED_DB_DATABASE", "flashfeed"),
  username: System.fetch_env!("FLASHFEED_DB_USERNAME"),
  password: System.fetch_env!("FLASHFEED_DB_PASSWORD"),
  hostname: System.fetch_env!("FLASHFEED_DB_HOSTNAME"),
  port: System.get_env("FLASHFEED_DB_PORT", "5432")
