<script setup lang="ts">
import Navbar from './components/Navbar.vue'
import HeroSection from './components/HeroSection.vue'
import SkillsSection from './components/SkillsSection.vue'
import ExperienceSection from './components/ExperienceSection.vue'
import ProjectsSection from './components/ProjectsSection.vue'
import ContactSection from './components/ContactSection.vue'
import Footer from './components/Footer.vue'
import AvaChatbot from './components/AvaChatbot.vue'
</script>

<template>
  <div class="min-h-screen bg-[#09090b] text-zinc-100 selection:bg-zinc-800 selection:text-white">
    <!-- Top Navigation Bar -->
    <Navbar />

    <!-- Main Content Flow -->
    <main>
      <HeroSection />
      <SkillsSection />
      <ExperienceSection />
      <ProjectsSection />
      <ContactSection />
    </main>

    <!-- Footer -->
    <Footer />

    <!-- Floating AI Assistant Ava -->
    <AvaChatbot />
  </div>
</template>
