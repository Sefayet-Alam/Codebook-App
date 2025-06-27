import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
          '${downloadsDir.path}/all_snippets_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);

      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      debugPrint('Error saving PDF: $e');
      return null;
    }
  }

  Future<void> _printSaveAndOpenPdf() async {
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
    final pdf = await PdfGenerator.generateCombinedPdf(snippets);
    final savedPath = await _savePdfToDownloads(pdf);

    setState(() => _saving = false);

    if (savedPath != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF saved to:\n$savedPath')));

      final result = await OpenFile.open(savedPath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open PDF: ${result.message}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save PDF. Permission denied or error.'),
        ),
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
              onPressed: _saving ? null : _printSaveAndOpenPdf,
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
