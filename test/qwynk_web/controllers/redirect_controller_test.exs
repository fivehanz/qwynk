defmodule QwynkWeb.RedirectControllerTest do
  use QwynkWeb.ConnCase, async: false

  import Qwynk.Fixtures

  alias Qwynk.Traffic.Cache

  setup do
    Cache.init()
    Cache.flush()
    reset_analytics()
    user = user_fixture()
    domain = domain_fixture(%{host: "acme.test"})
    link = link_fixture(user, %{domain: domain})
    %{user: user, domain: domain, link: link}
  end

  # The Host header is what selects the domain, so every request has to carry one.
  defp on_host(conn, host), do: %{conn | host: host}

  test "a cold request misses the cache and redirects 302", %{conn: conn, link: link} do
    conn = conn |> on_host("acme.test") |> get("/#{link.slug}")

    assert redirected_to(conn, 302) == "https://example.com"
    assert get_resp_header(conn, "x-qwynk-cache") == ["miss"]
  end

  test "the second request is served from cache", %{conn: conn, link: link} do
    conn |> on_host("acme.test") |> get("/#{link.slug}")
    conn = build_conn() |> on_host("acme.test") |> get("/#{link.slug}")

    assert redirected_to(conn, 302) == "https://example.com"
    assert get_resp_header(conn, "x-qwynk-cache") == ["hit"]
  end

  test "the permanent strategy redirects 301", %{conn: conn, user: user, domain: domain} do
    link =
      link_fixture(user, %{
        domain: domain,
        destination: "https://p.example",
        strategy: :permanent
      })

    conn = conn |> on_host("acme.test") |> get("/#{link.slug}")
    assert redirected_to(conn, 301) == "https://p.example"
  end

  test "the same slug on another domain resolves elsewhere", %{conn: conn, user: user} do
    other = domain_fixture(%{host: "beta.test"})
    acme = link_fixture(user, %{domain: domain_by_host("acme.test"), slug: "launch"})

    _beta =
      link_fixture(user, %{domain: other, slug: "launch", destination: "https://beta.example"})

    assert redirected_to(conn |> on_host("acme.test") |> get("/launch"), 302) == acme.destination

    assert redirected_to(build_conn() |> on_host("beta.test") |> get("/launch"), 302) ==
             "https://beta.example"
  end

  test "a slug does not leak across domains", %{conn: conn, link: link} do
    domain_fixture(%{host: "beta.test"})

    assert conn |> on_host("beta.test") |> get("/#{link.slug}") |> Map.fetch!(:status) == 404
  end

  test "an unknown host 404s rather than erroring", %{conn: conn, link: link} do
    assert conn |> on_host("nobody.test") |> get("/#{link.slug}") |> Map.fetch!(:status) == 404
  end

  test "a deactivated domain stops resolving", %{conn: conn, domain: domain, link: link} do
    {:ok, _} = Qwynk.Traffic.update_domain(domain, %{is_active: false}, authorize?: false)

    assert conn |> on_host("acme.test") |> get("/#{link.slug}") |> Map.fetch!(:status) == 404
  end

  test "a disabled link stops redirecting", %{conn: conn, user: user, link: link} do
    {:ok, _} = Qwynk.Traffic.disable_link(link, actor: user)

    assert conn |> on_host("acme.test") |> get("/#{link.slug}") |> Map.fetch!(:status) == 404
  end

  test "an unknown slug 404s and caches nothing", %{conn: conn} do
    conn = conn |> on_host("acme.test") |> get("/nope-nope")

    assert conn.status == 404
    assert Cache.fetch("acme.test", "nope-nope") == :miss
  end

  test "the redirect path drops no cookies", %{conn: conn, link: link} do
    conn = conn |> on_host("acme.test") |> get("/#{link.slug}")

    assert get_resp_header(conn, "set-cookie") == []
  end

  describe "the root path" do
    test "404s by default rather than advertising the admin", %{conn: conn} do
      conn = conn |> on_host("acme.test") |> get("/")

      assert conn.status == 404
      assert get_resp_header(conn, "location") == []
    end

    test "redirects when a root_url is configured", %{conn: conn, domain: domain} do
      {:ok, _} =
        Qwynk.Traffic.update_domain(domain, %{root_url: "https://acme.example"},
          authorize?: false
        )

      conn = conn |> on_host("acme.test") |> get("/")

      assert redirected_to(conn, 302) == "https://acme.example"
      assert get_resp_header(conn, "set-cookie") == []
    end

    test "404s on a host nobody configured", %{conn: conn} do
      assert conn |> on_host("nobody.test") |> get("/") |> Map.fetch!(:status) == 404
    end
  end

  test "the reserved namespace still works on any host", %{conn: conn} do
    assert html_response(conn |> on_host("acme.test") |> get("/_/sign-in"), 200)
  end

  test "a redirect logs exactly one hit carrying the cached link_id", %{conn: conn, link: link} do
    conn |> on_host("acme.test") |> get("/#{link.slug}")
    drain_analytics()

    assert [hit] = Qwynk.Analytics.list_hits!(authorize?: false)
    assert hit.link_id == link.id
    assert hit.visitor_hash != nil
  end

  test "a cache hit still logs, and logs no PII", %{conn: conn, link: link} do
    conn |> on_host("acme.test") |> get("/#{link.slug}")

    build_conn()
    |> on_host("acme.test")
    |> put_req_header("referer", "https://news.example.com/x?secret=1")
    |> get("/#{link.slug}")

    drain_analytics()

    hits = Qwynk.Analytics.list_hits!(authorize?: false)
    assert length(hits) == 2
    assert "news.example.com" in Enum.map(hits, & &1.referrer_domain)
    refute Enum.any?(hits, &(&1.referrer_domain && &1.referrer_domain =~ "secret"))
  end

  test "a 404 logs nothing", %{conn: conn} do
    conn |> on_host("acme.test") |> get("/nope-nope")
    drain_analytics()

    assert Qwynk.Analytics.list_hits!(authorize?: false) == []
  end

  defp domain_by_host(host) do
    {:ok, domain} = Qwynk.Traffic.domain_by_host(host, authorize?: false)
    domain
  end
end
