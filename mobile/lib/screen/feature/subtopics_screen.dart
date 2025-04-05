import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../model/topic.dart';
import '../../model/chunk.dart';
import '../../widget/topic_card.dart';
import 'chunking_practice_screen.dart';

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
                            // TODO: Implement start practice
                          },
                          onViewLesson: () {
                            if (subtopic.subtopics == null) {
                              // This is a question, navigate to chunking practice
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChunkingPracticeScreen(
                                    question: subtopic.title,
                                    questionTranslation: subtopic.description,
                                    basicChunks: [
                                      Chunk(
                                        phrase: 'I have ___',
                                        meaning: 'Tôi đã ___',
                                        audioUrl: 'assets/audio/i_have.mp3',
                                      ),
                                      Chunk(
                                        phrase: 'I have never ___',
                                        meaning: 'Tôi chưa bao giờ ___',
                                        audioUrl:
                                            'assets/audio/i_have_never.mp3',
                                      ),
                                      Chunk(
                                        phrase: 'Missed a deadline',
                                        meaning: 'Trễ deadline',
                                        audioUrl:
                                            'assets/audio/missed_deadline.mp3',
                                      ),
                                      Chunk(
                                        phrase: 'Talked to my boss',
                                        meaning: 'Nói chuyện với sếp',
                                        audioUrl:
                                            'assets/audio/talked_boss.mp3',
                                      ),
                                      Chunk(
                                        phrase: 'Been late for work',
                                        meaning: 'Đi làm muộn',
                                        audioUrl: 'assets/audio/late_work.mp3',
                                      ),
                                    ],
                                    advancedChunks: [
                                      Chunk(
                                        phrase: 'miss a deadline',
                                        meaning: 'Trễ deadline',
                                        audioUrl:
                                            'assets/audio/miss_deadline.mp3',
                                      ),
                                      Chunk(
                                        phrase: 'finish the task on time',
                                        meaning:
                                            'Hoàn thành công việc đúng hạn',
                                        audioUrl:
                                            'assets/audio/finish_task.mp3',
                                      ),
                                    ],
                                  ),
                                ),
                              );
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
