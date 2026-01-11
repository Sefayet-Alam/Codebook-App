import 'dart:async'; // TimeoutException
import 'dart:convert';
import 'dart:io'; // SocketException
import 'package:flutter/foundation.dart'; // debugPrint
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../env.dart'; // Your env file with API key
import '../models/snippet.dart';
import 'firestore_service.dart';

class AIService {
  final String uid;
  final String _apiKey = Env.groqApiKey;
  final String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final FirestoreService _firestoreService;

  AIService(this.uid) {
    _firestoreService = FirestoreService(uid);
  }

  Future<List<Snippet>> _fetchUserSnippets() {
    // Use existing FirestoreService method to get all snippets across all sections
    return _firestoreService.getAllSnippets();
  }

  Future<String> getCodeSuggestion(String prompt) async {
    if (_apiKey.isEmpty) {
      throw Exception('Groq API key is missing');
    }

    try {
      final snippets = await _fetchUserSnippets();

      // Limit number of snippets to send (adjust as needed)
      final snippetsToSend = snippets.take(5).toList();

      // Limit length of each snippet's code (adjust length as needed)
      final truncatedLength = 800;

      final snippetContext = snippetsToSend.isNotEmpty
          ? "User's snippets:\n${snippetsToSend.map((s) {
              final truncatedCode = s.code.length > truncatedLength ? s.code.substring(0, truncatedLength) + '\n...' : s.code;
              return '### ${s.title} (${s.language})\n```${s.language}\n$truncatedCode\n```';
            }).join('\n\n')}"
          : "No snippets available";

      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              "model": "openai/gpt-oss-120b",
              "messages": [
                {
                  "role": "system",
                  "content":
                      "You're a coding assistant. Format responses in markdown.Reply in brief.If user asks for code, only give snippet (with as less comments possible).Give explanation only when user asks.\nUser's snippets:\n$snippetContext",
                },
                {"role": "user", "content": prompt},
              ],
              "temperature": 0.7,
              "max_tokens": 1024,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('AI response: $data');
        return data['choices'][0]['message']['content'] ?? '';
      } else {
        debugPrint('API error ${response.statusCode}: ${response.body}');
        throw Exception('API error ${response.statusCode}: ${response.body}');
      }
    } on SocketException catch (_) {
      throw Exception('Network error: Please check your internet connection.');
    } on TimeoutException catch (_) {
      throw Exception('Request timeout: The server took too long to respond.');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
