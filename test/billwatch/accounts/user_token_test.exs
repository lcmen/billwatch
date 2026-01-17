defmodule Billwatch.Accounts.UserTokenTest do
  use Billwatch.DataCase

  alias Billwatch.Accounts.UserToken
  import Billwatch.UsersFixtures

  describe "build_password_reset_token/1" do
    test "generates a URL-encoded token" do
      user = user_fixture()
      {token, user_token} = UserToken.build_password_reset_token(user)

      assert is_binary(token)
      assert String.length(token) > 0
      assert user_token.context == "reset"
      assert user_token.sent_to == user.email
      assert user_token.user_id == user.id
    end

    test "hashes the token" do
      user = user_fixture()
      {token, user_token} = UserToken.build_password_reset_token(user)

      # The token in the struct should be hashed, not the raw token
      refute user_token.token == token
      assert byte_size(user_token.token) == 32
    end
  end

  describe "verify_password_reset_token_query/1" do
    test "returns a valid query for a valid token" do
      user = user_fixture()
      {token, user_token} = UserToken.build_password_reset_token(user)
      Repo.insert!(user_token)

      {:ok, query} = UserToken.verify_password_reset_token_query(token)
      assert %{id: id} = Repo.one(query)
      assert id == user.id
    end

    test "returns error for invalid token" do
      # Use a token that will fail base64 decoding (invalid padding)
      assert UserToken.verify_password_reset_token_query("oops!") == :error
    end

    test "does not return user if email does not match" do
      user = user_fixture()
      {token, user_token} = UserToken.build_password_reset_token(user)

      # Change the sent_to email after token creation
      user_token = %{user_token | sent_to: "different@example.com"}
      Repo.insert!(user_token)

      {:ok, query} = UserToken.verify_password_reset_token_query(token)
      refute Repo.one(query)
    end

    test "does not return user if context is different" do
      user = user_fixture()
      {token, user_token} = UserToken.build_password_reset_token(user)

      # Insert with different context
      user_token = %{user_token | context: "confirm"}
      Repo.insert!(user_token)

      {:ok, query} = UserToken.verify_password_reset_token_query(token)
      refute Repo.one(query)
    end
  end
end
