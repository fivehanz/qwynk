defmodule Qwynk.Analytics.Buffer do
  @moduledoc """
  Batches anonymous click events and bulk-inserts them.

  Bounded on purpose (AGENTS.md rule 5): past `max_size` new events are dropped
  and counted. Shedding analytics is always preferable to letting a database
  outage grow the heap until the node dies — redirects must keep working.

  Only anonymous events reach this process. Enrichment happens upstream in
  `Qwynk.Analytics.Enrich` (rule 4).
  """
  use GenServer

  require Logger

  alias Qwynk.Analytics.{Enrich, Hit, Salt}

  @flush_interval :timer.seconds(5)
  @flush_at 1000
  @max_size 10_000

  def start_link(opts) do
    {name, opts} = Keyword.pop(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc "Buffers an already-enriched event. Never blocks the caller."
  def record(event, server \\ __MODULE__), do: GenServer.cast(server, {:record, event})

  @doc "Flushes synchronously. Used by tests and on the timer."
  def flush(server \\ __MODULE__), do: GenServer.call(server, :flush)

  @doc "Returns `%{buffered: n, dropped: n, rejected: n}`."
  def stats(server \\ __MODULE__), do: GenServer.call(server, :stats)

  @doc "Discards everything buffered. For tests."
  def reset(server \\ __MODULE__), do: GenServer.call(server, :reset)

  @impl true
  def init(opts) do
    state = %{
      events: [],
      count: 0,
      dropped: 0,
      rejected: 0,
      date: Date.utc_today(),
      flush_interval: Keyword.get(opts, :flush_interval, @flush_interval),
      flush_at: Keyword.get(opts, :flush_at, @flush_at),
      max_size: Keyword.get(opts, :max_size, @max_size)
    }

    {:ok, schedule(state)}
  end

  @impl true
  def handle_cast({:record, _event}, %{count: count, max_size: max} = state)
      when count >= max do
    {:noreply, %{state | dropped: state.dropped + 1}}
  end

  def handle_cast({:record, event}, state) do
    state = %{state | events: [event | state.events], count: state.count + 1}

    if state.count >= state.flush_at do
      {:noreply, do_flush(state)}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_call(:flush, _from, state), do: {:reply, :ok, do_flush(state)}

  def handle_call(:stats, _from, state) do
    {:reply, %{buffered: state.count, dropped: state.dropped, rejected: state.rejected}, state}
  end

  def handle_call(:reset, _from, state) do
    {:reply, :ok, %{state | events: [], count: 0, dropped: 0, rejected: 0}}
  end

  @impl true
  def handle_info(:tick, state) do
    {:noreply, state |> do_flush() |> roll_date() |> schedule()}
  end

  defp schedule(%{flush_interval: :infinity} = state), do: state

  defp schedule(state) do
    Process.send_after(self(), :tick, state.flush_interval)
    state
  end

  defp do_flush(%{count: 0} = state), do: state

  defp do_flush(state) do
    events = Enum.reverse(state.events)

    case Ash.bulk_create(events, Hit, :log, return_errors?: true, authorize?: false) do
      %{status: :success} ->
        %{state | events: [], count: 0}

      result ->
        # The rows were rejected (a constraint violation, a link destroyed
        # between dispatch and flush). Retrying cannot make them valid, and
        # retaining them would poison every later batch queued behind them,
        # so drop and count.
        Logger.warning("analytics flush rejected #{state.count} events: #{inspect(result)}")
        %{state | events: [], count: 0, rejected: state.rejected + state.count}
    end
  rescue
    # The database is unreachable. These events are still valid, so retain them
    # (bounded by max_size) and retry on the next tick. Redirects keep working.
    error ->
      Logger.warning("analytics flush failed, retaining #{state.count} events: #{inspect(error)}")
      state
  end

  # Reuses the tick that is already running, so the daily salt roll needs no
  # separate process and no cron (AGENTS.md rule 9).
  defp roll_date(state) do
    today = Date.utc_today()

    if today == state.date do
      state
    else
      Salt.refresh()
      Qwynk.Analytics.purge_salts()
      %{state | date: today}
    end
  end

  @doc """
  Enriches and buffers a raw request. Call this from a task, never from the
  request process — enrichment does a GeoIP lookup (AGENTS.md rules 1 and 2).
  """
  def enrich_and_record(raw, server \\ __MODULE__) do
    raw |> Enrich.call() |> record(server)
  end
end
