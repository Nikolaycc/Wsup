defmodule Wsup.Repo do
  use Ecto.Repo,
    otp_app: :wsup,
    adapter: Ecto.Adapters.Postgres
end
