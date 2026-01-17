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
  attr :path, :string, default: nil, doc: "path to navigate to on click"

  def logo(assigns) do
    ~H"""
    <.link
      navigate={@path}
      class={[
        "flex items-center gap-2 font-bold transition-opacity text-xl hover:opacity-80",
        !@path && "pointer-events-none"
      ]}
    >
      <div class="bg-orange-500 rounded-lg flex items-center justify-center text-white font-bold w-7 h-7 text-sm">
        B
      </div>
      <span class={(@light && "text-white") || "text-gray-900"}>BillWatch</span>
    </.link>
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
              <.logo path={~p"/calendar"} />

              {render_slot(@header)}
            </div>
            
    <!-- Right: Add Bill + Settings -->
            <div class="flex items-center gap-2">
              <.button variant="primary">
                <span class="">+</span> Add bill
              </.button>

              <.dropdown id="settings-dropdown">
                <:trigger>
                  <.icon name="hero-cog-6-tooth" class="w-5 h-5 my-0.5 text-gray-600" />
                </:trigger>
                <:content>
                  <.button navigate={~p"/settings"} variant="transparent">
                    <.icon name="hero-cog-6-tooth" class="w-4 h-4" /> Settings
                  </.button>
                  <.button navigate="/" variant="transparent">
                    <.icon name="hero-question-mark-circle" class="w-4 h-4" /> Help & Support
                  </.button>
                  <div class="h-px bg-gray-200 my-1"></div>
                  <.button href={~p"/signout"} method="delete" variant="transparent" class="text-red-600 hover:bg-red-50">
                    <.icon name="hero-arrow-right-on-rectangle" class="w-4 h-4" /> Log out
                  </.button>
                </:content>
              </.dropdown>
            </div>
          </div>
        </div>
      </header>

      <.flash_messages flash={@flash} autohide={true} />
      
    <!-- Main Content -->
      <main>
        {render_slot(@inner_block)}
      </main>
    </div>
    """
  end

  @doc """
  Renders a centered modal dialog with backdrop, title, and content.

  ## Examples

      <.modal title="Log in" flash={@flash}>
        <.form for={@form}>
          <!-- form fields here -->
        </.form>
      </.modal>

  """
  attr :title, :string, required: true, doc: "the modal title"
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :close_path, :string, default: "/", doc: "path to navigate to when closing the modal"
  slot :inner_block, required: true

  def modal(assigns) do
    ~H"""
    <!-- Modal overlay backdrop -->
    <div class="fixed inset-0 bg-black/40 z-40"></div>

    <!-- Modal Card -->
    <div class="fixed inset-0 z-50 flex items-center justify-center px-4 py-12">
      <div class="w-full max-w-[360px] p-8 bg-white rounded-2xl shadow-[0_25px_50px_rgba(0,0,0,0.25)]">
        <div class="flex justify-between items-center mb-6">
          <h2 class="text-xl font-semibold text-gray-900">{@title}</h2>
          <.button navigate={@close_path} variant="secondary" size="sm">
            ✕
          </.button>
        </div>

        <.flash_messages flash={@flash} autohide={false} embedded={true} />

        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
