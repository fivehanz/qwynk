defmodule QwynkWeb.DashboardLive do
  @moduledoc "Owner dashboard: totals and recent links."
  use QwynkWeb, :live_view

  on_mount {QwynkWeb.LiveUserAuth, :live_user_required}

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    links = Qwynk.Traffic.list_links!(actor: user)

    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign(:totals, Qwynk.Analytics.totals(user.id))
     |> assign(
       :recent,
       links |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime}) |> Enum.take(5)
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={assigns[:current_scope]}>
      <div class="mx-auto max-w-5xl px-4 py-10">
        <h1 class="mb-8 font-mono text-xs uppercase tracking-widest text-primary">Dashboard</h1>

        <div class="mb-10 grid grid-cols-1 gap-4 sm:grid-cols-3">
          <div class="border border-base-300 bg-base-200/40 p-5">
            <p class="font-mono text-xs uppercase tracking-widest opacity-60">Links</p>
            <p class="mt-1 text-4xl font-bold">{@totals.links}</p>
          </div>
          <div class="border border-base-300 bg-base-200/40 p-5">
            <p class="font-mono text-xs uppercase tracking-widest opacity-60">Clicks / 30d</p>
            <p class="mt-1 text-4xl font-bold text-primary">{@totals.clicks}</p>
          </div>
          <div class="border border-base-300 bg-base-200/40 p-5">
            <p class="font-mono text-xs uppercase tracking-widest opacity-60">Uniques / 30d</p>
            <p class="mt-1 text-4xl font-bold text-secondary">{@totals.uniques}</p>
          </div>
        </div>

        <div class="flex items-center justify-between">
          <h2 class="font-mono text-xs uppercase tracking-widest opacity-60">Recent links</h2>
          <.link navigate={~p"/_/app/links"} class="font-mono text-xs text-primary hover:underline">
            All links →
          </.link>
        </div>

        <ul class="mt-3 divide-y divide-base-300 border border-base-300">
          <li :for={link <- @recent} class="flex items-center justify-between gap-4 px-4 py-3">
            <.link navigate={~p"/_/app/links/#{link.id}"} class="font-mono text-sm text-primary">
              /{link.slug}
            </.link>
            <span class="truncate font-mono text-xs opacity-60">{link.destination}</span>
          </li>
          <li :if={@recent == []} class="px-4 py-8 text-center font-mono text-sm opacity-60">
            No links yet.
          </li>
        </ul>
      </div>
    </Layouts.app>
    """
  end
end
