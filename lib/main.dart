/*
  Enhanced portfolio with Ava Chatbot integration
  - Floating chat button with animated icon
  - Chat interface with message history
  - API integration for real-time responses
  - Auto-scroll to contact section
*/
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
import 'dart:js' as js;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

import 'package:uuid/uuid.dart';

// ----------------- Plugin Registration
void registerPlugins([final Registrar? pluginRegistrar]) {
  final Registrar registrar = pluginRegistrar ?? webPluginRegistrar;
  UrlLauncherPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}

// ----------------- Constants
class CustomColor {
  static const Color scaffoldBg = Color(0xff252734);
  static const Color bgLight1 = Color(0xff333646);
  static const Color bgLight2 = Color(0xff424657);
  static const Color textFieldBg = Color(0xffC8C9CE);
  static const Color hintDark = Color(0xff666874);
  static const Color yellowSecondary = Color(0xffFFC25C);
  static const Color yellowPrimary = Color(0xffFFAF29);
  static const Color whitePrimary = Color(0xffEAEAEB);
  static const Color whiteSecondary = Color(0xffC8C9CE);
}

List<String> navTitles = [
  "Home",
  "Skills",
  "Projects",
  "Contact",
];

List<IconData> navIcons = [
  Icons.home,
  Icons.handyman_outlined,
  Icons.apps,
  Icons.quick_contacts_mail,
  Icons.web,
];

const double kMedDesktopWidth = 800;
const double kMinDesktopWidth = 600;

const List<Map> platformItems = [
  {"img": "assets/web_icon.png", "title": "Gen AI Development"},
  {"img": "assets/ios_icon.png", "title": "IOS Dev(Flutter)"},
  {"img": "assets/android_icon.png", "title": "Android Dev(Flutter)"},
];

const List<Map> skillItems = [
  {"img": "assets/genai_icon.png", "title": "Gen AI"},
  {"img": "assets/langchain_icon_r.png", "title": "Langchain"},
  {"img": "assets/rag.png", "title": "RAG"},
  {"img": "assets/flutter_icon.jpg", "title": "Flutter(Frontend)"},
  {"img": "assets/fast_api.png", "title": "FastAPI(Backend)"},
  {"img": "assets/firebase.png", "title": "Firebase(Backend)"},
  {"img": "assets/python.png", "title": "Python(Backend)"},
];

// ----------------- Chat Models
class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}

// ----------------- Chat Service
class ChatService {
  static const String baseUrl = 'https://personalaibot-1.onrender.com';
  final String threadId;

  ChatService({required this.threadId});

  Future<String> sendMessage(String query) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/query'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'query': query,
          'thread_id': threadId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'No response received';
      } else {
        return 'Error: Unable to get response (${response.statusCode})';
      }
    } catch (e) {
      return 'Error: Unable to connect to chatbot service. Please check if the API is running.';
    }
  }
}

// ----------------- Ava Chatbot Widget
// Modified AvaChatbot Widget with Welcome Popup
class AvaChatbot extends StatefulWidget {
  const AvaChatbot({super.key});

  @override
  State<AvaChatbot> createState() => _AvaChatbotState();
}

