defmodule QwynkWeb.RedirectControllerTest do
  use QwynkWeb.ConnCase, async: false

  import Qwynk.Fixtures

  alias Qwynk.Traffic.Cache

  setup do
    Cache.init()
    user = user_fixture()
    link = link_fixture(user)
    Cache.delete(link.slug)
    %{user: user, link: link}
  end

  test "a cold request misses the cache and redirects 302", %{conn: conn, link: link} do
    conn = get(conn, "/#{link.slug}")

    assert redirected_to(conn, 302) == "https://example.com"
    assert get_resp_header(conn, "x-qwynk-cache") == ["miss"]
  end

  test "the second request is served from cache", %{conn: conn, link: link} do
    get(conn, "/#{link.slug}")
    conn = get(build_conn(), "/#{link.slug}")

    assert redirected_to(conn, 302) == "https://example.com"
    assert get_resp_header(conn, "x-qwynk-cache") == ["hit"]
  end

  test "the permanent strategy redirects 301", %{conn: conn, user: user} do
    link = link_fixture(user, %{destination: "https://p.example", strategy: :permanent})

    assert redirected_to(get(conn, "/#{link.slug}"), 301) == "https://p.example"
  end

  test "a disabled link stops redirecting", %{conn: conn, user: user, link: link} do
    {:ok, _} = Qwynk.Traffic.disable_link(link, actor: user)

    assert get(conn, "/#{link.slug}").status == 404
  end

  test "an unknown slug 404s and caches nothing", %{conn: conn} do
    conn = get(conn, "/nope-nope")

    assert conn.status == 404
    assert Cache.fetch("nope-nope") == :miss
  end

  test "the redirect path drops no cookies", %{conn: conn, link: link} do
    conn = get(conn, "/#{link.slug}")

    assert get_resp_header(conn, "set-cookie") == []
  end

  test "the redirect route does not shadow the reserved namespace", %{conn: conn} do
    assert html_response(get(conn, "/_/sign-in"), 200)
  end
end
