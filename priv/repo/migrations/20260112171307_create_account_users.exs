defmodule Billwatch.Repo.Migrations.CreateAccountUsers do
  use Ecto.Migration

  def change do
    create table(:account_users, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :account_id, references(:accounts, type: :binary_id, on_delete: :delete_all),
        null: false

      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :role, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:account_users, [:account_id])
    create unique_index(:account_users, [:user_id])
  end
end
