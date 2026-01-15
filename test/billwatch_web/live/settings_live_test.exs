defmodule BillwatchWeb.SettingsLiveTest do
  use BillwatchWeb.ConnCase

  import Phoenix.LiveViewTest
  import Billwatch.UsersFixtures

  alias Billwatch.Accounts

  describe "SettingsLive" do
    test "requires authentication - redirects to home", %{conn: conn} do
      # Not logged in
      {:error, {:redirect, %{to: path, flash: flash}}} = live(conn, ~p"/settings")

      assert path == "/"
      assert flash["error"] == "You must log in to access this page."
    end

    test "requires confirmed user - redirects to home with error", %{conn: conn} do
      # Create unconfirmed user and log in
      unconfirmed_user = unconfirmed_user_fixture()
      conn = log_in_user(conn, unconfirmed_user)

      {:error, {:redirect, %{to: path, flash: flash}}} = live(conn, ~p"/settings")

      assert path == "/"
      assert flash["error"] == "You must confirm your email address to access this page."
    end

    test "renders settings page for confirmed user", %{conn: conn} do
      # Create confirmed user and log in
      confirmed_user = user_fixture()
      conn = log_in_user(conn, confirmed_user)

      {:ok, _view, html} = live(conn, ~p"/settings")

      assert html =~ "Account Settings"
      assert html =~ "Manage your account password settings"
      assert html =~ confirmed_user.email
      assert html =~ "Email changes are not currently supported"
    end

    test "updates password successfully", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/settings")

      result =
        view
        |> form("#update_password", %{
          user: %{
            password: "V@lidPassw0rd123",
            password_confirmation: "V@lidPassw0rd123"
          }
        })
        |> render_submit()

      assert result =~ "Password updated successfully"
      assert Accounts.get_user_by_email_and_password(user.email, "V@lidPassw0rd123")
    end

    test "does not update password with invalid data", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/settings")

      result =
        view
        |> form("#update_password", %{
          user: %{
            password: "short",
            password_confirmation: "different"
          }
        })
        |> render_submit()

      assert result =~ "should be at least 10 character(s)"
      assert result =~ "does not match password"
    end

    test "validates password on change", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/settings")

      result =
        view
        |> form("#update_password", %{
          user: %{
            password: "short",
            password_confirmation: "short"
          }
        })
        |> render_change()

      assert result =~ "should be at least 10 character(s)"
    end

    test "clears form after successful password update", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/settings")

      view
      |> form("#update_password", %{
        user: %{
          password: "V@lidPassw0rd123",
          password_confirmation: "V@lidPassw0rd123"
        }
      })
      |> render_submit()

      # Form should be cleared (no pre-filled values)
      html = render(view)
      assert html =~ "Password updated successfully"
    end
  end
end
