import 'package:cloud_firestore/cloud_firestore.dart';

class Snippet {
  final String id;
  final String title;
  final String language;
  final String section;
  final String code;
  final String markdown;
  final DateTime createdAt;
  final int? orderIndex; // Add orderIndex as nullable int

  Snippet({
    required this.id,
    required this.title,
    required this.language,
    this.section = '',
    required this.code,
    this.markdown = '',
    required this.createdAt,
    this.orderIndex,
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
      orderIndex: data['orderIndex'] != null ? data['orderIndex'] as int : null,
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
      'orderIndex': orderIndex,
    };
  }
}
