import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple local preference toggle for the Settings screen. Language uses
/// the shared [localeProvider] from core/localization instead of its own
/// provider, since locale is an app-wide concern.
final notificationsEnabledProvider = NotifierProvider<NotificationsPrefNotifier, bool>(NotificationsPrefNotifier.new);

class NotificationsPrefNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}
