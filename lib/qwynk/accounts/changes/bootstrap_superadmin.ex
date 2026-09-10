defmodule Qwynk.Accounts.Changes.BootstrapSuperadmin do
  @moduledoc """
  The first account to register becomes the superadmin.

  Without this nobody can ever reach the console on a fresh install, and there
  is no out-of-band way to grant the role.
  """
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.before_action(changeset, fn changeset ->
      if first_user?() do
        Ash.Changeset.force_change_attribute(changeset, :role, :superadmin)
      else
        changeset
      end
    end)
  end

  defp first_user?, do: Ash.count!(Qwynk.Accounts.User, authorize?: false) == 0
end
