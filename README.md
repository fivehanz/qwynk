# Qwynk

**Qwynk** is a high-performance, privacy-centric URL shortener and link manager.
It separates the redirect engine (ETS-backed) from the analytics engine
(async batching).

**Status: v1 working.** Redirect engine, privacy-first analytics pipeline and
the owner-scoped admin are implemented and tested. GeoIP enrichment is wired
but needs a MaxMind database to return anything. See `PRD.md` for the
specification and `AGENTS.md` for the architecture rules that must hold.

## Tech Stack
* **Core:** Elixir 1.18+ / OTP 26+, Phoenix 1.8, Ash Framework 3.0
* **Data:** PostgreSQL 16+, ETS (Erlang Term Storage)
* **Frontend:** LiveView + Tailwind v4 + Daisy UI v5, server-rendered SVG charts
* **Geo:** MaxMind GeoLite2 (local MMDB, optional)

No Redis. No job queue. OTP provides the cache, the buffer and the async
dispatch.

## Directory Structure
* `lib/qwynk/traffic/` — link management, slug logic, ETS cache
* `lib/qwynk/analytics/` — hit logging, enrichment, GeoIP, buffer
* `lib/qwynk/accounts/` — user auth and roles
* `lib/qwynk_web/` — router, redirect controller, admin LiveViews
* `landing_page/` — Astro marketing site (deployed separately to Cloudflare)
* `brand_book/` — SvelteKit brand reference

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

Upgrading an install that predates roles:

```bash
mix qwynk.grant_role you@example.com superadmin
```

## Prerequisites (FreeBSD)
* Elixir 1.18+ & Erlang/OTP 26+ (see `mise.toml`)
* PostgreSQL 16+
* Optional: MaxMind City database (`GeoLite2-City.mmdb`) in `priv/geoip/`.
  Without it, `country` is simply `nil`. The file is gitignored — MaxMind's
  license does not permit redistribution.

There is no C compiler requirement: `simple_sat` replaced `picosat_elixir`, so
`gmake` and `clang` are no longer needed.

## Configuration
Set the following environment variables in your `sys.rc` or `.env`:

```bash
export SECRET_KEY_BASE="your_secure_key"
export DATABASE_URL="postgres://user:pass@localhost/qwynk_prod"
export PHX_HOST="jsmx.org"
export POOL_SIZE=10
export GEOIP_PATH="/usr/local/share/qwynk/GeoLite2-City.mmdb"  # optional
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
