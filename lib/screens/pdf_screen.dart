import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';

import '../models/snippet.dart';
import '../services/firestore_service.dart';
import '../utils/pdf_generator.dart';

class PdfScreen extends StatefulWidget {
  const PdfScreen({super.key});

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  bool _saving = false;

  Future<String?> _savePdfToAppStorage(pw.Document pdf) async {
    try {
      final bytes = await pdf.save();

      final dir = await getExternalStorageDirectory();
      if (dir == null) throw 'Could not access external storage directory';

      final filePath =
          '${dir.path}/all_snippets_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e) {
      debugPrint('Error saving PDF: $e');
      return null;
    }
  }

  Future<void> _showTeamNameDialog() async {
    final teamNameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Team Name'),
        content: TextField(
          controller: teamNameController,
          decoration: const InputDecoration(
            hintText: 'Team name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final trimmed = teamNameController.text.trim();
              if (trimmed.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a team name')),
                );
              } else {
                Navigator.pop(context, trimmed);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _printSaveAndOpenPdf(result);
    }
  }

  Future<void> _printSaveAndOpenPdf(String teamName) async {
    setState(() => _saving = true);

    final firestore = context.read<FirestoreService>();
    final snippets = await firestore.getAllSnippets();

    if (snippets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No snippets found to export.')),
      );
      setState(() => _saving = false);
      return;
    }

    // Use simple PDF generation here for a single-column combined PDF
    final pdf = await PdfGenerator.generateSimplePdf(
      snippets,
      teamName: teamName,
    );

    final savedPath = await _savePdfToAppStorage(pdf);

    setState(() => _saving = false);

    if (savedPath != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF saved to:\n$savedPath')));

      try {
        final result = await OpenFile.open(savedPath);
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open PDF: ${result.message}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to open PDF: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save PDF. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export All Snippets as PDF'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: _saving
                  ? const Text('Saving PDF...')
                  : const Text('Export All Snippets'),
              onPressed: _saving ? null : _showTeamNameDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent[700],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
