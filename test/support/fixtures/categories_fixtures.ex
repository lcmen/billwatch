defmodule Billwatch.CategoriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  Category entities.
  """

  alias Billwatch.Bills.Category
  alias Billwatch.Repo

  import Billwatch.AccountsFixtures

  def unique_category_name, do: "Category #{System.unique_integer()}"

  def valid_category_attributes(attrs \\ %{}) do
    account = Map.get_lazy(attrs, :account, &account_fixture/0)

    Enum.into(attrs, %{
      account_id: account.id,
      name: unique_category_name(),
      color: "#FF5733"
    })
  end

  def category_fixture(attrs \\ %{}) do
    attrs
    |> valid_category_attributes()
    |> then(&Category.changeset(%Category{}, &1))
    |> Repo.insert!()
  end
end
