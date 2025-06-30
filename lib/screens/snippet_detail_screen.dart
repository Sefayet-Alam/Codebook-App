import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../models/snippet.dart';

class SnippetDetailScreen extends StatelessWidget {
  final Snippet snippet;

  const SnippetDetailScreen({super.key, required this.snippet});

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: snippet.code ?? ''));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Code copied to clipboard')));
  }

  void _shareSnippet() {
    final text =
        '''
${snippet.title} (${snippet.language} - ${snippet.section})

Code:
${snippet.code}

Explanation:
${snippet.markdown}
''';
    Share.share(text, subject: snippet.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(snippet.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyCode(context),
          ),
          IconButton(icon: const Icon(Icons.share), onPressed: _shareSnippet),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            Text(
              '${snippet.language} - ${snippet.section}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: HighlightView(
                snippet.code ?? '',
                language: (snippet.language?.toLowerCase() ?? 'plaintext'),
                theme: githubTheme,
                textStyle: const TextStyle(
                  fontFamily: 'SourceCodePro',
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Explanation:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            MarkdownBody(
              data: snippet.markdown.isNotEmpty
                  ? snippet.markdown
                  : '_No explanation provided._',
              styleSheet: MarkdownStyleSheet.fromTheme(
                Theme.of(context),
              ).copyWith(p: const TextStyle(fontSize: 14, height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}
