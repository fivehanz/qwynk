defmodule Qwynk.Traffic.Cache do
  @moduledoc """
  Read-through ETS cache for the redirect hot path.

  The stored entry carries `link_id` so the analytics path never needs a second
  lookup (AGENTS.md rule 6). TTL is a safety net only — mutations invalidate
  explicitly via `Qwynk.Traffic.Changes.InvalidateCache` (rule 7).

  The table is `:public` because the request process writes to it on a miss, and
  it is created in `Qwynk.Application.start/2` so the application master owns it
  and it lives as long as the app.
  """

  @table :qwynk_cache
  @ttl_ms :timer.minutes(10)

  @type entry :: %{link_id: binary(), destination: binary(), strategy: :permanent | :temporary}

  @doc "Creates the table. Idempotent, so tests may call it repeatedly."
  def init do
    :ets.new(@table, [:named_table, :set, :public, read_concurrency: true])
  rescue
    ArgumentError -> @table
  end

  @spec entry(struct()) :: entry()
  def entry(link),
    do: %{link_id: link.id, destination: link.destination, strategy: link.strategy}

  @spec fetch(binary()) :: {:hit, entry()} | :miss
  def fetch(slug) do
    now = System.monotonic_time(:millisecond)

    case :ets.lookup(@table, slug) do
      [{^slug, entry, expires_at}] when expires_at > now ->
        {:hit, entry}

      [{^slug, _entry, _expired}] ->
        delete(slug)
        :miss

      [] ->
        :miss
    end
  end

  @spec put(binary(), entry(), integer()) :: entry()
  def put(slug, entry, ttl_ms \\ @ttl_ms) do
    :ets.insert(@table, {slug, entry, System.monotonic_time(:millisecond) + ttl_ms})
    entry
  end

  @spec delete(binary()) :: true
  def delete(slug), do: :ets.delete(@table, slug)
end
