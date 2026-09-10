defmodule Qwynk.Accounts.RolesTest do
  use Qwynk.DataCase, async: false

  import Qwynk.Fixtures

  alias Qwynk.Accounts.User

  describe "bootstrap" do
    test "the very first account becomes superadmin" do
      first =
        User
        |> Ash.Changeset.for_create(:register_with_password, %{
          email: "first@example.com",
          password: "password1234",
          password_confirmation: "password1234"
        })
        |> Ash.create!(authorize?: false)

      assert first.role == :superadmin
    end

    test "every account after the first is an ordinary user" do
      User
      |> Ash.Changeset.for_create(:register_with_password, %{
        email: "first@example.com",
        password: "password1234",
        password_confirmation: "password1234"
      })
      |> Ash.create!(authorize?: false)

      second =
        User
        |> Ash.Changeset.for_create(:register_with_password, %{
          email: "second@example.com",
          password: "password1234",
          password_confirmation: "password1234"
        })
        |> Ash.create!(authorize?: false)

      assert second.role == :user
    end
  end

  describe "set_role" do
    test "a superadmin can promote someone else" do
      boss = superadmin_fixture()
      user = user_fixture()

      assert {:ok, updated} =
               user
               |> Ash.Changeset.for_update(:set_role, %{role: :admin}, actor: boss)
               |> Ash.update()

      assert updated.role == :admin
    end

    test "nobody may change their own role, superadmin included" do
      boss = superadmin_fixture()

      assert {:error, error} =
               boss
               |> Ash.Changeset.for_update(:set_role, %{role: :user}, actor: boss)
               |> Ash.update()

      assert Exception.message(error) =~ "your own role"
    end

    test "an ordinary user cannot promote anyone" do
      user = user_fixture()
      other = user_fixture()

      assert {:error, %Ash.Error.Forbidden{}} =
               other
               |> Ash.Changeset.for_update(:set_role, %{role: :superadmin}, actor: user)
               |> Ash.update()
    end

    test "an admin cannot promote anyone either" do
      admin = user_fixture()

      admin =
        admin
        |> Ash.Changeset.for_update(:set_role, %{role: :admin})
        |> Ash.update!(authorize?: false)

      other = user_fixture()

      assert {:error, %Ash.Error.Forbidden{}} =
               other
               |> Ash.Changeset.for_update(:set_role, %{role: :superadmin}, actor: admin)
               |> Ash.update()
    end
  end

  describe "domain policies" do
    test "anyone signed in may read domains — hostnames are public DNS" do
      domain = domain_fixture()
      user = user_fixture()

      assert {:ok, _} = Qwynk.Traffic.get_domain(domain.id, actor: user)
    end

    test "only a superadmin may create one" do
      user = user_fixture()

      assert {:error, %Ash.Error.Forbidden{}} =
               Qwynk.Traffic.create_domain(%{host: "nope.example"}, actor: user)

      assert {:ok, _} =
               Qwynk.Traffic.create_domain(%{host: "yes.example"}, actor: superadmin_fixture())
    end

    test "a domain holding links refuses deletion and points at deactivation" do
      domain = domain_fixture()
      boss = superadmin_fixture()
      link_fixture(user_fixture(), %{domain: domain})

      assert {:error, error} = Qwynk.Traffic.destroy_domain(domain, actor: boss)
      assert Exception.message(error) =~ "deactivate"
    end

    test "an empty domain can be deleted" do
      domain = domain_fixture()
      boss = superadmin_fixture()

      assert :ok = Qwynk.Traffic.destroy_domain(domain, actor: boss)
    end

    test "the host is normalized to something a Host header can match" do
      boss = superadmin_fixture()

      {:ok, domain} =
        Qwynk.Traffic.create_domain(%{host: "  HTTPS://Links.Acme.com:8080/x  "}, actor: boss)

      assert domain.host == "links.acme.com"
    end
  end
end
