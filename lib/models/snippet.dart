import 'package:cloud_firestore/cloud_firestore.dart';

class Snippet {
  final String id;
  final String title;
  final String language;
  final String section;
  final String code;
  final String markdown;
  final DateTime createdAt;

  Snippet({
    required this.id,
    required this.title,
    required this.language,
    this.section = '', // default empty string if not provided
    required this.code,
    this.markdown = '', // default empty string
    required this.createdAt,
  });

  factory Snippet.fromMap(String id, Map<String, dynamic> data) {
    return Snippet(
      id: id,
      title: data['title'] ?? '',
      language: data['language'] ?? '',
      section: data['section'] ?? '',
      code: data['code'] ?? '',
      markdown: data['markdown'] ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'language': language,
      'section': section,
      'code': code,
      'markdown': markdown,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
