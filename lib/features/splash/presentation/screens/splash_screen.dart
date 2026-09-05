import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_colors.dart';
import '../../../../core/widgets/mascot/nawa_logo_mark.dart';

/// Nawa's branded moment between process start and the Welcome screen.
///
/// Firebase is already initialized by the time this widget mounts (awaited
/// in `main()` before `runApp`), so there's no real async work left to gate
/// on here — this is intentionally just a short, honest brand beat, not a
/// padded fake-loading delay.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _minDisplayTime = Duration(milliseconds: 550);

  @override
  void initState() {
    super.initState();
    Future.delayed(_minDisplayTime, () {
      if (mounted) context.go(RoutePaths.welcome);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: NawaColors.background,
      body: Center(child: NawaLogoMark()),
    );
  }
}
