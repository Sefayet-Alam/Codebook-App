import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/snippet.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Reference to 'sections' collection
  CollectionReference get _sectionsRef => _db.collection('sections');

  // --- Sections ---

  Stream<List<Section>> streamSections() {
    return _sectionsRef.orderBy('orderIndex').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Section.fromDoc(doc)).toList();
    });
  }

  Future<void> addSection(String name) async {
    final existingSections = await _sectionsRef
        .orderBy('orderIndex', descending: true)
        .limit(1)
        .get();

    int nextIndex = 0;
    if (existingSections.docs.isNotEmpty) {
      final data = existingSections.docs.first.data() as Map<String, dynamic>;
      nextIndex = (data['orderIndex'] ?? 0) + 1;
    }

    await _sectionsRef.add({'name': name, 'orderIndex': nextIndex});
  }

  Future<void> updateSectionsOrder(List<Section> sections) async {
    final batch = _db.batch();
    for (var i = 0; i < sections.length; i++) {
      final docRef = _sectionsRef.doc(sections[i].id);
      batch.update(docRef, {'orderIndex': i});
    }
    await batch.commit();
  }

  Future<void> deleteSection(String sectionId) async {
    // Delete all snippets inside section first
    final snippetsSnapshot = await _sectionsRef
        .doc(sectionId)
        .collection('snippets')
        .get();

    for (var doc in snippetsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Then delete section document
    await _sectionsRef.doc(sectionId).delete();
  }

  // --- Snippets under a section ---

  Stream<List<Snippet>> streamSnippets(String sectionId) {
    return _sectionsRef
        .doc(sectionId)
        .collection('snippets')
        .orderBy('orderIndex') // maintain order for UI reorder
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    Snippet.fromMap(doc.id, doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  Future<void> addSnippet(String sectionId, Snippet snippet) async {
    final snippetsRef = _sectionsRef.doc(sectionId).collection('snippets');

    final existingSnippets = await snippetsRef
        .orderBy('orderIndex', descending: true)
        .limit(1)
        .get();

    int nextIndex = 0;
    if (existingSnippets.docs.isNotEmpty) {
      nextIndex = (existingSnippets.docs.first.data()['orderIndex'] ?? 0) + 1;
    }

    final data = snippet.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['orderIndex'] = nextIndex;
    data['section'] = snippet.section;

    await snippetsRef.add(data);
  }

  Future<void> updateSnippet(String sectionId, Snippet snippet) async {
    final data = snippet.toMap();
    await _sectionsRef
        .doc(sectionId)
        .collection('snippets')
        .doc(snippet.id)
        .update(data);
  }

  Future<void> deleteSnippet(String sectionId, String snippetId) async {
    try {
      await _sectionsRef
          .doc(sectionId)
          .collection('snippets')
          .doc(snippetId)
          .delete();
    } catch (e) {
      print('Error deleting snippet: $e');
      rethrow;
    }
  }

  Future<void> updateSnippetsOrder(
    String sectionId,
    List<Snippet> snippets,
  ) async {
    final batch = _db.batch();
    final snippetsRef = _sectionsRef.doc(sectionId).collection('snippets');

    for (var i = 0; i < snippets.length; i++) {
      final docRef = snippetsRef.doc(snippets[i].id);
      batch.update(docRef, {'orderIndex': i});
    }

    await batch.commit();
  }

  // Get all snippets across all sections (collectionGroup query)
  Future<List<Snippet>> getAllSnippets() async {
    final querySnapshot = await _db.collectionGroup('snippets').get();
    return querySnapshot.docs
        .map(
          (doc) => Snippet.fromMap(doc.id, doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  // --- Chat Messages under aiChats collection ---

  CollectionReference get _aiChatsRef => _db.collection('aiChats');

  Stream<List<ChatMessage>> streamChatMessages(String chatId) {
    return _aiChatsRef
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ChatMessage(
              id: doc.id,
              text: data['text'] ?? '',
              isUser: data['isUser'] ?? false,
              timestamp: (data['timestamp'] as Timestamp).toDate(),
            );
          }).toList(),
        );
  }

  Future<void> addChatMessage(String chatId, ChatMessage message) async {
    await _aiChatsRef.doc(chatId).collection('messages').add({
      'text': message.text,
      'isUser': message.isUser,
      'timestamp': message.timestamp,
    });
  }
}

// --- Section model ---
class Section {
  final String id;
  final String name;

  Section({required this.id, required this.name});

  factory Section.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Section(id: doc.id, name: data['name'] ?? '');
  }
}

// --- ChatMessage model ---
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
