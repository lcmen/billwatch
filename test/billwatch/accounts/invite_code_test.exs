defmodule Billwatch.Accounts.InviteCodeTest do
  use Billwatch.DataCase

  alias Billwatch.Accounts

  describe "registration with invite code" do
    test "succeeds with correct invite code" do
      # test.exs has invite_code configured as "test_invite_code"
      attrs = %{
        email: "user@example.com",
        password: "ValidPassword1!",
        invite_code: "test_invite_code"
      }

      assert {:ok, user} = Accounts.register_user(attrs)
      assert user.email == "user@example.com"
      refute is_nil(user.id)
    end

    test "fails with incorrect invite code" do
      attrs = %{
        email: "user@example.com",
        password: "ValidPassword1!",
        invite_code: "wrong_code"
      }

      assert {:error, changeset} = Accounts.register_user(attrs)
      assert %{invite_code: ["is invalid"]} = errors_on(changeset)
    end

    test "fails with empty invite code" do
      attrs = %{
        email: "user@example.com",
        password: "ValidPassword1!",
        invite_code: ""
      }

      assert {:error, changeset} = Accounts.register_user(attrs)
      assert %{invite_code: ["is invalid"]} = errors_on(changeset)
    end

    test "fails without invite code field" do
      attrs = %{
        email: "user@example.com",
        password: "ValidPassword1!"
      }

      assert {:error, changeset} = Accounts.register_user(attrs)
      assert %{invite_code: ["is invalid"]} = errors_on(changeset)
    end
  end
end
