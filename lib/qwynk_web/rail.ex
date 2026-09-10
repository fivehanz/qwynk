defmodule QwynkWeb.Rail do
  @moduledoc """
  The header status readout. One instrument, built the same way on every screen,
  which is why it lives here instead of being reassembled per LiveView.
  """

  @doc "System state for `user`: link count, 30-day totals, cache temperature."
  def build(user) do
    totals = Qwynk.Analytics.totals(user.id)

    %{
      links: totals.links,
      clicks: totals.clicks,
      uniques: totals.uniques,
      cache: cache_state()
    }
  end

  @doc """
  A link's public URL, on its own domain.

  The endpoint's host is the console's host, which is often not the host the
  link lives on once several domains point here.
  """
  def link_url(%{domain: %{host: host}} = link) do
    scheme =
      if host in ["localhost", "127.0.0.1"],
        do: "http://localhost:4000/",
        else: "https://#{host}/"

    scheme <> link.slug
  end

  def link_url(link) do
    link = Ash.load!(link, :domain, authorize?: false)
    link_url(link)
  end

  defp cache_state do
    case :ets.info(:qwynk_cache, :size) do
      size when is_integer(size) and size > 0 -> :warm
      _ -> :cold
    end
  end
end
