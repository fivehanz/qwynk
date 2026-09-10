defmodule Qwynk.Traffic.Domain do
  @moduledoc """
  A hostname pointed at this server.

  Domains are operator-level, not user-owned: a self-hosted install runs the
  domains, users put links on them. `root_url` being null is the default and
  means the domain's root path 404s rather than advertising the admin.
  """
  use Ash.Resource,
    otp_app: :qwynk,
    domain: Qwynk.Traffic,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "domains"
    repo Qwynk.Repo
  end

  actions do
    defaults [:read]

    create :create do
      primary? true
      accept [:host, :root_url, :is_active]
      change Qwynk.Traffic.Changes.NormalizeHost
    end

    read :by_host do
      get? true
      argument :host, :string, allow_nil?: false
      filter expr(host == ^arg(:host) and is_active == true)
    end

    update :update do
      primary? true
      accept [:host, :root_url, :is_active]
      require_atomic? false
      change Qwynk.Traffic.Changes.NormalizeHost
      change Qwynk.Traffic.Changes.InvalidateDomainCache
    end

    destroy :destroy do
      primary? true
      require_atomic? false
      validate Qwynk.Traffic.Validations.DomainHasNoLinks
      change Qwynk.Traffic.Changes.InvalidateDomainCache
    end
  end

  policies do
    # Reading is open: the redirect path resolves domains with no actor at all,
    # and a user has to see the host their own link lives on to copy its URL.
    # Hostnames are public DNS — it is *managing* them that needs privilege.
    policy action_type(:read) do
      authorize_if always()
    end

    # Scoped to writes, not `always()`: every policy whose condition matches has
    # to pass, so a catch-all would forbid the reads the policy above allows.
    policy action_type([:create, :update, :destroy]) do
      authorize_if expr(^actor(:role) == :superadmin)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :host, :string do
      allow_nil? false
      public? true
      description "Hostname only — no scheme, no port, no path."
      constraints min_length: 3, max_length: 253
    end

    attribute :root_url, :string do
      public? true
      description "Where `/` goes. Null means 404, which is the default."
    end

    attribute :is_active, :boolean, allow_nil?: false, default: true, public?: true

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :links, Qwynk.Traffic.Link
  end

  identities do
    identity :unique_host, [:host]
  end
end
