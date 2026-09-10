defmodule QwynkWeb.LinkLive.Index do
  @moduledoc """
  Link list, create and edit.

  Ownership is enforced by the Ash policy on Link — this passes `actor` and
  never filters by owner_id itself, so the LiveView cannot drift from the policy.
  """
  use QwynkWeb, :live_view

  alias Qwynk.Traffic

  on_mount {QwynkWeb.LiveUserAuth, :live_user_required}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Links")
     |> assign(:query, "")
     |> assign(:form, nil)
     |> load_links()}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, socket |> assign(:query, query) |> load_links()}
  end

  def handle_event("new", _params, socket) do
    form =
      Traffic.Link
      |> AshPhoenix.Form.for_create(:create, actor: socket.assigns.current_user)
      |> to_form()

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("edit", %{"id" => id}, socket) do
    link = Traffic.get_link!(id, actor: socket.assigns.current_user)

    form =
      link
      |> AshPhoenix.Form.for_update(:update, actor: socket.assigns.current_user)
      |> to_form()

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("cancel", _params, socket), do: {:noreply, assign(socket, :form, nil)}

  def handle_event("validate", %{"form" => params}, socket) do
    {:noreply, assign(socket, :form, AshPhoenix.Form.validate(socket.assigns.form, params))}
  end

  def handle_event("save", %{"form" => params}, socket) do
    case save(socket.assigns.form, params, socket.assigns.current_user) do
      {:ok, _link} ->
        {:noreply,
         socket
         |> put_flash(:info, "Link saved.")
         |> assign(:form, nil)
         |> load_links()}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end

  def handle_event("disable", %{"id" => id}, socket) do
    user = socket.assigns.current_user
    link = Traffic.get_link!(id, actor: user)
    {:ok, _} = Traffic.disable_link(link, actor: user)

    {:noreply, socket |> put_flash(:info, "Link disabled.") |> load_links()}
  end

  # Creates go through Traffic.create_link/2 so they inherit the bounded slug
  # retry; AshPhoenix.Form.submit would call the action directly and lose it.
  defp save(%{source: %{type: :create}}, params, user) do
    attrs =
      %{destination: params["destination"], strategy: strategy(params["strategy"])}
      |> maybe_put_slug(params["slug"])

    Traffic.create_link(attrs, actor: user)
  end

  defp save(form, params, _user), do: AshPhoenix.Form.submit(form, params: params)

  defp maybe_put_slug(attrs, slug) when is_binary(slug) and slug != "",
    do: Map.put(attrs, :slug, slug)

  defp maybe_put_slug(attrs, _slug), do: attrs

  defp strategy("permanent"), do: :permanent
  defp strategy(_), do: :temporary

  defp load_links(socket) do
    links =
      socket.assigns.current_user
      |> then(&Traffic.list_links!(actor: &1))
      |> filter(socket.assigns.query)
      |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})

    assign(socket, :links, links)
  end

  defp filter(links, ""), do: links

  defp filter(links, query) do
    q = String.downcase(query)

    Enum.filter(links, fn link ->
      String.contains?(String.downcase(link.slug), q) or
        String.contains?(String.downcase(link.destination), q)
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={assigns[:current_scope]}>
      <div class="mx-auto max-w-5xl px-4 py-10">
        <div class="mb-6 flex items-center justify-between gap-4">
          <h1 class="font-mono text-xs uppercase tracking-widest text-primary">Links</h1>
          <button phx-click="new" class="btn btn-primary btn-sm rounded-none font-mono">
            New link
          </button>
        </div>

        <form phx-change="search" class="mb-6">
          <input
            type="search"
            name="query"
            value={@query}
            placeholder="Search slug or destination"
            class="input input-bordered w-full rounded-none font-mono text-sm"
          />
        </form>

        <div :if={@form} class="mb-6 border border-primary/40 bg-base-200/40 p-5">
          <.form for={@form} phx-change="validate" phx-submit="save" class="grid gap-3">
            <.input field={@form[:destination]} label="Destination" placeholder="https://example.com" />
            <.input field={@form[:slug]} label="Slug (optional — generated if blank)" />
            <.input
              field={@form[:strategy]}
              type="select"
              label="Strategy"
              options={[{"Temporary (302)", "temporary"}, {"Permanent (301)", "permanent"}]}
            />
            <div class="flex gap-2">
              <button type="submit" class="btn btn-primary btn-sm rounded-none font-mono">
                Save
              </button>
              <button
                type="button"
                phx-click="cancel"
                class="btn btn-ghost btn-sm rounded-none font-mono"
              >
                Cancel
              </button>
            </div>
          </.form>
        </div>

        <div class="overflow-x-auto border border-base-300">
          <table class="w-full text-left font-mono text-sm">
            <thead class="border-b border-base-300 text-xs uppercase tracking-widest opacity-60">
              <tr>
                <th class="px-4 py-3">Slug</th>
                <th class="px-4 py-3">Destination</th>
                <th class="px-4 py-3">Status</th>
                <th class="px-4 py-3 text-right">Actions</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-base-300">
              <tr :for={link <- @links} id={"link-#{link.id}"}>
                <td class="px-4 py-3">
                  <.link navigate={~p"/_/app/links/#{link.id}"} class="text-primary">
                    /{link.slug}
                  </.link>
                </td>
                <td class="max-w-xs truncate px-4 py-3 opacity-70">{link.destination}</td>
                <td class="px-4 py-3">
                  <span class={if link.is_active, do: "text-success", else: "opacity-50"}>
                    {if link.is_active, do: "active", else: "disabled"}
                  </span>
                </td>
                <td class="space-x-2 px-4 py-3 text-right text-xs">
                  <button phx-click="edit" phx-value-id={link.id} class="hover:text-primary">
                    edit
                  </button>
                  <button
                    :if={link.is_active}
                    phx-click="disable"
                    phx-value-id={link.id}
                    data-confirm="Disable this link?"
                    class="hover:text-error"
                  >
                    disable
                  </button>
                </td>
              </tr>
              <tr :if={@links == []}>
                <td colspan="4" class="px-4 py-10 text-center opacity-60">No links.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
