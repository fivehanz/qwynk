# Product Requirements Document: Qwynk v1.0

## 1. Executive Summary
**Qwynk** is a self-hosted, high-performance link management system. It prioritizes **low-latency redirection** via in-memory caching (ETS) and **privacy-first analytics** that respects GDPR by strictly avoiding PII storage.

## 2. System Architecture

* **Host:** FreeBSD 14+ Jail.
* **Stack:** Elixir 1.18+ (Phoenix 1.8), Ash 3.0, PostgreSQL 16+, ETS, LiveView.
* **Frontend:** LiveView + Tailwind v4 + Daisy UI v5. Charts are server-rendered SVG.

```
                 INTERNET
                    │
                    ▼
                OpenResty
                    │
                    ▼
               Phoenix 1.8
                    │
          ┌─────────┴─────────┐
          │                   │
       /_/...              /:slug
          │                   │
       LiveView              ETS
          │              ┌────┴────┐
          │             HIT       MISS
          │              │         │
          │              │      PostgreSQL
          │              │         │
          │              └────┬────┘
          │                   │
          │                 302
          │                   │
          │            async analytics
          │                   │
          │            AnalyticsBuffer
          │                   │
          │              batch insert
          │                   │
          └──────────── PostgreSQL
```

**No Redis. No job queue.** OTP already provides the machinery: ETS for the
cache, a GenServer for the buffer, `Task.Supervisor` for async dispatch.

## 3. Core Logic Specifications

### 3.1 The Routing Engine (The "Razor")
To eliminate lookup overhead, the Router differentiates administrative traffic
from redirect traffic immediately.
* **Namespace `/_/`**: Reserved for System Internals (Admin, Auth, Console, Dev
  tools). Reachable on every host.
* **Namespace `/:slug`**: All other single-segment requests are treated as Slugs.
* **Root `/`**: resolved per domain — see below.

A single segment, not `/*path`: with `/_/` reserved there is nothing a catch-all
would buy, and it would swallow multi-segment paths that should 404.

**Several domains may point at one server.** The `Host` header selects a
`Domain`, and slugs are unique *per domain* — `acme.com/launch` and
`beta.io/launch` are different links. An unknown or deactivated host 404s
everything.

```
GET <host>/         → unknown or inactive host  → 404
                    → root_url set              → 302 to root_url
                    → root_url null (default)   → 404

GET <host>/:slug    → resolved within that host's domain, else 404
GET <host>/_/…      → admin, on any host
```

The root path defaults to 404 rather than redirecting to sign-in: a bare link
domain should not advertise that an admin panel exists. A superadmin can point
it somewhere from the console.

### 3.2 The Hot Path (Redirect Flow)
Latency Budget: < 5ms (Internal Processing).

The ETS entry carries `link_id` so the analytics path never needs a second
lookup:

```elixir
{slug, %{link_id: uuid, destination: binary, strategy: :permanent | :temporary}, expires_at_ms}
```

1. **Request:** `GET /{slug}`. The response always carries `x-qwynk-cache: hit | miss`.
2. **Layer 1 (Memory):** `:ets.lookup(:qwynk_cache, slug)`.
   * *Hit and unexpired:* redirect. Dispatch enrichment to `Qwynk.TaskSupervisor`.
3. **Layer 2 (DB):** miss or expired → `Qwynk.Traffic.resolve(slug)`.
   * *Found:* write ETS (TTL 10m), redirect, dispatch enrichment.
   * *Not found:* 404 HTML. Nothing is cached and nothing is logged.

`:permanent` → 301, `:temporary` → 302.

**Cache invalidation.** TTL is the fallback, not the mechanism. `create` writes
nothing (the entry is populated lazily on first hit); `update`, `disable` and
`destroy` delete the ETS entry in an `after_action` hook. Without explicit
invalidation, an edit at 10:02 keeps serving the old destination until ~10:11.

