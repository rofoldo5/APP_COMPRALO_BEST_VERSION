import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _loading = true;
    });
    _controller.clear();
    _scrollDown();

    final response = await AiService.ask(text);
    setState(() {
      _messages.add({'role': 'ai', 'text': response});
      _loading = false;
    });
    _scrollDown();
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFf5576c),
              radius: 18,
              child: Text('AI', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Asistente de Mercado',
                    style: TextStyle(fontSize: 15, color: Color(0xFF2d2d2d))),
                Text('Pregúntame sobre cualquier producto',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (_loading && i == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Pensando...',
                              style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                }
                final msg = _messages[i];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      gradient: isUser
                          ? const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)])
                          : const LinearGradient(
                              colors: [Color(0xFFf093fb), Color(0xFFf5576c)]),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                    ),
                    child: Text(msg['text'] ?? '',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14, height: 1.4)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 16, right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              top: 12,
            ),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: '¿Qué quieres saber sobre un producto?',
                      hintStyle: const TextStyle(fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFF8F4FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color.fromARGB(255, 144, 22, 157), Color.fromARGB(255, 208, 26, 51)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}