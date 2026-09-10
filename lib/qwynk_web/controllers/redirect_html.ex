defmodule QwynkWeb.RedirectHTML do
  @moduledoc "Pages rendered by RedirectController. No layout, no session, no flash."
  use QwynkWeb, :html

  embed_templates "redirect_html/*"
end
