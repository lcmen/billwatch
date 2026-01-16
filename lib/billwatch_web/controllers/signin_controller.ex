defmodule BillwatchWeb.SigninController do
  use BillwatchWeb, :controller

  alias Billwatch.Accounts
  alias BillwatchWeb.UserAuth

  def new(conn, _params) do
    email =
      case conn.assigns[:current_scope] do
        %{user: %{email: email}} -> email
        _ -> nil
      end

    form = Phoenix.Component.to_form(%{"email" => email}, as: "user")

    render(conn, :new, form: form)
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password} = user_params}) do
    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, "Welcome back!")
      |> UserAuth.log_in_user(user, user_params)
    else
      conn
      |> put_flash(:error, "Invalid email or password")
      |> redirect(to: ~p"/signin")
    end
  end

  def delete(conn, _params) do
    conn
    |> UserAuth.log_out_user()
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: ~p"/")
  end
end
