import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays a system notification for FCM messages that arrive while the
/// app is in the foreground — Android/iOS only show the system tray
/// notification automatically when the app is backgrounded or terminated,
/// so this is what makes a foreground push visible at all. Best-effort
/// only: any failure here just means no visible banner, never a crash.
class LocalNotificationsService {
  static const _channelId = 'nawa_default_channel';
  static const _channelName = 'Nawa Notifications';

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      const settings = InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'));
      await _plugin.initialize(settings: settings);
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(_channelId, _channelName, importance: Importance.defaultImportance),
          );
      _initialized = true;
    } catch (_) {
      // Local display just won't work; nothing else depends on it.
    }
  }

  Future<void> showForeground({required String title, required String body}) async {
    if (!_initialized) return;
    try {
      await _plugin.show(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
      );
    } catch (_) {}
  }
}

final localNotificationsServiceProvider = Provider<LocalNotificationsService>((ref) => LocalNotificationsService());
