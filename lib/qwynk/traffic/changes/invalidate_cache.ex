defmodule Qwynk.Traffic.Changes.InvalidateCache do
  @moduledoc """
  Evicts the ETS entry after a link mutation (AGENTS.md rule 7).

  TTL is only the fallback: without this, an edit keeps serving the old
  destination for up to the remaining 10 minutes.

  ponytail: node-local eviction. A second node needs a Phoenix.PubSub broadcast
  here; a single FreeBSD jail does not.
  """
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, fn _changeset, record ->
      record = Ash.load!(record, :domain, authorize?: false)
      Qwynk.Traffic.Cache.delete(record.domain.host, record.slug)
      {:ok, record}
    end)
  end
end
