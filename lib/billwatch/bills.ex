defmodule Billwatch.Bills do
  @moduledoc """
  The Bills context.
  """

  import Ecto.Query, warn: false
  alias Billwatch.Repo
  alias Billwatch.Bills.Category

  @default_categories [
    %{name: "Housing", color: "#ef4444"},
    %{name: "Utilities", color: "#f59e0b"},
    %{name: "Insurance", color: "#8b5cf6"},
    %{name: "Subscriptions", color: "#10b981"},
    %{name: "Finance", color: "#3b82f6"},
    %{name: "Other", color: "#6b7280"}
  ]

  @doc """
  Returns all categories for the given account.
  """
  @spec categories(Ecto.UUID.t()) :: [Category.t()]
  def categories(account_id) do
    Repo.all(from c in Category, where: c.account_id == ^account_id)
  end

  @doc """
  Seeds default categories for a new account.

  Uses a transaction to ensure all categories are created atomically.
  Returns `{:ok, :seeded}` on success or `{:error, :seed_defaults}` on failure.
  """
  def seed_defaults(account_id) do
    multi =
      Enum.reduce(@default_categories, Ecto.Multi.new(), fn category_attrs, acc ->
        attrs = Map.put(category_attrs, :account_id, account_id)

        Ecto.Multi.insert(acc, {:category, category_attrs.name}, fn _changes ->
          Category.changeset(%Category{}, attrs)
        end)
      end)

    try do
      case Repo.transaction(multi) do
        {:ok, _results} -> {:ok, :seeded}
        {:error, _failed_op, _changeset, _changes} -> {:error, :seed_defaults}
      end
    rescue
      Ecto.ConstraintError -> {:error, :seed_defaults}
    end
  end
end
