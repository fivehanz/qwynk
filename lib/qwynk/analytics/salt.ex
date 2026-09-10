defmodule Qwynk.Analytics.Salt do
  @moduledoc """
  Today's hashing salt, held in `:persistent_term`.

  PostgreSQL must never be on the redirect path (AGENTS.md rule 3), and hashing
  must keep working while the database is down — so the salt is read at most
  once a day and cached. The date roll is driven by the buffer's existing tick;
  there is no separate salt process and no cron.
  """

  @key {__MODULE__, :salt}

  @doc "Today's salt, reading through to the database at most once per day."
  def current do
    today = Date.utc_today()

    case :persistent_term.get(@key, nil) do
      {^today, secret} -> secret
      _stale -> load(today)
    end
  end

  @doc "Forces a re-read. Called on the date roll."
  def refresh do
    :persistent_term.erase(@key)
    current()
  end

  defp load(today) do
    secret =
      Qwynk.Analytics.DailySalt
      |> Ash.Changeset.for_create(:get_or_create_today, %{date: today})
      |> Ash.create!(authorize?: false)
      |> Map.fetch!(:secret)

    :persistent_term.put(@key, {today, secret})
    secret
  end
end
