import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';
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

class _ChunkingPracticeScreenState extends State<ChunkingPracticeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _learnedChunks = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLearning = false;
  int _currentChunkIndex = 0;
  List<Chunk> _currentChunks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentChunks = widget.basicChunks;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onChunkLearned(Chunk chunk) {
    setState(() {
      _learnedChunks++;
    });
  }

  Future<void> _playAudio(String audioUrl) async {
    try {
      await _audioPlayer.setAsset(audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  void _startLearning() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InteractiveLearningScreen(
          question: widget.question,
          questionTranslation: widget.questionTranslation,
          basicChunks: widget.basicChunks,
          advancedChunks: widget.advancedChunks,
        ),
      ),
    );
  }

  void _nextChunk() {
    setState(() {
      if (_currentChunkIndex < _currentChunks.length - 1) {
        _currentChunkIndex++;
      } else {
        _isLearning = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chunking Practice'),
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
        child: Column(
          children: [
            // Question Header
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.question,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.questionTranslation,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Progress Indicator
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _learnedChunks /
                        (widget.basicChunks.length +
                            widget.advancedChunks.length),
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_learnedChunks/${widget.basicChunks.length + widget.advancedChunks.length} chunks learned',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_border,
                            size: 18,
                            color: _tabController.index == 0
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Basic',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _tabController.index == 0
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            size: 18,
                            color: _tabController.index == 1
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Advanced',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _tabController.index == 1
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                dividerColor: Colors.transparent,
                dividerHeight: 0,
                onTap: (index) {
                  setState(() {
                    _currentChunks =
                        index == 0 ? widget.basicChunks : widget.advancedChunks;
                  });
                },
              ),
            ),

            // Tab Content
            Expanded(
              child: _isLearning
                  ? _buildLearningView()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildChunkList(widget.basicChunks),
                        _buildChunkList(widget.advancedChunks),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isLearning ? _nextChunk : _startLearning,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              _isLearning ? 'Next' : 'Start Learning',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLearningView() {
    final currentChunk = _currentChunks[_currentChunkIndex];
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Theme.of(context).primaryColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_circle_outline, size: 48),
                  color: Theme.of(context).primaryColor,
                  onPressed: () => _playAudio(currentChunk.audioUrl),
                ),
                const SizedBox(height: 24),
                Text(
                  currentChunk.phrase,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  currentChunk.meaning,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChunkList(List<Chunk> chunks) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chunks.length,
      itemBuilder: (context, index) {
        final chunk = chunks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _isLearning = true;
                _currentChunkIndex = index;
                _currentChunks = chunks;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.play_circle_outline),
                      color: Theme.of(context).primaryColor,
                      onPressed: () => _playAudio(chunk.audioUrl),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chunk.phrase,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chunk.meaning,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (chunk.isLearned)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1, end: 0);
      },
    );
  }
}
