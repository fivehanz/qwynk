defmodule Qwynk.Analytics.Enrich do
  @moduledoc """
  The privacy boundary (AGENTS.md rule 4).

  Raw IP and User-Agent enter here and do not leave. Everything downstream —
  the buffer, the database, the admin — sees only the anonymous event this
  returns. Run this before buffering, never inside it.
  """

  alias Qwynk.Analytics.{Geo, Salt}

  @bot ~r/bot|crawler|spider|crawling|curl|wget|headless|slurp|monitoring/i
  @tablet ~r/ipad|tablet|playbook|silk|android(?!.*mobile)/i
  @mobile ~r/mobile|iphone|ipod|android|blackberry|opera mini|iemobile/i

  @spec call(map()) :: map()
  def call(%{link_id: link_id, ip: ip, user_agent: ua, referrer: referrer}) do
    %{
      link_id: link_id,
      timestamp: DateTime.utc_now() |> DateTime.truncate(:second),
      visitor_hash: hash(ip, ua),
      country: Geo.country(ip),
      device: device(ua),
      referrer_domain: referrer_domain(referrer)
    }
  end

  defp hash(ip, ua) do
    :crypto.hash(:sha256, [to_string(ip), to_string(ua), Salt.current()])
    |> Base.encode16(case: :lower)
  end

  # ponytail: four regexes instead of ua_inspector, which is a dependency plus a
  # downloaded UA database. The schema has exactly four buckets. Add it when the
  # admin needs browser/OS detail.
  defp device(nil), do: :desktop

  defp device(ua) do
    cond do
      Regex.match?(@bot, ua) -> :bot
      Regex.match?(@tablet, ua) -> :tablet
      Regex.match?(@mobile, ua) -> :mobile
      true -> :desktop
    end
  end

  # Host only. Never the path, query string or fragment — those carry secrets.
  defp referrer_domain(nil), do: nil

  defp referrer_domain(referrer) do
    case URI.parse(referrer) do
      %URI{host: host} when is_binary(host) and host != "" -> host
      _ -> nil
    end
  end
end
