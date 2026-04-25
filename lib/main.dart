import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:js' as js;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

// ─── THEME ───────────────────────────────────────────────────────────────────

class C {
  static const Color bg = Color(0xff07090F);
  static const Color surface = Color(0xff0C0F18);
  static const Color card = Color(0xff111520);
  static const Color cardHover = Color(0xff161B2A);
  static const Color border = Color(0xff1E2438);
  static const Color borderHi = Color(0xff2E3A55);

  // Single accent — cool steel blue, no purple, no pink
  static const Color accent = Color(0xff4F7EF8);
  static const Color accentLo = Color(0xff2B4FA8);
  static const Color accentGlow = Color(0x194F7EF8);

  static const Color text = Color(0xffE4EAF6);
  static const Color textMuted = Color(0xff6B7A99);
  static const Color textDim = Color(0xff343D54);

  static const Color green = Color(0xff2EB87A); // success / available
  static const Color amber = Color(0xffD4921C); // warning
}

TextStyle h1({Color c = C.text}) => TextStyle(
    fontFamily: 'monospace',
    fontSize: 52,
    fontWeight: FontWeight.w800,
    color: c,
    letterSpacing: -1.5,
    height: 1.08);

TextStyle h2({Color c = C.text}) => TextStyle(
    fontFamily: 'monospace',
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: c,
    letterSpacing: -0.4);

TextStyle h3({Color c = C.text}) => TextStyle(
    fontFamily: 'monospace',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: c);

TextStyle body({Color c = C.text}) =>
    TextStyle(fontSize: 14.5, color: c, height: 1.75, fontFamily: 'sans-serif');

TextStyle label({Color c = C.accent, double sz = 12}) => TextStyle(
    fontFamily: 'monospace', fontSize: sz, color: c, letterSpacing: 0.4);

// ─── CHAT ────────────────────────────────────────────────────────────────────

class ChatMessage {
  final String message;
  final bool isUser;
  ChatMessage({required this.message, required this.isUser});
}

class ChatService {
  static const String baseUrl = 'https://personalaibot-1.onrender.com';
  final String threadId;
  ChatService({required this.threadId});

  Future<String> sendMessage(String query) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query, 'thread_id': threadId}),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['response'] ?? 'No response';
      }
      return 'Error ${res.statusCode}';
    } catch (_) {
      return 'Unable to connect. Please try again.';
    }
  }
}

// ─── AVA CHATBOT ─────────────────────────────────────────────────────────────

class AvaChatbot extends StatefulWidget {
  const AvaChatbot({super.key});
  @override
  State<AvaChatbot> createState() => _AvaChatbotState();
}

