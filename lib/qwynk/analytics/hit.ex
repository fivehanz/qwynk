defmodule Qwynk.Analytics.Hit do
  @moduledoc """
  An immutable click record.

  There is deliberately no `ip` or `user_agent` column. That absence *is* the
  privacy guarantee (AGENTS.md rule 4), and a schema-level test asserts it.
  """
  use Ash.Resource,
    otp_app: :qwynk,
    domain: Qwynk.Analytics,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "hits"
    repo Qwynk.Repo

    custom_indexes do
      index [:link_id, :timestamp]
      index [:link_id, :visitor_hash]
    end
  end

  actions do
    defaults [:read]

    # No validation: write throughput is the priority, and the only caller is
    # Qwynk.Analytics.Buffer, which builds the struct itself.
    create :log do
      primary? true
      accept [:link_id, :timestamp, :visitor_hash, :country, :device, :referrer_domain]
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :timestamp, :utc_datetime, allow_nil?: false, public?: true
    attribute :visitor_hash, :string, allow_nil?: false, public?: true
    attribute :country, :string, public?: true

    attribute :device, :atom do
      public? true
      constraints one_of: [:mobile, :desktop, :tablet, :bot]
    end

    attribute :referrer_domain, :string, public?: true
  end

  relationships do
    belongs_to :link, Qwynk.Traffic.Link, allow_nil?: false, public?: true
  end
end
