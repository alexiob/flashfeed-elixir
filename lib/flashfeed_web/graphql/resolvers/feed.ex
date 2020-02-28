defmodule FlashfeedWeb.GraphQL.Schema.Resolvers.Feed do
  @moduledoc false
  use Absinthe.Schema.Notation

  alias Flashfeed.News.Crawler

  def list(_, _, _) do
    {:ok, Map.values(Crawler.entity_feeds())}
  end

  def get(_, %{key: key}, _) do
    case Map.get(Crawler.entity_feeds(), key) do
      nil -> {:error, "Feed with key '#{key}' not found"}
      feed -> {:ok, feed}
    end
  end
end
