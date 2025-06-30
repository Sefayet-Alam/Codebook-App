import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';

import 'snippets_screen.dart';
import '../models/section.dart';

class SectionsScreen extends StatefulWidget {
  const SectionsScreen({Key? key}) : super(key: key);

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  List<Section> _sections = [];
  late final FirestoreService firestore;

  @override
  void initState() {
    super.initState();
    firestore = context.read<FirestoreService>();
    firestore.streamSections().listen((sections) {
      if (mounted) setState(() => _sections = sections);
    });
  }

  Future<void> _reorderSections(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _sections.removeAt(oldIndex);
    _sections.insert(newIndex, item);
    setState(() {});
    await firestore.updateSectionsOrder(_sections);
  }

  void _addSectionDialog() {
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
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await firestore.addSection(name);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sections'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addSectionDialog),
        ],
      ),
      body: _sections.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ReorderableListView.builder(
              itemCount: _sections.length,
              onReorder: _reorderSections,
              padding: const EdgeInsets.all(8),
              buildDefaultDragHandles: false,
              itemBuilder: (context, index) {
                final section = _sections[index];
                return Card(
                  key: ValueKey(section.id),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(section.name),
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete Section'),
                            content: Text('Delete "${section.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await firestore.deleteSection(section.id);
                        }
                      },
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SnippetsScreen(
                          sectionId: section.id,
                          sectionName: section.name,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