class _AvaChatbotState extends State<AvaChatbot>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  bool _showPopup = true;
  bool _isLoading = false;
  final List<ChatMessage> _messages = [];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  late ChatService _svc;
  late AnimationController _anim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    final id = const Uuid().v4();
    _svc = ChatService(threadId: id);
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnim = CurvedAnimation(parent: _anim, curve: Curves.easeOutBack);
    _messages.add(ChatMessage(
      message:
          "Hi! I'm Ava, Aman's AI assistant. Ask me anything about his work, skills, or experience!",
      isUser: false,
    ));
    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) setState(() => _showPopup = false);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      _showPopup = false;
      _isOpen ? _anim.forward() : _anim.reverse();
    });
  }

  void _scrollToBottom() {
    if (_scroll.hasClients) {
      Future.delayed(const Duration(milliseconds: 80), () {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    setState(() {
      _messages.add(ChatMessage(message: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();
    final reply = await _svc.sendMessage(text);
    setState(() {
      _messages.add(ChatMessage(message: reply, isUser: false));
      _isLoading = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      if (_isOpen)
        Positioned(
          right: 24,
          bottom: 88,
          child: ScaleTransition(
            scale: _scaleAnim,
            alignment: Alignment.bottomRight,
            child: Container(
              width: 360,
              height: 520,
              decoration: BoxDecoration(
                color: C.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: C.borderHi),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: -8),
                  BoxShadow(
                      color: C.accent.withOpacity(0.08),
                      blurRadius: 60,
                      spreadRadius: -10),
                ],
              ),
              child: Column(children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: C.surface,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border(bottom: BorderSide(color: C.border)),
                  ),
                  child: Row(children: [
                    _AvaAvatar(size: 34),
                    const SizedBox(width: 10),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ava', style: h3()),
                          Row(children: [
                            Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                    color: C.green, shape: BoxShape.circle)),
                            const SizedBox(width: 5),
                            Text('Online', style: label(c: C.green, sz: 10)),
                          ])
                        ]),
                    const Spacer(),
                    IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: C.textMuted,
                        onPressed: _toggle),
                  ]),
                ),
                // Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(14),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i == _messages.length) return _TypingIndicator();
                      return _Bubble(_messages[i]);
                    },
                  ),
                ),
                // Input
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: C.surface,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16)),
                    border: Border(top: BorderSide(color: C.border)),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        style: body(),
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Ask me anything…',
                          hintStyle: body(c: C.textDim),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: C.bg,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _send,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: C.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_upward_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ),

      // Welcome popup
      if (_showPopup && !_isOpen)
        Positioned(
          right: 88,
          bottom: 28,
          child: _WelcomePopup(
              onDismiss: () => setState(() => _showPopup = false)),
        ),

      // FAB
      Positioned(
        right: 24,
        bottom: 24,
        child: GestureDetector(
          onTap: _toggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: C.accent,
              boxShadow: [
                BoxShadow(
                    color: C.accent.withOpacity(0.35),
                    blurRadius: 18,
                    spreadRadius: -4)
              ],
            ),
            child: AnimatedRotation(
              turns: _isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 250),
              child: Icon(
                  _isOpen ? Icons.close_rounded : Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 22),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _AvaAvatar extends StatelessWidget {
  final double size;
  const _AvaAvatar({this.size = 40});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: C.accent,
      ),
      child: Center(
          child: Text('Ava',
              style: label(c: Colors.white, sz: 9.5)
                  .copyWith(fontWeight: FontWeight.w700))),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage msg;
  const _Bubble(this.msg);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[_AvaAvatar(size: 24), const SizedBox(width: 8)],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isUser ? C.accent : C.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(msg.isUser ? 14 : 3),
                  bottomRight: Radius.circular(msg.isUser ? 3 : 14),
                ),
                border: msg.isUser ? null : Border.all(color: C.border),
              ),
              child: Text(msg.message,
                  style: body(c: msg.isUser ? Colors.white : C.text)
                      .copyWith(fontSize: 13.5)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      _AvaAvatar(size: 24),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
              bottomRight: Radius.circular(14),
              bottomLeft: Radius.circular(3)),
          border: Border.all(color: C.border),
        ),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Row(mainAxisSize: MainAxisSize.min, children: [
            for (int i = 0; i < 3; i++) ...[
              Opacity(
                opacity:
                    (math.sin((_ctrl.value * 2 * math.pi) - (i * 0.8)) + 1) / 2,
                child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                        color: C.accent, shape: BoxShape.circle)),
              ),
              if (i < 2) const SizedBox(width: 4),
            ]
          ]),
        ),
      ),
    ]);
  }
}

class _WelcomePopup extends StatelessWidget {
  final VoidCallback onDismiss;
  const _WelcomePopup({required this.onDismiss});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 230),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: C.borderHi),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20)
          ],
        ),
        child: Row(children: [
          _AvaAvatar(size: 30),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Hey! I'm Ava 👋", style: label(sz: 11.5)),
              const SizedBox(height: 2),
              Text('Ask me about Aman',
                  style: body(c: C.textMuted).copyWith(fontSize: 12)),
            ]),
          ),
          GestureDetector(
            onTap: onDismiss,
            child:
                const Icon(Icons.close_rounded, size: 14, color: C.textMuted),
          ),
        ]),
      ),
    );
  }
}

// ─── MODELS ──────────────────────────────────────────────────────────────────

class Project {
  final String title, description, tag;
  final List<String> chips;
  final String? github, web;
  final Color tagColor;
  const Project({
    required this.title,
    required this.description,
    required this.tag,
    required this.chips,
    this.github,
    this.web,
    required this.tagColor,
  });
}

