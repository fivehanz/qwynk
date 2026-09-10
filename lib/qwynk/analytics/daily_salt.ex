defmodule Qwynk.Analytics.DailySalt do
  @moduledoc """
  Rotating hash salt, one row per day.

  Retention is the point: the privacy guarantee comes from an old salt being
  *gone*, so `purge` deletes anything past the retention window. Keeping every
  salt forever would make the rotation decorative.
  """
  use Ash.Resource,
    otp_app: :qwynk,
    domain: Qwynk.Analytics,
    data_layer: AshPostgres.DataLayer

  @retention_days 2

  postgres do
    table "daily_salts"
    repo Qwynk.Repo
  end

  actions do
    defaults [:read]

    create :get_or_create_today do
      accept [:date]
      upsert? true
      upsert_identity :unique_date
      upsert_fields []
    end

    destroy :purge do
      primary? true
      require_atomic? false
      change filter(expr(date < ^Date.add(Date.utc_today(), -@retention_days)))
    end
  end

  attributes do
    attribute :date, :date, primary_key?: true, allow_nil?: false, public?: true, writable?: true

    attribute :secret, :string do
      allow_nil? false
      sensitive? true
      default fn -> Base.encode16(:crypto.strong_rand_bytes(32), case: :lower) end
    end
  end

  identities do
    identity :unique_date, [:date]
  end
end
