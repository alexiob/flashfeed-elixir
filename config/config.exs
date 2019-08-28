# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :flashfeed,
  crawler_every_seconds: 3600,
  crawler_news_outlets_config_path: "./priv/news_outlets.json",
  request: Flashfeed.News.Crawler.Request

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