const _projects = [
  Project(
    title: 'Concierge AI',
    description:
        'Conversational AI concierge managing everyday tasks — flights, hotels, Amazon, reminders — via intelligent LangGraph automation with seamless human handoff.',
    tag: 'Production',
    tagColor: C.green,
    chips: ['Python', 'LangGraph', 'LLM', 'RAG', 'Redis'],
    web: 'https://apps.apple.com/in/app/patronos/id6749004848',
  ),
  Project(
    title: 'GrabPic',
    description:
        'AI-powered event photo retrieval using facial recognition and vector search. Attendees selfie to instantly find themselves across thousands of event photos.',
    tag: 'GenAI',
    tagColor: C.accent,
    chips: ['FastAPI', 'RabbitMQ', 'Vector Search', 'JWT'],
    github: 'https://github.com/obaidaaman/GrabPic',
  ),
  Project(
    title: 'Agentic Blogger',
    description:
        'LangGraph-powered blogging pipeline orchestrating multiple AI agents — routing, research, planning, parallel section generation, and image generation — into a single automated workflow.',
    tag: 'GenAI',
    tagColor: C.accent,
    chips: ['FastAPI', 'LangGraph', 'Vector Search', 'API'],
    github: 'https://github.com/obaidaaman/AgenticBlogger',
  ),
  Project(
    title: 'Personal AI Bot (Ava)',
    description:
        'RAG-powered intelligent personal assistant using LangChain that represents my professional profile to potential collaborators and employers.',
    tag: 'GenAI',
    tagColor: C.accent,
    chips: ['LangChain', 'RAG', 'LangSmith', 'FastAPI'],
    github: 'https://github.com/obaidaaman/PersonalAIBot',
  ),
  Project(
    title: 'Property Maintenance System',
    description:
        'Role-based maintenance workflow for tenants, managers, and technicians with JWT auth, Firestore logging, and real-time email notifications.',
    tag: 'Backend',
    tagColor: C.textMuted,
    chips: ['FastAPI', 'Firebase', 'JWT', 'Event-driven'],
  ),
  Project(
    title: 'Quiz Master',
    description:
        'Full-stack multi-user quiz platform with Flask, Jinja2 & SQLite. Subject/chapter-wise quiz creation with comprehensive admin interface.',
    tag: 'Full Stack',
    tagColor: C.green,
    chips: ['Flask', 'SQLite', 'Jinja2', 'Python'],
    github: 'https://github.com/obaidaaman/Quiz-Master',
  ),
];

const _skills = [
  {'label': 'LangChain / LangGraph', 'cat': 'LLM Frameworks'},
  {'label': 'RAG Architecture', 'cat': 'LLM Frameworks'},
  {'label': 'MCP Servers', 'cat': 'LLM Frameworks'},
  {'label': 'FastAPI', 'cat': 'Backend'},
  {'label': 'Flask', 'cat': 'Backend'},
  {'label': 'Microservices', 'cat': 'Backend'},
  {'label': 'Redis Queue', 'cat': 'Backend'},
  {'label': 'Qdrant DB', 'cat': 'Vector DBs'},
  {'label': 'Chroma DB', 'cat': 'Vector DBs'},
  {'label': 'Python', 'cat': 'Languages'},
  {'label': 'Dart / Flutter', 'cat': 'Languages'},
  {'label': 'JavaScript', 'cat': 'Languages'},
  {'label': 'Firebase', 'cat': 'Cloud'},
  {'label': 'LangSmith', 'cat': 'Observability'},
  {'label': 'LangFuse', 'cat': 'Observability'},
  {'label': 'Git / GitHub', 'cat': 'Tools'},
];

// ─── MAIN ─────────────────────────────────────────────────────────────────────

void main() => runApp(const PortfolioApp());

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aman Obaid — AI Engineer',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: C.bg,
        colorScheme:
            const ColorScheme.dark(primary: C.accent, surface: C.surface),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'sans-serif'),
      ),
      home: const _PortfolioPage(),
    );
  }
}

