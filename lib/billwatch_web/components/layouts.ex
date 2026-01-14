defmodule BillwatchWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use BillwatchWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders the BillWatch logo with an orange square badge and text.

  ## Examples

      <.logo />
      <.logo light={true} />
      <.logo size={:large} />

  """
  attr :light, :boolean, default: false, doc: "use light (white) text for dark backgrounds"
  attr :size, :atom, default: :default, values: [:default, :large], doc: "size variant"

  def logo(assigns) do
    ~H"""
    <div class={[
      "flex items-center gap-2 font-bold",
      (@size == :large && "text-3xl") || "text-xl"
    ]}>
      <div class={[
        "bg-orange-500 rounded-lg flex items-center justify-center text-white font-bold",
        (@size == :large && "w-10 h-10 text-xl") || "w-7 h-7 text-sm"
      ]}>
        B
      </div>
      <span class={(@light && "text-white") || "text-gray-900"}>BillWatch</span>
    </div>
    """
  end

  @doc """
  Shows flash messages with auto-hide support.

  ## Examples

      <.flash_group flash={@flash} />
      <.flash_group flash={@flash} autohide={true} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :autohide, :boolean, default: false, doc: "whether to auto-hide flash messages"

  def flash_group(assigns) do
    ~H"""
    <.flash_messages flash={@flash} autohide={@autohide} />
    """
  end

  @doc """
  Renders the app layout with hamburger menu navigation.

  ## Examples

      <.app flash={@flash} current_scope={@current_scope} active_page={:calendar}>
        <:header_content>
          <h1>Calendar</h1>
        </:header_content>
        <p>Main content here</p>
      </.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :current_scope, :map, required: true, doc: "the current scope with user info"
  attr :active_page, :atom, default: :calendar, doc: "the currently active page (:calendar or :settings)"
  slot :header_content, doc: "content to display in the header next to hamburger menu"
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="min-h-screen bg-white">
      <!-- Header -->
      <header class="sticky top-0 z-20 bg-white border-b border-gray-200">
        <div class="max-w-[1400px] mx-auto px-4 py-3">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-4">
              <.button
                variant="ghost"
                phx-click={JS.remove_class("hidden", to: "#menu-overlay") |> JS.remove_class("hidden", to: "#menu-panel")}
                class="p-2"
              >
                <.icon name="hero-bars-3" class="w-5 h-5 text-gray-600" />
              </.button>
              {render_slot(@header_content)}
            </div>
          </div>
        </div>
      </header>
      
    <!-- Menu Overlay -->
      <div
        id="menu-overlay"
        phx-click={JS.add_class("hidden", to: "#menu-overlay") |> JS.add_class("hidden", to: "#menu-panel")}
        class="hidden fixed inset-0 bg-black/30 z-25"
      />
      
    <!-- Slide-out Menu Panel -->
      <div
        id="menu-panel"
        class="hidden fixed top-0 left-0 bottom-0 w-[280px] bg-white z-30 shadow-xl flex flex-col h-full"
      >
        <!-- Menu Header -->
        <div class="p-5 border-b border-gray-200">
          <div class="flex items-center justify-between">
            <.logo />
            <.button
              variant="secondary"
              phx-click={JS.add_class("hidden", to: "#menu-overlay") |> JS.add_class("hidden", to: "#menu-panel")}
              class="p-2"
            >
              <.icon name="hero-x-mark" class="w-4 h-4 text-gray-600" />
            </.button>
          </div>
        </div>
        
    <!-- Navigation (top) -->
        <div class="p-5">
          <h3 class="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-3">
            Categories
          </h3>
          <div class="flex flex-col gap-1.5">
            Categories will go here
          </div>
        </div>
        
    <!-- Account (bottom) -->
        <div class="p-5 border-t border-gray-200 mt-auto">
          <h3 class="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-3">
            Navigation
          </h3>
          <div class="flex flex-col gap-1.5">
            <.button
              navigate={~p"/calendar"}
              variant={if @active_page == :calendar, do: "primary", else: "secondary"}
              active={@active_page == :calendar}
              class="flex items-center gap-3 px-3 py-2.5 text-sm font-medium w-full justify-start"
            >
              <.icon name="hero-calendar" class="w-4.5 h-4.5" /> Calendar
            </.button>
            <.button
              navigate={~p"/settings"}
              variant={if @active_page == :settings, do: "primary", else: "secondary"}
              active={@active_page == :settings}
              class="flex items-center gap-3 px-3 py-2.5 text-sm font-medium w-full justify-start"
            >
              <.icon name="hero-cog-6-tooth" class="w-4.5 h-4.5" /> Settings
            </.button>
            <.button
              href={~p"/signout"}
              method="delete"
              variant="danger"
              class="flex items-center gap-3 px-3 py-2.5 text-sm font-medium w-full justify-start"
            >
              <.icon name="hero-arrow-right-on-rectangle" class="w-4.5 h-4.5" /> Log out
            </.button>
          </div>
        </div>
        
    <!-- Monthly/Yearly Cost (footer) -->
        <div class="p-4 border-t border-gray-200 bg-gray-50">
          <div class="flex justify-between text-sm text-gray-600 mb-1">
            <span>Monthly</span>
            <strong class="text-gray-900">$0.00</strong>
          </div>
          <div class="flex justify-between text-sm text-gray-600">
            <span>Yearly</span>
            <strong class="text-gray-900">$0.00</strong>
          </div>
        </div>
      </div>
      
    <!-- Flash Messages -->
      <.flash_group flash={@flash} autohide={true} />
      
    <!-- Main Content -->
      <main>
        {render_slot(@inner_block)}
      </main>
    </div>
    """
  end
end
