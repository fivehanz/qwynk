defmodule Qwynk.Traffic.Cache do
  @moduledoc """
  Read-through ETS caches for the redirect hot path.

  Two tables, both created in `Qwynk.Application.start/2` so the application
  master owns them and they live as long as the app, and both `:public` because
  the request process writes on a miss.

  * `:qwynk_cache` — `{{host, slug}, entry, expires_at}`. Keyed by host as well
    as slug because slugs are unique *per domain*: `acme.com/launch` and
    `beta.io/launch` are different links.
  * `:qwynk_domains` — `{host, domain_or_nil, expires_at}`. Domains are few and
    change rarely; caching them keeps the hot path to at most one Postgres
    query on a miss instead of two. Misses are cached too, so an unknown Host
    header cannot be used to hammer the database.
  """

  @table :qwynk_cache
  @domains :qwynk_domains
  @ttl_ms :timer.minutes(10)
  @domain_ttl_ms :timer.minutes(5)

  @type entry :: %{link_id: binary(), destination: binary(), strategy: :permanent | :temporary}

  @doc "Creates both tables. Idempotent, so tests may call it repeatedly."
  def init do
    new(@table)
    new(@domains)
    :ok
  end

  defp new(name) do
    :ets.new(name, [:named_table, :set, :public, read_concurrency: true])
  rescue
    ArgumentError -> name
  end

  @doc """
  Empties both tables.

  For tests: ETS is not covered by the SQL sandbox, so rows cached in one test
  outlive the transaction that created them and would resolve to ids that no
  longer exist.
  """
  def flush do
    :ets.delete_all_objects(@table)
    :ets.delete_all_objects(@domains)
    :ok
  end

  @spec entry(struct()) :: entry()
  def entry(link),
    do: %{link_id: link.id, destination: link.destination, strategy: link.strategy}

  @spec fetch(binary(), binary()) :: {:hit, entry()} | :miss
  def fetch(host, slug) do
    key = {host, slug}
    now = now()

    case :ets.lookup(@table, key) do
      [{^key, entry, expires_at}] when expires_at > now ->
        {:hit, entry}

      [{^key, _entry, _expired}] ->
        :ets.delete(@table, key)
        :miss

      [] ->
        :miss
    end
  end

  @spec put(binary(), binary(), entry(), integer()) :: entry()
  def put(host, slug, entry, ttl_ms \\ @ttl_ms) do
    :ets.insert(@table, {{host, slug}, entry, now() + ttl_ms})
    entry
  end

  @spec delete(binary(), binary()) :: true
  def delete(host, slug), do: :ets.delete(@table, {host, slug})

  @doc "Evicts every cached slug on `host`, plus the host's own domain entry."
  def delete_domain(nil), do: true

  def delete_domain(host) do
    :ets.match_delete(@table, {{host, :_}, :_, :_})
    :ets.delete(@domains, host)
    true
  end

  @doc """
  Resolves a Host header to a domain, `nil` when there is no active match.

  Negative results are cached as well, so an unknown host is one query per TTL
  rather than one per request.
  """
  @spec domain(binary()) :: {:ok, struct()} | :unknown
  def domain(host) do
    now = now()

    case :ets.lookup(@domains, host) do
      [{^host, cached, expires_at}] when expires_at > now ->
        wrap(cached)

      _ ->
        loaded =
          case Qwynk.Traffic.domain_by_host(host, authorize?: false) do
            {:ok, domain} -> domain
            {:error, _} -> nil
          end

        :ets.insert(@domains, {host, loaded, now + @domain_ttl_ms})
        wrap(loaded)
    end
  end

  defp wrap(nil), do: :unknown
  defp wrap(domain), do: {:ok, domain}

  defp now, do: System.monotonic_time(:millisecond)
end
