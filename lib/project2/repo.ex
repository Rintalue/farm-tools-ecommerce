defmodule Project2.Repo do
  use Ecto.Repo,
    otp_app: :project2,
    adapter: Ecto.Adapters.Postgres
end
