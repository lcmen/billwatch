defmodule Billwatch.Repo.Migrations.AddUniqueConstraintToCategories do
  use Ecto.Migration

  def change do
    create unique_index(:categories, [:account_id, :name])
  end
end
