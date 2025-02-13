import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../client.dart';
import '../constants.dart';

part 'completion.freezed.dart';
part 'completion.g.dart';

@freezed
class ChatChoice with _$ChatChoice {
  const factory ChatChoice({
    required int index,
    ChatMessage? message,
    ChatChoiceDelta? delta,
    String? finishReason,
  }) = _ChatChoice;

  factory ChatChoice.fromJson(Map<String, Object?> json) =>
      _$ChatChoiceFromJson(json);
}

@freezed
class ChatChoiceDelta with _$ChatChoiceDelta {
  const factory ChatChoiceDelta({
    String? content,
    String? role,
  }) = _ChatChoiceDelta;

  factory ChatChoiceDelta.fromJson(Map<String, Object?> json) =>
      _$ChatChoiceDeltaFromJson(json);
}

/// ChatCompletionRequest is the request body for the chat completion endpoint.
@freezed
class ChatCompletionRequest with _$ChatCompletionRequest {
  const factory ChatCompletionRequest({
    /// ID of the model to use. See the
    /// [model endpoint compatibility table](https://platform.openai.com/docs/models/model-endpoint-compatibility)
    /// for details on which models work with the Chat API.
    required Model model,

    /// The messages to generate chat completions for, in the [chat format](https://platform.openai.com/docs/guides/chat/introduction).
    required List<ChatMessage> messages,

    /// The sampling temperature. Defaults to 1.
    /// What sampling temperature to use, between 0 and 2. Higher values l
    /// ike 0.8 will make the output more random, while lower values like 0.2
    /// will make it more focused and deterministic.
    ///
    /// We generally recommend altering this or [topP] but not both.
    double? temperature,

    /// The top-p sampling parameter. Defaults to 1.
    /// An alternative to sampling with temperature, called nucleus sampling,
    /// where the model considers the results of the tokens with top_p
    /// probability mass. So 0.1 means only the tokens comprising the top 10%
    /// probability mass are considered.
    ///
    /// We generally recommend altering this or [temperature] but not both.
    double? topP,

    /// How many chat completion choices to generate for each input message.
    /// Defaults to 1.
    int? n,

    /// If set, partial message deltas will be sent, like in ChatGPT.
    /// Tokens will be sent as data-only server-sent events as they
    /// become available, with the stream terminated by a data: [DONE] message.
    /// See the OpenAI Cookbook for example code. Defaults to false.
    bool? stream,

    /// Up to 4 sequences where the API will stop generating further tokens.
    /// Defaults to null
    List<String>? stop,

    /// The maximum number of tokens to generate in the chat completion.
    ///  defaults to inf.
    /// The total length of input tokens and generated tokens is limited by the
    ///  model's context length.
    int? maxTokens,

    /// Number between -2.0 and 2.0. Positive values penalize new tokens
    /// based on whether they appear in the text so far, increasing the model's
    /// likelihood to talk about new topics.
    double? presencePenalty,

    /// Number between -2.0 and 2.0. Positive values penalize new tokens
    /// based on whether they appear in the text so far, increasing the
    /// model's likelihood to talk about new topics.
    double? frequencyPenalty,

    /// Modify the likelihood of specified tokens appearing in the completion.
    /// Defaults to null.
    ///  Accepts a json object that maps tokens (specified by their token ID in
    /// the tokenizer) to an associated bias value from -100 to 100.
    /// Mathematically, the bias is added to the logits generated by the model
    /// prior to sampling. The exact effect will vary per model, but values
    ///  between -1 and 1 should decrease or increase likelihood of selection;
    ///  values like -100 or 100 should result in a ban or exclusive selection
    /// of the relevant token.
    Map<String, dynamic>? logitBias,

    /// A unique identifier representing your end-user, which can help OpenAI to
    /// monitor and detect abuse. Learn more.
    String? user,
  }) = _ChatCompletionRequest;

  factory ChatCompletionRequest.fromJson(Map<String, Object?> json) =>
      _$ChatCompletionRequestFromJson(json);
}

/// ChatCompletionResponse is the response body for the chat completion endpoint.
/// ```json
/// {
///   "id": "chatcmpl-123",
///   "object": "chat.completion",
///   "created": 1677652288,
///   "choices": [{
///     "index": 0,
///     "message": {
///       "role": "assistant",
///       "content": "\n\nHello there, how may I assist you today?",
///     },
///     "finish_reason": "stop"
///   }],
///   "usage": {
///     "prompt_tokens": 9,
///     "completion_tokens": 12,
///     "total_tokens": 21
///   }
/// }
/// ```
@freezed
class ChatCompletionResponse with _$ChatCompletionResponse {
  const factory ChatCompletionResponse({
    /// The list of choices for the completion.
    required List<ChatChoice> choices,

    /// The ID of the completion.
    required String id,

    /// The object type of the completion.
    required String object,

    /// The time the completion was created.
    required int created,

    /// The usage statistics for the completion.
    ChatCompletionUsage? usage,
  }) = _ChatCompletionResponse;

  factory ChatCompletionResponse.fromJson(Map<String, Object?> json) =>
      _$ChatCompletionResponseFromJson(json);
}

@freezed
class ChatCompletionUsage with _$ChatCompletionUsage {
  const factory ChatCompletionUsage({
    /// The number of tokens used for the prompt.
    required int promptTokens,

    /// The number of tokens generated for the completion.
    required int completionTokens,

    /// The total number of tokens used for the prompt and completion.
    required int totalTokens,
  }) = _ChatCompletionUsage;

  factory ChatCompletionUsage.fromJson(Map<String, Object?> json) =>
      _$ChatCompletionUsageFromJson(json);
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String content,
    required ChatMessageRole role,
  }) = _ChatMessage;
  factory ChatMessage.fromJson(Map<String, Object?> json) =>
      _$ChatMessageFromJson(json);
}

@JsonEnum(valueField: "role")
enum ChatMessageRole {
  system("system"),
  assistant("assistant"),
  user("user");

  final String role;
  const ChatMessageRole(this.role);
}

extension ChatCompletion on OpenaiClient {
  static const kEndpoint = "chat/completions";
  Future<ChatCompletionResponse> sendChatCompletion(
      ChatCompletionRequest request) async {
    final data = await sendRequest(ChatCompletion.kEndpoint, request);
    return ChatCompletionResponse.fromJson(data);
  }

  Future sendChatCompletionStream(
    ChatCompletionRequest request, {
    Function(ChatCompletionResponse)? onSuccess,
  }) async {
    return sendStreamRequest(
      ChatCompletion.kEndpoint,
      jsonEncode(request),
      onSuccess: (data) =>
          onSuccess?.call(ChatCompletionResponse.fromJson(data)),
    );
  }
}
