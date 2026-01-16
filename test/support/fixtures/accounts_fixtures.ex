defmodule Billwatch.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  Account entities.
  """

  alias Billwatch.Accounts.Account
  alias Billwatch.Repo

  def unique_account_name, do: "Account #{System.unique_integer()}"

  def valid_account_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: unique_account_name()
    })
  end

  def account_fixture(attrs \\ %{}) do
    attrs
    |> valid_account_attributes()
    |> then(&Account.changeset(%Account{}, &1))
    |> Repo.insert!()
  end
end
