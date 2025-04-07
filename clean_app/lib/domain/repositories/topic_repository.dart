import '../models/topic.dart';

/// Repository interface for topic-related operations
abstract class TopicRepository {
  /// Get all topics
  Future<List<Topic>> getTopics();

  /// Get a specific topic by ID
  Future<Topic> getTopic(String id);

  /// Get topics by category
  Future<List<Topic>> getTopicsByCategory(String category);

  /// Mark a topic as completed
  Future<void> markTopicAsCompleted(String id);

  /// Get topic progress
  Future<double> getTopicProgress(String id);

  Future<List<Topic>> getWorkTopics();
  Future<List<Topic>> getEducationTopics();
  Future<List<Topic>> getTravelTopics();
  Future<void> updateTopicCompletion(String topicId, bool isCompleted);
  Future<Topic?> getTopicById(String topicId);
}
