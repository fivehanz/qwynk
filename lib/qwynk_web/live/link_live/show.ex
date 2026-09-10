defmodule QwynkWeb.LinkLive.Show do
  @moduledoc "One link: its details and a 30-day chart."
  use QwynkWeb, :live_view

  on_mount {QwynkWeb.LiveUserAuth, :live_user_required}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    # Ownership is the policy's job: a foreign link raises here.
    link = Qwynk.Traffic.get_link!(id, actor: socket.assigns.current_user)
    rows = Qwynk.Analytics.stats(link.id, 30)

    {:ok,
     socket
     |> assign(:page_title, "/" <> link.slug)
     |> assign(:link, link)
     |> assign(:rows, rows)
     |> assign(:clicks, Enum.sum(Enum.map(rows, & &1.clicks)))
     |> assign(:uniques, Enum.sum(Enum.map(rows, & &1.uniques)))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={assigns[:current_scope]}>
      <div class="mx-auto max-w-5xl px-4 py-10">
        <.link navigate={~p"/_/app/links"} class="font-mono text-xs opacity-60 hover:text-primary">
          ← Links
        </.link>

        <h1 class="mt-3 font-mono text-3xl font-bold text-primary">/{@link.slug}</h1>
        <p class="mt-1 truncate font-mono text-sm opacity-60">→ {@link.destination}</p>

        <dl class="mt-8 grid grid-cols-2 gap-4 sm:grid-cols-4">
          <div class="border border-base-300 bg-base-200/40 p-4">
            <dt class="font-mono text-xs uppercase tracking-widest opacity-60">Status</dt>
            <dd class={["mt-1 font-mono", if(@link.is_active, do: "text-success", else: "opacity-50")]}>
              {if @link.is_active, do: "active", else: "disabled"}
            </dd>
          </div>
          <div class="border border-base-300 bg-base-200/40 p-4">
            <dt class="font-mono text-xs uppercase tracking-widest opacity-60">Strategy</dt>
            <dd class="mt-1 font-mono">
              {if @link.strategy == :permanent, do: "301", else: "302"}
            </dd>
          </div>
          <div class="border border-base-300 bg-base-200/40 p-4">
            <dt class="font-mono text-xs uppercase tracking-widest opacity-60">Clicks / 30d</dt>
            <dd class="mt-1 font-mono text-primary">{@clicks}</dd>
          </div>
          <div class="border border-base-300 bg-base-200/40 p-4">
            <dt class="font-mono text-xs uppercase tracking-widest opacity-60">Uniques / 30d</dt>
            <dd class="mt-1 font-mono text-secondary">{@uniques}</dd>
          </div>
        </dl>

        <div class="mt-8 border border-base-300 bg-base-200/40 p-5">
          <.area_chart rows={@rows} />
        </div>

        <p class="mt-6 font-mono text-xs opacity-40">
          Created {Calendar.strftime(@link.inserted_at, "%Y-%m-%d %H:%M UTC")}
        </p>
      </div>
    </Layouts.app>
    """
  end
end
