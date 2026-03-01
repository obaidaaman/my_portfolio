import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:js' as js;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

// ─── THEME ───────────────────────────────────────────────────────────────────

class C {
  static const Color bg = Color(0xff0A0B0F);
  static const Color surface = Color(0xff111318);
  static const Color card = Color(0xff161A23);
  static const Color cardHover = Color(0xff1C2030);
  static const Color border = Color(0xff252B3B);
  static const Color accent = Color(0xff00E5FF); // electric cyan
  static const Color accentDim = Color(0xff0097A7);
  static const Color accentGlow = Color(0x2200E5FF);
  static const Color purple = Color(0xff7C3AED);
  static const Color purpleGlow = Color(0x227C3AED);
  static const Color text = Color(0xffF0F4FF);
  static const Color textMuted = Color(0xff8892A4);
  static const Color textDim = Color(0xff4A5568);
  static const Color success = Color(0xff22D3A0);
  static const Color warning = Color(0xffFFA726);
}

TextStyle heading1({Color color = C.text}) => TextStyle(
    fontFamily: 'monospace',
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: color,
    letterSpacing: -1.5,
    height: 1.1);

TextStyle heading2({Color color = C.text}) => TextStyle(
    fontFamily: 'monospace',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: -0.5);

TextStyle heading3({Color color = C.text}) => TextStyle(
    fontFamily: 'monospace',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: color);

TextStyle body({Color color = C.text}) =>
    TextStyle(fontSize: 15, color: color, height: 1.7);

TextStyle mono({Color color = C.accent, double size = 13}) => TextStyle(
    fontFamily: 'monospace', fontSize: size, color: color, letterSpacing: 0.5);

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
        vsync: this, duration: const Duration(milliseconds: 350));
    _scaleAnim = CurvedAnimation(parent: _anim, curve: Curves.easeOutBack);
    _messages.add(ChatMessage(
      message:
          "Hi! I'm Ava, Aman's AI assistant. Ask me anything about his work, skills, or experience!",
      isUser: false,
    ));
    Future.delayed(const Duration(seconds: 8), () {
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
      // Chat window
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
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: C.accent.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                      color: C.accent.withOpacity(0.15),
                      blurRadius: 40,
                      spreadRadius: -5)
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
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border(bottom: BorderSide(color: C.border)),
                  ),
                  child: Row(children: [
                    _AvaAvatar(size: 36),
                    const SizedBox(width: 10),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ava', style: heading3()),
                          Row(children: [
                            Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                    color: C.success, shape: BoxShape.circle)),
                            const SizedBox(width: 5),
                            Text('Online',
                                style: mono(color: C.success, size: 11)),
                          ])
                        ]),
                    const Spacer(),
                    IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
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
                        bottom: Radius.circular(20)),
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
                          hintStyle: body(color: C.textDim),
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
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [C.accent, C.accentDim]),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_upward_rounded,
                            color: Colors.black, size: 18),
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
            duration: const Duration(milliseconds: 300),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [C.accent, C.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                    color: C.accent.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: -4)
              ],
            ),
            child: AnimatedRotation(
              turns: _isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                  _isOpen ? Icons.close_rounded : Icons.auto_awesome_rounded,
                  color: Colors.black,
                  size: 24),
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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
            colors: [C.accent, C.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: Center(
          child: Text('Ava', style: mono(color: Colors.black, size: 10))),
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
          if (!msg.isUser) ...[_AvaAvatar(size: 26), const SizedBox(width: 8)],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isUser ? C.accent : C.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                ),
                border: msg.isUser ? null : Border.all(color: C.border),
              ),
              child: Text(msg.message,
                  style: body(color: msg.isUser ? Colors.black : C.text)),
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
      _AvaAvatar(size: 26),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(4)),
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
                    width: 6,
                    height: 6,
                    decoration:
                        BoxDecoration(color: C.accent, shape: BoxShape.circle)),
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
        constraints: const BoxConstraints(maxWidth: 240),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: C.accent.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(color: C.accent.withOpacity(0.1), blurRadius: 20)
          ],
        ),
        child: Row(children: [
          _AvaAvatar(size: 32),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hey! I\'m Ava 👋', style: mono(size: 12)),
              const SizedBox(height: 2),
              Text('Ask me about Aman', style: body(color: C.textMuted)),
            ]),
          ),
          GestureDetector(
            onTap: onDismiss,
            child:
                const Icon(Icons.close_rounded, size: 16, color: C.textMuted),
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
    title: 'Lynn Concierge',
    description:
        'WhatsApp AI concierge managing everyday tasks — flights, hotels, Amazon, reminders — via intelligent LangGraph automation with seamless human handoff.',
    tag: 'Production',
    tagColor: C.success,
    chips: ['LangGraph', 'LLM', 'WhatsApp API', 'Python'],
    web: 'https://concierge.pinch.co.in/lynn',
  ),
  Project(
    title: 'GrabPic',
    description:
        'AI-powered event photo retrieval using facial recognition and vector search. Attendees selfie to instantly find themselves across thousands of event photos.',
    tag: 'AI/ML',
    tagColor: C.accent,
    chips: ['FastAPI', 'Redis Queue', 'Vector Search', 'JWT'],
    github: 'https://github.com/obaidaaman/GrabPic',
  ),
  Project(
    title: 'Personal AI Bot (Ava)',
    description:
        'RAG-powered intelligent personal assistant using LangChain that represents my professional profile to potential collaborators and employers.',
    tag: 'GenAI',
    tagColor: C.purple,
    chips: ['LangChain', 'RAG', 'LangSmith', 'FastAPI'],
    github: 'https://github.com/obaidaaman/PersonalAIBot',
  ),
  Project(
    title: 'Prime View',
    description:
        'Luxury real estate web app with immersive property exploration, sleek UI, and curated listings for high-end urban and serene properties.',
    tag: 'Web',
    tagColor: C.warning,
    chips: ['React', 'Vercel', 'REST API', 'Responsive'],
    web: 'https://primeview-realestate.vercel.app/',
  ),
  Project(
    title: 'Property Maintenance System',
    description:
        'Role-based maintenance workflow for tenants, managers, and technicians with JWT auth, Firestore logging, and real-time email notifications.',
    tag: 'Backend',
    tagColor: C.accentDim,
    chips: ['FastAPI', 'Firebase', 'JWT', 'Event-driven'],
  ),
  Project(
    title: 'Quiz Master',
    description:
        'Full-stack multi-user quiz platform with Flask, Jinja2 & SQLite. Subject/chapter-wise quiz creation with comprehensive admin interface.',
    tag: 'Full Stack',
    tagColor: C.success,
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
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = w < 700;

    return Scaffold(
      backgroundColor: C.bg,
      body: Stack(children: [
        // Background grid
        const _GridBackground(),
        // Content
        SingleChildScrollView(
          controller: _scroll,
          child: Column(children: [
            _NavBar(scrolled: _scrolled, mobile: mobile, onTap: _scrollTo),
            _HeroSection(
                key: _keys[0], mobile: mobile, onContact: () => _scrollTo(3)),
            _SkillsSection(key: _keys[1], mobile: mobile),
            _ExperienceSection(key: _keys[2], mobile: mobile),
            _ProjectsSection(key: _keys[3], mobile: mobile),
            _ContactSection(key: _keys[4], mobile: mobile),
            const _Footer(),
          ]),
        ),
        // Ava
        const AvaChatbot(),
      ]),
    );
  }
}

