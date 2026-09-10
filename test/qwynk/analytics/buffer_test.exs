defmodule Qwynk.Analytics.BufferTest do
  use Qwynk.DataCase, async: false

  import Qwynk.Fixtures

  alias Qwynk.Analytics.Buffer

  setup do
    pid =
      start_supervised!(
        {Buffer, flush_interval: :infinity, max_size: 5, flush_at: 3, name: :test_buffer}
      )

    %{buffer: pid, link: link_fixture()}
  end

  defp event(link) do
    %{
      link_id: link.id,
      timestamp: DateTime.utc_now() |> DateTime.truncate(:second),
      visitor_hash: String.duplicate("a", 64),
      country: "US",
      device: :mobile,
      referrer_domain: "example.com"
    }
  end

  test "flushes to postgres at the size threshold", %{link: link} do
    for _ <- 1..3, do: Buffer.record(event(link), :test_buffer)
    Buffer.flush(:test_buffer)

    assert length(Qwynk.Analytics.list_hits!(authorize?: false)) == 3
    assert Buffer.stats(:test_buffer).buffered == 0
  end

  test "an explicit flush persists what is buffered", %{link: link} do
    Buffer.record(event(link), :test_buffer)
    Buffer.flush(:test_buffer)

    assert length(Qwynk.Analytics.list_hits!(authorize?: false)) == 1
  end

  test "drops events past max_size rather than growing", %{link: link} do
    # flush_at above max_size, so nothing drains and the bound bites.
    start_supervised!(
      {Buffer, flush_interval: :infinity, max_size: 5, flush_at: 999, name: :bound_buffer},
      id: :bound_buffer
    )

    for _ <- 1..40, do: Buffer.record(event(link), :bound_buffer)

    stats = Buffer.stats(:bound_buffer)
    assert stats.buffered == 5
    assert stats.dropped == 35
  end

  test "rejected rows are dropped and counted, not retried forever", %{link: link} do
    orphan = %{event(link) | link_id: Ecto.UUID.generate()}
    Buffer.record(orphan, :test_buffer)
    Buffer.flush(:test_buffer)

    stats = Buffer.stats(:test_buffer)
    assert stats.buffered == 0
    assert stats.rejected == 1
    assert Qwynk.Analytics.list_hits!(authorize?: false) == []
  end

  test "one bad row does not block later good ones", %{link: link} do
    Buffer.record(%{event(link) | link_id: Ecto.UUID.generate()}, :test_buffer)
    Buffer.flush(:test_buffer)

    Buffer.record(event(link), :test_buffer)
    Buffer.flush(:test_buffer)

    assert length(Qwynk.Analytics.list_hits!(authorize?: false)) == 1
  end

  test "stats starts empty" do
    assert Buffer.stats(:test_buffer) == %{buffered: 0, dropped: 0, rejected: 0}
  end
end
