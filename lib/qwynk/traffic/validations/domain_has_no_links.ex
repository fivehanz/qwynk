defmodule Qwynk.Traffic.Validations.DomainHasNoLinks do
  @moduledoc """
  Refuses to delete a domain that still has links.

  Deleting would cascade away live redirects with no way back. Deactivating
  stops traffic and is reversible, so that is the supported path.
  """
  use Ash.Resource.Validation

  @impl true
  def validate(changeset, _opts, _context) do
    count =
      Qwynk.Traffic.Link
      |> Ash.Query.filter(domain_id == ^changeset.data.id)
      |> Ash.count!(authorize?: false)

    if count == 0 do
      :ok
    else
      {:error,
       field: :id, message: "still has #{count} link(s) — deactivate it instead of deleting"}
    end
  end
end
