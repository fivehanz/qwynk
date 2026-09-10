defmodule QwynkWeb.RedirectController do
  @moduledoc """
  The hot path. Budget: < 5ms internal.

  On an ETS hit this touches neither PostgreSQL nor the GeoIP database, and it
  drops no cookies (PRD 5.1). Analytics dispatch is added in a later commit and
  must stay asynchronous (AGENTS.md rule 1).
  """
  use QwynkWeb, :controller

  alias Qwynk.Traffic.Cache

  def show(conn, %{"slug" => slug}) do
    case Cache.fetch(slug) do
      {:hit, entry} ->
        send_redirect(conn, entry, "hit")

      :miss ->
        case Qwynk.Traffic.resolve(slug, authorize?: false) do
          {:ok, link} -> send_redirect(conn, Cache.put(slug, Cache.entry(link)), "miss")
          {:error, _} -> not_found(conn)
        end
    end
  end

  defp send_redirect(conn, entry, cache_state) do
    conn
    |> put_resp_header("x-qwynk-cache", cache_state)
    |> put_status(status(entry.strategy))
    |> redirect(external: entry.destination)
  end

  defp status(:permanent), do: 301
  defp status(:temporary), do: 302

  defp not_found(conn) do
    conn
    |> put_status(:not_found)
    |> put_root_layout(false)
    |> put_view(html: QwynkWeb.RedirectHTML)
    |> render(:not_found)
  end
end
