import 'dart:io';

import 'package:ai_xmentor_voice/models/chat_message.dart';

import 'package:dart_openai/dart_openai.dart';

import 'package:ai_xmentor_voice/env/env.dart';

import 'dart:convert';

class ChatApi {
  static const _model = 'gpt-3.5-turbo';

  ChatApi() {
    OpenAI.apiKey = Env.apiKey;

    // OpenAI.organization = Env.organization;
  }

  Future<String> completeChat(List<ChatMessage> messages) async {
    final OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: _model,
      messages: messages
          .map((e) => OpenAIChatCompletionChoiceMessageModel(
                role: e.isUserMessage
                    ? OpenAIChatMessageRole.user
                    : OpenAIChatMessageRole.assistant,
                content: [
                  OpenAIChatCompletionChoiceMessageContentItemModel.text(
                    e.content,
                  )
                ],
              ))
          .toList(),
    );

    final content = chatCompletion.choices.first.message.content;
    print(content);

    final String response = content?.first.text ?? "";

    return response;
  }

  Future<String> completeSTT(String path) async {
    OpenAIAudioModel translation =
        await OpenAI.instance.audio.createTranslation(
      file: File(path),

      model: "whisper-1",

      responseFormat: OpenAIAudioResponseFormat.text,

      // prompt: "Receive a Vietnamese audio file, convert it into text."
    );

    return translation.text;
  }
}
