defmodule FlashfeedWeb.Plug.AssignUser do
  @moduledoc false
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
        |> put_session(:live_socket_id, "users_sockets:#{user.id}")
      _ ->
        conn
        |> assign(:current_user, nil)
        |> delete_session(:live_socket_id)
    end
  end
end
