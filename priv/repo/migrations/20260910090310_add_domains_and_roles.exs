defmodule Qwynk.Repo.Migrations.AddDomainsAndRoles do
  @moduledoc """
  Adds domains, scopes links to them, and adds user roles.

  Hand-edited from the generated version, which added `links.domain_id` as
  NOT NULL with no default and would fail on any database holding links. The
  column is added nullable, backfilled to a domain derived from PHX_HOST, and
  only then constrained.
  """

  use Ecto.Migration

  def up do
    create table(:domains, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :host, :text, null: false
      add :root_url, :text
      add :is_active, :boolean, null: false, default: true

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create unique_index(:domains, [:host], name: "domains_unique_host_index")

    alter table(:links) do
      add :domain_id,
          references(:domains,
            column: :id,
            name: "links_domain_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end

    alter table(:users) do
      add :role, :text, null: false, default: "user"
    end

    flush()

    # Only create the default domain if there is something to attach to it, so
    # a fresh install starts with no domains and the operator adds their own.
    host = System.get_env("PHX_HOST") || "localhost"

    execute("""
    INSERT INTO domains (id, host, root_url, is_active, inserted_at, updated_at)
    SELECT gen_random_uuid(), '#{host}', NULL, true,
           (now() AT TIME ZONE 'utc'), (now() AT TIME ZONE 'utc')
    WHERE EXISTS (SELECT 1 FROM links)
    """)

    execute("""
    UPDATE links
       SET domain_id = (SELECT id FROM domains WHERE host = '#{host}')
     WHERE domain_id IS NULL
    """)

    # Promote only when there is exactly one account, which is unambiguous.
    # `users` carries no timestamps, so with several accounts "the earliest" is
    # not determinable and ordering by a random UUID would crown an arbitrary
    # user. Those installs use `mix qwynk.grant_role <email> superadmin`.
    execute("""
    UPDATE users SET role = 'superadmin'
     WHERE (SELECT count(*) FROM users) = 1
    """)

    flush()

    alter table(:links) do
      modify :domain_id, :uuid, null: false
    end

    drop_if_exists unique_index(:links, [:slug], name: "links_unique_slug_index")
    create unique_index(:links, [:domain_id, :slug], name: "links_unique_slug_per_domain_index")
  end

  def down do
    alter table(:users) do
      remove :role
    end

    drop_if_exists unique_index(:links, [:domain_id, :slug],
                     name: "links_unique_slug_per_domain_index"
                   )

    drop constraint(:links, "links_domain_id_fkey")

    alter table(:links) do
      remove :domain_id
    end

    create unique_index(:links, [:slug], name: "links_unique_slug_index")

    drop_if_exists unique_index(:domains, [:host], name: "domains_unique_host_index")

    drop table(:domains)
  end
end
