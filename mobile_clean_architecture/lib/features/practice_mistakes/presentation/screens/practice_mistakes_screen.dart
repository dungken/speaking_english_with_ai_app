import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';

class PracticeMistakesScreen extends StatefulWidget {
  const PracticeMistakesScreen({super.key});

  @override
  State<PracticeMistakesScreen> createState() => _PracticeMistakesScreenState();
}

class _PracticeMistakesScreenState extends State<PracticeMistakesScreen> {
  String _stage =
      'prompt'; // 'prompt', 'recording', 'feedback', 'practice', 'complete'
  String _recordingState = 'ready'; // 'ready', 'recording', 'recorded'

  // Mock data - in real app this would come from user's mistake history
  final Map<String, dynamic> _practiceItem = {
    'situationPrompt':
        "Explain that you couldn't attend a meeting yesterday because you were sick",
    'targetGrammar': "past tense + excuse",
    'commonMistake': "I no can join the meeting yesterday because I am sick",
    'betterExpression':
        "I couldn't attend the meeting yesterday because I was sick",
    'mistakeDetails': [
      {
        'type': "grammar",
        'issue': "Incorrect negative structure",
        'example': "I no can join"
      },
      {
        'type': "word choice",
        'issue': "More formal alternatives",
        'example': "'attend' is better than 'join' for meetings"
      },
      {
        'type': "tense",
        'issue': "Past tense needed",
        'example': "'was sick' instead of 'am sick'"
      }
    ],
    'alternatives': [
      "I was unable to join the meeting yesterday as I was feeling unwell",
      "I had to miss yesterday's meeting because I was sick",
      "I couldn't make it to the meeting yesterday due to illness"
    ]
  };

  void _handleRecord() {
    if (_stage == 'prompt') {
      setState(() {
        _stage = 'recording';
        _recordingState = 'recording';
      });
    } else if (_recordingState == 'ready') {
      setState(() {
        _recordingState = 'recording';
      });
    } else if (_recordingState == 'recording') {
      setState(() {
        _recordingState = 'recorded';
      });
    }
  }

  void _handleShowFeedback() {
    setState(() {
      _stage = 'feedback';
    });
  }

  void _handlePracticeCorrect() {
    setState(() {
      _stage = 'practice';
      _recordingState = 'ready';
    });
  }

  void _handleComplete() {
    setState(() {
      _stage = 'complete';
    });
  }

