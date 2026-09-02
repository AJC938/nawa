import 'package:flutter/material.dart';

/// Temporary stub screen used by routes that don't have a real screen yet.
///
/// The next phase replaces each usage with the actual Nawa UI.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(label, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
