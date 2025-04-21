import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/widgets/buttons/primary_button.dart';
import '../../../../core/presentation/widgets/buttons/secondary_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';
import '../bloc/conversation_state.dart';
import 'widgets/feedback_panel.dart';
import 'widgets/message_bubble.dart';
import 'widgets/recording_button.dart';

/// Screen for active conversation
///
/// Displays the conversation between user and AI, allowing the user
/// to record responses and view feedback
class ConversationScreen extends StatefulWidget {
  final Conversation conversation;

  const ConversationScreen({
    Key? key,
    required this.conversation,
  }) : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _scrollController = ScrollController();
  bool _showSituation = true;

  @override
  void initState() {
    super.initState();
    // Make sure we're working with the latest conversation state
    if (widget.conversation.id != 
        (context.read<ConversationBloc>().state.conversation?.id ?? '')) {
      context.read<ConversationBloc>().add(LoadConversationEvent(
        conversationId: widget.conversation.id,
      ));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startRecording() {
    context.read<ConversationBloc>().add(StartRecordingEvent());
  }

  void _stopRecording() {
    // In a real app, we would have the audio file path and transcription here
    // This is a placeholder - your audio service would provide real values
    context.read<ConversationBloc>().add(StopRecordingEvent(
      filePath: '/path/to/audio.mp3',
      transcription: 'This is a sample transcription of the user\'s speech.',
    ));
  }

  void _cancelRecording() {
    context.read<ConversationBloc>().add(CancelRecordingEvent());
  }

  void _sendMessage(String message, {String? audioPath, String? transcription}) {
    context.read<ConversationBloc>().add(SendUserMessageEvent(
      content: message,
      audioPath: audioPath,
      transcription: transcription,
    ));
    _scrollToBottom();
  }

  void _requestFeedback(String messageId, String audioPath, String transcription) {
    context.read<ConversationBloc>().add(RequestFeedbackEvent(
      messageId: messageId,
      audioPath: audioPath,
      transcription: transcription,
    ));
  }

  void _closeFeedback() {
    context.read<ConversationBloc>().add(CloseFeedbackEvent());
  }

  void _completeConversation() {
    context.read<ConversationBloc>().add(CompleteConversationEvent());
  }

  Widget _buildSituationHeader(BuildContext context, Conversation conversation) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showSituation ? null : 60,
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Situation',
                  style: TextStyles.h3(context),
                ),
              ),
              IconButton(
                icon: Icon(_showSituation ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                onPressed: () {
                  setState(() {
                    _showSituation = !_showSituation;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (_showSituation) ...[
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                conversation.situation,
                style: TextStyles.body(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your role: ${conversation.userRole}',
              style: TextStyles.secondary(context),
            ),
            Text(
              'AI role: ${conversation.aiRole}',
              style: TextStyles.secondary(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context, List<Message> messages) {
    _scrollToBottom();
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return MessageBubble(
            message: message,
            onFeedbackRequest: message.sender == SenderType.user && message.audioPath != null
                ? () => _requestFeedback(
                    message.id,
                    message.audioPath!,
                    message.transcription ?? message.content,
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, ConversationState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(false),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.lastTranscription != null && state.lastTranscription!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.getBackgroundColor(false),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your response:',
                    style: TextStyles.secondary(context, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.lastTranscription!,
                    style: TextStyles.body(context),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SecondaryButton(
                        text: 'Re-record',
                        onPressed: _startRecording,
                        icon: Icons.mic,
                      ),
                      const SizedBox(width: 8),
                      PrimaryButton(
                        text: 'Send',
                        onPressed: () => _sendMessage(
                          state.lastTranscription!,
                          audioPath: state.lastRecordingPath,
                          transcription: state.lastTranscription,
                        ),
                        icon: Icons.send,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            RecordingButton(
              isRecording: state.recordingState == RecordingState.recording,
              isProcessing: state.recordingState == RecordingState.processing,
              onRecordingStarted: _startRecording,
              onRecordingStopped: _stopRecording,
              onRecordingCancelled: _cancelRecording,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, ConversationState state) {
    return Column(
      children: [
        _buildSituationHeader(context, state.conversation!),
        _buildMessageList(context, state.conversation!.messages),
        _buildInputArea(context, state),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, ConversationState state) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildSituationHeader(context, state.conversation!),
              _buildMessageList(context, state.conversation!.messages),
              _buildInputArea(context, state),
            ],
          ),
        ),
        if (state.activeFeedback != null)
          Expanded(
            flex: 2,
            child: FeedbackPanel(
              feedback: state.activeFeedback!,
              onClose: _closeFeedback,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationBloc, ConversationState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.conversation == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Conversation'),
            ),
            body: Center(
              child: Text(
                state.errorMessage ?? 'Conversation not found',
                style: TextStyles.body(context),
              ),
            ),
          );
        }

        final conversation = state.conversation!;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Role Play',
                  style: TextStyles.h3(context, isDarkMode: false),
                ),
                Text(
                  '${conversation.userRole} & ${conversation.aiRole}',
                  style: TextStyles.caption(context, isDarkMode: false),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: _completeConversation,
                tooltip: 'Complete conversation',
              ),
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                // Main conversation layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (ResponsiveLayout.isLargeScreen(context)) {
                      return _buildLandscapeLayout(context, state);
                    } else {
                      return _buildPortraitLayout(context, state);
                    }
                  },
                ),
                // Overlay feedback panel for portrait mode
                if (state.activeFeedback != null && !ResponsiveLayout.isLargeScreen(context))
                  Positioned.fill(
                    child: FeedbackPanel(
                      feedback: state.activeFeedback!,
                      onClose: _closeFeedback,
                      isOverlay: true,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