// ─── BACKGROUND ──────────────────────────────────────────────────────────────

class _GridBackground extends StatelessWidget {
  const _GridBackground();
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: _GridPainter()),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = C.border.withOpacity(0.35)
      ..strokeWidth = 0.5;
    const spacing = 60.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Glow at top
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [C.accent.withOpacity(0.06), Colors.transparent],
        radius: 0.6,
      ).createShader(Rect.fromLTWH(size.width * 0.5 - 300, -200, 600, 600));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 600), glow);
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
        color: scrolled ? C.surface.withOpacity(0.9) : Colors.transparent,
        border: scrolled ? Border(bottom: BorderSide(color: C.border)) : null,
      ),
      child: Row(children: [
        // Logo
        Text.rich(TextSpan(children: [
          TextSpan(
              text: 'AO',
              style: mono(color: C.accent, size: 18)
                  .copyWith(fontWeight: FontWeight.w900)),
          TextSpan(text: '.dev', style: mono(color: C.textMuted, size: 14)),
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
          style: mono(color: _hover ? C.accent : C.textMuted, size: 13),
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
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    _fade = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0, 0.6, curve: Curves.easeOut));
    _slide = Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0, 0.7, curve: Curves.easeOut)));
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
          constraints: const BoxConstraints(minHeight: 680),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 6, child: _HeroContent(onContact: onContact)),
        const SizedBox(width: 60),
        Expanded(flex: 4, child: _HeroCard()),
      ],
    );
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
      // Badge
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: C.accentGlow,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: C.accent.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: C.accent, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text('Available for opportunities', style: mono(size: 11)),
        ]),
      ),
      const SizedBox(height: 24),
      Text('Aman', style: heading1().copyWith(fontSize: 56, color: C.text)),
      Text('Obaid', style: heading1().copyWith(fontSize: 56, color: C.accent)),
      const SizedBox(height: 16),
      Row(children: [
        Text('AI Backend Engineer  •  ', style: body(color: C.textMuted)),
        const _TypingRole(),
      ]),
      const SizedBox(height: 20),
      SizedBox(
        width: 480,
        child: Text(
          'Building intelligent systems that bridge the gap between advanced AI models and real-world applications. Specialising in LLM orchestration, RAG pipelines, and autonomous agent architectures.',
          style: body(color: C.textMuted),
        ),
      ),
      const SizedBox(height: 36),
      Wrap(spacing: 14, runSpacing: 14, children: [
        _PrimaryBtn('Get In Touch', Icons.arrow_forward_rounded, onContact),
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: C.border),
        boxShadow: [
          BoxShadow(
              color: C.accent.withOpacity(0.07),
              blurRadius: 60,
              spreadRadius: -10)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Profile area
        Row(children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  colors: [C.accent, C.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: const Center(
                child: Text('AO',
                    style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Colors.black))),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Aman Obaid', style: heading3()),
            Text('AI Backend Engineer',
                style: mono(color: C.textMuted, size: 12)),
          ])
        ]),
        const SizedBox(height: 24),
        // Divider
        Container(height: 1, color: C.border),
        const SizedBox(height: 20),
        // Stats
        _StatRow('Experience', '1.5+ years', C.accent),
        const SizedBox(height: 12),
        _StatRow('Projects', '6+ shipped', C.purple),
        const SizedBox(height: 12),
        _StatRow('Education', 'IIT Madras', C.success),
        const SizedBox(height: 12),
        _StatRow('Speciality', 'LLM Systems', C.warning),
        const SizedBox(height: 20),
        Container(height: 1, color: C.border),
        const SizedBox(height: 16),
        // Tech stack mini chips
        Text('Core Stack', style: mono(color: C.textDim, size: 11)),
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final t in ['LangGraph', 'RAG', 'FastAPI', 'Python', 'Flutter'])
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: C.bg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: C.border),
              ),
              child: Text(t, style: mono(color: C.textMuted, size: 10)),
            ),
        ]),
      ]),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatRow(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text('$label:', style: mono(color: C.textMuted, size: 12)),
      const Spacer(),
      Text(value, style: mono(color: color, size: 12)),
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
      if (_del) {
        _curr = full.substring(0, _curr.length - 1);
      } else {
        _curr = full.substring(0, _curr.length + 1);
      }
    });
    if (!_del && _curr == full) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _del = true);
    } else if (_del && _curr.isEmpty) {
      _del = false;
      _idx = (_idx + 1) % _roles.length;
    }
    await Future.delayed(Duration(milliseconds: _del ? 40 : 80));
    _tick();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(_curr, style: mono(color: C.accent, size: 15)),
      Text('|', style: mono(color: C.accent, size: 15)),
    ]);
  }
}

