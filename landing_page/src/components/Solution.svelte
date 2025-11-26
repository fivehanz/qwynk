<script lang="ts">
    // Solution.svelte
</script>

<section
    id="solution"
    class="relative overflow-hidden bg-base-200 py-24 text-base-content"
>
    <!-- Decorative Elements -->
    <div
        class="absolute -right-20 top-20 h-96 w-96 rounded-full bg-primary/5 blur-3xl"
    ></div>
    <div
        class="absolute -left-20 bottom-20 h-96 w-96 rounded-full bg-primary/5 blur-3xl"
    ></div>

    <div class="container mx-auto px-4">
        <div class="mb-16 text-center">
            <h2
                class="mb-4 font-heading text-4xl font-bold text-base-content md:text-5xl"
            >
                THE <span class="text-primary">SOVEREIGN</span> ARCHITECTURE
            </h2>
            <p class="mx-auto max-w-2xl font-sans text-secondary">
                Built on Elixir, Phoenix, and ETS. Designed for the Hot Path.
            </p>
        </div>

        <div class="grid grid-cols-1 gap-12 lg:grid-cols-2">
            <!-- Feature List -->
            <div class="space-y-8 min-w-0">
                <div class="flex gap-4">
                    <div
                        class="flex h-12 w-12 shrink-0 items-center justify-center border border-primary/50 bg-primary/10 text-primary font-mono text-xl font-bold"
                    >
                        01
                    </div>
                    <div>
                        <h3
                            class="mb-2 font-heading text-2xl font-bold text-base-content"
                        >
                            The Razor Router
                        </h3>
                        <p class="font-sans text-secondary">
                            Namespace separation eliminates lookup overhead. <span
                                class="font-mono text-primary">/_/</span
                            > for system internals, everything else is a slug. Zero
                            ambiguity.
                        </p>
                    </div>
                </div>

                <div class="flex gap-4">
                    <div
                        class="flex h-12 w-12 shrink-0 items-center justify-center border border-primary/50 bg-primary/10 text-primary font-mono text-xl font-bold"
                    >
                        02
                    </div>
                    <div>
                        <h3
                            class="mb-2 font-heading text-2xl font-bold text-base-content"
                        >
                            ETS Caching (Hot Path)
                        </h3>
                        <p class="font-sans text-secondary">
                            Redirects serve from RAM. <span
                                class="font-mono text-primary">&lt;5ms</span
                            > internal processing time. Database hits are asynchronous.
                            If the DB dies, the cache lives on.
                        </p>
                    </div>
                </div>

                <div class="flex gap-4">
                    <div
                        class="flex h-12 w-12 shrink-0 items-center justify-center border border-primary/50 bg-primary/10 text-primary font-mono text-xl font-bold"
                    >
                        03
                    </div>
                    <div>
                        <h3
                            class="mb-2 font-heading text-2xl font-bold text-base-content"
                        >
                            Privacy Buffer
                        </h3>
                        <p class="font-sans text-secondary">
                            GDPR-compliant by default. No PII storage. IPs are
                            hashed with a daily salt and discarded. Analytics
                            without surveillance.
                        </p>
                    </div>
                </div>
            </div>

            <!-- Technical Diagram / Code Block -->
            <div
                class="relative border border-base-300 bg-base-100 p-4 md:p-6 font-mono text-xs md:text-sm shadow-2xl min-w-0"
            >
                <div
                    class="absolute -top-3 left-4 bg-base-100 px-2 text-xs text-secondary uppercase tracking-widest"
                >
                    lib/qwynk/router.ex
                </div>
                <pre class="overflow-x-auto text-secondary">
<span class="text-primary">defmodule</span> Qwynk.Router <span
                        class="text-primary">do</span
                    >
  <span class="text-secondary opacity-50"># The Hot Path</span>
  <span class="text-primary">def</span> dispatch(conn, slug) <span
                        class="text-primary">do</span
                    >
    <span class="text-primary">case</span> Cache.lookup(slug) <span
                        class="text-primary">do</span
                    >
      &#123;<span class="text-warning">:ok</span>, target&#125; ->
        <span class="text-info">Task</span>.start(<span class="text-primary"
                        >fn</span
                    > -> Analytics.capture(conn) <span class="text-primary"
                        >end</span
                    >)
        redirect(conn, target)
      
      <span class="text-warning">:miss</span> ->
        <span class="text-secondary opacity-50"
                        ># Fallback to DB, then populate cache</span
                    >
        resolve_from_db(slug)
    <span class="text-primary">end</span>
  <span class="text-primary">end</span>
<span class="text-primary">end</span>
        </pre>
                <div
                    class="mt-4 flex flex-wrap items-center justify-between gap-2 border-t border-base-300 pt-4 text-xs"
                >
                    <span class="text-success">● Elixir 1.18</span>
                    <span class="text-success">● Phoenix 1.8</span>
                    <span class="text-success">● Ash 3.0</span>
                </div>
            </div>
        </div>
    </div>
</section>
