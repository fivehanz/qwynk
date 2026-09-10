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
    log_hit(conn, entry)

    conn
    |> put_resp_header("x-qwynk-cache", cache_state)
    |> put_status(status(entry.strategy))
    |> redirect(external: entry.destination)
  end

  # Enrichment runs off the request process: on an ETS hit the hot path touches
  # neither PostgreSQL nor the GeoIP database (AGENTS.md rules 1-3).
  defp log_hit(conn, entry) do
    raw = %{
      link_id: entry.link_id,
      ip: client_ip(conn),
      user_agent: conn |> get_req_header("user-agent") |> List.first(),
      referrer: conn |> get_req_header("referer") |> List.first()
    }

    Task.Supervisor.start_child(Qwynk.TaskSupervisor, fn ->
      Qwynk.Analytics.Buffer.enrich_and_record(raw)
    end)

    conn
  end

  # x-forwarded-for is trusted because OpenResty fronts the app and the app is
  # not directly reachable (PRD 2).
  defp client_ip(conn) do
    case get_req_header(conn, "x-forwarded-for") do
      [value | _] -> value |> String.split(",") |> List.first() |> String.trim()
      [] -> conn.remote_ip |> :inet.ntoa() |> to_string()
    end
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
