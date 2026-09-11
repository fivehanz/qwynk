# Qwynk

**Qwynk** is a high-performance, privacy-centric URL shortener and link manager.
It separates the redirect engine (ETS-backed) from the analytics engine
(async batching).

**Status: v1 working.** The redirect engine, the privacy-first analytics
pipeline, multi-domain routing and the role-based admin are implemented, with
the suite in `test/` covering them. GeoIP enrichment is wired but needs a
MaxMind database to return anything. See `PRD.md` for the specification and
`AGENTS.md` for the architecture rules that must hold.

## Tech Stack
* **Core:** Elixir 1.18+ / OTP 26+, Phoenix 1.8, Ash Framework 3.0
* **Data:** PostgreSQL 16+, ETS (Erlang Term Storage)
* **Frontend:** LiveView + Tailwind v4, server-rendered SVG charts. daisyUI v5
  is vendored for its theme plugin only (`themes: false`; components are
  hand-written Tailwind, per `AGENTS.md`)
* **Geo:** MaxMind GeoLite2 (local MMDB, optional)

No Redis. No job queue. OTP provides the cache, the buffer and the async
dispatch.

## Directory Structure
* `lib/qwynk/traffic/` — link and domain management, slug logic, ETS cache
* `lib/qwynk/analytics/` — enrichment, GeoIP, daily salt, bounded buffer, hit
  records and stats queries
* `lib/qwynk/accounts/` — users, roles, API keys, tokens
* `lib/qwynk/` — domain entry points (`Traffic`, `Analytics`, `Accounts`),
  plus `Secrets`, `Mailer` and `Repo`
* `lib/qwynk_web/` — router, redirect controller, LiveViews, status rail,
  `components/` (including the SVG chart)
* `lib/mix/tasks/` — `mix qwynk.grant_role`
* `landing_page/` — Astro marketing site (deployed separately to Cloudflare)
* `brand_book/` — SvelteKit brand reference
* `docs/` — specs and plans for larger changes

## Architecture

1.  **The Bouncer:** incoming traffic hits the Phoenix Endpoint. The `Host`
    header picks a domain, `/_/` is reserved for internals on every host, and
    everything else is a slug within that domain. A bare domain root returns
    404 unless a superadmin points it somewhere.
2.  **The Cache:** lookups happen in RAM (ETS). The cached entry carries
    `link_id` so analytics never needs a second lookup.
3.  **The Vault:** persistent data lives in Postgres, managed by Ash resources.
4.  **The Ledger:** analytics are anonymized *before* buffering, then bulk
    inserted. Raw IP and User-Agent never leave the request.

## First run

The first account to register becomes the superadmin. Sign up at `/_/register`,
then add your hostnames under `/_/admin` — until a host is listed, every request
to it returns 404, including links.

## Roles

Access is role-based on `Qwynk.Accounts.User.role`:

* `superadmin` — domains, roles, and every link. This is the role that owns
  `/_/admin`.
* `admin` — every link, and can read domains.
* `user` — their own links only.

`mix qwynk.grant_role` upgrades an install that predates roles:

```bash
mix qwynk.grant_role you@example.com superadmin
```

## Prerequisites (FreeBSD)
* Elixir 1.18+ & Erlang/OTP 26+ (see `mise.toml`)
* PostgreSQL 16+
* Optional: MaxMind City database (`GeoLite2-City.mmdb`). Create `priv/geoip/`
  and put the file there. Without it, `country` is simply `nil`. The file is
  gitignored, because MaxMind's license does not permit redistribution.

A C compiler is required. `bcrypt_elixir` builds a small C NIF
(`c_src/bcrypt_nif.c`) through `elixir_make` when dependencies compile, so
`cc`/`clang` and `make` must be present on the build host. `simple_sat`
replaced `picosat_elixir`, so Ash no longer compiles its own SAT solver.

## Configuration
Set the following environment variables in your `sys.rc` or `.env`:

```bash
# Required. The app refuses to boot without these.
export SECRET_KEY_BASE="your_secure_key"        # signs cookies and sessions
export TOKEN_SIGNING_SECRET="your_other_key"    # signs auth tokens (`Qwynk.Secrets`)
export DATABASE_URL="postgres://user:pass@localhost/qwynk_prod"
export PHX_HOST="jsmx.org"

# Optional, with defaults.
export PORT=4000                                   # HTTP port
export POOL_SIZE=10                                # Postgres pool size
export DNS_CLUSTER_QUERY=""                        # Erlang clustering, unset by default
export GEOIP_PATH="/usr/local/share/qwynk/GeoLite2-City.mmdb"  # MaxMind City DB
```

## Development

```bash
mix setup        # deps, database, assets, seeds
mix phx.server   # http://localhost:4000
mix test         # the suite
mix precommit    # compile --warning-as-errors, deps.unlock --unused, format, test
```

## Deployment
Build the release **on FreeBSD**. A Phoenix release bundles the BEAM runtime and
is built for a specific OS and architecture — a Linux-built release will not run
in a FreeBSD jail.

```bash
mix deps.get --only prod
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix release
```

The release serves HTTP only when `PHX_SERVER` is set (`config/runtime.exs`):

```bash
PHX_SERVER=true bin/qwynk start
```

`mix phx.gen.release` writes a `rel/overlays/bin/server` script that sets it
for you.
