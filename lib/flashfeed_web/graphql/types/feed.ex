defmodule FlashfeedWeb.GraphQL.Schema.Types.Feed do
  @moduledoc false
  use Absinthe.Schema.Notation

  object :feed do
    field :uuid, :string
    field :name, :string
    field :title, :string
    field :date, :naive_datetime
    field :url, :string
    field :media_type, :string
    field :key, :string
    field :updated_at, :naive_datetime
    field :title_text, :string
    field :main_text, :string
    field :redirection_url, :string
  end
end
