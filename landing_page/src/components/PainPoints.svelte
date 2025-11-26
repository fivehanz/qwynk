<script lang="ts">
    // PainPoints.svelte
</script>

<section id="pain-points" class="bg-base-100 py-24 text-base-content">
    <div class="container mx-auto px-4">
        <div class="mb-16 text-center">
            <h2
                class="mb-4 font-heading text-4xl font-bold text-base-content md:text-5xl"
            >
                REJECT THE <span class="text-error">CLOUD ABSTRACTION</span>
            </h2>
            <p class="mx-auto max-w-2xl font-sans text-secondary">
                Your traffic is being routed through black boxes. You don't own
                the data. You don't control the latency. You are renting your
                own infrastructure.
            </p>
        </div>

        <div class="grid gap-8 md:grid-cols-3">
            <!-- Card 1 -->
            <div
                class="group border border-base-300 bg-base-200/30 p-8 transition-all hover:border-error/50 hover:bg-base-200/50"
            >
                <div class="mb-6 text-4xl text-error">⚠</div>
                <h3 class="mb-4 font-heading text-2xl font-bold">
                    Latency Tax
                </h3>
                <p class="font-sans text-secondary">
                    Every redirect adds 100ms+ of "cloud magic" overhead. Your
                    users wait while third-party servers handshake, track, and
                    resell their data.
                </p>
            </div>

            <!-- Card 2 -->
            <div
                class="group border border-base-300 bg-base-200/30 p-8 transition-all hover:border-error/50 hover:bg-base-200/50"
            >
                <div class="mb-6 text-4xl text-error">👁</div>
                <h3 class="mb-4 font-heading text-2xl font-bold">
                    Surveillance Capitalism
                </h3>
                <p class="font-sans text-secondary">
                    "Free" link shorteners are data brokers. They drop cookies,
                    fingerprint devices, and monetize your audience without your
                    consent.
                </p>
            </div>

            <!-- Card 3 -->
            <div
                class="group border border-base-300 bg-base-200/30 p-8 transition-all hover:border-error/50 hover:bg-base-200/50"
            >
                <div class="mb-6 text-4xl text-error">🔒</div>
                <h3 class="mb-4 font-heading text-2xl font-bold">
                    Vendor Lock-in
                </h3>
                <p class="font-sans text-secondary">
                    When they raise prices or change terms, you're trapped. Your
                    links are their property. Migrating is a broken promise.
                </p>
            </div>
        </div>
    </div>
</section>
