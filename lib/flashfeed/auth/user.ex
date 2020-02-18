defmodule Flashfeed.Auth.User do
  use Ecto.Schema
  use Pow.Ecto.Schema

  # import Ecto.Changeset

  schema "users" do
    pow_user_fields()

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> pow_changeset(attrs)
  end
end