class _PortfolioPage extends StatefulWidget {
  const _PortfolioPage();
  @override
  State<_PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<_PortfolioPage> {
  final _scroll = ScrollController();
  final _keys = List.generate(5, (_) => GlobalKey());
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final s = _scroll.offset > 60;
      if (s != _scrolled) setState(() => _scrolled = s);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollTo(int i) {
    final ctx = _keys[i].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = w < 700;
    return Scaffold(
      backgroundColor: C.bg,
      body: Stack(children: [
        const _SubtleBackground(),
        SingleChildScrollView(
          controller: _scroll,
          child: Column(children: [
            _NavBar(scrolled: _scrolled, mobile: mobile, onTap: _scrollTo),
            _HeroSection(
                key: _keys[0], mobile: mobile, onContact: () => _scrollTo(4)),
            _SkillsSection(key: _keys[1], mobile: mobile),
            _ExperienceSection(key: _keys[2], mobile: mobile),
            _ProjectsSection(key: _keys[3], mobile: mobile),
            _ContactSection(key: _keys[4], mobile: mobile),
            const _Footer(),
          ]),
        ),
        const AvaChatbot(),
      ]),
    );
  }
}

// ─── BACKGROUND ──────────────────────────────────────────────────────────────

class _SubtleBackground extends StatelessWidget {
  const _SubtleBackground();
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: CustomPaint(painter: _BgPainter()));
  }
}

class _BgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Very subtle dot grid
    final dot = Paint()..color = C.border.withOpacity(0.55);
    const step = 44.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 0.9, dot);
      }
    }
    // Top-center glow
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xff4F7EF8).withOpacity(0.07), Colors.transparent],
        radius: 0.7,
      ).createShader(Rect.fromCenter(
          center: Offset(size.width / 2, -80), width: 900, height: 700));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 500), glow);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── NAV ─────────────────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  final bool scrolled, mobile;
  final void Function(int) onTap;
  const _NavBar(
      {required this.scrolled, required this.mobile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      decoration: BoxDecoration(
        color: scrolled ? C.surface.withOpacity(0.92) : Colors.transparent,
        border: scrolled ? Border(bottom: BorderSide(color: C.border)) : null,
      ),
      child: Row(children: [
        Text.rich(TextSpan(children: [
          TextSpan(
              text: 'AO',
              style: label(sz: 17).copyWith(fontWeight: FontWeight.w900)),
          TextSpan(text: '.dev', style: label(c: C.textMuted, sz: 13)),
        ])),
        const Spacer(),
        if (!mobile)
          ...['Home', 'Skills', 'Experience', 'Projects', 'Contact']
              .asMap()
              .entries
              .map((e) => Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: _NavItem(e.value, () => onTap(e.key)),
                  )),
      ]),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _NavItem(this.label, this.onTap);
  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: label(c: _hover ? C.accent : C.textMuted, sz: 13),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

// ─── HERO ────────────────────────────────────────────────────────────────────

class _HeroSection extends StatefulWidget {
  final bool mobile;
  final VoidCallback onContact;
  const _HeroSection(
      {super.key, required this.mobile, required this.onContact});
  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..forward();
    _fade = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0, 0.65, curve: Curves.easeOut));
    _slide = Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0, 0.75, curve: Curves.easeOut)));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          constraints: const BoxConstraints(minHeight: 660),
          padding: EdgeInsets.fromLTRB(
              widget.mobile ? 24 : 80, 80, widget.mobile ? 24 : 80, 60),
          child: widget.mobile
              ? _HeroMobile(onContact: widget.onContact)
              : _HeroDesktop(onContact: widget.onContact),
        ),
      ),
    );
  }
}

class _HeroDesktop extends StatelessWidget {
  final VoidCallback onContact;
  const _HeroDesktop({required this.onContact});
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(flex: 6, child: _HeroContent(onContact: onContact)),
      const SizedBox(width: 60),
      Expanded(flex: 4, child: _HeroCard()),
    ]);
  }
}

class _HeroMobile extends StatelessWidget {
  final VoidCallback onContact;
  const _HeroMobile({required this.onContact});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _HeroCard(),
      const SizedBox(height: 40),
      _HeroContent(onContact: onContact),
    ]);
  }
}