class _AvaChatbotState extends State<AvaChatbot>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatService _chatService;
  bool _isLoading = false;
  late AnimationController _animationController;
  late String _sessionThreadId;
  bool _showWelcomePopup = true;

  @override
  void initState() {
    super.initState();
    var uuid = const Uuid();
    _sessionThreadId = uuid.v4();
    print("Session id ${_sessionThreadId}");
    _chatService = ChatService(threadId: uuid.toString());
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Add welcome message
    _messages.add(ChatMessage(
      message: "Hi! I'm Ava, Aman's AI assistant. How can I help you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));

    // Auto-hide the welcome popup after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _showWelcomePopup) {
        setState(() {
          _showWelcomePopup = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    setState(() {
      _isOpen = !_isOpen;
      _showWelcomePopup = false; // Hide popup when chat is opened
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _dismissPopup() {
    setState(() {
      _showWelcomePopup = false;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add(ChatMessage(
        message: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    final response = await _chatService.sendMessage(userMessage);

    setState(() {
      _messages.add(ChatMessage(
        message: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isLoading = false;
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Chat Window
        if (_isOpen)
          Positioned(
            right: 20,
            bottom: 90,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 350,
                height: 500,
                decoration: BoxDecoration(
                  color: CustomColor.bgLight1,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: CustomColor.yellowPrimary, width: 1),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CustomColor.bgLight2,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: CustomColor.yellowPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                'A',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ava',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: CustomColor.whitePrimary,
                                  ),
                                ),
                                Text(
                                  'AI Assistant',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: CustomColor.whiteSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: CustomColor.whitePrimary),
                            onPressed: _toggleChat,
                          ),
                        ],
                      ),
                    ),
                    // Messages
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
                    ),
                    // Loading indicator
                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: CustomColor.bgLight2,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: CustomColor.yellowPrimary,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Ava is typing...',
                                    style: TextStyle(
                                      color: CustomColor.whiteSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Input Field
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CustomColor.bgLight2,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(
                                  color: CustomColor.whitePrimary),
                              decoration: InputDecoration(
                                hintText: 'Type your message...',
                                hintStyle: const TextStyle(
                                    color: CustomColor.hintDark),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: CustomColor.scaffoldBg,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: CustomColor.yellowPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.black),
                              onPressed: _sendMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Welcome Popup
        if (_showWelcomePopup && !_isOpen)
          Positioned(
            right: 90,
            bottom: 30,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CustomColor.bgLight2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CustomColor.yellowPrimary,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: CustomColor.yellowPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Talk to Ava Bot! 👋',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: CustomColor.whitePrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ask me anything about Aman',
                          style: TextStyle(
                            fontSize: 11,
                            color: CustomColor.whiteSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: CustomColor.whiteSecondary,
                        size: 18,
                      ),
                      onPressed: _dismissPopup,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Floating Action Button
        Positioned(
          right: 20,
          bottom: 20,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animationController.value * math.pi,
                child: FloatingActionButton(
                  onPressed: _toggleChat,
                  backgroundColor: CustomColor.yellowPrimary,
                  child: Icon(
                    _isOpen ? Icons.close : Icons.chat_bubble,
                    color: Colors.black,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: CustomColor.yellowPrimary,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? CustomColor.yellowPrimary
                    : CustomColor.bgLight2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.message,
                style: TextStyle(
                  color:
                      message.isUser ? Colors.black : CustomColor.whitePrimary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------- Project Utils
class ProjectUtils {
  final String image;
  final String title;
  final String subtitle;
  final String? androidLink;
  final String? IosLink;
  final String? githubLink;
  final String? webLink;

  ProjectUtils({
    required this.image,
    required this.title,
    required this.subtitle,
    this.androidLink,
    this.IosLink,
    this.githubLink,
    this.webLink,
  });
}

List<ProjectUtils> hobbyProjects = [];

List<ProjectUtils> workProjects = [
  ProjectUtils(
      image: "assets/projects/lynn.png",
      title: 'Lynn Concierge',
      subtitle:
          'Lynn, a WhatsApp-based AI concierge that manages your everyday tasks. It handles end-to-end lifestyle services through an intelligent automation layer connecting with real-world tools to fulfill requests and bring in a Human Concierge for complex tasks, ensuring the service remains reliable and personally guided.',
      webLink: 'https://concierge.pinch.co.in/lynn'),
  ProjectUtils(
      image: "assets/projects/real_estate.png",
      title: 'Prime View',
      subtitle:
          'Explore luxury living at its finest. Discover a collection of exquisite properties in the most sought-after locations, offering urban luxury and serene living.',
      webLink: "https://primeview-realestate.vercel.app/"),
  ProjectUtils(
      image: "assets/projects/quiz_master.png",
      title: 'Quiz Master',
      subtitle:
          'Developed a full-stack multi-user quiz application using Flask, Jinja2, and SQLite, enabling subject and chapter-wise quiz creation and participation with comprehensive admin interface.',
      githubLink: "https://github.com/obaidaaman/Quiz-Master"),
  ProjectUtils(
      image: "assets/projects/ai_chatbot.png",
      title: 'Personal AI Assistant(Ava)',
      subtitle:
          'An intelligent RAG(Retrieval Augmented Generation)-powered personal assistant using LangChain, that represents myself to professionals by integrating LLM capable of automated professional candidate representation.',
      githubLink: 'https://github.com/obaidaaman/PersonalAIBot'),
  ProjectUtils(
      image: "assets/projects/news_finder.jpg",
      title: 'News Feed',
      subtitle:
          'NewsFeed is an android application which displays the real time news data fetched from an API. This application uses Open APi from NewsApi.org .',
      githubLink: 'https://github.com/obaidaaman/Chat-Pod'),
];

// ----------------- Social Media Utils
class SocialMediaUtils {
  final String socialHandleLink;
  final String socialHandleName;
  final String socialHandleImage;

  SocialMediaUtils({
    required this.socialHandleLink,
    required this.socialHandleName,
    required this.socialHandleImage,
  });
}

List<SocialMediaUtils> socialHandles = [
  SocialMediaUtils(
      socialHandleLink: "amanobaidofficial01@gmail.com",
      socialHandleName: 'Gmail',
      socialHandleImage: 'assets/gmail.png'),
  SocialMediaUtils(
      socialHandleLink: "https://www.linkedin.com/in/obaidaman14/",
      socialHandleName: 'LinkedIn',
      socialHandleImage: 'assets/linkedin.png'),
  SocialMediaUtils(
      socialHandleLink: "https://x.com/AmanObaid07",
      socialHandleName: 'Twitter',
      socialHandleImage: 'assets/twitter.png'),
];

// ----------------- Main HomePage with Chatbot
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  // 1. Create Keys for each section
  final List<GlobalKey> navbarKeys = List.generate(5, (index) => GlobalKey());

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 2. Logic to scroll to a specific key
  void scrollToSection(int navIndex) {
    if (navIndex == 4) {
      // Blog Section (Link to external URL Example)
      // js.context.callMethod('open', ['https://your-blog-url.com']);
      return;
    }

    final key = navbarKeys[navIndex];
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        key: scaffoldKey,
        // Update Drawer to pass the function
        endDrawer: constraints.maxWidth <= 600
            ? CustomDrawer(onNavItemTap: (int navIndex) {
                scaffoldKey.currentState?.closeEndDrawer();
                scrollToSection(navIndex);
              })
            : null,
        backgroundColor: CustomColor.scaffoldBg,
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  // Header
                  constraints.maxWidth <= 600
                      ? HeaderMobile(
                          onMenuTap: () {
                            scaffoldKey.currentState?.openEndDrawer();
                          },
                        )
                      : HeaderDesktop(onNavMenuTap: (int navIndex) {
                          scrollToSection(navIndex);
                        }),

                  // HOME (Index 0)
                  Container(
                    key: navbarKeys[0], // Assign Key 0
                    child: constraints.maxWidth >= kMinDesktopWidth
                        ? DescriptionDev(onGetInTouch: () => scrollToSection(3))
                        : DescDevMobile(onGetInTouch: () => scrollToSection(3)),
                  ),

                  // SKILLS (Index 1)
                  Container(
                    key: navbarKeys[1], // Assign Key 1
                    color: CustomColor.bgLight1,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 60),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'What I can do?',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: CustomColor.whitePrimary),
                        ),
                        const SizedBox(height: 50),
                        if (constraints.maxWidth >= kMedDesktopWidth)
                          const SkillsDesktop()
                        else
                          const SkilsMobile(),
                      ],
                    ),
                  ),

                  // PROJECTS (Index 2)
                  Container(
                    key: navbarKeys[2], // Assign Key 2
                    child: const ProjectSection(),
                  ),

                  // CONTACT (Index 3)
                  Container(
                    key: navbarKeys[3], // Assign Key 3
                    child: const ContactSection(),
                  ),

                  // Footer
                  const SizedBox(height: 20),
                  const Footer()
                ],
              ),
            ),
            // Chatbot overlay
            const AvaChatbot(),
          ],
        ),
      );
    });
  }
}

// ----------------- All other widgets
class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 100,
      child: const Text(
          textAlign: TextAlign.center,
          "Made by Aman Obaid\nAll rights reserved"),
    );
  }
}

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 60),
      color: CustomColor.bgLight1,
      child: Column(
        children: [
          const Text(
            'Get in Touch',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CustomColor.whitePrimary),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Wrap(
              spacing: 25,
              runSpacing: 20,
              children: [
                for (int i = 0; i < socialHandles.length; i++)
                  Container(
                    width: 250, // Increased width slightly to fit email text
                    decoration: BoxDecoration(
                        color: CustomColor.bgLight2,
                        borderRadius: BorderRadius.circular(5)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      leading: Image.asset(
                        socialHandles[i].socialHandleImage,
                        width: 26,
                      ),
                      // 1. Show the Name
                      title: Text(socialHandles[i].socialHandleName),

                      // 2. Show the Email/Link visibly
                      subtitle: Text(
                        socialHandles[i].socialHandleLink,
                        style: const TextStyle(
                            fontSize: 12, color: CustomColor.whiteSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),

                      // 3. Add Copy Button on the side
                      trailing: IconButton(
                        icon: const Icon(Icons.content_copy,
                            size: 20, color: CustomColor.yellowPrimary),
                        tooltip: 'Copy to clipboard',
                        onPressed: () {
                          // Copy logic
                          Clipboard.setData(ClipboardData(
                              text: socialHandles[i].socialHandleLink));

                          // Show Feedback
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${socialHandles[i].socialHandleName} copied to clipboard!'),
                              backgroundColor: CustomColor.yellowPrimary,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                              width: 300,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              action: SnackBarAction(
                                label: 'OK',
                                textColor: Colors.black,
                                onPressed: () {},
                              ),
                            ),
                          );
                        },
                      ),

                      // 4. Main Tap Logic (Keep existing behavior as backup)
                      onTap: () async {
                        if (socialHandles[i].socialHandleName == 'Gmail') {
                          final Uri emailUri = Uri(
                              scheme: 'mailto',
                              path: socialHandles[i].socialHandleLink,
                              queryParameters: {
                                'subject': 'Inquiry from Portfolio'
                              });
                          try {
                            if (await canLaunchUrl(emailUri)) {
                              await launchUrl(emailUri);
                            } else {
                              // If mailto fails, fallback to copy
                              Clipboard.setData(ClipboardData(
                                  text: socialHandles[i].socialHandleLink));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Could not launch mail app. Email copied instead!')),
                              );
                            }
                          } catch (e) {
                            print(e);
                          }
                        } else {
                          // Open other links
                          js.context.callMethod(
                              "open", [socialHandles[i].socialHandleLink]);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key, required this.onNavItemTap});
  final Function(int) onNavItemTap; // Add this callback

  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: CustomColor.scaffoldBg,
        child: Column(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close))),
            Expanded(
              child: ListView.builder(
                  itemCount: navTitles.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 30),
                      onTap: () {
                        onNavItemTap(index); // Trigger callback
                      },
                      titleTextStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: CustomColor.whitePrimary),
                      leading: Icon(navIcons[index]),
                      title: Text(navTitles[index]),
                    );
                  }),
            )
          ],
        ));
  }
}

