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

  # Conditionally builds CSS class strings based on boolean flags.
  #
  # Similar to the `classnames` library in JavaScript or Rails' `class_names` helper.
  # Takes a list of tuples where each tuple is `{class_string, boolean}`.
  # Only includes classes where the boolean is truthy.
  #
  # Examples:
  #
  #     class_names([
  #       {"base-class", true},
  #       {"active", @active},
  #       {"disabled", @disabled},
  #       {@custom_classes, @custom_classes != nil}
  #     ])
  #     #=> "base-class active"  (if @active is true and @disabled is false)
  #
  defp class_names(class_list) do
    class_list
    |> Enum.filter(fn
      {_class, condition} -> condition
      str when is_binary(str) -> true
      _ -> false
    end)
    |> Enum.map(fn
      {class, _condition} -> class
      str when is_binary(str) -> str
    end)
    |> Enum.join(" ")
    |> String.trim()
  end

  @doc """
  Renders flash messages as toast notifications with optional auto-hide functionality.

  ## Examples

      <.flash_messages flash={@flash} autohide={true} />
      <.flash_messages flash={@flash} autohide={false} inline={true} />
  """
  attr :flash, :map, required: true
  attr :autohide, :boolean, default: false
  attr :inline, :boolean, default: false

  def flash_messages(assigns) do
    ~H"""
    <div class={
      if @inline do
        nil
      else
        "fixed top-6 left-1/2 -translate-x-1/2 z-50 w-full max-w-md px-6 pointer-events-none"
      end
    }>
      <%= if @flash["info"] do %>
        <div
          id="flash-info"
          class={[
            "mb-3 p-4 bg-green-50 rounded-xl transition-all duration-300 ease-out",
            !@inline && "shadow-2xl animate-[slideDown_0.3s_ease-out] pointer-events-auto"
          ]}
          phx-mounted={
            if @autohide do
              JS.dispatch("phx:auto-hide", detail: %{id: "flash-info", delay: 3000})
            end
          }
        >
          <div class="flex items-start">
            <.icon name="hero-check-circle" class="w-5 h-5 text-green-600 mr-3 mt-0.5 flex-shrink-0" />
            <p class="text-sm text-green-900 font-medium">{@flash["info"]}</p>
          </div>
        </div>
      <% end %>
      <%= if @flash["error"] do %>
        <div
          id="flash-error"
          class={[
            "mb-3 p-4 bg-red-50 rounded-xl transition-all duration-300 ease-out",
            !@inline && "shadow-2xl animate-[slideDown_0.3s_ease-out] pointer-events-auto"
          ]}
          phx-mounted={
            if @autohide do
              JS.dispatch("phx:auto-hide", detail: %{id: "flash-error", delay: 3000})
            end
          }
        >
          <div class="flex items-start">
            <.icon name="hero-exclamation-circle" class="w-5 h-5 text-red-600 mr-3 mt-0.5 flex-shrink-0" />
            <p class="text-sm text-red-900 font-medium">{@flash["error"]}</p>
          </div>
        </div>
      <% end %>
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

  attr :class, :any
  attr :variant, :string, default: nil
  attr :size, :string, default: nil
  attr :active, :boolean, default: false, doc: "whether this button represents the current page"
  slot :inner_block, required: true

  def button(%{rest: rest} = assigns) do
    active = assigns.active || false
    disabled = rest[:disabled] || false
    variant = assigns.variant || "primary"

    # Base variant colors (always apply unless active overrides)
    variant_classes =
      case variant do
        "primary" ->
          class_names([
            "bg-orange-500 text-white",
            {"hover:bg-orange-600", !active && !disabled}
          ])

        "secondary" ->
          class_names([
            "bg-gray-100 text-gray-700",
            {"hover:bg-gray-200", !active && !disabled}
          ])

        "danger" ->
          class_names([
            "bg-red-50 text-red-600",
            {"hover:bg-red-100", !active && !disabled}
          ])

        "outline" ->
          class_names([
            "border border-gray-300 bg-white text-gray-700",
            {"hover:bg-gray-50", !active && !disabled}
          ])

        "ghost" ->
          class_names([
            "bg-transparent text-gray-700",
            {"hover:bg-gray-100", !active && !disabled}
          ])

        "custom" ->
          ""
      end

    # Cursor classes based on state
    cursor_classes =
      class_names([
        {"cursor-pointer", !active && !disabled},
        {"cursor-default pointer-events-none", active},
        {"cursor-not-allowed pointer-events-none", disabled && !active}
      ])

    disabled_classes = class_names([{"opacity-50", disabled}])

    # Size classes
    size_classes =
      case assigns.size do
        "sm" -> "px-2 py-1 text-sm"
        "lg" -> "px-4 py-3 text-lg"
        _ -> "px-3 py-2 text-base"
      end

    button_classes =
      class_names([
        "transition-colors font-medium rounded-lg",
        variant_classes,
        cursor_classes,
        disabled_classes,
        size_classes,
        Map.get(assigns, :class, "")
      ])

    # Build aria attributes
    aria_attrs =
      %{
        "aria-current": active && "page",
        "aria-disabled": (active || disabled) && "true"
      }
      |> Enum.reject(fn {_, v} -> !v end)
      |> Map.new()

    assigns = assign(assigns, :button_classes, button_classes)
    assigns = assign(assigns, :aria_attrs, aria_attrs)

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
