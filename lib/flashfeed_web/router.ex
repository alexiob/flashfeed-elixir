defmodule FlashfeedWeb.Router do
  use FlashfeedWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", FlashfeedWeb do
    pipe_through :api

    get "/version", UtilitiesController, :version

    get "/:format/:outlet/:source/:country/:region/:name", FeedController, :show
  end
end
