import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../application/chat/chat_bloc.dart';
import '../../../domain/repositories/ai_repository.dart';

class TopicPracticeScreen extends StatefulWidget {
  const TopicPracticeScreen({super.key});

  @override
  State<TopicPracticeScreen> createState() => _TopicPracticeScreenState();
}

class _TopicPracticeScreenState extends State<TopicPracticeScreen> {
  final _messageController = TextEditingController();
  String _selectedTopic = 'Travel';
  String _selectedLevel = 'Intermediate';

  final List<String> _topics = [
    'Travel',
    'Technology',
    'Food and Cooking',
    'Environment',
    'Sports',
    'Entertainment',
    'Education',
    'Health',
    'Business',
    'Culture',
  ];

  final List<String> _levels = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  bool _showVocabulary = false;
  List<String> _vocabularyList = [];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _requestVocabulary(BuildContext context) {
    context.read<ChatBloc>().add(
          SendMessage(
            'Please provide 5 key vocabulary words or phrases related to $_selectedTopic that would be useful for a $_selectedLevel level English learner. Format them as a simple list.',
          ),
        );
    setState(() {
      _showVocabulary = true;
    });
  }

  void _endPractice(BuildContext context) {
    context.read<ChatBloc>().add(
          SendMessage(
            'Please evaluate my English speaking performance in this topic practice session. Focus on vocabulary usage, grammar, and fluency. Also, suggest areas for improvement.',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(
        aiRepository: context.read<AiRepository>(),
      ),
      child: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Topic Practice'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.stop_circle_outlined),
                onPressed: () => _endPractice(context),
                tooltip: 'End Practice',
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedTopic,
                            decoration: const InputDecoration(
                              labelText: 'Select Topic',
                              border: OutlineInputBorder(),
                            ),
                            items: _topics.map((topic) {
                              return DropdownMenuItem(
                                value: topic,
                                child: Text(topic),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedTopic = value;
                                  _showVocabulary = false;
                                  _vocabularyList.clear();
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedLevel,
                            decoration: const InputDecoration(
                              labelText: 'Select Level',
                              border: OutlineInputBorder(),
                            ),
                            items: _levels.map((level) {
                              return DropdownMenuItem(
                                value: level,
                                child: Text(level),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedLevel = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<ChatBloc>().add(
                              SendMessage(
                                'Let\'s practice English conversation about $_selectedTopic at a $_selectedLevel level. Please start by introducing the topic and asking me a question to begin our discussion.',
                              ),
                            );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Practice'),
                    ),
                  ],
                ),
              ),
              if (_showVocabulary && _vocabularyList.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.book_outlined,
                              color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Key Vocabulary',
                            style: TextStyle(
                              color: Colors.green.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _vocabularyList
                            .map(
                              (word) => Chip(
                                label: Text(word),
                                backgroundColor: Colors.green.shade100,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is ChatSuccess) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: message.isUser
                                  ? Colors.blue.shade100
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(message.content),
                          );
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: () {
                        // TODO: Implement speech recognition
                      },
                      tooltip: 'Voice Input',
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type your response...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        maxLines: null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.book_outlined),
                      onPressed: () => _requestVocabulary(context),
                      tooltip: 'Get Vocabulary',
                    ),
                    const SizedBox(width: 8),
                    BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        final isLoading = state is ChatLoading;
                        return FloatingActionButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_messageController.text.isNotEmpty) {
                                    context.read<ChatBloc>().add(
                                          SendMessage(_messageController.text),
                                        );
                                    _messageController.clear();
                                  }
                                },
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(Icons.send),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
