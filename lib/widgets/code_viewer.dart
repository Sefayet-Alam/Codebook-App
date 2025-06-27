import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart'; // VSCode-like dark theme

class CodeViewer extends StatelessWidget {
  final String code;
  final String language;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;

  const CodeViewer({
    super.key,
    required this.code,
    required this.language,
    this.onCopy,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E), // match VSCode dark bg
      title: const Text('View Code', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: HighlightView(
          code,
          language: language.toLowerCase(),
          theme: vs2015Theme,
          padding: const EdgeInsets.all(12),
          textStyle: const TextStyle(
            fontFamily: 'SourceCodePro',
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
      actions: [
        if (onCopy != null)
          TextButton.icon(
            icon: const Icon(Icons.copy, color: Colors.white70),
            label: const Text('Copy', style: TextStyle(color: Colors.white70)),
            onPressed: () {
              onCopy!();
              Navigator.pop(context);
            },
          ),
        if (onShare != null)
          TextButton.icon(
            icon: const Icon(Icons.share, color: Colors.white70),
            label: const Text('Share', style: TextStyle(color: Colors.white70)),
            onPressed: () {
              onShare!();
              Navigator.pop(context);
            },
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}
