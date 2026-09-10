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

  @doc "Blocks until every dispatched analytics task has finished."
  def drain_analytics do
    Qwynk.TaskSupervisor
    |> Task.Supervisor.children()
    |> Enum.each(fn pid ->
      ref = Process.monitor(pid)

      receive do
        {:DOWN, ^ref, :process, ^pid, _} -> :ok
      after
        1000 -> :ok
      end
    end)

    Qwynk.Analytics.Buffer.flush()
  end

  @doc "Clears the application-wide buffer so tests do not leak events into each other."
  def reset_analytics, do: Qwynk.Analytics.Buffer.reset()

  def link_fixture(user \\ nil, attrs \\ %{}) do
    user = user || user_fixture()
    attrs = Map.merge(%{destination: "https://example.com"}, attrs)
    {:ok, link} = Qwynk.Traffic.create_link(attrs, actor: user)
    link
  end
end
