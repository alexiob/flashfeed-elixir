defmodule FlashfeedWeb.Router do
  @moduledoc false

  use FlashfeedWeb, :router
  use Pow.Phoenix.Router

  import Phoenix.LiveView.Router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {FlashfeedWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]

    plug FlashfeedWeb.Plug.APIAuth, otp_app: :flashfeed
  end

  pipeline :browser_protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: Pow.Phoenix.PlugErrorHandler
  end

  pipeline :api_protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: FlashfeedWeb.APIAuthErrorHandler
  end

  scope "/auth" do
    pipe_through :browser

    pow_routes()
  end

  scope "/api/v1", FlashfeedWeb, as: :api_v1 do
    pipe_through :api

    get "/version", UtilitiesController, :version

    get "/feed/:format/:outlet/:source/:country/:region/:name", FeedController, :show
  end

  scope "/api/v1", FlashfeedWeb, as: :api_v1 do
    pipe_through [:api, :api_protected]

    get "/proxy/*url", FeedController, :proxy
  end

  scope "/api" do
    pipe_through [:api, :api_protected]

    forward "/graphql",
            Absinthe.Plug,
            schema: FlashfeedWeb.GraphQL.Schema,
            socket: FlashfeedWeb.UserSocket

    forward "/graphiql",
            Absinthe.Plug.GraphiQL,
            schema: FlashfeedWeb.GraphQL.Schema,
            interface: :simple
  end

  scope "/docs/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :flashfeed, swagger_file: "swagger.json"
  end

  scope "/" do
    pipe_through [:browser, :browser_protected]

    get "/", FlashfeedWeb.PageController, :index
    live_dashboard "/dashboard"
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
