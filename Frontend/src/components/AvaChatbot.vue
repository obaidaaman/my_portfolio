<script setup lang="ts">
import { ref, nextTick } from 'vue'
import { chatService } from '../services/chatService'
import type { ChatMessage } from '../types/portfolio'
import { X, Send, RotateCcw, Bot } from 'lucide-vue-next'

const isOpen = ref(false)
const inputQuery = ref('')
const isLoading = ref(false)
const chatContainer = ref<HTMLElement | null>(null)

const starterPrompts = [
  'What is Aman’s experience with LangGraph?',
  'Tell me about the Lynn Concierge system',
  'What are Aman’s core backend skills?',
  'Where did Aman study?',
]

const messages = ref<ChatMessage[]>([
  {
    id: 'welcome_1',
    message:
      "Hi! I'm Ava, Aman's AI portfolio assistant. Ask me anything about his projects, experience with LangGraph & RAG, or technical background.",
    isUser: false,
    timestamp: new Date(),
  },
])

const scrollToBottom = async () => {
  await nextTick()
  if (chatContainer.value) {
    chatContainer.value.scrollTop = chatContainer.value.scrollHeight
  }
}

const toggleOpen = () => {
  isOpen.value = !isOpen.value
  if (isOpen.value) {
    scrollToBottom()
  }
}

const resetChat = () => {
  chatService.resetThread()
  messages.value = [
    {
      id: 'welcome_' + Date.now(),
      message:
        "Conversation reset. How else can I assist you regarding Aman's background or projects?",
      isUser: false,
      timestamp: new Date(),
    },
  ]
}

const sendQuery = async (queryText?: string) => {
  const query = (queryText || inputQuery.value).trim()
  if (!query || isLoading.value) return

  inputQuery.value = ''

  messages.value.push({
    id: 'user_' + Date.now(),
    message: query,
    isUser: true,
    timestamp: new Date(),
  })

  isLoading.value = true
  scrollToBottom()

  try {
    const reply = await chatService.sendMessage(query)
    messages.value.push({
      id: 'ava_' + Date.now(),
      message: reply,
      isUser: false,
      timestamp: new Date(),
    })
  } catch (err) {
    messages.value.push({
      id: 'err_' + Date.now(),
      message: 'Failed to retrieve response from Ava. Please try again.',
      isUser: false,
      timestamp: new Date(),
    })
  } finally {
    isLoading.value = false
    scrollToBottom()
  }
}

// Simple markdown-to-html formatter for bolding, bullet points, and links
const formatMessage = (text: string) => {
  let escaped = text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')

  // Replace **bold**
  escaped = escaped.replace(/\*\*(.*?)\*\*/g, '<strong class="text-white font-semibold">$1</strong>')
  // Replace *italic*
  escaped = escaped.replace(/\*(.*?)\*/g, '<em class="text-zinc-300">$1</em>')
  // Replace newlines
  escaped = escaped.replace(/\n/g, '<br />')

  return escaped
}
</script>

