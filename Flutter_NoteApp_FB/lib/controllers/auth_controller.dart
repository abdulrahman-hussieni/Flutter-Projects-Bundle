import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthController() {
    _initAuthListener();
  }

  // Initialize auth state listener
  void _initAuthListener() {
    _authService.authStateChanges.listen((User? user) {
      print('Auth state changed: ${user?.email ?? "No user"}');
      _currentUser = user;
      notifyListeners();
    });
  }

  // Sign up with email
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (!_validateSignUpInput(email, password, name)) {
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );

      _setLoading(false);

      if (result.success) {
        _currentUser = result.user;
        notifyListeners();
        print('Sign up successful');
        return true;
      } else {
        _errorMessage = result.errorMessage;
        notifyListeners();
        print('Sign up failed: ${result.errorMessage}');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'An unexpected error occurred. Please try again.';
      notifyListeners();
      print('Sign up error: $e');
      return false;
    }
  }

  // Sign in with email
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    if (!_validateSignInInput(email, password)) {
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      _setLoading(false);

      if (result.success) {
        _currentUser = result.user;
        notifyListeners();
        print('Sign in successful');
        return true;
      } else {
        _errorMessage = result.errorMessage;
        notifyListeners();
        print('Sign in failed: ${result.errorMessage}');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'An unexpected error occurred. Please try again.';
      notifyListeners();
      print('Sign in error: $e');
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.signInWithGoogle();

      _setLoading(false);

      if (result.success) {
        _currentUser = result.user;
        notifyListeners();
        print('Google sign in successful');
        return true;
      } else {
        _errorMessage = result.errorMessage;
        notifyListeners();
        print('Google sign in failed: ${result.errorMessage}');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'Failed to sign in with Google. Please try again.';
      notifyListeners();
      print('Google sign in error: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
      _currentUser = null;
      _setLoading(false);
      notifyListeners();
      print('Sign out successful');
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'Failed to sign out. Please try again.';
      notifyListeners();
      print('Sign out error: $e');
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      _errorMessage = 'Please enter your email address';
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(email)) {
      _errorMessage = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.resetPassword(email);

      _setLoading(false);

      if (result.success) {
        notifyListeners();
        print('Password reset email sent');
        return true;
      } else {
        _errorMessage = result.errorMessage;
        notifyListeners();
        print('Password reset failed: ${result.errorMessage}');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'Failed to send reset email. Please try again.';
      notifyListeners();
      print('Password reset error: $e');
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.deleteAccount();

      _setLoading(false);

      if (result.success) {
        _currentUser = null;
        notifyListeners();
        print('Account deleted successfully');
        return true;
      } else {
        _errorMessage = result.errorMessage;
        notifyListeners();
        print('Account deletion failed: ${result.errorMessage}');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'Failed to delete account. Please try again.';
      notifyListeners();
      print('Account deletion error: $e');
      return false;
    }
  }

  // Validation methods
  bool _validateSignUpInput(String email, String password, String name) {
    if (name.trim().isEmpty) {
      _errorMessage = 'Please enter your name';
      notifyListeners();
      return false;
    }

    if (email.trim().isEmpty) {
      _errorMessage = 'Please enter your email';
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(email)) {
      _errorMessage = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }

    if (password.isEmpty) {
      _errorMessage = 'Please enter a password';
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _errorMessage = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }

    return true;
  }

  bool _validateSignInInput(String email, String password) {
    if (email.trim().isEmpty) {
      _errorMessage = 'Please enter your email';
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(email)) {
      _errorMessage = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }

    if (password.isEmpty) {
      _errorMessage = 'Please enter your password';
      notifyListeners();
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Get user display name
  String get displayName {
    if (_currentUser?.displayName != null && _currentUser!.displayName!.isNotEmpty) {
      return _currentUser!.displayName!;
    }
    return _currentUser?.email?.split('@').first ?? 'User';
  }

  // Get user email
  String get userEmail => _currentUser?.email ?? '';
}