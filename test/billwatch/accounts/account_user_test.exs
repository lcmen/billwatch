defmodule Billwatch.Accounts.AccountUserTest do
  use Billwatch.DataCase

  alias Billwatch.Accounts.AccountUser

  import Billwatch.AccountsFixtures
  import Billwatch.UsersFixtures

  describe "changeset/2" do
    test "validates required fields" do
      changeset = AccountUser.changeset(%AccountUser{}, %{})

      assert %{role: ["can't be blank"], account_id: ["can't be blank"], user_id: ["can't be blank"]} =
               errors_on(changeset)

      changeset =
        AccountUser.changeset(%AccountUser{}, %{
          account_id: account_fixture().id,
          user_id: user_fixture().id,
          role: :invalid_role
        })

      assert %{role: ["is invalid"]} = errors_on(changeset)
    end

    test "validates unique user_id constraint (one account per user)" do
      user = user_fixture()
      other_account = account_fixture()

      {:error, changeset} =
        %AccountUser{}
        |> AccountUser.changeset(%{
          account_id: other_account.id,
          user_id: user.id,
          role: :member
        })
        |> Repo.insert()

      assert %{user_id: ["has already been taken"]} = errors_on(changeset)
    end
  end
end
