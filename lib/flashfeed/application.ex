defmodule Flashfeed.Application do
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    Logger.debug("Flashfeed.Application.start: starting...")

    # List all child processes to be supervised
    children = [
      Flashfeed.News.Crawler,
      FlashfeedWeb.Endpoint,
      FlashfeedWeb.Presence
    ]

    opts = [strategy: :one_for_one, name: Flashfeed.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    FlashfeedWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
