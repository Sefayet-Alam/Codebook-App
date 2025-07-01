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

  /// Simple PDF generator — single column, compact, minimal spacing
  static Future<pw.Document> generateSimplePdf(
    List<Snippet> snippets, {
    String? teamName,
  }) async {
    await _loadFonts();
    final pdf = pw.Document();

    // Group snippets by section
    final Map<String, List<Snippet>> sectionMap = {};
    for (var snippet in snippets) {
      final section = snippet.section.trim().isNotEmpty
          ? snippet.section
          : 'No Section';
      sectionMap.putIfAbsent(section, () => []).add(snippet);
    }

    // Sort snippets inside each section by orderIndex or createdAt
    sectionMap.forEach((key, list) {
      list.sort((a, b) {
        if (a.orderIndex != null && b.orderIndex != null) {
          return a.orderIndex!.compareTo(b.orderIndex!);
        }
        return a.createdAt.compareTo(b.createdAt);
      });
    });

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
        build: (context) {
          final content = <pw.Widget>[];
          sectionMap.forEach((section, snippets) {
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

            for (var snippet in snippets) {
              content.addAll(_snippetWidgetsCompact(snippet));
            }
          });

          return content;
        },
      ),
    );

    return pdf;
  }

  /// Combined PDF generator — two columns, compact, grouped by section
  static Future<pw.Document> generateCombinedPdf(
    List<Snippet> snippets, {
    String? teamName,
  }) async {
    await _loadFonts();
    final pdf = pw.Document();

    // Group snippets by section
    final Map<String, List<Snippet>> sectionMap = {};
    for (var snippet in snippets) {
      final section = snippet.section.trim().isNotEmpty
          ? snippet.section
          : 'No Section';
      sectionMap.putIfAbsent(section, () => []).add(snippet);
    }

    // Sort snippets inside each section by orderIndex or createdAt
    sectionMap.forEach((key, list) {
      list.sort((a, b) {
        if (a.orderIndex != null && b.orderIndex != null) {
          return a.orderIndex!.compareTo(b.orderIndex!);
        }
        return a.createdAt.compareTo(b.createdAt);
      });
    });

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
        build: (context) {
          final content = <pw.Widget>[];

          // For each section, add a header and two-column snippet layout
          sectionMap.forEach((section, snippets) {
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

            // Two-column layout with Wrap
            content.add(
              pw.Wrap(
                spacing: 12,
                runSpacing: 12,
                children: snippets.map((snippet) {
                  return pw.Container(
                    width:
                        (PdfPageFormat.a4.width - 24 * 2 - 12) /
                        2, // page width - margins - spacing
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: _snippetWidgetsCompact(snippet),
                    ),
                  );
                }).toList(),
              ),
            );
          });

          return content;
        },
      ),
    );

    return pdf;
  }

  /// Snippet widgets with minimal spacing and compact layout
  static List<pw.Widget> _snippetWidgetsCompact(Snippet snippet) {
    return [
      pw.Text(
        snippet.title.isNotEmpty ? snippet.title : 'No Title',
        style: pw.TextStyle(
          font: _regularFont,
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 3),
      pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Paragraph(
          text: snippet.code,
          style: pw.TextStyle(font: _monospaceFont, fontSize: 11),
        ),
      ),
      pw.SizedBox(height: 6),
    ];
  }
}
