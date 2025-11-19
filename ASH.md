# Ash Domain Specification: Qwynk

## 1. Domain: Traffic
**Purpose:** Manages the core redirection logic and link assets.

### Resource: `Link`
* **Persistence:** PostgreSQL Table `links`
* **Type:** Persistent
* **Identity:**
    * Primary Key: `slug` (String) - *chosen for read-speed optimization*

#### Attributes
| Name | Type | Constraints | Default | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `slug` | String | Min: 3, Max: 64, Regex: `^[a-z0-9-]+$` | - | The public identifier. |
| `destination` | String | URL format | - | The target URL. |
| `owner_id` | UUID | References `User` | - | |
| `is_active` | Boolean | - | `true` | Soft delete toggle. |
| `strategy` | Atom | One of: `:301`, `:302` | `:302` | HTTP Redirect code. |
| `inserted_at`| UTC | - | Auto | |

#### Actions
1.  **Action: `create`**
    * *Accepts:* `destination`, `slug` (optional).
    * *Change:* If `slug` is missing, call `Qwynk.Traffic.SlugGenerator.generate/0` (Goblin-Speak).
    * *Retry Logic:* On unique constraint error, call `generate_with_suffix/0` and retry once.
2.  **Action: `resolve` (Read)**
    * *Argument:* `slug`
    * *Filter:* `slug == ^arg and is_active == true`
    * *Optimization:* This is the "Source of Truth" for the ETS Cache.
3.  **Action: `disable` (Update)**
    * *Change:* Set `is_active` to `false`.

---

## 2. Domain: Analytics
**Purpose:** High-volume, privacy-focused event logging. Optimized for write-throughput.

### Resource: `Hit`
* **Persistence:** PostgreSQL Table `hits`
* **Type:** Persistent (Immutable Log)
* **Identity:**
    * Primary Key: `id` (UUID)

#### Attributes
| Name | Type | Notes |
| :--- | :--- | :--- |
| `link_slug` | String | Foreign Key to `Link.slug`. |
| `timestamp` | UTC | The moment of the click. |
| `visitor_hash`| String | SHA256(IP + UA + DailySalt). **No PII stored.** |
| `country` | String | ISO 2-Char (e.g., "US", "IN"). Derived from MaxMind. |
| `device` | Atom | `:mobile`, `:desktop`, `:tablet`, `:bot`. |
| `referrer` | String | The domain the user came from. |

#### Actions
1.  **Action: `log` (Create)**
    * *Strict Mode:* No validation required (speed priority).
    * *Note:* Only called by the `AnalyticsBuffer` GenServer.
2.  **Action: `stats` (Read)**
    * *Argument:* `slug`, `date_range`
    * *Calculation:* Count total rows.
    * *Calculation:* Count unique `visitor_hash`.

### Resource: `DailySalt`
* **Persistence:** PostgreSQL Table `daily_salts`
* **Purpose:** Rotates the cryptographic salt daily to prevent long-term tracking.

#### Attributes
| Name | Type | Notes |
| :--- | :--- | :--- |
| `date` | Date | Primary Key. |
| `secret` | String | 64-char random string. |

---

## 3. Domain: Accounts
**Purpose:** Authentication and System Access.
**Library:** `ash_authentication`

### Resource: `User` (illustrative, ash_authentication manages it by itself)
* **Persistence:** PostgreSQL Table `users`
* **Strategies:** Password + API.
* **Attributes:** `email`, `hashed_password`.
* **Policies:** Only the user can edit their own `Links`.
