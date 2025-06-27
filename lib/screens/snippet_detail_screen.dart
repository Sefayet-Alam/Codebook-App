import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart'; // Clipboard
import '../models/snippet.dart';

class SnippetDetailScreen extends StatelessWidget {
  final Snippet snippet;

  const SnippetDetailScreen({Key? key, required this.snippet})
    : super(key: key);

  void _shareSnippet(BuildContext context) {
    final shareContent =
        '''
${snippet.title} (${snippet.language} - ${snippet.section})

Code:
${snippet.code}

Explanation:
${snippet.markdown}
''';

    Share.share(shareContent, subject: snippet.title);
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: snippet.code));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Code copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(snippet.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share snippet',
            onPressed: () => _shareSnippet(context),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy code',
            onPressed: () => _copyCode(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            Text(
              '${snippet.language} - ${snippet.section}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: HighlightView(
                snippet.code,
                language: snippet.language.toLowerCase(),
                theme: githubTheme,
                padding: const EdgeInsets.all(12),
                textStyle: const TextStyle(
                  fontFamily: 'SourceCodePro',
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Explanation:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Divider(),
            MarkdownBody(
              data: snippet.markdown.isEmpty
                  ? '_No explanation provided._'
                  : snippet.markdown,
              styleSheet: MarkdownStyleSheet.fromTheme(
                Theme.of(context),
              ).copyWith(p: const TextStyle(fontSize: 14, height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }
}
