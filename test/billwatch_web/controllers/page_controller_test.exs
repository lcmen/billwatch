defmodule BillwatchWeb.PageControllerTest do
  use BillwatchWeb.ConnCase

  import Billwatch.UsersFixtures

  describe "GET /" do
    test "renders landing page successfully", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)

      assert response =~ "Track your bills"
      assert response =~ "never miss a payment"
      assert response =~ "Get started — it's free"
      assert response =~ "BillWatch"
    end

    test "shows login and signup buttons", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)

      assert response =~ "Log in"
      assert response =~ "Sign up"
    end

    test "redirects authenticated users to calendar", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      conn = get(conn, ~p"/")

      assert redirected_to(conn) == ~p"/calendar"
    end
  end
end
