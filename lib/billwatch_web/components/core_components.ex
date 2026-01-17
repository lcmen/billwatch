defmodule BillwatchWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, such as tables, forms, and
  inputs. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The foundation for styling is Tailwind CSS, a utility-first CSS framework.
  Here are useful references:

    * [Tailwind CSS](https://tailwindcss.com) - the foundational framework
      we build on. You will use it for layout, sizing, flexbox, grid, and
      spacing.

    * [Heroicons](https://heroicons.com) - see `icon/1` for usage.

    * [Phoenix.Component](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html) -
      the component system used by Phoenix. Some components, such as `<.link>`
      and `<.form>`, are defined there.

  """
  use Phoenix.Component
  use Gettext, backend: BillwatchWeb.Gettext

  alias Phoenix.LiveView.JS

  @doc """
  Renders flash messages as toast notifications with optional auto-hide functionality.

  ## Examples

      <.flash_messages flash={@flash} autohide={true} />
      <.flash_messages flash={@flash} autohide={false} inline={true} />
  """
  attr :flash, :map, required: true
  attr :autohide, :boolean, default: false
  attr :embedded, :boolean, default: false

  def flash_messages(assigns) do
    ~H"""
    <div class={
      if @embedded do
        nil
      else
        "fixed top-6 left-1/2 -translate-x-1/2 z-50 w-full max-w-md px-6 pointer-events-none"
      end
    }>
      <%= for {type, message} <- @flash do %>
        <.flash_message autohide={@autohide} embedded={@embedded} variant={type}>
          {message}
        </.flash_message>
      <% end %>
    </div>
    """
  end

  attr :autohide, :boolean, default: false
  attr :embedded, :boolean, default: false
  attr :variant, :string, required: true
  slot :inner_block, required: true

  def flash_message(assigns) do
    classes = [
      "flash",
      !assigns.embedded && "flash-toast",
      case assigns.variant do
        "error" -> "flash-error"
        "info" -> "flash-info"
      end
    ]

    icon =
      case assigns.variant do
        "error" -> "hero-exclamation-circle"
        "info" -> "hero-check-circle"
      end

    assigns =
      assigns
      |> assign(:id, "flash-#{assigns.variant}")
      |> assign(:classes, classes)
      |> assign(:icon, icon)

    ~H"""
    <div
      id={@id}
      class={@classes}
      phx-mounted={
        if @autohide do
          JS.dispatch("phx:auto-hide", detail: %{id: @id, delay: 3000})
        end
      }
    >
      <div class="flash-message">
        <.icon name={@icon} />
        <p>{render_slot(@inner_block)}</p>
      </div>
    </div>
    """
  end

  @doc """
  Renders a button with navigation support and multiple variants.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" variant="primary">Send!</.button>
      <.button navigate={~p"/"}>Home</.button>
      <.button navigate={~p"/calendar"} variant="secondary" active={true}>Calendar</.button>
  """
  attr :rest, :global, include: ~w(href navigate patch method download name value disabled type phx-click phx-value-id)

  attr :class, :any, default: nil
  attr :variant, :string, default: nil
  attr :size, :string, default: nil
  attr :active, :boolean, default: false, doc: "whether this button represents the current page"
  slot :inner_block, required: true

  def button(%{rest: rest} = assigns) do
    active = assigns.active || false
    disabled = rest[:disabled] || false

    aria_attrs =
      %{
        "aria-current": active && "page",
        "aria-disabled": (active || disabled) && "true"
      }
      |> Enum.reject(fn {_, v} -> !v end)
      |> Map.new()

    button_classes = [
      "btn",
      active && "btn-active",
      disabled && "btn-disabled",
      case assigns.variant do
        "primary" -> "btn-primary"
        "secondary" -> "btn-secondary"
        "danger" -> "btn-danger"
        "outline" -> "btn-outline"
        "transparent" -> "btn-transparent"
        "ghost" -> "btn-ghost"
        "blank" -> "btn-blank"
        _ -> "btn-primary"
      end,
      case assigns.size do
        "sm" -> "btn-sm"
        "lg" -> "btn-lg"
        _ -> nil
      end,
      assigns.class
    ]

    assigns =
      assigns
      |> assign(:aria_attrs, aria_attrs)
      |> assign(:button_classes, button_classes)

    if rest[:href] || rest[:navigate] || rest[:patch] do
      ~H"""
      <.link class={@button_classes} {@rest} {@aria_attrs}>
        {render_slot(@inner_block)}
      </.link>
      """
    else
      ~H"""
      <button class={@button_classes} {@rest} {@aria_attrs}>
        {render_slot(@inner_block)}
      </button>
      """
    end
  end

  @doc """
  Renders a dropdown menu with a trigger and content.

  ## Examples

      <.dropdown id="my-dropdown">
        <:trigger>
          <.button variant="outline">
            <.icon name="hero-cog-6-tooth" class="w-5 h-5" />
          </.button>
        </:trigger>
        <:content>
          <.button variant="transparent">Settings</.button>
          <.button variant="transparent">Help</.button>
        </:content>
      </.dropdown>

      <.dropdown id="categories" position="left">
        <:trigger>
          <.button variant="outline">Categories</.button>
        </:trigger>
        <:content class="p-2">
          <div>Custom content here</div>
        </:content>
      </.dropdown>
  """
  attr :id, :string, required: true, doc: "unique identifier for the dropdown"
  attr :position, :string, default: "right", values: ~w(left right), doc: "dropdown alignment (left or right)"
  attr :class, :string, default: nil, doc: "additional classes for the dropdown container"
  slot :trigger, required: true, doc: "the clickable element that toggles the dropdown"

  slot :content, required: true, doc: "the dropdown menu content" do
    attr :class, :string, doc: "additional classes for the dropdown content"
  end

  def dropdown(assigns) do
    position_class =
      case assigns.position do
        "left" -> "dropdown-left"
        "right" -> "dropdown-right"
        _ -> "dropdown-right"
      end

    assigns = assign(assigns, :position_class, position_class)

    ~H"""
    <div class={["dropdown", @class]}>
      <div phx-click={JS.toggle(to: "##{@id}")}>
        <.button variant="outline">
          {render_slot(@trigger)}
          <.icon name="hero-chevron-down" class="w-3 h-3 ml-0.5" />
        </.button>
      </div>

      <div
        id={@id}
        class={["dropdown-content", @position_class, get_in(@content, [Access.at(0), :class])]}
        phx-click-away={JS.hide(to: "##{@id}")}
      >
        {render_slot(@content)}
      </div>
    </div>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information. Unsupported types, such as radio, are best
  written directly in your templates.

  ## Examples

  ```heex
  <.input field={@form[:email]} type="email" />
  <.input name="my-input" errors={["oh no!"]} />
  ```

  ## Select type

  When using `type="select"`, you must pass the `options` and optionally
  a `value` to mark which option should be preselected.

  ```heex
  <.input field={@form[:user_type]} type="select" options={["Admin": "admin", "User": "user"]} />
  ```

  For more information on what kind of data can be passed to `options` see
  [`options_for_select`](https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html#options_for_select/2).
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               search select tel text textarea time url week hidden)

  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  attr :class, :any, default: nil, doc: "the input class to use over defaults"
  attr :error_class, :any, default: nil, doc: "the input error class to use over defaults"

  attr :rest, :global, include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "hidden"} = assigns) do
    ~H"""
    <input type="hidden" id={@id} name={@name} value={@value} {@rest} />
    """
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class="mb-2">
      <label class="flex items-center">
        <input
          type="hidden"
          name={@name}
          value="false"
          disabled={@rest[:disabled]}
          form={@rest[:form]}
        />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class={@class || "h-4 w-4 rounded border-gray-300 text-orange-500 focus:ring-orange-500 focus:ring-2"}
          {@rest}
        />
        <span class="ml-2 text-sm text-gray-700">{@label}</span>
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div class="mb-4">
      <label class="block">
        <span :if={@label} class="block text-sm font-medium text-gray-700 mb-1">{@label}</span>
        <select
          id={@id}
          name={@name}
          class={[
            @class || "w-full px-3.5 py-3 border rounded-lg text-sm focus:outline-none focus:ring-2 transition-colors",
            @errors == [] && "border-gray-300 focus:ring-orange-500 focus:border-orange-500",
            @errors != [] && (@error_class || "border-red-500 focus:ring-red-500 focus:border-red-500")
          ]}
          multiple={@multiple}
          {@rest}
        >
          <option :if={@prompt} value="">{@prompt}</option>
          {Phoenix.HTML.Form.options_for_select(@options, @value)}
        </select>
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div class="mb-4">
      <label class="block">
        <span :if={@label} class="block text-sm font-medium text-gray-700 mb-1">{@label}</span>
        <textarea
          id={@id}
          name={@name}
          class={[
            @class || "w-full px-3.5 py-3 border rounded-lg text-sm focus:outline-none focus:ring-2 transition-colors",
            @errors == [] && "border-gray-300 focus:ring-orange-500 focus:border-orange-500",
            @errors != [] && (@error_class || "border-red-500 focus:ring-red-500 focus:border-red-500")
          ]}
          {@rest}
        >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    ~H"""
    <div class="mb-4">
      <label class="block">
        <span :if={@label} class="block text-sm font-medium text-gray-700 mb-1">{@label}</span>
        <input
          type={@type}
          name={@name}
          id={@id}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          class={[
            @class || "w-full px-3.5 py-3 border rounded-lg text-sm focus:outline-none focus:ring-2 transition-colors",
            @errors == [] && "border-gray-300 focus:ring-orange-500 focus:border-orange-500",
            @errors != [] && (@error_class || "border-red-500 focus:ring-red-500 focus:border-red-500")
          ]}
          {@rest}
        />
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  # Helper used by inputs to generate form errors
  defp error(assigns) do
    ~H"""
    <p class="mt-1 flex gap-1.5 items-center text-sm text-red-600">
      <.icon name="hero-exclamation-circle" class="size-4" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Renders a header with title.
  """
  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", "pb-4"]}>
      <div>
        <h1 class="text-lg font-semibold leading-8">
          {render_slot(@inner_block)}
        </h1>
        <p :if={@subtitle != []} class="text-sm text-base-content/70">
          {render_slot(@subtitle)}
        </p>
      </div>
      <div class="flex-none">{render_slot(@actions)}</div>
    </header>
    """
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from the `deps/heroicons` directory and bundled within
  your compiled app.css by the plugin in `assets/vendor/heroicons.js`.

  ## Examples

      <.icon name="hero-x-mark" />
      <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :any, default: "size-4"

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(BillwatchWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(BillwatchWeb.Gettext, "errors", msg, opts)
    end
  end
end
