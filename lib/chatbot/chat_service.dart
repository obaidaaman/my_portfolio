import 'dart:convert';
import 'package:http/http.dart' as http;

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