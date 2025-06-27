import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/ai_service.dart';
import '../services/firestore_service.dart';
import '../models/snippet.dart';
import 'package:provider/provider.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _promptController = TextEditingController();
  final AIService _aiService = AIService();

  final String _chatId = 'default_chat'; // For now, single chat session

  bool _isLoading = false;
  late final FirestoreService _firestore;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _firestore = context.read<FirestoreService>();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _copyCodeToClipboard(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Code copied to clipboard')));
  }

  Future<void> _sendPrompt() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    _promptController.clear();
    setState(() => _isLoading = true);

    final userMessage = ChatMessage(
      id: '',
      text: prompt,
      isUser: true,
      timestamp: DateTime.now(),
    );

    await _firestore.addChatMessage(_chatId, userMessage);

    try {
      final fullPrompt = prompt; // Or build with snippets if needed
      final responseText = await _aiService.getCodeSuggestion(fullPrompt);

      final aiMessage = ChatMessage(
        id: '',
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      await _firestore.addChatMessage(_chatId, aiMessage);
    } catch (e) {
      final errorMessage = ChatMessage(
        id: '',
        text: 'Error: $e',
        isUser: false,
        timestamp: DateTime.now(),
      );
      await _firestore.addChatMessage(_chatId, errorMessage);
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  Widget _buildMessage(ChatMessage message) {
    final isUser = message.isUser;
    final alignment = isUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final bgColor = isUser
        ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
        : Theme.of(context).colorScheme.secondary.withOpacity(0.3);
    final textColor = isUser ? Colors.white : Colors.black87;

    final markdownStyle = MarkdownStyleSheet(
      p: TextStyle(color: textColor, fontSize: 14, height: 1.4),
      code: const TextStyle(
        fontFamily: 'SourceCodePro',
        fontSize: 14,
        backgroundColor: Color(0xFF1E1E1E),
        color: Colors.greenAccent,
      ),
      codeblockDecoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 0),
                bottomRight: Radius.circular(isUser ? 0 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  offset: const Offset(0, 1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Stack(
              children: [
                MarkdownBody(
                  data: message.text,
                  styleSheet: markdownStyle,
                  selectable: true,
                  // Optional: onTapLink handler if needed
                ),
                if (_containsCodeBlock(message.text))
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.copy,
                        size: 20,
                        color: Colors.white70,
                      ),
                      tooltip: 'Copy all code',
                      onPressed: () async {
                        final codeBlocks = _extractAllCodeBlocks(message.text);
                        if (codeBlocks.isNotEmpty) {
                          final codeText = codeBlocks.join('\n\n');
                          await Clipboard.setData(
                            ClipboardData(text: codeText),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Code copied to clipboard'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(message.timestamp),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  bool _containsCodeBlock(String text) {
    return text.contains('```');
  }

  List<String> _extractAllCodeBlocks(String text) {
    final regex = RegExp(r'```(?:\w*\n)?([\s\S]*?)```');
    final matches = regex.allMatches(text);
    return matches.map((m) => m.group(1)?.trim() ?? '').toList();
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Code Assistant')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _firestore.streamChatMessages(_chatId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      _buildMessage(messages[index]),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      hintText: 'Ask for code snippet or explanation...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: (_) => _sendPrompt(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendPrompt,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.tealAccent
                      : Theme.of(context).colorScheme.primary,
                  tooltip: 'Send message',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
