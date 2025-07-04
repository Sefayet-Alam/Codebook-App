// snippet_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/snippet.dart';
import '../services/firestore_service.dart';

class SnippetEditScreen extends StatefulWidget {
  final String sectionId;
  final Snippet? snippet;

  const SnippetEditScreen({super.key, required this.sectionId, this.snippet});

  @override
  State<SnippetEditScreen> createState() => _SnippetEditScreenState();
}

class _SnippetEditScreenState extends State<SnippetEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _codeController;
  late final TextEditingController _languageController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.snippet?.title ?? '');
    _codeController = TextEditingController(text: widget.snippet?.code ?? '');
    _languageController = TextEditingController(
      text: widget.snippet?.language ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  Future<void> _saveSnippet() async {
    if (_formKey.currentState!.validate()) {
      final firestore = context.read<FirestoreService>();

      final snippet = Snippet(
        id: widget.snippet?.id ?? '',
        title: _titleController.text.trim(),
        code: _codeController.text.trim(),
        language: _languageController.text.trim(),
        createdAt: widget.snippet?.createdAt ?? DateTime.now(),
        // Add any other required fields here
      );

      if (widget.snippet == null) {
        // Add new snippet
        await firestore.addSnippet(widget.sectionId, snippet);
      } else {
        // Update existing snippet (make sure ID is not empty!)
        if (snippet.id.isEmpty) {
          // Defensive check
          throw Exception('Cannot update snippet without valid id');
        }
        await firestore.updateSnippet(widget.sectionId, snippet);
      }

      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.snippet != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Snippet' : 'Add Snippet'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Snippet'),
                    content: const Text(
                      'Are you sure you want to delete this snippet?',
                    ),
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
                  final firestore = context.read<FirestoreService>();
                  await firestore.deleteSnippet(
                    widget.sectionId,
                    widget.snippet!.id,
                  );
                  if (context.mounted) {
                    Navigator.pop(context); // Exit edit screen
                    Navigator.pop(context); // Back to list screen
                  }
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) =>
                    val!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _languageController,
                decoration: const InputDecoration(labelText: 'Language'),
                validator: (val) =>
                    val!.isEmpty ? 'Please enter language' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                maxLines: 12,
                decoration: const InputDecoration(labelText: 'Code'),
                validator: (val) => val!.isEmpty ? 'Please enter code' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveSnippet,
                child: Text(isEditing ? 'Update Snippet' : 'Add Snippet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
