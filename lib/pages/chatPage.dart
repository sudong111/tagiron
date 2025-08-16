import 'package:flutter/material.dart';
import '../services/chatService.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _contentsController = TextEditingController();
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();

    _chatService.onMessageReceived = (msg) {
      setState(() {
        _messages.add(msg);
      });
    };

    _chatService.connect();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          bottom: 30,
          left: 16,
          right: 16,
        ),
      ),
    );
  }

  void _sendMessage() {
    final userName = _userNameController.text.trim();
    final content = _contentsController.text.trim();

    if (userName.isEmpty) {
      _showSnackBar('아이디를 입력해주세요.');
      return;
    }

    if (content.isEmpty) {
      _showSnackBar('메세지를 입력해주세요.');
      return;
    }

    if (!_chatService.isConnected) {
      _showSnackBar('서버와 연결해주세요.');
      return;
    }

    _chatService.sendMessage(userName, content);
    _contentsController.clear();
  }

  @override
  void dispose() {
    _chatService.disconnect();
    _userNameController.dispose();
    _contentsController.dispose();
    super.dispose();
  }

  Widget _userNameInputField() {
    return SizedBox(
      height: 40,
      width: 150,
      child: TextField(
        controller: _userNameController,
        decoration: const InputDecoration(
          hintText: "아이디 입력",
          contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _chatField() {
    return Expanded(
      child: ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(_messages[index]),
        ),
      ),
    );
  }

  Widget _messageInputField() {
    return Expanded(
      child: TextField(
        controller: _contentsController,
        decoration: const InputDecoration(
          hintText: '메시지를 입력하세요',
        ),
      ),
    );
  }

  Widget _messageSubmitButton() {
    return IconButton(
      icon: const Icon(Icons.send),
      onPressed: _sendMessage,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Tagiron Chat'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _userNameInputField(),
              ],
            ),
          ),
          _chatField(),
          Row(
            children: [
              _messageInputField(),
              _messageSubmitButton()
            ],
          ),
        ],
      ),
    );
  }
}
