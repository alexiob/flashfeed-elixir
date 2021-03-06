defmodule Flashfeed.Application do
  @moduledoc false

  use Application

  import Cachex.Spec

  require Logger

  @impl true
  def start(_type, _args) do
    Logger.debug("Flashfeed.Application.start: starting...")

    # :ets.new(:session, [:named_table, :public, read_concurrency: true])

    # List all child processes to be supervised
    children = children()

    opts = [strategy: :one_for_one, name: Flashfeed.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp children do
    children = [
      {Phoenix.PubSub, [name: Flashfeed.PubSub, adapter: Phoenix.PubSub.PG2]},
      Flashfeed.Repo,
      Flashfeed.News.Crawler,
      FlashfeedWeb.Telemetry,
      FlashfeedWeb.Endpoint,
      FlashfeedWeb.Presence,
      {Absinthe.Subscription, FlashfeedWeb.Endpoint},
      Supervisor.Spec.worker(Cachex, [
        :user_data_cache,
        [expiration: expiration(default: :timer.hours(1), interval: :timer.hours(1))]
      ])
    ]

    extra_children =
      case Application.get_env(:flashfeed, :pow)[:cache_store_backend] do
        Pow.Store.Backend.MnesiaCache ->
          File.mkdir_p!(Application.get_env(:mnesia, :dir))

          [
            {Pow.Store.Backend.MnesiaCache, [extra_db_nodes: [node()]]},
            Pow.Store.Backend.MnesiaCache.Unsplit
          ]

        _ ->
          []
      end

    children ++ extra_children
  end

  @impl true
  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    FlashfeedWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
