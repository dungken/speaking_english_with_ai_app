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
import '../bloc/conversation_event_adapter.dart';
import '../bloc/conversation_state.dart';
import '../bloc/conversation_state_adapter.dart';
import 'widgets/simple_feedback_panel.dart';
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
  TextEditingController _transcriptionEditController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Make sure we're working with the latest conversation state
    if (widget.conversation.id != 
        (context.read<ConversationBloc>().state.conversation?.id ?? '')) {
      context.read<ConversationBloc>().add(
        LoadConversationEvent(conversationId: widget.conversation.id),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _transcriptionEditController.dispose();
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
    // This will be handled by the bloc, which will now:
    // 1. Stop recording
    // 2. Upload the audio to get transcription and audioId
    // 3. Show the transcription to the user
    context.read<ConversationBloc>().add(StopRecordingEvent(
      filePath: 'placeholder', // This will be replaced by the actual audio service
    ));
  }

  void _cancelRecording() {
    context.read<ConversationBloc>().add(CancelRecordingEvent());
  }

  void _sendMessage(ConversationState state) {
    final conversationId = state.conversation?.id ?? '';
    final audioId = state.audioId;
    
    if (conversationId.isNotEmpty && audioId != null) {
      context.read<ConversationBloc>().add(
        SendSpeechMessageEvent(
          conversationId: conversationId,
          audioId: audioId,
        ),
      );
      _scrollToBottom();
    }
  }

  void _editTranscription(String newTranscription) {
    context.read<ConversationBloc>().add(
      EditTranscriptionEvent(
        transcription: newTranscription,
      ),
    );
  }

  void _requestFeedback(String messageId) {
    context.read<ConversationBloc>().add(
      GetMessageFeedbackEvent(
        messageId: messageId,
      ),
    );
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
                ? () => _requestFeedback(message.id)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildTranscriptionEditor(BuildContext context, String transcription) {
    if (_transcriptionEditController.text.isEmpty) {
      _transcriptionEditController.text = transcription;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.getBackgroundColor(false),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your response:',
            style: TextStyles.secondary(context, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: _transcriptionEditController,
            maxLines: 3,
            onChanged: _editTranscription,
            decoration: const InputDecoration(
              hintText: 'Edit your response if needed',
              border: InputBorder.none,
            ),
            style: TextStyles.body(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, ConversationState state) {
    final isRecording = ConversationStateAdapter.isRecording(state);
    final isProcessing = ConversationStateAdapter.isProcessing(state);
    final transcription = ConversationStateAdapter.getTranscriptionFromState(state);
    final isTranscriptionReady = ConversationStateAdapter.isTranscriptionReady(state);
    
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
          if (isTranscriptionReady && transcription != null) ...[
            _buildTranscriptionEditor(context, transcription),
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
                  onPressed: () => _sendMessage(state),
                  icon: Icons.send,
                ),
              ],
            ),
          ] else ...[
            RecordingButton(
              isRecording: isRecording,
              isProcessing: isProcessing,
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
    final messages = ConversationStateAdapter.getMessagesFromState(state);
    return Column(
      children: [
        _buildSituationHeader(context, state.conversation!),
        _buildMessageList(context, messages),
        _buildInputArea(context, state),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, ConversationState state) {
    final messages = ConversationStateAdapter.getMessagesFromState(state);
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildSituationHeader(context, state.conversation!),
              _buildMessageList(context, messages),
              _buildInputArea(context, state),
            ],
          ),
        ),
        if (state.activeFeedback != null)
          Expanded(
            flex: 2,
            child: SimpleFeedbackPanel(
              feedback: state.activeFeedback!.userFeedback,
              onClose: _closeFeedback,
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation'),
      ),
      body: Center(
        child: Text(
          message,
          style: TextStyles.body(context),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationBloc, ConversationState>(
      builder: (context, state) {
        // Handle loading state
        if (state.isLoading) {
          return _buildLoadingScreen();
        }

        // Handle error state or no conversation
        if (state.conversation == null) {
          return _buildErrorScreen(
            state.errorMessage ?? 'Conversation not found'
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
                    child: SimpleFeedbackPanel(
                      feedback: state.activeFeedback!.userFeedback,
                      onClose: _closeFeedback,
                      isOverlay: true,
                    ),
                  ),
                // Error message snackbar
                if (state.errorMessage != null)
                  Positioned(
                    bottom: 80,
                    left: 16,
                    right: 16,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.red.shade700,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Text(
                          state.errorMessage!,
                          style: TextStyles.body(context, color: Colors.white),
                        ),
                      ),
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