class _HeroContent extends StatelessWidget {
  final VoidCallback onContact;
  const _HeroContent({required this.onContact});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Status badge
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: C.green.withOpacity(0.08),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: C.green.withOpacity(0.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 6,
              height: 6,
              decoration:
                  const BoxDecoration(color: C.green, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text('Available for opportunities', style: label(c: C.green, sz: 11)),
        ]),
      ),
      const SizedBox(height: 28),
      Text('Aman', style: h1()),
      Text('Obaid', style: h1(c: C.accent)),
      const SizedBox(height: 18),
      Row(children: [
        Text('AI Backend Engineer  •  ', style: body(c: C.text)),
        const _TypingRole(),
      ]),
      const SizedBox(height: 22),
      SizedBox(
        width: 480,
        child: Text(
          'Building intelligent systems that bridge the gap between advanced AI models and real-world applications. Specialising in LLM orchestration, RAG pipelines, and autonomous agent architectures.',
          style: body(c: C.text),
        ),
      ),
      const SizedBox(height: 38),
      Wrap(spacing: 12, runSpacing: 12, children: [
        _PrimaryBtn('Get In Touch', Icons.arrow_forward_rounded, onContact),
        _OutlineBtn(
            'Resume',
            Icons.download_rounded,
            () => js.context
                .callMethod('open', ['assets/resume_amanobaidR.pdf'])),
        _OutlineBtn(
            'GitHub',
            Icons.code_rounded,
            () => js.context
                .callMethod('open', ['https://github.com/obaidaaman'])),
        _OutlineBtn(
            'LinkedIn',
            Icons.person_rounded,
            () => js.context.callMethod(
                'open', ['https://www.linkedin.com/in/obaidaman14/'])),
      ]),
    ]);
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 50,
              spreadRadius: -10),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: C.accent),
            child: const Center(
                child: Text('AO',
                    style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Colors.white))),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Aman Obaid', style: h3()),
            Text('AI Backend Engineer', style: label(c: C.textMuted, sz: 12)),
          ])
        ]),
        const SizedBox(height: 22),
        Container(height: 1, color: C.border),
        const SizedBox(height: 18),
        _StatRow('Experience', '1.5+ years', C.accent),
        const SizedBox(height: 11),
        _StatRow('Projects', '6+ shipped', C.green),
        const SizedBox(height: 11),
        _StatRow('Education', 'IIT Madras', C.amber),
        const SizedBox(height: 11),
        _StatRow('Speciality', 'LLM Systems', C.accent),
        const SizedBox(height: 18),
        Container(height: 1, color: C.border),
        const SizedBox(height: 14),
        Text('Core Stack', style: label(c: C.textDim, sz: 10.5)),
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final t in ['LangGraph', 'RAG', 'FastAPI', 'Python', 'Flutter'])
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: C.bg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: C.border)),
              child: Text(t, style: label(c: C.textMuted, sz: 10)),
            ),
        ]),
      ]),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String lbl, val;
  final Color color;
  const _StatRow(this.lbl, this.val, this.color);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text('$lbl:', style: label(c: C.textMuted, sz: 11.5)),
      const Spacer(),
      Text(val, style: label(c: color, sz: 11.5)),
    ]);
  }
}

class _TypingRole extends StatefulWidget {
  const _TypingRole();
  @override
  State<_TypingRole> createState() => _TypingRoleState();
}

class _TypingRoleState extends State<_TypingRole> {
  final _roles = [
    'GenAI Engineer',
    'LLM Systems',
    'Flutter Dev',
    'Backend Architect'
  ];
  int _idx = 0;
  String _curr = '';
  bool _del = false;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() async {
    if (!mounted) return;
    final full = _roles[_idx];
    setState(() {
      _curr = _del
          ? full.substring(0, _curr.length - 1)
          : full.substring(0, _curr.length + 1);
    });
    if (!_del && _curr == full) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _del = true);
    } else if (_del && _curr.isEmpty) {
      _del = false;
      _idx = (_idx + 1) % _roles.length;
    }
    await Future.delayed(Duration(milliseconds: _del ? 38 : 78));
    _tick();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(_curr, style: label(c: C.accent, sz: 14.5)),
      Text('|', style: label(c: C.accent, sz: 14.5)),
    ]);
  }
}

class _PrimaryBtn extends StatefulWidget {
  final String lbl;
  final IconData icon;
  final VoidCallback onTap;
  const _PrimaryBtn(this.lbl, this.icon, this.onTap);
  @override
  State<_PrimaryBtn> createState() => _PrimaryBtnState();
}

