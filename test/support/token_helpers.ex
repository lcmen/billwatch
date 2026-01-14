defmodule Billwatch.TokenHelpers do
  @moduledoc """
  Test helpers for working with authentication tokens.
  """

  import Ecto.Query

  alias Billwatch.Accounts

  @doc """
  Updates the authenticated_at timestamp for a user token.
  Useful for testing token expiration scenarios.
  """
  def update_user_token_authenticated_at(token, authenticated_at) when is_binary(token) do
    Billwatch.Repo.update_all(
      from(t in Accounts.UserToken,
        where: t.token == ^token
      ),
      set: [authenticated_at: authenticated_at, inserted_at: authenticated_at]
    )
  end

  @doc """
  Updates the authenticated_at timestamp for a user token by adding an offset.
  Useful for testing token aging.
  """
  def update_user_token_authenticated_at(token, amount_to_add, unit) do
    dt = DateTime.add(DateTime.utc_now(:second), amount_to_add, unit)
    update_user_token_authenticated_at(token, dt)
  end

  @doc """
  Extracts a token from an email delivery function.
  The token is wrapped in [TOKEN] markers in the email body.
  """
  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
