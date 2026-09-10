defmodule QwynkWeb.LinkLive.Show do
  @moduledoc "One link: its readout and a 30-day chart."
  use QwynkWeb, :live_view

  on_mount {QwynkWeb.LiveUserAuth, :live_user_required}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    # Ownership is the policy's job: a foreign link raises here.
    link = Qwynk.Traffic.get_link!(id, actor: socket.assigns.current_user, load: [:domain])
    rows = Qwynk.Analytics.stats(link.id, 30)

    {:ok,
     socket
     |> assign(:page_title, "/" <> link.slug)
     |> assign(:link, link)
     |> assign(:rows, rows)
     |> assign(:rail, QwynkWeb.Rail.build(socket.assigns.current_user))
     |> assign(:clicks, Enum.sum(Enum.map(rows, & &1.clicks)))
     |> assign(:uniques, Enum.sum(Enum.map(rows, & &1.uniques)))}
  end

  defp short_url(link), do: QwynkWeb.Rail.link_url(link)

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active={:links} rail={@rail} role={@current_user.role}>
      <.link
        navigate={~p"/_/app/links"}
        class="inline-flex items-center gap-1 text-sm text-secondary hover:text-primary"
      >
        <.icon name="hero-arrow-left" class="size-3.5" /> Links
      </.link>

      <div class="mt-4 flex flex-wrap items-start justify-between gap-4">
        <div class="min-w-0">
          <h1 class="font-mono text-2xl text-primary sm:text-3xl">
            <span class="text-secondary">{@link.domain.host}</span>/{@link.slug}
          </h1>
          <p class="mt-1.5 flex flex-wrap items-center gap-x-2 gap-y-1 break-all font-mono text-xs text-secondary">
            <.icon name="hero-arrow-long-right" class="size-3.5 shrink-0" />
            <a href={@link.destination} rel="noreferrer nofollow" class="hover:text-base-content">
              {@link.destination}
            </a>
          </p>
        </div>

        <button
          type="button"
          id={"copy-#{@link.id}"}
          phx-hook="Copy"
          data-copy={short_url(@link)}
          class="shrink-0 border border-base-300 px-3 py-1.5 text-sm text-secondary hover:border-primary hover:text-primary data-[copied]:border-primary data-[copied]:text-primary"
        >
          <span data-copy-label>copy link</span>
        </button>
      </div>

      <%!-- One hairline-divided readout row. No tiles nested in a panel. --%>
      <dl class="mt-8 grid grid-cols-2 gap-x-6 gap-y-5 border-y border-base-300 py-5 sm:grid-cols-4 sm:divide-x sm:divide-base-300">
        <div class="sm:pl-6 sm:first:pl-0">
          <dt class="text-xs text-secondary">Clicks · 30d</dt>
          <dd class="mt-1 font-heading text-3xl text-primary">{@clicks}</dd>
        </div>
        <div class="sm:pl-6">
          <dt class="text-xs text-secondary">Unique visitors</dt>
          <dd class="mt-1 font-heading text-3xl">{@uniques}</dd>
        </div>
        <div class="sm:pl-6">
          <dt class="text-xs text-secondary">Status</dt>
          <dd class={[
            "mt-1 flex items-center gap-2 text-sm",
            if(@link.is_active, do: "text-base-content", else: "text-secondary")
          ]}>
            <span class={[
              "inline-block size-1.5",
              if(@link.is_active, do: "bg-primary", else: "bg-base-300")
            ]}>
            </span>
            {if @link.is_active, do: "active", else: "disabled"}
          </dd>
        </div>
        <div class="sm:pl-6">
          <dt class="text-xs text-secondary">Redirect</dt>
          <dd class="mt-1 font-mono text-sm">
            {if @link.strategy == :permanent, do: "301 permanent", else: "302 temporary"}
          </dd>
        </div>
      </dl>

      <section class="mt-10">
        <h2 class="text-sm text-secondary">Traffic · last 30 days</h2>
        <.area_chart rows={@rows} class="mt-4" />
      </section>

      <p class="mt-10 font-mono text-[0.6875rem] text-secondary">
        created {Calendar.strftime(@link.inserted_at, "%Y-%m-%d %H:%M UTC")}
      </p>
    </Layouts.app>
    """
  end
end
