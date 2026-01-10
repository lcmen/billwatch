defmodule BillwatchWeb.PageController do
  use BillwatchWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