class DescriptionDev extends StatefulWidget {
  const DescriptionDev({super.key, required this.onGetInTouch});
  final VoidCallback onGetInTouch;

  @override
  State<DescriptionDev> createState() => _DescriptionDevState();
}

class _DescriptionDevState extends State<DescriptionDev> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 350),
      height: MediaQuery.of(context).size.height / 1.2,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Hi, \nI'm Aman Obaid\nA Software Development Engineer",
                style: TextStyle(
                    fontSize: 24,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                    color: CustomColor.whitePrimary),
              ),
              const SizedBox(height: 10),
              SizedBox(
                  width: 250,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      onPressed: widget.onGetInTouch,
                      child: const Text(
                        'Get in touch',
                        style: TextStyle(color: Colors.white),
                      ))),
            ],
          ),
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(colors: [
                CustomColor.scaffoldBg.withOpacity(0.3),
                CustomColor.scaffoldBg.withOpacity(0.3)
              ]).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Image.asset(
              height: MediaQuery.of(context).size.height / 2.6,
              'assets/Profile_img.png',
              width: MediaQuery.of(context).size.width / 2.7,
            ),
          )
        ],
      ),
    );
  }
}

class DescDevMobile extends StatelessWidget {
  const DescDevMobile({super.key, required this.onGetInTouch});
  final VoidCallback onGetInTouch;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
      height: screenHeight,
      constraints: const BoxConstraints(minHeight: 560.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(colors: [
                CustomColor.scaffoldBg.withOpacity(0.6),
                CustomColor.scaffoldBg.withOpacity(0.6),
              ]).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Image.asset(
              "assets/Profile_img.png",
              width: screenWidth / 2,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Hi,\nI'm Aman Obaid\nA Software Developer Engineer",
            style: TextStyle(
              fontSize: 24,
              height: 1.5,
              fontWeight: FontWeight.bold,
              color: CustomColor.whitePrimary,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: 190.0,
            child: ElevatedButton(
              onPressed: onGetInTouch,
              child: const Text("Get in touch"),
            ),
          )
        ],
      ),
    );
  }
}

