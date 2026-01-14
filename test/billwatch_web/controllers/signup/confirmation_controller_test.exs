defmodule BillwatchWeb.Signup.ConfirmationControllerTest do
  use BillwatchWeb.ConnCase

  alias Billwatch.Accounts
  import Billwatch.UsersFixtures

  describe "GET /users/confirm/:token" do
    test "confirms the user account", %{conn: conn} do
      {user, token} =
        unconfirmed_user_fixture()
        |> with_confirmation_token(valid_user_confirmation_token())

      conn = get(conn, ~p"/users/confirm/#{token}")

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Email confirmed successfully"
      assert Accounts.get_user!(user.id).confirmed_at
    end

    test "does not confirm with invalid token", %{conn: conn} do
      conn = get(conn, ~p"/users/confirm/invalid-token")

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Email confirmation link is invalid or it has expired"
    end
  end
end