class _PrimaryBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PrimaryBtn(this.label, this.icon, this.onTap);
  @override
  State<_PrimaryBtn> createState() => _PrimaryBtnState();
}

class _PrimaryBtnState extends State<_PrimaryBtn> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hover
                  ? [C.accent.withOpacity(0.9), C.purple.withOpacity(0.9)]
                  : [C.accent, C.accentDim],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: C.accent.withOpacity(_hover ? 0.4 : 0.2),
                  blurRadius: 20)
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(widget.label,
                style: mono(color: Colors.black, size: 14)
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Icon(widget.icon, color: Colors.black, size: 16),
          ]),
        ),
      ),
    );
  }
}

class _OutlineBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _OutlineBtn(this.label, this.icon, this.onTap);
  @override
  State<_OutlineBtn> createState() => _OutlineBtnState();
}

class _OutlineBtnState extends State<_OutlineBtn> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: _hover ? C.card : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: _hover ? C.accent.withOpacity(0.5) : C.border),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(widget.icon, color: _hover ? C.accent : C.textMuted, size: 16),
            const SizedBox(width: 8),
            Text(widget.label,
                style: mono(color: _hover ? C.accent : C.textMuted, size: 13)),
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
    final catColors = {
      'LLM Frameworks': C.accent,
      'Backend': C.purple,
      'Vector DBs': C.success,
      'Languages': C.warning,
      'Cloud': C.accentDim,
      'Observability': Color(0xffFF6B9D),
      'Tools': C.textMuted,
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: mobile ? 24 : 80, vertical: 80),
      child: Column(children: [
        _SectionLabel('Skills & Technologies'),
        const SizedBox(height: 12),
        Text('The tools I use to build intelligent systems',
            style: body(color: C.textMuted)),
        const SizedBox(height: 48),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: cats.map((cat) {
            final catSkills = _skills.where((s) => s['cat'] == cat).toList();
            return _SkillGroup(cat, catSkills, catColors[cat] ?? C.accent);
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
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(category, style: mono(color: color, size: 11)),
        ]),
        const SizedBox(height: 14),
        ...items.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Icon(Icons.chevron_right_rounded,
                    size: 14, color: color.withOpacity(0.6)),
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
      color: C.surface.withOpacity(0.5),
      child: Column(children: [
        _SectionLabel('Experience'),
        const SizedBox(height: 12),
        Text('Where I\'ve built real-world AI systems',
            style: body(color: C.textMuted)),
        const SizedBox(height: 48),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: _ExperienceCard(mobile: mobile),
        ),
        const SizedBox(height: 28),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: _EducationCard(mobile: mobile),
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
    final achievements = [
      'Architected AI-integrated WhatsApp concierge system using LangGraph handling 100+ concurrent conversations.',
      'Designed stateful multi-agent LLM system with persistent conversational memory and seamless human operator handoff with full context continuity.',
      'Built human-in-the-loop workflows autonomously executing web search, flight/hotel bookings, Amazon actions, reminders, and CRED integrations.',
      'Designed RAG-powered memory architecture supporting long-term recall across months of user interactions for context-sensitive personalisation.',
      'Developed event-driven async backend with multi-source ingestion and real-time decision routing across APIs and fulfillment services.',
    ];

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: C.accentGlow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: C.accent.withOpacity(0.3))),
            child: const Icon(Icons.auto_awesome_rounded,
                color: C.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('AI Backend Engineer', style: heading3()),
                const SizedBox(height: 2),
                Text('Pinch Lifestyle Pvt Ltd',
                    style: mono(color: C.accent, size: 13)),
              ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: C.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: C.success.withOpacity(0.3)),
            ),
            child: Text('Aug 2024 – Jan 2026',
                style: mono(color: C.success, size: 11)),
          ),
        ]),
        const SizedBox(height: 24),
        Container(height: 1, color: C.border),
        const SizedBox(height: 20),
        ...achievements.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                          color: C.accent, shape: BoxShape.circle)),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(a,
                        style:
                            body(color: C.textMuted).copyWith(fontSize: 14))),
              ]),
            )),
      ]),
    );
  }
}

