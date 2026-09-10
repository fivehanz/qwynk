defmodule Qwynk.Analytics.StatsTest do
  use Qwynk.DataCase, async: false

  import Qwynk.Fixtures

  defp log(link, visitor, date) do
    Ash.bulk_create!(
      [
        %{
          link_id: link.id,
          timestamp: DateTime.new!(date, ~T[12:00:00]),
          visitor_hash: visitor,
          device: :desktop
        }
      ],
      Qwynk.Analytics.Hit,
      :log,
      authorize?: false
    )
  end

  test "returns one zero-filled row per day" do
    link = link_fixture()
    rows = Qwynk.Analytics.stats(link.id, 30)

    assert length(rows) == 30
    assert Enum.all?(rows, &(&1.clicks == 0 and &1.uniques == 0))
    assert List.last(rows).date == Date.utc_today()
  end

  test "counts clicks and unique visitors per day" do
    link = link_fixture()
    today = Date.utc_today()
    yesterday = Date.add(today, -1)

    log(link, "visitor-a", today)
    log(link, "visitor-a", today)
    log(link, "visitor-b", today)
    log(link, "visitor-a", yesterday)

    rows = Qwynk.Analytics.stats(link.id, 30)
    by_date = Map.new(rows, &{&1.date, &1})

    assert by_date[today].clicks == 3
    assert by_date[today].uniques == 2
    assert by_date[yesterday].clicks == 1
    assert by_date[yesterday].uniques == 1
    assert by_date[Date.add(today, -2)].clicks == 0
  end

  test "another link's hits do not leak in" do
    user = user_fixture()
    mine = link_fixture(user)
    theirs = link_fixture()

    log(theirs, "visitor-a", Date.utc_today())

    assert Enum.all?(Qwynk.Analytics.stats(mine.id), &(&1.clicks == 0))
  end

  test "totals aggregate across a user's own links only" do
    user = user_fixture()
    mine = link_fixture(user)
    theirs = link_fixture()

    log(mine, "visitor-a", Date.utc_today())
    log(mine, "visitor-b", Date.utc_today())
    log(theirs, "visitor-c", Date.utc_today())

    totals = Qwynk.Analytics.totals(user.id)

    assert totals.links == 1
    assert totals.clicks == 2
    assert totals.uniques == 2
  end
end
