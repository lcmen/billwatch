defmodule Billwatch.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :account_id, references(:accounts, type: :binary_id, on_delete: :delete_all),
        null: false

      add :name, :string, null: false
      add :color, :string

      timestamps(type: :utc_datetime)
    end

    create index(:categories, [:account_id])
  end
end
