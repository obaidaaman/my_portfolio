export interface ChatResponse {
  response?: string
  error?: string
}

export class ChatService {
  private static readonly BASE_URL = 'https://personalaibot-1.onrender.com'
  private threadId: string

  constructor() {
    this.threadId = this.getOrCreateThreadId()
  }

  private getOrCreateThreadId(): string {
    const key = 'ava_thread_id'
    let existing = localStorage.getItem(key)
    if (!existing) {
      existing = 'tid_' + Math.random().toString(36).substring(2, 11) + '_' + Date.now()
      localStorage.setItem(key, existing)
    }
    return existing
  }

  public getThreadId(): string {
    return this.threadId
  }

  public resetThread(): void {
    const key = 'ava_thread_id'
    this.threadId = 'tid_' + Math.random().toString(36).substring(2, 11) + '_' + Date.now()
    localStorage.setItem(key, this.threadId)
  }

  public async sendMessage(query: string, signal?: AbortSignal): Promise<string> {
    try {
      const response = await fetch(`${ChatService.BASE_URL}/query`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          query,
          thread_id: this.threadId,
        }),
        signal,
      })

      if (!response.ok) {
        throw new Error(`Server returned status ${response.status}`)
      }

      const data: ChatResponse = await response.json()
      return data.response || 'I processed your request, but received an empty response.'
    } catch (err: unknown) {
      if (err instanceof Error && err.name === 'AbortError') {
        throw err
      }
      return 'Unable to reach Ava at the moment. Please try again or reach out directly via email.'
    }
  }
}

export const chatService = new ChatService()
