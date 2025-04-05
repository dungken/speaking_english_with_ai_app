// lib/widget/conversation/situation_form.dart

import 'package:flutter/material.dart';

class SituationForm extends StatefulWidget {
  final Function(String, String, String, String) onSubmit;

  SituationForm({required this.onSubmit});

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
        children: [
          RoleInputField(
            label: 'User Role',
            onChanged: (value) => _userRole = value,
          ),
          RoleInputField(
            label: 'AI Role',
            onChanged: (value) => _aiRole = value,
          ),
          // Add gender selection and situation input fields here
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmit(_userRole, _aiRole, _aiGender, _situation);
              }
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }
}