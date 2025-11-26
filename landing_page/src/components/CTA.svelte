<script lang="ts">
    import { SITE_CONFIG } from "../config";
</script>

<section class="border-t border-base-300 bg-base-100 py-24 text-center">
    <div class="container mx-auto px-4">
        <h2
            class="mb-8 font-heading text-5xl font-bold text-base-content md:text-6xl"
        >
            READY TO <span class="text-primary">TAKE CONTROL?</span>
        </h2>
        <div
            class="mx-auto mb-12 max-w-2xl space-y-2 font-sans text-xl text-secondary"
        >
            <p>Stop renting your infrastructure. Start owning it.</p>
            <p>
                Deploy via Docker or bare metal. Your infrastructure, your
                rules.
            </p>
        </div>

        <div
            class="flex flex-col items-center justify-center gap-6 sm:flex-row"
        >
            <a
                href={SITE_CONFIG.githubUrl}
                class="btn btn-primary btn-lg min-w-[240px] rounded-none border-primary text-xl font-bold text-base-100 hover:bg-primary/90 hover:shadow-[0_0_30px_rgba(45,212,191,0.5)]"
            >
                GITHUB_REPO
            </a>
        </div>

        <p class="mt-8 font-mono text-sm text-secondary opacity-70">
            Apache 2.0 Licensed. Open Source. Forever.
        </p>
    </div>
</section>
