defmodule Cloud.Repo do
  use Ecto.Repo,
    otp_app: :cloud,
    adapter: Ecto.Adapters.Postgres
end
