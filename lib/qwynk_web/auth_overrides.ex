defmodule QwynkWeb.AuthOverrides do
  @moduledoc """
  Brands the AshAuthentication screens to "Abyssal Terminal".

  These are listed after the DaisyUI overrides in every route macro in the
  router, so anything not set here falls back to the library defaults. The one
  override that is not cosmetic is Banner: its default `image_url` points at
  `ash-hq.org`, loading a third-party logo onto the sign-in page.
  """
  use AshAuthentication.Phoenix.Overrides

  # Flex column, not the library's full-height grid: as a grid the banner, the
  # form panel and the divider become separate auto rows and scatter down the
  # viewport.
  @page "flex min-h-screen flex-col items-center justify-center gap-0 bg-base-100 px-4 py-12"
  @panel "mx-auto w-full max-w-sm border border-base-300 bg-base-200/40 p-6 sm:p-8"
  @field "w-full border border-base-300 bg-base-100 px-2.5 py-2 text-sm " <>
           "placeholder:text-secondary focus:border-primary focus:outline-none"
  @submit "w-full border border-primary bg-primary px-3 py-2 text-sm font-medium " <>
            "text-primary-content transition-colors hover:bg-primary/90 disabled:opacity-50"

  override AshAuthentication.Phoenix.Components.Banner do
    set :root_class, "mb-5 flex flex-col items-center"
    set :href_url, "/_/sign-in"
    set :href_class, "flex items-center gap-2"
    set :image_url, nil
    set :dark_image_url, nil
    set :image_class, "hidden"
    set :dark_image_class, "hidden"
    set :text, "Qwynk"
    set :text_class, "font-heading text-2xl tracking-tight text-base-content"
  end

  override AshAuthentication.Phoenix.Components.SignIn do
    set :root_class, @page
    set :strategy_class, @panel

    set :authentication_error_container_class,
        "mx-auto mb-4 max-w-sm border border-error/60 bg-base-200 p-3 text-center"

    set :authentication_error_text_class, "text-sm text-error"
  end

  override AshAuthentication.Phoenix.Components.Password do
    set :root_class, nil
    set :hide_class, "hidden"
    set :show_first, :sign_in

    set :interstitial_class,
        "flex flex-row justify-between gap-2 mt-4 text-xs text-secondary"

    set :toggler_class, "text-secondary underline-offset-2 hover:text-primary hover:underline"
  end

  override AshAuthentication.Phoenix.Components.Password.SignInForm do
    set :label_class, "mb-5 font-heading text-lg text-base-content"
    set :disable_button_text, "Signing in…"
  end

  override AshAuthentication.Phoenix.Components.Password.RegisterForm do
    set :label_class, "mb-5 font-heading text-lg text-base-content"
    set :disable_button_text, "Creating account…"
  end

  override AshAuthentication.Phoenix.Components.Password.ResetForm do
    set :label_class, "mb-5 font-heading text-lg text-base-content"
    set :disable_button_text, "Sending…"
  end

  override AshAuthentication.Phoenix.Components.Password.Input do
    set :field_class, "mb-4"
    set :label_class, "mb-1 block text-sm text-base-content"
    set :input_class, @field
    set :input_class_with_error, @field <> " border-error"
    set :submit_class, @submit
    set :error_ul, "mt-1 text-xs text-error"
    set :error_li, nil
    set :identity_input_placeholder, "you@example.com"
    set :remember_me_class, "mb-4 flex items-center gap-2 text-sm text-secondary"
    set :checkbox_class, "mr-1 accent-primary"
    set :checkbox_label_class, "text-sm text-secondary"
  end

  override AshAuthentication.Phoenix.Components.Reset do
    set :root_class, @page
    set :strategy_class, @panel
  end

  override AshAuthentication.Phoenix.Components.Reset.Form do
    set :label_class, "mb-5 font-heading text-lg text-base-content"
    set :disable_button_text, "Changing password…"
  end

  override AshAuthentication.Phoenix.Components.Confirm do
    set :root_class, @page
    set :strategy_class, @panel
  end

  override AshAuthentication.Phoenix.Components.MagicLink do
    set :root_class, nil
    set :label_class, "mb-5 font-heading text-lg text-base-content"
    set :disable_button_text, "Sending…"
  end

  # Magic link renders no form on the sign-in page, so this rule divides
  # nothing. Hidden rather than styled.
  override AshAuthentication.Phoenix.Components.HorizontalRule do
    set :root_class, "hidden"
    set :hr_outer_class, "hidden"
    set :hr_inner_class, "hidden"
    set :text_outer_class, "hidden"
    set :text_inner_class, "hidden"
  end
end
