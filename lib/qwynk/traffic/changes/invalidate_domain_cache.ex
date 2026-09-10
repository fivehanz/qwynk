defmodule Qwynk.Traffic.Changes.InvalidateDomainCache do
  @moduledoc """
  Flushes a domain's cached entries after it changes.

  A host rename, a deactivation or a `root_url` edit all make previously cached
  redirects wrong, and the link-level hooks cannot see a domain-level change.
  Both the old and new host are evicted, because a rename moves the key.
  """
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    previous = changeset.data.host

    Ash.Changeset.after_action(changeset, fn _changeset, record ->
      Qwynk.Traffic.Cache.delete_domain(previous)
      Qwynk.Traffic.Cache.delete_domain(record.host)
      {:ok, record}
    end)
  end
end
