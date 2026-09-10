defmodule QwynkWeb.Router do
  use QwynkWeb, :router

  use AshAuthentication.Phoenix.Router

  import AshAuthentication.Plug.Helpers

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {QwynkWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]

    plug AshAuthentication.Strategy.ApiKey.Plug,
      resource: Qwynk.Accounts.User,
      # if you want to require an api key to be supplied, set `required?` to true
      required?: false

    plug :load_from_bearer
    plug :set_actor, :user
  end

  # The redirect path drops no cookies and touches no session (PRD 5.1).
  pipeline :redirect_path do
    plug :accepts, ["html"]
    plug :put_secure_browser_headers
  end

  scope "/", QwynkWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # `/_/` is reserved for system internals so that `/:slug` can own everything
  # else (PRD 3.1). These live in the root scope with explicit `/_/` paths:
  # AshAuthentication resolves `register_path`/`reset_path` through
  # `Phoenix.Router.scoped_path/2` AND defines the route inside the enclosing
  # scope, so nesting them in `scope "/_"` prefixes them twice (/_/_/register).
  scope "/", QwynkWeb do
    pipe_through :browser

    ash_authentication_live_session :authenticated_routes do
      # in each liveview, add one of the following at the top of the module:
      #
      # If an authenticated user must be present:
      # on_mount {QwynkWeb.LiveUserAuth, :live_user_required}
      #
      # If an authenticated user *may* be present:
      # on_mount {QwynkWeb.LiveUserAuth, :live_user_optional}
      #
      # If an authenticated user must *not* be present:
      # on_mount {QwynkWeb.LiveUserAuth, :live_no_user}
    end

    auth_routes AuthController, Qwynk.Accounts.User, path: "/_/auth"
    sign_out_route AuthController, "/_/sign-out"

    sign_in_route path: "/_/sign-in",
                  register_path: "/_/register",
                  reset_path: "/_/reset",
                  auth_routes_prefix: "/_/auth",
                  on_mount: [{QwynkWeb.LiveUserAuth, :live_no_user}],
                  overrides: [
                    QwynkWeb.AuthOverrides,
                    Elixir.AshAuthentication.Phoenix.Overrides.DaisyUI
                  ]

    reset_route path: "/_/password-reset",
                auth_routes_prefix: "/_/auth",
                overrides: [
                  QwynkWeb.AuthOverrides,
                  Elixir.AshAuthentication.Phoenix.Overrides.DaisyUI
                ]

    confirm_route Qwynk.Accounts.User, :confirm_new_user,
      path: "/_/confirm_new_user",
      auth_routes_prefix: "/_/auth",
      overrides: [QwynkWeb.AuthOverrides, Elixir.AshAuthentication.Phoenix.Overrides.DaisyUI]

    magic_sign_in_route(Qwynk.Accounts.User, :magic_link,
      path: "/_/magic_link",
      auth_routes_prefix: "/_/auth",
      overrides: [QwynkWeb.AuthOverrides, Elixir.AshAuthentication.Phoenix.Overrides.DaisyUI]
    )
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:qwynk, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    import Phoenix.LiveDashboard.Router

    scope "/_/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: QwynkWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  # LAST scope in the router: `/:slug` must never shadow a `/_/` route.
  scope "/", QwynkWeb do
    pipe_through :redirect_path

    get "/:slug", RedirectController, :show
  end
end
