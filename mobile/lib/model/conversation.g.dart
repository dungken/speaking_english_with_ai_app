// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
      userRole: json['userRole'] as String,
      aiRole: json['aiRole'] as String,
      situation: json['situation'] as String,
    );

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'userRole': instance.userRole,
      'aiRole': instance.aiRole,
      'situation': instance.situation,
    };

ConversationCreate _$ConversationCreateFromJson(Map<String, dynamic> json) =>
    ConversationCreate(
      userRole: json['userRole'] as String,
      aiRole: json['aiRole'] as String,
      situation: json['situation'] as String,
    );

Map<String, dynamic> _$ConversationCreateToJson(ConversationCreate instance) =>
    <String, dynamic>{
      'userRole': instance.userRole,
      'aiRole': instance.aiRole,
      'situation': instance.situation,
    };

ConversationResponse _$ConversationResponseFromJson(
        Map<String, dynamic> json) =>
    ConversationResponse(
      id: json['id'] as String,
      userId: json['userId'] as String,
      topic: json['topic'] as String,
      aiAssistant: json['aiAssistant'] as String,
      situationDescription: json['situationDescription'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      score: (json['score'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ConversationResponseToJson(
        ConversationResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'topic': instance.topic,
      'aiAssistant': instance.aiAssistant,
      'situationDescription': instance.situationDescription,
      'createdAt': instance.createdAt.toIso8601String(),
      'score': instance.score,
    };
