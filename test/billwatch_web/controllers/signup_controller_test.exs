defmodule BillwatchWeb.SignupControllerTest do
  use BillwatchWeb.ConnCase

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
    test "creates account but does not log in", %{conn: conn} do
      email = unique_user_email()

      conn =
        post(conn, ~p"/signup", %{
          "user" => valid_user_attributes(email: email)
        })

      refute get_session(conn, :user_token)
      assert redirected_to(conn) == ~p"/"
      assert conn.assigns.flash["info"] =~ ~r/An email was sent to .*, please access it to confirm your account/
    end

    test "returns error for invalid data", %{conn: conn} do
      conn =
        post(conn, ~p"/signup", %{
          "user" => %{"email" => "with spaces"}
        })

      assert html_response(conn, 422) =~ "must have the @ sign and no spaces"
    end
  end
end
