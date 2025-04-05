// lib/widget/conversation/role_input_field.dart

import 'package:flutter/material.dart';

class RoleInputField extends StatelessWidget {
  final String label;
  final String hint;
  final Function(String) onChanged;

  const RoleInputField({
    Key? key,
    required this.label,
    required this.hint,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(),
      ),
      validator: (value) =>
          value?.isEmpty == true ? 'Please enter the $label' : null,
      onChanged: onChanged,
    );
  }
}