defmodule QwynkWeb.AdminLive.Users do
  @moduledoc """
  Superadmin console: who can do what.

  A superadmin cannot change their own role. That is enforced by
  `Qwynk.Accounts.Changes.ProtectOwnRole` on the action, not here — this view
  only declines to render the control.
  """
  use QwynkWeb, :live_view

  require Ash.Query

  on_mount {QwynkWeb.LiveUserAuth, :live_superadmin_required}

  @roles [
    {:superadmin, "Domains, roles, and every link."},
    {:admin, "Every link, and can read domains."},
    {:user, "Their own links only."}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:page_title, "Users") |> assign(:roles, @roles) |> load()}
  end

  @impl true
  def handle_event("set-role", %{"user_id" => id, "role" => role}, socket) do
    actor = socket.assigns.current_user

    user = Ash.get!(Qwynk.Accounts.User, id, actor: actor)

    result =
      user
      |> Ash.Changeset.for_update(:set_role, %{role: String.to_existing_atom(role)}, actor: actor)
      |> Ash.update()

    case result do
      {:ok, updated} ->
        {:noreply,
         socket |> put_flash(:info, "#{updated.email} is now #{updated.role}") |> load()}

      {:error, error} ->
        {:noreply, put_flash(socket, :error, message(error))}
    end
  end

  defp message(%Ash.Error.Invalid{errors: [%{message: msg} | _]}), do: msg
  defp message(%Ash.Error.Forbidden{}), do: "You are not allowed to do that."
  defp message(_), do: "That did not work."

  defp load(socket) do
    actor = socket.assigns.current_user
    users = Ash.read!(Qwynk.Accounts.User, actor: actor)

    counts =
      Map.new(users, fn user ->
        {user.id,
         Qwynk.Traffic.Link
         |> Ash.Query.filter(owner_id == ^user.id)
         |> Ash.count!(authorize?: false)}
      end)

    socket
    |> assign(:users, Enum.sort_by(users, &to_string(&1.email)))
    |> assign(:counts, counts)
    |> assign(:rail, QwynkWeb.Rail.build(actor))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active={:admin} rail={@rail} role={@current_user.role}>
      <h1 class="font-heading text-2xl">Users</h1>
      <p class="mt-1 text-sm text-secondary">
        The first account to register owns the install. Roles cannot be changed
        on your own account.
      </p>

      <dl class="mt-6 grid gap-2 border-y border-base-300 py-4 text-sm sm:grid-cols-3">
        <div :for={{role, blurb} <- @roles} class="flex flex-col gap-0.5">
          <dt class="font-mono text-xs text-primary">{role}</dt>
          <dd class="text-xs text-secondary">{blurb}</dd>
        </div>
      </dl>

      <div class="mt-6 border-y border-base-300">
        <ul class="divide-y divide-base-300">
          <li
            :for={user <- @users}
            class="flex flex-col gap-3 py-3.5 sm:flex-row sm:items-center sm:gap-4"
          >
            <div class="min-w-0 flex-1">
              <div class="flex flex-wrap items-center gap-2">
                <span class="break-all font-mono text-sm">{user.email}</span>
                <span
                  :if={user.id == @current_user.id}
                  class="border border-base-300 px-1.5 py-0.5 text-[0.625rem] uppercase text-secondary"
                >
                  you
                </span>
              </div>
              <p class="mt-1 font-mono text-xs text-secondary">
                {@counts[user.id]} links
              </p>
            </div>

            <div class="shrink-0">
              <span
                :if={user.id == @current_user.id}
                class="border border-base-300 px-2.5 py-1.5 font-mono text-xs text-secondary"
                title="You cannot change your own role"
              >
                {user.role}
              </span>

              <form :if={user.id != @current_user.id} phx-change="set-role">
                <input type="hidden" name="user_id" value={user.id} />
                <label for={"role-#{user.id}"} class="sr-only">Role for {user.email}</label>
                <select
                  id={"role-#{user.id}"}
                  name="role"
                  class="border border-base-300 bg-base-100 px-2.5 py-1.5 font-mono text-xs focus:border-primary focus:outline-none"
                >
                  <option :for={{role, _} <- @roles} value={role} selected={user.role == role}>
                    {role}
                  </option>
                </select>
              </form>
            </div>
          </li>
        </ul>
      </div>
    </Layouts.app>
    """
  end
end
