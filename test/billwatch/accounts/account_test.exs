defmodule Billwatch.Accounts.AccountTest do
  use Billwatch.DataCase

  alias Billwatch.Accounts.Account

  describe "changeset/2" do
    test "validates fields" do
      changeset = Account.changeset(%Account{}, %{})
      assert %{name: ["can't be blank"]} = errors_on(changeset)

      changeset = Account.changeset(%Account{}, %{name: ""})
      assert %{name: ["can't be blank"]} = errors_on(changeset)

      changeset = Account.changeset(%Account{}, %{name: String.duplicate("a", 256)})
      assert %{name: ["should be at most 255 character(s)"]} = errors_on(changeset)
    end

    test "trims whitespace is not applied (uses exact name)" do
      changeset = Account.changeset(%Account{}, %{name: "  Test Account  "})

      assert changeset.valid?
      assert get_change(changeset, :name) == "  Test Account  "
    end
  end
end
