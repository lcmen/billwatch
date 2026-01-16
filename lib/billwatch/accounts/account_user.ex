defmodule Billwatch.Accounts.AccountUser do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_roles [:admin, :member]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "account_users" do
    field :role, Ecto.Enum, values: @valid_roles

    belongs_to :account, Billwatch.Accounts.Account
    belongs_to :user, Billwatch.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc """
  A changeset for creating or updating an account user relationship.
  """
  def changeset(account_user, attrs) do
    account_user
    |> cast(attrs, [:account_id, :user_id, :role])
    |> validate_required([:account_id, :user_id, :role])
    |> validate_inclusion(:role, @valid_roles)
    |> foreign_key_constraint(:account_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:user_id)
  end
end
