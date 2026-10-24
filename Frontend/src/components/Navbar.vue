<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { profile, navSections } from '../data/portfolioData'
import { FileText, Menu, X, ArrowUpRight } from 'lucide-vue-next'

const isScrolled = ref(false)
const mobileMenuOpen = ref(false)
const activeSection = ref('home')

const handleScroll = () => {
  isScrolled.value = window.scrollY > 40

  const sections = navSections.map((s) => s.toLowerCase())
  for (const section of [...sections].reverse()) {
    const el = document.getElementById(section)
    if (el) {
      const rect = el.getBoundingClientRect()
      if (rect.top <= 160) {
        activeSection.value = section
        break
      }
    }
  }
}

const scrollTo = (sectionName: string) => {
  mobileMenuOpen.value = false
  const id = sectionName.toLowerCase()
  const el = document.getElementById(id)
  if (el) {
    el.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }
}

onMounted(() => {
  window.addEventListener('scroll', handleScroll, { passive: true })
  handleScroll()
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})
</script>

<template>
  <header
    :class="[
      'fixed top-0 left-0 right-0 z-40 transition-all duration-300',
      isScrolled
        ? 'bg-[#09090b]/85 backdrop-blur-md border-b border-zinc-800/80 py-3 shadow-lg shadow-black/40'
        : 'bg-transparent py-5 border-b border-transparent',
    ]"
  >
    <div class="max-w-6xl mx-auto px-5 sm:px-8 flex items-center justify-between">
      <!-- Brand Initials / Monogram -->
      <a
        href="#home"
        @click.prevent="scrollTo('home')"
        class="group flex items-center gap-3 focus:outline-none"
      >
        <div
          class="w-9 h-9 rounded-md bg-zinc-900 border border-zinc-700/80 flex items-center justify-center font-mono font-bold text-sm tracking-tight text-[#c49f5a] group-hover:border-[#c49f5a]/60 group-hover:shadow-[0_0_12px_rgba(196,159,90,0.15)] transition-all duration-200"
        >
          {{ profile.initials }}
        </div>
        <div class="flex flex-col">
          <span class="text-sm font-semibold tracking-tight text-zinc-100 group-hover:text-white transition-colors">
            {{ profile.name }}
          </span>
          <span class="text-[11px] font-mono text-zinc-500 tracking-wide">
            {{ profile.role }}
          </span>
        </div>
      </a>

      <!-- Desktop Nav Items -->
      <nav class="hidden md:flex items-center gap-1 bg-zinc-900/60 p-1.5 rounded-full border border-zinc-800/70">
        <button
          v-for="section in navSections"
          :key="section"
          @click="scrollTo(section)"
          :class="[
            'px-3.5 py-1.5 rounded-full text-xs font-medium transition-all duration-200 focus:outline-none',
            activeSection === section.toLowerCase()
              ? 'bg-zinc-800 text-zinc-100 shadow-sm border border-zinc-700/60'
              : 'text-zinc-400 hover:text-zinc-200 hover:bg-zinc-800/40',
          ]"
        >
          {{ section }}
        </button>
      </nav>

      <!-- Desktop Right CTA -->
      <div class="hidden md:flex items-center gap-3">
        <a
          href="/resume.pdf"
          target="_blank"
          rel="noopener noreferrer"
          class="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-md text-xs font-mono font-medium text-zinc-200 bg-zinc-900 hover:bg-zinc-800 border border-zinc-700 hover:border-zinc-600 transition-all duration-200 group"
        >
          <FileText class="w-3.5 h-3.5 text-[#c49f5a]" />
          <span>Resume</span>
          <ArrowUpRight class="w-3 h-3 text-zinc-500 group-hover:text-zinc-300 transition-colors" />
        </a>
      </div>

      <!-- Mobile Hamburger Button -->
      <button
        @click="mobileMenuOpen = !mobileMenuOpen"
        class="md:hidden p-2 rounded-md bg-zinc-900 border border-zinc-800 text-zinc-400 hover:text-zinc-100 focus:outline-none"
        aria-label="Toggle menu"
      >
        <Menu v-if="!mobileMenuOpen" class="w-5 h-5" />
        <X v-else class="w-5 h-5" />
      </button>
    </div>

    <!-- Mobile Drawer Overlay -->
    <div
      v-if="mobileMenuOpen"
      class="md:hidden px-5 pt-4 pb-6 bg-[#0e0e11] border-b border-zinc-800/80 shadow-2xl transition-all"
    >
      <div class="flex flex-col gap-2">
        <button
          v-for="section in navSections"
          :key="section"
          @click="scrollTo(section)"
          :class="[
            'text-left px-4 py-2.5 rounded-md text-sm font-medium transition-colors',
            activeSection === section.toLowerCase()
              ? 'bg-zinc-800 text-zinc-100 border border-zinc-700'
              : 'text-zinc-400 hover:bg-zinc-900 hover:text-zinc-200',
          ]"
        >
          {{ section }}
        </button>
        <div class="pt-3 mt-2 border-t border-zinc-800 flex items-center justify-between">
          <a
            href="/resume.pdf"
            target="_blank"
            class="flex items-center gap-2 px-4 py-2 text-xs font-mono text-zinc-200 bg-zinc-900 rounded-md border border-zinc-700 w-full justify-center"
          >
            <FileText class="w-4 h-4 text-[#c49f5a]" />
            <span>View Resume PDF</span>
          </a>
        </div>
      </div>
    </div>
  </header>
</template>