class _PrimaryBtnState extends State<_PrimaryBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          decoration: BoxDecoration(
            color: _h ? C.accent.withOpacity(0.88) : C.accent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                  color: C.accent.withOpacity(_h ? 0.38 : 0.18),
                  blurRadius: 18,
                  spreadRadius: -4)
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(widget.lbl,
                style: label(c: Colors.white, sz: 13.5)
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Icon(widget.icon, color: Colors.white, size: 15),
          ]),
        ),
      ),
    );
  }
}

class _OutlineBtn extends StatefulWidget {
  final String lbl;
  final IconData icon;
  final VoidCallback onTap;
  const _OutlineBtn(this.lbl, this.icon, this.onTap);
  @override
  State<_OutlineBtn> createState() => _OutlineBtnState();
}

class _OutlineBtnState extends State<_OutlineBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: _h ? C.card : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: _h ? C.borderHi : C.border),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(widget.icon, color: _h ? C.accent : C.textMuted, size: 15),
            const SizedBox(width: 8),
            Text(widget.lbl,
                style: label(c: _h ? C.accent : C.textMuted, sz: 13)),
          ]),
        ),
      ),
    );
  }
}

// ─── SKILLS ──────────────────────────────────────────────────────────────────

class _SkillsSection extends StatelessWidget {
  final bool mobile;
  const _SkillsSection({super.key, required this.mobile});

  @override
  Widget build(BuildContext context) {
    final cats = _skills.map((s) => s['cat']!).toSet().toList();
    final catColors = <String, Color>{
      'LLM Frameworks': C.accent,
      'Backend': C.accent,
      'Vector DBs': C.green,
      'Languages': C.amber,
      'Cloud': C.green,
      'Observability': C.textMuted,
      'Tools': C.textMuted,
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: mobile ? 24 : 80, vertical: 80),
      child: Column(children: [
        _SectionLabel('Skills & Technologies'),
        const SizedBox(height: 10),
        Text('The tools I use to build intelligent systems',
            style: body(c: C.textMuted)),
        const SizedBox(height: 48),
        Wrap(
          spacing: 18,
          runSpacing: 18,
          alignment: WrapAlignment.center,
          children: cats.map((cat) {
            final items = _skills.where((s) => s['cat'] == cat).toList();
            return _SkillGroup(cat, items, catColors[cat] ?? C.accent);
          }).toList(),
        ),
      ]),
    );
  }
}

class _SkillGroup extends StatelessWidget {
  final String category;
  final List<Map<String, String>> items;
  final Color color;
  const _SkillGroup(this.category, this.items, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(category, style: label(c: color, sz: 10.5)),
        ]),
        const SizedBox(height: 14),
        ...items.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Icon(Icons.chevron_right_rounded,
                    size: 13, color: color.withOpacity(0.5)),
                const SizedBox(width: 4),
                Text(s['label']!, style: body().copyWith(fontSize: 13)),
              ]),
            )),
      ]),
    );
  }
}

// ─── EXPERIENCE ──────────────────────────────────────────────────────────────

class _ExperienceSection extends StatelessWidget {
  final bool mobile;
  const _ExperienceSection({super.key, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: mobile ? 24 : 80, vertical: 80),
      color: C.surface.withOpacity(0.4),
      child: Column(children: [
        _SectionLabel('Experience'),
        const SizedBox(height: 10),
        Text("Where I've built real-world AI systems",
            style: body(c: C.textMuted)),
        const SizedBox(height: 48),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: _ExperienceCard(mobile: mobile),
        ),
      ]),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final bool mobile;
  const _ExperienceCard({required this.mobile});

