import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/widgets/inputs/app_text_field.dart';
import '../../../../core/presentation/widgets/buttons/primary_button.dart';
import '../../../../core/presentation/widgets/layout/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';
import '../bloc/conversation_state.dart';
import 'conversation_page.dart';

class CreateConversationPage extends StatefulWidget {
  const CreateConversationPage({Key? key}) : super(key: key);

  @override
  State<CreateConversationPage> createState() => _CreateConversationPageState();
}

class _CreateConversationPageState extends State<CreateConversationPage> {
  final _userRoleController = TextEditingController();
  final _aiRoleController = TextEditingController();
  final _situationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _userRoleController.dispose();
    _aiRoleController.dispose();
    _situationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      title: 'Create Conversation',
      body: BlocConsumer<ConversationBloc, ConversationState>(
        listener: (context, state) {
          if (state is ConversationActive) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ConversationPage(
                  conversation: state.conversation!,
                  initialMessage: state.conversation!.messages.isNotEmpty
                      ? state.conversation!.messages.first
                      : null,
                ),
              ),
            );
          } else if (state is ConversationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.errorMessage ?? "An error occurred")),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create a Role-Play Conversation',
                    style: TextStyles.h2(context, isDarkMode: isDarkMode),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Set up your roles and situation for a realistic English practice conversation.',
                    style: TextStyles.body(context, isDarkMode: isDarkMode),
                  ),
                  const SizedBox(height: 32),

                  // Your Role
                  Text(
                    'Your Role',
                    style: TextStyles.h3(context, isDarkMode: isDarkMode),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _userRoleController,
                    hintText: 'e.g., Job applicant, Customer, Tourist',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your role';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // AI Role
                  Text(
                    'AI Role',
                    style: TextStyles.h3(context, isDarkMode: isDarkMode),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _aiRoleController,
                    hintText: 'e.g., Interviewer, Waiter, Hotel receptionist',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the AI role';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Situation
                  Text(
                    'Situation',
                    style: TextStyles.h3(context, isDarkMode: isDarkMode),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _situationController,
                    hintText: 'e.g., Job interview at a tech company',
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please describe the situation';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  // Create Button
                  PrimaryButton(
                    text: 'Start Conversation',
                    isLoading: state is ConversationCreating,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<ConversationBloc>().add(
                              CreateConversationEvent(
                                userRole: _userRoleController.text,
                                aiRole: _aiRoleController.text,
                                situation: _situationController.text,
                              ),
                            );
                      }
                    },
                    isFullWidth: true,
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
