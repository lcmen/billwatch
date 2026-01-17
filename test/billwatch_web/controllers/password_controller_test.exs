defmodule BillwatchWeb.PasswordControllerTest do
  use BillwatchWeb.ConnCase

  import Billwatch.UsersFixtures
  alias Billwatch.Accounts

  describe "GET /password/reset" do
    test "renders the reset password request page", %{conn: conn} do
      conn = get(conn, ~p"/password/reset")
      response = html_response(conn, 200)
      assert response =~ "Reset password"
      assert response =~ "Send reset instructions"
    end
  end

  describe "POST /password/reset" do
    test "sends a new reset password token", %{conn: conn} do
      user = user_fixture()
      conn = post(conn, ~p"/password/reset", %{"user" => %{"email" => user.email}})

      assert redirected_to(conn) == ~p"/signin"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If that email exists"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn = post(conn, ~p"/password/reset", %{"user" => %{"email" => "unknown@example.com"}})

      assert redirected_to(conn) == ~p"/signin"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If that email exists"
    end
  end

  describe "GET /password/reset/:token" do
    setup do
      user = user_fixture()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_password_reset_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "renders reset password form with valid token", %{conn: conn, token: token} do
      conn = get(conn, ~p"/password/reset/#{token}")
      response = html_response(conn, 200)
      assert response =~ "Create new password"
      assert response =~ "Reset password"
    end

    test "redirects with invalid token", %{conn: conn} do
      conn = get(conn, ~p"/password/reset/invalid")
      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Password reset link is invalid or expired"
    end

    test "redirects if token already used", %{conn: conn, token: token} do
      {:ok, _} =
        Accounts.reset_user_password(token, %{password: "N3wV@lidPassw0rd", password_confirmation: "N3wV@lidPassw0rd"})

      conn = get(conn, ~p"/password/reset/#{token}")
      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Password reset link is invalid or expired"
    end
  end

  describe "PUT /password/reset/:token" do
    setup do
      user = user_fixture()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_password_reset_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "resets password with valid token and data", %{conn: conn, token: token} do
      new_password = "N3wV@lidPassw0rd"

      conn =
        put(conn, ~p"/password/reset/#{token}", %{
          "user" => %{
            "password" => new_password,
            "password_confirmation" => new_password
          }
        })

      assert redirected_to(conn) == ~p"/signin"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Password reset successfully"
    end

    test "does not reset password with invalid token", %{conn: conn} do
      conn =
        put(conn, ~p"/password/reset/invalid", %{
          "user" => %{
            "password" => "N3wV@lidPassw0rd",
            "password_confirmation" => "N3wV@lidPassw0rd"
          }
        })

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Password reset link is invalid or expired"
    end

    test "renders errors for invalid password", %{conn: conn, token: token} do
      conn =
        put(conn, ~p"/password/reset/#{token}", %{
          "user" => %{
            "password" => "short",
            "password_confirmation" => "mismatch"
          }
        })

      response = html_response(conn, 200)
      assert response =~ "Create new password"
      assert response =~ "should be at least 10 character"
    end

    test "renders errors for password mismatch", %{conn: conn, token: token} do
      conn =
        put(conn, ~p"/password/reset/#{token}", %{
          "user" => %{
            "password" => "V@lidPassw0rd123",
            "password_confirmation" => "D1ff3r3ntP@ssw0rd"
          }
        })

      response = html_response(conn, 200)
      assert response =~ "Create new password"
      assert response =~ "does not match"
    end

    test "validates password requirements", %{conn: conn, token: token} do
      conn =
        put(conn, ~p"/password/reset/#{token}", %{
          "user" => %{
            "password" => "alllowercase",
            "password_confirmation" => "alllowercase"
          }
        })

      response = html_response(conn, 200)
      assert response =~ "at least one upper case character"
      assert response =~ "at least one digit or punctuation character"
    end
  end

  describe "authenticated user redirects" do
    setup %{conn: conn} do
      user = user_fixture()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_password_reset_instructions(user, url)
        end)

      %{conn: log_in_user(conn, user), user: user, token: token}
    end

    test "redirects if user is already authenticated for GET /password/reset", %{conn: conn} do
      conn = get(conn, ~p"/password/reset")
      assert redirected_to(conn) == ~p"/"
    end

    test "redirects if user is already authenticated for GET /password/reset/:token", %{conn: conn, token: token} do
      conn = get(conn, ~p"/password/reset/#{token}")
      assert redirected_to(conn) == ~p"/"
    end

    test "redirects if user is already authenticated for POST /password/reset", %{conn: conn} do
      conn = post(conn, ~p"/password/reset", %{"user" => %{"email" => "test@example.com"}})
      assert redirected_to(conn) == ~p"/"
    end

    test "redirects if user is already authenticated for POST /password/reset/:token", %{conn: conn, token: token} do
      conn = put(conn, ~p"/password/reset/#{token}", %{"user" => %{"email" => "test@example.com"}})
      assert redirected_to(conn) == ~p"/"
    end
  end
end
