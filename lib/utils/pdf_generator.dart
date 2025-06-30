import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import '../models/snippet.dart';

class PdfGenerator {
  static pw.Font? _monospaceFont;
  static pw.Font? _regularFont;

  static Future<void> _loadFonts() async {
    if (_monospaceFont == null || _regularFont == null) {
      final monoData = await rootBundle.load(
        'assets/fonts/RobotoMono-Regular.ttf',
      );
      final regularData = await rootBundle.load(
        'assets/fonts/OpenSans-Regular.ttf',
      );

      _monospaceFont = pw.Font.ttf(monoData);
      _regularFont = pw.Font.ttf(regularData);
    }
  }

  static Future<pw.Document> generateSimplePdf(
    List<Snippet> snippets, {
    String? teamName,
  }) async {
    await _loadFonts();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(12),
        header: (context) {
          if (teamName == null || teamName.isEmpty) return pw.Container();
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Align(
              alignment: pw.Alignment.topLeft,
              child: pw.Text(
                teamName,
                style: pw.TextStyle(
                  font: _regularFont,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          );
        },
        footer: (context) => pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 10,
              color: PdfColors.grey,
            ),
          ),
        ),
        build: (context) => _buildContent(snippets),
      ),
    );

    return pdf;
  }

  static Future<pw.Document> generateCombinedPdf(
    List<Snippet> snippets, {
    required String teamName,
  }) async {
    await _loadFonts();
    final pdf = pw.Document();

    final Map<String, List<Snippet>> sectionMap = {};
    for (var snippet in snippets) {
      final section = (snippet.section?.trim().isNotEmpty ?? false)
          ? snippet.section!
          : '';
      sectionMap.putIfAbsent(section, () => []).add(snippet);
    }

    for (var entry in sectionMap.entries) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(12),
          header: (context) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Align(
              alignment: pw.Alignment.topLeft,
              child: pw.Text(
                teamName,
                style: pw.TextStyle(
                  font: _regularFont,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          footer: (context) => pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(
                font: _regularFont,
                fontSize: 10,
                color: PdfColors.grey,
              ),
            ),
          ),
          build: (context) => _buildSectionContent(entry.key, entry.value),
        ),
      );
    }

    return pdf;
  }

  static List<pw.Widget> _buildContent(List<Snippet> snippets) {
    final Map<String, List<Snippet>> sectionMap = {};
    for (var snippet in snippets) {
      final section = (snippet.section?.trim().isNotEmpty ?? false)
          ? snippet.section!
          : '';
      sectionMap.putIfAbsent(section, () => []).add(snippet);
    }

    final content = <pw.Widget>[];

    sectionMap.forEach((section, sectionSnippets) {
      content.add(
        pw.Header(
          level: 0,
          child: pw.Text(
            section,
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
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
          style: pw.TextStyle(
            font: _regularFont,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
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
        style: pw.TextStyle(
          font: _regularFont,
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Paragraph(
        text: snippet.code ?? '',
        style: pw.TextStyle(font: _monospaceFont, fontSize: 12),
      ),
      pw.SizedBox(height: 12),
      pw.Divider(),
      pw.SizedBox(height: 10),
    ];
  }
}
