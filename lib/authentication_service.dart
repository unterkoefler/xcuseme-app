import 'package:firebase_auth/firebase_auth.dart';
import 'package:xcuseme/firestore_service.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Stream<User> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<String> sendPasswordResetEmail({String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyMessage(e);
    }
  }

  Future<String> login({String email, String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyMessage(e);
    }
  }

  Future<String> signup(
      {String email,
      String password,
      String confirmPassword,
      bool agreedToTos}) async {
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    if (!agreedToTos) {
      return 'You must agree to the Terms and Conditions';
    }
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await FirestoreService()
          .createUserDocument(user: _firebaseAuth.currentUser, email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyMessage(e);
    }
  }

  String _friendlyMessage(FirebaseAuthException error) {
    print(error.code);
    switch (error.code) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
      case "account-exists-with-different-credential":
      case "email-already-in-use":
        return "Email already used. Please log in.";
      case "ERROR_WRONG_PASSWORD":
      case "wrong-password":
        return "Password is incorrect.";
      case "ERROR_USER_NOT_FOUND":
      case "user-not-found":
        return "No user found with this email. Please sign up.";
      case "ERROR_USER_DISABLED":
      case "user-disabled":
        return "User disabled.";
      case "ERROR_TOO_MANY_REQUESTS":
      case "operation-not-allowed":
        return "Too many requests to log into this account.";
      case 'weak-password':
        return 'Password is too weak';
      case "ERROR_OPERATION_NOT_ALLOWED":
      case "operation-not-allowed":
        return "Server error, please try again later.";
      case "ERROR_INVALID_EMAIL":
      case "invalid-email":
        return "Email address is invalid.";
      default:
        return "Login failed. Please try again.";
    }
  }
}
