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
    <.link
      navigate={~p"/calendar"}
      class={[
        "flex items-center gap-2 font-bold hover:opacity-80 transition-opacity",
        (@size == :large && "text-3xl") || "text-xl"
      ]}
    >
      <div class={[
        "bg-orange-500 rounded-lg flex items-center justify-center text-white font-bold",
        (@size == :large && "w-10 h-10 text-xl") || "w-7 h-7 text-sm"
      ]}>
        B
      </div>
      <span class={(@light && "text-white") || "text-gray-900"}>BillWatch</span>
    </.link>
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
  Renders the app layout with header navigation and filter bar.

  ## Examples

      <.app flash={@flash} current_scope={@current_scope} active_page={:calendar} year={2026}>
        <p>Main content here</p>
      </.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :current_scope, :map, required: true, doc: "the current scope with user info"
  attr :active_page, :atom, default: :calendar, doc: "the currently active page (:calendar or :settings)"
  attr :year, :integer, default: nil, doc: "current year for year navigation (optional)"
  slot :inner_block, required: true
  slot :header

  def app(assigns) do
    ~H"""
    <div class="min-h-screen bg-white">
      <!-- Header -->
      <header class="sticky top-0 z-20 bg-white border-b border-gray-200">
        <div class="px-4 py-3">
          <div class="flex items-center justify-between">
            <!-- Left: Logo + Year Nav -->
            <div class="flex items-center gap-4">
              <.logo />

              {render_slot(@header)}
            </div>
            
    <!-- Right: Add Bill + Settings -->
            <div class="flex items-center gap-2">
              <.button variant="primary" class="px-4 py-2 text-sm font-semibold flex items-center gap-1.5">
                <span class="">+</span> Add bill
              </.button>

              <.button
                variant="outline"
                class="p-2"
                phx-click={JS.toggle(to: "#settings-dropdown")}
              >
                <.icon name="hero-cog-6-tooth" class="w-5 h-5 text-gray-600" />
              </.button>
              
    <!-- Settings Dropdown -->
              <div
                id="settings-dropdown"
                class="hidden absolute top-14 right-4 bg-white rounded-xl shadow-xl border border-gray-200 min-w-[180px] overflow-hidden z-30"
              >
                <.button
                  navigate={~p"/users/settings"}
                  variant="transparent"
                  class="w-full px-4 py-3 text-sm text-left flex items-center gap-2.5 hover:bg-gray-50 justify-start"
                >
                  <.icon name="hero-cog-6-tooth" class="w-4 h-4" /> Settings
                </.button>
                <.button
                  navigate="/"
                  variant="transparent"
                  class="w-full px-4 py-3 text-sm text-left flex items-center gap-2.5 hover:bg-gray-50 justify-start"
                >
                  <.icon name="hero-question-mark-circle" class="w-4 h-4" /> Help & Support
                </.button>
                <div class="h-px bg-gray-200 my-1"></div>
                <.button
                  href={~p"/signout"}
                  method="delete"
                  variant="transparent"
                  class="w-full px-4 py-3 text-sm text-left flex items-center gap-2.5 text-red-600 hover:bg-red-50 justify-start"
                >
                  <.icon name="hero-arrow-right-on-rectangle" class="w-4 h-4" /> Log out
                </.button>
              </div>
            </div>
          </div>
        </div>
      </header>
      
    <!-- Filter Bar (only on calendar page) -->
      <%= if @active_page == :calendar do %>
        <div class="px-4 py-2.5 flex items-center justify-between">
          <!-- Categories Dropdown -->
          <div class="relative">
            <.button
              variant="outline"
              class="px-3 py-2 text-sm flex items-center gap-2"
              phx-click={JS.toggle(to: "#categories-dropdown")}
            >
              <.icon name="hero-funnel" class="w-4 h-4" />
              <span>All Categories</span>
              <.icon name="hero-chevron-down" class="w-3 h-3 ml-0.5" />
            </.button>
            
    <!-- Categories Dropdown Menu (hidden by default) -->
            <div
              id="categories-dropdown"
              class="hidden absolute top-full left-0 mt-1 bg-white rounded-xl shadow-xl border border-gray-200 min-w-[220px] overflow-hidden z-30 p-2"
            >
              <div class="flex justify-between items-center px-2 py-1 mb-1">
                <span class="text-xs font-semibold text-gray-400 uppercase tracking-wide">
                  Categories
                </span>
              </div>
              <div class="text-sm text-gray-600 px-2 py-3">Categories will be listed here</div>
            </div>
          </div>
          
    <!-- Totals -->
          <div class="flex items-center gap-4 text-sm">
            <span class="text-gray-500">
              Monthly <strong class="text-gray-900">$0</strong>
            </span>
            <span class="text-gray-300">·</span>
            <span class="text-gray-500">
              Yearly <strong class="text-gray-900">$0</strong>
            </span>
          </div>
        </div>
      <% end %>
      
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
