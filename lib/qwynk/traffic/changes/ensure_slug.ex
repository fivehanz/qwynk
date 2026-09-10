defmodule Qwynk.Traffic.Changes.EnsureSlug do
  @moduledoc "Fills in a generated Goblin-Speak slug when the caller did not supply one."
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    case Ash.Changeset.get_attribute(changeset, :slug) do
      nil ->
        Ash.Changeset.force_change_attribute(
          changeset,
          :slug,
          Qwynk.Traffic.SlugGenerator.generate()
        )

      _slug ->
        changeset
    end
  end
end
