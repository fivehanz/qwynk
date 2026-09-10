defmodule QwynkWeb.NamespaceTest do
  use QwynkWeb.ConnCase, async: true

  test "sign-in lives under the reserved namespace", %{conn: conn} do
    assert html_response(get(conn, ~p"/_/sign-in"), 200)
  end

  test "register and reset are prefixed exactly once", %{conn: conn} do
    assert html_response(get(conn, "/_/register"), 200)
    assert html_response(get(conn, "/_/reset"), 200)
    assert_error_sent 404, fn -> get(conn, "/_/_/register") end
  end

  test "the root namespace does not serve auth routes", %{conn: conn} do
    assert_error_sent 404, fn -> get(conn, "/sign-in") end
  end
end
