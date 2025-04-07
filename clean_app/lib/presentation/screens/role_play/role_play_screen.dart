import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../application/conversation/conversation_bloc.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../../domain/repositories/conversation_repository.dart';
import '../../widgets/chat_message_bubble.dart';

class RolePlayScreen extends StatefulWidget {
  const RolePlayScreen({super.key});

  @override
  State<RolePlayScreen> createState() => _RolePlayScreenState();
}

class _RolePlayScreenState extends State<RolePlayScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String _selectedScenario = 'Job Interview';
  String? _currentConversationId;

  final List<String> _scenarios = [
    'Job Interview',
    'Restaurant Order',
    'Shopping',
    'Travel Booking',
    'Doctor Visit',
    'Business Meeting',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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

  void _startNewScenario(BuildContext context) {
    context.read<ConversationBloc>().add(
          CreateConversation(
            userRole: 'User',
            aiRole: _getAiRoleForScenario(_selectedScenario),
            situation: _getSituationForScenario(_selectedScenario),
          ),
        );
  }

  String _getAiRoleForScenario(String scenario) {
    switch (scenario) {
      case 'Job Interview':
        return 'Interviewer';
      case 'Restaurant Order':
        return 'Waiter';
      case 'Shopping':
        return 'Shop Assistant';
      case 'Travel Booking':
        return 'Travel Agent';
      case 'Doctor Visit':
        return 'Doctor';
      case 'Business Meeting':
        return 'Business Partner';
      default:
        return 'AI Assistant';
    }
  }

  String _getSituationForScenario(String scenario) {
    switch (scenario) {
      case 'Job Interview':
        return 'You are interviewing for a software developer position.';
      case 'Restaurant Order':
        return 'You are ordering food at a restaurant.';
      case 'Shopping':
        return 'You are shopping for clothes at a department store.';
      case 'Travel Booking':
        return 'You are booking a vacation package.';
      case 'Doctor Visit':
        return 'You are visiting the doctor for a check-up.';
      case 'Business Meeting':
        return 'You are discussing a project proposal with a potential client.';
      default:
        return 'General conversation practice.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConversationBloc(
        repository: context.read<ConversationRepository>(),
      ),
      child: BlocListener<ConversationBloc, ConversationState>(
        listener: (context, state) {
          if (state is ConversationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          } else if (state is ConversationSuccess &&
              state.conversationId != null) {
            _currentConversationId = state.conversationId;
            _scrollToBottom();
          } else if (state is ConversationSuccess) {
            _scrollToBottom();
          } else if (state is ConversationEnded) {
            _showFeedbackDialog(context, state.feedback);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Role Play'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.stop_circle_outlined),
                onPressed: _currentConversationId == null
                    ? null
                    : () {
                        context.read<ConversationBloc>().add(
                              EndConversation(_currentConversationId!),
                            );
                      },
                tooltip: 'End Conversation',
              ),
            ],
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade900.withOpacity(0.8)
                        : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedScenario,
                          decoration: InputDecoration(
                            labelText: 'Select Scenario',
                            labelStyle: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.tealAccent
                                  : const Color(0xFF3B82F6),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade700
                                    : Colors.blue.shade200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade700
                                    : Colors.blue.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.tealAccent
                                    : const Color(0xFF3B82F6),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade800.withOpacity(0.5)
                                    : Colors.white,
                          ),
                          dropdownColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade800
                                  : Colors.white,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                            fontSize: 16,
                          ),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.tealAccent
                                    : const Color(0xFF3B82F6),
                          ),
                          items: _scenarios.map((scenario) {
                            return DropdownMenuItem(
                              value: scenario,
                              child: Text(scenario),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedScenario = value;
                                _currentConversationId = null;
                              });
                              _startNewScenario(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade900.withOpacity(0.8)
                          : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: BlocBuilder<ConversationBloc, ConversationState>(
                      builder: (context, state) {
                        if (state is ConversationLoading &&
                            state is! ConversationSuccess &&
                            state is! ConversationHistoryLoaded) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final messages = state is ConversationSuccess
                            ? state.messages
                            : state is ConversationHistoryLoaded
                                ? state.messages
                                : <ChatMessage>[];

                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return ChatMessageBubble(message: message);
                          },
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade900.withOpacity(0.8)
                        : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, -2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                            filled: true,
                            fillColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade800.withOpacity(0.5)
                                    : Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.tealAccent
                                    : const Color(0xFF3B82F6),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.tealAccent
                              : const Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send),
                          color: Colors.white,
                          onPressed: () {
                            if (_messageController.text.trim().isNotEmpty) {
                              context.read<ConversationBloc>().add(
                                    SendMessage(
                                      conversationId: _currentConversationId!,
                                      message: _messageController.text.trim(),
                                    ),
                                  );
                              _messageController.clear();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFeedbackDialog(
      BuildContext context, Map<String, dynamic> feedback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conversation Feedback'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pronunciation Score: ${feedback['pronunciation_score']}'),
              const SizedBox(height: 8),
              Text('Grammar Score: ${feedback['grammar_score']}'),
              const SizedBox(height: 8),
              Text('Fluency Score: ${feedback['fluency_score']}'),
              const SizedBox(height: 16),
              const Text('Suggestions for Improvement:'),
              const SizedBox(height: 8),
              Text(feedback['suggestions']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentConversationId = null;
              });
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
