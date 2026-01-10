defmodule Billwatch.Repo do
  use Ecto.Repo,
    otp_app: :billwatch,
    adapter: Ecto.Adapters.SQLite3
end
