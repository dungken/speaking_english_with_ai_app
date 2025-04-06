import 'package:flutter/material.dart';
import 'role_input_field.dart';

class SituationForm extends StatefulWidget {
  final Function(String, String, String) onSubmit;

  const SituationForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _SituationFormState createState() => _SituationFormState();
}

class _SituationFormState extends State<SituationForm> {
  final _formKey = GlobalKey<FormState>();
  String _userRole = '';
  String _aiRole = '';
  String _situation = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoleInputField(
            label: 'Your Role',
            hint: 'e.g., Student',
            onChanged: (value) => _userRole = value,
          ),
          const SizedBox(height: 16),
          RoleInputField(
            label: 'AI Role',
            hint: 'e.g., Teacher',
            onChanged: (value) => _aiRole = value,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Situation',
              hintText: 'Describe the conversation scenario',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) => _situation = value,
            validator: (value) =>
                value?.isEmpty == true ? 'Please describe the situation' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() == true) {
                widget.onSubmit(_userRole, _aiRole, _situation);
              }
            },
            child: const Text('Create Conversation'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
