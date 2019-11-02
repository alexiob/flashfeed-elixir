defmodule FlashfeedWeb.Router do
  use FlashfeedWeb, :router

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

  scope "/api/v1", FlashfeedWeb do
    pipe_through :api

    get "/version", UtilitiesController, :version

    get "/:format/:outlet/:source/:country/:region/:name", FeedController, :show
  end

  scope "/", FlashfeedWeb do
    pipe_through :browser

    get "/", PageController, :index
  end
end
