defmodule BillwatchWeb.SettingsController do
  use BillwatchWeb, :controller

  alias Billwatch.Accounts
  alias BillwatchWeb.UserAuth

  plug :assign_password_changeset

  def edit(conn, _params) do
    render(conn, :edit)
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"user" => user_params} = params
    user = conn.assigns.current_scope.user

    case Accounts.update_user_password(user, user_params) do
      {:ok, {user, _}} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:user_return_to, ~p"/users/settings")
        |> UserAuth.log_in_user(user)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:edit, password_changeset: changeset)
    end
  end

  defp assign_password_changeset(conn, _opts) do
    user = conn.assigns.current_scope.user
    assign(conn, :password_changeset, Accounts.change_user_password(user))
  end
end
