defmodule Qwynk.Traffic.CacheTest do
  use ExUnit.Case, async: false

  alias Qwynk.Traffic.Cache

  setup do
    Cache.init()
    Cache.delete("zip-zap")
    :ok
  end

  defp entry,
    do: %{link_id: Ecto.UUID.generate(), destination: "https://example.com", strategy: :temporary}

  test "an unknown slug is a miss" do
    assert Cache.fetch("zip-zap") == :miss
  end

  test "a stored slug is a hit carrying link_id" do
    e = entry()
    Cache.put("zip-zap", e)
    assert {:hit, ^e} = Cache.fetch("zip-zap")
    assert is_binary(e.link_id)
  end

  test "delete evicts" do
    Cache.put("zip-zap", entry())
    Cache.delete("zip-zap")
    assert Cache.fetch("zip-zap") == :miss
  end

  test "an expired entry reads as a miss and is evicted" do
    Cache.put("zip-zap", entry(), -1)
    assert Cache.fetch("zip-zap") == :miss
    assert :ets.lookup(:qwynk_cache, "zip-zap") == []
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