  @override
  Widget build(BuildContext context) {
    final items = [
      'Architected a stateful multi-agent system using LangGraph, implementing persistent graph memory and thread-level checkpoints to manage state-machine transitions for 100+ concurrent sessions.',
      'Engineered a Human-in-the-Loop (HITL) orchestration layer that facilitates seamless model-to-operator context transfer, ensuring full graph state continuity during complex transition events.',
      'Developed a decoupled autonomous execution engine for multi-service tool-calling (Amazon, CRED, Web-Search); managed the lifecycle of agentic actions through distributed background workers to ensure system reliability.',
      'Implemented a high-dimensional RAG memory architecture optimized for long-horizon context recall, leveraging vector-search indexing to maintain retrieval accuracy across months of user interaction data.',
      'Built an event-driven asynchronous backend using FastAPI and message brokering for multi-source ingestion, utilizing real-time decision routing to coordinate tasks across distributed fulfillment APIs.'
    ];

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: C.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: C.accentGlow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: C.accent.withOpacity(0.25))),
            child: const Icon(Icons.auto_awesome_rounded,
                color: C.accent, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('AI Backend Engineer', style: h3()),
                const SizedBox(height: 3),
                Text('Pinch Lifestyle Pvt Ltd', style: label(sz: 12.5)),
              ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: C.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: C.green.withOpacity(0.25)),
            ),
            child:
                Text('Aug 2024 – Jan 2026', style: label(c: C.green, sz: 11)),
          ),
        ]),
        const SizedBox(height: 22),
        Container(height: 1, color: C.border),
        const SizedBox(height: 18),
        ...items.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                          color: C.accent, shape: BoxShape.circle)),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(a,
                        style: body(c: C.text).copyWith(fontSize: 13.5))),
              ]),
            )),
      ]),
    );
  }
}

// ─── PROJECTS ────────────────────────────────────────────────────────────────

class _ProjectsSection extends StatelessWidget {
  final bool mobile;
  const _ProjectsSection({super.key, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: mobile ? 24 : 80, vertical: 80),
      child: Column(children: [
        _SectionLabel('Projects'),
        const SizedBox(height: 10),
        Text("Things I've built, shipped and maintained",
            style: body(c: C.textMuted)),
        const SizedBox(height: 48),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Wrap(
            spacing: 18,
            runSpacing: 18,
            alignment: WrapAlignment.center,
            children: _projects
                .map((p) => _ProjectCard(p: p, mobile: mobile))
                .toList(),
          ),
        ),
      ]),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final Project p;
  final bool mobile;
  const _ProjectCard({required this.p, required this.mobile});
  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: widget.mobile ? double.infinity : 325,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: _h ? C.cardHover : C.card,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: _h ? p.tagColor.withOpacity(0.35) : C.border),
          boxShadow: _h
              ? [BoxShadow(color: p.tagColor.withOpacity(0.08), blurRadius: 28)]
              : [],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: p.tagColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: p.tagColor.withOpacity(0.25)),
              ),
              child: Text(p.tag, style: label(c: p.tagColor, sz: 10)),
            ),
            const Spacer(),
            if (p.github != null)
              _IconLink(Icons.code_rounded, 'GitHub', p.github!),
            if (p.web != null)
              _IconLink(Icons.open_in_new_rounded, 'Web', p.web!),
          ]),
          const SizedBox(height: 14),
          Text(p.title, style: h3().copyWith(fontSize: 16.5)),
          const SizedBox(height: 9),
          Text(p.description,
              style: body(c: C.textMuted).copyWith(fontSize: 13),
              maxLines: 4,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 18),
          Wrap(
              spacing: 6,
              runSpacing: 6,
              children: p.chips
                  .map((chip) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: C.bg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: C.border)),
                        child: Text(chip, style: label(c: C.text, sz: 10)),
                      ))
                  .toList()),
        ]),
      ),
    );
  }
}

class _IconLink extends StatefulWidget {
  final IconData icon;
  final String tooltip, url;
  const _IconLink(this.icon, this.tooltip, this.url);
  @override
  State<_IconLink> createState() => _IconLinkState();
}

class _IconLinkState extends State<_IconLink> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _h = true),
        onExit: (_) => setState(() => _h = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => js.context.callMethod('open', [widget.url]),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child:
                Icon(widget.icon, size: 17, color: _h ? C.accent : C.textDim),
          ),
        ),
      ),
    );
  }
}

// ─── CONTACT ─────────────────────────────────────────────────────────────────

class _ContactSection extends StatelessWidget {
  final bool mobile;
  const _ContactSection({super.key, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: mobile ? 24 : 80, vertical: 80),
      color: C.surface.withOpacity(0.4),
      child: Column(children: [
        _SectionLabel('Contact'),
        const SizedBox(height: 10),
        Text("Let's build something great together",
            style: body(c: C.textMuted)),
        const SizedBox(height: 48),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: _ContactCards(mobile: mobile),
        ),
      ]),
    );
  }
}

