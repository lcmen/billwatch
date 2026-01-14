defmodule Billwatch.ScopeFixtures do
  alias Billwatch.Accounts.Scope
  alias Billwatch.UsersFixtures

  def scope_fixture do
    user = UsersFixtures.user_fixture()
    scope_fixture(user)
  end

  def scope_fixture(user) do
    # Preload account_user and account if not already loaded
    user =
      if Ecto.assoc_loaded?(user.account_user) do
        user
      else
        Billwatch.Repo.preload(user, account_user: :account)
      end

    # Extract account and role from account_user
    case user.account_user do
      %{account: account, role: role} ->
        Scope.new()
        |> Scope.for_user(user)
        |> Scope.for_account(account)
        |> Scope.with_role(role)

      nil ->
        # User has no account yet, just return scope with user
        Scope.for_user(user)
    end
  end
end
