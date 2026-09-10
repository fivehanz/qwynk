defmodule Qwynk.Traffic.LinkTest do
  use Qwynk.DataCase, async: false

  import Qwynk.Fixtures

  alias Qwynk.Traffic
  alias Qwynk.Traffic.Cache

  setup do
    Cache.init()
    Cache.flush()
    %{domain: domain_fixture(%{host: "primary.example"})}
  end

  defp attrs(domain, extra \\ %{}),
    do: Map.merge(%{destination: "https://example.com", domain_id: domain.id}, extra)

  test "generates a goblin-speak slug when none is given", %{domain: domain} do
    user = user_fixture()
    {:ok, link} = Traffic.create_link(attrs(domain), actor: user)

    assert link.slug =~ ~r/^[a-z]{3}-[a-z]{3}$/
    assert link.strategy == :temporary
    assert link.is_active
    assert link.owner_id == user.id
  end

  test "accepts an explicit slug", %{domain: domain} do
    user = user_fixture()

    {:ok, link} = Traffic.create_link(attrs(domain, %{slug: "docs"}), actor: user)

    assert link.slug == "docs"
    assert link.domain_id == domain.id
  end

  test "the same slug is free on a different domain", %{domain: domain} do
    other = domain_fixture(%{host: "other.example"})
    user = user_fixture()

    assert {:ok, mine} = Traffic.create_link(attrs(domain, %{slug: "launch"}), actor: user)

    assert {:ok, theirs} =
             Traffic.create_link(
               attrs(other, %{slug: "launch", destination: "https://other.example/x"}),
               actor: user
             )

    assert mine.slug == theirs.slug
    refute mine.id == theirs.id
  end

  test "resolve is scoped to its domain", %{domain: domain} do
    other = domain_fixture(%{host: "other.example"})
    user = user_fixture()
    {:ok, link} = Traffic.create_link(attrs(domain, %{slug: "launch"}), actor: user)

    assert {:ok, found} = Traffic.resolve("launch", domain.id, authorize?: false)
    assert found.id == link.id
    assert {:error, _} = Traffic.resolve("launch", other.id, authorize?: false)
  end

  test "a caller-supplied duplicate slug errors rather than silently retrying", %{domain: domain} do
    user = user_fixture()

    {:ok, _} = Traffic.create_link(attrs(domain, %{slug: "taken"}), actor: user)

    assert {:error, _} = Traffic.create_link(attrs(domain, %{slug: "taken"}), actor: user)
  end

  test "generated slugs survive collisions", %{domain: domain} do
    user = user_fixture()

    slugs =
      for _ <- 1..40 do
        {:ok, link} = Traffic.create_link(attrs(domain), actor: user)
        link.slug
      end

    assert length(Enum.uniq(slugs)) == 40
  end

  test "resolve returns only active links, and needs no actor", %{domain: domain} do
    user = user_fixture()
    {:ok, link} = Traffic.create_link(attrs(domain), actor: user)

    assert {:ok, found} = Traffic.resolve(link.slug, domain.id, authorize?: false)
    assert found.id == link.id

    {:ok, _} = Traffic.disable_link(link, actor: user)
    assert {:error, _} = Traffic.resolve(link.slug, domain.id, authorize?: false)
  end

  test "links are owner-scoped by policy", %{domain: domain} do
    owner = user_fixture()
    stranger = user_fixture()
    {:ok, link} = Traffic.create_link(attrs(domain), actor: owner)

    assert {:ok, _} = Traffic.get_link(link.id, actor: owner)
    assert {:error, _} = Traffic.get_link(link.id, actor: stranger)
  end

  test "staff see every link, regardless of owner", %{domain: domain} do
    owner = user_fixture()
    admin = superadmin_fixture()
    {:ok, link} = Traffic.create_link(attrs(domain), actor: owner)

    assert {:ok, _} = Traffic.get_link(link.id, actor: admin)
  end

  test "updating a link evicts its cache entry", %{domain: domain} do
    user = user_fixture()

    {:ok, link} =
      Traffic.create_link(attrs(domain, %{destination: "https://a.example"}), actor: user)

    Cache.put(domain.host, link.slug, Cache.entry(link))

    {:ok, _} = Traffic.update_link(link, %{destination: "https://b.example"}, actor: user)
    assert Cache.fetch(domain.host, link.slug) == :miss
  end

  test "disabling a link evicts its cache entry", %{domain: domain} do
    user = user_fixture()

    {:ok, link} =
      Traffic.create_link(attrs(domain, %{destination: "https://a.example"}), actor: user)

    Cache.put(domain.host, link.slug, Cache.entry(link))

    {:ok, _} = Traffic.disable_link(link, actor: user)
    assert Cache.fetch(domain.host, link.slug) == :miss
  end

  test "destroying a link evicts its cache entry", %{domain: domain} do
    user = user_fixture()

    {:ok, link} =
      Traffic.create_link(attrs(domain, %{destination: "https://a.example"}), actor: user)

    Cache.put(domain.host, link.slug, Cache.entry(link))

    :ok = Traffic.destroy_link(link, actor: user)
    assert Cache.fetch(domain.host, link.slug) == :miss
  end
end
