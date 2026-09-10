defmodule QwynkWeb.PageControllerTest do
  use QwynkWeb.ConnCase

  test "GET / sends you into the app", %{conn: conn} do
    assert redirected_to(get(conn, ~p"/")) == "/_/app"
  end
end
