import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import '../models/snippet.dart';

class PdfGenerator {
  static pw.Font? _monospaceFont;

  /// Load monospace font once
  static Future<void> _loadFonts() async {
    if (_monospaceFont == null) {
      final fontData = await rootBundle.load(
        'assets/fonts/RobotoMono-Regular.ttf',
      );
      _monospaceFont = pw.Font.ttf(fontData);
    }
  }

  /// Export one snippet PDF
  static Future<pw.Document> generateSnippetPdf(Snippet snippet) async {
    return generateSimplePdf([snippet]);
  }

  /// Combined full export: section-by-section
  static Future<pw.Document> generateCombinedPdf(List<Snippet> snippets) async {
    await _loadFonts();
    final pdf = pw.Document();

    final Map<String, List<Snippet>> sectionMap = {};
    for (var snippet in snippets) {
      final section = (snippet.section?.trim().isNotEmpty ?? false)
          ? snippet.section!
          : 'No Section';
      sectionMap.putIfAbsent(section, () => []).add(snippet);
    }

    // Add each section as a MultiPage
    for (var entry in sectionMap.entries) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (context) {
            return _buildSectionContent(entry.key, entry.value);
          },
        ),
      );
    }

    return pdf;
  }

  /// Reusable for small PDF export
  static Future<pw.Document> generateSimplePdf(List<Snippet> snippets) async {
    await _loadFonts();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return _buildContent(snippets);
        },
      ),
    );

    return pdf;
  }

  static List<pw.Widget> _buildContent(List<Snippet> snippets) {
    final Map<String, List<Snippet>> sectionMap = {};
    for (var snippet in snippets) {
      final section = (snippet.section?.trim().isNotEmpty ?? false)
          ? snippet.section!
          : 'No Section';
      sectionMap.putIfAbsent(section, () => []).add(snippet);
    }

    final content = <pw.Widget>[];

    sectionMap.forEach((section, sectionSnippets) {
      content.add(
        pw.Header(
          level: 0,
          child: pw.Text(
            section,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
        ),
      );

      for (var snippet in sectionSnippets) {
        content.addAll(_snippetWidgets(snippet));
      }
    });

    return content;
  }

  static List<pw.Widget> _buildSectionContent(
    String section,
    List<Snippet> snippets,
  ) {
    final widgets = <pw.Widget>[
      pw.Header(
        level: 0,
        child: pw.Text(
          section,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
      ),
    ];

    for (var snippet in snippets) {
      widgets.addAll(_snippetWidgets(snippet));
    }

    return widgets;
  }

  static List<pw.Widget> _snippetWidgets(Snippet snippet) {
    return [
      pw.Text(
        snippet.title ?? 'No Title',
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 4),
      pw.Paragraph(
        text: snippet.code ?? '',
        style: pw.TextStyle(font: _monospaceFont, fontSize: 11),
      ),
      pw.SizedBox(height: 16),
      pw.Divider(),
      pw.SizedBox(height: 10),
    ];
  }
}
