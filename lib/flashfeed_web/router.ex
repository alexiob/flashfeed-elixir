defmodule FlashfeedWeb.Router do
  use FlashfeedWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/v1/api", FlashfeedWeb do
    pipe_through :api

    get "/version", UtilitiesController, :version

    get "/alexa/flashfeed/:outlet/:source/:country/:region/:name", FeedController, :get
  end
end
