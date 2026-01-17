defmodule Billwatch.Bills.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "categories" do
    field :name, :string
    field :color, :string

    belongs_to :account, Billwatch.Accounts.Account

    timestamps(type: :utc_datetime)
  end

  @doc """
  A changeset for creating or updating a category.
  """
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :color, :account_id])
    |> validate_required([:name, :account_id])
    |> validate_length(:name, min: 1, max: 100)
    |> validate_format(:color, ~r/^#[0-9A-Fa-f]{6}$/, message: "must be a valid hex color (e.g., #FF5733)")
    |> foreign_key_constraint(:account_id)
    |> unique_constraint([:account_id, :name], name: :categories_account_id_name_index)
  end
end
