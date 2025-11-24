<script lang="ts">
    let motionState = $state(false);
    let activeTab = $state("overview");

    function toggleMotion() {
        motionState = !motionState;
    }
</script>

<div
    class="min-h-screen bg-base-100 text-base-content font-sans selection:bg-primary selection:text-primary-content"
>
    <!-- Navigation / Status Bar -->
    <nav
        class="sticky top-0 z-50 border-b border-base-300 bg-base-100/95 backdrop-blur-md"
    >
        <div
            class="max-w-7xl mx-auto px-6 h-14 flex items-center justify-between"
        >
            <div class="flex items-center gap-4">
                <span class="font-heading font-bold text-lg tracking-tight"
                    >QWYNK <span class="text-primary">///</span> BRAND_OS</span
                >
                <span
                    class="hidden md:inline-block px-2 py-0.5 text-[10px] font-mono bg-base-300 text-secondary uppercase tracking-widest"
                    >v1.1.0</span
                >
            </div>
            <div
                class="font-mono text-xs text-secondary flex items-center gap-6"
            >
                <div
                    class="flex items-center gap-2 pl-6 border-l border-base-300"
                >
                    <span class="w-2 h-2 rounded-full bg-primary animate-pulse"
                    ></span>
                    <span>SYSTEM: ONLINE</span>
                </div>
            </div>
        </div>
    </nav>

    <main class="max-w-7xl mx-auto p-6 md:p-12 lg:p-20 space-y-40">
        <!-- 1. Brand Core -->
        <section class="grid grid-cols-1 lg:grid-cols-12 gap-12 pt-12">
            <div class="lg:col-span-12 mb-8 border-b border-base-300 pb-12">
                <div
                    class="font-mono text-xs text-primary tracking-[0.2em] uppercase mb-4"
                >
                    01_CORE_IDENTITY
                </div>
                <h1
                    class="font-heading text-6xl md:text-8xl font-bold tracking-tighter text-base-content leading-none mb-8"
                >
                    The Sovereign <br />
                    <span class="text-primary">Architect.</span>
                </h1>
                <p
                    class="text-2xl md:text-3xl text-secondary font-light tracking-wide max-w-4xl leading-relaxed"
                >
                    Qwynk is not a service; it is infrastructure. We reject the
                    abstraction of "the cloud" in favor of bare-metal reality.
                    We do not ask for permission; we enforce protocols.
                </p>
            </div>

            <!-- Archetype Deep Dive -->
            <div class="lg:col-span-6 space-y-8">
                <h3 class="font-mono text-sm uppercase text-secondary mb-6">
                    Archetype Intersection
                </h3>
                <div
                    class="grid grid-cols-2 gap-px bg-base-300 border border-base-300"
                >
                    <div class="bg-base-100 p-8">
                        <h4 class="font-heading text-2xl mb-2">The Ruler</h4>
                        <p class="text-sm text-secondary mb-4">
                            Control. Stability. Order.
                        </p>
                        <ul
                            class="text-sm space-y-2 list-disc pl-4 text-secondary"
                        >
                            <li>Enforces structure</li>
                            <li>Eliminates chaos</li>
                            <li>Absolute authority</li>
                        </ul>
                    </div>
                    <div class="bg-base-100 p-8">
                        <h4 class="font-heading text-2xl mb-2">The Creator</h4>
                        <p class="text-sm text-secondary mb-4">
                            Engineering. Vision. Craft.
                        </p>
                        <ul
                            class="text-sm space-y-2 list-disc pl-4 text-secondary"
                        >
                            <li>Builds systems</li>
                            <li>Optimizes performance</li>
                            <li>Tangible results</li>
                        </ul>
                    </div>
                </div>
                <!-- Voice & Tone -->
                <div class="bg-base-100 p-8 border border-t-0 border-base-300">
                    <h4 class="font-heading text-2xl mb-4">The Voice</h4>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <div>
                            <strong
                                class="block font-mono text-xs uppercase text-primary mb-1"
                                >Precise</strong
                            >
                            <p class="text-sm text-secondary">
                                No ambiguity. No marketing fluff.
                            </p>
                        </div>
                        <div>
                            <strong
                                class="block font-mono text-xs uppercase text-primary mb-1"
                                >Laconic</strong
                            >
                            <p class="text-sm text-secondary">
                                Minimum words. Maximum impact.
                            </p>
                        </div>
                        <div>
                            <strong
                                class="block font-mono text-xs uppercase text-primary mb-1"
                                >Latency-Obsessed</strong
                            >
                            <p class="text-sm text-secondary">
                                Speed is a feature.
                            </p>
                        </div>
                    </div>
                    <div class="mt-6 pt-6 border-t border-base-300/50">
                        <p class="font-heading text-xl text-base-content">
                            "Traffic is a physical asset. Own it."
                        </p>
                    </div>
                </div>
            </div>

            <!-- Voice Translation Layer -->
            <div class="lg:col-span-6 space-y-8">
                <h3 class="font-mono text-sm uppercase text-secondary mb-6">
                    Voice Translation Layer
                </h3>
                <div class="border border-base-300">
                    <div
                        class="grid grid-cols-2 border-b border-base-300 bg-base-200/50"
                    >
                        <div
                            class="p-3 font-mono text-xs text-secondary uppercase tracking-widest"
                        >
                            Standard SaaS (Weak)
                        </div>
                        <div
                            class="p-3 font-mono text-xs text-primary uppercase tracking-widest border-l border-base-300"
                        >
                            Qwynk (Sovereign)
                        </div>
                    </div>

                    <div class="grid grid-cols-2 border-b border-base-300">
                        <div
                            class="p-4 text-sm text-secondary line-through decoration-error/50"
                        >
                            "We help you manage your traffic better."
                        </div>
                        <div
                            class="p-4 text-sm font-medium border-l border-base-300"
                        >
                            "Traffic is a physical asset. Own it."
                        </div>
                    </div>

                    <div class="grid grid-cols-2 border-b border-base-300">
                        <div
                            class="p-4 text-sm text-secondary line-through decoration-error/50"
                        >
                            "Oops! Something went wrong on our end."
                        </div>
                        <div
                            class="p-4 text-sm font-medium border-l border-base-300"
                        >
                            "SYSTEM_ERR: Connection Refused."
                        </div>
                    </div>

                    <div class="grid grid-cols-2">
                        <div
                            class="p-4 text-sm text-secondary line-through decoration-error/50"
                        >
                            "Please wait while we load your data..."
                        </div>
                        <div
                            class="p-4 text-sm font-medium border-l border-base-300"
                        >
                            "Initializing Sequence..."
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- 1.5 Brand Positioning & Messaging -->
        <section class="border-t border-base-300 pt-20">
            <div
                class="flex flex-col md:flex-row md:items-baseline justify-between mb-16 gap-4"
            >
                <div>
                    <div
                        class="font-mono text-xs text-primary tracking-[0.2em] uppercase mb-2"
                    >
                        01B_POSITIONING
                    </div>
                    <h2 class="font-heading text-4xl md:text-5xl font-bold">
                        Strategic Position
                    </h2>
                </div>
                <p class="max-w-md text-secondary">
                    Who we serve, how we compete, and what we promise.
                </p>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-16">
                <!-- Target Audience -->
                <div class="space-y-8">
                    <h3
                        class="font-mono text-sm uppercase text-secondary border-b border-base-300 pb-2"
                    >
                        Target Audience
                    </h3>

                    <div class="space-y-6">
                        <div class="glass-panel p-6">
                            <div
                                class="flex items-center gap-3 mb-4 pb-4 border-b border-base-300/50"
                            >
                                <span
                                    class="font-mono text-xs px-2 py-1 bg-primary/20 text-primary border border-primary"
                                    >PRIMARY</span
                                >
                                <h4 class="font-heading text-xl">
                                    Engineering-Led Teams
                                </h4>
                            </div>
                            <ul
                                class="text-sm space-y-2 list-disc pl-4 text-secondary"
                            >
                                <li>CTOs, VPs of Engineering, DevOps Teams</li>
                                <li>10-500 employee SaaS companies</li>
                                <li>Custom link infrastructure needs</li>
                                <li>Performance-obsessed technical buyers</li>
                            </ul>
                        </div>

                        <div class="glass-panel p-6">
                            <div
                                class="flex items-center gap-3 mb-4 pb-4 border-b border-base-300/50"
                            >
                                <span
                                    class="font-mono text-xs px-2 py-1 bg-secondary/20 text-secondary border border-secondary"
                                    >SECONDARY</span
                                >
                                <h4 class="font-heading text-xl">
                                    Growth & Product
                                </h4>
                            </div>
                            <ul
                                class="text-sm space-y-2 list-disc pl-4 text-secondary"
                            >
                                <li>Growth marketers & product managers</li>
                                <li>Need granular traffic insights</li>
                                <li>Require reliable, low-latency redirects</li>
                                <li>
                                    Value control over third-party dependencies
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- Competitive Differentiation -->
                <div class="space-y-8">
                    <h3
                        class="font-mono text-sm uppercase text-secondary border-b border-base-300 pb-2"
                    >
                        Competitive Differentiation
                    </h3>

                    <div class="border border-base-300">
                        <div
                            class="grid grid-cols-2 border-b border-base-300 bg-base-200/50"
                        >
                            <div
                                class="p-3 font-mono text-xs text-primary uppercase tracking-widest"
                            >
                                Qwynk
                            </div>
                            <div
                                class="p-3 font-mono text-xs text-secondary uppercase tracking-widest border-l border-base-300"
                            >
                                Competitors
                            </div>
                        </div>

                        <div class="grid grid-cols-2 border-b border-base-300">
                            <div class="p-4 text-sm font-medium">
                                Bare-metal reality
                            </div>
                            <div
                                class="p-4 text-sm text-secondary border-l border-base-300"
                            >
                                "Cloud magic" abstraction
                            </div>
                        </div>

                        <div class="grid grid-cols-2 border-b border-base-300">
                            <div class="p-4 text-sm font-medium">
                                Absolute sovereignty
                            </div>
                            <div
                                class="p-4 text-sm text-secondary border-l border-base-300"
                            >
                                Managed convenience
                            </div>
                        </div>

                        <div class="grid grid-cols-2 border-b border-base-300">
                            <div class="p-4 text-sm font-medium">
                                GDPR-first, zero PII
                            </div>
                            <div
                                class="p-4 text-sm text-secondary border-l border-base-300"
                            >
                                Cookie tracking, data mining
                            </div>
                        </div>

                        <div class="grid grid-cols-2 border-b border-base-300">
                            <div class="p-4 text-sm font-medium">
                                &lt;5ms internal latency
                            </div>
                            <div
                                class="p-4 text-sm text-secondary border-l border-base-300"
                            >
                                "Fast enough"
                            </div>
                        </div>

                        <div class="grid grid-cols-2">
                            <div class="p-4 text-sm font-medium">
                                Technical precision
                            </div>
                            <div
                                class="p-4 text-sm text-secondary border-l border-base-300"
                            >
                                Marketing fluff
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Value Propositions -->
                <div class="col-span-full mt-8">
                    <h3
                        class="font-mono text-sm uppercase text-secondary border-b border-base-300 pb-2 mb-8"
                    >
                        Value Propositions
                    </h3>

                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <div class="glass-panel p-8">
                            <div
                                class="font-mono text-xs text-primary mb-3 tracking-widest"
                            >
                                FOR_ENGINEERING
                            </div>
                            <h4 class="font-heading text-2xl mb-4">
                                Own Your Traffic Infrastructure.
                            </h4>
                            <p class="text-sm text-secondary">
                                Self-hosted with &lt;5ms redirect latency.
                                ETS-cached resilience (works even if DB fails).
                                Full data sovereignty.
                            </p>
                        </div>

                        <div class="glass-panel p-8">
                            <div
                                class="font-mono text-xs text-primary mb-3 tracking-widest"
                            >
                                FOR_GROWTH
                            </div>
                            <h4 class="font-heading text-2xl mb-4">
                                Attribution Without Abstraction.
                            </h4>
                            <p class="text-sm text-secondary">
                                GDPR-compliant analytics with zero cookies.
                                Real-time insights. Privacy-first click tracking
                                without PII storage.
                            </p>
                        </div>

                        <div class="glass-panel p-8">
                            <div
                                class="font-mono text-xs text-primary mb-3 tracking-widest"
                            >
                                FOR_LEADERSHIP
                            </div>
                            <h4 class="font-heading text-2xl mb-4">
                                Infrastructure as Competitive Advantage.
                            </h4>
                            <p class="text-sm text-secondary">
                                Treat traffic like the physical asset it is. No
                                vendor lock-in. Privacy compliance built-in.
                                Reduce dependencies.
                            </p>
                        </div>
                    </div>
                </div>

                <!-- Messaging Hierarchy -->
                <div class="col-span-full mt-8">
                    <h3
                        class="font-mono text-sm uppercase text-secondary border-b border-base-300 pb-2 mb-8"
                    >
                        Messaging Hierarchy
                    </h3>

                    <div class="space-y-6">
                        <div class="glass-panel p-8">
                            <div
                                class="font-mono text-xs text-primary mb-4 tracking-widest flex items-center gap-2"
                            >
                                <span class="w-2 h-2 rounded-full bg-primary"
                                ></span>
                                ELEVATOR_PITCH (15 seconds)
                            </div>
                            <p
                                class="text-xl text-base-content leading-relaxed"
                            >
                                "Qwynk is privacy-first, self-hosted link
                                infrastructure. Think Bitly, but GDPR-compliant,
                                &lt;5ms latency, zero vendor lock-in. Built for
                                teams who treat traffic as a physical asset."
                            </p>
                        </div>

                        <div class="glass-panel p-8">
                            <div
                                class="font-mono text-xs text-secondary mb-4 tracking-widest"
                            >
                                EXTENDED_PITCH (30 seconds)
                            </div>
                            <p class="text-lg text-secondary leading-relaxed">
                                "Most link shorteners are SaaS black boxes that
                                track your users, create latency bottlenecks,
                                and risk vendor lock-in. Qwynk runs on your
                                infrastructure—giving you &lt;5ms redirects,
                                GDPR-compliant analytics with zero PII storage,
                                and memorable 'Goblin-Speak' slugs like
                                'zip-zap'. It's infrastructure, not a service."
                            </p>
                        </div>

                        <div class="border border-base-300">
                            <div
                                class="grid grid-cols-2 border-b border-base-300 bg-base-200/50"
                            >
                                <div
                                    class="p-3 font-mono text-xs text-secondary uppercase tracking-widest"
                                >
                                    Context
                                </div>
                                <div
                                    class="p-3 font-mono text-xs text-secondary uppercase tracking-widest border-l border-base-300"
                                >
                                    Tagline
                                </div>
                            </div>

                            <div
                                class="grid grid-cols-2 border-b border-base-300"
                            >
                                <div
                                    class="p-4 text-sm font-mono text-secondary"
                                >
                                    Homepage Hero
                                </div>
                                <div
                                    class="p-4 text-sm font-medium border-l border-base-300"
                                >
                                    "Traffic is a physical asset. Own it."
                                </div>
                            </div>

                            <div
                                class="grid grid-cols-2 border-b border-base-300"
                            >
                                <div
                                    class="p-4 text-sm font-mono text-secondary"
                                >
                                    Documentation Header
                                </div>
                                <div
                                    class="p-4 text-sm font-medium border-l border-base-300"
                                >
                                    "Infrastructure-grade link routing."
                                </div>
                            </div>

                            <div
                                class="grid grid-cols-2 border-b border-base-300"
                            >
                                <div
                                    class="p-4 text-sm font-mono text-secondary"
                                >
                                    GitHub README
                                </div>
                                <div
                                    class="p-4 text-sm font-medium border-l border-base-base-300"
                                >
                                    "Self-hosted link management with sub-10ms
                                    latency."
                                </div>
                            </div>

                            <div class="grid grid-cols-2">
                                <div
                                    class="p-4 text-sm font-mono text-secondary"
                                >
                                    Social Bio
                                </div>
                                <div
                                    class="p-4 text-sm font-medium border-l border-base-300"
                                >
                                    "Bare-metal link infrastructure. No cloud.
                                    No abstraction."
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- 2. Typography: The Tri-Type Stack -->
        <section class="border-t border-base-300 pt-20">
            <div
                class="flex flex-col md:flex-row md:items-baseline justify-between mb-16 gap-4"
            >
                <div>
                    <div
                        class="font-mono text-xs text-primary tracking-[0.2em] uppercase mb-2"
                    >
                        02_TYPOGRAPHY
                    </div>
                    <h2 class="font-heading text-4xl md:text-5xl font-bold">
                        The Tri-Type Stack
                    </h2>
                </div>
                <p class="max-w-md text-secondary">
                    Three fonts to strictly separate hierarchy, interface, and
                    raw data.
                </p>
            </div>

            <div class="space-y-24">
                <!-- A. Space Grotesk - The Voice -->
                <div class="grid grid-cols-1 lg:grid-cols-12 gap-12">
                    <div class="lg:col-span-5 space-y-6">
                        <div>
                            <div
                                class="font-mono text-xs text-primary uppercase tracking-widest mb-2"
                            >
                                A. THE VOICE
                            </div>
                            <h3 class="font-heading text-3xl mb-4">
                                Space Grotesk
                            </h3>
                            <div
                                class="font-mono text-sm space-y-2 text-secondary"
                            >
                                <div class="flex gap-8">
                                    <span class="w-20">Weight:</span>
                                    <span class="text-base-content"
                                        >Bold (700)</span
                                    >
                                </div>
                                <div class="flex gap-8">
                                    <span class="w-20">Tracking:</span>
                                    <span class="text-base-content"
                                        >-0.025em</span
                                    >
                                </div>
                                <div class="flex gap-8">
                                    <span class="w-20">Source:</span>
                                    <a
                                        href="https://fonts.google.com/specimen/Space+Grotesk"
                                        class="text-primary hover:underline"
                                        >Google Fonts</a
                                    >
                                </div>
                            </div>
                        </div>
                        <div class="pt-4 border-t border-base-300/50">
                            <div
                                class="font-mono text-xs uppercase tracking-widest text-primary mb-2"
                            >
                                USAGE
                            </div>
                            <p class="text-sm text-secondary mb-4">
                                Page Titles, Hero Text, KPI Values. A grotesque
                                sans-serif with brutal, idiosyncratic geometry.
                                Feels like heavy machinery.
                            </p>
                            <div class="space-y-2">
                                <div class="flex items-baseline gap-3">
                                    <span class="text-success">✓</span>
                                    <span class="text-sm text-secondary"
                                        >Headlines and display text</span
                                    >
                                </div>
                                <div class="flex items-baseline gap-3">
                                    <span class="text-success">✓</span>
                                    <span class="text-sm text-secondary"
                                        >Large metric numbers</span
                                    >
                                </div>
                                <div class="flex items-baseline gap-3">
                                    <span class="text-error">✗</span>
                                    <span class="text-sm text-secondary"
                                        >Body copy or paragraphs</span
                                    >
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="lg:col-span-7">
                        <div
                            class="border border-base-300 bg-base-200/30 p-8 space-y-8"
                        >
                            <div>
                                <div
                                    class="font-mono text-[10px] text-secondary mb-3"
                                >
                                    DISPLAY
                                </div>
                                <p
                                    class="font-heading text-7xl tracking-tighter leading-none"
                                >
                                    QWYNK
                                </p>
                            </div>
                            <div>
                                <div
                                    class="font-mono text-[10px] text-secondary mb-3"
                                >
                                    HERO TEXT
                                </div>
                                <p
                                    class="font-heading text-5xl tracking-tighter leading-tight"
                                >
                                    Traffic is a physical asset.
                                </p>
                            </div>
                            <div>
                                <div
                                    class="font-mono text-[10px] text-secondary mb-3"
                                >
                                    KPI VALUE
                                </div>
                                <p
                                    class="font-heading text-6xl tracking-tighter text-primary"
                                >
                                    12,847
                                </p>
                            </div>
                            <div class="pt-6 border-t border-base-300/50">
                                <div class="font-mono text-xs text-secondary">
                                    Aa Bb Cc Dd Ee Ff Gg Hh Ii Jj Kk Ll Mm<br />
                                    Nn Oo Pp Qq Rr Ss Tt Uu Vv Ww Xx Yy Zz<br />
                                    0123456789 !@#$%^&*()
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- B. IBM Plex Sans - The Fabric -->
                <div class="grid grid-cols-1 lg:grid-cols-12 gap-12">
                    <div class="lg:col-span-5 space-y-6">
                        <div>
                            <div
                                class="font-mono text-xs text-primary uppercase tracking-widest mb-2"
                            >
                                B. THE FABRIC
                            </div>
                            <h3 class="font-heading text-3xl mb-4">
                                IBM Plex Sans
                            </h3>
                            <div
                                class="font-mono text-sm space-y-2 text-secondary"
                            >
                                <div class="flex gap-8">
                                    <span class="w-20">Weight:</span>
                                    <span class="text-base-content"
                                        >Regular (400), Medium (500)</span
                                    >
                                </div>
                                <div class="flex gap-8">
                                    <span class="w-20">Tracking:</span>
                                    <span class="text-base-content">Normal</span
                                    >
                                </div>
                                <div class="flex gap-8">
                                    <span class="w-20">Source:</span>
                                    <a
                                        href="https://fonts.google.com/specimen/IBM+Plex+Sans"
                                        class="text-primary hover:underline"
                                        >Google Fonts</a
                                    >
                                </div>
                            </div>
                        </div>
                        <div class="pt-4 border-t border-base-300/50">
                            <div
                                class="font-mono text-xs uppercase tracking-widest text-primary mb-2"
                            >
                                USAGE
                            </div>
                            <p class="text-sm text-secondary mb-4">
                                Buttons, Navigation, Tables, Settings. "Mankind
                                and Machine." Engineered for readability with
                                distinct humanist angles.
                            </p>
                            <div class="space-y-2">
                                <div class="flex items-baseline gap-3">
                                    <span class="text-success">✓</span>
                                    <span class="text-sm text-secondary"
                                        >UI labels and buttons</span
                                    >
                                </div>
                                <div class="flex items-baseline gap-3">
                                    <span class="text-success">✓</span>
                                    <span class="text-sm text-secondary"
                                        >Body text and descriptions</span
                                    >
                                </div>
                                <div class="flex items-baseline gap-3">
                                    <span class="text-success">✓</span>
                                    <span class="text-sm text-secondary"
                                        >Navigation and menus</span
                                    >
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="lg:col-span-7">
                        <div
                            class="border border-base-300 bg-base-200/30 p-8 space-y-8 font-sans"
                        >
                            <div>
                                <div
                                    class="font-mono text-[10px] text-secondary mb-3"
                                >
                                    BUTTON TEXT
                                </div>
                                <button class="btn btn-primary">
                                    Deploy Infrastructure
                                </button>
                            </div>
                            <div>
                                <div
                                    class="font-mono text-[10px] text-secondary mb-3"
                                >
                                    BODY TEXT
                                </div>
                                <p class="text-base leading-relaxed">
                                    Qwynk is not a service; it is
                                    infrastructure. We reject the abstraction of
                                    "the cloud" in favor of bare-metal reality.
                                    We do not ask for permission; we enforce
                                    protocols.
                                </p>
                            </div>
                            <div>
                                <div
                                    class="font-mono text-[10px] text-secondary mb-3"
                                >
                                    LABELS
                                </div>
                                <div class="space-y-2">
                                    <div class="text-sm font-medium">
                                        Target Host
                                    </div>
                                    <div class="text-xs text-secondary">
                                        Deployment Region
                                    </div>
                                </div>
                            </div>
                            <div class="pt-6 border-t border-base-300/50">
                                <div class="text-sm text-secondary">
                                    Aa Bb Cc Dd Ee Ff Gg Hh Ii Jj Kk Ll Mm<br />
                                    Nn Oo Pp Qq Rr Ss Tt Uu Vv Ww Xx Yy Zz<br />
                                    0123456789 !@#$%^&*()
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- C. IBM Plex Mono - The Truth -->
                <div class="grid grid-cols-1 lg:grid-cols-12 gap-12">
                    <div class="lg:col-span-5 space-y-6">
                        <div>
                            <div
                                class="font-mono text-xs text-primary uppercase tracking-widest mb-2"
                            >
                                C. THE TRUTH
                            </div>
                            <h3 class="font-heading text-3xl mb-4">
                                IBM Plex Mono
                            </h3>
                            <div
                                class="font-mono text-sm space-y-2 text-secondary"
                            >
                                <div class="flex gap-8">
                                    <span class="w-20">Weight:</span>
                                    <span class="text-base-content"
                                        >Regular (400)</span
                                    >
                                </div>
                                <div class="flex gap-8">
                                    <span class="w-20">Tracking:</span>
                                    <span class="text-base-content">Wide</span>
                                </div>
                                <div class="flex gap-8">
                                    <span class="w-20">Source:</span>
                                    <a
                                        href="https://fonts.google.com/specimen/IBM+Plex+Mono"
                                        class="text-primary hover:underline"
                                        >Google Fonts</a
                                    >
                                </div>
                            </div>
                        </div>
                        <div class="pt-4 border-t border-base-300/50">
                            <div
                                class="font-mono text-xs uppercase tracking-widest text-primary mb-2"
                            >
                                USAGE
                            </div>
                            <p class="text-sm text-secondary mb-4">
                                Link Slugs, Visitor Hashes, IP Addresses,
                                Console Logs. Creates a unified "blueprint"
                                aesthetic. Crisp, unpretentious, highly legible
                                for technical data.
                            </p>
                            <div class="space-y-2">
                                <div class="flex items-baseline gap-3">
                                    <span class="text-success">✓</span>
                                    <span class="text-sm text-secondary"
                                        >Code and terminal output</span
                                    >
                                </div>
                                <div class="flex items-baseline gap-3">
                                    <span class="text-success">✓</span>
                                    <span class="text-sm text-secondary"
                                        >IDs, hashes, timestamps</span
                                    >
                                </div>
                                <div class="flex items-baseline gap-3">
                                    <span class="text-success">✓</span>
                                    <span class="text-sm text-secondary"
                                        >Technical data and metrics</span
                                    >
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="lg:col-span-7">
                        <div
                            class="border border-base-300 bg-base-200/30 p-8 space-y-8 font-mono"
                        >
                            <div>
                                <div
                                    class="font-mono text-[10px] text-secondary mb-3"
                                >
                                    TERMINAL OUTPUT
                                </div>
                                <div class="text-sm space-y-1">
                                    <div class="text-primary">
                                        $ qwynk deploy --region=us-east-1
                                    </div>
                                    <div class="text-secondary">
                                        DEPLOYMENT_STARTED: 2025-01-15T08:42:00Z
                                    </div>
                                    <div class="text-base-content">
                                        STATUS: OPERATIONAL | LATENCY: 12ms
                                    </div>
                                </div>
                            </div>
                            <div>
                                <div
                                    class="font-mono text-[10px] text-secondary mb-3"
                                >
                                    DATA VALUES
                                </div>
                                <div class="text-sm space-y-1">
                                    <div>
                                        <span class="text-secondary"
                                            >LINK_ID:</span
                                        >
                                        <span class="text-primary"
                                            >lnk_8f92a9b2c3d4</span
                                        >
                                    </div>
                                    <div>
                                        <span class="text-secondary"
                                            >IP_ADDR:</span
                                        >
                                        <span class="text-base-content"
                                            >192.168.1.100</span
                                        >
                                    </div>
                                    <div>
                                        <span class="text-secondary"
                                            >TIMESTAMP:</span
                                        >
                                        <span class="text-base-content"
                                            >14:02:47.329</span
                                        >
                                    </div>
                                </div>
                            </div>
                            <div>
                                <div
                                    class="font-mono text-[10px] text-secondary mb-3"
                                >
                                    ERROR MESSAGE
                                </div>
                                <div class="text-sm text-error">
                                    ERR_CONN_REFUSED: Target host unreachable
                                </div>
                            </div>
                            <div class="pt-6 border-t border-base-300/50">
                                <div class="text-xs text-secondary">
                                    Aa Bb Cc Dd Ee Ff Gg Hh Ii Jj Kk Ll Mm<br />
                                    Nn Oo Pp Qq Rr Ss Tt Uu Vv Ww Xx Yy Zz<br />
                                    0123456789 !@#$%^&*() [] &lt;&gt; / \
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Typography Mixing Example -->
                <div class="glass-panel p-8">
                    <div
                        class="font-mono text-xs text-primary uppercase tracking-widest mb-6"
                    >
                        TYPOGRAPHY IN HARMONY
                    </div>
                    <div class="space-y-6">
                        <h4 class="font-heading text-4xl tracking-tighter">
                            System Status Dashboard
                        </h4>
                        <p class="font-sans text-lg text-secondary">
                            User <span class="font-mono text-primary"
                                >usr_892</span
                            >
                            accessed the deployment system at
                            <span class="font-mono text-base-content"
                                >14:02:00</span
                            >
                            from region
                            <span class="font-mono text-base-content"
                                >US-EAST-1</span
                            >.
                        </p>
                        <div class="pt-4 border-t border-base-300/50">
                            <div
                                class="font-heading text-2xl tracking-tight text-primary mb-1"
                            >
                                12,847
                            </div>
                            <div class="font-sans text-sm text-secondary">
                                Total Redirects
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- 3. Color Palette: "Bioluminescence" -->
        <section class="border-t border-base-300 pt-20">
            <div
                class="flex flex-col md:flex-row md:items-baseline justify-between mb-16 gap-4"
            >
                <div>
                    <div
                        class="font-mono text-xs text-primary tracking-[0.2em] uppercase mb-2"
                    >
                        03_COLOR_PALETTE
                    </div>
                    <h2 class="font-heading text-4xl md:text-5xl font-bold">
                        Bioluminescence
                    </h2>
                </div>
                <p class="max-w-md text-secondary">
                    A strict dark-mode-only palette. Deep abyssal blue-black to
                    reduce eye fatigue and create atmosphere.
                </p>
            </div>

            <div class="space-y-12">
                <!-- Abyssal Void -->
                <div
                    class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center"
                >
                    <div class="lg:col-span-4">
                        <div
                            class="h-64 w-full bg-[#020617] border border-base-300 rounded-sm shadow-2xl relative overflow-hidden"
                        >
                            <div
                                class="absolute inset-0 flex items-center justify-center"
                            >
                                <span
                                    class="font-heading text-6xl text-[#F1F5F9] tracking-tighter opacity-30"
                                >
                                    #020617
                                </span>
                            </div>
                        </div>
                    </div>
                    <div class="lg:col-span-8 space-y-4">
                        <div>
                            <h3 class="font-heading text-3xl mb-2">
                                Abyssal Void
                            </h3>
                            <div class="font-mono text-sm space-y-1">
                                <div class="flex gap-8">
                                    <span class="text-secondary">HEX:</span>
                                    <span class="text-primary">#020617</span>
                                </div>
                                <div class="flex gap-8">
                                    <span class="text-secondary">TW:</span>
                                    <span class="text-base-content"
                                        >slate-950</span
                                    >
                                </div>
                                <div class="flex gap-8">
                                    <span class="text-secondary">RGB:</span>
                                    <span class="text-base-content"
                                        >2, 6, 23</span
                                    >
                                </div>
                            </div>
                        </div>
                        <div class="pt-4 border-t border-base-300/50">
                            <div
                                class="font-mono text-xs uppercase tracking-widest text-primary mb-2"
                            >
                                USAGE
                            </div>
                            <p class="text-sm text-secondary">
                                The Canvas. A deep, ink-blue black. Primary
                                background for all interfaces.
                            </p>
                        </div>
                    </div>
                </div>

                <!-- Deep Hull -->
                <div
                    class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center"
                >
                    <div class="lg:col-span-4">
                        <div
                            class="h-64 w-full bg-[#0F172A] border border-base-300 rounded-sm shadow-2xl relative overflow-hidden"
                        >
                            <div
                                class="absolute inset-0 flex items-center justify-center"
                            >
                                <span
                                    class="font-heading text-6xl text-[#F1F5F9] tracking-tighter opacity-30"
                                >
                                    #0F172A
                                </span>
                            </div>
                        </div>
                    </div>
                    <div class="lg:col-span-8 space-y-4">
                        <div>
                            <h3 class="font-heading text-3xl mb-2">
                                Deep Hull
                            </h3>
                            <div class="font-mono text-sm space-y-1">
                                <div class="flex gap-8">
                                    <span class="text-secondary">HEX:</span>
                                    <span class="text-primary">#0F172A</span>
                                </div>
                                <div class="flex gap-8">
                                    <span class="text-secondary">TW:</span>
                                    <span class="text-base-content"
                                        >slate-900</span
                                    >
                                </div>
                                <div class="flex gap-8">
                                    <span class="text-secondary">RGB:</span>
                                    <span class="text-base-content"
                                        >15, 23, 42</span
                                    >
                                </div>
                            </div>
                        </div>
                        <div class="pt-4 border-t border-base-300/50">
                            <div
                                class="font-mono text-xs uppercase tracking-widest text-primary mb-2"
                            >
                                USAGE
                            </div>
                            <p class="text-sm text-secondary">
                                Cards / Panels. Slightly lighter for visual
                                hierarchy. Surface element backgrounds.
                            </p>
                        </div>
                    </div>
                </div>

                <!-- Cyan Flux -->
                <div
                    class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center"
                >
                    <div class="lg:col-span-4">
                        <div
                            class="h-64 w-full bg-[#2DD4BF] border border-base-300 rounded-sm shadow-2xl relative overflow-hidden"
                        >
                            <div
                                class="absolute inset-0 flex items-center justify-center"
                            >
                                <span
                                    class="font-heading text-6xl text-[#020617] tracking-tighter opacity-60"
                                >
                                    #2DD4BF
                                </span>
                            </div>
                            <div
                                class="absolute inset-0 shadow-[inset_0_0_60px_rgba(45,212,191,0.3)]"
                            ></div>
                        </div>
                    </div>
                    <div class="lg:col-span-8 space-y-4">
                        <div>
                            <h3 class="font-heading text-3xl mb-2 text-primary">
                                Cyan Flux
                            </h3>
                            <div class="font-mono text-sm space-y-1">
                                <div class="flex gap-8">
                                    <span class="text-secondary">HEX:</span>
                                    <span class="text-primary">#2DD4BF</span>
                                </div>
                                <div class="flex gap-8">
                                    <span class="text-secondary">TW:</span>
                                    <span class="text-base-content"
                                        >teal-400</span
                                    >
                                </div>
                                <div class="flex gap-8">
                                    <span class="text-secondary">RGB:</span>
                                    <span class="text-base-content"
                                        >45, 212, 191</span
                                    >
                                </div>
                                <div class="flex gap-8">
                                    <span class="text-secondary">WCAG:</span>
                                    <span class="text-success"
                                        >12.4:1 (AAA)</span
                                    >
                                </div>
                            </div>
                        </div>
                        <div class="pt-4 border-t border-base-300/50">
                            <div
                                class="font-mono text-xs uppercase tracking-widest text-primary mb-2"
                            >
                                USAGE
                            </div>
                            <p class="text-sm text-secondary">
                                The Signal. PRIMARY color. Buttons, active
                                states, data lines, links. The bioluminescent
                                glow in the dark.
                            </p>
                        </div>
                    </div>
                </div>

                <!-- Reactor Red -->
                <div
                    class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center"
                >
                    <div class="lg:col-span-4">
                        <div
                            class="h-64 w-full bg-[#F87171] border border-base-300 rounded-sm shadow-2xl relative overflow-hidden"
                        >
                            <div
                                class="absolute inset-0 flex items-center justify-center"
                            >
                                <span
                                    class="font-heading text-6xl text-[#020617] tracking-tighter opacity-60"
                                >
                                    #F87171
                                </span>
                            </div>
                            <div
                                class="absolute inset-0 shadow-[inset_0_0_60px_rgba(248,113,113,0.2)]"
                            ></div>
                        </div>
                    </div>
                    <div class="lg:col-span-8 space-y-4">
                        <div>
                            <h3 class="font-heading text-3xl mb-2 text-error">
                                Reactor Red
                            </h3>
                            <div class="font-mono text-sm space-y-1">
                                <div class="flex gap-8">
                                    <span class="text-secondary">HEX:</span>
                                    <span class="text-error">#F87171</span>
                                </div>
                                <div class="flex gap-8">
                                    <span class="text-secondary">TW:</span>
                                    <span class="text-base-content"
                                        >red-400</span
                                    >
                                </div>
                                <div class="flex gap-8">
                                    <span class="text-secondary">RGB:</span>
                                    <span class="text-base-content"
                                        >248, 113, 113</span
                                    >
                                </div>
                                <div class="flex gap-8">
                                    <span class="text-secondary">WCAG:</span>
                                    <span class="text-success">7.8:1 (AA)</span>
                                </div>
                            </div>
                        </div>
                        <div class="pt-4 border-t border-base-300/50">
                            <div
                                class="font-mono text-xs uppercase tracking-widest text-error mb-2"
                            >
                                USAGE
                            </div>
                            <p class="text-sm text-secondary">
                                Errors. SECONDARY color. Softer than pure red to
                                prevent vibration on dark backgrounds.
                            </p>
                        </div>
                    </div>
                </div>

                <!-- Ice White -->
                <div
                    class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center"
                >
                    <div class="lg:col-span-4">
                        <div
                            class="h-64 w-full bg-[#F1F5F9] border border-base-300 rounded-sm shadow-2xl relative overflow-hidden"
                        >
                            <div
                                class="absolute inset-0 flex items-center justify-center"
                            >
                                <span
                                    class="font-heading text-6xl text-[#020617] tracking-tighter opacity-20"
                                >
                                    #F1F5F9
                                </span>
                            </div>
                        </div>
                    </div>
                    <div class="lg:col-span-8 space-y-4">
                        <div>
                            <h3 class="font-heading text-3xl mb-2">
                                Ice White
                            </h3>
                            <div class="font-mono text-sm space-y-1">
                                <div class="flex gap-8">
                                    <span class="text-secondary">HEX:</span>
                                    <span class="text-primary">#F1F5F9</span>
                                </div>
                                <div class="flex gap-8">
                                    <span class="text-secondary">TW:</span>
                                    <span class="text-base-content"
                                        >slate-100</span
                                    >
                                </div>
                                <div class="flex gap-8">
                                    <span class="text-secondary">RGB:</span>
                                    <span class="text-base-content"
                                        >241, 245, 249</span
                                    >
                                </div>
                                <div class="flex gap-8">
                                    <span class="text-secondary">WCAG:</span>
                                    <span class="text-success">16:1 (AAA)</span>
                                </div>
                            </div>
                        </div>
                        <div class="pt-4 border-t border-base-300/50">
                            <div
                                class="font-mono text-xs uppercase tracking-widest text-primary mb-2"
                            >
                                USAGE
                            </div>
                            <p class="text-sm text-secondary">
                                Primary Reading. Crisp, cool white. Main text
                                color. High contrast against Abyssal Void.
                            </p>
                        </div>
                    </div>
                </div>

                <!-- Steel Grey -->
                <div
                    class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center"
                >
                    <div class="lg:col-span-4">
                        <div
                            class="h-64 w-full bg-[#94A3B8] border border-base-300 rounded-sm shadow-2xl relative overflow-hidden"
                        >
                            <div
                                class="absolute inset-0 flex items-center justify-center"
                            >
                                <span
                                    class="font-heading text-6xl text-[#020617] tracking-tighter opacity-40"
                                >
                                    #94A3B8
                                </span>
                            </div>
                        </div>
                    </div>
                    <div class="lg:col-span-8 space-y-4">
                        <div>
                            <h3
                                class="font-heading text-3xl mb-2 text-secondary"
                            >
                                Steel Grey
                            </h3>
                            <div class="font-mono text-sm space-y-1">
                                <div class="flex gap-8">
                                    <span class="text-secondary">HEX:</span>
                                    <span class="text-primary">#94A3B8</span>
                                </div>
                                <div class="flex gap-8">
                                    <span class="text-secondary">TW:</span>
                                    <span class="text-base-content"
                                        >slate-400</span
                                    >
                                </div>
                                <div class="flex gap-8">
                                    <span class="text-secondary">RGB:</span>
                                    <span class="text-base-content"
                                        >148, 163, 184</span
                                    >
                                </div>
                                <div class="flex gap-8">
                                    <span class="text-secondary">WCAG:</span>
                                    <span class="text-success">8.3:1 (AAA)</span
                                    >
                                </div>
                            </div>
                        </div>
                        <div class="pt-4 border-t border-base-300/50">
                            <div
                                class="font-mono text-xs uppercase tracking-widest text-secondary mb-2"
                            >
                                USAGE
                            </div>
                            <p class="text-sm text-secondary">
                                Metadata. Muted text. Blue-tinted grey to match
                                the void. Labels, timestamps, secondary
                                information.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- 4. Components Anatomy -->
        <section class="border-t border-base-300 pt-20">
            <div
                class="flex flex-col md:flex-row md:items-baseline justify-between mb-16 gap-4"
            >
                <div>
                    <div
                        class="font-mono text-xs text-primary tracking-[0.2em] uppercase mb-2"
                    >
                        04_ARCHITECTURE
                    </div>
                    <h2 class="font-heading text-4xl md:text-5xl font-bold">
                        Component Anatomy
                    </h2>
                </div>
                <p class="max-w-md text-secondary">
                    Deconstructing the atomic units of the interface.
                </p>
            </div>

            <div class="space-y-24">
                <!-- The Data Table -->
                <div class="grid grid-cols-1 lg:grid-cols-12 gap-12">
                    <div class="lg:col-span-4 space-y-6">
                        <h3 class="font-heading text-2xl">The Data Table</h3>
                        <p class="text-sm text-secondary">
                            The primary interface for Qwynk. Dense, legible, and
                            actionable.
                        </p>
                        <ul class="text-sm space-y-4 font-mono text-secondary">
                            <li class="flex gap-3">
                                <span class="text-primary">01</span>
                                <span
                                    >Header: Uppercase, tracking-widest,
                                    text-xs.</span
                                >
                            </li>
                            <li class="flex gap-3">
                                <span class="text-primary">02</span>
                                <span
                                    >Row: 48px height (12 units). Hover reveals
                                    actions.</span
                                >
                            </li>
                            <li class="flex gap-3">
                                <span class="text-primary">03</span>
                                <span
                                    >Font: Mono for IDs/Values, Sans for Names.</span
                                >
                            </li>
                        </ul>
                    </div>

                    <div class="lg:col-span-8">
                        <div class="border border-base-300 bg-base-100">
                            <!-- Table Header -->
                            <div
                                class="grid grid-cols-12 gap-4 px-6 py-3 border-b border-base-300 bg-base-200/30"
                            >
                                <div
                                    class="col-span-2 font-mono text-[10px] uppercase tracking-widest text-secondary"
                                >
                                    ID
                                </div>
                                <div
                                    class="col-span-4 font-mono text-[10px] uppercase tracking-widest text-secondary"
                                >
                                    Node Name
                                </div>
                                <div
                                    class="col-span-3 font-mono text-[10px] uppercase tracking-widest text-secondary"
                                >
                                    Status
                                </div>
                                <div
                                    class="col-span-3 font-mono text-[10px] uppercase tracking-widest text-secondary text-right"
                                >
                                    Latency
                                </div>
                            </div>

                            <!-- Table Row 1 -->
                            <div
                                class="grid grid-cols-12 gap-4 px-6 py-4 border-b border-base-300 hover:bg-base-200/50 transition-colors group cursor-pointer"
                            >
                                <div
                                    class="col-span-2 font-mono text-sm text-primary"
                                >
                                    #8F2A
                                </div>
                                <div
                                    class="col-span-4 font-sans text-sm font-medium text-base-content"
                                >
                                    US-East-Gateway-01
                                </div>
                                <div class="col-span-3 flex items-center gap-2">
                                    <span
                                        class="w-1.5 h-1.5 rounded-full bg-success"
                                    ></span>
                                    <span
                                        class="font-mono text-xs text-secondary"
                                        >ACTIVE</span
                                    >
                                </div>
                                <div
                                    class="col-span-3 font-mono text-sm text-base-content text-right"
                                >
                                    12ms
                                </div>
                            </div>

                            <!-- Table Row 2 -->
                            <div
                                class="grid grid-cols-12 gap-4 px-6 py-4 border-b border-base-300 hover:bg-base-200/50 transition-colors group cursor-pointer"
                            >
                                <div
                                    class="col-span-2 font-mono text-sm text-primary"
                                >
                                    #9C3B
                                </div>
                                <div
                                    class="col-span-4 font-sans text-sm font-medium text-base-content"
                                >
                                    EU-West-Relay-04
                                </div>
                                <div class="col-span-3 flex items-center gap-2">
                                    <span
                                        class="w-1.5 h-1.5 rounded-full bg-warning animate-pulse"
                                    ></span>
                                    <span class="font-mono text-xs text-warning"
                                        >DEGRADED</span
                                    >
                                </div>
                                <div
                                    class="col-span-3 font-mono text-sm text-warning text-right"
                                >
                                    145ms
                                </div>
                            </div>

                            <!-- Table Row 3 -->
                            <div
                                class="grid grid-cols-12 gap-4 px-6 py-4 hover:bg-base-200/50 transition-colors group cursor-pointer"
                            >
                                <div
                                    class="col-span-2 font-mono text-sm text-primary"
                                >
                                    #1A4F
                                </div>
                                <div
                                    class="col-span-4 font-sans text-sm font-medium text-base-content"
                                >
                                    AP-South-Edge-02
                                </div>
                                <div class="col-span-3 flex items-center gap-2">
                                    <span
                                        class="w-1.5 h-1.5 rounded-full bg-error"
                                    ></span>
                                    <span class="font-mono text-xs text-error"
                                        >OFFLINE</span
                                    >
                                </div>
                                <div
                                    class="col-span-3 font-mono text-sm text-error text-right"
                                >
                                    --
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Input Fields -->
                <div class="grid grid-cols-1 lg:grid-cols-12 gap-12">
                    <div class="lg:col-span-4 space-y-6">
                        <h3 class="font-heading text-2xl">Input Fields</h3>
                        <p class="text-sm text-secondary">
                            Inputs are brutally simple. No rounded corners.
                            Focus states are high-contrast Cyan.
                        </p>
                    </div>
                    <div
                        class="lg:col-span-8 grid grid-cols-1 md:grid-cols-2 gap-8"
                    >
                        <div class="space-y-2">
                            <div
                                class="font-mono text-xs uppercase tracking-widest text-secondary"
                            >
                                API Key
                            </div>
                            <input
                                type="text"
                                value="qk_live_8f92...9a2b"
                                class="w-full bg-base-100 border border-base-300 p-3 font-mono text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all"
                            />
                        </div>
                        <div class="space-y-2">
                            <div
                                class="font-mono text-xs uppercase tracking-widest text-error"
                            >
                                Target Host (Invalid)
                            </div>
                            <input
                                type="text"
                                value="192.168.0.999"
                                class="w-full bg-base-100 border border-error p-3 font-mono text-sm text-error focus:outline-none"
                            />
                            <p class="font-mono text-[10px] text-error">
                                ERR_INVALID_IP_FORMAT
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- 5. Motion Doctrine (Refined) -->
        <section class="border-t border-base-300 pt-20 pb-32">
            <div
                class="flex flex-col md:flex-row md:items-baseline justify-between mb-16 gap-4"
            >
                <div>
                    <div
                        class="font-mono text-xs text-primary tracking-[0.2em] uppercase mb-2"
                    >
                        05_KINETICS
                    </div>
                    <h2 class="font-heading text-4xl md:text-5xl font-bold">
                        Hydraulic Motion
                    </h2>
                </div>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-12">
                <div
                    class="glass-panel p-8 flex flex-col items-center justify-center min-h-[400px] relative overflow-hidden"
                >
                    <div
                        class="absolute inset-0 opacity-5"
                        style="background-image: linear-gradient(#2DD4BF 1px, transparent 1px), linear-gradient(90deg, #2DD4BF 1px, transparent 1px); background-size: 40px 40px;"
                    ></div>

                    <div class="relative z-10 w-full max-w-lg">
                        <div class="flex justify-between items-center mb-8">
                            <div class="font-mono text-xs text-secondary">
                                ACTUATOR_TEST
                            </div>
                            <button
                                class="btn btn-primary"
                                onclick={toggleMotion}
                            >
                                {motionState ? "RETRACT" : "DEPLOY"}
                            </button>
                        </div>

                        <div
                            class="h-64 border border-base-300 bg-base-100 relative overflow-hidden"
                        >
                            <div
                                class="absolute top-0 left-0 h-full bg-base-200 border-r border-primary transition-all duration-data ease-hydraulic"
                                style="width: {motionState ? '100%' : '0%'}"
                            >
                                <div
                                    class="absolute inset-0 bg-primary/5"
                                ></div>
                                <div
                                    class="absolute right-0 top-0 bottom-0 w-[1px] bg-primary shadow-[0_0_15px_#2DD4BF]"
                                ></div>
                                <div
                                    class="absolute inset-0 flex items-center justify-center transition-opacity duration-system delay-100"
                                    class:opacity-100={motionState}
                                    class:opacity-0={!motionState}
                                >
                                    <div class="text-center">
                                        <p
                                            class="font-heading text-4xl text-base-content tracking-tighter"
                                        >
                                            SYSTEM ACTIVE
                                        </p>
                                        <p
                                            class="font-mono text-xs text-primary mt-2 tracking-[0.5em]"
                                        >
                                            OPERATIONAL
                                        </p>
                                    </div>
                                </div>
                            </div>
                            <div
                                class="absolute inset-0 flex items-center justify-center opacity-20"
                            >
                                <p class="font-mono text-xs tracking-widest">
                                    WAITING FOR INPUT...
                                </p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="space-y-8">
                    <h3
                        class="font-mono text-sm uppercase text-secondary border-b border-base-300 pb-2"
                    >
                        The "Why"
                    </h3>
                    <p class="text-lg text-secondary leading-relaxed">
                        Motion in Qwynk is not for delight; it is for <strong
                            class="text-base-content">orientation</strong
                        >. It mimics the physics of heavy hydraulic
                        machinery—high torque, precise stops, zero bounce. This
                        reinforces the feeling of controlling a massive,
                        physical infrastructure.
                    </p>

                    <div class="bg-base-200/30 p-6 border border-base-300">
                        <h4 class="font-heading text-lg mb-4">
                            The Hydraulic Curve
                        </h4>
                        <div
                            class="h-32 w-full bg-base-100 border border-base-300 relative"
                        >
                            <svg
                                class="absolute inset-0 w-full h-full text-primary"
                                viewBox="0 0 100 100"
                                preserveAspectRatio="none"
                            >
                                <path
                                    d="M0,100 C19,100 22,0 100,0"
                                    fill="none"
                                    stroke="currentColor"
                                    stroke-width="2"
                                    vector-effect="non-scaling-stroke"
                                />
                            </svg>
                            <div
                                class="absolute bottom-2 left-2 font-mono text-[10px] text-secondary"
                            >
                                0%
                            </div>
                            <div
                                class="absolute top-2 right-2 font-mono text-[10px] text-secondary"
                            >
                                100%
                            </div>
                        </div>
                        <p class="font-mono text-xs text-secondary mt-2">
                            cubic-bezier(0.19, 1, 0.22, 1)
                        </p>
                    </div>

                    <!-- Motion Tokens Table -->
                    <div class="mt-12">
                        <h4 class="font-heading text-lg mb-4">Motion Tokens</h4>
                        <div class="overflow-x-auto border border-base-300">
                            <table class="w-full text-left text-sm">
                                <thead
                                    class="bg-base-200/50 font-mono text-xs uppercase text-secondary"
                                >
                                    <tr>
                                        <th class="p-3 border-b border-base-300"
                                            >Token</th
                                        >
                                        <th class="p-3 border-b border-base-300"
                                            >Time</th
                                        >
                                        <th class="p-3 border-b border-base-300"
                                            >Usage</th
                                        >
                                    </tr>
                                </thead>
                                <tbody
                                    class="divide-y divide-base-300 font-mono text-xs"
                                >
                                    <tr>
                                        <td class="p-3 text-primary">instant</td
                                        >
                                        <td class="p-3">0ms</td>
                                        <td class="p-3 text-secondary"
                                            >Errors, critical state changes</td
                                        >
                                    </tr>
                                    <tr>
                                        <td class="p-3 text-primary">ui</td>
                                        <td class="p-3">120ms</td>
                                        <td class="p-3 text-secondary"
                                            >Buttons, toggles, navigation</td
                                        >
                                    </tr>
                                    <tr>
                                        <td class="p-3 text-primary">system</td>
                                        <td class="p-3">200ms</td>
                                        <td class="p-3 text-secondary"
                                            >LiveView patches, component mounts</td
                                        >
                                    </tr>
                                    <tr>
                                        <td class="p-3 text-primary">data</td>
                                        <td class="p-3">320ms</td>
                                        <td class="p-3 text-secondary"
                                            >D3 updates, chart transitions</td
                                        >
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Footer -->
        <footer class="border-t border-base-300 py-12">
            <div
                class="flex flex-col md:flex-row justify-between items-end gap-6"
            >
                <div>
                    <p class="font-heading text-2xl font-bold">QWYNK</p>
                    <p class="font-mono text-xs text-secondary mt-2">
                        © 2025 Qwynk Systems. All rights reserved.
                    </p>
                </div>
                <div
                    class="font-mono text-xs text-secondary text-right space-y-1"
                >
                    <p>STATUS: OPERATIONAL</p>
                    <p>REGION: US-EAST-1</p>
                    <p>LATENCY: 12ms</p>
                </div>
            </div>
        </footer>
    </main>
</div>
