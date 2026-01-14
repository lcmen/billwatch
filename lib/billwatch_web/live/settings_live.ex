defmodule BillwatchWeb.SettingsLive do
  use BillwatchWeb, :live_view

  alias BillwatchWeb.Layouts

  on_mount {BillwatchWeb.UserAuth, :assign_current_scope}

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Settings")}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} active_page={:settings}>
      <:header_content>
        <h1 class="text-lg font-semibold text-gray-900">Settings</h1>
      </:header_content>

      <div class="p-6 max-w-2xl mx-auto">
        <div class="flex flex-col gap-6">
          <!-- Profile Info Card -->
          <div class="bg-white rounded-xl border border-gray-200 p-6">
            <h2 class="text-lg font-semibold text-gray-900 mb-4">Profile</h2>
            <div class="flex flex-col gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-500 mb-1">Email</label>
                <p class="text-gray-900">{@current_scope.user.email}</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-500 mb-1">Account</label>
                <p class="text-gray-900">{@current_scope.account.name}</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-500 mb-1">Role</label>
                <span class={[
                  "inline-flex px-2.5 py-1 rounded-full text-xs font-medium",
                  @current_scope.role == :admin && "bg-orange-100 text-orange-700",
                  @current_scope.role != :admin && "bg-gray-100 text-gray-700"
                ]}>
                  {String.capitalize(to_string(@current_scope.role))}
                </span>
              </div>
            </div>
          </div>
          
    <!-- Password Change Card -->
          <div class="bg-white rounded-xl border border-gray-200 p-6">
            <h2 class="text-lg font-semibold text-gray-900 mb-4">Change Password</h2>
            <form class="flex flex-col gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Current password</label>
                <input
                  type="password"
                  class="w-full px-3 py-2.5 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                  placeholder="Enter current password"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">New password</label>
                <input
                  type="password"
                  class="w-full px-3 py-2.5 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                  placeholder="Enter new password"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Confirm new password</label>
                <input
                  type="password"
                  class="w-full px-3 py-2.5 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                  placeholder="Confirm new password"
                />
              </div>
              <p class="text-xs text-gray-500">
                Must be at least 10 characters with uppercase, lowercase, and a digit.
              </p>
              <.button
                type="submit"
                variant="primary"
                class="w-full py-3"
              >
                Update Password
              </.button>
            </form>
          </div>
          
    <!-- Danger Zone Card -->
          <div class="bg-white rounded-xl border border-red-200 p-6">
            <h2 class="text-lg font-semibold text-red-600 mb-4">Danger Zone</h2>
            <div class="flex flex-col gap-3">
              <.button variant="secondary" phx-click="leave_account" class="w-full py-3">
                Leave Account
              </.button>
              <.button variant="danger" phx-click="delete_account" class="w-full py-3">
                Delete Account
              </.button>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
