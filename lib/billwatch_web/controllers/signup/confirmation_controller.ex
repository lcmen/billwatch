defmodule BillwatchWeb.Signup.ConfirmationController do
  use BillwatchWeb, :controller

  alias Billwatch.Accounts

  def confirm(conn, %{"token" => token}) do
    case Accounts.confirm_user(token) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Email confirmed successfully. You can now log in.")
        |> redirect(to: ~p"/")

      :error ->
        conn
        |> put_flash(:error, "Email confirmation link is invalid or it has expired.")
        |> redirect(to: ~p"/")
    end
  end
end
