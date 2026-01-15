defmodule BillwatchWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use BillwatchWeb, :html

  embed_templates "page_html/*"

  @doc """
  Renders the landing page background with gradient, pattern, navigation, hero, and footer.
  This is used as the background for modal pages like signin/signup.
  """
  attr :class, :string, default: nil
  attr :flash, :map, default: nil
  slot :inner_block

  def landing_page_background(assigns) do
    ~H"""
    <div class={["min-h-screen bg-gradient-to-br from-[#667eea] via-[#764ba2] to-[#f97316] relative", @class]}>
      <!-- Pattern overlay -->
      <div
        class="absolute inset-0 opacity-5 pointer-events-none"
        style={"background-image: url(\"data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='1'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E\")"}
      >
      </div>
      
    <!-- Toast Notifications (only shown when explicitly passed) -->
      <%= if @flash do %>
        <.flash_messages flash={@flash} autohide={true} />
      <% end %>
      
    <!-- Navigation -->
      <nav class="relative z-10 px-6 py-4 flex justify-between items-center">
        <BillwatchWeb.Layouts.logo light={true} />
        <div class="flex gap-3">
          <.button
            navigate={~p"/signin"}
            variant="ghost"
          >
            Log in
          </.button>
          <.button
            navigate={~p"/signup"}
            variant="blank"
          >
            Sign up
          </.button>
        </div>
      </nav>
      <!-- Hero -->
      <main class="relative z-10 flex-1 flex flex-col items-center justify-center px-6 py-20 text-center min-h-[calc(100vh-160px)]">
        <h1 class="text-5xl md:text-6xl font-bold text-white mb-4 drop-shadow-lg leading-tight">
          Track your bills,<br />never miss a payment
        </h1>
        <p class="text-lg text-white/90 mb-8 max-w-md">
          Simple calendar view for all your recurring bills and subscriptions.
        </p>
        <.button
          navigate={~p"/signup"}
          variant="blank"
          size="lg"
        >
          Get started — it's free
        </.button>
      </main>
      <!-- Footer -->
      <footer class="relative z-10 px-6 py-4 text-center text-white/60 text-sm">
        © 2026 BillWatch
      </footer>

      {render_slot(@inner_block)}
    </div>
    """
  end
end
