import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/buttons/primary_button.dart';
import '../../../../core/presentation/widgets/inputs/app_text_input.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';
import '../bloc/conversation_state.dart';
import 'conversation_screen.dart';

/// Screen for creating a new conversation
///
/// Allows the user to specify their role, the AI's role, and the situation
class CreateConversationScreen extends StatefulWidget {
  const CreateConversationScreen({Key? key}) : super(key: key);

  @override
  State<CreateConversationScreen> createState() => _CreateConversationScreenState();
}

class _CreateConversationScreenState extends State<CreateConversationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userRoleController = TextEditingController();
  final _aiRoleController = TextEditingController();
  final _situationController = TextEditingController();

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _userRoleController.addListener(_validateForm);
    _aiRoleController.addListener(_validateForm);
    _situationController.addListener(_validateForm);
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
      listener: (context, state) {
        if (state is ConversationActive) {
          // Navigate to the conversation screen when conversation is created
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ConversationScreen(
                conversation: state.conversation!,
              ),
            ),
          );
        } else if (state is ConversationCreationFailed) {
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to create conversation'),
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (ResponsiveLayout.isLargeScreen(context)) {
              return _buildLandscapeLayout(context);
            } else {
              return _buildPortraitLayout(context);
            }
          },
        ),
      ),
    );
  }
}
