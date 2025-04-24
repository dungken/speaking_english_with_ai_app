import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/buffer_queue_error_handler.dart';
import '../../../../core/utils/rendering/buffer_queue_manager.dart';
import '../../../../core/utils/android_recording_optimizer.dart';

import '../../../../core/presentation/widgets/buttons/primary_button.dart';
import '../../../../core/presentation/widgets/buttons/secondary_button.dart';
import '../../../../core/presentation/widgets/wrapper/surface_view_wrapper.dart';
import '../../../../core/presentation/widgets/wrapper/error_boundary.dart';
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
import 'widgets/simplified_recording_button.dart';

/// Optimized conversation screen that prevents unnecessary rebuilds
class ConversationScreenOptimized extends StatefulWidget {
  final Conversation conversation;

  const ConversationScreenOptimized({
    Key? key,
    required this.conversation,
  }) : super(key: key);

  @override
  State<ConversationScreenOptimized> createState() => _ConversationScreenOptimizedState();
}

class _ConversationScreenOptimizedState extends State<ConversationScreenOptimized> {
  final _scrollController = ScrollController();
  bool _showSituation = true;
  TextEditingController _transcriptionEditController = TextEditingController();

  @override
  void initState() {
    super.initState();
    BufferQueueManager.startMonitoring();

    // Initialize conversation if needed
    if (widget.conversation.id !=
        (context.read<ConversationBloc>().state.conversation?.id ?? '')) {
      context.read<ConversationBloc>().add(
            LoadConversationEvent(conversationId: widget.conversation.id),
          );
    }
  }

  @override
  void dispose() {
    BufferQueueManager.stopMonitoring();
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
    // Clear the transcription text controller when starting a new recording
    _transcriptionEditController.clear();
    context.read<ConversationBloc>().add(StartRecordingEvent());
  }

  void _stopRecording() {
    context.read<ConversationBloc>().add(StopRecordingEvent(
          filePath: 'placeholder',
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
                icon: Icon(_showSituation
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down),
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
            onFeedbackRequest:
                message.sender == SenderType.user && message.audioPath != null
                    ? () => _requestFeedback(message.id)
                    : null,
          );
        },
      ),
    );
  }

  Widget _buildTranscriptionEditor(BuildContext context, String transcription) {
    // Always update the controller when transcription changes
    if (_transcriptionEditController.text != transcription) {
      _transcriptionEditController.text = transcription;
      // Set the cursor to the end of the text
      _transcriptionEditController.selection = TextSelection.fromPosition(
        TextPosition(offset: transcription.length),
      );
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

  Widget _buildInputArea(BuildContext context) {
    return BlocSelector<ConversationBloc, ConversationState, ({
      bool isRecording,
      bool isProcessing,
      String? transcription,
      bool isTranscriptionReady,
    })>(
      selector: (state) => (
        isRecording: ConversationStateAdapter.isRecording(state),
        isProcessing: ConversationStateAdapter.isProcessing(state),
        transcription: ConversationStateAdapter.getTranscriptionFromState(state),
        isTranscriptionReady: ConversationStateAdapter.isTranscriptionReady(state),
      ),
      builder: (context, inputState) {
        return AndroidRecordingOptimizer.wrapRecordingWidget(
          isRecording: inputState.isRecording,
          child: BufferQueueManager.optimizeWidget(
            child: SurfaceViewWrapper(
              isActiveMedia: inputState.isRecording || inputState.isProcessing,
              child: Container(
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
                    if (inputState.isTranscriptionReady && inputState.transcription != null) ...[
                      _buildTranscriptionEditor(context, inputState.transcription!),
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
                          BlocBuilder<ConversationBloc, ConversationState>(
                            builder: (context, state) {
                              return PrimaryButton(
                                text: 'Send',
                                onPressed: () => _sendMessage(state),
                                icon: Icons.send,
                              );
                            },
                          ),
                        ],
                      ),
                    ] else ...[
                      SimplifiedRecordingButton(
                        isRecording: inputState.isRecording,
                        isProcessing: inputState.isProcessing,
                        onRecordingStarted: _startRecording,
                        onRecordingStopped: _stopRecording,
                        onRecordingCancelled: _cancelRecording,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConversationContent(BuildContext context, ConversationState state) {
    final messages = ConversationStateAdapter.getMessagesFromState(state);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ResponsiveLayout.isLargeScreen(context)) {
          return Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildSituationHeader(context, state.conversation!),
                    _buildMessageList(context, messages),
                    _buildInputArea(context),
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
        } else {
          return Column(
            children: [
              _buildSituationHeader(context, state.conversation!),
              _buildMessageList(context, messages),
              _buildInputArea(context),
            ],
          );
        }
      },
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
    return ErrorBoundary(
      onError: (error, stackTrace) {
        BufferQueueErrorHandler.handleBufferQueueError(
          context,
          error.toString(),
        );
      },
      child: BlocBuilder<ConversationBloc, ConversationState>(
        // Only rebuild when conversation is null/loaded or error occurs
        buildWhen: (previous, current) {
          return previous.conversation != current.conversation ||
              previous.errorMessage != current.errorMessage ||
              (previous.conversation == null && current.conversation != null);
        },
        builder: (context, state) {
          if (state.conversation == null) {
            if (state.isLoading) {
              return _buildLoadingScreen();
            }
            return _buildErrorScreen(
                state.errorMessage ?? 'Conversation not found');
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
                  // Main conversation content
                  BlocBuilder<ConversationBloc, ConversationState>(
                    builder: (context, state) => _buildConversationContent(context, state),
                  ),
                  // Feedback overlay (only rebuilds when feedback changes)
                  BlocSelector<ConversationBloc, ConversationState, bool>(
                    selector: (state) => state.activeFeedback != null && 
                        !ResponsiveLayout.isLargeScreen(context),
                    builder: (context, showFeedbackOverlay) {
                      if (showFeedbackOverlay) {
                        return BlocSelector<ConversationBloc, ConversationState, String?>(
                          selector: (state) => state.activeFeedback?.userFeedback,
                          builder: (context, feedbackText) {
                            return Positioned.fill(
                              child: SimpleFeedbackPanel(
                                feedback: feedbackText ?? '',
                                onClose: _closeFeedback,
                                isOverlay: true,
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  // Error message (only rebuilds when error changes)
                  BlocSelector<ConversationBloc, ConversationState, String?>(
                    selector: (state) => state.errorMessage,
                    builder: (context, errorMessage) {
                      if (errorMessage != null) {
                        return Positioned(
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
                                errorMessage,
                                style: TextStyles.body(context, color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
