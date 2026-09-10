defmodule QwynkWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use QwynkWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  attr :active, :atom,
    default: nil,
    doc: "which nav section is current: :dashboard, :links or :settings"

  attr :rail, :map,
    default: nil,
    doc: "system readout for the status rail: %{links:, clicks:, cache:}"

  attr :role, :atom, default: nil, doc: "current user's role; gates the console link"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="sticky top-0 z-30 border-b border-base-300 bg-base-100/95 backdrop-blur-sm">
      <%!-- Wraps on small screens: at 360px the wordmark and four nav items
           already consume the full row, so nothing fits beside them. Sign out
           stays on the first line and the nav drops below rather than any
           control being hidden. --%>
      <div class="mx-auto flex max-w-6xl flex-wrap items-center gap-x-3 gap-y-1 px-4 py-2.5 sm:flex-nowrap sm:gap-x-6 sm:px-6 sm:py-3">
        <.link
          navigate={~p"/_/app"}
          class="flex shrink-0 items-baseline gap-1.5"
          aria-label="Qwynk home"
        >
          <span class="font-heading text-base leading-none">Qwynk</span>
          <span aria-hidden="true" class="font-heading text-xs leading-none text-primary">///</span>
        </.link>

        <nav
          class="order-last flex w-full items-center gap-1 overflow-x-auto text-sm sm:order-none sm:w-auto sm:flex-1 sm:overflow-visible"
          aria-label="Sections"
        >
          <.nav_link navigate={~p"/_/app"} active={@active == :dashboard}>Dashboard</.nav_link>
          <.nav_link navigate={~p"/_/app/links"} active={@active == :links}>Links</.nav_link>
          <.nav_link navigate={~p"/_/app/settings"} active={@active == :settings}>
            Settings
          </.nav_link>
          <.nav_link :if={@role == :superadmin} navigate={~p"/_/admin"} active={@active == :admin}>
            Console
          </.nav_link>
        </nav>

        <a
          href={~p"/_/sign-out"}
          class="ml-auto shrink-0 px-1 py-2 text-sm text-secondary hover:text-error sm:ml-0 sm:px-0 sm:py-1"
        >
          Sign out
        </a>
      </div>

      <div :if={@rail} class="hidden border-t border-base-300/60 bg-base-200/40 sm:block">
        <div class="mx-auto flex max-w-6xl flex-wrap items-center gap-x-5 gap-y-1 px-4 py-1.5 font-mono text-[0.6875rem] text-secondary sm:px-6">
          <span><span class="text-base-content tabular">{@rail.links}</span> links</span>
          <span aria-hidden="true" class="text-base-300">/</span>
          <span><span class="text-base-content tabular">{@rail.clicks}</span> clicks 30d</span>
          <span aria-hidden="true" class="text-base-300">/</span>
          <span><span class="text-base-content tabular">{@rail.uniques}</span> uniques 30d</span>
          <span aria-hidden="true" class="text-base-300">/</span>
          <span class="flex items-center gap-1.5">
            cache
            <span class={[
              "inline-block size-1.5",
              if(@rail.cache == :warm, do: "bg-primary", else: "bg-base-300")
            ]}>
            </span>
            <span class="text-base-content">{@rail.cache}</span>
          </span>
        </div>
      </div>
    </header>

    <main class="mx-auto max-w-6xl px-4 py-8 sm:px-6 sm:py-10">
      {render_slot(@inner_block)}
    </main>

    <.flash_group flash={@flash} />
    """
  end

  attr :navigate, :string, required: true
  attr :active, :boolean, default: false
  slot :inner_block, required: true

  defp nav_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      aria-current={@active && "page"}
      class={[
        "relative shrink-0 whitespace-nowrap px-2 py-2 after:absolute after:inset-x-2 after:bottom-0 after:h-px sm:py-1.5",
        if(@active,
          do: "text-base-content after:bg-primary",
          else: "text-secondary hover:text-base-content after:bg-transparent"
        )
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end
end
