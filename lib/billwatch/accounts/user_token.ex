defmodule Billwatch.Accounts.UserToken do
  use Ecto.Schema
  import Ecto.Query
  alias Billwatch.Accounts.UserToken

  @hash_algorithm :sha256
  @rand_size 32

  @session_validity_in_days 14

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    field :authenticated_at, :utc_datetime
    belongs_to :user, Billwatch.Accounts.User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc """
  Builds a token for password reset to be delivered to the user's email.
  """
  def build_password_reset_token(user, token \\ nil) do
    build_email_token(user, "reset", token)
  end

  @doc """
  Generates a token that will be stored in a signed place, such as session or cookie.
  """
  def build_session_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    dt = user.authenticated_at || DateTime.utc_now(:second)
    {token, %UserToken{token: token, context: "session", user_id: user.id, authenticated_at: dt}}
  end

  @doc """
  Builds a token for user confirmation to be delivered to the user's email.
  """
  def build_user_confirm_token(user, token \\ nil) do
    build_email_token(user, "confirm", token)
  end

  @doc """
  Gets all tokens for the given user for the given contexts.
  """
  def by_user_and_contexts_query(user, :all) do
    from t in UserToken, where: t.user_id == ^user.id
  end

  def by_user_and_contexts_query(user, contexts) when is_list(contexts) do
    from t in UserToken, where: t.user_id == ^user.id and t.context in ^contexts
  end

  @doc """
  Checks if the password reset token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The given token is valid if it matches its hashed counterpart in the
  database and the email matches. Password reset tokens do not expire.
  """
  def verify_password_reset_token_query(token) do
    verify_token_query(token, "reset")
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The given token is valid if it matches its hashed counterpart in the
  database and the email matches. Confirmation tokens do not expire.
  """
  def verify_confirmation_token_query(token) do
    verify_token_query(token, "confirm")
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any, along with the token's creation time.

  The token is valid if it matches the value in the database and it has
  not expired (after @session_validity_in_days).
  """
  def verify_session_token_query(token) do
    query =
      from token in UserToken,
        join: user in assoc(token, :user),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        where: [token: ^token, context: "session"],
        select: {%{user | authenticated_at: token.authenticated_at}, token.inserted_at}

    {:ok, query}
  end

  defp build_email_token(user, context, token) do
    token =
      if token == nil do
        :crypto.strong_rand_bytes(@rand_size)
      else
        token
      end

    hashed_token = :crypto.hash(@hash_algorithm, token)

    {
      Base.url_encode64(token, padding: false),
      %UserToken{token: hashed_token, context: context, sent_to: user.email, user_id: user.id}
    }
  end

  defp verify_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from token in UserToken,
            join: user in assoc(token, :user),
            where: token.sent_to == user.email,
            where: [token: ^hashed_token, context: ^context],
            select: user

        {:ok, query}

      :error ->
        :error
    end
  end
end
