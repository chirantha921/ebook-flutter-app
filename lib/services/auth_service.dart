import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // Sign up with email and password
  Future<UserCredential> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getReadableErrorMessage(e.code));
    }
  }

  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getReadableErrorMessage(e.code));
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw AuthException('Google sign in aborted');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getReadableErrorMessage(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  // Sign out
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getReadableErrorMessage(e.code));
    }
  }

  // Update user profile
  Future<void> updateProfile(String displayName, {String? photoUrl}) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      if (photoUrl != null) {
        await _auth.currentUser?.updatePhotoURL(photoUrl);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getReadableErrorMessage(e.code));
    }
  }

  // Convert Firebase error codes to readable messages
  String _getReadableErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'Email already exists.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'too-many-requests':
        return 'Too many attempts, please try again later.';
      case 'user-not-found':
        return 'Email not found.';
      case 'wrong-password':
        return 'Invalid password.';
      case 'user-disabled':
        return 'User account has been disabled.';
      default:
        return 'Authentication failed: $errorCode';
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}