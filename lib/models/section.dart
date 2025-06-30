import 'package:cloud_firestore/cloud_firestore.dart';

class Section {
  final String id;
  final String name;

  Section({required this.id, required this.name});

  factory Section.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Section(id: doc.id, name: data['name'] ?? '');
  }
}
