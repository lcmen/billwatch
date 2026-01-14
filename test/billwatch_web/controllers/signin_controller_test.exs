defmodule BillwatchWeb.SigninControllerTest do
  use BillwatchWeb.ConnCase

  import Billwatch.UsersFixtures

  setup do
    %{unconfirmed_user: unconfirmed_user_fixture(), user: user_fixture()}
  end

  describe "GET /signin" do
    test "renders login page", %{conn: conn} do
      conn = get(conn, ~p"/signin")
      assert html_response(conn, 200) =~ "Log in"
    end

    test "renders login page with email filled in (sudo mode)", %{conn: conn, user: user} do
      html =
        conn
        |> log_in_user(user)
        |> get(~p"/signin")
        |> html_response(200)

      assert html =~ "You need to reauthenticate"
      refute html =~ "Sign up"
      assert html =~ ~s(id="login_form_email")
      assert html =~ ~s(value="#{user.email}")
      assert html =~ "readonly"
    end
  end

  describe "POST /signin" do
    test "logs the user in", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/signin", %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == ~p"/"

      # Authenticated users are redirected to calendar
      conn = get(conn, ~p"/")
      assert redirected_to(conn) == ~p"/calendar"
    end

    test "logs the user in with remember me and return to", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(user_return_to: "/foo/bar")
        |> post(~p"/signin", %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_billwatch_web_user_remember_me"]
      assert redirected_to(conn) == "/foo/bar"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "returns unauthorized with invalid credentials", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/signin", %{
          "user" => %{"email" => user.email, "password" => "invalid_password"}
        })

      assert redirected_to(conn) == ~p"/signin"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Invalid email or password"
    end
  end

  describe "DELETE /signout" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> delete(~p"/signout")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "redirects unauthenticated users", %{conn: conn} do
      conn = delete(conn, ~p"/signout")
      assert redirected_to(conn) == ~p"/"
    end
  end
end
