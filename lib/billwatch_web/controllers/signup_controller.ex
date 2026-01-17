defmodule BillwatchWeb.SignupController do
  use BillwatchWeb, :controller

  alias Billwatch.Accounts
  alias Billwatch.Accounts.User
  alias Billwatch.Bills

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %{user: user, account: account}} <- Accounts.register_user(user_params),
         {:ok, _} <- Bills.seed_defaults(account.id),
         {:ok, _} <- Accounts.deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}")) do
      conn
      |> put_flash(:info, "An email was sent to #{user.email}, please access it to confirm your account.")
      |> redirect(to: ~p"/")
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:new, changeset: changeset)

      {:error, :seed_defaults} ->
        conn
        |> put_flash(:error, "Account created but failed to set up default categories. Please contact support.")
        |> redirect(to: ~p"/")

      {:error, :already_confirmed} ->
        conn
        |> put_flash(:error, "This account is already confirmed.")
        |> redirect(to: ~p"/")
    end
  end
end
