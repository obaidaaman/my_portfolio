<script setup lang="ts">
import { profile } from '../data/portfolioData'
import { ArrowUp } from 'lucide-vue-next'

const scrollToTop = () => {
  window.scrollTo({ top: 0, behavior: 'smooth' })
}
</script>

<template>
  <footer class="py-12 border-t border-zinc-800/80 bg-[#09090b] text-zinc-500 text-xs">
    <div class="max-w-6xl mx-auto px-5 sm:px-8 flex flex-col sm:flex-row items-center justify-between gap-6">
      <div class="flex items-center gap-3">
        <span class="font-mono font-semibold text-zinc-300">{{ profile.initials }}</span>
        <span>•</span>
        <span>© {{ new Date().getFullYear() }} {{ profile.name }}</span>
        <span class="hidden sm:inline">•</span>
        <span class="hidden sm:inline text-zinc-600 font-mono">Vue 3 + Vite</span>
      </div>

      <button
        @click="scrollToTop"
        class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded bg-zinc-900 border border-zinc-800 hover:border-zinc-700 text-zinc-400 hover:text-zinc-200 font-mono text-xs transition-colors"
      >
        <span>Back to top</span>
        <ArrowUp class="w-3.5 h-3.5" />
      </button>
    </div>
  </footer>
</template>