class _EducationCard extends StatelessWidget {
  final bool mobile;
  const _EducationCard({required this.mobile});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.border),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: C.purpleGlow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: C.purple.withOpacity(0.3))),
          child: const Icon(Icons.school_rounded, color: C.purple, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('B.S in Data Science and Application',
              style: heading3().copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Text('Indian Institute of Technology, Madras',
              style: mono(color: C.purple, size: 12)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: C.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: C.purple.withOpacity(0.3)),
          ),
          child: Text('2023 – 2027', style: mono(color: C.purple, size: 11)),
        ),
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
        const SizedBox(height: 12),
        Text('Things I\'ve built, shipped and maintained',
            style: body(color: C.textMuted)),
        const SizedBox(height: 48),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: _ProjectsGrid(mobile: mobile),
        ),
      ]),
    );
  }
}

class _ProjectsGrid extends StatelessWidget {
  final bool mobile;
  const _ProjectsGrid({required this.mobile});
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: _projects
          .map((p) => _ProjectCard(project: p, mobile: mobile))
          .toList(),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final Project project;
  final bool mobile;
  const _ProjectCard({required this.project, required this.mobile});
  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: widget.mobile ? double.infinity : 330,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _hover ? C.cardHover : C.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: _hover ? p.tagColor.withOpacity(0.4) : C.border),
          boxShadow: _hover
              ? [BoxShadow(color: p.tagColor.withOpacity(0.12), blurRadius: 30)]
              : [],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: p.tagColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: p.tagColor.withOpacity(0.3)),
              ),
              child: Text(p.tag, style: mono(color: p.tagColor, size: 10)),
            ),
            const Spacer(),
            if (p.github != null)
              _IconLink(Icons.code_rounded, 'GitHub', p.github!),
            if (p.web != null)
              _IconLink(Icons.open_in_new_rounded, 'Web', p.web!),
          ]),
          const SizedBox(height: 16),
          Text(p.title, style: heading3().copyWith(fontSize: 18)),
          const SizedBox(height: 10),
          Text(p.description,
              style: body(color: C.textMuted).copyWith(fontSize: 13),
              maxLines: 4,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 20),
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
                          border: Border.all(color: C.border),
                        ),
                        child:
                            Text(chip, style: mono(color: C.textDim, size: 10)),
                      ))
                  .toList()),
        ]),
      ),
    );
  }
}

