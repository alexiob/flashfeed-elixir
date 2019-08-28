defmodule FlashfeedTest do
  use ExUnit.Case
  doctest Flashfeed

  test "load news sources" do
    entities = Flashfeed.News.Sources.load()

    assert length(entities) >= 1

    Enum.each(entities, fn entity ->
      assert Ecto.UUID.cast(Map.get(entity, "uuid")) === {:ok, Map.get(entity, "uuid")}
    end)
  end

  test "fetch feeds" do
    entities = Flashfeed.News.Sources.load()

    for entity <- entities do
      case Flashfeed.News.Crawler.Engine.RaiNews.fetch(entity) do
        {:ok, feed} ->
          assert is_list(feed)

          new_entity_feeds = Keyword.get_values(feed, :ok)
          assert length(new_entity_feeds) === 4

          Enum.each(new_entity_feeds, fn feed_entry ->
            assert Flashfeed.News.Crawler.Utilities.entity_key(entity, feed_entry["name"]) ===
                     feed_entry["key"]
          end)

          entity_feeds = Flashfeed.News.Crawler.Engine.RaiNews.update(%{}, feed)

          assert length(Map.keys(entity_feeds)) === length(new_entity_feeds)
          assert is_map(entity_feeds["rainews-rainews-it-fvg-gr"])

        {:error, cause} ->
          raise(cause)
      end
    end
  end
end
