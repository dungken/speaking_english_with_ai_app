import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/smooth_transition_manager.dart';

import '../../../../core/presentation/widgets/buttons/primary_button.dart';
import '../../../../core/presentation/widgets/inputs/app_text_input.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';
import '../bloc/conversation_state.dart';

/// Screen for creating a new conversation
///
/// Allows the user to specify their role, the AI's role, and the situation
class CreateConversationScreen extends StatefulWidget {
  const CreateConversationScreen({Key? key}) : super(key: key);

  @override
  State<CreateConversationScreen> createState() =>
      _CreateConversationScreenState();
}

class _CreateConversationScreenState extends State<CreateConversationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userRoleController = TextEditingController();
  final _aiRoleController = TextEditingController();
  final _situationController = TextEditingController();

  bool _isFormValid = false;
  bool _hasNavigated = false; // Flag to track if navigation has occurred

  @override
  void initState() {
    super.initState();
    _userRoleController.addListener(_validateForm);
    _aiRoleController.addListener(_validateForm);
    _situationController.addListener(_validateForm);
    _hasNavigated = false; // Reset navigation flag when screen initializes
  }

  @override
  void dispose() {
    _userRoleController.dispose();
    _aiRoleController.dispose();
    _situationController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _userRoleController.text.isNotEmpty &&
        _aiRoleController.text.isNotEmpty &&
        _situationController.text.isNotEmpty;

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  void _createConversation() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ConversationBloc>().add(CreateConversationEvent(
            userRole: _userRoleController.text,
            aiRole: _aiRoleController.text,
            situation: _situationController.text,
          ));
    }
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.h3(context),
        ),
        const SizedBox(height: 8),
        AppTextInput(
          controller: controller,
          hintText: hint,
          maxLines: maxLines,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveLayout.getCardPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set up a role-play scenario to practice your English',
              style: TextStyles.body(context),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormField(
                        label: 'Your Role',
                        hint: 'e.g., Job applicant, Customer, Patient',
                        controller: _userRoleController,
                      ),
                      _buildFormField(
                        label: 'AI Role',
                        hint: 'e.g., Interviewer, Customer service, Doctor',
                        controller: _aiRoleController,
                      ),
                      _buildFormField(
                        label: 'Situation',
                        hint: 'Describe the context of this conversation',
                        controller: _situationController,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            PrimaryButton(
              text: 'Start Conversation',
              isFullWidth: true,
              onPressed: _isFormValid ? _createConversation : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveLayout.getCardPadding(context)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create a Conversation',
                    style: TextStyles.h1(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set up a role-play scenario to practice your English',
                    style: TextStyles.body(context),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Center(
                      child: Icon(
                        Icons.chat_bubble_outline,
                        size: 120,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 3,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormField(
                              label: 'Your Role',
                              hint: 'e.g., Job applicant, Customer, Patient',
                              controller: _userRoleController,
                            ),
                            _buildFormField(
                              label: 'AI Role',
                              hint:
                                  'e.g., Interviewer, Customer service, Doctor',
                              controller: _aiRoleController,
                            ),
                            _buildFormField(
                              label: 'Situation',
                              hint: 'Describe the context of this conversation',
                              controller: _situationController,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    PrimaryButton(
                      text: 'Start Conversation',
                      isFullWidth: true,
                      onPressed: _isFormValid ? _createConversation : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationBloc, ConversationState>(
      listenWhen: (previous, current) {
        // Only trigger listener when state changes FROM something else TO ConversationActive or ConversationCreationFailed
        // And prevent re-triggering when returning from another screen with the same state
        return (previous is! ConversationActive &&
                current is ConversationActive &&
                !_hasNavigated) ||
            (previous is! ConversationCreationFailed &&
                current is ConversationCreationFailed);
      },
      listener: (context, state) {
        if (state is ConversationActive &&
            state.conversation != null &&
            !_hasNavigated) {
          // Set the flag before doing anything to prevent multiple executions
          setState(() {
            _hasNavigated = true;
          });

          // Use smooth transition to prevent frame skipping
          SmoothTransitionManager.executeWithProperTiming(
            callback: () {
              if (context.mounted) {
                // Show success message and navigate in the callback to ensure proper timing
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Conversation created successfully!'),
                      backgroundColor: AppColors.success),
                );

                // Navigate directly to conversation screen instead of loading page
                context.push(
                  '/conversation/${state.conversation!.id}',
                  extra: state
                      .conversation!, // Pass the conversation object directly
                );
              }
            },
            isHeavyOperation: true, // Screen transitions are heavy operations
          );
        } else if (state is ConversationCreationFailed) {
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(state.errorMessage ?? 'Failed to create conversation'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Conversation'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (ResponsiveLayout.isLargeScreen(context)) {
                  return _buildLandscapeLayout(context);
                } else {
                  return _buildPortraitLayout(context);
                }
              },
            ),
            // Show loading overlay while creating conversation
            BlocBuilder<ConversationBloc, ConversationState>(
              builder: (context, state) {
                if (state is ConversationCreating) {
                  return Container(
                    color: Colors.black.withOpacity(0.3),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 20),
                          Text('Creating your conversation...'),
                        ],
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
  }
}
