defmodule QwynkWeb.NamespaceTest do
  use QwynkWeb.ConnCase, async: true

  test "sign-in lives under the reserved namespace", %{conn: conn} do
    assert html_response(get(conn, ~p"/_/sign-in"), 200)
  end

  test "register and reset are prefixed exactly once", %{conn: conn} do
    assert html_response(get(conn, "/_/register"), 200)
    assert html_response(get(conn, "/_/reset"), 200)
    assert get(conn, "/_/_/register").status == 404
  end

  test "the root namespace does not serve auth routes", %{conn: conn} do
    assert get(conn, "/sign-in").status == 404
  end
end
