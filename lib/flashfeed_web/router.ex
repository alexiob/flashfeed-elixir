defmodule FlashfeedWeb.Router do
  use FlashfeedWeb, :router
  use Pow.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, {FlashfeedWeb.LayoutView, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: Pow.Phoenix.PlugErrorHandler
  end

  scope "/auth" do
    pipe_through :browser

    pow_routes()
  end

  scope "/api/v1", FlashfeedWeb do
    pipe_through :api

    get "/version", UtilitiesController, :version
    get "/proxy/*url", FeedController, :proxy

    get "/feed/:format/:outlet/:source/:country/:region/:name", FeedController, :show
  end

  scope "/docs/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :flashfeed, swagger_file: "swagger.json"
  end

  scope "/", FlashfeedWeb do
    pipe_through [:browser, :protected]

    get "/", PageController, :index
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "Flashfeed"
      }
    }
  end
end