  void _handleNext() {
    // In a real app, this would load the next practice item
    setState(() {
      _stage = 'prompt';
      _recordingState = 'ready';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
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
            child: const Text(
              'Practice 3/8',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: _buildContent(isDarkMode),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    switch (_stage) {
      case 'prompt':
        return _buildPromptStage(isDarkMode);
      case 'recording':
        return _buildRecordingStage(isDarkMode);
      case 'feedback':
        return _buildFeedbackStage(isDarkMode);
      case 'practice':
        return _buildPracticeStage(isDarkMode);
      case 'complete':
        return _buildCompleteStage(isDarkMode);
      default:
        return _buildPromptStage(isDarkMode);
    }
  }

  Widget _buildPromptStage(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCard(
          isDarkMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Express This Idea',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.blue[800] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.blue[700]!.withAlpha(255)
                        : Colors.blue[100]!.withAlpha(255),
                  ),
                ),
                child: Text(
                  _practiceItem['situationPrompt'],
                  style: TextStyle(
                    color: isDarkMode ? Colors.blue[100] : Colors.blue[700],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.flash_on,
                    size: 16,
                    color: Colors.amber[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Based on mistakes from your conversations',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          isDarkMode,
          child: Column(
            children: [
              Text(
                'Tap to record your response',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _handleRecord,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.blue[800] : Colors.blue[600],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          isDarkMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    size: 16,
                    color: Colors.amber[500],
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'What to Watch For',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Pay attention to using the correct verb tense when talking about past events.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This is an area you\'ve struggled with before',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingStage(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCard(
          isDarkMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Express This Idea',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.blue[800] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.blue[700]!.withAlpha(255)
                        : Colors.blue[100]!.withAlpha(255),
                  ),
                ),
                child: Text(
                  _practiceItem['situationPrompt'],
                  style: TextStyle(
                    color: isDarkMode ? Colors.blue[100] : Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          isDarkMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Response',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (_recordingState == 'recording')
                Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.red[900] : Colors.red[100],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.red[500],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Recording...',
                      style: TextStyle(
                        color: Colors.red[500],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to stop',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _handleRecord,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.red[500],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.stop,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.play_arrow,
                          size: 16,
                          color:
                              isDarkMode ? Colors.blue[300] : Colors.blue[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[700]!.withAlpha(255)
                                  : Colors.grey[200]!.withAlpha(255),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.75,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.blue[600]
                                      : Colors.blue[500],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '0:04',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.grey[700]!.withAlpha(255)
                              : Colors.grey[200]!.withAlpha(255),
                        ),
                      ),
                      child: Text(
                        _practiceItem['commonMistake'],
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _recordingState = 'ready';
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Record Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isDarkMode ? Colors.grey[800] : Colors.white,
                              foregroundColor: isDarkMode
                                  ? Colors.blue[300]
                                  : Colors.blue[600],
                              elevation: 0,
                              side: BorderSide(
                                color: isDarkMode
                                    ? Colors.blue[700]!.withAlpha(255)
                                    : Colors.blue[200]!.withAlpha(255),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _handleShowFeedback,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode
                                  ? Colors.blue[800]
                                  : Colors.blue[600],
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                            child: const Text('See Feedback'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackStage(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCard(
          isDarkMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Response',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow, size: 14),
                    label: const Text('Play'),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          isDarkMode ? Colors.blue[300] : Colors.blue[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.grey[700]!.withAlpha(255)
                        : Colors.grey[200]!.withAlpha(255),
                  ),
                ),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                    children: [
                      const TextSpan(text: 'I '),
                      TextSpan(
                        text: 'no can',
                        style: TextStyle(
                          color: Colors.red[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const TextSpan(text: ' join the meeting '),
                      TextSpan(
                        text: 'yesterday',
                        style: TextStyle(
                          color: Colors.red[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const TextSpan(text: ' because I '),
                      TextSpan(
                        text: 'am',
                        style: TextStyle(
                          color: Colors.red[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const TextSpan(text: ' sick.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          isDarkMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Improvement Suggestions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                _practiceItem['mistakeDetails'].length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.red[500],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _practiceItem['mistakeDetails'][index]['issue'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Text(
                          _practiceItem['mistakeDetails'][index]['example'],
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                      if (index < _practiceItem['mistakeDetails'].length - 1)
                        const Divider(height: 24),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.green[500],
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Better way to express this:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.green[900] : Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.green[800]!.withAlpha(255)
                        : Colors.green[100]!.withAlpha(255),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _practiceItem['betterExpression'],
                      style: TextStyle(
                        color:
                            isDarkMode ? Colors.green[100] : Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.volume_up, size: 12),
                      label: const Text('Listen'),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            isDarkMode ? Colors.green[300] : Colors.green[700],
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handlePracticeCorrect,
                  icon: const Icon(Icons.repeat),
                  label: const Text('Practice the Correct Version'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDarkMode ? Colors.blue[800] : Colors.blue[600],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPracticeStage(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCard(
          isDarkMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Practice the Correct Version',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.green[900] : Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.green[800]!.withAlpha(255)
                        : Colors.green[100]!.withAlpha(255),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _practiceItem['betterExpression'],
                      style: TextStyle(
                        color:
                            isDarkMode ? Colors.green[100] : Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.volume_up, size: 12),
                      label: const Text('Listen'),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            isDarkMode ? Colors.green[300] : Colors.green[700],
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Alternative Expressions:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(
                _practiceItem['alternatives'].length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color:
                              isDarkMode ? Colors.blue[800] : Colors.blue[100],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDarkMode
                                  ? Colors.blue[300]
                                  : Colors.blue[600],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _practiceItem['alternatives'][index],
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 32),
              const Text(
                'Your Practice',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_recordingState == 'recording')
                Column(
                  children: [
                    Text(
                      'Recording...',
                      style: TextStyle(
                        color: Colors.red[500],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _handleRecord,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.red[500],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.stop,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              else if (_recordingState == 'recorded')
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.play_arrow,
                          size: 16,
                          color:
                              isDarkMode ? Colors.blue[300] : Colors.blue[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[700]!.withAlpha(255)
                                  : Colors.grey[200]!.withAlpha(255),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.blue[600]
                                    : Colors.blue[500],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '0:03',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _recordingState = 'ready';
                              });
                            },
                            icon: const Icon(Icons.refresh, size: 14),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isDarkMode ? Colors.grey[800] : Colors.white,
                              foregroundColor: isDarkMode
                                  ? Colors.blue[300]
                                  : Colors.blue[600],
                              elevation: 0,
                              side: BorderSide(
                                color: isDarkMode
                                    ? Colors.blue[700]!.withAlpha(255)
                                    : Colors.blue[200]!.withAlpha(255),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _handleComplete,
                            icon: const Icon(Icons.check_circle, size: 14),
                            label: const Text('Perfect!'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode
                                  ? Colors.green[800]!.withAlpha(255)
                                  : Colors.green[600]!.withAlpha(255),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Center(
                  child: GestureDetector(
                    onTap: _handleRecord,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.blue[800] : Colors.blue[600],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          isDarkMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: isDarkMode ? Colors.blue[300] : Colors.blue[500],
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Why This Matters',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Using the correct tense helps your listener understand exactly when events happened. For past events, using past tense forms like "couldn\'t" and "was" is essential for clarity.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteStage(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.green[900] : Colors.green[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: 28,
            color: Colors.green[500],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Great job!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You\'ve practiced the correct way to express this idea. This will help you avoid similar mistakes in the future.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),
        _buildCard(
          isDarkMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Improvement',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.red[900] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.red[800]!.withAlpha(255)
                        : Colors.red[100]!.withAlpha(255),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Before:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _practiceItem['commonMistake'],
                      style: TextStyle(
                        color: isDarkMode ? Colors.red[100] : Colors.red[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.green[900] : Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.green[800]!.withAlpha(255)
                        : Colors.green[100]!.withAlpha(255),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'After:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _practiceItem['betterExpression'],
                      style: TextStyle(
                        color:
                            isDarkMode ? Colors.green[100] : Colors.green[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Accuracy:',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '95%',
                        style: TextStyle(
                          color: Colors.green[500],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 128,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey[700]!.withAlpha(255)
                              : Colors.grey[200]!.withAlpha(255),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.95,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green[500],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _handleNext,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continue to Next Practice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.blue[800] : Colors.blue[600],
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(bool isDarkMode, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
