defmodule FlashfeedWeb.FeedController do
  use FlashfeedWeb, :controller

  action_fallback(FlashfeedWeb.FallbackController)

  def show(
        conn,
        %{
          "format" => "amazon_alexa"
        } = params
      ) do
    render_feed(conn, params)
  end

  defp render_feed(conn, %{
         "format" => format,
         "outlet" => outlet,
         "source" => source,
         "country" => country,
         "region" => region,
         "name" => name
       }) do
    {:ok, feed} =
      Flashfeed.News.Crawler.feed(%{
        outlet: outlet,
        source: source,
        country: country,
        region: region,
        name: name,
        format: String.to_atom(format)
      })

    render(conn, "feed.json", feed: feed)
  end
end
