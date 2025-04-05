import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../model/topic.dart';
import '../../model/chunk.dart';
import '../../widgets/topic_card.dart';
import 'interactive_learning_screen.dart';

class SubtopicsScreen extends StatelessWidget {
  final Topic topic;

  const SubtopicsScreen({
    Key? key,
    required this.topic,
  }) : super(key: key);

  void _navigateToInteractiveLearning(BuildContext context, Topic subtopic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InteractiveLearningScreen(
          question: subtopic.title,
          questionTranslation: subtopic.description,
          basicChunks: [
            Chunk(
              phrase: 'I prefer ___',
              meaning: 'Tôi thích ___ hơn',
              audioUrl: 'assets/audio/i_prefer.mp3',
            ),
            Chunk(
              phrase: 'studying',
              meaning: 'học tập',
              audioUrl: 'assets/audio/studying.mp3',
            ),
            Chunk(
              phrase: 'working',
              meaning: 'làm việc',
              audioUrl: 'assets/audio/working.mp3',
            ),
            Chunk(
              phrase: 'because ___',
              meaning: 'bởi vì ___',
              audioUrl: 'assets/audio/because.mp3',
            ),
          ],
          advancedChunks: [
            Chunk(
              phrase: 'I prefer studying because',
              meaning: 'Tôi thích học tập hơn bởi vì',
              audioUrl: 'assets/audio/i_prefer_studying.mp3',
            ),
            Chunk(
              phrase: 'I prefer working because',
              meaning: 'Tôi thích làm việc hơn bởi vì',
              audioUrl: 'assets/audio/i_prefer_working.mp3',
            ),
          ],
        ),
      ),
    );
  }

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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    topic.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (topic.subtopics != null)
              Column(
                children: topic.subtopics!
                    .map((subtopic) => TopicCard(
                          topic: subtopic,
                          onStartPractice: () {
                            if (subtopic.subtopics == null) {
                              _navigateToInteractiveLearning(context, subtopic);
                            }
                          },
                          onViewLesson: () {
                            if (subtopic.subtopics == null) {
                              _navigateToInteractiveLearning(context, subtopic);
                            }
                          },
                          onMarkAsDone: () {
                            // TODO: Implement mark as done
                          },
                          onTap: () {
                            if (subtopic.subtopics != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SubtopicsScreen(
                                    topic: subtopic,
                                  ),
                                ),
                              );
                            } else {
                              _navigateToInteractiveLearning(context, subtopic);
                            }
                          },
                        ))
                    .toList()
                    .animate(interval: 100.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.1, end: 0),
              ),
          ],
        ),
      ),
    );
  }
}