class _ContactCards extends StatelessWidget {
  final bool mobile;
  const _ContactCards({required this.mobile});

  @override
  Widget build(BuildContext context) {
    final contacts = [
      {
        'icon': Icons.email_rounded,
        'label': 'Email',
        'value': 'amanobaidofficial01@gmail.com',
        'color': C.accent,
      },
      {
        'icon': Icons.person_rounded,
        'label': 'LinkedIn',
        'value': 'https://www.linkedin.com/in/obaidaman14',
        'color': C.accent,
      },
      {
        'icon': Icons.code_rounded,
        'label': 'GitHub',
        'value': 'https://www.github.com/obaidaaman',
        'color': C.green,
      },
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: contacts
          .map((c) => _ContactCard(
                icon: c['icon'] as IconData,
                lbl: c['label'] as String,
                val: c['value'] as String,
                color: c['color'] as Color,
                mobile: mobile,
              ))
          .toList(),
    );
  }
}

class _ContactCard extends StatefulWidget {
  final IconData icon;
  final String lbl, val;
  final Color color;
  final bool mobile;
  const _ContactCard({
    required this.icon,
    required this.lbl,
    required this.val,
    required this.color,
    required this.mobile,
  });
  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _hover = false;
  bool _copied = false;

  void _open() {
    if (widget.lbl == 'Email') {
      js.context.callMethod('open', ['mailto:${widget.val}']);
    } else {
      js.context.callMethod('open', [widget.val]);
    }
  }

  void _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.val));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final display = widget.lbl == 'Email'
        ? widget.val
        : widget.val.replaceFirst('https://', '').replaceFirst('www.', '');

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: _open,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.mobile ? double.infinity : 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _hover ? C.cardHover : C.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: _hover ? widget.color.withOpacity(0.35) : C.border),
            boxShadow: _hover
                ? [
                    BoxShadow(
                        color: widget.color.withOpacity(0.08), blurRadius: 20)
                  ]
                : [],
          ),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: widget.color.withOpacity(0.2)),
              ),
              child: Icon(widget.icon, color: widget.color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(widget.lbl, style: h3().copyWith(fontSize: 14.5)),
            const SizedBox(height: 4),
            Text(display,
                style: label(c: C.textMuted, sz: 10),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 14),
            _SmallBtn(
                'Open', Icons.open_in_new_rounded, widget.color, _hover, _open),
            const SizedBox(height: 7),
            _SmallBtn(
              _copied ? 'Copied!' : 'Copy',
              _copied ? Icons.check_rounded : Icons.copy_rounded,
              widget.color,
              _copied,
              _copy,
            ),
          ]),
        ),
      ),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final String lbl;
  final IconData icon;
  final Color color;
  final bool active;
  final VoidCallback onTap;
  const _SmallBtn(this.lbl, this.icon, this.color, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.12) : C.bg,
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: active ? color.withOpacity(0.35) : C.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: active ? color : C.textMuted),
          const SizedBox(width: 6),
          Text(lbl, style: label(c: active ? color : C.textMuted, sz: 11)),
        ]),
      ),
    );
  }
}

// ─── FOOTER ──────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 26),
      decoration:
          BoxDecoration(border: Border(top: BorderSide(color: C.border))),
      child: Row(children: [
        Text.rich(TextSpan(children: [
          TextSpan(
              text: 'AO',
              style: label(sz: 14).copyWith(fontWeight: FontWeight.w900)),
          TextSpan(text: '.dev', style: label(c: C.textDim, sz: 12)),
        ])),
        const Spacer(),
        Text('Built with Flutter & ❤️', style: label(c: C.textDim, sz: 11)),
        const Spacer(),
        Text('© 2025 Aman Obaid', style: label(c: C.textDim, sz: 11)),
      ]),
    );
  }
}

// ─── SECTION LABEL ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 22, height: 1, color: C.accent),
        const SizedBox(width: 10),
        Text(text.toUpperCase(),
            style: label(sz: 10.5).copyWith(letterSpacing: 3)),
        const SizedBox(width: 10),
        Container(width: 22, height: 1, color: C.accent),
      ]),
      const SizedBox(height: 10),
      Text(text, style: h2()),
    ]);
  }
}
