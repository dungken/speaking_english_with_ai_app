import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';
import '../../model/chunk.dart';
import '../../widgets/learning_stages/chunking_stage.dart';
import '../../widgets/learning_stages/sentence_building_stage.dart';
import '../../widgets/learning_stages/reflex_practice_stage.dart';
import '../../widgets/learning_stages/summary_stage.dart';

/// Learning stages in the interactive learning process
enum LearningStage {
  chunking,
  sentenceBuilding,
  reflexPractice,
  summary,
}

class InteractiveLearningScreen extends StatefulWidget {
  static const double defaultPadding = 24.0;
  static const double smallPadding = 16.0;
  static const double tinyPadding = 8.0;
  static const double defaultBorderRadius = 20.0;
  static const double smallBorderRadius = 16.0;
  static const double defaultElevation = 3.0;
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 36.0;
  static const double defaultFontSize = 16.0;
  static const double largeFontSize = 24.0;
  static const double titleFontSize = 18.0;

  static const double scoreThresholdHigh = 0.7;
  static const double scoreThresholdMedium = 0.4;

  static const double progressBarHeight = 12.0;
  static const double timelineCircleSize = 32.0;
  static const double timelineConnectorHeight = 3.0;

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
  bool _isRecording = false;
  String _userAnswer = '';
  bool _showFeedback = false;
  double _pronunciationScore = 0.0;
  double _reactionTime = 0.0;
  DateTime? _startTime;
  List<String> _pronunciationFeedback = [];
  List<String> _grammarFeedback = [];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Plays audio from the given asset URL
  Future<void> _playAudio(String audioUrl) async {
    try {
      await _audioPlayer.setAsset(audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  /// Starts voice recording for pronunciation practice
  void _startRecording() {
    setState(() {
      _isRecording = true;
    });
    // TODO: Implement actual voice recording
  }

  /// Stops voice recording and processes the result
  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _showFeedback = true;

      // Simulate pronunciation analysis
      _pronunciationScore = 0.85;
      _updatePronunciationFeedback();
    });
  }

  void _updatePronunciationFeedback() {
    _pronunciationFeedback.clear();
    if (_pronunciationScore < 0.6) {
      _pronunciationFeedback
          .add("Work on your pronunciation of 'prefer' and 'because'");
      _pronunciationFeedback.add("Try to speak more clearly and slowly");
    } else if (_pronunciationScore < 0.8) {
      _pronunciationFeedback
          .add("Your pronunciation is good, but could be clearer");
      _pronunciationFeedback
          .add("Pay attention to word stress in longer phrases");
    } else {
      _pronunciationFeedback.add("Excellent pronunciation!");
      _pronunciationFeedback.add("Keep practicing to maintain this level");
    }
  }

  /// Checks the user's answer against the correct chunk
  void _checkAnswer(String selectedAnswer) {
    final now = DateTime.now();
    if (_startTime != null) {
      _reactionTime = now.difference(_startTime!).inMilliseconds / 1000;
    }

    setState(() {
      _showFeedback = true;
      _userAnswer = selectedAnswer;
    });
  }

  /// Moves to the next step in the learning process
  void _nextStep() {
    setState(() {
      if (_currentStage == LearningStage.chunking) {
        _handleChunkingNextStep();
      } else {
        _handleOtherStagesNextStep();
      }
      _showFeedback = false;
      if (_currentStage == LearningStage.reflexPractice && !_showFeedback) {
        _startReflexPractice();
      }
    });
  }

  /// Handles next step logic specifically for chunking stage
  void _handleChunkingNextStep() {
    if (_currentChunkIndex < widget.basicChunks.length - 1) {
      _currentChunkIndex++;
    } else {
      _currentStage = LearningStage.sentenceBuilding;
    }
  }

  /// Handles next step logic for non-chunking stages
  void _handleOtherStagesNextStep() {
    switch (_currentStage) {
      case LearningStage.sentenceBuilding:
        _currentStage = LearningStage.reflexPractice;
        _startReflexPractice();
        break;
      case LearningStage.reflexPractice:
        if (_showFeedback) {
          _currentStage = LearningStage.summary;
        } else {
          _currentChunkIndex =
              (_currentChunkIndex + 1) % widget.basicChunks.length;
          _startReflexPractice();
        }
        break;
      case LearningStage.summary:
        Navigator.of(context).pop();
        break;
      default:
        break;
    }
  }

