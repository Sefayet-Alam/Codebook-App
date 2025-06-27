import 'dart:async'; // TimeoutException
import 'dart:convert';
import 'dart:io'; // SocketException
import 'package:flutter/foundation.dart'; // debugPrint
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../env.dart'; // Import the generated env class
import '../models/snippet.dart';

class AIService {
  final String _apiKey = Env.groqApiKey;
  final String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Snippet>> _fetchAllSnippets() async {
    try {
      final snapshot = await _firestore
          .collectionGroup('snippets')
          .get()
          .timeout(const Duration(seconds: 10));

      return snapshot.docs
          .map(
            (doc) =>
                Snippet.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();
    } on TimeoutException {
      debugPrint('Snippet fetch timed out after 10 seconds');
      return [];
    } catch (e) {
      debugPrint('Snippet fetch error: $e');
      return [];
    }
  }

  Future<String> getCodeSuggestion(String prompt) async {
    if (_apiKey.isEmpty) {
      throw Exception('Groq API key is missing');
    }

    try {
      final snippets = await _fetchAllSnippets();
      final snippetContext = snippets.isNotEmpty
          ? "User's snippets:\n${snippets.map((s) => '### ${s.title} (${s.language})\n```${s.language}\n${s.code}\n```').join('\n')}"
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
              "max_tokens": 1024,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['choices'][0]['message']['content'];
      } else {
        throw Exception('API error ${response.statusCode}: ${response.body}');
      }
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timed out after 15 seconds');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }
}
