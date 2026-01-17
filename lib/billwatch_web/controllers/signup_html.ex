defmodule BillwatchWeb.SignupHTML do
  use BillwatchWeb, :html

  import BillwatchWeb.PageHTML, only: [landing_page: 1]

  embed_templates "signup_html/*"
end
