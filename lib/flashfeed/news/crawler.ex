defmodule Flashfeed.News.Crawler do
  @moduledoc false

  use GenServer

  require Logger

  alias Flashfeed.News.Crawler.Utilities
  alias Flashfeed.News.Sources

  @fetch_feed_task_timeout 10_000
  @crawler_engine_module_signature "Elixir.Flashfeed.News.Crawler.Engine."
  @topic_entity_feeds "entity_feeds"

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    state = init_state(%{})

    Logger.debug("Flashfeed.News.Crawler.init")

    {:ok, state, {:continue, :crawl}}
  end

  @doc """
  This is public so it can be used in tests. Is this the proper approach?
  """
  def init_state(state) do
    entities = Sources.load()

    state
    |> Map.put(:entities, entities)
    |> Map.put(:entity_feeds_last_update, nil)
    |> Map.put(:entity_feeds, %{})
    |> Map.put(:crawler_engines, retrieve_crawler_engines())
  end

  @doc """
  Updates the `entity_feeds` state entry with the latest news feeds, if any.
  """
  def update(state) do
    state
    |> crawl_entities()
  end

  def subscribe do
    Logger.debug("Flashfeed.News.Crawler.subscribe: #{inspect(self())}")
    Phoenix.PubSub.subscribe(Flashfeed.PubSub, @topic_entity_feeds)
  end

  # CLIENT FUNCTIONS

  @doc """
  List available feeds
  """
  def entity_feeds do
    GenServer.call(__MODULE__, {:entity_feeds})
  end

  @doc """
  Get last time the feeds where updated
  """
  def entity_feeds_last_update do
    GenServer.call(__MODULE__, {:entity_feeds_last_update})
  end

  @doc """
  Gets the feed
  """
  def feed(%{outlet: _, source: _, country: _, region: _, name: _, format: format} = entry_fields) do
    entity_key = Utilities.entity_key(entry_fields)
    GenServer.call(__MODULE__, {:feed, entity_key, format})
  end

  # MESSAGE HANDLERS

  @impl true
  def handle_continue(:crawl, state) do
    {:noreply, crawl(state)}
  end

  @impl true
  def handle_call({:entity_feeds}, _from, state) do
    {:reply, state.entity_feeds, state}
  end

  @impl true
  def handle_call({:entity_feeds_last_update}, _from, state) do
    {:reply, state.entity_feeds_last_update, state}
  end

  @impl true
  def handle_call({:feed, entity_key, format}, _from, state) do
    {reply, state} =
      case Map.get(state.entity_feeds, entity_key, nil) do
        nil ->
          {{:error, :unknown_key}, state}

        feed ->
          {feed_to_format(feed, format), state}
      end

    {:reply, reply, state}
  end

  @impl true
  def handle_info(:crawl, state) do
    {:noreply, crawl(state)}
  end

  # Public, for testing purposes
  @doc """
  Supported formats are:
  * :amazon_alexa
  """
  def feed_to_format(feed, format) do
    case format do
      :amazon_alexa -> {:ok, feed_to_amazon_alexa(feed)}
      :google_assistant -> {:ok, feed_to_google_assistant(feed)}
      _ -> {:error, "unknown '#{format}' feed format "}
    end
  end

  defp feed_to_amazon_alexa(feed) do
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

  defp feed_to_google_assistant(_feed) do
    throw("not implemented")
  end

  # PRIVATE FUNCTIONS

  defp crawl(state) do
    schedule_update()

    state
    |> update()
    |> notify_updated_feeds()
  end

  defp schedule_update do
    Process.send_after(
      self(),
      :crawl,
      Application.get_env(:flashfeed, :crawler_every_seconds, 3600) * 1000
    )
  end

  defp entity_crawler(entity, state) do
    Task.async(fn ->
      # Logger.debug(
      #   "Flashfeed.News.Crawler.crawl: entity '#{entity.name}-#{entity.country}-#{entity.region}'"
      # )

      crawler = Map.get(state.crawler_engines, entity.crawler, nil)

      if crawler do
        case crawler.fetch(entity) do
          {:ok, new_entity_feeds} ->
            entity_feeds = crawler.update(state.entity_feeds, new_entity_feeds)
            {:ok, entity_feeds}

          {:error, reason} ->
            {:error,
             "Flashfeed.News.Crawler.crawl: entity '#{entity.name}' crawler engine '#{
               entity.crawler
             }' errored as #{inspect(reason)}"}
        end
      else
        {:error,
         "Flashfeed.News.Crawler.crawl: entity '#{entity.name}' has an unknown crawler engine named '#{
           entity.crawler
         }'"}
      end
    end)
  end

  defp crawl_entities(state) do
    Logger.info("Flashfeed.News.Crawler.crawl_entities: started at #{DateTime.utc_now()}")

    entity_feeds =
      Enum.map(state.entities, fn entity ->
        entity_crawler(entity, state)
      end)
      |> Enum.map(fn task -> Task.await(task, @fetch_feed_task_timeout) end)

    feeds = Keyword.get_values(entity_feeds, :ok)
    errors = Keyword.get_values(entity_feeds, :error)

    Enum.each(errors, fn error ->
      Logger.error(error)
    end)

    entity_feeds =
      case length(feeds) do
        0 ->
          Map.get(state, :entity_feeds, %{})

        _ ->
          Enum.reduce(feeds, %{}, fn feed, acc ->
            Map.merge(acc, feed)
          end)
      end

    %{state | entity_feeds: entity_feeds, entity_feeds_last_update: NaiveDateTime.local_now()}
  end

  defp notify_updated_feeds(state) do
    Phoenix.PubSub.broadcast(
      Flashfeed.PubSub,
      @topic_entity_feeds,
      %{event: :feeds_update, state: state}
    )

    state
  end

  # Scans all modules in search for the ones starting with the given prefix.
  # The engine name is the lowercase version of the last module name part.
  defp retrieve_crawler_engines do
    with {:ok, modules_list} <- :application.get_key(:flashfeed, :modules) do
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
