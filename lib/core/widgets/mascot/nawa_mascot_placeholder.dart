import 'package:flutter/material.dart';

import '../../../app/theme/nawa_colors.dart';

enum MascotMood { happy, celebrating, sad, sleepy }

/// Abstract stand-in for the approved Nawa mascot illustration.
///
/// `assets/branding/nawa_mascot.png` is not yet available (see
/// assets/branding/README.md). This widget is intentionally a simple,
/// neutral blob-with-eyes built from brand colors — it exists only to hold
/// the mascot's layout position on screen, not to invent a competing
/// character design. Swap it for `Image.asset('assets/branding/nawa_mascot.png')`
/// once the real asset is approved and added.
class NawaMascotPlaceholder extends StatelessWidget {
  const NawaMascotPlaceholder({super.key, this.size = 140, this.mood = MascotMood.happy});

  final double size;
  final MascotMood mood;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Nawa',
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [NawaColors.primary, NawaColors.accent],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Eye(size: size, mood: mood),
                    SizedBox(width: size * 0.14),
                    _Eye(size: size, mood: mood),
                  ],
                ),
                SizedBox(height: size * 0.08),
                _Mouth(size: size, mood: mood),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye({required this.size, required this.mood});

  final double size;
  final MascotMood mood;

  @override
  Widget build(BuildContext context) {
    final eyeSize = size * 0.22;
    if (mood == MascotMood.sleepy) {
      return Container(
        width: eyeSize,
        height: eyeSize * 0.25,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(eyeSize)),
      );
    }
    return Container(
      width: eyeSize,
      height: eyeSize,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      alignment: mood == MascotMood.sad ? Alignment.topCenter : Alignment.center,
      child: Container(
        width: eyeSize * 0.5,
        height: eyeSize * 0.5,
        decoration: const BoxDecoration(color: NawaColors.textPrimary, shape: BoxShape.circle),
      ),
    );
  }
}

class _Mouth extends StatelessWidget {
  const _Mouth({required this.size, required this.mood});

  final double size;
  final MascotMood mood;

  @override
  Widget build(BuildContext context) {
    final width = size * (mood == MascotMood.celebrating ? 0.34 : 0.22);
    final height = size * 0.1;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: mood == MascotMood.sad
            ? BorderRadius.vertical(top: Radius.circular(height))
            : BorderRadius.vertical(bottom: Radius.circular(height)),
      ),
    );
  }
}
