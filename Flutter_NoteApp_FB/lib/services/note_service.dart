import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note.dart';

class NoteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String collectionName = "notes";

  // Test Firestore connection
  Future<bool> testConnection() async {
    try {
      print('Testing Firestore connection...');
      await _db.settings;
      print('Firestore connection successful');
      return true;
    } catch (e) {
      print('Firestore connection failed: $e');
      return false;
    }
  }

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  Future<List<Note>> getAllNotes() async {
    try {
      // Check if user is authenticated
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      print('Getting notes for user: $currentUserId');
      print('From collection: $collectionName');

      // Get notes filtered by userId
      final snapshot = await _db
          .collection(collectionName)
          .where('userId', isEqualTo: currentUserId)
          .orderBy("createdAt", descending: true)
          .get()
          .timeout(const Duration(seconds: 10));

      print('Query executed successfully');
      print('Number of documents found: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        print('No notes found for this user');
        return [];
      }

      final notes = snapshot.docs
          .map((doc) {
        try {
          return Note.fromJson({...doc.data(), 'id': doc.id});
        } catch (e) {
          print('Error parsing document ${doc.id}: $e');
          return null;
        }
      })
          .where((note) => note != null)
          .cast<Note>()
          .toList();

      print('Successfully parsed ${notes.length} notes');
      return notes;

    } catch (e) {
      print('Error in getAllNotes: $e');
      print('Error type: ${e.runtimeType}');

      if (e.toString().contains('FAILED_PRECONDITION')) {
        print('Index not ready yet, returning empty list');
        return [];
      } else if (e.toString().contains('PERMISSION_DENIED')) {
        throw Exception('Permission denied. Check your Firestore security rules.');
      } else if (e.toString().contains('UNAVAILABLE')) {
        throw Exception('Firestore service is temporarily unavailable. Please try again.');
      } else {
        throw Exception('Failed to fetch notes: ${e.toString()}');
      }
    }
  }

  Future<Note?> getNoteById(String id) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      print('Getting note by ID: $id');

      final doc = await _db
          .collection(collectionName)
          .doc(id)
          .get()
          .timeout(const Duration(seconds: 10));

      if (!doc.exists) {
        print('Note with ID $id not found');
        return null;
      }

      final note = Note.fromJson({...doc.data()!, 'id': doc.id});

      // Verify the note belongs to the current user
      if (note.userId != currentUserId) {
        print('Access denied: Note does not belong to current user');
        return null;
      }

      return note;
    } catch (e) {
      print('Error in getNoteById: $e');
      throw Exception('Failed to fetch note: $e');
    }
  }

  Future<String?> addNote(Note note) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      print('=== Starting addNote ===');
      print('Note title: ${note.title}');
      print('Note content length: ${note.content.length}');
      print('User ID: $currentUserId');
      print('Collection name: $collectionName');

      // Ensure the note has the correct userId
      final noteWithUserId = Note(
        id: note.id,
        title: note.title,
        content: note.content,
        createdAt: note.createdAt,
        userId: currentUserId!,
      );

      final noteData = noteWithUserId.toJson();
      print('Note data to be saved: $noteData');

      // Test connection first
      final connectionOk = await testConnection();
      if (!connectionOk) {
        throw Exception('Unable to connect to database');
      }

      print('Connection test passed, attempting to add note...');

      // Add the note
      final docRef = await _db
          .collection(collectionName)
          .add(noteData)
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('Add operation timed out after 15 seconds');
          throw Exception('Save operation timed out');
        },
      );

      print('Note added successfully with ID: ${docRef.id}');
      print('Document path: ${docRef.path}');
      print('=== addNote completed successfully ===');

      return docRef.id;
    } catch (e) {
      print('=== Error in addNote ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('=== End addNote error ===');

      rethrow;
    }
  }

  Future<void> updateNote(Note updatedNote) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Verify the note belongs to the current user
      if (updatedNote.userId != currentUserId) {
        throw Exception('Access denied: Cannot update note belonging to another user');
      }

      print('Starting to update note: ${updatedNote.id}');

      final noteData = updatedNote.toJson();
      print('Update data: $noteData');

      await _db
          .collection(collectionName)
          .doc(updatedNote.id)
          .update(noteData)
          .timeout(const Duration(seconds: 10));

      print('Note updated successfully');
    } catch (e) {
      print('Error in updateNote: $e');
      throw Exception('Failed to update note: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      print('Starting to delete note: $id');

      // First verify the note belongs to the current user
      final note = await getNoteById(id);
      if (note == null) {
        throw Exception('Note not found or access denied');
      }

      await _db
          .collection(collectionName)
          .doc(id)
          .delete()
          .timeout(const Duration(seconds: 10));

      print('Note deleted successfully');
    } catch (e) {
      print('Error in deleteNote: $e');
      throw Exception('Failed to delete note: $e');
    }
  }

  // Check if collection exists
  Future<bool> collectionExists() async {
    try {
      final snapshot = await _db
          .collection(collectionName)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));

      return true;
    } catch (e) {
      print('Error checking collection existence: $e');
      return false;
    }
  }
}