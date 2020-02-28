defmodule FlashfeedWeb.GraphQL.Schema do
  @moduledoc """
  All GraphQL schemas
  """
  use Absinthe.Schema

  import_types(Absinthe.Type.Custom)

  import_types(__MODULE__.Types.{
    Feed
  })

  import_types(__MODULE__.Queries.{
    Feed
  })

  query do
    @desc "Pong back a ping message"
    field :ping, type: :string do
      arg :message, non_null(:string)
      resolve(fn (_parent, %{message: message}, _resolution) ->
        {:ok, "pong: #{message}"}
      end)
    end

    import_fields(:feed_queries)
  end
end
