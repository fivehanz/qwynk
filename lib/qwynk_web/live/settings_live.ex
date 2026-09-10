defmodule QwynkWeb.SettingsLive do
  @moduledoc "Account settings. Deliberately thin — no controls that do nothing."
  use QwynkWeb, :live_view

  on_mount {QwynkWeb.LiveUserAuth, :live_user_required}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Settings")
     |> assign(:rail, QwynkWeb.Rail.build(socket.assigns.current_user))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active={:settings} rail={@rail}>
      <h1 class="font-heading text-2xl">Settings</h1>

      <dl class="mt-8 max-w-xl divide-y divide-base-300 border-y border-base-300">
        <div class="flex items-baseline justify-between gap-4 py-3">
          <dt class="text-sm text-secondary">Email</dt>
          <dd class="font-mono text-data">{@current_user.email}</dd>
        </div>
        <div class="flex items-baseline justify-between gap-4 py-3">
          <dt class="text-sm text-secondary">Account ID</dt>
          <dd class="font-mono text-data text-secondary">{@current_user.id}</dd>
        </div>
      </dl>

      <div class="mt-8">
        <a
          href={~p"/_/sign-out"}
          class="inline-flex items-center border border-base-300 px-3 py-2 text-sm text-secondary hover:border-error hover:text-error"
        >
          Sign out
        </a>
      </div>

      <p class="mt-10 max-w-xl text-sm leading-relaxed text-secondary">
        Qwynk stores no raw IP addresses and drops no cookies on redirects.
        Visitor counts come from a daily-rotating hash that is discarded after
        two days, so returning visitors cannot be tracked across weeks.
      </p>
    </Layouts.app>
    """
  end
end
