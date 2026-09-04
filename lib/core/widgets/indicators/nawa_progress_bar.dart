import 'package:flutter/material.dart';

import '../../../app/theme/nawa_colors.dart';
import '../../../app/theme/nawa_radius.dart';

/// Thin rounded progress bar used for experience-session progress and
/// interest-level bars.
class NawaProgressBar extends StatelessWidget {
  const NawaProgressBar({super.key, required this.value, this.color = NawaColors.primary, this.height = 8});

  /// 0.0 - 1.0
  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(NawaRadius.pill),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(height: height, color: NawaColors.border),
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                height: height,
                width: constraints.maxWidth * value.clamp(0, 1),
                color: color,
              ),
            ],
          );
        },
      ),
    );
  }
}
