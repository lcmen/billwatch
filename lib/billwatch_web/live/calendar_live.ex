defmodule BillwatchWeb.CalendarLive do
  use BillwatchWeb, :live_view

  alias BillwatchWeb.Layouts

  on_mount {BillwatchWeb.UserAuth, :assign_current_scope}

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Calendar")
     |> assign(:bills, [])}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} active_page={:calendar}>
      <:header_content>
        <div class="flex items-center gap-2">
          <.button variant="ghost" phx-click="prev_year" class="p-2 text-gray-600">‹</.button>
          <span class="text-lg font-semibold min-w-[60px] text-center">2026</span>
          <.button variant="ghost" phx-click="next_year" class="p-2 text-gray-600">›</.button>
        </div>
      </:header_content>

      <div class="p-3 max-w-[1400px] mx-auto">
        <!-- Empty State -->
        <div class="bg-white rounded-xl border border-gray-200 p-16 text-center">
          <div class="w-16 h-16 bg-orange-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <.icon name="hero-calendar" class="w-8 h-8 text-orange-500" />
          </div>
          <h2 class="text-xl font-semibold text-gray-900 mb-2">No bills yet</h2>
          <p class="text-gray-600 mb-6">Get started by adding your first bill</p>
          <.button variant="primary" phx-click="show_add_modal" class="px-6 py-3">
            Add your first bill
          </.button>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
