defmodule FlashfeedWeb.UtilitiesController do
  use FlashfeedWeb, :controller

  action_fallback(FlashfeedWeb.FallbackController)

  def version(conn, _params) do
    render(conn, "version.txt",
      name: "flashfeed-elixir",
      version: Application.spec(:flashfeed, :vsn) |> to_string()
    )
  end
end
