defmodule BillwatchWeb.SettingsLive do
  use BillwatchWeb, :live_view

  alias Billwatch.Accounts
  alias BillwatchWeb.Layouts

  on_mount {BillwatchWeb.UserAuth, :assign_current_scope}

  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    password_changeset = Accounts.change_user_password(user)

    {:ok,
     socket
     |> assign(:page_title, "Settings")
     |> assign(:password_form, to_form(password_changeset))}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} active_page={:settings}>
      <div class="max-w-2xl mx-auto p-8">
        <div class="text-center mb-8">
          <.header>
            Account Settings
            <:subtitle>Manage your account password settings</:subtitle>
          </.header>
        </div>

        <div class="mb-8">
          <label class="block text-sm font-medium text-gray-700 mb-2">Email</label>
          <input
            type="email"
            value={@current_scope.user.email}
            disabled
            class="w-full px-3.5 py-3 border border-gray-300 rounded-lg text-sm bg-gray-50 text-gray-500 cursor-not-allowed"
          />
          <p class="mt-2 text-sm text-gray-500">Email changes are not currently supported</p>
        </div>

        <div class="border-t border-gray-200 my-8"></div>

        <.form id="update_password" for={@password_form} phx-submit="update_password" phx-change="validate_password">
          <.input
            field={@password_form[:password]}
            type="password"
            label="New password"
            autocomplete="new-password"
            required
          />
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label="Confirm new password"
            autocomplete="new-password"
            required
          />
          <.button variant="primary" phx-disable-with="Changing...">
            Save Password
          </.button>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("validate_password", %{"user" => user_params}, socket) do
    password_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form)}
  end

  def handle_event("update_password", %{"user" => user_params}, socket) do
    user = socket.assigns.current_scope.user

    case Accounts.update_user_password(user, user_params) do
      {:ok, {user, _}} ->
        password_form =
          user
          |> Accounts.change_user_password(%{})
          |> to_form()

        {:noreply,
         socket
         |> put_flash(:info, "Password updated successfully.")
         |> assign(:password_form, password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
