use Mix.Config

config :flashfeed, Flashfeed.Repo,
  database: "flashfeed",
  username: "alex",
  password: "alex",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :flashfeed,
  crawler_news_outlets_config_path: "priv/test_news_outlets.json",
  request: Flashfeed.News.Crawler.Request.Mock

config :flashfeed, FlashfeedWeb.Endpoint,
  url: [host: "localhost"],
  server: false
