import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/topic/topic_bloc.dart';
import '../../../domain/models/topic.dart';
import '../../../domain/repositories/topic_repository.dart';
import '../../widgets/topic_card.dart';
import '../subtopics/subtopics_screen.dart';

class TopicSelectionScreen extends StatefulWidget {
  const TopicSelectionScreen({Key? key}) : super(key: key);

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> {
  Topic? _selectedTopic;

  @override
  void initState() {
    super.initState();
    context.read<TopicBloc>().add(LoadTopics());
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Topic to Study'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue.shade900.withOpacity(0.3)
                  : Colors.blue.shade50,
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.purple.shade900.withOpacity(0.3)
                  : Colors.purple.shade50,
            ],
          ),
        ),
        child: BlocBuilder<TopicBloc, TopicState>(
          builder: (context, state) {
            if (state is TopicLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TopicError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load topics',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        context.read<TopicBloc>().add(LoadTopics());
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            if (state is TopicLoaded) {
              return Row(
                children: [
                  // Left side - Categories and main topics
                  Expanded(
                    flex: 1,
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: mq.size.width * .04,
                        vertical: mq.size.height * .015,
                      ),
                      children: [
                        _buildCategory(
                            context, 'Work Topics', state.workTopics),
                        _buildCategory(
                            context, 'Education Topics', state.educationTopics),
                        _buildCategory(context, 'Travel Experience Topics',
                            state.travelTopics),
                      ],
                    ),
                  ),
                  // Right side - Subtopic details
                  if (_selectedTopic != null)
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedTopic!.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (_selectedTopic!.description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                _selectedTopic!.description,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                            if (_selectedTopic!.subtopics.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _selectedTopic!.subtopics.length,
                                  itemBuilder: (context, index) {
                                    final subtopic =
                                        _selectedTopic!.subtopics[index];
                                    return TopicCard(
                                      topic: subtopic,
                                      onStartPractice: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/topic-practice',
                                          arguments: subtopic,
                                        );
                                      },
                                      onViewLesson: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/lesson-view',
                                          arguments: subtopic,
                                        );
                                      },
                                      onMarkAsDone: () {
                                        context.read<TopicBloc>().add(
                                              MarkTopicAsCompleted(
                                                subtopic.id,
                                                !subtopic.isCompleted,
                                              ),
                                            );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              );
            }

            return const Center(child: Text('No topics available'));
          },
        ),
      ),
    );
  }

  Widget _buildCategory(
      BuildContext context, String title, List<Topic> topics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...topics.map((topic) => TopicCard(
              topic: topic,
              onStartPractice: () {
                Navigator.pushNamed(
                  context,
                  '/topic-practice',
                  arguments: topic,
                );
              },
              onViewLesson: () {
                Navigator.pushNamed(
                  context,
                  '/lesson-view',
                  arguments: topic,
                );
              },
              onMarkAsDone: () {
                context.read<TopicBloc>().add(
                      MarkTopicAsCompleted(
                        topic.id,
                        !topic.isCompleted,
                      ),
                    );
              },
              onTap: () {
                if (topic.subtopics.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubtopicsScreen(
                        topic: topic,
                      ),
                    ),
                  );
                }
                setState(() {
                  _selectedTopic = topic;
                });
              },
            )),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }
}
