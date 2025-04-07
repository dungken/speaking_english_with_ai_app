import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/topic.dart';
import '../../domain/repositories/topic_repository.dart';

// Events
abstract class TopicEvent {}

class LoadTopics extends TopicEvent {}

class LoadTopicsByCategory extends TopicEvent {
  final String category;
  LoadTopicsByCategory(this.category);
}

class LoadTopic extends TopicEvent {
  final String id;
  LoadTopic(this.id);
}

class MarkTopicAsCompleted extends TopicEvent {
  final String topicId;
  final bool isCompleted;
  MarkTopicAsCompleted(this.topicId, this.isCompleted);
}

class LoadTopicProgress extends TopicEvent {
  final String id;
  LoadTopicProgress(this.id);
}

// States
abstract class TopicState {}

class TopicInitial extends TopicState {}

class TopicLoading extends TopicState {}

class TopicsLoaded extends TopicState {
  final List<Topic> topics;
  TopicsLoaded(this.topics);
}

class TopicLoaded extends TopicState {
  final List<Topic> workTopics;
  final List<Topic> educationTopics;
  final List<Topic> travelTopics;
  final Topic? topic;

  TopicLoaded({
    required this.workTopics,
    required this.educationTopics,
    required this.travelTopics,
    this.topic,
  });
}

class TopicProgressLoaded extends TopicState {
  final double progress;
  TopicProgressLoaded(this.progress);
}

class TopicError extends TopicState {
  final String message;
  TopicError(this.message);
}

class SingleTopicLoaded extends TopicState {
  final Topic topic;
  SingleTopicLoaded(this.topic);
}

// Bloc
class TopicBloc extends Bloc<TopicEvent, TopicState> {
  final TopicRepository _repository;

  TopicBloc({required TopicRepository repository})
      : _repository = repository,
        super(TopicLoading()) {
    on<LoadTopics>(_onLoadTopics);
    on<LoadTopicsByCategory>(_onLoadTopicsByCategory);
    on<LoadTopic>(_onLoadTopic);
    on<MarkTopicAsCompleted>(_onMarkTopicAsCompleted);
    on<LoadTopicProgress>(_onLoadTopicProgress);
  }

  Future<void> _onLoadTopics(LoadTopics event, Emitter<TopicState> emit) async {
    emit(TopicLoading());
    try {
      final workTopics = await _repository.getWorkTopics();
      final educationTopics = await _repository.getEducationTopics();
      final travelTopics = await _repository.getTravelTopics();

      emit(TopicLoaded(
        workTopics: workTopics,
        educationTopics: educationTopics,
        travelTopics: travelTopics,
      ));
    } catch (e) {
      emit(TopicError(e.toString()));
    }
  }

  Future<void> _onLoadTopicsByCategory(
      LoadTopicsByCategory event, Emitter<TopicState> emit) async {
    try {
      emit(TopicLoading());
      final topics = await _repository.getTopicsByCategory(event.category);
      emit(TopicsLoaded(topics));
    } catch (e) {
      emit(TopicError(e.toString()));
    }
  }

  Future<void> _onLoadTopic(LoadTopic event, Emitter<TopicState> emit) async {
    try {
      emit(TopicLoading());
      final topic = await _repository.getTopic(event.id);
      emit(TopicLoaded(
        workTopics: [],
        educationTopics: [],
        travelTopics: [],
        topic: topic,
      ));
    } catch (e) {
      emit(TopicError(e.toString()));
    }
  }

  Future<void> _onMarkTopicAsCompleted(
      MarkTopicAsCompleted event, Emitter<TopicState> emit) async {
    try {
      await _repository.updateTopicCompletion(event.topicId, event.isCompleted);
      add(LoadTopics()); // Reload topics to reflect changes
    } catch (e) {
      emit(TopicError(e.toString()));
    }
  }

  Future<void> _onLoadTopicProgress(
      LoadTopicProgress event, Emitter<TopicState> emit) async {
    try {
      emit(TopicLoading());
      final progress = await _repository.getTopicProgress(event.id);
      emit(TopicProgressLoaded(progress));
    } catch (e) {
      emit(TopicError(e.toString()));
    }
  }
}
