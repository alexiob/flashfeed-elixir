defmodule Flashfeed.News.Crawler.Engine do
  @moduledoc false
  @callback fetch(Flashfeed.News.Entity.t()) :: {:ok, term} | {:error, String.t()}
  @callback update(Flashfeed.News.Entity.t() | nil, Flashfeed.News.Entity.t()) ::
              Flashfeed.News.Entity.t()
end
