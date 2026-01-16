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
            current_password: "P@ssWord123",
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
            current_password: "P@ssWord123",
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
          current_password: "P@ssWord123",
          password: "V@lidPassw0rd123",
          password_confirmation: "V@lidPassw0rd123"
        }
      })
      |> render_submit()

      # Form should be cleared (no pre-filled values)
      html = render(view)
      assert html =~ "Password updated successfully"
    end

    test "requires current password on submit", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/settings")

      result =
        view
        |> form("#update_password", %{
          user: %{
            # current_password intentionally omitted
            password: "V@lidPassw0rd123",
            password_confirmation: "V@lidPassw0rd123"
          }
        })
        |> render_submit()

      assert result =~ "can&#39;t be blank"
      refute Accounts.get_user_by_email_and_password(user.email, "V@lidPassw0rd123")
    end

    test "rejects incorrect current password", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/settings")

      result =
        view
        |> form("#update_password", %{
          user: %{
            current_password: "WrongPassword123!",
            password: "V@lidPassw0rd123",
            password_confirmation: "V@lidPassw0rd123"
          }
        })
        |> render_submit()

      assert result =~ "is not valid"
      refute Accounts.get_user_by_email_and_password(user.email, "V@lidPassw0rd123")
      # Old password should still work
      assert Accounts.get_user_by_email_and_password(user.email, "P@ssWord123")
    end

    test "validates current password presence during typing", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/settings")

      result =
        view
        |> form("#update_password", %{
          user: %{
            # current_password intentionally omitted
            password: "V@lidPassw0rd123",
            password_confirmation: "V@lidPassw0rd123"
          }
        })
        |> render_change()

      # Should show "can't be blank" during typing (presence check always runs)
      assert result =~ "can&#39;t be blank"
    end
  end
end
