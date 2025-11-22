# Qwynk Brand Identity Specification
**Version:** 1.0
**Theme:** Abyssal Terminal
**Philosophy:** Sovereign. Structural. Silent.

---

## 1. Brand Core

### The Archetype: "The Sovereign Architect"
Qwynk is an intersection of **The Ruler** (Control) and **The Creator** (Engineering). It rejects the abstraction of the cloud in favor of bare-metal reality. It does not "suggest" routing; it enforces it.

* **Voice:** Precise, Laconic, Latency-Obsessed. No marketing fluff.
* **Motto:** *"Traffic is a physical asset. Own it."*
* **Vibe:** A submarine dashboard in the deepest part of the ocean. Dark, pressurized, with electric, glowing readouts.

---

## 2. Typography
We utilize a **Tri-Type Stack** to strictly separate hierarchy, interface, and raw data.

### A. Headings (The Voice)
**Font:** [Space Grotesk](https://fonts.google.com/specimen/Space+Grotesk)
* **Weight:** Bold (700)
* **Tracking:** Tight (`-0.025em`)
* **Role:** Page Titles, Hero Text, KPI Values.
* **Why:** A "Grotesque" sans-serif with brutal, idiosyncratic geometry. It feels like heavy machinery.

### B. Body / UI (The Fabric)
**Font:** [IBM Plex Sans](https://fonts.google.com/specimen/IBM+Plex+Sans)
* **Weight:** Regular (400), Medium (500)
* **Tracking:** Normal
* **Role:** Buttons, Navigation, Tables, Settings.
* **Why:** "Mankind and Machine." Engineered for readability with distinct humanist angles. It adds a technical sophistication that generic fonts lack.

### C. Data / Code (The Truth)
**Font:** [JetBrains Mono](https://www.jetbrains.com/lp/mono/)
* **Weight:** Regular (400)
* **Tracking:** Wide
* **Role:** Link Slugs, Visitor Hashes, IP Addresses, Console Logs.
* **Why:** Designed strictly for code. The increased x-height makes differentiating `0`, `O`, `1`, `l` effortless.

---

## 3. Color Palette: "Bioluminescence"
A strict **Dark Mode Only** palette. We move away from dead grey to a deep, "Abyssal" Blue-Black to reduce eye fatigue and create atmosphere.

### The Palette

| Role | Brand Name | Hex Code | Tailwind Map | WCAG (on Bg) | Usage |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Background** | **Abyssal Void** | `#020617` | `slate-950` | N/A | **The Canvas.** A deep, ink-blue black. |
| **Surface** | **Deep Hull** | `#0F172A` | `slate-900` | N/A | **Cards / Panels.** Slightly lighter for hierarchy. |
| **Primary** | **Cyan Flux** | `#2DD4BF` | `teal-400` | **12.4:1** | **The Signal.** Buttons, Active States, Data Lines. |
| **Secondary** | **Reactor Red** | `#F87171` | `red-400` | **7.8:1** | **Errors.** Softer than pure red to prevent vibration. |
| **Text (Main)** | **Ice White** | `#F1F5F9` | `slate-100` | **16:1** | **Primary Reading.** Crisp, cool white. |
| **Text (Muted)** | **Steel Grey** | `#94A3B8` | `slate-400` | **8.3:1** | **Metadata.** Blue-tinted grey to match the void. |

### Implementation Rules
1.  **No Gradients:** Use solid colors. The "glow" comes from the contrast of Cyan against Slate, not CSS blur effects (keep CPU usage low).
2.  **Borders:** Use thin, crisp borders (`1px solid slate-800`) to define structure.
3.  **Shadows:** Minimal usage. If used, tint the shadow with the primary color (`shadow-[0_0_15px_rgba(45,212,191,0.1)]`) to simulate bioluminescence.

---

## 4. Motion Doctrine

Qwynk motion behaves like **pressure-regulated hydraulics**: tight, functional, never playful. Motion exists only to signal **state**, **structure**, or **data change**. Nothing floats. Nothing bounces. Nothing wiggles.

### Principles
- **Mechanical, not cinematic:** Motion simulates machine actuation.  
- **Short + Intentional:** No animation exceeds **320ms**.  
- **Zero elasticity:** No springs, no rubber-band effects.  
- **Dark-ops clarity:** Motion must *clarify* system change, never distract.  
- **CPU-efficient:** Simple transforms and opacity only.

---

## 4.1. Motion Tokens

### Durations
| Token | Time | Usage |
|-------|------|--------|
| `instant` | `0ms` | Errors, critical state changes |
| `ui` | `120ms` | Buttons, toggles, navigation |
| `system` | `200ms` | LiveView patches, component mounts |
| `data` | `320ms` | D3 updates, chart transitions |

### Easings
| Token | Curve | Usage |
|-------|--------|--------|
| `hydraulic` | `cubic-bezier(0.19, 1, 0.22, 1)` | Default UI motion |
| `data-out` | `ease-out` | Chart transitions |

### Tailwind v4 Tokens (Config Snippet)

```css

/* In app.css, inside the @theme block */
@theme {
  /* ... existing font vars ... */

  /* MOTION TOKEN MAP */
  --ease-hydraulic: cubic-bezier(0.19, 1, 0.22, 1);
  --ease-data-out: ease-out;

  --duration-instant: 0ms;
  --duration-ui: 120ms;
  --duration-system: 200ms;
  --duration-data: 320ms;
}

```

---

## 5. UI Component Strategy (Tailwind v4)

### The "Data Card"
Neo-Brutalist structure. No rounded corners on the main container (or very small `rounded-sm`).
```html
<div class="border border-slate-800 bg-slate-900/50 p-4">
  <h3 class="font-plex text-xs uppercase tracking-widest text-slate-500">Clicks</h3>
  <p class="font-grotesk font-bold text-3xl text-teal-400">1,024</p>
</div>
```

---

## 6. Appendix

```css
/* 1. TYPOGRAPHY IMPORT */
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600&family=JetBrains+Mono:wght@400&family=Space+Grotesk:wght@700&display=swap');

/* 2. TAILWIND V4 SETUP */
@import "tailwindcss";

/* 3. GLOBAL THEME CONFIG (Fonts & Motion) */
@theme {
  /* --- FONTS --- */
  /* We override the defaults so you don't have to type 'font-plex' everywhere */
  --font-sans: "IBM Plex Sans", ui-sans-serif, system-ui, sans-serif;
  --font-mono: "JetBrains Mono", ui-monospace, SFMono-Regular, monospace;
  --font-heading: "Space Grotesk", sans-serif;

  /* --- MOTION DOCTRINE (Hydraulics) --- */
  --ease-hydraulic: cubic-bezier(0.19, 1, 0.22, 1);
  --ease-data-out: ease-out;

  --duration-instant: 0ms;
  --duration-ui: 120ms;
  --duration-system: 200ms;
  --duration-data: 320ms;
  
  /* --- SPACING --- */
  --spacing-4-5: 1.125rem; /* For dense data grids */
}

/* 4. DAISYUI V5 SETUP */
@plugin "daisyui" {
  themes: abyssal --default;
}

/* 5. THE ABYSSAL THEME DEFINITION */
@plugin "daisyui/theme" {
  name: "abyssal";
  default: true;

  /* --- PALETTE: BIOLUMINESCENCE --- */
  
  /* The Void (Backgrounds) */
  --color-base-100: #020617; /* Abyssal Void (Slate-950) */
  --color-base-200: #0F172A; /* Deep Hull (Slate-900) */
  --color-base-300: #1E293B; /* Surface Detail (Slate-800) */
  --color-base-content: #F1F5F9; /* Ice White (Slate-100) */

  /* The Signal (Primary) */
  --color-primary: #2DD4BF; /* Cyan Flux (Teal-400) */
  --color-primary-content: #020617; /* Black text on Cyan */
  
  /* The Muted (Secondary/Neutral) */
  --color-secondary: #94A3B8; /* Steel Grey (Slate-400) */
  --color-secondary-content: #020617;
  --color-neutral: #1E293B;   /* Slate-800 */
  --color-neutral-content: #94A3B8;

  /* The Critical (Error) */
  --color-error: #F87171; /* Reactor Red (Red-400) */
  --color-error-content: #020617;

  --color-success: #2DD4BF; /* Map success to Cyan for consistency */
  --color-warning: #FBBF24; /* Amber-400 */
  --color-info: #38BDF8;    /* Sky-400 */

  /* --- SHAPE: NEO-BRUTALIST --- */
  /* "Zero Elasticity" visual translation -> Sharp Corners */
  --radius-selector: 0rem; 
  --radius-field: 0rem;
  --radius-box: 0rem;
  --radius-btn: 0rem;
  
  --border-btn: 1px;
  --border-input: 1px;
}

/* 6. UTILITY CLASSES & OVERRIDES */

/* Utility for the Space Grotesk Heading */
@utility font-heading {
  font-family: var(--font-heading);
  letter-spacing: -0.025em;
  font-weight: 700;
}

/* Utility for Glass Panels (Dashboard Cards) */
@utility glass-panel {
  @apply border border-base-300 bg-base-200/50 backdrop-blur-md;
}

/* Apply the Motion Doctrine globally to interactive elements */
@layer base {
  button, a, .btn {
    @apply transition-all duration-ui ease-hydraulic;
  }
}

```
