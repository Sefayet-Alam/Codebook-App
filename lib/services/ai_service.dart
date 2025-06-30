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
      final limitedSnippets = snippets.take(3).toList();

      final snippetContext = limitedSnippets.isNotEmpty
          ? "User's snippets:\n${limitedSnippets.map((s) {
              final truncatedCode = s.code.length > 500 ? s.code.substring(0, 500) + '\n...' : s.code;
              return '### ${s.title} (${s.language})\n```${s.language}\n$truncatedCode\n```';
            }).join('\n')}"
          : "No snippets available";

      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              "model": "llama3-70b-8192",
              "messages": [
                {
                  "role": "system",
                  "content":
                      "You're a coding assistant. Format responses in markdown.\nUser's snippets:\n$snippetContext",
                },
                {"role": "user", "content": prompt},
              ],
              "temperature": 0.7,
              "max_tokens": 1024, // safer token count
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
    } on SocketException catch (e) {
      debugPrint('Network error: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } on TimeoutException {
      debugPrint('Request timed out');
      throw Exception('Request timed out after 15 seconds');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }
}
