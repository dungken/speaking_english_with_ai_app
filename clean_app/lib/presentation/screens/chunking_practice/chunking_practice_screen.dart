import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../application/topic/topic_bloc.dart';
import '../../../domain/models/topic.dart';
import '../../../domain/repositories/topic_repository.dart';

class ChunkingPracticeScreen extends StatefulWidget {
  final String topicId;

  const ChunkingPracticeScreen({
    super.key,
    required this.topicId,
  });

  @override
  State<ChunkingPracticeScreen> createState() => _ChunkingPracticeScreenState();
}

class _ChunkingPracticeScreenState extends State<ChunkingPracticeScreen> {
  final TextEditingController _textController = TextEditingController();
  List<String> _chunks = [];
  bool _isCorrect = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TopicBloc(
        repository: context.read<TopicRepository>(),
      )..add(LoadTopic(widget.topicId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chunking Practice'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: BlocBuilder<TopicBloc, TopicState>(
          builder: (context, state) {
            if (state is TopicLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TopicLoaded && state.topic != null) {
              return _buildPracticeContent(context, state.topic!);
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

  Widget _buildPracticeContent(BuildContext context, Topic topic) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Practice Chunking',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Break down the following sentence into meaningful chunks:',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Example Sentence:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The quick brown fox jumps over the lazy dog.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Correct Chunks:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChunkChip('The quick brown fox'),
                      _buildChunkChip('jumps over'),
                      _buildChunkChip('the lazy dog'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Enter your chunks (separated by commas)',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _chunks = value.split(',').map((e) => e.trim()).toList();
                _isCorrect = _checkChunks(_chunks);
              });
            },
          ),
          const SizedBox(height: 16),
          if (_chunks.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Chunks:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _chunks.map((chunk) => _buildChunkChip(chunk)).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle : Icons.error,
                      color: _isCorrect ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isCorrect
                          ? 'Correct! Your chunks are well-formed.'
                          : 'Try again. Make sure your chunks are meaningful.',
                      style: TextStyle(
                        color: _isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildChunkChip(String text) {
    return Chip(
      label: Text(text),
      backgroundColor: Colors.blue.withOpacity(0.1),
    );
  }

  bool _checkChunks(List<String> chunks) {
    // TODO: Implement proper chunk checking logic
    return chunks.length == 3;
  }
}
