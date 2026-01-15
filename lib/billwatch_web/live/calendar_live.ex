defmodule BillwatchWeb.CalendarLive do
  use BillwatchWeb, :live_view

  alias BillwatchWeb.Layouts

  @days ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
  @months ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

  on_mount {BillwatchWeb.UserAuth, :assign_current_scope}

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Calendar")
     |> assign(:bills, [])}
  end

  def handle_params(params, _uri, socket) do
    year =
      case params["year"] do
        nil -> Date.utc_today().year
        year -> String.to_integer(year)
      end

    {:noreply, assign(socket, dates: generate_dates(year), year: year)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} active_page={:calendar}>
      <:header>
        <div class="flex items-center gap-1 ml-2">
          <.button
            class="px-2.5 py-1.5 text-lg text-gray-600"
            variant="transparent"
            patch={~p"/calendar?year=#{@year - 1}"}
          >
            ‹
          </.button>
          <span class="text-lg font-semibold w-12 text-center">{@year}</span>
          <.button
            variant="transparent"
            class="px-2.5 py-1.5 text-lg text-gray-600"
            patch={~p"/calendar?year=#{@year + 1}"}
          >
            ›
          </.button>
        </div>
      </:header>

      <div class="p-2">
        <div class="border border-gray-200 rounded-xl overflow-hidden bg-gray-200" style="gap: 1px;">
          <div class="grid grid-cols-[repeat(auto-fill,minmax(70px,1fr))] gap-px bg-gray-200">
            <%= for date <- @dates do %>
              <div class="bg-white h-16 p-1 flex flex-col">
                <div class="flex items-baseline gap-1 mb-0.5">
                  <%= if date.day == 1 do %>
                    <span class="text-[9px] font-bold text-orange-500">
                      {month_name(date)}
                    </span>
                  <% end %>
                  <span class="text-[9px] font-semibold text-gray-400">
                    {day_name(date)}
                  </span>
                  <span class="text-[11px] font-semibold text-gray-900">
                    {date.day}
                  </span>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp generate_dates(year) do
    start_date = Date.new!(year, 1, 1)
    end_date = Date.new!(year, 12, 31)

    Date.range(start_date, end_date)
  end

  defp day_name(date) do
    Enum.at(@days, Date.day_of_week(date) - 1)
  end

  defp month_name(date) do
    Enum.at(@months, date.month - 1)
  end
end
