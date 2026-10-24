<script setup lang="ts">
import { ref } from 'vue'
import { profile } from '../data/portfolioData'
import { Mail, Linkedin, Github, Copy, Check, ArrowUpRight } from 'lucide-vue-next'

const copied = ref(false)

const copyEmail = async () => {
  try {
    await navigator.clipboard.writeText(profile.email)
    copied.value = true
    setTimeout(() => {
      copied.value = false
    }, 2200)
  } catch (err) {
    console.error('Failed to copy email', err)
  }
}
</script>

<template>
  <section id="contact" class="py-24 border-t border-zinc-800/80 bg-[#0c0c0f]">
    <div class="max-w-6xl mx-auto px-5 sm:px-8">
      <!-- Section Header -->
      <div class="mb-14">
        <div class="inline-flex items-center gap-2 font-mono text-xs uppercase tracking-widest text-[#c49f5a] mb-2.5">
          <span>04 // Connect</span>
        </div>
        <h2 class="text-3xl sm:text-4xl font-bold font-display tracking-tight text-white mb-4">
          Let's Build Something Intelligent
        </h2>
        <p class="text-zinc-400 max-w-xl text-sm sm:text-base">
          Whether you're exploring autonomous agent systems, building a RAG application, or discussing backend architecture — my inbox is always open.
        </p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
        <!-- Direct Email Card -->
        <div class="p-6 rounded-xl bg-[#141417] border border-zinc-800/90 flex flex-col justify-between group">
          <div>
            <div class="w-10 h-10 rounded-lg bg-zinc-900 border border-zinc-800 flex items-center justify-center text-[#c49f5a] mb-4">
              <Mail class="w-5 h-5" />
            </div>
            <h3 class="font-bold text-white text-base mb-1">Direct Email</h3>
            <p class="text-xs text-zinc-400 mb-4 font-mono break-all select-all">
              {{ profile.email }}
            </p>
          </div>

          <div class="flex items-center gap-2 pt-2">
            <button
              @click="copyEmail"
              class="flex-1 inline-flex items-center justify-center gap-2 px-3 py-2 rounded-md bg-zinc-900 hover:bg-zinc-800 border border-zinc-700/80 text-xs font-mono text-zinc-300 transition-colors"
            >
              <Check v-if="copied" class="w-3.5 h-3.5 text-emerald-400" />
              <Copy v-else class="w-3.5 h-3.5 text-zinc-400" />
              <span>{{ copied ? 'Copied to Clipboard' : 'Copy Address' }}</span>
            </button>
            <a
              :href="`mailto:${profile.email}`"
              class="p-2 rounded-md bg-zinc-900 hover:bg-zinc-800 border border-zinc-700/80 text-zinc-400 hover:text-white transition-colors"
              aria-label="Send direct email"
            >
              <ArrowUpRight class="w-4 h-4" />
            </a>
          </div>
        </div>

        <!-- LinkedIn Card -->
        <div class="p-6 rounded-xl bg-[#141417] border border-zinc-800/90 flex flex-col justify-between group">
          <div>
            <div class="w-10 h-10 rounded-lg bg-zinc-900 border border-zinc-800 flex items-center justify-center text-sky-400 mb-4">
              <Linkedin class="w-5 h-5" />
            </div>
            <h3 class="font-bold text-white text-base mb-1">LinkedIn</h3>
            <p class="text-xs text-zinc-400 mb-4">
              Connect professionally, review background history, and message directly.
            </p>
          </div>

          <a
            :href="profile.linkedin"
            target="_blank"
            rel="noopener noreferrer"
            class="inline-flex items-center justify-center gap-2 px-3 py-2 rounded-md bg-zinc-900 hover:bg-zinc-800 border border-zinc-700/80 text-xs font-mono text-zinc-300 group-hover:text-white transition-colors"
          >
            <span>Connect on LinkedIn</span>
            <ArrowUpRight class="w-3.5 h-3.5 text-zinc-500" />
          </a>
        </div>

        <!-- GitHub Card -->
        <div class="p-6 rounded-xl bg-[#141417] border border-zinc-800/90 flex flex-col justify-between group">
          <div>
            <div class="w-10 h-10 rounded-lg bg-zinc-900 border border-zinc-800 flex items-center justify-center text-zinc-200 mb-4">
              <Github class="w-5 h-5" />
            </div>
            <h3 class="font-bold text-white text-base mb-1">GitHub</h3>
            <p class="text-xs text-zinc-400 mb-4">
              Explore public repositories, LangGraph prototypes, and backend codebases.
            </p>
          </div>

          <a
            :href="profile.github"
            target="_blank"
            rel="noopener noreferrer"
            class="inline-flex items-center justify-center gap-2 px-3 py-2 rounded-md bg-zinc-900 hover:bg-zinc-800 border border-zinc-700/80 text-xs font-mono text-zinc-300 group-hover:text-white transition-colors"
          >
            <span>Browse Repositories</span>
            <ArrowUpRight class="w-3.5 h-3.5 text-zinc-500" />
          </a>
        </div>
      </div>
    </div>
  </section>
</template>
