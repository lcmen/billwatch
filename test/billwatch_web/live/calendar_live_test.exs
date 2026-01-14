defmodule BillwatchWeb.CalendarLiveTest do
  use BillwatchWeb.ConnCase

  import Phoenix.LiveViewTest
  import Billwatch.UsersFixtures

  describe "CalendarLive" do
    test "requires authentication - redirects to home", %{conn: conn} do
      # Not logged in
      {:error, {:redirect, %{to: path, flash: flash}}} = live(conn, ~p"/calendar")

      assert path == "/"
      assert flash["error"] == "You must log in to access this page."
    end

    test "requires confirmed user - redirects to home with error", %{conn: conn} do
      # Create unconfirmed user and log in
      unconfirmed_user = unconfirmed_user_fixture()
      conn = log_in_user(conn, unconfirmed_user)

      {:error, {:redirect, %{to: path, flash: flash}}} = live(conn, ~p"/calendar")

      assert path == "/"
      assert flash["error"] == "You must confirm your email address to access this page."
    end

    test "renders calendar for confirmed user", %{conn: conn} do
      # Create confirmed user and log in
      confirmed_user = user_fixture()
      conn = log_in_user(conn, confirmed_user)

      {:ok, _view, html} = live(conn, ~p"/calendar")

      assert html =~ "No bills yet"
      assert html =~ "Add your first bill"
    end
  end
end
