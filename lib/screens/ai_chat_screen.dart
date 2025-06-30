import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../services/ai_service.dart';
import '../services/firestore_service.dart';
import '../models/chat_message.dart';

class AIChatScreen extends StatefulWidget {
  final String uid;
  final String email;

  const AIChatScreen({super.key, required this.uid, required this.email});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final FirestoreService _firestore;
  late final AIService _aiService;

  final String _chatId = 'default_chat';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firestore = FirestoreService(widget.uid);
    _aiService = AIService(widget.uid);
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
      final response = await _aiService.getCodeSuggestion(prompt);
      final aiMessage = ChatMessage(
        id: '',
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      await _firestore.addChatMessage(_chatId, aiMessage);
    } catch (e) {
      await _firestore.addChatMessage(
        _chatId,
        ChatMessage(
          id: '',
          text: 'Error: $e',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
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

  Widget _buildMessage(ChatMessage message) {
    final isUser = message.isUser;
    final alignment = isUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final bgColor = isUser
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceVariant;
    final textColor = isUser ? Colors.white : Colors.black87;

    final markdownStyle = MarkdownStyleSheet(
      p: TextStyle(color: textColor, fontSize: 16, height: 1.4),
      code: TextStyle(
        fontFamily: 'RobotoMono',
        fontSize: 14,
        backgroundColor: Colors.grey[200],
        color: Colors.black87,
      ),
      codeblockDecoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      blockquoteDecoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        border: Border(left: BorderSide(color: bgColor, width: 4)),
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isUser ? 12 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 12),
              ),
            ),
            child: MarkdownBody(
              data: message.text,
              styleSheet: markdownStyle,
              selectable: true,
              builders: {'code': CodeBlockBuilder(context)},
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(message.timestamp),
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  String _shortEmail(String email) {
    final atIndex = email.indexOf('@');
    String prefix = atIndex == -1 ? email : email.substring(0, atIndex);
    return prefix.length > 15 ? '${prefix.substring(0, 12)}...' : prefix;
  }

  @override
  Widget build(BuildContext context) {
    final shortEmail = _shortEmail(widget.email);
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Code Assistant'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(child: Text(shortEmail[0].toUpperCase())),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
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
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        _buildMessage(messages[index]),
                  );
                },
              ),
            ),
            if (_isLoading) const LinearProgressIndicator(minHeight: 2),
            SafeArea(
              top: false,
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promptController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant,
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
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _isLoading ? null : _sendPrompt,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

class CodeBlockBuilder extends MarkdownElementBuilder {
  final BuildContext context;

  CodeBlockBuilder(this.context);

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final code = element.textContent;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: SelectableText(
            code,
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.copy, size: 20),
            tooltip: 'Copy code',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Code copied!')));
            },
          ),
        ),
      ],
    );
  }
}
