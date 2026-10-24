<script setup lang="ts">
import { experience, education } from '../data/portfolioData'
import { GraduationCap, Calendar, CheckCircle2 } from 'lucide-vue-next'
</script>

<template>
  <section id="experience" class="py-24 border-t border-zinc-800/80 bg-[#0c0c0e]">
    <div class="max-w-6xl mx-auto px-5 sm:px-8">
      <!-- Section Header -->
      <div class="mb-14">
        <div class="inline-flex items-center gap-2 font-mono text-xs uppercase tracking-widest text-[#c49f5a] mb-2.5">
          <span>02 // Trajectory</span>
        </div>
        <h2 class="text-3xl sm:text-4xl font-bold font-display tracking-tight text-white mb-4">
          Experience & Education
        </h2>
        <p class="text-zinc-400 max-w-xl text-sm sm:text-base">
          Proven history in architecting autonomous multi-agent production pipelines and resilient async backends.
        </p>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        <!-- Professional Work Timeline (8 cols) -->
        <div class="lg:col-span-8">
          <div class="relative pl-6 sm:pl-8 border-l border-zinc-800 space-y-12">
            <!-- Experience Item -->
            <div class="relative group">
              <!-- Timeline Node Marker -->
              <div
                class="absolute -left-[31px] sm:-left-[39px] top-1.5 w-3.5 h-3.5 rounded-full bg-zinc-950 border-2 border-[#c49f5a] shadow-[0_0_8px_rgba(196,159,90,0.4)]"
              ></div>

              <div class="p-6 sm:p-7 rounded-xl bg-[#141417] border border-zinc-800/90 hover:border-zinc-700/80 transition-all duration-200">
                <div class="flex flex-wrap items-start justify-between gap-2 mb-3">
                  <div>
                    <h3 class="text-lg sm:text-xl font-bold text-white tracking-tight">
                      {{ experience.role }}
                    </h3>
                    <div class="flex items-center gap-2 text-zinc-300 font-medium text-sm mt-0.5">
                      <span class="text-[#c49f5a]">{{ experience.company }}</span>
                    </div>
                  </div>

                  <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-zinc-900 border border-zinc-800 text-xs font-mono text-zinc-400">
                    <Calendar class="w-3.5 h-3.5 text-zinc-500" />
                    <span>{{ experience.period }}</span>
                  </div>
                </div>

                <div class="mt-5 space-y-3">
                  <div
                    v-for="(item, idx) in experience.achievements"
                    :key="idx"
                    class="flex items-start gap-3 text-sm text-zinc-300 leading-relaxed"
                  >
                    <CheckCircle2 class="w-4 h-4 text-[#c49f5a]/80 shrink-0 mt-0.5" />
                    <span>{{ item }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Education Card (4 cols) -->
        <div class="lg:col-span-4">
          <div class="p-6 sm:p-7 rounded-xl bg-[#141417] border border-zinc-800/90">
            <div class="flex items-center gap-3 mb-5">
              <div class="w-10 h-10 rounded-lg bg-zinc-900 border border-zinc-800 flex items-center justify-center text-[#c49f5a]">
                <GraduationCap class="w-5 h-5" />
              </div>
              <div>
                <span class="text-xs font-mono uppercase tracking-wider text-zinc-500">Education</span>
                <h4 class="font-bold text-white text-base leading-snug">Academic Degree</h4>
              </div>
            </div>

            <div class="space-y-2">
              <h5 class="text-zinc-100 font-semibold text-base">
                {{ education.degree }}
              </h5>
              <p class="text-[#c49f5a] text-sm font-medium">
                {{ education.institution }}
              </p>
              <div class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded bg-zinc-900 text-xs font-mono text-zinc-400 border border-zinc-800/80 mt-2">
                <Calendar class="w-3 h-3 text-zinc-500" />
                <span>{{ education.period }}</span>
              </div>
            </div>

            <div class="mt-6 pt-5 border-t border-zinc-800/80 text-xs text-zinc-400 leading-relaxed">
              Rigorous curriculum spanning machine learning foundations, algorithms, statistical data analysis, and scalable software systems.
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
