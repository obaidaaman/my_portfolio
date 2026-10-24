import type {
  ContactChannel,
  EducationEntry,
  ExperienceEntry,
  ProfileStat,
  Project,
  SkillGroup,
} from '../types/portfolio'

export const profile = {
  name: 'Aman Obaid',
  initials: 'AO',
  role: 'AI Backend Engineer',
  rotatingRoles: [
    'AI Backend Engineer',
    'GenAI Systems',
    'Flutter Developer',
  ],
  tagline:
    'Building intelligent systems that bridge advanced AI models and real-world applications. Focused on LLM orchestration, RAG pipelines, and autonomous agent architectures.',
  email: 'amanobaidofficial01@gmail.com',
  github: 'https://github.com/obaidaaman',
  linkedin: 'https://www.linkedin.com/in/obaidaman14/',
  resumeAssetPath: '/resume.pdf',
  stats: [
    { label: 'Experience', value: '1.5+ years' },
    { label: 'Projects', value: '6+ shipped' },
    { label: 'Education', value: 'IIT Madras' },
    { label: 'Speciality', value: 'LLM Systems' },
  ] as ProfileStat[],
  coreStack: [
    'LangGraph',
    'RAG',
    'FastAPI',
    'Python',
    'Flutter',
  ],
}

export const skillGroups: SkillGroup[] = [
  {
    category: 'LLM Frameworks',
    items: ['LangChain / LangGraph', 'RAG Architecture', 'MCP Servers'],
  },
  {
    category: 'Backend',
    items: ['FastAPI', 'Flask', 'Microservices', 'Redis Queue'],
  },
  {
    category: 'Vector DBs',
    items: ['Qdrant DB', 'Chroma DB'],
  },
  {
    category: 'Languages',
    items: ['Python', 'Dart / Flutter', 'JavaScript'],
  },
  {
    category: 'Cloud',
    items: ['Firebase'],
  },
  {
    category: 'Observability',
    items: ['LangSmith', 'LangFuse'],
  },
  {
    category: 'Tools',
    items: ['Git / GitHub'],
  },
]

export const experience: ExperienceEntry = {
  role: 'SDE 1',
  company: 'Pinch Lifestyle Pvt Ltd',
  period: 'Aug 2024 – Jan 2026',
  achievements: [
    'Built an agentic AI personal assistant for 1000+ users in Python and LangGraph, automating flight, hotel, and product research to replace a slow manual concierge workflow.',
    'Designed a ReAct-style agent in LangGraph integrating search APIs with persistent long-term memory, autonomously querying external vendors and synthesizing personalized options in real time.',
    'Built a bidirectional AI-human handoff system with shared conversation context, reducing repeated user inputs during handoffs by 67% and enabling seamless transitions between AI assistance and personalized concierge support.',
    'Built a RAG pipeline (LangChain, Qdrant) indexing company operating procedures to enforce pricing and brand tone, drastically reducing hallucinated recommendations.',
    'Shipped services with Docker to Google Cloud, instrumenting Cloud Monitoring and distributed tracing to identify latency bottlenecks, cutting per-turn response times by 45% (9.5s to 5s) using Redis caching and concurrent async retrieval.',
  ],
}

export const education: EducationEntry = {
  degree: 'B.S. in Data Science and Applications',
  institution: 'Indian Institute of Technology, Madras',
  period: '2023 – 2027',
}

export const projects: Project[] = [
  {
    title: 'Lynn Concierge',
    description:
      'Production AI personal assistant developed at Pinch Lifestyle for 1000+ users. Automates complex flight, hotel, and product research via LangGraph ReAct agents with persistent long-term memory and a bidirectional human handoff system.',
    tag: 'Production',
    chips: ['LangGraph', 'Python', 'ReAct Agent', 'FastAPI', 'Production'],
  },
  {
    title: 'DocuScope',
    description:
      'An agentic document analysis and reconciliation system that grounds reasoning across growing document collections, evaluates user-defined compliance rules, flags contradictions, and incrementally updates reports with item-level human review.',
    tag: 'GenAI',
    chips: ['Multi-Agent', 'Document RAG', 'FastAPI', 'Python', 'Rule Engine'],
    github: 'https://github.com/obaidaaman/DocuScope',
  },
  {
    title: 'Agentic Blogger',
    description:
      'Autonomous multi-agent technical publishing pipeline built with LangGraph, FastAPI, and PostgreSQL. Features an isolated subprocess sandbox with AST validation for verified code execution, and targeted section regeneration.',
    tag: 'GenAI',
    chips: ['LangGraph', 'FastAPI', 'PostgreSQL', 'AST Sandbox', 'Vector Search'],
    github: 'https://github.com/obaidaaman/AgenticBlogger',
  },
  {
    title: 'GrabPic',
    description:
      'AI-powered event photo discovery platform using facial recognition and vector search. Decouples heavy ML inference with Celery and Redis to match attendee selfies in under 200ms with strict privacy and JWT authentication.',
    tag: 'GenAI',
    chips: ['FastAPI', 'Qdrant', 'Celery', 'Redis', 'JWT'],
    github: 'https://github.com/obaidaaman/GrabPic',
  },
  {
    title: 'Personal AI Bot (Ava)',
    description:
      'RAG-powered personal assistant using LangChain that represents my professional profile to potential collaborators and employers.',
    tag: 'GenAI',
    chips: ['LangChain', 'RAG', 'LangSmith', 'FastAPI'],
    github: 'https://github.com/obaidaaman/PersonalAIBot',
  },
  {
    title: 'Property Maintenance System',
    description:
      'Role-based maintenance workflow for tenants, managers, and technicians with JWT auth, Firestore logging, and real-time email notifications.',
    tag: 'Backend',
    chips: ['FastAPI', 'Firebase', 'JWT', 'Event-driven'],
  },
  {
    title: 'Quiz Master',
    description:
      'Full-stack multi-user quiz platform with Flask, Jinja2 and SQLite. Subject and chapter-wise quiz creation with a full admin interface.',
    tag: 'Full Stack',
    chips: ['Flask', 'SQLite', 'Jinja2', 'Python'],
    github: 'https://github.com/obaidaaman/Quiz-Master',
  },
]

export const contactChannels: ContactChannel[] = [
  { label: 'Email', value: profile.email, kind: 'email' },
  { label: 'LinkedIn', value: profile.linkedin, kind: 'link' },
  { label: 'GitHub', value: 'https://www.github.com/obaidaaman', kind: 'link' },
]

export const navSections = ['Home', 'Skills', 'Experience', 'Projects', 'Contact']
