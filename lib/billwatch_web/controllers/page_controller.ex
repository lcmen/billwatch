defmodule BillwatchWeb.PageController do
  use BillwatchWeb, :controller

  def home(conn, _params) do
    # Redirect authenticated users to calendar
    if conn.assigns[:current_scope] do
      redirect(conn, to: ~p"/calendar")
    else
      render(conn, :home)
    end
  end
end
