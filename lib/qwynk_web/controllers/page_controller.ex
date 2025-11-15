defmodule QwynkWeb.PageController do
  use QwynkWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
