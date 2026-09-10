defmodule Qwynk.Analytics.SaltTest do
  use Qwynk.DataCase, async: false

  alias Qwynk.Analytics.{DailySalt, Salt}

  setup do
    :persistent_term.erase({Salt, :salt})
    :ok
  end

  test "current/0 is stable within a day" do
    salt = Salt.current()
    assert byte_size(salt) == 64
    assert Salt.current() == salt
  end

  test "current/0 caches in persistent_term after the first read" do
    Salt.current()
    assert {%Date{}, _secret} = :persistent_term.get({Salt, :salt})
  end

  test "refresh/0 re-reads and keeps the same secret for the same day" do
    salt = Salt.current()
    assert Salt.refresh() == salt
  end

  test "purge removes salts past the retention window but keeps today's" do
    today = Salt.current()
    old = Date.add(Date.utc_today(), -5)

    DailySalt
    |> Ash.Changeset.for_create(:get_or_create_today, %{date: old})
    |> Ash.create!(authorize?: false)

    :ok = Qwynk.Analytics.purge_salts()

    dates = Qwynk.Analytics.list_salts!(authorize?: false) |> Enum.map(& &1.date)
    refute old in dates
    assert Date.utc_today() in dates
    assert Salt.current() == today
  end
end
