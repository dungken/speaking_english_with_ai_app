import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';
import '../../model/chunk.dart';

enum LearningStage {
  chunking,
  sentenceBuilding,
  reflexPractice,
  summary,
}

class InteractiveLearningScreen extends StatefulWidget {
  final String question;
  final String questionTranslation;
  final List<Chunk> basicChunks;
  final List<Chunk> advancedChunks;

  const InteractiveLearningScreen({
    Key? key,
    required this.question,
    required this.questionTranslation,
    required this.basicChunks,
    required this.advancedChunks,
  }) : super(key: key);

  @override
  State<InteractiveLearningScreen> createState() =>
      _InteractiveLearningScreenState();
}

class _InteractiveLearningScreenState extends State<InteractiveLearningScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  LearningStage _currentStage = LearningStage.chunking;
  int _currentChunkIndex = 0;
  bool _isChunkingStep1 = true;
  bool _isRecording = false;
  String _userAnswer = '';
  bool _showFeedback = false;
  bool _isCorrect = false;
  double _pronunciationScore = 0.0;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String audioUrl) async {
    try {
      await _audioPlayer.setAsset(audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
    });
    // TODO: Implement voice recording
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _showFeedback = true;
      // TODO: Implement voice recognition and scoring
      _pronunciationScore = 0.85; // Example score
    });
  }

  void _checkAnswer(String selectedAnswer) {
    setState(() {
      _showFeedback = true;
      _isCorrect =
          selectedAnswer == widget.basicChunks[_currentChunkIndex].phrase;
    });
  }

  void _nextStep() {
    setState(() {
      if (_currentStage == LearningStage.chunking) {
        if (_isChunkingStep1) {
          _isChunkingStep1 = false;
        } else {
          _isChunkingStep1 = true;
          if (_currentChunkIndex < widget.basicChunks.length - 1) {
            _currentChunkIndex++;
          } else {
            _currentStage = LearningStage.sentenceBuilding;
          }
        }
      } else if (_currentStage == LearningStage.sentenceBuilding) {
        _currentStage = LearningStage.reflexPractice;
      } else if (_currentStage == LearningStage.reflexPractice) {
        _currentStage = LearningStage.summary;
      }
      _showFeedback = false;
    });
  }

  void _previousStep() {
    setState(() {
      if (_currentStage == LearningStage.chunking) {
        if (!_isChunkingStep1) {
          _isChunkingStep1 = true;
        } else if (_currentChunkIndex > 0) {
          _currentChunkIndex--;
        }
      } else if (_currentStage == LearningStage.sentenceBuilding) {
        _currentStage = LearningStage.chunking;
        _currentChunkIndex = widget.basicChunks.length - 1;
        _isChunkingStep1 = false;
      } else if (_currentStage == LearningStage.reflexPractice) {
        _currentStage = LearningStage.sentenceBuilding;
      }
      _showFeedback = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Learning'),
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
            // Progress Timeline
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimelineItem(
                    'Chunking',
                    _currentStage == LearningStage.chunking,
                    _currentStage.index >= LearningStage.chunking.index,
                  ),
                  _buildTimelineConnector(_currentStage.index >=
                      LearningStage.sentenceBuilding.index),
                  _buildTimelineItem(
                    'Sentence Building',
                    _currentStage == LearningStage.sentenceBuilding,
                    _currentStage.index >= LearningStage.sentenceBuilding.index,
                  ),
                  _buildTimelineConnector(_currentStage.index >=
                      LearningStage.reflexPractice.index),
                  _buildTimelineItem(
                    'Reflex Practice',
                    _currentStage == LearningStage.reflexPractice,
                    _currentStage.index >= LearningStage.reflexPractice.index,
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildCurrentStage(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_currentStage == LearningStage.sentenceBuilding ||
                      _currentStage == LearningStage.reflexPractice)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            // TODO: Implement hint functionality
                          },
                          icon: const Icon(Icons.lightbulb_outline),
                          label: const Text('Hint'),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                        _buildMicrophoneButton(),
                      ],
                    )
                  else if (_currentStage == LearningStage.chunking &&
                      !_isChunkingStep1)
                    _buildMicrophoneButton(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (_currentStage != LearningStage.chunking ||
                          !_isChunkingStep1 ||
                          _currentChunkIndex > 0)
                        TextButton.icon(
                          onPressed: _previousStep,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back'),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: _nextStep,
                        icon: Icon(
                          _currentStage == LearningStage.summary
                              ? Icons.check
                              : Icons.arrow_forward,
                        ),
                        label: Text(
                          _currentStage == LearningStage.summary
                              ? 'Complete'
                              : 'Next',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineConnector(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isCompleted
              ? Theme.of(context).primaryColor.withOpacity(0.5)
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String label, bool isActive, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? Theme.of(context).primaryColor
                : isCompleted
                    ? Theme.of(context).primaryColor.withOpacity(0.5)
                    : Colors.grey.shade300,
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? Theme.of(context).primaryColor.withOpacity(0.3)
                    : Colors.transparent,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isCompleted
              ? const Icon(
                  Icons.check,
                  size: 18,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? Theme.of(context).primaryColor
                : isCompleted
                    ? Theme.of(context).primaryColor.withOpacity(0.7)
                    : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMicrophoneButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          _isRecording ? Icons.stop_circle : Icons.mic,
          size: 36,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: _isRecording ? _stopRecording : _startRecording,
      ),
    );
  }

  Widget _buildCurrentStage() {
    switch (_currentStage) {
      case LearningStage.chunking:
        return _buildChunkingStage();
      case LearningStage.sentenceBuilding:
        return _buildSentenceBuildingStage();
      case LearningStage.reflexPractice:
        return _buildReflexPracticeStage();
      case LearningStage.summary:
        return _buildSummaryStage();
    }
  }

  Widget _buildChunkingStage() {
    final currentChunk = widget.basicChunks[_currentChunkIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isChunkingStep1) ...[
          // Question Section
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Translate the bold phrase:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: '${widget.questionTranslation}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_showFeedback)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isCorrect
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isCorrect
                            ? Colors.green.shade200
                            : Colors.red.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isCorrect ? Icons.check_circle : Icons.error,
                          color: _isCorrect ? Colors.green : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isCorrect ? 'Correct!' : 'Incorrect. Try again.',
                          style: TextStyle(
                            color: _isCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Answer Choices Section
          Container(
            margin: const EdgeInsets.only(top: 24),
            child: Column(
              children: [
                Text(
                  'Choose the correct answer:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: _buildMultipleChoiceButtons(),
                ),
              ],
            ),
          ),
        ] else ...[
          // Pronunciation Practice Section
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Speak the phrase:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentChunk.phrase,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '/maɪ ədˈvaɪs ɪz/', // TODO: Add IPA transcription
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 18,
                              fontFamily: 'Arial',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentChunk.meaning,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 18,
                          ),
                        ),
                        if (_showFeedback) ...[
                          const SizedBox(height: 24),
                          LinearProgressIndicator(
                            value: _pronunciationScore,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Accuracy: ${(_pronunciationScore * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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
        ],
      ],
    );
  }

  Widget _buildSentenceBuildingStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Listen, speak and repeat:',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My advice is to be honest',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Translate: My advice is to be honest',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                if (_showFeedback) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isCorrect
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isCorrect ? Icons.check_circle : Icons.error,
                          color: _isCorrect ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isCorrect ? 'Correct!' : 'Incorrect. Try again.',
                          style: TextStyle(
                            color: _isCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildReflexPracticeStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Answer the image with hints:',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What is your advice for an interview?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // TODO: Add image
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                ),
                if (_showFeedback) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isCorrect
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isCorrect ? Icons.check_circle : Icons.error,
                          color: _isCorrect ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isCorrect ? 'Correct!' : 'Incorrect. Try again.',
                          style: TextStyle(
                            color: _isCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildSummaryStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You have completed:',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryItem('Chunking', widget.basicChunks.length),
                _buildSummaryItem('Sentence Building', 2),
                _buildSummaryItem('Reflex Practice', 1),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            '$title: $count exercises',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMultipleChoiceButtons() {
    final currentChunk = widget.basicChunks[_currentChunkIndex];
    return [
      _buildChoiceButton('My advices are'),
      _buildChoiceButton('My advise is'),
      _buildChoiceButton('My advice is'),
    ];
  }

  Widget _buildChoiceButton(String text) {
    return ElevatedButton(
      onPressed: () => _checkAnswer(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: _showFeedback
            ? (_isCorrect &&
                    text == widget.basicChunks[_currentChunkIndex].phrase
                ? Colors.green
                : (!_isCorrect && text == _userAnswer
                    ? Colors.red
                    : Colors.grey.shade200))
            : Colors.grey.shade200,
        foregroundColor: _showFeedback
            ? (_isCorrect &&
                    text == widget.basicChunks[_currentChunkIndex].phrase
                ? Colors.white
                : (!_isCorrect && text == _userAnswer
                    ? Colors.white
                    : Colors.black))
            : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 2,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