<template>
  <!-- Floating Widget Container -->
  <div class="fixed bottom-5 right-5 z-50">
    <!-- Chat Window -->
    <div
      v-if="isOpen"
      class="mb-3 w-[calc(100vw-2.5rem)] sm:w-[410px] h-[550px] max-h-[82vh] rounded-2xl bg-[#111114] border border-zinc-800/90 shadow-2xl flex flex-col overflow-hidden backdrop-blur-xl animate-in fade-in zoom-in-95 duration-200"
    >
      <!-- Chat Header -->
      <div class="px-4 py-3.5 bg-[#16161a] border-b border-zinc-800/80 flex items-center justify-between">
        <div class="flex items-center gap-2.5">
          <div class="relative w-8 h-8 rounded-lg bg-zinc-900 border border-zinc-700/80 flex items-center justify-center text-[#c49f5a]">
            <Bot class="w-4 h-4" />
            <span class="absolute -top-0.5 -right-0.5 w-2 h-2 rounded-full bg-emerald-500 ring-2 ring-[#16161a]"></span>
          </div>
          <div>
            <div class="flex items-center gap-1.5">
              <span class="font-bold text-sm text-white">Ava</span>
              <span class="text-[10px] font-mono px-1.5 py-0.2 rounded bg-zinc-800 text-zinc-400 border border-zinc-700">AI</span>
            </div>
            <p class="text-[11px] text-zinc-400 font-mono">Personal Portfolio Assistant</p>
          </div>
        </div>

        <div class="flex items-center gap-1">
          <button
            @click="resetChat"
            title="Reset conversation thread"
            class="p-1.5 rounded-md hover:bg-zinc-800 text-zinc-400 hover:text-zinc-200 transition-colors focus:outline-none"
          >
            <RotateCcw class="w-4 h-4" />
          </button>
          <button
            @click="toggleOpen"
            title="Close chat"
            class="p-1.5 rounded-md hover:bg-zinc-800 text-zinc-400 hover:text-zinc-200 transition-colors focus:outline-none"
          >
            <X class="w-4 h-4" />
          </button>
        </div>
      </div>

      <!-- Messages Body -->
      <div ref="chatContainer" class="flex-1 overflow-y-auto p-4 space-y-3.5 text-xs sm:text-sm">
        <div
          v-for="msg in messages"
          :key="msg.id"
          :class="[
            'flex gap-2.5',
            msg.isUser ? 'justify-end' : 'justify-start',
          ]"
        >
          <!-- Assistant Avatar -->
          <div
            v-if="!msg.isUser"
            class="w-6 h-6 rounded-md bg-zinc-900 border border-zinc-800 flex items-center justify-center text-[#c49f5a] shrink-0 mt-0.5"
          >
            <Bot class="w-3.5 h-3.5" />
          </div>

          <!-- Message Bubble -->
          <div
            :class="[
              'max-w-[82%] px-3.5 py-2.5 rounded-xl leading-relaxed',
              msg.isUser
                ? 'bg-zinc-200 text-zinc-950 font-medium rounded-tr-none'
                : 'bg-[#1a1a20] text-zinc-300 border border-zinc-800/80 rounded-tl-none',
            ]"
            v-html="formatMessage(msg.message)"
          ></div>
        </div>

        <!-- Thinking Indicator -->
        <div v-if="isLoading" class="flex gap-2.5 justify-start">
          <div class="w-6 h-6 rounded-md bg-zinc-900 border border-zinc-800 flex items-center justify-center text-[#c49f5a] shrink-0">
            <Bot class="w-3.5 h-3.5" />
          </div>
          <div class="px-3.5 py-2.5 rounded-xl bg-[#1a1a20] border border-zinc-800/80 text-zinc-400 flex items-center gap-1.5">
            <span class="w-1.5 h-1.5 rounded-full bg-[#c49f5a] animate-pulse"></span>
            <span class="w-1.5 h-1.5 rounded-full bg-[#c49f5a] animate-pulse [animation-delay:0.2s]"></span>
            <span class="w-1.5 h-1.5 rounded-full bg-[#c49f5a] animate-pulse [animation-delay:0.4s]"></span>
            <span class="ml-1 text-[11px] font-mono text-zinc-500">Ava is thinking...</span>
          </div>
        </div>
      </div>

      <!-- Quick Suggested Prompts (when only 1 or 2 messages) -->
      <div v-if="messages.length <= 2 && !isLoading" class="px-4 py-2 border-t border-zinc-800/60 bg-[#141418]">
        <div class="text-[11px] font-mono text-zinc-500 mb-1.5">Suggested Questions:</div>
        <div class="flex flex-wrap gap-1.5">
          <button
            v-for="prompt in starterPrompts"
            :key="prompt"
            @click="sendQuery(prompt)"
            class="text-[11px] font-mono px-2 py-1 rounded bg-zinc-900 hover:bg-zinc-800 border border-zinc-800 hover:border-zinc-700 text-zinc-300 text-left transition-colors"
          >
            {{ prompt }}
          </button>
        </div>
      </div>

      <!-- Input Bar -->
      <form
        @submit.prevent="sendQuery()"
        class="p-3 bg-[#16161a] border-t border-zinc-800/80 flex items-center gap-2"
      >
        <input
          v-model="inputQuery"
          type="text"
          placeholder="Ask Ava anything about Aman..."
          :disabled="isLoading"
          class="flex-1 bg-zinc-900 border border-zinc-800 rounded-lg px-3 py-2 text-xs sm:text-sm text-zinc-100 placeholder-zinc-500 focus:outline-none focus:border-[#c49f5a]/60 disabled:opacity-50"
        />
        <button
          type="submit"
          :disabled="!inputQuery.trim() || isLoading"
          class="p-2 rounded-lg bg-zinc-100 hover:bg-white text-zinc-950 disabled:opacity-40 disabled:cursor-not-allowed transition-all"
        >
          <Send class="w-4 h-4" />
        </button>
      </form>
    </div>

    <!-- Floating Toggle Button -->
    <button
      @click="toggleOpen"
      class="group relative flex items-center gap-2.5 px-4 py-3 rounded-full bg-[#16161a] hover:bg-[#1f1f25] border border-zinc-700 hover:border-[#c49f5a]/50 text-white shadow-xl hover:shadow-2xl transition-all duration-200 active:scale-95"
      aria-label="Toggle Ava AI Chatbot"
    >
      <div class="relative w-5 h-5 flex items-center justify-center text-[#c49f5a]">
        <Bot class="w-5 h-5" />
        <span class="absolute -top-1 -right-1 w-2 h-2 rounded-full bg-emerald-400"></span>
      </div>
      <span class="text-xs font-semibold tracking-wide pr-1">Ask Ava</span>
    </button>
  </div>
</template>
