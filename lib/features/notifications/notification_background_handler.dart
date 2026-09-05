import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../firebase_options.dart';

/// Registered via [FirebaseMessaging.onBackgroundMessage] in `main()`.
/// FCM requires a top-level (or static) function for this, run in its own
/// background isolate — Firebase isn't already initialized there, so it
/// must be done again here before touching anything Firebase-related.
///
/// There is nothing else to do: Android/iOS already display the system
/// notification for a background/terminated message on their own. This
/// handler exists only because FCM requires one to be registered.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
