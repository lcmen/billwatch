defmodule BillwatchWeb.PasswordController do
  use BillwatchWeb, :controller

  alias Billwatch.Accounts

  def new(conn, _params) do
    form = Phoenix.Component.to_form(%{}, as: "user")
    render(conn, :new, form: form)
  end

  def create(conn, %{"user" => %{"email" => email}}) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_password_reset_instructions(
        user,
        &url(~p"/password/reset/#{&1}")
      )
    end

    # Always show success message to prevent email enumeration
    conn
    |> put_flash(:info, "If that email exists, we've sent password reset instructions.")
    |> redirect(to: ~p"/signin")
  end

  def edit(conn, %{"token" => token}) do
    case Accounts.get_user_by_reset_password_token(token) do
      nil ->
        conn
        |> put_flash(:error, "Password reset link is invalid or expired.")
        |> redirect(to: ~p"/")

      _user ->
        form = Phoenix.Component.to_form(%{}, as: "user")
        render(conn, :edit, form: form, token: token)
    end
  end

  def update(conn, %{"token" => token, "user" => user_params}) do
    case Accounts.reset_user_password(token, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Password reset successfully. Please log in.")
        |> redirect(to: ~p"/signin")

      {:error, changeset} ->
        form = Phoenix.Component.to_form(changeset, as: "user")
        render(conn, :edit, form: form, token: token)

      :error ->
        conn
        |> put_flash(:error, "Password reset link is invalid or expired.")
        |> redirect(to: ~p"/")
    end
  end
end
