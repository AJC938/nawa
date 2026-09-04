import 'package:flutter/material.dart';

import '../../../app/theme/nawa_colors.dart';
import '../../../l10n/app_localizations.dart';

class NawaBottomNavItem {
  const NawaBottomNavItem({required this.icon, required this.activeIcon, required this.label});

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// The 4-tab primary navigation: Home, Explore, Profile, Parent.
class NawaBottomNav extends StatelessWidget {
  const NawaBottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static List<NawaBottomNavItem> items(AppLocalizations l10n) => [
        NawaBottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: l10n.navHome),
        NawaBottomNavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, label: l10n.navExplore),
        NawaBottomNavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: l10n.navProfile),
        NawaBottomNavItem(icon: Icons.groups_outlined, activeIcon: Icons.groups_rounded, label: l10n.navParent),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final navItems = items(l10n);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: NawaColors.surface,
        border: Border(top: BorderSide(color: NawaColors.border)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < navItems.length; i++)
                Expanded(
                  child: _NavButton(
                    item: navItems[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});

  final NawaBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? NawaColors.primary : NawaColors.textMuted;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? item.activeIcon : item.icon, color: color),
            const SizedBox(height: 4),
            Text(item.label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
