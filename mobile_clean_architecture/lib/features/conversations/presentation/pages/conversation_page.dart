import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/widgets/layout/app_scaffold.dart';
import '../../../../core/presentation/widgets/inputs/voice_input.dart';
import '../../../../core/services/audio_services.dart';
import '../../../../core/services/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';
import '../bloc/conversation_state.dart';
import '../widgets/conversation_bubbles.dart';
import '../widgets/feedback_card.dart';

class ConversationPage extends StatefulWidget {
  final Conversation conversation;
  final Message? initialMessage;

  const ConversationPage({
    Key? key,
    required this.conversation,
    this.initialMessage,
  }) : super(key: key);

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final AudioService _audioService = getIt<AudioService>();
  final ScrollController _scrollController = ScrollController();

  bool _isRecording = false;
  String? _currentMessageId;
  bool _isFeedbackVisible = false;

  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();

    // Add initial message if provided
    if (widget.initialMessage != null) {
      _messages.add(widget.initialMessage!);
    }

    // Initialize audio service
    _audioService.initialize();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _startRecording() async {
    setState(() {
      _isRecording = true;
    });

    // Start recording using the audio service
    await _audioService.startRecording();

    // Dispatch event to bloc to update recording state
    context.read<ConversationBloc>().add(StartRecordingEvent());
  }

  void _stopRecording() async {
    setState(() {
      _isRecording = false;
    });

    // Stop recording and get audio file path
    final audioPath = await _audioService.stopRecording();

    if (audioPath != null) {
      try {
        // Notify bloc that recording has stopped
        context.read<ConversationBloc>().add(StopRecordingEvent(
              filePath: audioPath,
            ));

        // Upload audio and get transcription ID
        final transcriptionResult =
            await _audioService.uploadAudioAndGetTranscription(audioPath);
        final String audioId = transcriptionResult['audio_id'];

        // Send the audio message to the conversation
        context.read<ConversationBloc>().add(SendSpeechMessageEvent(
              conversationId: widget.conversation.id,
              audioId: audioId,
            ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showFeedback(String messageId) {
    setState(() {
      _currentMessageId = messageId;
      _isFeedbackVisible = true;
    });

    // Request feedback for the message
    context.read<ConversationBloc>().add(GetMessageFeedbackEvent(
          messageId: messageId,
        ));
  }

  void _hideFeedback() {
    setState(() {
      _isFeedbackVisible = false;
    });

    // Close feedback in bloc
    context.read<ConversationBloc>().add(CloseFeedbackEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      title: 'Conversation',
      body: BlocConsumer<ConversationBloc, ConversationState>(
        listener: (context, state) {
          if (state is MessagesSent) {
            setState(() {
              _messages.add(state.lastMessages!.userMessage);
              _messages.add(state.lastMessages!.aiMessage);
            });

            // Scroll to see the new messages
            Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
          } else if (state is ConversationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred')),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Column(
                children: [
                  // Situation banner at the top
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.getBackgroundColor(isDarkMode)
                        .withOpacity(0.95),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Situation',
                          style: TextStyles.caption(
                            context,
                            isDarkMode: isDarkMode,
                            color: AppColors.getTextSecondaryColor(isDarkMode),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.conversation.situation,
                          style: TextStyles.body(
                            context,
                            isDarkMode: isDarkMode,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildRoleBadge(
                              'You: ${widget.conversation.userRole}',
                              AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            _buildRoleBadge(
                              'AI: ${widget.conversation.aiRole}',
                              AppColors.accent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Messages list in the middle
                  Expanded(
                    child: _messages.isEmpty
                        ? Center(
                            child: Text(
                              'No messages yet. Start the conversation!',
                              style: TextStyles.body(
                                context,
                                isDarkMode: isDarkMode,
                                color:
                                    AppColors.getTextSecondaryColor(isDarkMode),
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              final showFeedbackButton =
                                  message.sender == SenderType.user;

                              return Column(
                                children: [
                                  MessageBubble(
                                    message: message,
                                    onFeedbackPressed: showFeedbackButton
                                        ? () => _showFeedback(message.id)
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              );
                            },
                          ),
                  ),

                  // Voice input at the bottom
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: VoiceInput(
                      isRecording: _isRecording,
                      onRecordingStarted: _startRecording,
                      onRecordingStopped: _stopRecording,
                      placeholder: 'Tap the microphone to respond...',
                      showWaveform: true,
                      maxDuration: const Duration(seconds: 60),
                    ),
                  ),
                ],
              ),

              // Feedback overlay when visible
              if (_isFeedbackVisible)
                GestureDetector(
                  onTap: _hideFeedback, // Tap outside closes the feedback panel
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap:
                          () {}, // Prevent taps on feedback card from closing overlay
                      child: BlocBuilder<ConversationBloc, ConversationState>(
                        builder: (context, state) {
                          if (state is FeedbackLoading) {
                            return const FeedbackCard(
                              isLoading: true,
                            );
                          } else if (state is FeedbackLoaded) {
                            return FeedbackCard(
                              feedback: state.activeFeedback,
                              onClose: _hideFeedback,
                            );
                          } else if (state is FeedbackProcessing) {
                            return FeedbackCard(
                              isProcessing: true,
                              processingMessage: state.processingMessage,
                              onRetry: () {
                                if (_currentMessageId != null) {
                                  context.read<ConversationBloc>().add(
                                        GetMessageFeedbackEvent(
                                            messageId: _currentMessageId!),
                                      );
                                }
                              },
                              onClose: _hideFeedback,
                            );
                          } else if (state is FeedbackError) {
                            return FeedbackCard(
                              error: state.errorMessage,
                              onRetry: () {
                                if (_currentMessageId != null) {
                                  context.read<ConversationBloc>().add(
                                        GetMessageFeedbackEvent(
                                            messageId: _currentMessageId!),
                                      );
                                }
                              },
                              onClose: _hideFeedback,
                            );
                          }

                          // Default loading state
                          return const FeedbackCard(
                            isLoading: true,
                          );
                        },
                      ),
                    ),
                  ),
                ),

              // Loading indicator
              if (state.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRoleBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}
