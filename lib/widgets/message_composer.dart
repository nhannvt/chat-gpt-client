// widgets/message_composer.dart

import 'package:flutter/material.dart';

import 'package:ai_xmentor_voice/audio_recorder.dart';

class MessageComposer extends StatelessWidget {
  MessageComposer({
    required this.onSubmitted,
    required this.onRecordStart,
    required this.onRecordStop,
    required this.awaitingResponse,
    super.key,
  });

  final TextEditingController _messageController = TextEditingController();

  final void Function(String) onSubmitted;

  final void Function(String) onRecordStart;

  final void Function(String) onRecordStop;

  final bool awaitingResponse;

  final bool awaitingRecord = false;

  String? audioPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.05),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: !awaitingResponse
                  ? TextField(
                      controller: _messageController,
                      onSubmitted: onSubmitted,
                      decoration: const InputDecoration(
                        hintText: 'Write your message here...',
                        border: InputBorder.none,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Fetching response...'),
                        ),
                      ],
                    ),
            ),
            Recorder(
              onStop: (path) {
                onRecordStop(path);
              },
            ),
            IconButton(
              onPressed: !awaitingResponse
                  ? () => onSubmitted(_messageController.text)
                  : null,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