### 3.3 Slug Generation ("Goblin-Speak")
* **Algorithm:** Programmatic CVC-CVC construction (e.g., `zip-zap`).
* **Namespace:** 16 onsets × 5 nuclei × 11 codas = 880 syllables → **774,400 slugs**.
* **Collision Strategy:** retry with a fresh slug up to 5 times, then fall back to
  a numeric suffix (e.g. `zip-zap-5`). Birthday collisions reach ~50% near 1,000
  links, so retrying once is not enough.
* **Benefit:** Memorable, fun, zero dictionary dependencies.

### 3.4 The Analytics Pipe (The "Buffer")
Direct DB writes on the request path are forbidden. So is buffering PII.

```
HTTP request ──► IP, User-Agent, Referrer   (request memory only)
                        │
                        ▼
              Analytics.Enrich  ◄── privacy boundary
                        │
      visitor_hash · country · device · referrer_domain
                        │
                        ▼
                 AnalyticsBuffer  (bounded, max 10_000)
                        │
                        ▼
                   PostgreSQL  (bulk insert)
```

1. **Dispatch:** the redirect process hands raw request data to a task under
   `Qwynk.TaskSupervisor` and returns immediately.
2. **Enrichment (in the task, before buffering):**
    * **Geo:** look the IP up in the local MaxMind `.mmdb`.
    * **Privacy:** `visitor_hash = SHA256(ip <> user_agent <> daily_salt)`.
    * **Referrer:** reduced to its host. Never the path, query or fragment.
    * **Device:** classified from the User-Agent.
   The salt comes from `:persistent_term`, never from PostgreSQL — hashing must
   keep working while the database is down.
3. **Buffer:** only the anonymous struct is cast to the GenServer.
4. **Flush:** every 5 seconds OR at 1000 items → `Ash.bulk_create/3`.
5. **Backpressure:** at 10,000 buffered events new events are **dropped** and
   counted. If PostgreSQL is down the buffer retries on the next tick until the
   bound is reached, then sheds. Redirects never block or fail because analytics
   is unhealthy.

## 4. UI/UX Requirements

### 4.0 Roles

| Role | Links | Domains | Users |
| :--- | :--- | :--- | :--- |
| `user` | own only | read | — |
| `admin` | all | read | — |
| `superadmin` | all | manage | manage roles |

The first account to register becomes `superadmin`; without that nobody could
reach the console on a fresh install. Nobody may change their own role,
including a superadmin, so the lowest-privilege account cannot escalate and the
last superadmin cannot lock everyone out. An install that predates roles uses
`mix qwynk.grant_role <email> superadmin`.

### 4.1 Admin (`/_/app`)
* **Design System:** DaisyUI v5 (Dark Mode), hand-written Tailwind components.
* **Routes:**
    * `/_/sign-in` — authentication (AshAuthentication)
    * `/_/app` — dashboard: total links, 30-day clicks, 30-day uniques
    * `/_/app/links` — list, search, create, edit, disable, copy-to-clipboard
    * `/_/app/links/:id` — destination, slug, status, created, clicks, uniques, 30-day chart
    * `/_/app/settings` — account
    * `/_/admin` — superadmin console: domains and their root behaviour
    * `/_/admin/users` — superadmin console: roles
* Links are owner-scoped: a user sees only their own, enforced by Ash policy
  rather than by filtering in the LiveView.
* **Interactions:** All state changes use LiveView. No full page reloads.

## 5. Non-Functional Requirements
1.  **Privacy:** No cookies dropped on redirect. No raw IPs stored. No referrer
    paths or query strings stored. The `hits` table has no `ip` or `user_agent`
    column by construction.
2.  **Reliability:** If the DB is down, cached links must still work until TTL
    expires. Analytics loss under a DB outage is acceptable; redirect failure is not.
3.  **Build:** Must compile on FreeBSD (standard Mix, no Docker, no C NIF
    dependencies). Build the release *on* FreeBSD — a Linux-built release will
    not run there.
