import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/widgets/buttons/primary_button.dart';
import '../../../../core/presentation/widgets/layout/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../domain/entities/conversation.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';
import '../bloc/conversation_state.dart';
import 'conversation_page.dart';
import 'create_conversation_page.dart';

class ConversationsListPage extends StatelessWidget {
  const ConversationsListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Conversations',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CreateConversationPage(),
              ),
            );
          },
        ),
      ],
      body: BlocConsumer<ConversationBloc, ConversationState>(
        listener: (context, state) {
          if (state is ConversationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred')),
            );
          }
        },
        buildWhen: (previous, current) {
          // Only rebuild the UI when these specific states change
          return previous.isLoading != current.isLoading ||
              previous is ConversationInitial !=
                  current is ConversationInitial ||
              previous is ConversationsLoaded !=
                  current is ConversationsLoaded ||
              (previous is ConversationsLoaded &&
                  current is ConversationsLoaded &&
                  previous.conversations != current.conversations);
        },
        builder: (context, state) {
          // Load conversations when page is first opened
          if (state is ConversationInitial) {
            context.read<ConversationBloc>().add(
                  const GetUserConversationsEvent(),
                );
            return const Center(child: CircularProgressIndicator());
          }

          // Show loading indicator
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Display conversations if loaded
          if (state is ConversationsLoaded) {
            final conversations = state.conversations;

            if (conversations.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ConversationBloc>().add(
                      const GetUserConversationsEvent(page: 1),
                    );
                // Wait for refresh to complete
                await Future.delayed(const Duration(seconds: 1));
              },
              child: _buildConversationsList(context, conversations),
            );
          }

          // Default state
          return _buildEmptyState(context);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.getTextSecondaryColor(isDarkMode),
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyles.h2(context, isDarkMode: isDarkMode),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Start a new conversation to practice your English speaking skills',
            style: TextStyles.body(
              context,
              isDarkMode: isDarkMode,
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Create Conversation',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateConversationPage(),
                ),
              );
            },
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  // Use a more efficient ListView implementation
  Widget _buildConversationsList(
      BuildContext context, List<Conversation> conversations) {
    return ListView.builder(
      // Add caching to avoid rebuilding when scrolling
      cacheExtent: 100,
      padding: const EdgeInsets.all(16),
      // Use efficient indexed item count loading
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        // Use a separate efficient widget for list items
        return ConversationListItem(conversation: conversation);
      },
    );
  }
}

/// A separate stateless widget for individual conversation items
/// This helps optimize rebuilds - only changed items will rebuild
class ConversationListItem extends StatelessWidget {
  final Conversation conversation;

  // Cache the date formatter to avoid recreating it for every item
  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy • h:mm a');

  const ConversationListItem({
    Key? key,
    required this.conversation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hasEnded = conversation.endedAt != null;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ConversationPage(
                conversation: conversation,
                initialMessage: conversation.messages.isNotEmpty
                    ? conversation.messages.first
                    : null,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Situation
              Text(
                conversation.situation,
                style: TextStyles.h3(context, isDarkMode: isDarkMode),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Roles - precalculate and construct once
              Row(
                children: [
                  _buildRoleBadge(
                    'You: ${conversation.userRole}',
                    AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _buildRoleBadge(
                    'AI: ${conversation.aiRole}',
                    AppColors.accent,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date - use cached formatter
                  Text(
                    _dateFormat.format(conversation.startedAt),
                    style: TextStyles.caption(
                      context,
                      isDarkMode: isDarkMode,
                      color: AppColors.getTextSecondaryColor(isDarkMode),
                    ),
                  ),

                  // Status - prebuilt widgets
                  if (hasEnded)
                    _buildStatusBadge(
                        'Completed', AppColors.success, isDarkMode)
                  else
                    _buildStatusBadge(
                        'In Progress', AppColors.info, isDarkMode),
                ],
              ),

              // Message preview (if available)
              if (conversation.messages.isNotEmpty)
                _buildMessagePreview(
                    context, conversation.messages.last.content, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildStatusBadge(String text, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildMessagePreview(
      BuildContext context, String content, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyles.body(
            context,
            isDarkMode: isDarkMode,
            color: AppColors.getTextSecondaryColor(isDarkMode),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
