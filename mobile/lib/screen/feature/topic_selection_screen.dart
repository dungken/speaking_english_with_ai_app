import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../helper/global.dart';
import '../../model/topic.dart';
import '../../widgets/topic_card.dart';
import 'subtopics_screen.dart';

class TopicSelectionScreen extends StatefulWidget {
  const TopicSelectionScreen({Key? key}) : super(key: key);

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> {
  Topic? _selectedTopic;
  final List<Topic> _workTopics = [
    Topic(
      title: 'Sharing work opinions',
      description: 'Learn to express your thoughts about work',
      difficulty: TopicDifficulty.easy,
      lessonCount: '14 lessons',
      subtopics: [
        Topic(
          title: 'Chunking Practice',
          description: 'Practice breaking down complex ideas',
          difficulty: TopicDifficulty.easy,
          subtopics: [
            Topic(
              title: 'First Set of Questions',
              description: 'Practice expressing preferences and experiences',
              difficulty: TopicDifficulty.easy,
              subtopics: [
                Topic(
                  title: 'Studying or working, which one do you like more?',
                  description: 'Practice expressing preferences',
                  difficulty: TopicDifficulty.easy,
                ),
                Topic(
                  title: 'Is your job related to your major?',
                  description: 'Discuss career choices',
                  difficulty: TopicDifficulty.easy,
                ),
                Topic(
                  title: 'Have you ever missed a deadline?',
                  description: 'Talk about time management',
                  difficulty: TopicDifficulty.easy,
                ),
              ],
            ),
            Topic(
              title: 'First Review Lesson',
              description: 'Consolidate your learning from the first set',
              difficulty: TopicDifficulty.easy,
              isReview: true,
            ),
            Topic(
              title: 'Second Set of Questions',
              description: 'Practice more complex work-related topics',
              difficulty: TopicDifficulty.easy,
              subtopics: [
                Topic(
                  title: 'How do you manage your time?',
                  description: 'Discuss time management strategies',
                  difficulty: TopicDifficulty.easy,
                ),
                Topic(
                  title: 'What would your perfect working environment be like?',
                  description: 'Describe ideal work conditions',
                  difficulty: TopicDifficulty.easy,
                ),
                Topic(
                  title: 'What advice would you give a newbie?',
                  description: 'Share professional guidance',
                  difficulty: TopicDifficulty.easy,
                ),
              ],
            ),
            Topic(
              title: 'Second Review Lesson',
              description: 'Consolidate your learning from the second set',
              difficulty: TopicDifficulty.easy,
              isReview: true,
            ),
          ],
        ),
        Topic(
          title: 'Roleplay Practice',
          description: 'Practice real-world scenarios',
          difficulty: TopicDifficulty.medium,
          subtopics: [
            Topic(
              title: 'Giving job advice to a new intern',
              description: 'Practice with a Westerner',
              difficulty: TopicDifficulty.medium,
            ),
            Topic(
              title: 'The CEO\'s son',
              description: 'Practice with Onion',
              difficulty: TopicDifficulty.medium,
            ),
            Topic(
              title: 'Talking with a foreign guest about work',
              description: 'Practice with a Westerner',
              difficulty: TopicDifficulty.medium,
            ),
          ],
        ),
        Topic(
          title: 'Advanced Expansion',
          description: 'Expand your ideas and vocabulary',
          difficulty: TopicDifficulty.hard,
          subtopics: [
            Topic(
              title: 'Have you ever missed a deadline?',
              description: 'Expanding ideas',
              difficulty: TopicDifficulty.hard,
            ),
            Topic(
              title: 'What would your perfect working environment be like?',
              description: 'Expanding ideas',
              difficulty: TopicDifficulty.hard,
            ),
            Topic(
              title: 'What advice would you give a newbie?',
              description: 'Expanding ideas',
              difficulty: TopicDifficulty.hard,
            ),
          ],
        ),
      ],
    ),
    Topic(
      title: 'Sharing internship experience',
      description: 'Share your internship stories',
      difficulty: TopicDifficulty.easy,
      lessonCount: '10 lessons',
    ),
    Topic(
      title: 'Scheduling with foreign clients',
      description: 'Learn to schedule meetings effectively',
      difficulty: TopicDifficulty.medium,
    ),
    Topic(
      title: 'Requesting leave from your boss',
      description: 'Practice professional leave requests',
      difficulty: TopicDifficulty.hard,
    ),
  ];

  final List<Topic> _educationTopics = [
    Topic(
      title: 'Talking about learning English',
      description: 'Discuss your English learning journey',
      difficulty: TopicDifficulty.easy,
    ),
    Topic(
      title: 'Talking about exam preparation',
      description: 'Share exam preparation tips',
      difficulty: TopicDifficulty.easy,
    ),
    Topic(
      title: 'Discussing extra study needs',
      description: 'Talk about additional learning requirements',
      difficulty: TopicDifficulty.medium,
    ),
    Topic(
      title: 'Talking about your major',
      description: 'Explain your field of study',
      difficulty: TopicDifficulty.hard,
    ),
  ];

  final List<Topic> _travelTopics = [
    Topic(
      title: 'Giving directions to foreigners',
      description: 'Help tourists find their way',
      difficulty: TopicDifficulty.easy,
    ),
    Topic(
      title: 'Planning a trip',
      description: 'Organize travel plans',
      difficulty: TopicDifficulty.hard,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
        child: Row(
          children: [
            // Left side - Categories and main topics
            Expanded(
              flex: 1,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: mq.width * .04,
                  vertical: mq.height * .015,
                ),
                children: [
                  _buildCategory(context, 'Work Topics', _workTopics),
                  _buildCategory(context, 'Education Topics', _educationTopics),
                  _buildCategory(
                      context, 'Travel Experience Topics', _travelTopics),
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
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                      if (_selectedTopic!.subtopics != null) ...[
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _selectedTopic!.subtopics!.length,
                            itemBuilder: (context, index) {
                              final subtopic =
                                  _selectedTopic!.subtopics![index];
                              return TopicCard(
                                topic: subtopic,
                                onStartPractice: () {
                                  // TODO: Implement start practice
                                },
                                onViewLesson: () {
                                  // TODO: Implement view lesson
                                },
                                onMarkAsDone: () {
                                  // TODO: Implement mark as done
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
                // TODO: Implement start practice
              },
              onViewLesson: () {
                // TODO: Implement view lesson
              },
              onMarkAsDone: () {
                // TODO: Implement mark as done
              },
              onTap: () {
                if (topic.subtopics != null) {
                  Get.to(() => SubtopicsScreen(
                        topic: topic,
                      ));
                }
              },
            )),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }
}
