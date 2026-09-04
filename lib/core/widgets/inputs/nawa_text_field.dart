import 'package:flutter/material.dart';

/// Labeled text field matching the Nawa input style (label above, rounded
/// bordered field, optional trailing icon such as a password toggle).
class NawaTextField extends StatelessWidget {
  const NawaTextField({
    super.key,
    this.label,
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.errorText,
    this.autofillHints,
    this.onChanged,
  });

  final String? label;
  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? errorText;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Text(label!, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          onChanged: onChanged,
          decoration: InputDecoration(hintText: hint, suffixIcon: suffixIcon, errorText: errorText),
        ),
      ],
    );
  }
}
