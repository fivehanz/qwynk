<script lang="ts">
    import { SITE_CONFIG } from "../config";
</script>

<section
    class="relative flex min-h-[80vh] flex-col items-center justify-center overflow-hidden bg-base-100 px-4 text-center"
>
    <!-- Background Grid/Glow -->
    <div
        class="absolute inset-0 z-0 opacity-20"
        style="background-image: radial-gradient(#2DD4BF 1px, transparent 1px); background-size: 40px 40px;"
    ></div>
    <div
        class="absolute inset-0 z-0 bg-gradient-to-b from-transparent via-base-100/50 to-base-100"
    ></div>

    <!-- Content -->
    <div class="z-10 mx-auto w-full max-w-4xl px-4">
        <div
            class="mb-6 inline-block border border-primary/30 bg-primary/10 px-3 py-1 text-xs font-bold tracking-widest text-primary uppercase backdrop-blur-sm"
        >
            System Status: Operational
        </div>

        <h1
            class="mb-6 font-heading text-5xl font-bold leading-tight text-base-content md:text-7xl lg:text-8xl"
        >
            TRAFFIC IS A <br />
            <span class="text-primary">PHYSICAL ASSET.</span>
        </h1>

        <p
            class="mx-auto mb-10 max-w-2xl font-sans text-lg text-secondary md:text-xl"
        >
            Own it. Self-hosted link infrastructure with &lt;5ms latency.
            <br class="hidden md:block" />
            Privacy-first. Zero vendor lock-in. Bare-metal reality.
        </p>

        <div
            class="flex flex-col items-center justify-center gap-4 sm:flex-row"
        >
            <a
                href={SITE_CONFIG.githubUrl}
                class="btn btn-primary btn-lg min-w-[200px] rounded-none border-primary font-bold text-base-100 hover:bg-primary/90 hover:shadow-[0_0_20px_rgba(45,212,191,0.4)]"
            >
                DEPLOY NOW
            </a>
            <a
                href="#features"
                class="btn btn-outline btn-secondary btn-lg min-w-[200px] rounded-none border-secondary/50 font-mono hover:border-secondary hover:bg-secondary/10 hover:text-base-content"
            >
                READ_DOCS
            </a>
        </div>

        <!-- Terminal Output Decoration -->
        <div
            class="mx-auto mt-16 w-full max-w-2xl overflow-hidden border border-base-300 bg-base-200/50 p-4 text-left font-mono text-xs text-secondary backdrop-blur-md md:text-sm"
        >
            <div class="flex gap-2 pb-2 text-base-300">
                <div class="h-3 w-3 rounded-full bg-error/50"></div>
                <div class="h-3 w-3 rounded-full bg-warning/50"></div>
                <div class="h-3 w-3 rounded-full bg-success/50"></div>
            </div>
            <div class="space-y-1">
                <p>
                    <span class="text-primary">➜</span>
                    <span class="text-info">~</span> qwynk create --slug=product
                    --link=https://example.com
                </p>
                <p class="text-success">
                    ✔ LINK_CREATED: /product → https://example.com
                </p>
                <p class="text-secondary">Slug: product</p>
                <p>
                    <span class="text-primary">➜</span>
                    <span class="text-info">~</span>
                    <span class="animate-blink">&#9608;</span>
                </p>
            </div>
        </div>
    </div>
</section>
