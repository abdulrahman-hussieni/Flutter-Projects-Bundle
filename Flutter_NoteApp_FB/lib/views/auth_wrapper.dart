import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/note_controller.dart';
import 'login_screen.dart';
import 'notes_list_screen.dart';

/// Wrapper widget that determines whether to show login or home screen
class AuthWrapper extends StatelessWidget {
  final AuthController authController;

  const AuthWrapper({
    super.key,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authController,
      builder: (context, child) {
        final currentUser = authController.currentUser;

        print('=== AuthWrapper build ===');
        print('Current user: ${currentUser?.uid}');
        print('Is authenticated: ${authController.isAuthenticated}');
        print('Is loading: ${authController.isLoading}');

        // Show loading screen while checking auth state
        if (currentUser == null && authController.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00BCD4),
              ),
            ),
          );
        }

        // If user is authenticated, show notes list
        if (authController.isAuthenticated && currentUser != null) {
          print('User authenticated, showing NotesListScreen');
          // Clear notes when switching users
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final noteController = context.read<NoteController>();
            // Only clear if we have a different user or stale data
            if (noteController.currentUserId != currentUser.uid) {
              print('Clearing stale notes for different user');
              noteController.clearNotesOnLogout();
            }
          });

          return const NotesListScreen();
        }

        // Otherwise show login screen
        print('User not authenticated, showing LoginScreen');
        return LoginScreen(authController: authController);
      },
    );
  }
}