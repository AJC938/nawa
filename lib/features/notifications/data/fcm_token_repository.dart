import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stores the authenticated parent's FCM device token(s) under
/// `users/{uid}/fcmTokens/{token}` — never globally, never inside the
/// child profile. The token itself is the document id, so re-registering
/// the SAME token (e.g. on every app open) merges into the same document
/// instead of piling up duplicates; a parent with multiple devices simply
/// gets one document per distinct token.
abstract class FcmTokenRepository {
  Future<void> saveToken({required String uid, required String token, required String platform});
}

class FirestoreFcmTokenRepository implements FcmTokenRepository {
  FirestoreFcmTokenRepository([FirebaseFirestore? firestore]) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _tokens(String uid) =>
      _firestore.collection('users').doc(uid).collection('fcmTokens');

  @override
  Future<void> saveToken({required String uid, required String token, required String platform}) async {
    final doc = _tokens(uid).doc(token);
    final existing = await doc.get();
    await doc.set({
      'token': token,
      'platform': platform,
      'updatedAt': FieldValue.serverTimestamp(),
      if (!existing.exists) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

final fcmTokenRepositoryProvider = Provider<FcmTokenRepository>((ref) => FirestoreFcmTokenRepository());
