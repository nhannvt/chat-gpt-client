// chat_page.dart

import 'package:ai_xmentor_voice/api/chat_api.dart';

import 'package:ai_xmentor_voice/models/chat_message.dart';

import 'package:ai_xmentor_voice/widgets/message_bubble.dart';

import 'package:ai_xmentor_voice/widgets/message_composer.dart';

import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart' as ap;

class ChatPage extends StatefulWidget {
  const ChatPage({
    required this.chatApi,
    super.key,
  });

  final ChatApi chatApi;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messages = <ChatMessage>[
    ChatMessage('Hello, how can I help?', false),
  ];

  var _awaitingResponse = false;

  final _audioPlayer = ap.AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI xMentor')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ..._messages.map(
                  (msg) => MessageBubble(
                    content: msg.content,
                    isUserMessage: msg.isUserMessage,
                  ),
                ),
              ],
            ),
          ),
          MessageComposer(
            onSubmitted: _onSubmitted,
            onRecordStart: _onRecordStart,
            onRecordStop: _onRecordStop,
            awaitingResponse: _awaitingResponse,
          ),
        ],
      ),
    );
  }

  Future<void> _onRecordStart(String message) async {}

  Future<void> _onRecordStop(String path) async {
    setState(() {
      _awaitingResponse = true;
    });

    try {
      _audioPlayer.play(
        ap.DeviceFileSource(path),
      );

      final response = await widget.chatApi.completeSTT(path);

      setState(() {
        _messages.add(ChatMessage(response, true));

        _awaitingResponse = false;
      });
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );

      setState(() {
        _awaitingResponse = false;
      });
    }
  }

  Future<void> _onSubmitted(String message) async {
    setState(() {
      _messages.add(ChatMessage(message, true));

      _awaitingResponse = true;
    });

    try {
      final response = await widget.chatApi.completeChat(_messages);

      setState(() {
        _messages.add(ChatMessage(response, false));

        _awaitingResponse = false;
      });
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );

      setState(() {
        _awaitingResponse = false;
      });
    }
  }
}
