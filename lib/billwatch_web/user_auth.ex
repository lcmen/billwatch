defmodule BillwatchWeb.UserAuth do
  use BillwatchWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Billwatch.Accounts
  alias Billwatch.Accounts.Scope

  @doc """
  LiveView on_mount hook to assign current_scope from session.

  ## Usage

      defmodule MyAppWeb.SomeLive do
        use MyAppWeb, :live_view

        on_mount {MyAppWeb.UserAuth, :assign_current_scope}
      end

  """
  def on_mount(:assign_current_scope, _params, session, socket) do
    case session["user_token"] do
      nil ->
        {:cont, Phoenix.Component.assign(socket, :current_scope, nil)}

      token ->
        case Accounts.get_user_by_session_token(token) do
          {user, _token_inserted_at} ->
            {:cont, Phoenix.Component.assign(socket, :current_scope, build_scope(user))}

          nil ->
            {:cont, Phoenix.Component.assign(socket, :current_scope, nil)}
        end
    end
  end

  # Make the remember me cookie valid for 14 days. This should match
  # the session validity setting in UserToken.
  @max_cookie_age_in_days 14
  @remember_me_cookie "_billwatch_web_user_remember_me"
  @remember_me_options [
    sign: true,
    max_age: @max_cookie_age_in_days * 24 * 60 * 60,
    same_site: "Lax"
  ]

  # How old the session token should be before a new one is issued. When a request is made
  # with a session token older than this value, then a new session token will be created
  # and the session and remember-me cookies (if set) will be updated with the new token.
  # Lowering this value will result in more tokens being created by active users. Increasing
  # it will result in less time before a session token expires for a user to get issued a new
  # token. This can be set to a value greater than `@max_cookie_age_in_days` to disable
  # the reissuing of tokens completely.
  @session_reissue_age_in_days 7

  @doc """
  Authenticates the user by looking into the session and remember me token.

  Will reissue the session token if it is older than the configured age.
  Builds a complete scope with user, account, and role.
  """
  def fetch_current_scope_for_user(conn, _opts) do
    with {token, conn} <- load_user_token(conn),
         {user, token_inserted_at} <- Accounts.get_user_by_session_token(token) do
      conn
      |> assign(:current_scope, build_scope(user))
      |> reissue_user_token_if_expired(user, token_inserted_at)
    else
      nil -> assign(conn, :current_scope, nil)
    end
  end

  @doc """
  Logs the user in.

  Redirects to the session's `:user_return_to` path
  or falls back to the `signed_in_path/1`.
  """
  def log_in_user(conn, user, params \\ %{}) do
    user_return_to = get_session(conn, :user_return_to)

    conn
    |> create_or_extend_session(user, params)
    |> redirect(to: user_return_to || signed_in_path(conn))
  end

  @doc """
  Logs the user out.

  It clears all session data for safety. See create_session_for_user/2.
  """
  def log_out_user(conn) do
    user_token = get_session(conn, :user_token)
    user_token && Accounts.delete_user_session_token(user_token)

    if live_socket_id = get_session(conn, :live_socket_id) do
      BillwatchWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> create_session_for_user(nil)
    |> delete_resp_cookie(@remember_me_cookie)
  end

  @doc """
  Plug for routes that require sudo mode.
  """
  def require_sudo_mode(conn, _opts) do
    case conn.assigns[:current_scope] do
      %Scope{user: user} when not is_nil(user) ->
        if Accounts.sudo_mode?(user, -10) do
          conn
        else
          conn
          |> put_flash(:error, "You must re-authenticate to access this page.")
          |> store_return_to()
          |> redirect(to: ~p"/")
          |> halt()
        end

      _ ->
        conn
        |> put_flash(:error, "You must log in to access this page.")
        |> store_return_to()
        |> redirect(to: ~p"/")
        |> halt()
    end
  end

  @doc """
  Plug for routes that require the user to not be authenticated.
  """
  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns.current_scope do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  @doc """
  Plug for routes that require the user to be authenticated and confirmed.
  """
  def require_authenticated_user(conn, _opts) do
    case conn.assigns.current_scope do
      %Scope{user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
        # Confirmed user - allow through
        conn

      %Scope{user: user} when not is_nil(user) ->
        # Logged in but not confirmed
        conn
        |> put_flash(:error, "You must confirm your email address to access this page.")
        |> redirect(to: ~p"/")
        |> halt()

      _ ->
        # Not logged in
        conn
        |> put_flash(:error, "You must log in to access this page.")
        |> store_return_to()
        |> redirect(to: ~p"/")
        |> halt()
    end
  end

  defp load_user_token(conn) do
    if token = get_session(conn, :user_token) do
      {token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if token = conn.cookies[@remember_me_cookie] do
        {token, conn |> put_token_in_session(token) |> put_session(:user_remember_me, true)}
      else
        nil
      end
    end
  end

  # Reissue the session token if it is older than the configured reissue age.
  defp reissue_user_token_if_expired(conn, user, token_inserted_at) do
    token_age = DateTime.diff(DateTime.utc_now(:second), token_inserted_at, :day)

    if token_age >= @session_reissue_age_in_days do
      create_or_extend_session(conn, user, %{})
    else
      conn
    end
  end

  # This function is the one responsible for creating session tokens
  # and storing them safely in the session and cookies. It may be called
  # either when logging in, during sudo mode, or to renew a session which
  # will soon expire.
  #
  # When the session is created, rather than extended, the
  # create_session_for_user/2 function will clear the session
  # to avoid fixation attacks. See that function to customize this behaviour.
  defp create_or_extend_session(conn, user, params) do
    token = Accounts.generate_user_session_token(user)
    remember_me = get_session(conn, :user_remember_me)

    conn
    |> create_session_for_user(user)
    |> put_token_in_session(token)
    |> maybe_put_remember_me_in_cookie(token, params, remember_me)
  end

  # Clears session data only when logging in a different user.
  #
  # When the same user is already logged in (e.g., during token reissuance),
  # keeps the session data to prevent CSRF errors and data loss in other open tabs.
  #
  # When logging in a different user or logging out, clears all session data
  # to prevent session fixation attacks.
  #
  # Note: The session token is always updated after this via put_token_in_session/2.
  #
  # To preserve specific session data during login/logout, fetch before clearing:
  #
  #     preferred_locale = get_session(conn, :preferred_locale)
  #     conn
  #     |> configure_session(renew: true)
  #     |> clear_session()
  #     |> put_session(:preferred_locale, preferred_locale)
  #
  defp create_session_for_user(conn, user) do
    case conn.assigns[:current_scope] do
      %Scope{user: %{id: user_id}} when not is_nil(user) and user_id == user.id ->
        # Same user - keep session data
        conn

      _ ->
        # Different user or no user - clear session for security
        delete_csrf_token()

        conn
        |> configure_session(renew: true)
        |> clear_session()
    end
  end

  defp maybe_put_remember_me_in_cookie(conn, token, params, default) do
    remember_me = get_in(params, ["remember_me"]) == "true" || default

    if remember_me do
      put_remember_me_in_cookie(conn, token)
    else
      conn
    end
  end

  defp put_remember_me_in_cookie(conn, token) do
    conn
    |> put_session(:user_remember_me, true)
    |> put_resp_cookie(@remember_me_cookie, token, @remember_me_options)
  end

  defp put_token_in_session(conn, token) do
    put_session(conn, :user_token, token)
  end

  # Builds a scope for the given user from preloaded account_user data.
  # Expects user to always have account_user preloaded with account.
  defp build_scope(%Billwatch.Accounts.User{account_user: %{account: account, role: role}} = user) do
    Scope.new()
    |> Scope.for_user(user)
    |> Scope.for_account(account)
    |> Scope.with_role(role)
  end

  defp signed_in_path(_conn), do: ~p"/"

  defp store_return_to(conn) do
    if conn.method == "GET" do
      put_session(conn, :user_return_to, current_path(conn))
    else
      conn
    end
  end
end
