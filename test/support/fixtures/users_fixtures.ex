defmodule Billwatch.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  User entities via the `Billwatch.Accounts` context.
  """

  alias Billwatch.Accounts

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "P@ssWord123"
  def valid_user_confirmation_token, do: "token"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      invite_code: "test_invite_code"
    })
  end

  def unconfirmed_user_fixture(attrs \\ %{}) do
    {:ok, %{user: user}} =
      attrs
      |> valid_user_attributes()
      |> Accounts.register_user()

    user
  end

  def user_fixture(attrs \\ %{}) do
    {_, token} = unconfirmed_user_fixture(attrs) |> with_confirmation_token(valid_user_confirmation_token())
    {:ok, user} = Accounts.confirm_user(token)
    user
  end

  def with_password(user, password) do
    {:ok, {user, _expired_tokens}} =
      Accounts.update_user_password(user, %{
        current_password: valid_user_password(),
        password: password
      })

    user
  end

  def with_confirmation_token(user, token) do
    {encoded_token, user_token} = Accounts.UserToken.build_email_token(user, "confirm", token)
    Billwatch.Repo.insert!(user_token)
    {user, encoded_token}
  end
end
