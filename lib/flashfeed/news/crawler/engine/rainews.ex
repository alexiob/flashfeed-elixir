defmodule Flashfeed.News.Crawler.Engine.RaiNews do
  @moduledoc """
  Rai News feed crawler.
  """
  @behaviour Flashfeed.News.Crawler.Engine

  require Logger

  @request Application.get_env(:flashfeed, :request)

  alias Flashfeed.News.Crawler.Utilities

  @fetch_entity_task_timeout 10_000

  @impl Flashfeed.News.Crawler.Engine
  def fetch(%Flashfeed.News.Entity{} = entity) do
    case @request.get(entity.url, false) do
      {:ok, body} ->
        # Kept here for creating the test data in case of changes in the input data format
        # {:ok, file} = File.open("test/data/rainews-it-source.html", [:write])
        # IO.binwrite(file, body)
        # File.close(file)

        {:ok, document} = Floki.parse_document(body)
        data = Floki.find(document, "[data-feed]")

        data_feeds =
          Enum.map(data, fn feed ->
            fetch_entity_feed(entity, feed)
          end)
          |> Enum.map(fn task -> Task.await(task, @fetch_entity_task_timeout) end)

        {:ok, data_feeds}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl Flashfeed.News.Crawler.Engine
  def update(current_entity_feeds, new_entity_feeds) do
    Keyword.get_values(new_entity_feeds, :ok)
    |> Enum.reduce(%{}, fn feed, acc ->
      current_feed = Map.get(current_entity_feeds, feed.key, nil)

      case is_updated(current_feed, feed) do
        true -> Map.put(acc, feed.key, feed)
        false -> Map.put(acc, feed.key, %{current_feed | checked_at: feed.checked_at})
      end
    end)
  end

  @doc false
  def is_updated(cur, %Flashfeed.News.Feed{} = new) do
    case cur do
      nil ->
        true

      _ ->
        !(cur.url === new.url && cur.title === new.title &&
            cur.date === new.date)
    end
  end

  defp fetch_entity_feed(%Flashfeed.News.Entity{} = entity, feed) do
    Task.async(fn ->
      name =
        Floki.text(feed)
        |> String.downcase()
        |> String.replace(" ", "_")

      content_url = "#{entity.base_url}#{List.first(Floki.attribute(feed, "data-feed"))}"

      fetch_entity_feed(entity, name, content_url)
    end)
  end

  defp fetch_entity_feed(%Flashfeed.News.Entity{} = entity, name, url) do
    entity_feed =
      case @request.get(url, true) do
        {:ok, content} ->
          # Kept here for creating the test data in case of changes in the input data format
          # filename = Path.basename(URI.parse(url).path)
          # {:ok, file} = File.open("test/data/#{filename}", [:write])
          # IO.binwrite(file, Jason.encode!(content))
          # File.close(file)

          # Logger.debug(
          #   ">>> rainews.fetch_entity_feed[#{name}][#{url}]: #{inspect(content, pretty: true)}"
          # )

          if content["count"] > 0 do
            item = List.first(content["items"])
            updated_at = DateTime.utc_now()
            update_date = "#{Timex.format!(updated_at, "%Y-%m-%dT%H:%M:%S", :strftime)}Z"

            title_text =
              String.replace(
                "#{String.upcase(entity.title)} #{String.upcase(name)} #{item["title"]}",
                "_",
                " "
              )

            main_text = ""

            {:ok,
             %Flashfeed.News.Feed{
               uuid: Utilities.entity_uuid(),
               name: name,
               title: item["title"],
               date: parse_date(item["date"]),
               url: Utilities.https_url(item["mediaUrl"]),
               media_type: Utilities.media_type(item["type"]),
               key: Utilities.entity_key(entity, name),
               checked_at: updated_at,
               updated_at: updated_at,
               title_text: title_text,
               main_text: main_text,
               redirection_url: entity.url,
               update_date: update_date
             }}
          end

        {:error, reason} ->
          {:error,
           "Flashfeed.News.Crawler.RaiNews.fetch: error fetching '#{entity.name}' content URL '#{
             url
           }': #{reason}"}
      end

    entity_feed
  end

  defp parse_date(date) do
    case Timex.parse(date, "{0D}/{0M}/{YYYY}") do
      {:ok, datetime} -> datetime
      {:error, reason} -> reason
    end
  end
end
