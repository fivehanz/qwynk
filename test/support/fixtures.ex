defmodule Qwynk.Fixtures do
  @moduledoc "Test fixtures. Kept deliberately thin — no factory library."

  @doc """
  An ordinary account.

  The role is forced back to `:user` because the first account inside a test's
  sandbox transaction is always the first account *in the database*, so
  `BootstrapSuperadmin` would silently hand it superadmin and quietly defeat
  every owner-scoping assertion. `superadmin_fixture/1` is the explicit way up.
  """
  def user_fixture(attrs \\ %{}) do
    email = Map.get(attrs, :email, "user#{System.unique_integer([:positive])}@example.com")

    Qwynk.Accounts.User
    |> Ash.Changeset.for_create(:register_with_password, %{
      email: email,
      password: "password1234",
      password_confirmation: "password1234"
    })
    |> Ash.create!(authorize?: false)
    |> then(&Ash.Changeset.for_update(&1, :set_role, %{role: :user}))
    |> Ash.update!(authorize?: false)
  end

  @doc """
  Blocks until every dispatched analytics task has finished.

  Drains repeatedly rather than sampling once: the redirect returns before its
  task is spawned, so a single look at the supervisor's children can catch an
  empty list and flush too early.
  """
  def drain_analytics(attempts \\ 20) do
    drained? = drain_once()

    cond do
      attempts <= 0 -> :ok
      drained? -> drain_analytics(attempts - 1)
      true -> :ok
    end

    Qwynk.Analytics.Buffer.flush()
  end

  defp drain_once do
    case Task.Supervisor.children(Qwynk.TaskSupervisor) do
      [] ->
        # Give a just-returned request a moment to start its task.
        Process.sleep(5)
        Task.Supervisor.children(Qwynk.TaskSupervisor) != []

      pids ->
        Enum.each(pids, fn pid ->
          ref = Process.monitor(pid)

          receive do
            {:DOWN, ^ref, :process, ^pid, _} -> :ok
          after
            1000 -> Process.demonitor(ref, [:flush])
          end
        end)

        true
    end
  end

  @doc "Clears the application-wide buffer so tests do not leak events into each other."
  def reset_analytics, do: Qwynk.Analytics.Buffer.reset()

  def domain_fixture(attrs \\ %{}) do
    host = Map.get(attrs, :host, "d#{System.unique_integer([:positive])}.example")

    Qwynk.Traffic.create_domain!(Map.merge(attrs, %{host: host}), authorize?: false)
  end

  def link_fixture(user \\ nil, attrs \\ %{}) do
    user = user || user_fixture()
    {domain, attrs} = Map.pop_lazy(attrs, :domain, &domain_fixture/0)

    attrs =
      %{destination: "https://example.com", domain_id: domain.id}
      |> Map.merge(attrs)

    {:ok, link} = Qwynk.Traffic.create_link(attrs, actor: user)
    link
  end

  def superadmin_fixture(attrs \\ %{}) do
    user = user_fixture(attrs)

    user
    |> Ash.Changeset.for_update(:set_role, %{role: :superadmin})
    |> Ash.update!(authorize?: false)
  end
end
