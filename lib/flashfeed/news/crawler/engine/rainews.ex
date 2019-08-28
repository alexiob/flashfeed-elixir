defmodule Flashfeed.News.Crawler.Engine.RaiNews do
  @moduledoc false

  require Logger

  @request Application.get_env(:flashfeed, :request)

  alias Flashfeed.News.Crawler.Utilities

  @fetch_entity_task_timeout 10_000

  def fetch(entity) do
    case @request.get(entity["url"], false) do
      {:ok, body} ->
        # Kept here for creatingthe test data in case of changes in the input data format
        # {:ok, file} = File.open("test/data/rainews-it-source.html", [:write])
        # IO.binwrite(file, body)
        # File.close(file)

        data =
          body
          |> Floki.find("[data-feed]")

        data_feeds =
          Enum.map(data, fn feed ->
            Task.async(fn ->
              name =
                Floki.text(feed)
                |> String.downcase()
                |> String.replace(" ", "_")

              content_url =
                "#{entity["base_url"]}#{List.first(Floki.attribute(feed, "data-feed"))}"

              fetch_entity_feed(name, content_url, entity)
            end)
          end)
          |> Enum.map(fn task -> Task.await(task, @fetch_entity_task_timeout) end)

        {:ok, data_feeds}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def update(current_entity_feeds, new_entity_feeds) do
    new_entity_feeds =
      Keyword.get_values(new_entity_feeds, :ok)
      |> Enum.filter(fn feed ->
        current_feed = Map.get(current_entity_feeds, feed["key"], nil)
        is_updated(current_feed, feed)
      end)
      |> Enum.reduce(%{}, fn feed, acc ->
        Map.put(acc, feed["key"], feed)
      end)

    Map.merge(current_entity_feeds, new_entity_feeds)
  end

  defp is_updated(cur, new) do
    case cur do
      nil ->
        true

      _ ->
        !(cur["url"] === new["url"] && cur["title"] === new["title"] &&
            cur["date"] === new["date"])
    end
  end

  defp fetch_entity_feed(name, url, entity) do
    entity_feed =
      case @request.get(url, true) do
        {:ok, content} ->
          # Kept here for creatingthe test data in case of changes in the input data format
          # filename = Path.basename(URI.parse(url).path)
          # {:ok, file} = File.open("test/data/#{filename}", [:write])
          # IO.binwrite(file, Poison.encode!(content))
          # File.close(file)

          if content["count"] > 0 do
            item = List.first(content["items"])

            {:ok,
             %{
               "name" => name,
               "uuid" => Utilities.entity_uuid(),
               "title" => item["title"],
               "date" => parse_date(item["date"]),
               "url" => Utilities.https_url(item["mediaUrl"]),
               "media_type" => Utilities.media_type(item["type"]),
               "key" => Utilities.entity_key(entity, name),
               "updated_at" => DateTime.utc_now()
             }}
          end

        {:error, reason} ->
          {:error,
           "Flashfeed.News.Crawler.RaiNews.fetch: error fetching '#{entity["entity_name"]}' content URL '#{
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
