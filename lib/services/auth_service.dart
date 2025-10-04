

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('Starting email sign up for: $email');

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name.trim());
      await userCredential.user?.reload();

      print('Sign up successful: ${userCredential.user?.uid}');

      return AuthResult(
        success: true,
        user: _auth.currentUser,
        message: 'Account created successfully',
      );
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        errorMessage: _getFirebaseAuthErrorMessage(e.code),
      );
    } catch (e) {
      print('Unexpected error during sign up: $e');
      return AuthResult(
        success: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('Starting email sign in for: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      print('Sign in successful: ${userCredential.user?.uid}');

      return AuthResult(
        success: true,
        user: userCredential.user,
        message: 'Signed in successfully',
      );
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        errorMessage: _getFirebaseAuthErrorMessage(e.code),
      );
    } catch (e) {
      print('Unexpected error during sign in: $e');
      return AuthResult(
        success: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  // Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      print('Starting Google sign in...');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Google sign in cancelled by user');
        return AuthResult(
          success: false,
          errorMessage: 'Sign in cancelled',
        );
      }

      print('Google user obtained: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in to Firebase with Google credentials...');

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      print('Google sign in successful: ${userCredential.user?.uid}');

      return AuthResult(
        success: true,
        user: userCredential.user,
        message: 'Signed in with Google successfully',
      );
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        errorMessage: _getFirebaseAuthErrorMessage(e.code),
      );
    } catch (e) {
      print('Unexpected error during Google sign in: $e');
      return AuthResult(
        success: false,
        errorMessage: 'Failed to sign in with Google. Please try again.',
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('Signing out user...');
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      print('Sign out successful');
    } catch (e) {
      print('Error during sign out: $e');
      rethrow;
    }
  }

  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      print('Sending password reset email to: $email');

      await _auth.sendPasswordResetEmail(email: email.trim());

      print('Password reset email sent');

      return AuthResult(
        success: true,
        message: 'Password reset email sent. Please check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        errorMessage: _getFirebaseAuthErrorMessage(e.code),
      );
    } catch (e) {
      print('Unexpected error during password reset: $e');
      return AuthResult(
        success: false,
        errorMessage: 'Failed to send reset email. Please try again.',
      );
    }
  }

  // Delete account
  Future<AuthResult> deleteAccount() async {
    try {
      print('Deleting user account...');

      await _auth.currentUser?.delete();

      print('Account deleted successfully');

      return AuthResult(
        success: true,
        message: 'Account deleted successfully',
      );
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error: ${e.code} - ${e.message}');

      if (e.code == 'requires-recent-login') {
        return AuthResult(
          success: false,
          errorMessage: 'Please sign in again before deleting your account.',
        );
      }

      return AuthResult(
        success: false,
        errorMessage: _getFirebaseAuthErrorMessage(e.code),
      );
    } catch (e) {
      print('Unexpected error during account deletion: $e');
      return AuthResult(
        success: false,
        errorMessage: 'Failed to delete account. Please try again.',
      );
    }
  }

  // Helper method to convert Firebase Auth error codes to user-friendly messages
  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

// Auth result class to handle responses
class AuthResult {
  final bool success;
  final User? user;
  final String? message;
  final String? errorMessage;

  AuthResult({
    required this.success,
    this.user,
    this.message,
    this.errorMessage,
  });
}