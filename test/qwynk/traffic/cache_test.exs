defmodule Qwynk.Traffic.CacheTest do
  use ExUnit.Case, async: false

  alias Qwynk.Traffic.Cache

  setup do
    Cache.init()
    Cache.flush()
    Cache.delete("a.example", "zip-zap")
    :ok
  end

  defp entry,
    do: %{link_id: Ecto.UUID.generate(), destination: "https://example.com", strategy: :temporary}

  test "an unknown slug is a miss" do
    assert Cache.fetch("a.example", "zip-zap") == :miss
  end

  test "a stored slug is a hit carrying link_id" do
    e = entry()
    Cache.put("a.example", "zip-zap", e)
    assert {:hit, ^e} = Cache.fetch("a.example", "zip-zap")
    assert is_binary(e.link_id)
  end

  test "delete evicts" do
    Cache.put("a.example", "zip-zap", entry())
    Cache.delete("a.example", "zip-zap")
    assert Cache.fetch("a.example", "zip-zap") == :miss
  end

  test "an expired entry reads as a miss and is evicted" do
    Cache.put("a.example", "zip-zap", entry(), -1)
    assert Cache.fetch("a.example", "zip-zap") == :miss
    assert :ets.lookup(:qwynk_cache, {"a.example", "zip-zap"}) == []
  end

  test "the same slug on two hosts is two different entries" do
    a = entry()
    b = entry()
    Cache.put("a.example", "zip-zap", a)
    Cache.put("b.example", "zip-zap", b)

    assert Cache.fetch("a.example", "zip-zap") == {:hit, a}
    assert Cache.fetch("b.example", "zip-zap") == {:hit, b}
    refute a == b
  end

  test "delete_domain evicts one host and leaves the others" do
    Cache.put("a.example", "zip-zap", entry())
    Cache.put("a.example", "mip-tok", entry())
    Cache.put("b.example", "zip-zap", entry())

    Cache.delete_domain("a.example")

    assert Cache.fetch("a.example", "zip-zap") == :miss
    assert Cache.fetch("a.example", "mip-tok") == :miss
    assert {:hit, _} = Cache.fetch("b.example", "zip-zap")
  end

  test "entry/1 projects a link to the cached shape" do
    link = %{
      id: Ecto.UUID.generate(),
      destination: "https://e.example",
      strategy: :permanent,
      slug: "a-b"
    }

    assert Cache.entry(link) == %{
             link_id: link.id,
             destination: "https://e.example",
             strategy: :permanent
           }
  end
end
