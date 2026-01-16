defmodule Billwatch.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :name, :string

    has_many :account_users, Billwatch.Accounts.AccountUser
    has_many :users, through: [:account_users, :user]
    has_many :categories, Billwatch.Bills.Category

    timestamps(type: :utc_datetime)
  end

  @doc """
  A changeset for creating or updating an account.
  """
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 255)
  end
end