class HeaderDesktop extends StatelessWidget {
  const HeaderDesktop({super.key, required this.onNavMenuTap});
  final Function(int) onNavMenuTap; // Add this callback

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      width: double.maxFinite,
      decoration: BoxDecoration(
          color: Colors.blueGrey,
          gradient: const LinearGradient(
              colors: [Colors.transparent, CustomColor.bgLight1]),
          borderRadius: BorderRadius.circular(80)),
      child: Row(
        children: [
          SiteLogo(onTap: () {}),
          const Spacer(),
          for (int i = 0; i < navTitles.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: TextButton(
                  onPressed: () {
                    onNavMenuTap(i); // Trigger the callback with index
                  },
                  child: Text(
                    navTitles[i],
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: CustomColor.whitePrimary),
                  )),
            )
        ],
      ),
    );
  }
}

class HeaderMobile extends StatelessWidget {
  const HeaderMobile({super.key, this.onLogoTap, this.onMenuTap});
  final VoidCallback? onLogoTap;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: Colors.blueGrey,
          gradient: LinearGradient(
              colors: [Colors.transparent, CustomColor.bgLight1]),
          borderRadius: BorderRadius.circular(80)),
      margin: EdgeInsets.fromLTRB(40, 5, 20, 5),
      child: Row(
        children: [
          SiteLogo(onTap: onLogoTap),
          Spacer(),
          IconButton(onPressed: onMenuTap, icon: Icon(Icons.menu)),
          SizedBox(width: 15)
        ],
      ),
    );
  }
}

