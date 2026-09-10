defmodule QwynkWeb.AdminLive.Domains do
  @moduledoc """
  Superadmin console: the hostnames this server answers for.

  `root_url` being blank is the default and means the domain's root path 404s
  rather than advertising that an admin panel exists.
  """
  use QwynkWeb, :live_view

  require Ash.Query

  alias Qwynk.Traffic

  on_mount {QwynkWeb.LiveUserAuth, :live_superadmin_required}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Domains")
     |> assign(:form, nil)
     |> assign(:mode, nil)
     |> load()}
  end

  @impl true
  def handle_event("new", _params, socket) do
    form =
      Traffic.Domain
      |> AshPhoenix.Form.for_create(:create, actor: socket.assigns.current_user)
      |> to_form()

    {:noreply, assign(socket, form: form, mode: :create)}
  end

  def handle_event("edit", %{"id" => id}, socket) do
    domain = Traffic.get_domain!(id, actor: socket.assigns.current_user)

    form =
      domain
      |> AshPhoenix.Form.for_update(:update, actor: socket.assigns.current_user)
      |> to_form()

    {:noreply, assign(socket, form: form, mode: :edit)}
  end

  def handle_event("cancel", _params, socket),
    do: {:noreply, assign(socket, form: nil, mode: nil)}

  def handle_event("validate", %{"form" => params}, socket) do
    {:noreply, assign(socket, :form, AshPhoenix.Form.validate(socket.assigns.form, params))}
  end

  def handle_event("save", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, domain} ->
        {:noreply,
         socket
         |> put_flash(:info, "Saved #{domain.host}")
         |> assign(form: nil, mode: nil)
         |> load()}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end

  def handle_event("toggle-active", %{"id" => id}, socket) do
    user = socket.assigns.current_user
    domain = Traffic.get_domain!(id, actor: user)

    case Traffic.update_domain(domain, %{is_active: !domain.is_active}, actor: user) do
      {:ok, updated} ->
        state = if updated.is_active, do: "active", else: "inactive"
        {:noreply, socket |> put_flash(:info, "#{updated.host} is #{state}") |> load()}

      {:error, error} ->
        {:noreply, put_flash(socket, :error, message(error))}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    user = socket.assigns.current_user
    domain = Traffic.get_domain!(id, actor: user)

    case Traffic.destroy_domain(domain, actor: user) do
      :ok -> {:noreply, socket |> put_flash(:info, "Deleted #{domain.host}") |> load()}
      {:error, error} -> {:noreply, put_flash(socket, :error, message(error))}
    end
  end

  defp message(%Ash.Error.Invalid{errors: [%{message: msg} | _]}), do: msg
  defp message(_), do: "That did not work."

  defp load(socket) do
    user = socket.assigns.current_user
    domains = Traffic.list_domains!(actor: user)

    counts =
      Map.new(domains, fn domain ->
        {domain.id,
         Qwynk.Traffic.Link
         |> Ash.Query.filter(domain_id == ^domain.id)
         |> Ash.count!(authorize?: false)}
      end)

    socket
    |> assign(:domains, Enum.sort_by(domains, & &1.host))
    |> assign(:counts, counts)
    |> assign(:rail, QwynkWeb.Rail.build(user))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active={:admin} rail={@rail} role={@current_user.role}>
      <div class="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 class="font-heading text-2xl">Domains</h1>
          <p class="mt-1 text-sm text-secondary">
            Hostnames pointed at this server. Each keeps its own slug namespace.
          </p>
        </div>

        <button
          :if={is_nil(@form)}
          type="button"
          phx-click="new"
          class="border border-primary bg-primary px-3 py-1.5 text-sm font-medium text-primary-content hover:bg-primary/90"
        >
          Add domain
        </button>
      </div>

      <div :if={@form} class="mt-6 max-w-xl border border-primary/40 bg-base-200/40 p-5">
        <h2 class="font-heading text-sm">
          {if @mode == :create, do: "Add domain", else: "Edit domain"}
        </h2>

        <.form for={@form} phx-change="validate" phx-submit="save" class="mt-4 grid gap-4">
          <.input field={@form[:host]} label="Host" placeholder="links.acme.com" required />

          <div>
            <.input
              field={@form[:root_url]}
              label="Root URL"
              placeholder="Leave blank to return 404"
            />
            <p class="mt-1 text-xs text-secondary">
              Where the bare domain sends visitors. Blank is the default and returns
              404, so the domain gives nothing away.
            </p>
          </div>

          <div class="flex gap-2 pt-1">
            <button
              type="submit"
              phx-disable-with="Saving…"
              class="border border-primary bg-primary px-3 py-1.5 text-sm font-medium text-primary-content hover:bg-primary/90"
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

      <div :if={@domains != []} class="mt-6 border-y border-base-300">
        <ul class="divide-y divide-base-300">
          <li
            :for={domain <- @domains}
            class="flex flex-col gap-3 py-3.5 sm:flex-row sm:items-center sm:gap-4"
          >
            <div class="min-w-0 flex-1">
              <div class="flex flex-wrap items-center gap-2">
                <span class={[
                  "font-mono text-sm",
                  if(domain.is_active, do: "text-base-content", else: "text-secondary line-through")
                ]}>
                  {domain.host}
                </span>
                <span
                  :if={!domain.is_active}
                  class="border border-base-300 px-1.5 py-0.5 text-[0.625rem] uppercase text-secondary"
                >
                  inactive
                </span>
                <span class="font-mono text-[0.6875rem] text-secondary">
                  {@counts[domain.id]} links
                </span>
              </div>
              <p class="mt-1 break-all font-mono text-xs text-secondary">
                / → {if domain.root_url in [nil, ""], do: "404", else: domain.root_url}
              </p>
            </div>

            <div class="flex shrink-0 items-center gap-1 text-xs">
              <button
                type="button"
                phx-click="edit"
                phx-value-id={domain.id}
                class="border border-base-300 px-2 py-1 text-secondary hover:border-primary hover:text-primary"
              >
                edit
              </button>
              <button
                type="button"
                phx-click="toggle-active"
                phx-value-id={domain.id}
                data-confirm={
                  domain.is_active && "Deactivate #{domain.host}? Every link on it stops resolving."
                }
                class="border border-base-300 px-2 py-1 text-secondary hover:border-error hover:text-error"
              >
                {if domain.is_active, do: "deactivate", else: "activate"}
              </button>
              <button
                :if={@counts[domain.id] == 0}
                type="button"
                phx-click="delete"
                phx-value-id={domain.id}
                data-confirm={"Delete #{domain.host}?"}
                class="border border-base-300 px-2 py-1 text-secondary hover:border-error hover:text-error"
              >
                delete
              </button>
            </div>
          </li>
        </ul>
      </div>

      <div
        :if={@domains == []}
        class="mt-6 border border-dashed border-base-300 px-6 py-14 text-center"
      >
        <p class="font-heading text-lg">No domains yet</p>
        <p class="mx-auto mt-2 max-w-md text-sm leading-relaxed text-secondary">
          Point a hostname's DNS at this server, then add it here. Until a host is
          listed, every request to it returns 404 — including links.
        </p>
      </div>
    </Layouts.app>
    """
  end
end
