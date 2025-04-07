import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/topic/topic_bloc.dart';
import '../../../domain/models/topic.dart';
import '../../widgets/topic_card.dart';

class SubtopicsScreen extends StatelessWidget {
  final Topic topic;

  const SubtopicsScreen({
    Key? key,
    required this.topic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(topic.title),
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (topic.description.isNotEmpty) ...[
              Text(
                topic.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
            ],
            ...topic.subtopics.map((subtopic) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TopicCard(
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
                    onTap: subtopic.subtopics.isNotEmpty
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SubtopicsScreen(
                                  topic: subtopic,
                                ),
                              ),
                            );
                          }
                        : null,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
