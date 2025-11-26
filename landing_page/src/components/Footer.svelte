<script lang="ts">
    import { SITE_CONFIG } from "../config";
    const year = new Date().getFullYear();
</script>

<footer
    class="border-t border-base-300 bg-base-200 py-12 text-center font-mono text-sm text-secondary"
>
    <div class="container mx-auto px-4">
        <div class="mb-4 text-2xl font-bold text-base-content">QWYNK</div>
        <p class="mb-8">Sovereign. Structural. Silent.</p>

        <div class="mb-8 flex justify-center gap-8">
            <a href="#" class="hover:text-primary">Documentation</a>
            <a href={SITE_CONFIG.githubUrl} class="hover:text-primary">GitHub</a
            >
            <a href="#" class="hover:text-primary">Twitter</a>
        </div>

        <p class="opacity-50">
            &copy; {year}
            <a href={SITE_CONFIG.authorUrl} class="hover:text-primary">Hanz</a>.
            All rights reserved.
        </p>
    </div>
</footer>
