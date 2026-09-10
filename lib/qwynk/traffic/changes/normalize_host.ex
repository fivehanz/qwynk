defmodule Qwynk.Traffic.Changes.NormalizeHost do
  @moduledoc """
  Reduces whatever was typed to a bare lowercase hostname.

  Operators paste `https://Acme.com/` as often as they type `acme.com`, and the
  Host header this is matched against is bare and lowercase.
  """
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    case Ash.Changeset.get_attribute(changeset, :host) do
      host when is_binary(host) ->
        Ash.Changeset.force_change_attribute(changeset, :host, normalize(host))

      _ ->
        changeset
    end
  end

  @doc "acme.com, from anything reasonable a human might paste."
  def normalize(host) do
    host
    |> String.trim()
    |> String.downcase()
    |> String.replace(~r{^[a-z]+://}, "")
    |> String.split("/")
    |> List.first()
    |> String.split(":")
    |> List.first()
    |> Kernel.||("")
  end
end