  /// Moves to the previous step in the learning process
  void _previousStep() {
    setState(() {
      if (_currentStage == LearningStage.chunking) {
        _handleChunkingPreviousStep();
      } else {
        _handleOtherStagesPreviousStep();
      }
      _showFeedback = false;
    });
  }

  /// Handles previous step logic specifically for chunking stage
  void _handleChunkingPreviousStep() {
    if (_currentChunkIndex > 0) {
      _currentChunkIndex--;
    }
  }

  /// Handles previous step logic for non-chunking stages
  void _handleOtherStagesPreviousStep() {
    switch (_currentStage) {
      case LearningStage.sentenceBuilding:
        _currentStage = LearningStage.chunking;
        _currentChunkIndex = widget.basicChunks.length - 1;
        break;
      case LearningStage.reflexPractice:
        _currentStage = LearningStage.sentenceBuilding;
        break;
      case LearningStage.summary:
        _currentStage = LearningStage.reflexPractice;
        _currentChunkIndex = widget.basicChunks.length - 1;
        break;
      default:
        break;
    }
  }

  void _startReflexPractice() {
    setState(() {
      _startTime = DateTime.now();
      _showFeedback = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Interactive Learning'),
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: _buildBackgroundGradient(),
      child: Column(
        children: [
          _buildProgressTimeline(),
          _buildContentArea(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  BoxDecoration _buildBackgroundGradient() {
    return BoxDecoration(
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
    );
  }

  Widget _buildProgressTimeline() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        InteractiveLearningScreen.smallPadding,
        InteractiveLearningScreen.smallPadding,
        InteractiveLearningScreen.smallPadding,
        InteractiveLearningScreen.defaultPadding,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: InteractiveLearningScreen.smallPadding,
        horizontal: InteractiveLearningScreen.tinyPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
            InteractiveLearningScreen.defaultBorderRadius),
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
        children: _buildTimelineItems(),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 500));
  }

  List<Widget> _buildTimelineItems() {
    final stages = [
      ('Chunk', LearningStage.chunking),
      ('Sentence', LearningStage.sentenceBuilding),
      ('Reflex', LearningStage.reflexPractice),
    ];

    return List.generate(stages.length * 2 - 1, (index) {
      if (index.isEven) {
        final stageIndex = index ~/ 2;
        final (label, stage) = stages[stageIndex];
        return Expanded(
          flex: 1,
          child: _buildTimelineItem(
            label,
            _currentStage == stage,
            _currentStage.index >= stage.index,
          ),
        );
      } else {
        return Expanded(
          flex: 1,
          child: _buildTimelineConnector(
            _currentStage.index >= stages[index ~/ 2 + 1].$2.index,
          ),
        );
      }
    });
  }

  Widget _buildTimelineItem(String label, bool isActive, bool isCompleted) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: InteractiveLearningScreen.timelineCircleSize,
          height: InteractiveLearningScreen.timelineCircleSize,
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
                  size: 20,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(height: InteractiveLearningScreen.tinyPadding),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: InteractiveLearningScreen.defaultFontSize,
            height: 1.2,
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

  Widget _buildTimelineConnector(bool isCompleted) {
    return Container(
      height: InteractiveLearningScreen.timelineConnectorHeight,
      margin: const EdgeInsets.symmetric(
          horizontal: InteractiveLearningScreen.tinyPadding),
      decoration: BoxDecoration(
        color: isCompleted
            ? Theme.of(context).primaryColor.withOpacity(0.5)
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildContentArea() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: InteractiveLearningScreen.smallPadding),
        child: Column(
          children: [
            const SizedBox(height: InteractiveLearningScreen.tinyPadding),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _buildCurrentStage(),
            ),
            const SizedBox(height: InteractiveLearningScreen.defaultPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(InteractiveLearningScreen.defaultPadding),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_shouldShowBackButton)
            TextButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back_ios_new),
              label: const Text('Back'),
              style: _getBackButtonStyle(),
            ).animate().fadeIn(duration: const Duration(milliseconds: 300)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: _shouldShowBackButton
                    ? InteractiveLearningScreen.tinyPadding
                    : 0,
              ),
              child: _shouldShowNextButton
                  ? ElevatedButton.icon(
                      onPressed: _nextStep,
                      icon: Icon(
                        _getNextButtonIcon,
                        size: InteractiveLearningScreen.defaultIconSize,
                      ),
                      label: Text(
                        _getNextButtonText,
                        style: const TextStyle(
                          fontSize: InteractiveLearningScreen.titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: _getNextButtonStyle(),
                    )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 300))
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  bool get _shouldShowBackButton =>
      _currentStage != LearningStage.chunking || _currentChunkIndex > 0;

  ButtonStyle _getBackButtonStyle() {
    return TextButton.styleFrom(
      foregroundColor: Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(
        horizontal: InteractiveLearningScreen.defaultPadding,
        vertical: InteractiveLearningScreen.smallPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(InteractiveLearningScreen.smallBorderRadius),
        side: BorderSide(
          color: Theme.of(context).primaryColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }

  ButtonStyle _getNextButtonStyle() {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(
        horizontal: InteractiveLearningScreen.defaultPadding,
        vertical: InteractiveLearningScreen.defaultPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(InteractiveLearningScreen.smallBorderRadius),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: InteractiveLearningScreen.defaultElevation,
    );
  }

  Widget _buildCurrentStage() {
    switch (_currentStage) {
      case LearningStage.chunking:
        return ChunkingStage(
          questionTranslation: widget.questionTranslation,
          currentChunk: widget.basicChunks[_currentChunkIndex],
          userAnswer: _userAnswer,
          showFeedback: _showFeedback,
          onAnswerSelected: _checkAnswer,
          onPlayAudio: () => _playAudio('assets/audio/chunk.mp3'),
          options: _getOptionsForCurrentChunk(),
        );
      case LearningStage.sentenceBuilding:
        return SentenceBuildingStage(
          sentence: widget.question,
          translation: widget.questionTranslation,
          isRecording: _isRecording,
          showFeedback: _showFeedback,
          pronunciationScore: _pronunciationScore,
          onPlayAudio: () => _playAudio('assets/audio/sentence.mp3'),
          onStartRecording: _startRecording,
          onStopRecording: _stopRecording,
        );
      case LearningStage.reflexPractice:
        return ReflexPracticeStage(
          sentence: widget.question,
          translation: widget.questionTranslation,
          chunks: widget.basicChunks.map((chunk) => chunk.phrase).toList(),
          showFeedback: _showFeedback,
          reactionTime: _reactionTime,
          onAnswerSelected: (answer) {
            if (!_showFeedback) {
              _checkAnswer(answer);
            }
          },
          onPlayAudio: () => _playAudio('assets/audio/sentence.mp3'),
          onStartRecording: _startRecording,
          onStopRecording: _stopRecording,
          isRecording: _isRecording,
        );
      case LearningStage.summary:
        return SummaryStage(
          readingScore: _pronunciationScore,
          conversationScore: _getReactionScore(),
          pronunciationFeedback: _pronunciationFeedback,
          improvementPoints: _grammarFeedback,
        );
    }
  }

  double _getReactionScore() {
    if (_reactionTime <= 1.0) return 1.0;
    if (_reactionTime <= 2.0) return 0.66;
    if (_reactionTime <= 3.0) return 0.33;
    return 0.0;
  }

  bool get _shouldShowNextButton {
    if (_currentStage == LearningStage.reflexPractice && !_showFeedback) {
      return false;
    }
    return true;
  }

  String get _getNextButtonText {
    switch (_currentStage) {
      case LearningStage.summary:
        return 'Complete';
      case LearningStage.reflexPractice:
        if (_showFeedback) {
          return _currentChunkIndex == widget.basicChunks.length - 1
              ? 'View Summary'
              : 'Next Word';
        }
        return 'Next';
      default:
        return 'Next';
    }
  }

  IconData get _getNextButtonIcon {
    switch (_currentStage) {
      case LearningStage.summary:
        return Icons.check_circle_outline;
      default:
        return Icons.arrow_forward_ios;
    }
  }

  List<String> _getOptionsForCurrentChunk() {
    final currentChunk = widget.basicChunks[_currentChunkIndex];
    final correctAnswer = currentChunk.phrase;

    // Get wrong options from other chunks, excluding the current one
    final wrongOptions = widget.basicChunks
        .where((chunk) => chunk != currentChunk)
        .map((chunk) => chunk.phrase)
        .take(2)
        .toList();

    // Add the correct answer and shuffle
    final options = [...wrongOptions, correctAnswer];
    options.shuffle();

    return options;
  }
}
