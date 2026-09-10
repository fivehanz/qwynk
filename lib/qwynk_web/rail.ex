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

  defp cache_state do
    case :ets.info(:qwynk_cache, :size) do
      size when is_integer(size) and size > 0 -> :warm
      _ -> :cold
    end
  end
end
