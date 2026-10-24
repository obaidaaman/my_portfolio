export interface Project {
  title: string
  description: string
  tag: string
  chips: string[]
  github?: string
  web?: string
}

export interface ProfileStat {
  label: string
  value: string
}

export interface SkillGroup {
  category: string
  items: string[]
}

export interface ExperienceEntry {
  role: string
  company: string
  period: string
  achievements: string[]
}

export interface EducationEntry {
  degree: string
  institution: string
  period: string
}

export type ContactKind = 'email' | 'link'

export interface ContactChannel {
  label: string
  value: string
  kind: ContactKind
}

export interface ChatMessage {
  id: string
  message: string
  isUser: boolean
  timestamp: Date
}
