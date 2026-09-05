import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Records small authenticated events under
/// `users/{uid}/notificationEvents/{eventId}` that a Cloud Function reacts
/// to by sending an FCM push — the Flutter app never sends notifications
/// itself. Each call creates exactly one new event document; callers are
/// responsible for calling this only from a genuine one-shot success point
/// (e.g. [AuthController.login]'s own success branch), never from a
/// listener that can fire more than once, so a single login can never
/// produce more than one event.
abstract class NotificationEventRepository {
  Future<void> recordLoginEvent(String uid);
}

class FirestoreNotificationEventRepository implements NotificationEventRepository {
  FirestoreNotificationEventRepository([FirebaseFirestore? firestore]) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> recordLoginEvent(String uid) async {
    await _firestore.collection('users').doc(uid).collection('notificationEvents').add({
      'type': 'login',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

final notificationEventRepositoryProvider = Provider<NotificationEventRepository>(
  (ref) => FirestoreNotificationEventRepository(),
);
