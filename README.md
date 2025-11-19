# Qwynk

**Qwynk** is a high-performance, privacy-centric URL shortener and link manager designed for the "UNIX Philosophy." It separates the redirect engine (ETS-backed) from the analytics engine (Async Batching).

## Tech Stack
* **Core:** Elixir, Phoenix 1.8, Ash Framework 3.0
* **Data:** PostgreSQL, ETS (Erlang Term Storage)
* **Frontend:** LiveView, Tailwind v4, D3.js
* **Geo:** MaxMind GeoLite2 (Local MMDB)

## Directory Structure
* `lib/qwynk/traffic/` - Link management & Slug logic.
* `lib/qwynk/analytics/` - Hit logging & GeoIP.
* `lib/qwynk/accounts/` - User auth.

## Architecture

[Image of Qwynk Data Flow Diagram]

1.  **The Bouncer:** Incoming traffic hits the Phoenix Endpoint.
2.  **The Cache:** Lookups happen in RAM (ETS).
3.  **The Vault:** Persistent data lives in Postgres, managed by Ash Resources.
4.  **The Ledger:** Analytics are hashed (anonymized) and buffered before writing.

## Prerequisites (FreeBSD)
* Elixir 1.18+ & Erlang/OTP 26+ (verified in mise.toml)
* PostgreSQL 16+
* `gmake` and `clang` (Required for `picosat` NIF compilation)
* MaxMind City Database (`GeoLite2-City.mmdb`) placed in `priv/geoip/`

## Configuration
Set the following environment variables in your `sys.rc` or `.env`:

```bash
export SECRET_KEY_BASE="your_secure_key"
export DATABASE_URL="postgres://user:pass@localhost/qwynk_prod"
export PHX_HOST="jsmx.org"
export POOL_SIZE=10
