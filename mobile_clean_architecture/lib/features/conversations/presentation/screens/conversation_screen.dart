import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
import '../bloc/conversation_state.dart';
import '../bloc/conversation_state_adapter.dart';
import 'widgets/simple_feedback_panel.dart';
import 'widgets/message_bubble.dart';
import 'widgets/simplified_recording_button.dart';

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

  // Initializes the screen and sets up buffer monitoring and conversation state.
  // This ensures the screen is ready to handle user interactions and displays the correct conversation.
  @override
  void initState() {
    super.initState();

    // Filter out BLASTBufferQueue errors
    BufferQueueErrorHandler.filterBLASTBufferQueueErrors();

    // Start buffer monitoring when the screen initializes
    BufferQueueManager.startMonitoring();
    // Make sure we're working with the latest conversation state
    if (widget.conversation.id !=
        (context.read<ConversationBloc>().state.conversation?.id ?? '')) {
      context.read<ConversationBloc>().add(
            LoadConversationEvent(conversationId: widget.conversation.id),
          );
    }
  }

  // Cleans up resources like buffer monitoring and controllers when the screen is disposed.
  // This prevents memory leaks and ensures proper cleanup when the user leaves the screen.
  @override
  void dispose() {
    // Stop buffer monitoring when the screen is disposed
    BufferQueueManager.stopMonitoring();
    _scrollController.dispose();
    _transcriptionEditController.dispose();
    super.dispose();
  }

  // Scrolls the message list to the bottom to show the latest messages.
  // This is used after sending a message or when new messages are added.
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

  // Starts a new voice recording and clears the transcription text.
  // This is the first step in capturing user input for the conversation.
  void _startRecording() {
    // Clear the transcription text controller when starting a new recording
    _transcriptionEditController.clear();
    context.read<ConversationBloc>().add(StartRecordingEvent());
  }

  // Stops the current recording and triggers transcription processing.
  // This is used to convert the user's audio input into text for the conversation.
  void _stopRecording() {
    // This will be handled by the bloc, which will now:
    // 1. Stop recording
    // 2. Upload the audio to get transcription and audioId
    // 3. Show the transcription to the user
    context.read<ConversationBloc>().add(StopRecordingEvent(
          filePath:
              'placeholder', // This will be replaced by the actual audio service
        ));
  }

  // Cancels the current recording session.
  // This is used when the user decides not to send the recorded message.
  void _cancelRecording() {
    context.read<ConversationBloc>().add(CancelRecordingEvent());
  }

  // Sends the user's message (audio and transcription) to the conversation.
  // This is the final step in user input, adding the message to the conversation flow.
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

  // Updates the transcription text when the user edits it.
  // This allows the user to refine their input before sending it.
  void _editTranscription(String newTranscription) {
    context.read<ConversationBloc>().add(
          EditTranscriptionEvent(
            transcription: newTranscription,
          ),
        );
  }

  // Requests feedback for a specific message in the conversation.
  // This is used to provide the user with insights or corrections on their input.
  void _requestFeedback(String messageId) {
    context.read<ConversationBloc>().add(
          GetMessageFeedbackEvent(
            messageId: messageId,
          ),
        );
  }

  // Closes the feedback panel.
  // This is used to hide feedback when the user is done reviewing it.
  void _closeFeedback() {
    context.read<ConversationBloc>().add(CloseFeedbackEvent());
  }

  // Marks the conversation as complete.
  // This is used to signal the end of the conversation session.
  void _completeConversation() {
    context.read<ConversationBloc>().add(CompleteConversationEvent());
  }

  // Builds the header displaying the conversation's situation and roles.
  // This provides context to the user about their role and the AI's role in the conversation.
  Widget _buildSituationHeader(
      BuildContext context, Conversation conversation) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showSituation ? null : 60,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        physics: _showSituation
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
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
              Text(
                conversation.situation,
                style: TextStyles.body(context),
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
      ),
    );
  }

  // Builds the list of messages in the conversation.
  // This displays the conversation history between the user and the AI.
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

  // Builds the transcription editor for the user's response.
  // This allows the user to review and edit their transcribed message before sending it.
  Widget _buildTranscriptionEditor(BuildContext context, String transcription) {
    // Always update the controller when transcription changes to maintain the reference
    if (_transcriptionEditController.text != transcription) {
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
          Text(
            transcription,
            style: TextStyles.body(context),
          ),
        ],
      ),
    );
  }

  // Builds the input area for recording and sending messages.
  // This is the main interaction point for the user to contribute to the conversation.
  Widget _buildInputArea(BuildContext context) {
    return BlocSelector<
        ConversationBloc,
        ConversationState,
        ({
          bool isRecording,
          bool isProcessing,
          String? transcription,
          bool isTranscriptionReady,
          bool isTranscriptionSuccessful,
        })>(
      selector: (state) => (
        isRecording: ConversationStateAdapter.isRecording(state),
        isProcessing: ConversationStateAdapter.isProcessing(state),
        transcription:
            ConversationStateAdapter.getTranscriptionFromState(state),
        isTranscriptionReady:
            ConversationStateAdapter.isTranscriptionReady(state),
        isTranscriptionSuccessful:
            ConversationStateAdapter.isTranscriptionSuccessful(state),
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
                    if (inputState.isTranscriptionReady &&
                        inputState.transcription != null) ...[
                      _buildTranscriptionEditor(
                          context, inputState.transcription!),
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
                          if (inputState.isTranscriptionSuccessful)
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

  // Builds the layout for portrait orientation.
  // This organizes the conversation components vertically for smaller screens.
  Widget _buildPortraitLayout(BuildContext context, ConversationState state) {
    final messages = ConversationStateAdapter.getMessagesFromState(state);
    return Column(
      children: [
        _buildSituationHeader(context, state.conversation!),
        _buildMessageList(context, messages),
        _buildInputArea(context),
      ],
    );
  }

  // Builds the layout for landscape orientation.
  // This organizes the conversation components horizontally for larger screens.
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
  }

  // Builds a loading screen while the conversation is being loaded.
  // This provides feedback to the user during data fetching.
  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Builds an error screen when the conversation fails to load.
  // This informs the user about issues and prevents a blank screen.
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

  // Wraps the screen with an error boundary to handle buffer queue errors.
  // This ensures the app remains stable even if errors occur.
  @override
  Widget build(BuildContext context) {
    // Set up error boundary for BLASTBufferQueue errors
    return ErrorBoundary(
      onError: (error, stackTrace) {
        BufferQueueErrorHandler.handleBufferQueueError(
          context,
          error.toString(),
        );
      },
      child: _buildScreen(context),
    );
  }

  // Builds the main screen layout based on the conversation state.
  // This dynamically updates the UI to reflect the current state of the conversation.
  Widget _buildScreen(BuildContext context) {
    return BlocBuilder<ConversationBloc, ConversationState>(
      // Only rebuild when conversation is null/loaded or error occurs
      buildWhen: (previous, current) {
        return previous.conversation != current.conversation ||
            previous.errorMessage != current.errorMessage ||
            (previous.conversation == null && current.conversation != null);
      },
      builder: (context, state) {
        if (state.conversation == null) {
          if (state.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _buildErrorScreen(
              state.errorMessage ?? 'Conversation not found');
        }

        final conversation = state.conversation!;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.go('/home');
              },
            ),
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
                  builder: (context, state) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        if (ResponsiveLayout.isLargeScreen(context)) {
                          return _buildLandscapeLayout(context, state);
                        } else {
                          return _buildPortraitLayout(context, state);
                        }
                      },
                    );
                  },
                ),
                // Feedback overlay (only rebuilds when feedback changes)
                BlocSelector<ConversationBloc, ConversationState, bool>(
                  selector: (state) =>
                      state.activeFeedback != null &&
                      !ResponsiveLayout.isLargeScreen(context),
                  builder: (context, showFeedbackOverlay) {
                    if (showFeedbackOverlay) {
                      return BlocSelector<ConversationBloc, ConversationState,
                          String?>(
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
                  selector: (state) {
                    // Filter out recording initialization errors
                    if (state.errorMessage != null &&
                        state.errorMessage!
                            .contains('Failed to start recording')) {
                      return null;
                    }
                    return state.errorMessage;
                  },
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
                              style:
                                  TextStyles.body(context, color: Colors.white),
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
    );
  }
}
