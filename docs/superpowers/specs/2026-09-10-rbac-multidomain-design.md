# RBAC, multi-domain routing, and the superadmin console

**Status:** design · 2026-09-10

## Why

Three requests that turn out to be one change:

1. **There is no RBAC.** `Qwynk.Accounts.User` has `email`, `hashed_password`,
   `confirmed_at` and nothing else. The only authorization rule in the system is
   `Link`'s owner scoping. Every account is equal, so there is no one who can be
   trusted with system settings.
2. **`/` redirecting to sign-in is wrong.** A link domain's root should not
   advertise that an admin panel exists. Default to 404; let an operator set a
   redirect target per domain.
3. **Multiple domains point at one server.** Which means "the root path" is not
   one thing — it is per-domain, and so is the slug namespace.

(2) cannot be configured without (1), and (2) is meaningless without (3). They
ship together.

## The load-bearing decision

**Slugs become unique per domain, not globally.**

Today `Link` has `identity :unique_slug, [:slug]`. With several domains on one
server that is wrong: `acme.com/launch` and `beta.io/launch` are different
links, and two customers must be able to hold the same slug. So:

- `Link` gains `domain_id`, and the identity becomes `[:domain_id, :slug]`.
- The ETS cache key changes from `slug` to `{host, slug}`.
- `resolve` takes host **and** slug.

This is a breaking change to the hot path, and it is the reason this work is not
just a settings page. Everything else follows from it.

## Data model

### `Qwynk.Traffic.Domain` (new)

| Attribute | Type | Notes |
| :--- | :--- | :--- |
| `id` | UUID | |
| `host` | String | Unique, lowercased, no scheme or port. `acme.com`. |
| `root_url` | String | Nullable. **Null means 404** — the default. |
| `is_active` | Boolean | Default true. Inactive → every path 404s. |
| `inserted_at` / `updated_at` | UTC | |

Domains are system-level, managed by superadmins. They are not owned by users:
a self-hosted operator runs the domains, users just put links on them.

### `Qwynk.Traffic.Link` (changed)

- `belongs_to :domain`, `allow_nil? false`.
- `identity :unique_slug_per_domain, [:domain_id, :slug]` replaces `unique_slug`.

### `Qwynk.Accounts.User` (changed)

- `role` : atom, one of `:superadmin`, `:admin`, `:user`. Default `:user`.

| Role | Links | Domains | Users |
| :--- | :--- | :--- | :--- |
| `user` | own only | — | — |
| `admin` | all | read | — |
| `superadmin` | all | manage | manage roles |

**Bootstrap:** the first account to register becomes `:superadmin`. Without this
nobody can ever reach the console. Implemented as a change on
`register_with_password` that checks whether any user exists.

A user may never change their own role — otherwise the lowest-privilege account
can escalate. Enforced by policy, not by the UI.

## Routing

`/_/…` stays reachable on every host. It is already namespaced, so no host
special-casing is needed for the admin.

```
GET <host>/            → domain lookup
                          ├─ unknown host, or inactive     → 404
                          ├─ root_url set                  → 302 to root_url
                          └─ root_url null                 → 404   (default)

GET <host>/:slug       → domain lookup, then slug within that domain
                          └─ miss                          → 404

GET <host>/_/…         → admin, on any host
```

The root path is served by the same controller as slugs, because both need the
domain and both must stay off the session. `PageController` is deleted.

### Cache

`Cache.fetch/1` becomes `Cache.fetch/2` keyed `{host, slug}`. Invalidation keys
on the link's domain host. Domain edits (host change, deactivation, root_url
change) must flush that domain's entries — a `Cache.delete_domain/1` doing a
`:ets.match_delete` on the host half of the key.

A domain row is looked up per request on a cache miss. Domains are few and
change rarely, so they get their own tiny ETS table, warmed at boot and
invalidated on write. The hot path must not gain a second Postgres query.

## Superadmin console

At `/_/admin`, distinct from `/_/app`. Visible only to `:superadmin`.

- **Domains** — list, add, edit host, set or clear `root_url`, activate /
  deactivate. Deleting a domain with links is refused; deactivate instead.
- **Users** — list, change role, see link counts. Cannot change own role.

`/_/app` stays the per-user surface for every role.

## Migration

Existing links have no domain. One data migration:

1. Create a domain from `PHX_HOST` (falling back to `localhost`), `root_url`
   null so behaviour matches the new default.
2. Backfill every existing link's `domain_id` to it.
3. Then make `domain_id` non-null and swap the identity.

Existing users all get `:user` except the earliest by `inserted_at`, which
becomes `:superadmin`.

## What this deliberately does not do

- No per-domain ownership or billing. Domains are operator-level.
- No custom 404 pages per domain. One branded 404 for all.
- No wildcard or apex/`www` aliasing. One row per host; add `www.acme.com`
  separately if you want it.
- No TLS or certificate management. That is the reverse proxy's job.
- `admin` gets read-only visibility of domains. If it needs more, promote.

## Verification

- Two domains in the same database holding the *same* slug, resolving to
  different destinations — this is the test that proves the namespace change.
- `/` on a domain with null `root_url` → 404; set a `root_url` → 302; both
  without touching the session or setting a cookie.
- Unknown `Host:` header → 404, never a 500.
- A `:user` cannot reach `/_/admin`; an `:admin` can see but not write domains.
- No user can change their own role, including a superadmin.
- Cache: a domain deactivation evicts that domain's slugs and no others.
