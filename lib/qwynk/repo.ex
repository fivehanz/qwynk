defmodule Qwynk.Repo do
  use Ecto.Repo,
    otp_app: :qwynk,
    adapter: Ecto.Adapters.Postgres
end
