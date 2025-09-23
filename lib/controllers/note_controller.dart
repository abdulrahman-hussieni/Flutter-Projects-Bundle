import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/note_service.dart';

class NoteController extends ChangeNotifier {
  final NoteService _noteService = NoteService();

  List<Note> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFirebaseConnected = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFirebaseConnected => _isFirebaseConnected;

  Future<void> loadNotes() async {
    print('=== Starting loadNotes ===');

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

      print('Connection successful, loading notes...');
      _notes = await _noteService.getAllNotes();

      print('Successfully loaded ${_notes.length} notes');
      print('Notes loaded: ${_notes.map((n) => n.title).toList()}');

      _errorMessage = null;

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
    print('Content: "${content.substring(0, content.length > 50 ? 50 : content.length)}..."');

    if (title.trim().isEmpty || content.trim().isEmpty) {
      _errorMessage = 'Title and content cannot be empty';
      print('Validation failed: empty title or content');
      notifyListeners();
      return false;
    }

    // اختبار الاتصال قبل المحاولة
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
    } catch (e) {
      print('Connection test error: $e');
      _errorMessage = 'Database connection error. Please try again.';
      notifyListeners();
      return false;
    }

    try {
      _clearError();

      final note = Note(
        id: "",
        title: title.trim(),
        content: content.trim(),
        createdAt: DateTime.now(),
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
        );

        // إضافة الملاحظة للقائمة المحلية
        _notes.insert(0, savedNote);
        print('Note added to local list. Total notes: ${_notes.length}');

        // تنبيه جميع المستمعين للتغيير
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

    if (errorStr.contains('failed_precondition')) {
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
      );

      await _noteService.updateNote(updatedNote);
      print('Note updated successfully');

      // تحديث الملاحظة في القائمة المحلية
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

      // حذف الملاحظة من القائمة المحلية
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
    print('Refreshing notes...');
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

  // إضافة طريقة جديدة لإشعار المستمعين يدوياً إذا احتجنا لها
  void forceNotifyListeners() {
    notifyListeners();
  }
}