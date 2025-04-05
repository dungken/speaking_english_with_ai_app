import 'package:flutter/material.dart';
import '../../model/chunk.dart';
import 'interactive_learning_screen.dart';

class ChunkingPracticeScreen extends StatefulWidget {
  final String question;
  final String questionTranslation;
  final List<Chunk> basicChunks;
  final List<Chunk> advancedChunks;

  const ChunkingPracticeScreen({
    Key? key,
    required this.question,
    required this.questionTranslation,
    required this.basicChunks,
    required this.advancedChunks,
  }) : super(key: key);

  @override
  State<ChunkingPracticeScreen> createState() => _ChunkingPracticeScreenState();
}

class _ChunkingPracticeScreenState extends State<ChunkingPracticeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chunking Practice'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Practice breaking down complex ideas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              const SizedBox(height: 24),
              _buildLessonCard(
                context,
                title: 'First Set of Questions',
                subtitle: 'Practice expressing preferences and experiences',
                difficulty: 'Easy',
                isReview: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InteractiveLearningScreen(
                        question: "What's your favorite food?",
                        questionTranslation: "Món ăn yêu thích của bạn là gì?",
                        basicChunks: [], // Add your chunks here
                        advancedChunks: [], // Add your chunks here
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildLessonCard(
                context,
                title: 'First Review Lesson',
                subtitle: 'Consolidate your learning from the first set',
                difficulty: 'Easy',
                isReview: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InteractiveLearningScreen(
                        question: "What's your favorite food?",
                        questionTranslation: "Món ăn yêu thích của bạn là gì?",
                        basicChunks: [], // Add your chunks here
                        advancedChunks: [], // Add your chunks here
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildLessonCard(
                context,
                title: 'Second Set of Questions',
                subtitle: 'Practice more complex work-related topics',
                difficulty: 'Easy',
                isReview: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InteractiveLearningScreen(
                        question: "What are your career goals?",
                        questionTranslation:
                            "Mục tiêu nghề nghiệp của bạn là gì?",
                        basicChunks: [], // Add your chunks here
                        advancedChunks: [], // Add your chunks here
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildLessonCard(
                context,
                title: 'Second Review Lesson',
                subtitle: 'Consolidate your learning from the second set',
                difficulty: 'Easy',
                isReview: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InteractiveLearningScreen(
                        question: "What are your career goals?",
                        questionTranslation:
                            "Mục tiêu nghề nghiệp của bạn là gì?",
                        basicChunks: [], // Add your chunks here
                        advancedChunks: [], // Add your chunks here
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String difficulty,
    required bool isReview,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    difficulty,
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
