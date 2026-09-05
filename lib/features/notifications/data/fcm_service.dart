import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thin wrapper over [FirebaseMessaging] so the rest of the app never
/// touches it directly, and every call is defensively wrapped — permission
/// being denied, the token being unavailable, or messaging being
/// temporarily down must never crash the app or block sign-in.
class FcmService {
  FcmService([FirebaseMessaging? messaging]) : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  /// Requests notification permission. Safe to call even where permission
  /// prompts aren't supported (e.g. already granted/denied platforms) —
  /// failures are swallowed since a denied/unavailable permission is a
  /// normal, non-fatal outcome for this simple proof-of-concept.
  Future<void> requestPermission() async {
    try {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
    } catch (_) {
      // Notifications simply won't show; nothing else in the app depends on this.
    }
  }

  /// The current device token, or null if unavailable for any reason.
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  Stream<RemoteMessage> get onForegroundMessage => FirebaseMessaging.onMessage;

  Stream<RemoteMessage> get onNotificationOpened => FirebaseMessaging.onMessageOpenedApp;
}

final fcmServiceProvider = Provider<FcmService>((ref) => FcmService());
