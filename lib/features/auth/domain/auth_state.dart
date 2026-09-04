import 'package:firebase_auth/firebase_auth.dart' show User;

import 'auth_error_code.dart';

enum AuthStatus { loggedOut, loggingIn, authenticated, error }

class AuthState {
  const AuthState({this.status = AuthStatus.loggedOut, this.user, this.errorCode});

  final AuthStatus status;

  /// The authenticated Firebase user, when [status] is [AuthStatus.authenticated].
  final User? user;
  final AuthErrorCode? errorCode;
}