class _IconLink extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final String url;
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
                Icon(widget.icon, size: 18, color: _h ? C.accent : C.textDim),
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
      color: C.surface.withOpacity(0.5),
      child: Column(children: [
        _SectionLabel('Contact'),
        const SizedBox(height: 12),
        Text("Let's build something great together",
            style: body(color: C.textMuted)),
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
        'color': C.accent
      },
      {
        'icon': Icons.person_rounded,
        'label': 'LinkedIn',
        'value': 'https://www.linkedin.com/in/obaidaman14',
        'color': C.purple
      },
      {
        'icon': Icons.code_rounded,
        'label': 'GitHub',
        'value': 'https://www.github.com/obaidaaman',
        'color': C.success
      },
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: contacts
          .map((c) => _ContactCard(
                icon: c['icon'] as IconData,
                label: c['label'] as String,
                value: c['value'] as String,
                color: c['color'] as Color,
                mobile: mobile,
              ))
          .toList(),
    );
  }
}

class _ContactCard extends StatefulWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  final bool mobile;
  const _ContactCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color,
      required this.mobile});
  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _hover = false;
  bool _copied = false;

  void _open() {
    if (widget.label == 'Email') {
      js.context.callMethod('open', ['mailto:${widget.value}']);
    } else {
      js.context.callMethod('open', [widget.value]);
    }
  }

  void _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = widget.label == 'Email'
        ? widget.value
        : widget.value
            .replaceFirst('https://', '')
            .replaceFirst('www.', '')
            .replaceFirst('wwww.', '');

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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _hover ? widget.color.withOpacity(0.4) : C.border),
            boxShadow: _hover
                ? [
                    BoxShadow(
                        color: widget.color.withOpacity(0.12), blurRadius: 20)
                  ]
                : [],
          ),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: widget.color.withOpacity(0.2)),
              ),
              child: Icon(widget.icon, color: widget.color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(widget.label, style: heading3().copyWith(fontSize: 15)),
            const SizedBox(height: 4),
            Text(
              displayValue,
              style: mono(color: C.textMuted, size: 10),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            // Open button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _hover ? widget.color.withOpacity(0.15) : C.bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _hover ? widget.color.withOpacity(0.4) : C.border),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.open_in_new_rounded,
                    size: 13, color: _hover ? widget.color : C.textMuted),
                const SizedBox(width: 6),
                Text('Open',
                    style: mono(
                        color: _hover ? widget.color : C.textMuted, size: 11)),
              ]),
            ),
            const SizedBox(height: 8),
            // Copy button — stopPropagation via separate GestureDetector with HitTestBehavior
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _copy();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: _copied ? widget.color.withOpacity(0.15) : C.bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color:
                          _copied ? widget.color.withOpacity(0.4) : C.border),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_copied ? Icons.check_rounded : Icons.copy_rounded,
                      size: 13, color: _copied ? widget.color : C.textMuted),
                  const SizedBox(width: 6),
                  Text(_copied ? 'Copied!' : 'Copy',
                      style: mono(
                          color: _copied ? widget.color : C.textMuted,
                          size: 11)),
                ]),
              ),
            ),
          ]),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 28),
      decoration:
          BoxDecoration(border: Border(top: BorderSide(color: C.border))),
      child: Row(children: [
        Text.rich(TextSpan(children: [
          TextSpan(
              text: 'AO',
              style: mono(color: C.accent, size: 14)
                  .copyWith(fontWeight: FontWeight.w900)),
          TextSpan(text: '.dev', style: mono(color: C.textDim, size: 12)),
        ])),
        const Spacer(),
        Text('Built with Flutter & ❤️',
            style: mono(color: C.textDim, size: 11)),
        const Spacer(),
        Text('© 2025 Aman Obaid', style: mono(color: C.textDim, size: 11)),
      ]),
    );
  }
}

// ─── HELPERS ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 24, height: 1, color: C.accent),
        const SizedBox(width: 10),
        Text(text.toUpperCase(),
            style: mono(size: 11).copyWith(letterSpacing: 3)),
        const SizedBox(width: 10),
        Container(width: 24, height: 1, color: C.accent),
      ]),
      const SizedBox(height: 10),
      Text(text, style: heading2()),
    ]);
  }
}
