<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { profile } from '../data/portfolioData'
import { ArrowDown, FileText, Send, Terminal, Code2 } from 'lucide-vue-next'

const currentRoleIndex = ref(0)
let timer: ReturnType<typeof setInterval> | null = null

onMounted(() => {
  timer = setInterval(() => {
    currentRoleIndex.value = (currentRoleIndex.value + 1) % profile.rotatingRoles.length
  }, 3200)
})

onUnmounted(() => {
  if (timer) clearInterval(timer)
})

const scrollTo = (id: string) => {
  const el = document.getElementById(id)
  if (el) el.scrollIntoView({ behavior: 'smooth' })
}
</script>

<template>
  <section id="home" class="relative pt-32 pb-20 md:pt-40 md:pb-28 overflow-hidden bg-subtle-grid">
    <div class="max-w-6xl mx-auto px-5 sm:px-8">
      <!-- Status Badge -->
      <div class="inline-flex items-center gap-2.5 px-3 py-1.5 rounded-full bg-zinc-900/90 border border-zinc-800 text-xs text-zinc-300 mb-8 backdrop-blur-sm">
        <span class="relative flex h-2 w-2">
          <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
          <span class="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
        </span>
        <span class="font-mono text-[11px] text-zinc-400">Available for GenAI & Backend Systems</span>
      </div>

      <!-- Main Heading & Title -->
      <div class="max-w-3xl">
        <h1 class="text-4xl sm:text-6xl md:text-7xl font-bold tracking-tight text-white mb-5 font-display leading-[1.08]">
          Hi, I'm <span class="text-zinc-100">{{ profile.name }}</span>
        </h1>

        <!-- Rotating role typewriter container -->
        <div class="flex items-center gap-2 mb-6 text-xl sm:text-2xl md:text-3xl font-medium text-zinc-300">
          <Terminal class="w-5 h-5 sm:w-6 sm:h-6 text-[#c49f5a] shrink-0" />
          <span class="text-zinc-400">Specializing in</span>
          <span class="font-mono font-semibold text-white border-b-2 border-[#c49f5a]/70 pb-0.5 transition-all duration-300">
            {{ profile.rotatingRoles[currentRoleIndex] }}
          </span>
        </div>

        <!-- Tagline -->
        <p class="text-base sm:text-lg text-zinc-400 leading-relaxed max-w-2xl mb-10">
          {{ profile.tagline }}
        </p>

        <!-- CTA Buttons -->
        <div class="flex flex-wrap items-center gap-3.5 mb-16">
          <button
            @click="scrollTo('projects')"
            class="inline-flex items-center gap-2 px-5 py-2.5 rounded-lg text-sm font-medium bg-zinc-100 hover:bg-white text-zinc-950 shadow-md transition-all duration-200 hover:-translate-y-0.5 active:translate-y-0"
          >
            <span>Explore Projects</span>
            <ArrowDown class="w-4 h-4 text-zinc-900" />
          </button>

          <button
            @click="scrollTo('contact')"
            class="inline-flex items-center gap-2 px-5 py-2.5 rounded-lg text-sm font-medium bg-zinc-900 hover:bg-zinc-800 text-zinc-200 border border-zinc-800 hover:border-zinc-700 transition-all duration-200 hover:-translate-y-0.5"
          >
            <Send class="w-4 h-4 text-[#c49f5a]" />
            <span>Contact Aman</span>
          </button>

          <a
            href="/resume.pdf"
            target="_blank"
            class="inline-flex items-center gap-2 px-4 py-2.5 rounded-lg text-sm font-mono text-zinc-400 hover:text-zinc-200 hover:bg-zinc-900/60 transition-colors"
          >
            <FileText class="w-4 h-4 text-zinc-500" />
            <span>Resume</span>
          </a>
        </div>
      </div>

      <!-- Bento Stats Grid -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-3 sm:gap-4 mb-10">
        <div
          v-for="stat in profile.stats"
          :key="stat.label"
          class="p-5 rounded-xl bg-zinc-900/60 border border-zinc-800/80 hover:border-zinc-700/90 transition-all duration-200"
        >
          <div class="text-2xl sm:text-3xl font-bold font-mono text-white mb-1 tracking-tight">
            {{ stat.value }}
          </div>
          <div class="text-xs font-mono text-zinc-500 uppercase tracking-wider">
            {{ stat.label }}
          </div>
        </div>
      </div>

      <!-- Core Stack Strip -->
      <div class="p-4 rounded-xl bg-[#111114] border border-zinc-800/80 flex flex-wrap items-center justify-between gap-4">
        <div class="flex items-center gap-2 text-xs font-mono text-zinc-400">
          <Code2 class="w-4 h-4 text-[#c49f5a]" />
          <span class="uppercase tracking-wider">Primary Stack</span>
        </div>
        <div class="flex flex-wrap items-center gap-2">
          <span
            v-for="item in profile.coreStack"
            :key="item"
            class="px-2.5 py-1 rounded bg-zinc-800/70 text-xs font-mono text-zinc-300 border border-zinc-700/60"
          >
            {{ item }}
          </span>
        </div>
      </div>
    </div>
  </section>
</template>
