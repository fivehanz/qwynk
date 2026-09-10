defmodule QwynkWeb.PageController do
  use QwynkWeb, :controller

  @doc """
  The Phoenix app has no marketing surface — that is the Astro site at
  qwynk.jsmx.org. `/` is just the way in; LiveUserAuth bounces anonymous
  visitors on to sign-in.
  """
  def home(conn, _params), do: redirect(conn, to: ~p"/_/app")
end
