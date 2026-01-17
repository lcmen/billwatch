defmodule BillwatchWeb.PasswordHTML do
  use BillwatchWeb, :html

  import BillwatchWeb.PageHTML, only: [landing_page: 1]

  embed_templates "password_html/*"
end
