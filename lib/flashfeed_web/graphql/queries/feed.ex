defmodule FlashfeedWeb.GraphQL.Schema.Queries.Feed do
  @moduledoc false
  use Absinthe.Schema.Notation

  alias FlashfeedWeb.GraphQL.Schema.Resolvers.Feed

  object :feed_queries do
    field :feeds, list_of(:feed) do
      description("A list of all available feeds")
      resolve(&Feed.list/3)
    end

    field :feed, :feed do
      description("Get a specific feed")
      arg :key, non_null(:string)
      resolve(&Feed.get/3)
    end
  end
end
