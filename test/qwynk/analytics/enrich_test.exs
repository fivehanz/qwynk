defmodule Qwynk.Analytics.EnrichTest do
  use Qwynk.DataCase, async: false

  alias Qwynk.Analytics.Enrich

  @raw %{
    link_id: "11111111-1111-1111-1111-111111111111",
    ip: "203.0.113.7",
    user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) Mobile/15E148",
    referrer: "https://news.example.com/a/b?secret=123#frag"
  }

  test "the output carries no raw ip or user agent" do
    event = Enrich.call(@raw)

    assert Enum.sort(Map.keys(event)) ==
             [:country, :device, :link_id, :referrer_domain, :timestamp, :visitor_hash]

    refute event.visitor_hash =~ "203.0.113"
    refute event.visitor_hash =~ "iPhone"
  end

  test "referrer is reduced to its host" do
    assert Enrich.call(@raw).referrer_domain == "news.example.com"
  end

  test "a missing or malformed referrer yields nil" do
    assert Enrich.call(%{@raw | referrer: nil}).referrer_domain == nil
    assert Enrich.call(%{@raw | referrer: "not a url"}).referrer_domain == nil
  end

  test "device classification covers all four buckets" do
    assert Enrich.call(@raw).device == :mobile
    assert Enrich.call(%{@raw | user_agent: "Mozilla/5.0 (Macintosh)"}).device == :desktop
    assert Enrich.call(%{@raw | user_agent: "Googlebot/2.1"}).device == :bot
    assert Enrich.call(%{@raw | user_agent: "Mozilla/5.0 (iPad; CPU OS 17_0)"}).device == :tablet
  end

  test "the same visitor hashes identically, a different one does not" do
    a = Enrich.call(@raw).visitor_hash

    assert a == Enrich.call(@raw).visitor_hash
    refute a == Enrich.call(%{@raw | ip: "203.0.113.8"}).visitor_hash
    refute a == Enrich.call(%{@raw | user_agent: "curl/8"}).visitor_hash
  end

  test "country is nil when no geo database is loaded" do
    :persistent_term.erase({Qwynk.Analytics.Geo, :db})
    assert Enrich.call(@raw).country == nil
  end
end
