import '../../../l10n/app_localizations.dart';

/// Friendly, UI-safe classification of an auth failure. Never exposes raw
/// Firebase exception text to the user.
enum AuthErrorCode {
  invalidCredential,
  invalidEmail,
  emailAlreadyInUse,
  weakPassword,
  userNotFound,
  wrongPassword,
  tooManyRequests,
  networkError,
  unknown,
}

/// Maps a `FirebaseAuthException.code` to a friendly [AuthErrorCode].
AuthErrorCode authErrorCodeFromFirebase(String code) {
  switch (code) {
    case 'invalid-credential':
      return AuthErrorCode.invalidCredential;
    case 'invalid-email':
      return AuthErrorCode.invalidEmail;
    case 'email-already-in-use':
      return AuthErrorCode.emailAlreadyInUse;
    case 'weak-password':
      return AuthErrorCode.weakPassword;
    case 'user-not-found':
      return AuthErrorCode.userNotFound;
    case 'wrong-password':
      return AuthErrorCode.wrongPassword;
    case 'too-many-requests':
      return AuthErrorCode.tooManyRequests;
    case 'network-request-failed':
      return AuthErrorCode.networkError;
    default:
      return AuthErrorCode.unknown;
  }
}

extension AuthErrorCodeX on AuthErrorCode {
  String message(AppLocalizations l10n) {
    switch (this) {
      case AuthErrorCode.invalidCredential:
      case AuthErrorCode.userNotFound:
      case AuthErrorCode.wrongPassword:
        return l10n.authErrorInvalidCredential;
      case AuthErrorCode.invalidEmail:
        return l10n.authErrorInvalidEmail;
      case AuthErrorCode.emailAlreadyInUse:
        return l10n.authErrorEmailInUse;
      case AuthErrorCode.weakPassword:
        return l10n.authErrorWeakPassword;
      case AuthErrorCode.tooManyRequests:
        return l10n.authErrorTooManyRequests;
      case AuthErrorCode.networkError:
        return l10n.authErrorNetwork;
      case AuthErrorCode.unknown:
        return l10n.authErrorGeneric;
    }
  }
}
