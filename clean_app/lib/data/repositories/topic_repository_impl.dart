import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../../domain/entities/topic_entity.dart';
import '../../domain/repositories/topic_repository.dart';
import '../../domain/models/topic.dart';

class TopicRepositoryImpl implements TopicRepository {
  final String baseUrl;
  final http.Client client;

  TopicRepositoryImpl({
    this.baseUrl = 'https://api.example.com',
    http.Client? client,
  }) : client = client ?? http.Client();

  // Mock data for testing
  final List<Topic> _mockTopics = [
    Topic(
      id: '1',
      title: 'Daily Conversation',
      description: 'Learn common phrases and expressions used in daily life',
      level: 'Beginner',
      isCompleted: false,
      subtopics: [
        Topic(
          id: '1-1',
          title: 'Greetings',
          description: 'Learn how to greet people in different situations',
          level: 'Beginner',
          isCompleted: false,
        ),
        Topic(
          id: '1-2',
          title: 'Small Talk',
          description: 'Practice making small talk with others',
          level: 'Beginner',
          isCompleted: false,
        ),
      ],
    ),
    Topic(
      id: '2',
      title: 'Business English',
      description: 'Master professional communication in the workplace',
      level: 'Intermediate',
      isCompleted: false,
      subtopics: [
        Topic(
          id: '2-1',
          title: 'Meetings',
          description: 'Learn how to participate in business meetings',
          level: 'Intermediate',
          isCompleted: false,
        ),
        Topic(
          id: '2-2',
          title: 'Presentations',
          description: 'Practice giving effective presentations',
          level: 'Intermediate',
          isCompleted: false,
        ),
      ],
    ),
    Topic(
      id: '3',
      title: 'Travel English',
      description: 'Essential phrases for travelers',
      level: 'Beginner',
      isCompleted: false,
      subtopics: [
        Topic(
          id: '3-1',
          title: 'At the Airport',
          description: 'Learn airport-related vocabulary and phrases',
          level: 'Beginner',
          isCompleted: false,
        ),
        Topic(
          id: '3-2',
          title: 'Hotel Stay',
          description: 'Practice hotel check-in and common requests',
          level: 'Beginner',
          isCompleted: false,
        ),
      ],
    ),
  ];

  @override
  Future<List<Topic>> getTopics() async {
    // Return mock data instead of making API call
    return _mockTopics;
  }

  @override
  Future<Topic> getTopic(String id) async {
    // Return mock data instead of making API call
    final topic = _mockTopics.firstWhere(
      (topic) => topic.id == id,
      orElse: () => throw Exception('Topic not found'),
    );
    return topic;
  }

  @override
  Future<List<Topic>> getTopicsByCategory(String category) async {
    try {
      final response =
          await client.get(Uri.parse('$baseUrl/topics/category/$category'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Topic.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load topics by category');
      }
    } catch (e) {
      log('Error getting topics by category: $e');
      rethrow;
    }
  }

  @override
  Future<void> markTopicAsCompleted(String id) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    final topicIndex = _mockTopics.indexWhere((topic) => topic.id == id);
    if (topicIndex != -1) {
      _mockTopics[topicIndex] =
          _mockTopics[topicIndex].copyWith(isCompleted: true);
    }
  }

  @override
  Future<double> getTopicProgress(String id) async {
    // Simulate API call with random progress
    await Future.delayed(const Duration(milliseconds: 500));
    return 0.3 + (DateTime.now().millisecond % 70) / 100;
  }

  @override
  Future<List<Topic>> getWorkTopics() async {
    return _mockTopics.where((topic) => topic.level == 'Intermediate').toList();
  }

  @override
  Future<List<Topic>> getEducationTopics() async {
    return _mockTopics.where((topic) => topic.level == 'Beginner').toList();
  }

  @override
  Future<List<Topic>> getTravelTopics() async {
    return _mockTopics
        .where((topic) => topic.title.contains('Travel'))
        .toList();
  }

  @override
  Future<Topic?> getTopicById(String topicId) async {
    try {
      return await getTopic(topicId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateTopicCompletion(String topicId, bool isCompleted) async {
    await markTopicAsCompleted(topicId);
  }
}
