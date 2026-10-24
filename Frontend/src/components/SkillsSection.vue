<script setup lang="ts">
import { skillGroups } from '../data/portfolioData'
import {
  Cpu,
  Server,
  Database,
  Code2,
  Cloud,
  Eye,
  Wrench,
  Layers,
} from 'lucide-vue-next'

const getCategoryIcon = (category: string) => {
  switch (category) {
    case 'LLM Frameworks':
      return Cpu
    case 'Backend':
      return Server
    case 'Vector DBs':
      return Database
    case 'Languages':
      return Code2
    case 'Cloud':
      return Cloud
    case 'Observability':
      return Eye
    case 'Tools':
      return Wrench
    default:
      return Layers
  }
}
</script>

<template>
  <section id="skills" class="py-24 border-t border-zinc-800/80 bg-[#09090b]">
    <div class="max-w-6xl mx-auto px-5 sm:px-8">
      <!-- Section Header -->
      <div class="mb-14">
        <div class="inline-flex items-center gap-2 font-mono text-xs uppercase tracking-widest text-[#c49f5a] mb-2.5">
          <span>01 // Capabilities</span>
        </div>
        <h2 class="text-3xl sm:text-4xl font-bold font-display tracking-tight text-white mb-4">
          Skills & Technical Expertise
        </h2>
        <p class="text-zinc-400 max-w-xl text-sm sm:text-base">
          Engineered for production LLM systems, deterministic tool use, high-concurrency event routing, and distributed state persistence.
        </p>
      </div>

      <!-- Skills Bento Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div
          v-for="(group, idx) in skillGroups"
          :key="group.category"
          :class="[
            'p-6 rounded-xl bg-[#121215] border border-zinc-800/90 hover:border-zinc-700 transition-all duration-200 group',
            idx === 0 ? 'md:col-span-2 lg:col-span-2 bg-[#141417]' : '',
          ]"
        >
          <div class="flex items-center justify-between mb-4">
            <div class="flex items-center gap-3">
              <div
                class="w-8 h-8 rounded-lg bg-zinc-900 border border-zinc-800 flex items-center justify-center text-[#c49f5a] group-hover:border-[#c49f5a]/40 transition-colors"
              >
                <component :is="getCategoryIcon(group.category)" class="w-4 h-4" />
              </div>
              <h3 class="font-semibold text-zinc-100 text-base">
                {{ group.category }}
              </h3>
            </div>
            <span class="text-[11px] font-mono text-zinc-600">
              {{ group.items.length }} skills
            </span>
          </div>

          <!-- Items list -->
          <div class="flex flex-wrap gap-2 pt-1">
            <span
              v-for="item in group.items"
              :key="item"
              class="px-2.5 py-1 text-xs font-mono rounded bg-zinc-900/90 border border-zinc-800 text-zinc-300 group-hover:border-zinc-700 transition-colors"
            >
              {{ item }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
