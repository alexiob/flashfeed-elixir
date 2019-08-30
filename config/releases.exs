import(Config)

config :flashfeed, FlashfeedWeb.Endpoint, http: [port: System.fetch_env!("PORT")]
