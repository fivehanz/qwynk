defmodule QwynkWeb.LinkLive.Index do
  @moduledoc """
  The link list — the primary surface of the admin.

  Ownership is enforced by the Ash policy on Link: this passes `actor` and never
  filters by owner_id itself, so the view cannot drift from the policy.
  """
  use QwynkWeb, :live_view

  alias Qwynk.Traffic
  alias Qwynk.Traffic.SlugGenerator

  on_mount {QwynkWeb.LiveUserAuth, :live_user_required}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Links")
     |> assign(:query, "")
     |> assign(:form, nil)
     |> assign(:mode, nil)
     |> assign(:domains, active_domains())
     |> load_links()}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, socket |> assign(:query, query) |> load_links()}
  end

  def handle_event("clear-search", _params, socket) do
    {:noreply, socket |> assign(:query, "") |> load_links()}
  end

  def handle_event("new", _params, socket) do
    # The form arrives carrying a slug: EnsureSlug runs whenever the changeset is
    # built, so this field cannot be kept empty while bound to it. Showing the
    # real value is the better trade anyway now that generate can re-roll it —
    # you see what you are about to get instead of a ghost placeholder.
    form =
      Traffic.Link
      |> AshPhoenix.Form.for_create(:create, actor: socket.assigns.current_user)
      |> to_form()

    {:noreply,
     socket
     |> assign(form: form, mode: :create, suggested: SlugGenerator.generate())
     |> assign(:prefix, default_prefix(socket.assigns.domains))}
  end

  def handle_event("edit", %{"id" => id}, socket) do
    link = Traffic.get_link!(id, actor: socket.assigns.current_user)

    form =
      link
      |> AshPhoenix.Form.for_update(:update, actor: socket.assigns.current_user)
      |> to_form()

    link = Ash.load!(link, :domain, authorize?: false)

    {:noreply,
     socket
     |> assign(form: form, mode: :edit, suggested: link.slug)
     |> assign(:prefix, link.domain.host)}
  end

  def handle_event("suggest", _params, socket) do
    form = socket.assigns.form
    params = Map.put(form.source.params || %{}, "slug", SlugGenerator.generate())

    {:noreply, assign(socket, :form, AshPhoenix.Form.validate(form, params))}
  end

  def handle_event("cancel", _params, socket),
    do: {:noreply, assign(socket, form: nil, mode: nil)}

  def handle_event("validate", %{"form" => params}, socket) do
    {:noreply,
     socket
     |> assign(:form, AshPhoenix.Form.validate(socket.assigns.form, params))
     |> assign(:prefix, prefix_for(params["domain_id"], socket.assigns))}
  end

  def handle_event("save", %{"form" => params}, socket) do
    case save(socket.assigns.mode, socket.assigns.form, params, socket.assigns.current_user) do
      {:ok, link} ->
        {:noreply,
         socket
         |> put_flash(:info, "Saved /#{link.slug}")
         |> assign(form: nil, mode: nil)
         |> load_links()}

      {:error, %AshPhoenix.Form{} = form} ->
        {:noreply, assign(socket, :form, form)}

      {:error, error} ->
        {:noreply, put_flash(socket, :error, message(error))}
    end
  end

  def handle_event("toggle-active", %{"id" => id, "active" => active}, socket) do
    user = socket.assigns.current_user
    link = Traffic.get_link!(id, actor: user)

    result =
      if active == "true",
        do: Traffic.disable_link(link, actor: user),
        else: Traffic.update_link(link, %{is_active: true}, actor: user)

    case result do
      {:ok, updated} ->
        verb = if updated.is_active, do: "enabled", else: "disabled"

        {:noreply, socket |> put_flash(:info, "/#{updated.slug} #{verb}") |> load_links()}

      {:error, error} ->
        {:noreply, put_flash(socket, :error, message(error))}
    end
  end

  # Creates route through Traffic.create_link/2 so they inherit the bounded slug
  # retry; AshPhoenix.Form.submit would call the action directly and lose it.
  defp save(:create, _form, params, user) do
    %{
      destination: params["destination"],
      strategy: strategy(params["strategy"]),
      domain_id: params["domain_id"]
    }
    |> maybe_put_slug(params["slug"])
    |> Traffic.create_link(actor: user)
  end

  defp save(:edit, form, params, _user), do: AshPhoenix.Form.submit(form, params: params)

  defp maybe_put_slug(attrs, slug) when is_binary(slug) and slug != "",
    do: Map.put(attrs, :slug, String.trim(slug))

  defp maybe_put_slug(attrs, _slug), do: attrs

  defp default_prefix([]), do: "—"
  defp default_prefix([domain | _]), do: domain.host

  # The prefix has to follow the domain select, or it shows the wrong host for
  # the link being created.
  defp prefix_for(nil, assigns), do: assigns.prefix

  defp prefix_for(domain_id, assigns) do
    case Enum.find(assigns.domains, &(&1.id == domain_id)) do
      nil -> assigns.prefix
      domain -> domain.host
    end
  end

  defp strategy("permanent"), do: :permanent
  defp strategy(_), do: :temporary

  defp message(%Ash.Error.Invalid{errors: [%{message: msg, field: field} | _]}),
    do: "#{field} #{msg}"

  defp message(_), do: "Could not save that link."

  defp active_domains do
    Qwynk.Traffic.list_domains!(authorize?: false)
    |> Enum.filter(& &1.is_active)
    |> Enum.sort_by(& &1.host)
  end

  defp load_links(socket) do
    all = Traffic.list_links!(actor: socket.assigns.current_user, load: [:domain])

    socket
    |> assign(:total_count, length(all))
    |> assign(:rail, QwynkWeb.Rail.build(socket.assigns.current_user))
    |> assign(
      :links,
      all |> filter(socket.assigns.query) |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
    )
  end

  defp filter(links, ""), do: links

  defp filter(links, query) do
    q = String.downcase(String.trim(query))

    Enum.filter(links, fn link ->
      String.contains?(String.downcase(link.slug), q) or
        String.contains?(String.downcase(link.destination), q)
    end)
  end

  # The link's own domain, not the endpoint's: a link on acme.com must copy as
  # acme.com even when the console is being used from somewhere else.
  defp short_url(link), do: QwynkWeb.Rail.link_url(link)

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active={:links} rail={@rail} role={@current_user.role}>
      <div class="flex flex-wrap items-center justify-between gap-4">
        <h1 class="font-heading text-2xl">Links</h1>

        <button
          :if={is_nil(@form) and @domains != []}
          type="button"
          phx-click="new"
          class="border border-primary bg-primary px-3 py-1.5 text-sm font-medium text-primary-content hover:bg-primary/90"
        >
          New link
        </button>
      </div>

      <div
        :if={@domains == []}
        class="mt-6 border border-warning/40 bg-base-200/40 p-4 text-sm text-secondary"
      >
        No active domains, so there is nowhere to put a link yet.
        <.link :if={@current_user.role == :superadmin} navigate={~p"/_/admin"} class="text-primary">
          Add one in the console.
        </.link>
        <span :if={@current_user.role != :superadmin}>Ask an administrator to add one.</span>
      </div>

      <.link_form
        :if={@form}
        form={@form}
        mode={@mode}
        suggested={@suggested}
        prefix={@prefix}
        domains={@domains}
      />

      <form :if={@total_count > 0} phx-change="search" phx-submit="search" class="mt-6">
        <label for="query" class="sr-only">Search links</label>
        <div class="relative max-w-md">
          <.icon
            name="hero-magnifying-glass"
            class="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-secondary"
          />
          <input
            type="text"
            id="query"
            name="query"
            value={@query}
            autocomplete="off"
            placeholder="Filter by slug or destination"
            phx-debounce="200"
            class="w-full border border-base-300 bg-base-200/40 py-2 pl-9 pr-3 text-sm placeholder:text-secondary focus:border-primary focus:outline-none"
          />
        </div>
      </form>

      <div :if={@links != []} class="mt-6 border-y border-base-300">
        <ul class="divide-y divide-base-300">
          <li
            :for={link <- @links}
            id={"link-#{link.id}"}
            class="group flex flex-col gap-3 py-3.5 sm:flex-row sm:items-center sm:gap-4"
          >
            <div class="min-w-0 flex-1">
              <div class="flex items-center gap-2">
                <.link
                  navigate={~p"/_/app/links/#{link.id}"}
                  class={[
                    "font-mono text-sm",
                    if(link.is_active, do: "text-primary", else: "text-secondary line-through")
                  ]}
                >
                  <span :if={length(@domains) > 1} class="text-secondary">{link.domain.host}</span>/{link.slug}
                </.link>
                <span
                  :if={!link.is_active}
                  class="border border-base-300 px-1.5 py-0.5 text-[0.625rem] uppercase text-secondary"
                >
                  disabled
                </span>
                <span
                  :if={link.strategy == :permanent}
                  class="border border-base-300 px-1.5 py-0.5 font-mono text-[0.625rem] text-secondary"
                  title="Permanent redirect — browsers cache this"
                >
                  301
                </span>
              </div>
              <p
                class="mt-0.5 break-all font-mono text-[0.6875rem] text-secondary"
                title={link.destination}
              >
                {link.destination}
              </p>
            </div>

            <div class="flex shrink-0 items-center gap-1 text-xs">
              <button
                type="button"
                id={"copy-#{link.id}"}
                phx-hook="Copy"
                data-copy={short_url(link)}
                class="border border-base-300 px-2 py-1 text-secondary hover:border-primary hover:text-primary data-[copied]:border-primary data-[copied]:text-primary"
              >
                <span data-copy-label>copy</span>
              </button>
              <button
                type="button"
                phx-click="edit"
                phx-value-id={link.id}
                class="border border-base-300 px-2 py-1 text-secondary hover:border-primary hover:text-primary"
              >
                edit
              </button>
              <button
                type="button"
                phx-click="toggle-active"
                phx-value-id={link.id}
                phx-value-active={to_string(link.is_active)}
                data-confirm={link.is_active && "Disable /#{link.slug}? Visitors will get a 404."}
                class="border border-base-300 px-2 py-1 text-secondary hover:border-error hover:text-error"
              >
                {if link.is_active, do: "disable", else: "enable"}
              </button>
            </div>
          </li>
        </ul>
      </div>

      <%!-- No links at all: teach what one is. --%>
      <div
        :if={@links == [] and @total_count == 0}
        class="mt-6 border border-dashed border-base-300 px-6 py-14 text-center"
      >
        <p class="font-heading text-lg">No links yet</p>
        <p class="mx-auto mt-2 max-w-md text-sm leading-relaxed text-secondary">
          A link maps a short slug on your domain to any destination URL. Leave the
          slug blank and Qwynk generates a memorable one like <span class="font-mono text-base-content">zip-zap</span>.
        </p>
        <button
          :if={is_nil(@form) and @domains != []}
          type="button"
          phx-click="new"
          class="mt-6 border border-primary bg-primary px-3 py-1.5 text-sm font-medium text-primary-content hover:bg-primary/90"
        >
          Create your first link
        </button>
      </div>

      <%!-- Search matched nothing: a different state, a different exit. --%>
      <div
        :if={@links == [] and @total_count > 0}
        class="mt-6 border border-dashed border-base-300 px-6 py-14 text-center"
      >
        <p class="text-sm text-secondary">
          Nothing matches <span class="font-mono text-base-content">{@query}</span>
          across your {@total_count} links.
        </p>
        <button
          type="button"
          phx-click="clear-search"
          class="mt-4 border border-base-300 px-3 py-1.5 text-sm text-secondary hover:border-primary hover:text-primary"
        >
          Clear filter
        </button>
      </div>
    </Layouts.app>
    """
  end

  attr :form, :any, required: true
  attr :mode, :atom, required: true
  attr :suggested, :string, required: true
  attr :prefix, :string, required: true
  attr :domains, :list, required: true

  defp link_form(assigns) do
    ~H"""
    <div class="mt-6 max-w-xl border border-primary/40 bg-base-200/40 p-5">
      <h2 class="font-heading text-sm">
        {if @mode == :create, do: "New link", else: "Edit link"}
      </h2>

      <.form for={@form} phx-change="validate" phx-submit="save" class="mt-4 grid gap-4">
        <.input
          field={@form[:destination]}
          type="url"
          label="Destination"
          placeholder="https://example.com/somewhere"
          required
        />

        <div :if={@mode == :create}>
          <label for="domain_id" class="mb-1 block text-sm">Domain</label>
          <select
            id="domain_id"
            name="form[domain_id]"
            class="w-full border border-base-300 bg-base-100 px-2.5 py-2 text-sm focus:border-primary focus:outline-none"
          >
            <option :for={domain <- @domains} value={domain.id}>{domain.host}</option>
          </select>
        </div>

        <div>
          <label for={@form[:slug].id} class="mb-1 block text-sm">Short link</label>
          <div class="flex items-stretch border border-base-300 bg-base-100 focus-within:border-primary">
            <span class="flex select-none items-center border-r border-base-300 px-2.5 font-mono text-[0.6875rem] text-secondary">
              {@prefix}/
            </span>
            <input
              type="text"
              id={@form[:slug].id}
              name={@form[:slug].name}
              value={@form[:slug].value}
              disabled={@mode == :edit}
              placeholder={@suggested}
              autocomplete="off"
              class="w-full bg-transparent px-2.5 py-2 font-mono text-sm placeholder:text-secondary focus:outline-none disabled:text-secondary"
            />
            <button
              :if={@mode == :create}
              type="button"
              phx-click="suggest"
              title="Suggest another slug"
              class="flex shrink-0 items-center gap-1.5 border-l border-base-300 px-2.5 text-xs text-secondary hover:text-primary"
            >
              <.icon name="hero-arrow-path" class="size-3.5" /> generate
            </button>
          </div>
          <p class="mt-1 text-xs text-secondary">
            {if @mode == :edit,
              do: "Slugs can't change — visitors may already have this one.",
              else: "Type your own, or generate another. Clearing it also generates one."}
          </p>
        </div>

        <div>
          <.input
            field={@form[:strategy]}
            type="select"
            label="Redirect type"
            options={[{"Temporary — 302", "temporary"}, {"Permanent — 301", "permanent"}]}
          />
          <p class="mt-1 text-xs text-secondary">
            Browsers cache a permanent redirect, so changing the destination later
            may not reach visitors who already followed it.
          </p>
        </div>

        <div class="flex gap-2 pt-1">
          <button
            type="submit"
            phx-disable-with="Saving…"
            class="border border-primary bg-primary px-3 py-1.5 text-sm font-medium text-primary-content hover:bg-primary/90 disabled:opacity-50"
          >
            Save
          </button>
          <button
            type="button"
            phx-click="cancel"
            class="border border-base-300 px-3 py-1.5 text-sm text-secondary hover:text-base-content"
          >
            Cancel
          </button>
        </div>
      </.form>
    </div>
    """
  end
end
