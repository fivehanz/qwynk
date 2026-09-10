defmodule Qwynk.Analytics.HitTest do
  use Qwynk.DataCase, async: false

  import Qwynk.Fixtures

  test "bulk_create logs many hits at once" do
    link = link_fixture()

    events =
      for _ <- 1..3 do
        %{
          link_id: link.id,
          timestamp: DateTime.utc_now() |> DateTime.truncate(:second),
          visitor_hash: String.duplicate("a", 64),
          country: "US",
          device: :mobile,
          referrer_domain: "example.com"
        }
      end

    assert %{status: :success} =
             Ash.bulk_create(events, Qwynk.Analytics.Hit, :log,
               return_errors?: true,
               authorize?: false
             )

    assert length(Qwynk.Analytics.list_hits!(authorize?: false)) == 3
  end

  test "country and referrer_domain are optional" do
    link = link_fixture()

    assert %{status: :success} =
             Ash.bulk_create(
               [
                 %{
                   link_id: link.id,
                   timestamp: DateTime.utc_now() |> DateTime.truncate(:second),
                   visitor_hash: String.duplicate("b", 64),
                   country: nil,
                   device: :desktop,
                   referrer_domain: nil
                 }
               ],
               Qwynk.Analytics.Hit,
               :log,
               return_errors?: true,
               authorize?: false
             )
  end

  test "the hits table stores no PII columns" do
    %{rows: rows} =
      Qwynk.Repo.query!(
        "select column_name from information_schema.columns where table_name = 'hits'"
      )

    columns = List.flatten(rows)

    refute "ip" in columns
    refute "ip_address" in columns
    refute "user_agent" in columns
    refute "referrer" in columns
    assert "referrer_domain" in columns
    assert "visitor_hash" in columns
  end
end
