use Mix.Config

config :flashfeed,
  crawler_news_outlets_config_path: "./test/data/news_outlets.json",
  request: Flashfeed.News.Crawler.Request.Mock
