import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import '../models/snippet.dart';

class SnippetCard extends StatelessWidget {
  final Snippet snippet;

  const SnippetCard({required this.snippet, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        title: Text(snippet.title),
        subtitle: Text('${snippet.language} - ${snippet.section}'),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: HighlightView(
              snippet.code ?? '',
              language: (snippet.language?.toLowerCase() ?? 'plaintext'),
              theme: githubTheme,
              padding: const EdgeInsets.all(12),
              textStyle: const TextStyle(fontFamily: 'Courier', fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              snippet.markdown.isNotEmpty
                  ? snippet.markdown
                  : '_No explanation provided._',
            ),
          ),
        ],
      ),
    );
  }
}
