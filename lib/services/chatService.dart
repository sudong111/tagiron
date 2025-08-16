import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class ChatService {
  StompClient? _stompClient;
  Function(String)? onMessageReceived;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void connect() {
    _stompClient = StompClient(
      config: StompConfig.SockJS(
        url: 'http://10.0.2.2:8080/ws-stomp',
        onConnect: (frame) {
          _isConnected = true;
          _onConnect(frame);
        },
        onDisconnect: (_) {
          _isConnected = false;
        },
        onWebSocketError: (error) {
          _isConnected = false;
        },
      ),
    );
    _stompClient!.activate();
  }

  void _onConnect(StompFrame frame) {
    _stompClient!.subscribe(
      destination: '/topic/public',
      callback: (frame) {
        if (frame.body == null) return;
        try {
          final data = jsonDecode(frame.body!);
          final msg = '${data['sender'] ?? 'Unknown'}: ${data['content'] ?? ''}';
          if (onMessageReceived != null) onMessageReceived!(msg);
        } catch (_) {
          if (onMessageReceived != null) onMessageReceived!(frame.body!);
        }
      },
    );
  }

  void sendMessage(String sender, String content) {
    final message = jsonEncode({"sender": sender, "content": content, "type": "CHAT"});
    _stompClient?.send(destination: '/app/chat.sendMessage', body: message);
  }

  void disconnect() {
    _stompClient?.deactivate();
  }
}