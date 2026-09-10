defmodule Qwynk.Fixtures do
  @moduledoc "Test fixtures. Kept deliberately thin — no factory library."

  def user_fixture(attrs \\ %{}) do
    email = Map.get(attrs, :email, "user#{System.unique_integer([:positive])}@example.com")

    Qwynk.Accounts.User
    |> Ash.Changeset.for_create(:register_with_password, %{
      email: email,
      password: "password1234",
      password_confirmation: "password1234"
    })
    |> Ash.create!(authorize?: false)
  end

  def link_fixture(user \\ nil, attrs \\ %{}) do
    user = user || user_fixture()
    attrs = Map.merge(%{destination: "https://example.com"}, attrs)
    {:ok, link} = Qwynk.Traffic.create_link(attrs, actor: user)
    link
  end
end
