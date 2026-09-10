defmodule QwynkWeb.LinkLiveTest do
  use QwynkWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import Qwynk.Fixtures

  alias Qwynk.Traffic.Cache

  setup do
    Cache.init()
    Cache.flush()
    reset_analytics()
    %{domain: domain_fixture(%{host: "acme.test"})}
  end

  # The slug input's value attribute, or nil when it is empty.
  defp slug_value(html) do
    case Regex.run(~r/<input[^>]*name="form\[slug\]"[^>]*value="([^"]+)"/, html) do
      [_, value] -> value
      nil -> nil
    end
  end

  defp sign_in(conn, user) do
    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> AshAuthentication.Plug.Helpers.store_in_session(user)
  end

  test "an anonymous visitor is redirected to sign-in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/_/sign-in"}}} = live(conn, ~p"/_/app/links")
  end

  test "the list shows only the signed-in user's links", %{conn: conn, domain: domain} do
    user = user_fixture()

    mine =
      link_fixture(user, %{domain: domain, slug: "mine-aa", destination: "https://mine.example"})

    theirs =
      link_fixture(nil, %{
        domain: domain,
        slug: "theirs-bb",
        destination: "https://theirs.example"
      })

    {:ok, _view, html} = conn |> sign_in(user) |> live(~p"/_/app/links")

    assert html =~ mine.slug
    refute html =~ theirs.slug
  end

  test "creating a link with a blank slug generates one", %{conn: conn, domain: domain} do
    user = user_fixture()
    {:ok, view, _html} = conn |> sign_in(user) |> live(~p"/_/app/links")

    view |> element("button", "New link") |> render_click()

    html =
      view
      |> form("form[phx-submit=save]",
        form: %{destination: "https://generated.example", slug: ""}
      )
      |> render_submit()

    assert html =~ "https://generated.example"
    [link] = Qwynk.Traffic.list_links!(actor: user)
    assert link.slug =~ ~r/^[a-z]{3}-[a-z]{3}$/
    # The domain select's preselected value is what the form submits.
    assert link.domain_id == domain.id
  end

  test "generate fills the slug field and can be rolled again", %{conn: conn} do
    user = user_fixture()
    {:ok, view, _html} = conn |> sign_in(user) |> live(~p"/_/app/links")

    view |> element("button", "New link") |> render_click()

    # The form opens showing the slug it would assign, rather than a placeholder.
    initial = slug_value(render(view))
    assert initial =~ ~r/^[a-z]{3}-[a-z]{3}$/

    first = view |> element("button[phx-click=suggest]") |> render_click() |> slug_value()
    assert first =~ ~r/^[a-z]{3}-[a-z]{3}$/
    refute first == initial

    second = view |> element("button[phx-click=suggest]") |> render_click() |> slug_value()
    assert second =~ ~r/^[a-z]{3}-[a-z]{3}$/
    refute first == second
  end

  test "the URL prefix follows the domain select", %{conn: conn, domain: domain} do
    other = domain_fixture(%{host: "zeta.test"})
    user = user_fixture()

    {:ok, view, _html} = conn |> sign_in(user) |> live(~p"/_/app/links")
    view |> element("button", "New link") |> render_click()

    assert render(view) =~ domain.host

    html =
      view
      |> form("form[phx-submit=save]", form: %{domain_id: other.id})
      |> render_change()

    assert html =~ "#{other.host}/"
  end

  test "generate keeps what was already typed", %{conn: conn} do
    user = user_fixture()
    {:ok, view, _html} = conn |> sign_in(user) |> live(~p"/_/app/links")

    view |> element("button", "New link") |> render_click()

    view
    |> form("form[phx-submit=save]", form: %{destination: "https://kept.example"})
    |> render_change()

    html = view |> element("button[phx-click=suggest]") |> render_click()

    assert slug_value(html)
    assert html =~ "https://kept.example"
  end

  test "a generated slug is what actually gets saved", %{conn: conn, domain: domain} do
    user = user_fixture()
    {:ok, view, _html} = conn |> sign_in(user) |> live(~p"/_/app/links")

    view |> element("button", "New link") |> render_click()
    generated = view |> element("button[phx-click=suggest]") |> render_click() |> slug_value()

    view
    |> form("form[phx-submit=save]",
      form: %{destination: "https://saved.example", slug: generated, domain_id: domain.id}
    )
    |> render_submit()

    assert [link] = Qwynk.Traffic.list_links!(actor: user)
    assert link.slug == generated
  end

  test "editing an existing link offers no generate control", %{conn: conn, domain: domain} do
    user = user_fixture()
    link = link_fixture(user, %{domain: domain})

    {:ok, view, _html} = conn |> sign_in(user) |> live(~p"/_/app/links")
    view |> element("button[phx-click=edit][phx-value-id='#{link.id}']") |> render_click()

    refute has_element?(view, "button[phx-click=suggest]")
  end

  test "disabling a link updates the row in place", %{conn: conn} do
    user = user_fixture()
    link = link_fixture(user)

    {:ok, view, _html} = conn |> sign_in(user) |> live(~p"/_/app/links")

    html =
      view
      |> element("button[phx-value-id='#{link.id}'][phx-click=toggle-active]")
      |> render_click()

    assert html =~ "disabled"
    assert Qwynk.Traffic.get_link!(link.id, actor: user).is_active == false
  end

  test "search filters by slug and destination", %{conn: conn, domain: domain} do
    user = user_fixture()
    link_fixture(user, %{domain: domain, slug: "alpha-aa", destination: "https://alpha.example"})
    link_fixture(user, %{domain: domain, slug: "beta-bb", destination: "https://beta.example"})

    {:ok, view, _html} = conn |> sign_in(user) |> live(~p"/_/app/links")

    html = view |> form("form[phx-change=search]", query: "alpha") |> render_change()

    assert html =~ "alpha-aa"
    refute html =~ "beta-bb"
  end

  test "the detail page renders stats and the chart", %{conn: conn, domain: domain} do
    user = user_fixture()
    link = link_fixture(user, %{domain: domain})

    {:ok, _view, html} = conn |> sign_in(user) |> live(~p"/_/app/links/#{link.id}")

    assert html =~ link.slug
    assert html =~ "Clicks · 30d"
    assert html =~ "<svg"
    assert html =~ "No traffic in this window"
  end

  test "a foreign link is not reachable by id", %{conn: conn} do
    user = user_fixture()
    theirs = link_fixture()

    # The policy, not the LiveView, is what stops this.
    assert {:error, _} = Qwynk.Traffic.get_link(theirs.id, actor: user)

    assert catch_error(conn |> sign_in(user) |> live(~p"/_/app/links/#{theirs.id}"))
  end

  test "settings shows the account and the privacy stance", %{conn: conn} do
    user = user_fixture()

    {:ok, _view, html} = conn |> sign_in(user) |> live(~p"/_/app/settings")

    assert html =~ to_string(user.email)
    assert html =~ "no raw IP addresses"
  end

  test "the dashboard shows totals", %{conn: conn} do
    user = user_fixture()
    link_fixture(user)

    {:ok, _view, html} = conn |> sign_in(user) |> live(~p"/_/app")

    assert html =~ "Dashboard"
    assert html =~ "Clicks · 30d"
  end
end
