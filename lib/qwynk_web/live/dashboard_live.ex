defmodule QwynkWeb.DashboardLive do
  @moduledoc "Owner dashboard: one instrument strip and the most recent links."
  use QwynkWeb, :live_view

  on_mount {QwynkWeb.LiveUserAuth, :live_user_required}

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    links = Qwynk.Traffic.list_links!(actor: user)
    rows = aggregate(links)

    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign(:rail, QwynkWeb.Rail.build(user))
     |> assign(:totals, Qwynk.Analytics.totals(user.id))
     |> assign(:rows, rows)
     |> assign(
       :recent,
       links |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime}) |> Enum.take(5)
     )}
  end

  # Sum the per-link series into one account-wide series for the sparkline.
  defp aggregate([]), do: Qwynk.Analytics.stats(Ecto.UUID.generate(), 30)

  defp aggregate(links) do
    links
    |> Enum.map(&Qwynk.Analytics.stats(&1.id, 30))
    |> Enum.zip_with(fn day_slices ->
      %{
        date: hd(day_slices).date,
        clicks: Enum.sum(Enum.map(day_slices, & &1.clicks)),
        uniques: Enum.sum(Enum.map(day_slices, & &1.uniques))
      }
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active={:dashboard} rail={@rail} role={@current_user.role}>
      <h1 class="font-heading text-2xl">Dashboard</h1>

      <%!-- The instrument strip: one aligned readout, not a grid of cards. --%>
      <div class="mt-6 flex flex-wrap items-end gap-x-10 gap-y-6 border-y border-base-300 py-6">
        <div>
          <p class="text-xs text-secondary">Links</p>
          <p class="mt-1 font-heading text-4xl">{@totals.links}</p>
        </div>
        <div>
          <p class="text-xs text-secondary">Clicks · 30d</p>
          <p class="mt-1 font-heading text-4xl text-primary">{@totals.clicks}</p>
        </div>
        <div>
          <p class="text-xs text-secondary">Unique visitors</p>
          <p class="mt-1 font-heading text-4xl">{@totals.uniques}</p>
        </div>
        <div class="ml-auto hidden sm:block">
          <p class="text-right text-xs text-secondary">30-day trend</p>
          <.sparkline rows={@rows} class="mt-1 w-40" />
        </div>
      </div>

      <div class="mt-10 flex items-center justify-between gap-4">
        <h2 class="text-sm text-secondary">Recent links</h2>
        <.link navigate={~p"/_/app/links"} class="text-sm text-primary hover:underline">
          All links
        </.link>
      </div>

      <div :if={@recent != []} class="mt-3 border-y border-base-300">
        <ul class="divide-y divide-base-300">
          <li :for={link <- @recent} class="flex items-center gap-4 py-3">
            <.link
              navigate={~p"/_/app/links/#{link.id}"}
              class={[
                "shrink-0 font-mono text-sm",
                if(link.is_active, do: "text-primary", else: "text-secondary line-through")
              ]}
            >
              /{link.slug}
            </.link>
            <p
              class="min-w-0 flex-1 truncate font-mono text-xs text-secondary"
              title={link.destination}
            >
              {link.destination}
            </p>
          </li>
        </ul>
      </div>

      <div
        :if={@recent == []}
        class="mt-3 border border-dashed border-base-300 px-6 py-12 text-center"
      >
        <p class="text-sm text-secondary">Nothing to route yet.</p>
        <.link
          navigate={~p"/_/app/links"}
          class="mt-4 inline-block border border-primary bg-primary px-3 py-1.5 text-sm font-medium text-primary-content hover:bg-primary/90"
        >
          Create your first link
        </.link>
      </div>
    </Layouts.app>
    """
  end
end
