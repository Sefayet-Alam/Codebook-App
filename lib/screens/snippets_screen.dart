import 'dart:io';

import 'package:codebook_app/utils/pdf_generator.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../services/firestore_service.dart';
import '../models/snippet.dart';
import 'snippet_edit_screen.dart';
import '../widgets/code_viewer.dart';

class SnippetsScreen extends StatefulWidget {
  final String sectionId;
  final String sectionName;

  const SnippetsScreen({
    super.key,
    required this.sectionId,
    required this.sectionName,
  });

  @override
  State<SnippetsScreen> createState() => _SnippetsScreenState();
}

class _SnippetsScreenState extends State<SnippetsScreen> {
  List<Snippet> _snippets = [];
  String? _selectedLanguage;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSnippets();
  }

  void _loadSnippets() {
    final firestore = context.read<FirestoreService>();
    firestore.streamSnippets(widget.sectionId).listen((snippets) {
      setState(() => _snippets = snippets);
    });
  }

  Future<void> _reorderSnippets(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;

    setState(() {
      final item = _snippets.removeAt(oldIndex);
      _snippets.insert(newIndex, item);
    });

    final firestore = context.read<FirestoreService>();
    await firestore.updateSnippetsOrder(widget.sectionId, _snippets);
  }

  void _showCode(Snippet snippet) {
    showDialog(
      context: context,
      builder: (_) => CodeViewer(
        code: snippet.code,
        language: snippet.language,
        onCopy: () {
          Clipboard.setData(ClipboardData(text: snippet.code));
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Code copied')));
        },
        onShare: () {
          Share.share(
            snippet.code ?? '',
            subject: snippet.title ?? 'Code Snippet',
          );
        },
      ),
    );
  }

  void _showLanguageFilterDialog() {
    final languages = _snippets.map((s) => s.language).toSet().toList();
    languages.sort();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('All'),
                selected: _selectedLanguage == null,
                onTap: () {
                  setState(() => _selectedLanguage = null);
                  Navigator.pop(context);
                },
              ),
              ...languages.map(
                (lang) => ListTile(
                  title: Text(lang),
                  selected: _selectedLanguage == lang,
                  onTap: () {
                    setState(() => _selectedLanguage = lang);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      return status.isGranted;
    }
    return true;
  }

  Future<String?> _savePdfToDownloads(pw.Document pdf) async {
    await _requestPermission();
    try {
      final bytes = await pdf.save();

      Directory downloadsDir;

      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final filePath =
          '${downloadsDir.path}/codebook_snippet_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);

      await file.writeAsBytes(bytes);

      return file.path;
    } catch (e) {
      debugPrint('Error saving PDF: $e');
      return null;
    }
  }

  void saveDoc(Snippet snippet) async {
    setState(() => _saving = true);

    final pdf = await PdfGenerator.generateSimplePdf([snippet]);
    final savedPath = await _savePdfToDownloads(pdf);

    setState(() => _saving = false);

    if (savedPath != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved to $savedPath')));
    } else if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save PDF')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSnippets = _selectedLanguage == null
        ? _snippets
        : _snippets.where((s) => s.language == _selectedLanguage).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedLanguage == null
              ? 'Snippets - ${widget.sectionName}'
              : 'Snippets - ${widget.sectionName} (${_selectedLanguage})',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by language',
            onPressed: _showLanguageFilterDialog,
          ),
        ],
      ),
      body: _saving
          ? const Center(child: CircularProgressIndicator())
          : filteredSnippets.isEmpty
          ? Center(
              child: Text(
                _selectedLanguage == null
                    ? 'No snippets yet'
                    : 'No snippets for $_selectedLanguage',
              ),
            )
          : ReorderableListView.builder(
              itemCount: filteredSnippets.length,
              onReorder: _reorderSnippets,
              buildDefaultDragHandles: false,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final snippet = filteredSnippets[index];
                return Card(
                  key: ValueKey(snippet.id),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(snippet.title ?? 'Untitled'),
                    subtitle: Text(snippet.language),
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'view') {
                          _showCode(snippet);
                        } else if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SnippetEditScreen(
                                sectionId: widget.sectionId,
                                snippet: snippet,
                              ),
                            ),
                          );
                        } else if (value == 'delete') {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete Snippet'),
                              content: Text('Delete "${snippet.title}"?'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                ),
                                TextButton(
                                  child: const Text('Delete'),
                                  onPressed: () => Navigator.pop(context, true),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            final firestore = context.read<FirestoreService>();
                            await firestore.deleteSnippet(
                              widget.sectionId,
                              snippet.id,
                            );
                          }
                        } else if (value == 'print') {
                          saveDoc(snippet);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'view', child: Text('View')),
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                        const PopupMenuItem(
                          value: 'print',
                          child: Text('Print'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SnippetEditScreen(sectionId: widget.sectionId),
            ),
          );
        },
      ),
    );
  }
}
