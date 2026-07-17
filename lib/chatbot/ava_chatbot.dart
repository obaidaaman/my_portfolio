import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import 'chat_service.dart';

class AvaChatbot extends StatefulWidget {
  const AvaChatbot({super.key});
  @override
  State<AvaChatbot> createState() => _AvaChatbotState();
}

class _AvaChatbotState extends State<AvaChatbot> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  bool _showPopup = true;
  bool _isLoading = false;
  final List<ChatMessage> _messages = [];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  late final ChatService _svc;

  @override
  void initState() {
    super.initState();
    _svc = ChatService(threadId: const Uuid().v4());
    _messages.add(ChatMessage(
      message: "Hi, I'm Ava — Aman's assistant. Ask me about his work, skills, or experience.",
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
    super.dispose();
  }

  void _toggle() => setState(() {
        _isOpen = !_isOpen;
        _showPopup = false;
      });

  void _scrollToBottom() {
    if (!_scroll.hasClients) return;
    Future.delayed(const Duration(milliseconds: 80), () {
      _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
    });
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
    if (!mounted) return;
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
          child: AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 150),
            child: _ChatPanel(
              messages: _messages,
              isLoading: _isLoading,
              controller: _ctrl,
              scrollController: _scroll,
              onSend: _send,
              onClose: _toggle,
            ),
          ),
        ),
      if (_showPopup && !_isOpen)
        Positioned(
          right: 88,
          bottom: 28,
          child: _WelcomePopup(onDismiss: () => setState(() => _showPopup = false)),
        ),
      Positioned(
        right: 24,
        bottom: 24,
        child: GestureDetector(
          onTap: _toggle,
          child: Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accent),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                _isOpen ? Icons.close_rounded : Icons.chat_bubble_rounded,
                key: ValueKey(_isOpen),
                color: AppColors.bg,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _ChatPanel extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool isLoading;
  final TextEditingController controller;
  final ScrollController scrollController;
  final VoidCallback onSend;
  final VoidCallback onClose;

  const _ChatPanel({
    required this.messages,
    required this.isLoading,
    required this.controller,
    required this.scrollController,
    required this.onSend,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 520,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            border: const Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(children: [
            const _AvaAvatar(size: 34),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Ava', style: AppText.h3()),
              Row(children: [
                Container(
                    width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('Online', style: AppText.mono(size: 11)),
              ]),
            ]),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              color: AppColors.textMuted,
              onPressed: onClose,
            ),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(14),
            itemCount: messages.length + (isLoading ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i == messages.length) return const _TypingIndicator();
              return _Bubble(messages[i]);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.lg)),
            border: const Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: AppText.body(),
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Ask me anything…',
                  hintStyle: AppText.body(color: AppColors.textDim),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  filled: true,
                  fillColor: AppColors.bg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSend,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: const Icon(Icons.arrow_upward_rounded, color: AppColors.bg, size: 18),
              ),
            ),
          ]),
        ),
      ]),
    );
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
        color: AppColors.bg,
        border: Border.all(color: AppColors.accent, width: 1.4),
      ),
      child: Center(child: Text('A', style: AppText.h3(color: AppColors.accent, size: size * 0.42))),
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
        mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[const _AvaAvatar(size: 24), const SizedBox(width: 8)],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isUser ? AppColors.accent : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: msg.isUser ? null : Border.all(color: AppColors.border),
              ),
              child: Text(msg.message, style: AppText.body(color: msg.isUser ? AppColors.bg : AppColors.text)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      const _AvaAvatar(size: 24),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Row(mainAxisSize: MainAxisSize.min, children: [
            for (int i = 0; i < 3; i++) ...[
              Opacity(
                opacity: (math.sin((_ctrl.value * 2 * math.pi) - (i * 0.8)) + 1) / 2,
                child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
              ),
              if (i < 2) const SizedBox(width: 4),
            ],
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
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          const _AvaAvatar(size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("I'm Ava", style: AppText.mono(color: AppColors.text, size: 12)),
              const SizedBox(height: 2),
              Text('Ask me about Aman', style: AppText.body(color: AppColors.textMuted, size: 13)),
            ]),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
          ),
        ]),
      ),
    );
  }
}