defmodule FlashfeedWeb.APIAuthErrorHandler do
  @moduledoc false
  use FlashfeedWeb, :controller

  require Logger

  @spec call(Plug.Conn.t(), :not_authenticated) :: Plug.Conn.t()
  def call(conn, :not_authenticated) do
    conn
    |> put_status(Plug.Conn.Status.code(:unauthorized))
    |> json(%{
      error: %{
        code: Plug.Conn.Status.code(:unauthorized),
        message: "Not authenticated"
      }
    })
  end
end
