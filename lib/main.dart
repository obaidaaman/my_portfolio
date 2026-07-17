import 'package:flutter/material.dart';
import 'package:my_portfolio/widgets/experience_section.dart';
import 'package:my_portfolio/widgets/skills_section.dart';
import 'chatbot/ava_chatbot.dart';
import 'theme/app_theme.dart';
import 'widgets/common_widgets.dart';
import 'widgets/contact_section.dart';
import 'widgets/footer.dart';
import 'widgets/hero_section.dart';
import 'widgets/nav_bar.dart';
import 'widgets/projects_section.dart';


void main() => runApp(const PortfolioApp());

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aman Obaid — Software Engineer',
      theme: buildAppTheme(),
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
  final _sectionKeys = List.generate(5, (_) => GlobalKey());
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final isScrolled = _scroll.offset > 60;
      if (isScrolled != _scrolled) setState(() => _scrolled = isScrolled);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToSection(int index) {
    final ctx = _sectionKeys[index].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
        const GridBackground(),
        SingleChildScrollView(
          controller: _scroll,
          child: Column(children: [
            NavBar(scrolled: _scrolled, mobile: mobile, onTap: _scrollToSection),
            HeroSection(
              key: _sectionKeys[0],
              mobile: mobile,
              onContact: () => _scrollToSection(4),
            ),
            SkillsSection(key: _sectionKeys[1], mobile: mobile),
            ExperienceSection(key: _sectionKeys[2], mobile: mobile),
            ProjectsSection(key: _sectionKeys[3], mobile: mobile),
            ContactSection(key: _sectionKeys[4], mobile: mobile),
            const Footer(),
          ]),
        ),
        const AvaChatbot(),
      ]),
    );
  }
}