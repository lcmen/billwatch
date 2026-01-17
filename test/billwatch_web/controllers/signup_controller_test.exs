defmodule BillwatchWeb.SignupControllerTest do
  use BillwatchWeb.ConnCase

  alias Billwatch.Bills

  import Billwatch.UsersFixtures

  describe "GET /signup" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, ~p"/signup")
      assert html_response(conn, 200) =~ "Create account"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn = conn |> log_in_user(user_fixture()) |> get(~p"/signup")
      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "POST /signup" do
    @tag :capture_log
    test "creates account with default categories but does not log in", %{conn: conn} do
      email = unique_user_email()

      conn =
        post(conn, ~p"/signup", %{
          "user" => valid_user_attributes(email: email)
        })

      refute get_session(conn, :user_token)
      assert redirected_to(conn) == ~p"/"
      assert conn.assigns.flash["info"] =~ ~r/An email was sent to .*, please access it to confirm your account/

      user = Billwatch.Accounts.get_user_by_email(email, preload: :account)
      assert user

      categories = Bills.categories(user.account.id)
      assert length(categories) == 6
    end

    test "returns error for invalid data", %{conn: conn} do
      conn =
        post(conn, ~p"/signup", %{
          "user" => %{"email" => "with spaces"}
        })

      assert html_response(conn, 422) =~ "must have the @ sign and no spaces"
    end

    test "does not create categories when user validation fails", %{conn: conn} do
      conn =
        post(conn, ~p"/signup", %{
          "user" => %{"email" => "invalid"}
        })

      assert html_response(conn, 422)

      # Verify no categories were created
      categories = Billwatch.Repo.all(Billwatch.Bills.Category)
      assert categories == []
    end
  end
end
