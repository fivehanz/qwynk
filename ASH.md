# Ash Domain Specification: Qwynk

## 1. Domain: Traffic
**Purpose:** Manages the core redirection logic and link assets.

### Resource: `Domain`
* **Persistence:** PostgreSQL Table `domains`
* **Purpose:** A hostname pointed at this server. Operator-level, not user-owned.

| Name | Type | Notes |
| :--- | :--- | :--- |
| `host` | String | Unique. Normalized to a bare lowercase hostname on write. |
| `root_url` | String | Nullable. **Null means the root path 404s** — the default. |
| `is_active` | Boolean | Default true. Inactive → every path on it 404s. |

Reads are open: the redirect path resolves domains with no actor at all, and a
user must see the host their own link lives on. Writes are superadmin-only.
That policy is deliberately scoped to `[:create, :update, :destroy]` rather than
`always()` — every policy whose condition matches has to pass, so a catch-all
would forbid the reads the read policy allows.

Deleting a domain that still holds links is refused; deactivate instead.
Domain writes evict that host's cached entries, old host and new, since a
rename moves the cache key.

### Resource: `Link`
* **Persistence:** PostgreSQL Table `links`
* **Type:** Persistent
* **Identity:**
    * Primary Key: `id` (UUID) - *Standard Surrogate Key*
    * Identity: `slug` (Unique Index) - *For fast lookups*

#### Attributes
| Name | Type | Constraints | Default | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | Primary Key, Auto-generated | | |
| `slug` | String | Min: 3, Max: 64, Regex: `^[a-z0-9-]+$` | generated | The public identifier. |
| `destination` | String | URL format | - | The target URL. |
| `owner_id` | UUID | References `User`, not null | - | Set by `relate_actor(:owner)`. |
| `domain_id` | UUID | References `Domain`, not null | - | Which host this link lives on. |
| `is_active` | Boolean | - | `true` | Soft delete toggle. |
| `strategy` | Atom | One of: `:permanent`, `:temporary` | `:temporary` | `:permanent` → 301, `:temporary` → 302. |
| `inserted_at`| UTC | - | Auto | |
| `updated_at`| UTC | - | Auto | |

> `strategy` is **not** `:301` / `:302`. Those are not valid Elixir atoms — an
> atom literal cannot begin with a digit.

> **Identity is `[:domain_id, :slug]`, not `[:slug]`.** Two customers on two
> domains must be able to hold the same slug. This is why the ETS cache is keyed
> `{host, slug}` and `resolve` takes both.

#### Actions
1.  **Action: `create`**
    * *Accepts:* `destination`, `slug` (optional), `strategy` (optional).
    * *Change:* `relate_actor(:owner)`, then `Changes.EnsureSlug` — if `slug` is
      missing, call `Qwynk.Traffic.SlugGenerator.generate/0` (Goblin-Speak).
    * *Retry Logic:* handled by `Qwynk.Traffic.create_link/2`, not by the action.
      On a unique-slug conflict, retry with a fresh slug **up to 5 times**, then
      fall back to `generate_with_suffix/0`. The namespace is 774,400 slugs, so
      birthday collisions reach ~50% near 1,000 links; retrying once is not enough.
      A caller-supplied slug is never retried — the conflict is returned.
2.  **Action: `resolve` (Read)**
    * *Arguments:* `slug`, `domain_id`
    * *Filter:* `slug == ^arg(:slug) and domain_id == ^arg(:domain_id) and is_active == true`
    * *Policy:* `authorize_if always()`. A public redirect has no actor. Every
      other action on this resource is owner-scoped.
    * *Optimization:* Postgres index scan on `slug`. This is the "Source of
      Truth" for the ETS Cache.
3.  **Actions: `update`, `disable`, `destroy`**
    * *Change:* `Changes.InvalidateCache` — deletes the ETS entry in an
      `after_action` hook. TTL is the fallback, not the mechanism.
    * All three need `require_atomic? false`: `config/config.exs` sets
      `default_actions_require_atomic?: true` and an `after_action` hook is not atomic.
    * `disable` sets `is_active` to `false`.

---

## 2. Domain: Analytics
**Purpose:** High-volume, privacy-focused event logging. Optimized for write-throughput.

### Resource: `Hit`
* **Persistence:** PostgreSQL Table `hits`
* **Type:** Persistent (Immutable Log)
* **Identity:** Primary Key `id` (UUID)

#### Attributes
| Name | Type | Notes |
| :--- | :--- | :--- |
| `link_id` | UUID | Foreign Key to `Link.id`. (16 bytes vs. string length.) |
| `timestamp` | UTC | The moment of the click. |
| `visitor_hash`| String | `SHA256(ip <> user_agent <> daily_salt)`. **No PII stored.** |
| `country` | String | ISO 2-char (e.g. "US", "IN"). Derived from MaxMind. Nullable. |
| `device` | Atom | `:mobile`, `:desktop`, `:tablet`, `:bot`. |
| `referrer_domain` | String | Host only. Nullable. |

**`referrer_domain`, not `referrer`.** Normalization is part of the schema
contract:

```
https://example.com/foo?secret=123#frag  →  example.com
```

Never store the path, query string or fragment — they carry secrets.

**There is deliberately no `ip` or `user_agent` column.** That absence *is* the
privacy guarantee, and a schema-level test asserts it.

#### Indexes
* `(link_id, timestamp)` — the stats time-series query.
* `(link_id, visitor_hash)` — unique-visitor counting.

#### Actions
1.  **Action: `log` (Create)**
    * *Strict Mode:* no validation (write throughput is the priority).
    * *Note:* only called by `Qwynk.Analytics.Buffer`, via `Ash.bulk_create/3`.
2.  **Query: `Qwynk.Analytics.stats/2`**
    * *Arguments:* `link_id`, `days` (default 30).
    * *Returns:* one row per day, zero-filled, with `clicks` and `uniques`.
    * Implemented as one SQL query using `generate_series` — Ash aggregates
      cannot express `count(distinct …)` grouped by day without a custom fragment.

### Resource: `DailySalt`
* **Persistence:** PostgreSQL Table `daily_salts`
* **Purpose:** Rotates the cryptographic salt daily to prevent long-term tracking.

#### Attributes
| Name | Type | Notes |
| :--- | :--- | :--- |
| `date` | Date | Primary Key. |
| `secret` | String | 64-char random string. Sensitive. |

#### Access pattern
* Read **at most once per day** into `:persistent_term` via `Analytics.Salt`.
  PostgreSQL must never be on the redirect path, and hashing must keep working
  when the DB is down.
* The date roll is handled by the buffer's existing 5-second tick — no extra
  process, no cron.

#### Retention
* A `purge` action deletes salts older than **2 days**, run on the same date roll.
* This is the point of rotating at all: the guarantee comes from the old salt
  being *gone*. Keeping every salt forever would make the rotation decorative.

---

## 3. Domain: Accounts
**Purpose:** Authentication and System Access.
**Library:** managed by `ash_authentication` (password, magic link, API key).

`User.role` is one of `:superadmin`, `:admin`, `:user`, defaulting to `:user`.
The first account registered is promoted by `Changes.BootstrapSuperadmin`.
`set_role` is superadmin-only and carries `Changes.ProtectOwnRole`, which
refuses a change to the actor's own account.

> `Token.expunge_expired` is currently unscheduled — removing Oban removed the
> only thing that ran it. Expired token rows accumulate harmlessly at this
> scale. If it ever matters, the buffer's daily roll is where it belongs.
> Per AGENTS.md rule 9, do not reintroduce a job framework for it.
