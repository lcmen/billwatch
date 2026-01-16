defmodule Billwatch.Bills.CategoryTest do
  use Billwatch.DataCase

  alias Billwatch.Bills.Category

  import Billwatch.AccountsFixtures

  describe "changeset/2" do
    test "validates required fields" do
      changeset = Category.changeset(%Category{}, %{})

      assert %{
               name: ["can't be blank"],
               account_id: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates name is required (empty string)" do
      account = account_fixture()

      changeset =
        Category.changeset(%Category{}, %{
          name: "",
          account_id: account.id
        })

      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates name length maximum" do
      account = account_fixture()
      long_name = String.duplicate("a", 101)

      changeset =
        Category.changeset(%Category{}, %{
          name: long_name,
          account_id: account.id
        })

      assert %{name: ["should be at most 100 character(s)"]} = errors_on(changeset)
    end

    test "validates color format" do
      account = account_fixture()

      invalid_colors = [
        "FF5733",
        # missing #
        "#FF573",
        # too short
        "#FF57333",
        # too long
        "#GG5733",
        # invalid hex
        "red",
        # not hex
        "#ff573g"
        # invalid character
      ]

      for invalid_color <- invalid_colors do
        changeset =
          Category.changeset(%Category{}, %{
            name: "Test",
            account_id: account.id,
            color: invalid_color
          })

        assert %{color: [error]} = errors_on(changeset)
        assert error =~ "must be a valid hex color"
      end
    end

    test "accepts valid hex colors" do
      account = account_fixture()

      valid_colors = [
        "#FF5733",
        "#ff5733",
        "#000000",
        "#FFFFFF",
        "#AbCdEf"
      ]

      for valid_color <- valid_colors do
        changeset =
          Category.changeset(%Category{}, %{
            name: "Test",
            account_id: account.id,
            color: valid_color
          })

        assert changeset.valid?
        assert get_change(changeset, :color) == valid_color
      end
    end

    test "accepts nil color (optional field)" do
      account = account_fixture()

      changeset =
        Category.changeset(%Category{}, %{
          name: "Test Category",
          account_id: account.id,
          color: nil
        })

      assert changeset.valid?
    end

    test "accepts missing color (optional field)" do
      account = account_fixture()

      changeset =
        Category.changeset(%Category{}, %{
          name: "Test Category",
          account_id: account.id
        })

      assert changeset.valid?
    end

    test "validates foreign key constraint for account_id" do
      invalid_account_id = Ecto.UUID.generate()

      assert_raise Ecto.ConstraintError, fn ->
        %Category{}
        |> Category.changeset(%{
          name: "Test",
          account_id: invalid_account_id,
          color: "#FF5733"
        })
        |> Repo.insert!()
      end
    end

    test "accepts valid attributes" do
      account = account_fixture()

      changeset =
        Category.changeset(%Category{}, %{
          name: "Utilities",
          account_id: account.id,
          color: "#FF5733"
        })

      assert changeset.valid?
      assert get_change(changeset, :name) == "Utilities"
      assert get_change(changeset, :color) == "#FF5733"
    end
  end
end