class ProjectCardWidget extends StatelessWidget {
  const ProjectCardWidget({super.key, required this.project});
  final ProjectUtils project;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      height: 332,
      width: 260,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: CustomColor.bgLight2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            project.image,
            height: 140,
            width: 260,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 15, 12, 10),
            child: Text(
              project.title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: CustomColor.whitePrimary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Text(
              project.subtitle,
              style: const TextStyle(
                  color: CustomColor.whiteSecondary, fontSize: 10),
            ),
          ),
          const Spacer(),
          Container(
            color: CustomColor.bgLight1,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const Text(
                  'Available on:',
                  style: TextStyle(
                      color: CustomColor.yellowSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
                const Spacer(),

                // 1. Check for iOS Link
                if (project.IosLink != null)
                  InkWell(
                    onTap: () {
                      js.context.callMethod("open", [project.IosLink]);
                    },
                    child: Image.asset('assets/ios_icon.png', width: 16),
                  ),

                // 2. Check for Android Link
                if (project.androidLink != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: InkWell(
                      onTap: () {
                        js.context.callMethod("open", [project.androidLink]);
                      },
                      child: Image.asset('assets/android_icon.png', width: 17),
                    ),
                  ),

                // 3. Check for Github Link (Only shows if link exists)
                if (project.githubLink != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: InkWell(
                      onTap: () {
                        js.context.callMethod("open", [project.githubLink]);
                      },
                      child: Image.asset('assets/github.png', width: 17),
                    ),
                  ),

                // 4. Check for Web Link
                if (project.webLink != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: InkWell(
                      onTap: () {
                        js.context.callMethod("open", [project.webLink]);
                      },
                      child: Image.asset('assets/web_icon.png', width: 17),
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ProjectSection extends StatelessWidget {
  const ProjectSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 60),
      child: Column(
        children: [
          const Text(
            'My Projects',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CustomColor.whitePrimary),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Wrap(
              spacing: 25,
              runSpacing: 20,
              children: [
                for (int i = 0; i < workProjects.length; i++)
                  ProjectCardWidget(project: workProjects[i]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SiteLogo extends StatelessWidget {
  const SiteLogo({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        'AO',
        style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline),
      ),
    );
  }
}

class SkillsDesktop extends StatefulWidget {
  const SkillsDesktop({super.key});

  @override
  State<SkillsDesktop> createState() => _SkillsDesktopState();
}

class _SkillsDesktopState extends State<SkillsDesktop> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Wrap(
            spacing: 5.0,
            runSpacing: 5.0,
            children: [
              for (int i = 0; i < platformItems.length; i++)
                Container(
                  width: 200,
                  decoration: BoxDecoration(
                      color: CustomColor.bgLight2,
                      borderRadius: BorderRadius.circular(5)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    leading: Image.asset(platformItems[i]["img"], width: 26),
                    title: Text(platformItems[i]["title"]),
                  ),
                )
            ],
          ),
        ),
        const SizedBox(width: 80),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (int i = 0; i < skillItems.length; i++)
                  Chip(
                    backgroundColor: CustomColor.bgLight1,
                    label: Text(skillItems[i]["title"]),
                    avatar: Image.asset(skillItems[i]["img"]),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                  )
              ],
            ),
          ),
        )
      ],
    );
  }
}

class SkilsMobile extends StatelessWidget {
  const SkilsMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 500),
      child: Column(
        children: [
          for (int i = 0; i < platformItems.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 5),
              width: double.maxFinite,
              decoration: BoxDecoration(
                  color: CustomColor.bgLight2,
                  borderRadius: BorderRadius.circular(5)),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                leading: Image.asset(platformItems[i]["img"], width: 26),
                title: Text(platformItems[i]["title"]),
              ),
            ),
          const SizedBox(height: 50),
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            alignment: WrapAlignment.center,
            children: [
              for (int i = 0; i < skillItems.length; i++)
                Chip(
                  backgroundColor: CustomColor.bgLight1,
                  label: Text(skillItems[i]["title"]),
                  avatar: Image.asset(skillItems[i]["img"]),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                )
            ],
          )
        ],
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aman Obaid Portfolio',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
