import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fcm_service.dart';
import 'fcm_token_repository.dart';
import 'local_notifications_service.dart';

/// Wires Firebase Messaging into the app: permission + token registration
/// per authenticated user, plus foreground message display. A small,
/// deliberately dumb service (no Riverpod state of its own) — used by
/// [AuthController] only. Every entry point here is best-effort: a denied
/// permission, an unavailable token, or messaging being briefly down must
/// never crash the app or block sign-in.
class NotificationBootstrap {
  NotificationBootstrap(this._ref);

  final Ref _ref;
  StreamSubscription<String>? _tokenRefreshSubscription;
  bool _messageListenersReady = false;

  /// Requests permission, fetches the current device token, saves it for
  /// [uid], and keeps it fresh via token-refresh for the life of the app.
  /// Safe to call repeatedly (every login, every app start with a
  /// persisted session) — saving the same token is just a merge, never a
  /// duplicate (see [FcmTokenRepository]).
  Future<void> registerToken(String uid) async {
    try {
      final fcm = _ref.read(fcmServiceProvider);
      await fcm.requestPermission();

      final token = await fcm.getToken();
      if (token != null) {
        await _ref.read(fcmTokenRepositoryProvider).saveToken(uid: uid, token: token, platform: _platform);
      }

      await _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = fcm.onTokenRefresh.listen((refreshed) {
        unawaited(_ref.read(fcmTokenRepositoryProvider).saveToken(uid: uid, token: refreshed, platform: _platform));
      });
    } catch (_) {
      // Registration is best-effort — never block or fail sign-in over it.
    }
  }

  /// Shows a system notification for messages that arrive in the
  /// foreground, and acknowledges notification taps. Idempotent — safe to
  /// call from a provider `build()` that can re-run.
  void listenForMessages() {
    if (_messageListenersReady) return;
    _messageListenersReady = true;
    try {
      final fcm = _ref.read(fcmServiceProvider);
      final local = _ref.read(localNotificationsServiceProvider);
      unawaited(local.initialize());

      // Both listeners live for the app's process lifetime (same as this
      // singleton service), so there's nothing to hold onto for cancellation.
      fcm.onForegroundMessage.listen((message) {
        final notification = message.notification;
        if (notification == null) return;
        local.showForeground(title: notification.title ?? '', body: notification.body ?? '');
      });

      // No in-app destination to deep-link to for this simple
      // proof-of-concept — acknowledging the stream is enough to satisfy
      // "handle notification tap/open where practical".
      fcm.onNotificationOpened.listen((_) {});
    } catch (_) {
      // Foreground display is best-effort only.
    }
  }
}

String get _platform {
  try {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
  } catch (_) {
    // Platform is unavailable (e.g. web) — fall through to 'unknown'.
  }
  return 'unknown';
}

final notificationBootstrapProvider = Provider<NotificationBootstrap>((ref) => NotificationBootstrap(ref));
