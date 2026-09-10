defmodule Qwynk.Analytics do
  use Ash.Domain, otp_app: :qwynk

  resources do
    resource Qwynk.Analytics.Hit do
      define :list_hits, action: :read
    end

    resource Qwynk.Analytics.DailySalt do
      define :list_salts, action: :read
      define :purge_salt, action: :purge
    end
  end

  @doc "Deletes salts past the retention window."
  def purge_salts do
    Qwynk.Analytics.DailySalt
    |> Ash.bulk_destroy!(:purge, %{}, authorize?: false, strategy: [:atomic, :stream])
    |> then(fn _ -> :ok end)
  end
end
