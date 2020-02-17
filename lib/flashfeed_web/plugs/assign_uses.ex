defmodule FlashfeedWeb.Plug.AssignUser do
  import Plug.Conn

  require Logger

  alias Flashfeed.Auth.User
  alias Flashfeed.Repo

  def init(opts), do: opts

  def call(conn, params) do
    case Pow.Plug.current_user(conn) do
      %User{} = user ->
        conn
        |> assign(:current_user, Repo.preload(user, params[:preload] || []))
      _ ->
        conn
        |> assign(:current_user, nil)
    end
  end
end
