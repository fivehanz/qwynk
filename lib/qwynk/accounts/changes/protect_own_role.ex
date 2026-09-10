defmodule Qwynk.Accounts.Changes.ProtectOwnRole do
  @moduledoc """
  Refuses a role change to the actor's own account.

  Enforced here rather than in the UI so that the lowest-privilege account
  cannot escalate through the API, and so a superadmin cannot lock everyone out
  by demoting themselves.
  """
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, %{actor: %{id: actor_id}}) do
    if changeset.data.id == actor_id do
      Ash.Changeset.add_error(changeset,
        field: :role,
        message: "you cannot change your own role"
      )
    else
      changeset
    end
  end

  def change(changeset, _opts, _context), do: changeset
end
