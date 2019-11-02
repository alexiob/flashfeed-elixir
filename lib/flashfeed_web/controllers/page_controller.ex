defmodule FlashfeedWeb.PageController do
  use FlashfeedWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
