defmodule Mix.Tasks.Qwynk.GrantRole do
  @moduledoc """
  Grants a role to an account from the command line.

      mix qwynk.grant_role someone@example.com superadmin

  The escape hatch for an install that has no superadmin: the first account to
  register gets the role automatically, but an install that predates roles has
  several accounts and no way to tell which came first.
  """
  @shortdoc "Grants superadmin, admin or user to an account"

  use Mix.Task

  require Ash.Query

  @roles ~w(superadmin admin user)

  @impl Mix.Task
  def run([email, role]) when role in @roles do
    Mix.Task.run("app.start")

    user =
      Qwynk.Accounts.User
      |> Ash.Query.filter(email == ^email)
      |> Ash.read_one!(authorize?: false)

    case user do
      nil ->
        Mix.raise("No account with email #{email}")

      user ->
        user
        |> Ash.Changeset.for_update(:set_role, %{role: String.to_existing_atom(role)})
        |> Ash.update!(authorize?: false)

        Mix.shell().info("#{email} is now #{role}")
    end
  end

  def run(_args) do
    Mix.raise("Usage: mix qwynk.grant_role <email> <#{Enum.join(@roles, "|")}>")
  end
end
