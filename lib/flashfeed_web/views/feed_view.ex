defmodule FlashfeedWeb.FeedView do
  use FlashfeedWeb, :view

  def render("feed.json", %{feed: feed}) do
    feed
  end
end
