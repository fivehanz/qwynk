defmodule QwynkWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in LiveViews.
  """

  import Phoenix.Component
  use QwynkWeb, :verified_routes

  # This is used for nested liveviews to fetch the current user.
  # To use, place the following at the top of that liveview:
  # on_mount {QwynkWeb.LiveUserAuth, :current_user}
  def on_mount(:current_user, _params, session, socket) do
    {:cont, AshAuthentication.Phoenix.LiveSession.assign_new_resources(socket, session)}
  end

  def on_mount(:live_user_optional, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:live_user_required, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/_/sign-in")}
    end
  end

  def on_mount(:live_superadmin_required, _params, _session, socket) do
    case socket.assigns[:current_user] do
      %{role: :superadmin} ->
        {:cont, socket}

      %{} ->
        # A signed-in non-superadmin gets sent back to their own dashboard
        # rather than a forbidden page: the console is not theirs to know about.
        {:halt, Phoenix.LiveView.redirect(socket, to: "/_/app")}

      _ ->
        {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/_/sign-in")}
    end
  end

  def on_mount(:live_no_user, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/_/app")}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end
end
