defmodule Qwynk.Traffic.LinkTest do
  use Qwynk.DataCase, async: false

  import Qwynk.Fixtures

  alias Qwynk.Traffic
  alias Qwynk.Traffic.Cache

  setup do
    Cache.init()
    :ok
  end

  test "generates a goblin-speak slug when none is given" do
    user = user_fixture()
    {:ok, link} = Traffic.create_link(%{destination: "https://example.com"}, actor: user)

    assert link.slug =~ ~r/^[a-z]{3}-[a-z]{3}$/
    assert link.strategy == :temporary
    assert link.is_active
    assert link.owner_id == user.id
  end

  test "accepts an explicit slug" do
    user = user_fixture()

    {:ok, link} =
      Traffic.create_link(%{destination: "https://example.com", slug: "docs"}, actor: user)

    assert link.slug == "docs"
  end

  test "a caller-supplied duplicate slug errors rather than silently retrying" do
    user = user_fixture()

    {:ok, _} =
      Traffic.create_link(%{destination: "https://a.example", slug: "taken"}, actor: user)

    assert {:error, _} =
             Traffic.create_link(%{destination: "https://b.example", slug: "taken"}, actor: user)
  end

  test "generated slugs survive collisions" do
    user = user_fixture()

    slugs =
      for _ <- 1..40 do
        {:ok, link} = Traffic.create_link(%{destination: "https://example.com"}, actor: user)
        link.slug
      end

    assert length(Enum.uniq(slugs)) == 40
  end

  test "resolve returns only active links, and needs no actor" do
    user = user_fixture()
    {:ok, link} = Traffic.create_link(%{destination: "https://example.com"}, actor: user)

    assert {:ok, found} = Traffic.resolve(link.slug, authorize?: false)
    assert found.id == link.id

    {:ok, _} = Traffic.disable_link(link, actor: user)
    assert {:error, _} = Traffic.resolve(link.slug, authorize?: false)
  end

  test "links are owner-scoped by policy" do
    owner = user_fixture()
    stranger = user_fixture()
    {:ok, link} = Traffic.create_link(%{destination: "https://example.com"}, actor: owner)

    assert {:ok, _} = Traffic.get_link(link.id, actor: owner)
    assert {:error, _} = Traffic.get_link(link.id, actor: stranger)
  end

  test "updating a link evicts its cache entry" do
    user = user_fixture()
    {:ok, link} = Traffic.create_link(%{destination: "https://a.example"}, actor: user)
    Cache.put(link.slug, Cache.entry(link))

    {:ok, _} = Traffic.update_link(link, %{destination: "https://b.example"}, actor: user)
    assert Cache.fetch(link.slug) == :miss
  end

  test "disabling a link evicts its cache entry" do
    user = user_fixture()
    {:ok, link} = Traffic.create_link(%{destination: "https://a.example"}, actor: user)
    Cache.put(link.slug, Cache.entry(link))

    {:ok, _} = Traffic.disable_link(link, actor: user)
    assert Cache.fetch(link.slug) == :miss
  end

  test "destroying a link evicts its cache entry" do
    user = user_fixture()
    {:ok, link} = Traffic.create_link(%{destination: "https://a.example"}, actor: user)
    Cache.put(link.slug, Cache.entry(link))

    :ok = Traffic.destroy_link(link, actor: user)
    assert Cache.fetch(link.slug) == :miss
  end
end
