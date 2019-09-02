defmodule Flashfeed.Application do
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    Logger.debug("Flashfeed.Application.start: starting...")

    # List all child processes to be supervised
    children = [
      FlashfeedWeb.Endpoint,
      Flashfeed.News.Crawler
    ]

    opts = [strategy: :one_for_one, name: Flashfeed.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    FlashfeedWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
