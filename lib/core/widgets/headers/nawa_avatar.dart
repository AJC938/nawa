import 'package:flutter/material.dart';

import '../../../app/theme/nawa_colors.dart';

/// Placeholder child avatar (initial on a brand-colored circle) until real
/// avatar illustrations are available.
class NawaAvatar extends StatelessWidget {
  const NawaAvatar({super.key, required this.name, this.radius = 32});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: NawaColors.primary.withValues(alpha: 0.15),
      child: Text(
        initial,
        style: TextStyle(color: NawaColors.primary, fontWeight: FontWeight.w700, fontSize: radius * 0.8),
      ),
    );
  }
}
