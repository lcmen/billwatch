defmodule Billwatch.BillsTest do
  use Billwatch.DataCase

  alias Billwatch.Bills
  alias Billwatch.Bills.Category
  alias Billwatch.Repo

  import Billwatch.AccountsFixtures

  describe "seed_defaults/1" do
    test "creates all 6 default categories for an account" do
      account = account_fixture()

      assert {:ok, :seeded} = Bills.seed_defaults(account.id)

      categories = Repo.all(from c in Category, where: c.account_id == ^account.id)
      assert length(categories) == 6

      Enum.each(categories, fn category ->
        assert category.color =~ ~r/^#[0-9A-Fa-f]{6}$/
      end)
    end

    test "is idempotent - returns error when called twice for same account" do
      account = account_fixture()

      assert {:ok, :seeded} = Bills.seed_defaults(account.id)
      assert {:error, :seed_defaults} = Bills.seed_defaults(account.id)

      # Should still only have 6 categories
      categories = Repo.all(from c in Category, where: c.account_id == ^account.id)
      assert length(categories) == 6
    end

    test "returns error for invalid account_id" do
      invalid_account_id = Ecto.UUID.generate()

      assert {:error, :seed_defaults} = Bills.seed_defaults(invalid_account_id)

      # No categories should be created due to rollback
      assert Repo.aggregate(Category, :count) == 0
    end
  end
end
