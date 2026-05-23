import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note.dart';
import '../services/note_service.dart';

class NoteController extends ChangeNotifier {
  final NoteService _noteService = NoteService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Note> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFirebaseConnected = false;
  String? _lastLoadedUserId; // Track which user's notes are currently loaded

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFirebaseConnected => _isFirebaseConnected;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  NoteController() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      print('=== Auth state changed in NoteController ===');
      print('New user: ${user?.uid}');
      print('Last loaded user: $_lastLoadedUserId');

      if (user == null) {
        // User signed out
        print('User signed out, clearing notes');
        _notes = [];
        _lastLoadedUserId = null;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
      } else if (_lastLoadedUserId != user.uid) {
        // Different user signed in
        print('Different user detected, clearing old notes');
        _notes = [];
        _lastLoadedUserId = user.uid;
        _errorMessage = null;
        notifyListeners();
        // Load new user's notes automatically
        loadNotes();
      }
    });
  }

  Future<void> loadNotes() async {
    print('=== Starting loadNotes ===');

    // Check if user is authenticated
    if (currentUserId == null) {
      print('No user authenticated, cannot load notes');
      _notes = [];
      _lastLoadedUserId = null;
      notifyListeners();
      return;
    }

    // Check if we're already loading notes for this user
    if (_lastLoadedUserId == currentUserId && _isLoading) {
      print('Already loading notes for this user, skipping...');
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Testing Firebase connection...');
      _isFirebaseConnected = await _noteService.testConnection();
      print('Firebase connection status: $_isFirebaseConnected');

      if (!_isFirebaseConnected) {
        throw Exception('Unable to connect to Firebase. Please check your internet connection.');
      }

      print('Loading notes for user: $currentUserId');
      final loadedNotes = await _noteService.getAllNotes();

      print('Successfully loaded ${loadedNotes.length} notes');
      if (loadedNotes.isNotEmpty) {
        print('First note: ${loadedNotes.first.title}');
        print('Notes user IDs: ${loadedNotes.map((n) => n.userId).toSet()}');
      }

      // Update state
      _notes = loadedNotes;
      _lastLoadedUserId = currentUserId;
      _errorMessage = null;

      print('Notes updated in controller. Count: ${_notes.length}');

    } catch (e) {
      print('=== Error in loadNotes ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');

      _errorMessage = _getErrorMessage(e);
      _notes = [];
      _isFirebaseConnected = false;

      print('Set error message: $_errorMessage');
    }

    _isLoading = false;
    notifyListeners();
    print('=== loadNotes completed ===');
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      print('Note with ID $id not found');
      return null;
    }
  }

  Future<bool> createNote(String title, String content) async {
    print('=== Starting createNote ===');
    print('Title: "$title"');
    print('Content length: ${content.length}');

    if (title.trim().isEmpty || content.trim().isEmpty) {
      _errorMessage = 'Title and content cannot be empty';
      print('Validation failed: empty title or content');
      notifyListeners();
      return false;
    }

    if (currentUserId == null) {
      _errorMessage = 'User not authenticated. Please sign in again.';
      print('Error: No authenticated user');
      notifyListeners();
      return false;
    }

    try {
      print('Testing connection before creating note...');
      _isFirebaseConnected = await _noteService.testConnection();

      if (!_isFirebaseConnected) {
        _errorMessage = 'Unable to connect to database. Please check your internet connection.';
        print('Connection test failed');
        notifyListeners();
        return false;
      }

      print('Connection test passed, proceeding with note creation...');
      _clearError();

      final note = Note(
        id: "",
        title: title.trim(),
        content: content.trim(),
        createdAt: DateTime.now(),
        userId: currentUserId!,
      );

      print('Calling _noteService.addNote...');
      final documentId = await _noteService.addNote(note);
      print('addNote returned: $documentId');

      if (documentId != null && documentId.isNotEmpty) {
        print('Note created successfully with ID: $documentId');

        final savedNote = Note(
          id: documentId,
          title: note.title,
          content: note.content,
          createdAt: note.createdAt,
          userId: note.userId,
        );

        _notes.insert(0, savedNote);
        print('Note added to local list. Total notes: ${_notes.length}');

        notifyListeners();

        print('=== createNote completed successfully ===');
        return true;
      } else {
        print('addNote returned null or empty ID');
        _errorMessage = 'Failed to save note: Invalid response from server';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('=== Error in createNote ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');

      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    print('Processing error: $errorStr');

    if (errorStr.contains('not authenticated')) {
      return 'Please sign in to create notes.';
    } else if (errorStr.contains('failed_precondition')) {
      return 'Database is being set up. This may take a few moments. Please try again.';
    } else if (errorStr.contains('permission_denied') || errorStr.contains('permission denied')) {
      return 'Permission denied. Please check your database configuration.';
    } else if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
      return 'Operation timed out. Please check your internet connection and try again.';
    } else if (errorStr.contains('network') || errorStr.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorStr.contains('unavailable')) {
      return 'Database service is temporarily unavailable. Please try again later.';
    } else if (errorStr.contains('firebase') || errorStr.contains('firestore')) {
      return 'Database error. Please try again later.';
    } else if (errorStr.contains('unable to connect')) {
      return 'Unable to connect to database. Please check your internet connection.';
    } else {
      return 'Unable to load notes. Please check your internet connection and try again.';
    }
  }

  Future<bool> updateNote(String id, String title, String content) async {
    if (title.trim().isEmpty || content.trim().isEmpty) {
      _errorMessage = 'Title and content cannot be empty';
      notifyListeners();
      return false;
    }

    try {
      final originalNote = getNoteById(id);
      if (originalNote == null) {
        _errorMessage = 'Note not found';
        notifyListeners();
        return false;
      }

      print('Updating note: $id');
      _clearError();

      final updatedNote = Note(
        id: id,
        title: title.trim(),
        content: content.trim(),
        createdAt: originalNote.createdAt,
        userId: originalNote.userId,
      );

      await _noteService.updateNote(updatedNote);
      print('Note updated successfully');

      final noteIndex = _notes.indexWhere((note) => note.id == id);
      if (noteIndex != -1) {
        _notes[noteIndex] = updatedNote;
        notifyListeners();
      }

      return true;
    } catch (e) {
      print('Error updating note: $e');
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNote(String id) async {
    try {
      print('Deleting note: $id');
      _clearError();

      await _noteService.deleteNote(id);
      print('Note deleted successfully');

      _notes.removeWhere((note) => note.id == id);
      notifyListeners();

      return true;
    } catch (e) {
      print('Error deleting note: $e');
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshNotes() async {
    print('=== Refreshing notes... ===');
    await loadNotes();
  }

  void clearError() {
    _clearError();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
      print('Error message cleared');
    }
  }

  Future<void> init() async {
    print('Initializing NoteController...');
    await loadNotes();
  }

  void clearNotesOnLogout() {
    print('=== Clearing notes on logout ===');
    _notes = [];
    _errorMessage = null;
    _isLoading = false;
    _isFirebaseConnected = false;
    _lastLoadedUserId = null;
    notifyListeners();
    print('Notes cleared. Current count: ${_notes.length}');
  }
}