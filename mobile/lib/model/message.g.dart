// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageCreate _$MessageCreateFromJson(Map<String, dynamic> json) =>
    MessageCreate(
      text: json['text'] as String,
      audioUrl: json['audioUrl'] as String?,
    );

Map<String, dynamic> _$MessageCreateToJson(MessageCreate instance) =>
    <String, dynamic>{
      'text': instance.text,
      'audioUrl': instance.audioUrl,
    };

MessageResponse _$MessageResponseFromJson(Map<String, dynamic> json) =>
    MessageResponse(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      role: json['role'] as String,
      text: json['text'] as String,
      audioUrl: json['audioUrl'] as String?,
      feedback: json['feedback'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MessageResponseToJson(MessageResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'role': instance.role,
      'text': instance.text,
      'audioUrl': instance.audioUrl,
      'feedback': instance.feedback,
      'createdAt': instance.createdAt.toIso8601String(),
    };
