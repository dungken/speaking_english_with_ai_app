import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/topic/topic_bloc.dart';
import '../../../domain/models/topic.dart';
import '../../../domain/repositories/topic_repository.dart';

class InteractiveLearningScreen extends StatefulWidget {
  final String topicId;

  const InteractiveLearningScreen({
    super.key,
    required this.topicId,
  });

  @override
  State<InteractiveLearningScreen> createState() =>
      _InteractiveLearningScreenState();
}

class _InteractiveLearningScreenState extends State<InteractiveLearningScreen> {
  int _currentStep = 0;
  final List<String> _steps = [
    'Introduction',
    'Vocabulary',
    'Grammar',
    'Practice',
    'Quiz',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TopicBloc(
        repository: context.read<TopicRepository>(),
      )..add(LoadTopic(widget.topicId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Interactive Learning'),
        ),
        body: BlocBuilder<TopicBloc, TopicState>(
          builder: (context, state) {
            if (state is TopicLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TopicLoaded && state.topic != null) {
              return _buildLearningContent(context, state.topic!);
            } else if (state is TopicError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<TopicBloc>()
                            .add(LoadTopic(widget.topicId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('No content available'));
          },
        ),
      ),
    );
  }

  Widget _buildLearningContent(BuildContext context, Topic topic) {
    return Stepper(
      currentStep: _currentStep,
      onStepContinue: () {
        if (_currentStep < _steps.length - 1) {
          setState(() {
            _currentStep++;
          });
        }
      },
      onStepCancel: () {
        if (_currentStep > 0) {
          setState(() {
            _currentStep--;
          });
        }
      },
      steps: [
        Step(
          title: const Text('Introduction'),
          content: _buildIntroductionContent(topic),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: const Text('Vocabulary'),
          content: _buildVocabularyContent(topic),
          isActive: _currentStep >= 1,
        ),
        Step(
          title: const Text('Grammar'),
          content: _buildGrammarContent(topic),
          isActive: _currentStep >= 2,
        ),
        Step(
          title: const Text('Practice'),
          content: _buildPracticeContent(topic),
          isActive: _currentStep >= 3,
        ),
        Step(
          title: const Text('Quiz'),
          content: _buildQuizContent(topic),
          isActive: _currentStep >= 4,
        ),
      ],
    );
  }

  Widget _buildIntroductionContent(Topic topic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          topic.title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Text(
          topic.description,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        const Text(
          'Learning Objectives:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text('• Understand key concepts and terminology'),
        const Text('• Learn essential vocabulary'),
        const Text('• Master grammar rules'),
        const Text('• Practice through interactive exercises'),
        const Text('• Test your knowledge with a quiz'),
      ],
    );
  }

  Widget _buildVocabularyContent(Topic topic) {
    // TODO: Implement vocabulary content
    return const Center(
      child: Text('Vocabulary content coming soon'),
    );
  }

  Widget _buildGrammarContent(Topic topic) {
    // TODO: Implement grammar content
    return const Center(
      child: Text('Grammar content coming soon'),
    );
  }

  Widget _buildPracticeContent(Topic topic) {
    // TODO: Implement practice content
    return const Center(
      child: Text('Practice content coming soon'),
    );
  }

  Widget _buildQuizContent(Topic topic) {
    // TODO: Implement quiz content
    return const Center(
      child: Text('Quiz content coming soon'),
    );
  }
}
