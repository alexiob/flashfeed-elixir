defmodule Flashfeed.News.Crawler do
  @moduledoc false

  use GenServer

  require Logger

  @fetch_feed_task_timeout 10_000
  @crawler_engine_module_signature "Elixir.Flashfeed.News.Crawler.Engine."

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    state = init_state(state)

    Logger.debug("Flashfeed.News.Crawler.init")

    schedule_update()

    {:ok, update(state)}
  end

  @doc false
  def init_state(state) do
    entities = Flashfeed.News.Sources.load()

    state
    |> Map.put(:entities, entities)
    |> Map.put(:entity_feeds, %{})
    |> Map.put(:crawler_engines, retrieve_crawler_engines())
  end

  def update(state) do
    entity_feeds = crawl_entities(state)
    update_feeds(state, entity_feeds)
  end

  # CLIENT FUNCTIONS

  def feed(%{outlet: _, source: _, country: _, region: _, name: _} = entry_fields) do
    entity_key = Flashfeed.News.Crawler.Utilities.entity_key(entry_fields)
    GenServer.call(__MODULE__, {:feed, entity_key})
  end

  # MESSAGE HANDLERS

  def handle_call({:feed, entity_key}, _from, state) do
    {reply, state} =
      case Map.get(state.entity_feeds, entity_key, nil) do
        nil ->
          {{:error, :unknown_key}, state}

        feed ->
          feed_data = feed_to_alexa(feed)
          {{:ok, feed_data}, state}
      end

    {:reply, reply, state}
  end

  def handle_info(:crawl, state) do
    schedule_update()

    {:noreply, update(state)}
  end

  # PRIVATE FUNCTIONS

  defp schedule_update() do
    Process.send_after(
      self(),
      :crawl,
      Application.get_env(:flashfeed, :crawler_every_seconds, 3600) * 1000
    )
  end

  @doc false
  def feed_to_alexa(feed) do
    feed_entry = %{
      "uid" => feed.uuid,
      "updateDate" => feed.update_date,
      "titleText" => feed.title_text,
      "mainText" => feed.main_text,
      "streamUrl" => feed.url,
      "redirectionUrl" => feed.redirection_url
    }

    [feed_entry]
  end

  defp crawl_entities(state) do
    # Logger.debug("Flashfeed.News.Crawler.crawl")

    entity_feeds =
      Enum.map(state.entities, fn entity ->
        Task.async(fn ->
          Logger.debug(
            "Flashfeed.News.Crawler.crawl: entity '#{entity.name}-#{entity.country}-#{
              entity.region
            }'"
          )

          crawler = Map.get(state.crawler_engines, entity.crawler, nil)

          if !crawler do
            {:error,
             "Flashfeed.News.Crawler.crawl: entity '#{entity.name}' has an unknown crawler engine named '#{
               entity.crawler
             }'"}
          else
            case crawler.fetch(entity) do
              {:ok, new_entity_feeds} ->
                entity_feeds = crawler.update(state.entity_feeds, new_entity_feeds)
                {:ok, entity_feeds}

              {:error, reason} ->
                {:error,
                 "Flashfeed.News.Crawler.crawl: entity '#{entity.name}' crawler engine '#{
                   entity.crawler
                 }' errored as #{reason}"}
            end
          end
        end)
      end)
      |> Enum.map(fn task -> Task.await(task, @fetch_feed_task_timeout) end)

    feeds = Keyword.get_values(entity_feeds, :ok)
    errors = Keyword.get_values(entity_feeds, :error)

    Enum.each(errors, fn error ->
      Logger.error(error)
    end)

    entity_feeds =
      Enum.reduce(feeds, %{}, fn feed, acc ->
        Map.merge(acc, feed)
      end)

    entity_feeds
  end

  defp update_feeds(state, entity_feeds) do
    %{state | entity_feeds: entity_feeds}
  end

  defp retrieve_crawler_engines() do
    with {:ok, modules_list} = :application.get_key(:flashfeed, :modules) do
      modules_list
      |> Enum.filter(fn module ->
        module |> to_string |> String.starts_with?(@crawler_engine_module_signature)
      end)
      |> Enum.reduce(%{}, fn module, acc ->
        Map.put(acc, Module.split(module) |> List.last() |> String.downcase(), module)
      end)
    end
  end
end
