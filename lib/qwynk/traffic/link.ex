defmodule Qwynk.Traffic.Link do
  @moduledoc """
  A short link. `resolve` is the source of truth behind the ETS cache.
  """
  use Ash.Resource,
    otp_app: :qwynk,
    domain: Qwynk.Traffic,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "links"
    repo Qwynk.Repo
  end

  actions do
    defaults [:read]

    create :create do
      primary? true
      accept [:destination, :slug, :strategy, :domain_id]
      change relate_actor(:owner)
      change Qwynk.Traffic.Changes.EnsureSlug
    end

    read :resolve do
      get? true
      argument :slug, :string, allow_nil?: false
      argument :domain_id, :uuid, allow_nil?: false

      filter expr(slug == ^arg(:slug) and domain_id == ^arg(:domain_id) and is_active == true)
    end

    update :update do
      primary? true
      accept [:destination, :strategy, :is_active]
      # after_action hooks are not atomic, and config sets
      # default_actions_require_atomic?: true
      require_atomic? false
      change Qwynk.Traffic.Changes.InvalidateCache
    end

    update :disable do
      accept []
      require_atomic? false
      change set_attribute(:is_active, false)
      change Qwynk.Traffic.Changes.InvalidateCache
    end

    destroy :destroy do
      primary? true
      require_atomic? false
      change Qwynk.Traffic.Changes.InvalidateCache
    end
  end

  policies do
    # A public redirect has no actor. Every other action is owner-scoped,
    # except that staff can see and manage everything.
    policy action(:resolve) do
      authorize_if always()
    end

    policy always() do
      authorize_if expr(^actor(:role) in [:superadmin, :admin])
      authorize_if relates_to_actor_via(:owner)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :slug, :string do
      allow_nil? false
      public? true
      constraints min_length: 3, max_length: 64, match: ~r/^[a-z0-9-]+$/
    end

    attribute :destination, :string, allow_nil?: false, public?: true

    attribute :strategy, :atom do
      public? true
      allow_nil? false
      default :temporary
      constraints one_of: [:permanent, :temporary]
    end

    attribute :is_active, :boolean, allow_nil?: false, default: true, public?: true

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :owner, Qwynk.Accounts.User, allow_nil?: false, public?: true
    belongs_to :domain, Qwynk.Traffic.Domain, allow_nil?: false, public?: true
  end

  identities do
    # Per domain, not global: two customers must be able to hold the same slug.
    identity :unique_slug_per_domain, [:domain_id, :slug]
  end
end
