defmodule QwynkWeb.RedirectController do
  @moduledoc """
  The hot path, and the root path, for every domain pointed at this server.

  On an ETS hit this touches neither PostgreSQL nor the GeoIP database, and it
  drops no cookies (PRD 5.1). Analytics dispatch stays asynchronous
  (AGENTS.md rule 1).

  Slugs are resolved *within* a domain, so `acme.com/launch` and
  `beta.io/launch` are different links.
  """
  use QwynkWeb, :controller

  alias Qwynk.Traffic.Cache

  @doc """
  `/` on a link domain.

  404 by default: a bare domain should not advertise that an admin panel
  exists. A superadmin can point it somewhere via the domain's `root_url`.
  """
  def root(conn, _params) do
    case Cache.domain(host(conn)) do
      {:ok, %{root_url: url}} when is_binary(url) and url != "" ->
        conn
        |> put_resp_header("x-qwynk-cache", "root")
        |> redirect(external: url)

      _ ->
        not_found(conn)
    end
  end

  def show(conn, %{"slug" => slug}) do
    host = host(conn)

    case Cache.fetch(host, slug) do
      {:hit, entry} ->
        send_redirect(conn, entry, "hit")

      :miss ->
        resolve(conn, host, slug)
    end
  end

  defp resolve(conn, host, slug) do
    with {:ok, domain} <- Cache.domain(host),
         {:ok, link} <- Qwynk.Traffic.resolve(slug, domain.id, authorize?: false) do
      send_redirect(conn, Cache.put(host, slug, Cache.entry(link)), "miss")
    else
      _ -> not_found(conn)
    end
  end

  defp send_redirect(conn, entry, cache_state) do
    log_hit(conn, entry)

    conn
    |> put_resp_header("x-qwynk-cache", cache_state)
    |> put_status(status(entry.strategy))
    |> redirect(external: entry.destination)
  end

  defp status(:permanent), do: 301
  defp status(:temporary), do: 302

  # Downcased to match the normalized `host` stored on Domain; a Host header may
  # arrive in any case and may carry a port.
  defp host(conn) do
    conn.host
    |> to_string()
    |> String.downcase()
    |> String.split(":")
    |> List.first()
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

  defp not_found(conn) do
    conn
    |> put_status(:not_found)
    |> put_root_layout(false)
    |> put_view(html: QwynkWeb.RedirectHTML)
    |> render(:not_found)
  end
end
