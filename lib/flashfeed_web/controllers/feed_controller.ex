defmodule FlashfeedWeb.FeedController do
  use FlashfeedWeb, :controller
  use PhoenixSwagger

  action_fallback(FlashfeedWeb.FallbackController)

  @request Application.get_env(:flashfeed, :request)

  swagger_path :show do
    get("/api/v1/feed/{format}/{outlet}/{source}/{country}/{region}/{name}")
    description("Returns a properly formatted news feed.")
    produces("application/json")

    parameters do
      format(:path, :string, "Response format", required: true, default: "amazon_alexa")
      outlet(:path, :string, "News outled", required: true, default: "rainews")
      source(:path, :string, "News source", required: true, default: "rainews")
      country(:path, :string, "Country", required: true, default: "it")
      region(:path, :string, "Region", required: true, default: "fvg")
      name(:path, :string, "News feed name", required: true, default: "gr")
    end

    # response(200, "Success")
  end

  def show(
        conn,
        %{
          "format" => "amazon_alexa"
        } = params
      ) do
    render_feed(conn, params)
  end

  def proxy(conn, %{"url" => url} = _params) do
    @request.proxy(conn, url)
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
