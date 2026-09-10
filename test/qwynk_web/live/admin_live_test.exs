defmodule QwynkWeb.AdminLiveTest do
  use QwynkWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import Qwynk.Fixtures

  alias Qwynk.Traffic.Cache

  setup do
    Cache.init()
    Cache.flush()
    :ok
  end

  defp sign_in(conn, user) do
    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> AshAuthentication.Plug.Helpers.store_in_session(user)
  end

  describe "access" do
    test "an anonymous visitor is sent to sign-in", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/_/sign-in"}}} = live(conn, ~p"/_/admin")
    end

    test "an ordinary user is sent back to their own dashboard", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/_/app"}}} =
               conn |> sign_in(user_fixture()) |> live(~p"/_/admin")
    end

    test "the console link is hidden from ordinary users", %{conn: conn} do
      domain_fixture()
      {:ok, _view, html} = conn |> sign_in(user_fixture()) |> live(~p"/_/app/links")

      refute html =~ "Console"
    end

    test "a superadmin sees the console link", %{conn: conn} do
      domain_fixture()
      {:ok, _view, html} = conn |> sign_in(superadmin_fixture()) |> live(~p"/_/app/links")

      assert html =~ "Console"
    end
  end

  describe "domains" do
    test "lists domains with their root behaviour and link counts", %{conn: conn} do
      domain_fixture(%{host: "acme.test"})
      redirecting = domain_fixture(%{host: "beta.test", root_url: "https://beta.example"})

      {:ok, _view, html} = conn |> sign_in(superadmin_fixture()) |> live(~p"/_/admin")

      assert html =~ "acme.test"
      assert html =~ "404"
      assert html =~ redirecting.root_url
    end

    test "adding a domain normalizes what was pasted", %{conn: conn} do
      {:ok, view, _html} = conn |> sign_in(superadmin_fixture()) |> live(~p"/_/admin")

      view |> element("button", "Add domain") |> render_click()

      html =
        view
        |> form("form[phx-submit=save]", form: %{host: "HTTPS://Links.Acme.com/", root_url: ""})
        |> render_submit()

      assert html =~ "links.acme.com"
    end

    test "deactivating a domain evicts its cached links", %{conn: conn} do
      domain = domain_fixture(%{host: "acme.test"})
      link = link_fixture(user_fixture(), %{domain: domain})
      Cache.put("acme.test", link.slug, Cache.entry(link))

      {:ok, view, _html} = conn |> sign_in(superadmin_fixture()) |> live(~p"/_/admin")

      view
      |> element("button[phx-value-id='#{domain.id}'][phx-click=toggle-active]")
      |> render_click()

      assert Cache.fetch("acme.test", link.slug) == :miss
    end

    test "a domain with links offers no delete control", %{conn: conn} do
      domain = domain_fixture(%{host: "acme.test"})
      link_fixture(user_fixture(), %{domain: domain})

      {:ok, view, _html} = conn |> sign_in(superadmin_fixture()) |> live(~p"/_/admin")

      refute has_element?(view, "button[phx-value-id='#{domain.id}'][phx-click=delete]")
    end
  end

  describe "users" do
    test "a superadmin can change someone else's role", %{conn: conn} do
      boss = superadmin_fixture()
      user = user_fixture()

      {:ok, view, _html} = conn |> sign_in(boss) |> live(~p"/_/admin/users")

      view
      |> form("form[phx-change=set-role]", %{user_id: user.id, role: "admin"})
      |> render_change()

      assert Ash.get!(Qwynk.Accounts.User, user.id, authorize?: false).role == :admin
    end

    test "the superadmin's own row has no role control", %{conn: conn} do
      boss = superadmin_fixture()

      {:ok, view, html} = conn |> sign_in(boss) |> live(~p"/_/admin/users")

      assert html =~ "you"
      refute has_element?(view, "select#role-#{boss.id}")
    end
  end

  describe "links without a domain" do
    test "the list explains there is nowhere to put one", %{conn: conn} do
      {:ok, _view, html} = conn |> sign_in(user_fixture()) |> live(~p"/_/app/links")

      assert html =~ "nowhere to put a link"
      assert html =~ "Ask an administrator"
      refute html =~ "New link"
    end

    test "a superadmin is pointed at the console instead", %{conn: conn} do
      {:ok, _view, html} = conn |> sign_in(superadmin_fixture()) |> live(~p"/_/app/links")

      assert html =~ "Add one in the console"
    end
  end
end
