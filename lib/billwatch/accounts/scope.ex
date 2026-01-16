defmodule Billwatch.Accounts.Scope do
  @moduledoc """
  Defines the scope of the caller to be used throughout the app.

  The `Billwatch.Accounts.Scope` allows public interfaces to receive
  information about the caller, such as if the call is initiated from an
  end-user, and if so, which user. Additionally, such a scope can carry fields
  such as "super user" or other privileges for use as authorization, or to
  ensure specific code paths can only be access for a given scope.

  It is useful for logging as well as for scoping pubsub subscriptions and
  broadcasts when a caller subscribes to an interface or performs a particular
  action.

  Feel free to extend the fields on this struct to fit the needs of
  growing application requirements.
  """

  alias Billwatch.Accounts.{User, Account}

  defstruct user: nil, account: nil, role: nil

  @doc """
  Creates an empty scope.
  """
  def new do
    %__MODULE__{}
  end

  @doc """
  Creates a scope for the given user.
  """
  def for_user(%User{} = user) do
    %__MODULE__{user: user}
  end

  @doc """
  Adds a user to the scope.
  """
  def for_user(%__MODULE__{} = scope, %User{} = user) do
    %{scope | user: user}
  end

  @doc """
  Adds an account to the scope.

  Returns nil if the scope is nil.
  """
  def for_account(%__MODULE__{} = scope, %Account{} = account) do
    %{scope | account: account}
  end

  @doc """
  Adds a role to the scope.

  Returns nil if the scope is nil.
  """
  def with_role(%__MODULE__{} = scope, role) when role in [:admin, :member] do
    %{scope | role: role}
  end
end
