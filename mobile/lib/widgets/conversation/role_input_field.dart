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
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the $label';
        }
        return null;
      },
    );
  }
} 