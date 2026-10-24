<script setup lang="ts">
import { ref, computed } from 'vue'
import { projects } from '../data/portfolioData'
import { ExternalLink, Github } from 'lucide-vue-next'

const selectedCategory = ref('All')

const categories = computed(() => {
  const set = new Set(projects.map((p) => p.tag))
  return ['All', ...Array.from(set)]
})

const filteredProjects = computed(() => {
  if (selectedCategory.value === 'All') return projects
  return projects.filter((p) => p.tag === selectedCategory.value)
})

const getTagBadgeClass = (tag: string) => {
  switch (tag) {
    case 'Production':
      return 'text-[#c49f5a] bg-[#c49f5a]/10 border-[#c49f5a]/30'
    case 'GenAI':
      return 'text-emerald-400 bg-emerald-950/30 border-emerald-800/40'
    case 'Backend':
      return 'text-sky-400 bg-sky-950/30 border-sky-800/40'
    case 'Full Stack':
      return 'text-indigo-300 bg-indigo-950/30 border-indigo-800/40'
    default:
      return 'text-zinc-400 bg-zinc-900 border-zinc-800'
  }
}
</script>

<template>
  <section id="projects" class="py-24 border-t border-zinc-800/80 bg-[#09090b]">
    <div class="max-w-6xl mx-auto px-5 sm:px-8">
      <!-- Section Header -->
      <div class="flex flex-col md:flex-row md:items-end justify-between gap-6 mb-12">
        <div>
          <div class="inline-flex items-center gap-2 font-mono text-xs uppercase tracking-widest text-[#c49f5a] mb-2.5">
            <span>03 // Showcase</span>
          </div>
          <h2 class="text-3xl sm:text-4xl font-bold font-display tracking-tight text-white mb-3">
            Featured Projects
          </h2>
          <p class="text-zinc-400 max-w-xl text-sm sm:text-base">
            From multi-agent LLM systems in production to high-performance async backends and vector search pipelines.
          </p>
        </div>

        <!-- Filter Tabs -->
        <div class="flex flex-wrap items-center gap-1.5 p-1 bg-zinc-900/80 rounded-lg border border-zinc-800 self-start md:self-auto">
          <button
            v-for="cat in categories"
            :key="cat"
            @click="selectedCategory = cat"
            :class="[
              'px-3 py-1.5 rounded-md text-xs font-mono transition-all duration-150 focus:outline-none',
              selectedCategory === cat
                ? 'bg-zinc-800 text-zinc-100 shadow-sm border border-zinc-700'
                : 'text-zinc-400 hover:text-zinc-200 hover:bg-zinc-800/40',
            ]"
          >
            {{ cat }}
          </button>
        </div>
      </div>

      <!-- Projects Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        <div
          v-for="project in filteredProjects"
          :key="project.title"
          class="flex flex-col justify-between p-6 rounded-xl bg-[#121215] border border-zinc-800/90 hover:border-zinc-700 hover:shadow-xl hover:shadow-black/50 transition-all duration-200 group"
        >
          <div>
            <!-- Header: Tag & External Links -->
            <div class="flex items-center justify-between gap-2 mb-4">
              <span
                :class="[
                  'px-2.5 py-0.5 rounded text-[11px] font-mono border font-medium tracking-wide',
                  getTagBadgeClass(project.tag),
                ]"
              >
                {{ project.tag }}
              </span>

              <div class="flex items-center gap-1 text-zinc-500">
                <a
                  v-if="project.github"
                  :href="project.github"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="p-1.5 rounded hover:bg-zinc-800 hover:text-zinc-200 transition-colors"
                  :aria-label="`${project.title} GitHub repository`"
                >
                  <Github class="w-4 h-4" />
                </a>
                <a
                  v-if="project.web"
                  :href="project.web"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="p-1.5 rounded hover:bg-zinc-800 hover:text-zinc-200 transition-colors"
                  :aria-label="`${project.title} live demo`"
                >
                  <ExternalLink class="w-4 h-4" />
                </a>
              </div>
            </div>

            <!-- Title -->
            <h3 class="text-lg font-bold text-zinc-100 group-hover:text-white mb-2.5 transition-colors">
              {{ project.title }}
            </h3>

            <!-- Description -->
            <p class="text-xs sm:text-sm text-zinc-400 leading-relaxed mb-6">
              {{ project.description }}
            </p>
          </div>

          <!-- Bottom: Tech Stack Chips & Links -->
          <div class="pt-4 border-t border-zinc-800/70 space-y-4">
            <div class="flex flex-wrap gap-1.5">
              <span
                v-for="chip in project.chips"
                :key="chip"
                class="px-2 py-0.5 text-[11px] font-mono rounded bg-zinc-900 border border-zinc-800 text-zinc-400 group-hover:border-zinc-700/80 transition-colors"
              >
                {{ chip }}
              </span>
            </div>

            <div class="flex items-center gap-3 pt-1">
              <a
                v-if="project.web"
                :href="project.web"
                target="_blank"
                rel="noopener noreferrer"
                class="inline-flex items-center gap-1.5 text-xs font-mono text-[#c49f5a] hover:text-[#d4af37] transition-colors"
              >
                <span>Live Demo</span>
                <ExternalLink class="w-3.5 h-3.5" />
              </a>

              <a
                v-if="project.github"
                :href="project.github"
                target="_blank"
                rel="noopener noreferrer"
                class="inline-flex items-center gap-1.5 text-xs font-mono text-zinc-400 hover:text-zinc-200 transition-colors"
              >
                <Github class="w-3.5 h-3.5" />
                <span>Source</span>
              </a>

              <span
                v-if="!project.web && !project.github"
                class="inline-flex items-center gap-1.5 text-xs font-mono text-zinc-500"
              >
                <span class="w-1.5 h-1.5 rounded-full bg-[#c49f5a]/70"></span>
                <span>Proprietary Production System</span>
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
