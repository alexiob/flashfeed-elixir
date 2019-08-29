defmodule Flashfeed.Repo do
  use Ecto.Repo,
    otp_app: :flashfeed,
    adapter: Ecto.Adapters.Postgres
end
