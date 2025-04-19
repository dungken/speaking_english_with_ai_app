import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme_provider.dart';
import '../providers/practice_mistakes_provider.dart';
import '../widgets/prompt_stage_widget.dart';
import '../widgets/recording_stage_widget.dart';
import '../widgets/feedback_stage_widget.dart';
import '../widgets/practice_stage_widget.dart';
import '../widgets/complete_stage_widget.dart';

/// Screen for practicing common language mistakes
/// Provides a multi-stage interactive experience for users to improve their expression
class PracticeMistakesScreen extends StatelessWidget {
  const PracticeMistakesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PracticeMistakesProvider(),
      child: const _PracticeMistakesScreenContent(),
    );
  }
}

class _PracticeMistakesScreenContent extends StatelessWidget {
  const _PracticeMistakesScreenContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PracticeMistakesProvider>(context);
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: _buildAppBar(isDarkMode, provider),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: _buildContent(isDarkMode, provider),
        ),
      ),
    );
  }

  /// Builds the app bar with title and progress indicator
  PreferredSizeWidget _buildAppBar(bool isDarkMode, PracticeMistakesProvider provider) {
    return AppBar(
      title: const Text('Improve Your Expression'),
      elevation: 0,
      backgroundColor: isDarkMode ? Colors.blue[900] : Colors.blue[600],
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.blue[800] : Colors.blue[500],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Practice ${provider.currentItemIndex + 1}/${provider.totalItems}',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  /// Builds the appropriate content based on the current stage
  Widget _buildContent(bool isDarkMode, PracticeMistakesProvider provider) {
    switch (provider.currentStage) {
      case PracticeStage.prompt:
        return PromptStageWidget(
          practiceItem: provider.currentItem,
          isDarkMode: isDarkMode,
          onRecordTap: provider.handleRecord,
        );
      case PracticeStage.recording:
        return RecordingStageWidget(
          practiceItem: provider.currentItem,
          isDarkMode: isDarkMode,
          recordingState: provider.recordingStateString,
          onRecordTap: provider.handleRecord,
          onRecordAgain: provider.resetRecording,
          onShowFeedback: provider.showFeedback,
        );
      case PracticeStage.feedback:
        return FeedbackStageWidget(
          practiceItem: provider.currentItem,
          isDarkMode: isDarkMode,
          onPracticeCorrect: provider.practiceCorrect,
        );
      case PracticeStage.practice:
        return PracticeStageWidget(
          practiceItem: provider.currentItem,
          isDarkMode: isDarkMode,
          recordingState: provider.recordingStateString,
          onRecordTap: provider.handleRecord,
          onRecordAgain: provider.resetRecording,
          onComplete: provider.complete,
        );
      case PracticeStage.complete:
        return CompleteStageWidget(
          practiceItem: provider.currentItem,
          isDarkMode: isDarkMode,
          onNext: provider.next,
        );
    }
  }
}
