defmodule FlashfeedWeb.FeedController do
  use FlashfeedWeb, :controller

  action_fallback(FlashfeedWeb.FallbackController)

  def get(conn, %{"outlet" => outlet, "source" => source, "country" => country, "region" => region, "name" => name}) do
    {:ok, feed} = Flashfeed.News.Crawler.feed(%{outlet: outlet, source: source, country: country, region: region, name: name})

    render(conn, "feed.json", feed: feed)
  end
end
