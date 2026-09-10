defmodule Qwynk.Traffic do
  use Ash.Domain, otp_app: :qwynk

  alias Qwynk.Traffic.{Domain, Link, SlugGenerator}

  resources do
    resource Domain do
      define :get_domain, action: :read, get_by: [:id]
      define :list_domains, action: :read
      define :domain_by_host, action: :by_host, args: [:host]
      define :create_domain, action: :create
      define :update_domain, action: :update
      define :destroy_domain, action: :destroy
    end

    resource Link do
      define :get_link, action: :read, get_by: [:id]
      define :list_links, action: :read
      define :resolve, action: :resolve, args: [:slug, :domain_id]
      define :insert_link, action: :create
      define :update_link, action: :update
      define :disable_link, action: :disable
      define :destroy_link, action: :destroy
    end
  end

  # 16 onsets x 5 nuclei x 11 codas, squared => 774_400 slugs, so birthday
  # collisions reach ~50% near a thousand links. Five fresh draws, then a
  # numeric suffix. A caller-supplied slug is never retried.
  @attempts 5

  @doc "Creates a link, retrying generated slugs on collision."
  def create_link(attrs, opts \\ []), do: do_create(attrs, opts, @attempts)

  defp do_create(attrs, opts, 0) do
    attrs |> Map.put(:slug, SlugGenerator.generate_with_suffix()) |> insert_link(opts)
  end

  defp do_create(attrs, opts, attempts) do
    case insert_link(attrs, opts) do
      {:error, error} ->
        if Map.has_key?(attrs, :slug) or not slug_taken?(error) do
          {:error, error}
        else
          do_create(attrs, opts, attempts - 1)
        end

      ok ->
        ok
    end
  end

  defp slug_taken?(%Ash.Error.Invalid{errors: errors}) do
    Enum.any?(errors, &match?(%{field: :slug}, &1))
  end

  defp slug_taken?(_), do: false
end
