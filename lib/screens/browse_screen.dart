import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import 'snippets_screen.dart'; // Correct import

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  void _addSectionDialog(BuildContext context, FirestoreService firestore) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Section'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Section name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                firestore.addSection(name);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.watch<FirestoreService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Codebook'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addSectionDialog(context, firestore),
          ),
        ],
      ),
      body: StreamBuilder<List<Section>>(
        stream: firestore.streamSections(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));

          final sections = snapshot.data ?? [];

          if (sections.isEmpty)
            return const Center(child: Text('No sections yet'));

          return ListView.builder(
            itemCount: sections.length,
            itemBuilder: (_, index) {
              final section = sections[index];
              return ListTile(
                title: Text(section.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => firestore.deleteSection(section.id),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SnippetsScreen(
                        sectionId: section.id,
                        sectionName: section.name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
