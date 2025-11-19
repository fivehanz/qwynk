# Product Requirements Document: Qwynk v1.0

## 1. Executive Summary
**Qwynk** is a self-hosted, high-performance link management system. It prioritizes **low-latency redirection** via Edge-like caching (ETS) and **privacy-first analytics** that respects GDPR by strictly avoiding PII storage.

## 2. System Architecture

* **Host:** FreeBSD 14+ Jail.
* **Stack:** Elixir 1.18+ (Phoenix 1.8), Ash 3.0, PostgreSQL 16+.
* **Frontend:** LiveView v1 + Tailwind v4 + Daisy UI v5 + D3.js.

## 3. Core Logic Specifications

### 3.1 The Routing Engine (The "Razor")
To eliminate lookup overhead, the Router must differentiate Administrative traffic from Redirect traffic immediately.
* **Namespace `/_/`**: Reserved for System Internals (Admin, Auth, API).
* **Namespace `/*path`**: All other requests are treated as Slugs.

### 3.2 The Hot Path (Redirect Flow)
Latency Budget: < 5ms (Internal Processing).
1.  **Request:** `GET /{slug}` (returns "x-qwynk-cache" header with hit / miss)
2.  **Layer 1 (Memory):** Check ETS Table `:qwynk_cache`. 
    * *Hit:* Return 302. Spawn Async Analytics Task.
3.  Layer 3 (DB):
    * *Miss:* Query DB (`Link.resolve`).
        * *Found:* Write to ETS (TTL 10m). Return 302. Spawn Async Analytics Task.
        * *Null:* Return 404 HTML.

### 3.3 The Analytics Pipe (The "Buffer")
Direct DB writes on request are forbidden.
1.  **Capture:** Request Data (IP, UA, Referrer) is passed to `Qwynk.Analytics.Buffer` (GenServer).
2.  **Enrichment:**
    * **Geo:** Lookup IP in local MaxMind `.mmdb`.
    * **Privacy:** Fetch `DailySalt`. Hash = `SHA256(IP + UA + Salt)`.
3.  **Buffer:** Struct is stored in a list in GenServer State.
4.  **Flush:** Every 5 seconds OR 100 items -> Bulk Insert to Postgres via Ash.

## 4. UI/UX Requirements

### 4.1 Dashboard (`/_/app`)
* **Design System:** DaisyUI v5 (Dark Mode).
* **Views:**
    * **Link List:** Sortable table (Clicks, Created At). Quick "Copy" button.
    * **Link Detail:** D3.js Area Chart (Clicks vs. Uniques) over 30 days.
* **Interactions:** All state changes (Create/Edit) use LiveView (WebSocket). No full page reloads.

## 5. Non-Functional Requirements
1.  **Privacy:** No Cookies dropped on Redirect. No Raw IPs stored.
2.  **Reliability:** If DB is down, Cached links must still work until TTL expires.
3.  **Build:** Must compile on FreeBSD (Standard Mix, no Docker).
