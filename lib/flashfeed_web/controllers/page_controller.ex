defmodule FlashfeedWeb.PageController do
  use FlashfeedWeb, :controller

  plug FlashfeedWeb.Plug.AssignUser

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
