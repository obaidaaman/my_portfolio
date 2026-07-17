import '../models/project.dart';

/// Static profile info shown in the hero and nav.
class Profile {
  Profile._();

  static const name = 'Aman Obaid';
  static const initials = 'AO';
  static const role = 'AI Backend Engineer';
  static const rotatingRoles = [
    'AI Backend Engineer',
    'GenAI Systems',
    'Flutter Developer',
  ];
  static const tagline = 'Building intelligent systems that bridge advanced '
      'AI models and real-world applications. Focused on LLM orchestration, '
      'RAG pipelines, and autonomous agent architectures.';

  static const email = 'amanobaidofficial01@gmail.com';
  static const github = 'https://github.com/obaidaaman';
  static const linkedin = 'https://www.linkedin.com/in/obaidaman14/';
  static const resumeAssetPath = 'assets/Resume_Aman_Obaid.pdf';

  static const stats = [
    ProfileStat('Experience', '1.5+ years'),
    ProfileStat('Projects', '6+ shipped'),
    ProfileStat('Education', 'IIT Madras'),
    ProfileStat('Speciality', 'LLM Systems'),
  ];

  static const coreStack = [
    'LangGraph',
    'RAG',
    'FastAPI',
    'Python',
    'Flutter',
  ];
}

class ProfileStat {
  final String label;
  final String value;
  const ProfileStat(this.label, this.value);
}

class SkillGroup {
  final String category;
  final List<String> items;
  const SkillGroup(this.category, this.items);
}

const skillGroups = <SkillGroup>[
  SkillGroup('LLM Frameworks', ['LangChain / LangGraph', 'RAG Architecture', 'MCP Servers']),
  SkillGroup('Backend', ['FastAPI', 'Flask', 'Microservices', 'Redis Queue']),
  SkillGroup('Vector DBs', ['Qdrant DB', 'Chroma DB']),
  SkillGroup('Languages', ['Python', 'Dart / Flutter', 'JavaScript']),
  SkillGroup('Cloud', ['Firebase']),
  SkillGroup('Observability', ['LangSmith', 'LangFuse']),
  SkillGroup('Tools', ['Git / GitHub']),
];

class ExperienceEntry {
  final String role;
  final String company;
  final String period;
  final List<String> achievements;
  const ExperienceEntry({
    required this.role,
    required this.company,
    required this.period,
    required this.achievements,
  });
}

const experience = ExperienceEntry(
  role: 'AI Backend Engineer',
  company: 'Pinch Lifestyle Pvt Ltd',
  period: 'AUG 2024 – JAN 2026',
  achievements: [
    'Architected an AI-integrated WhatsApp concierge system using LangGraph, handling 100+ concurrent conversations.',
    'Designed a stateful multi-agent LLM system with persistent conversational memory and seamless human-operator handoff, preserving full context.',
    'Built human-in-the-loop workflows that autonomously execute web search, flight/hotel bookings, Amazon actions, reminders, and CRED integrations.',
    'Designed a RAG-powered memory architecture supporting long-term recall across months of user interaction for context-sensitive personalisation.',
    'Developed an event-driven async backend with multi-source ingestion and real-time decision routing across APIs and fulfillment services.',
  ],
);

class EducationEntry {
  final String degree;
  final String institution;
  final String period;
  const EducationEntry({
    required this.degree,
    required this.institution,
    required this.period,
  });
}

const education = EducationEntry(
  degree: 'B.S. in Data Science and Applications',
  institution: 'Indian Institute of Technology, Madras',
  period: '2023 – 2027',
);

const projects = <Project>[
  Project(
    title: 'Lynn Concierge',
    description:
        'WhatsApp AI concierge managing everyday tasks — flights, hotels, Amazon, reminders — via intelligent LangGraph automation with seamless human handoff.',
    tag: 'Production',
    chips: ['LangGraph', 'LLM', 'WhatsApp API', 'Python'],
    web: 'https://concierge.pinch.co.in/lynn',
  ),
  Project(
    title: 'GrabPic',
    description:
        'AI-powered event photo retrieval using facial recognition and vector search. Attendees selfie to instantly find themselves across thousands of event photos.',
    tag: 'GenAI',
    chips: ['FastAPI', 'Redis Queue', 'Vector Search', 'JWT'],
    github: 'https://github.com/obaidaaman/GrabPic',
  ),
  Project(
    title: 'Agentic Blogger',
    description:
        'An agentic AI blogging pipeline built with LangGraph, FastAPI, and structured LLM outputs — orchestrating routing, research, planning, parallel section generation, and image generation.',
    tag: 'GenAI',
    chips: ['FastAPI', 'LangGraph', 'Vector Search', 'API'],
    github: 'https://github.com/obaidaaman/AgenticBlogger',
  ),
  Project(
    title: 'Personal AI Bot (Ava)',
    description:
        'RAG-powered personal assistant using LangChain that represents my professional profile to potential collaborators and employers.',
    tag: 'GenAI',
    chips: ['LangChain', 'RAG', 'LangSmith', 'FastAPI'],
    github: 'https://github.com/obaidaaman/PersonalAIBot',
  ),
  Project(
    title: 'Property Maintenance System',
    description:
        'Role-based maintenance workflow for tenants, managers, and technicians with JWT auth, Firestore logging, and real-time email notifications.',
    tag: 'Backend',
    chips: ['FastAPI', 'Firebase', 'JWT', 'Event-driven'],
  ),
  Project(
    title: 'Quiz Master',
    description:
        'Full-stack multi-user quiz platform with Flask, Jinja2 and SQLite. Subject and chapter-wise quiz creation with a full admin interface.',
    tag: 'Full Stack',
    chips: ['Flask', 'SQLite', 'Jinja2', 'Python'],
    github: 'https://github.com/obaidaaman/Quiz-Master',
  ),
];

enum ContactKind { email, link }

class ContactChannel {
  final String label;
  final String value;
  final ContactKind kind;
  const ContactChannel(this.label, this.value, this.kind);
}

const contactChannels = <ContactChannel>[
  ContactChannel('Email', Profile.email, ContactKind.email),
  ContactChannel('LinkedIn', Profile.linkedin, ContactKind.link),
  ContactChannel('GitHub', 'https://www.github.com/obaidaaman', ContactKind.link),
];

const navSections = ['Home', 'Skills', 'Experience', 'Projects', 'Contact'];