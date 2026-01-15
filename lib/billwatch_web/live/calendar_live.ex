defmodule BillwatchWeb.CalendarLive do
  use BillwatchWeb, :live_view

  alias BillwatchWeb.Layouts

  on_mount {BillwatchWeb.UserAuth, :assign_current_scope}

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Calendar")
     |> assign(:year, 2026)
     |> assign(:bills, [])}
  end

  def handle_event("prev_year", _params, socket) do
    {:noreply, assign(socket, :year, socket.assigns.year - 1)}
  end

  def handle_event("next_year", _params, socket) do
    {:noreply, assign(socket, :year, socket.assigns.year + 1)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} active_page={:calendar} year={@year}>
      <div class="p-2">
        <div class="border border-gray-200 rounded-xl overflow-hidden bg-gray-200" style="gap: 1px;">
          <div class="grid grid-cols-[repeat(auto-fill,minmax(70px,1fr))] gap-px bg-gray-200">
            <%= for day <- 1..365 do %>
              <div class="bg-white h-16 p-1 flex flex-col">
                <div class="flex items-baseline gap-1 mb-0.5">
                  <%= if rem(day, 30) == 1 do %>
                    <span class="text-[9px] font-bold text-orange-500">
                      <%= month_name(div(day, 30)) %>
                    </span>
                  <% end %>
                  <span class="text-[9px] font-semibold text-gray-400">
                    <%= day_of_week(day) %>
                  </span>
                  <span class="text-[11px] font-semibold text-gray-900">
                    <%= rem(day - 1, 30) + 1 %>
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

  defp month_name(month) do
    months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    Enum.at(months, rem(month, 12))
  end

  defp day_of_week(day) do
    days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    Enum.at(days, rem(day, 7))
  end
end
