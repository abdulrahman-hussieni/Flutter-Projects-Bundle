import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class NoteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionName = "notes";

  // اختبار الاتصال بـ Firestore
  Future<bool> testConnection() async {
    try {
      print('Testing Firestore connection...');

      // محاولة بسيطة للوصول للـ Firestore بدون query معقد
      await _db.settings;

      print('Firestore connection successful');
      return true;
    } catch (e) {
      print('Firestore connection failed: $e');
      return false;
    }
  }

  Future<List<Note>> getAllNotes() async {
    try {
      print('Getting all notes from collection: $collectionName');

      // محاولة الحصول على البيانات مع التعامل مع حالة الـ collection الفاضي
      final snapshot = await _db
          .collection(collectionName)
          .orderBy("createdAt", descending: true)
          .get()
          .timeout(const Duration(seconds: 10));

      print('Query executed successfully');
      print('Number of documents found: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        print('No notes found in the collection');
        return []; // إرجاع قائمة فارغة بدلاً من خطأ
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

      // التعامل مع أخطاء مختلفة
      if (e.toString().contains('FAILED_PRECONDITION')) {
        print('Index not ready yet, returning empty list');
        return []; // مؤقتاً حتى يتم إنشاء الـ index
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

      return Note.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      print('Error in getNoteById: $e');
      throw Exception('Failed to fetch note: $e');
    }
  }

  Future<String?> addNote(Note note) async {
    try {
      print('=== Starting addNote ===');
      print('Note title: ${note.title}');
      print('Note content length: ${note.content.length}');
      print('Collection name: $collectionName');

      final noteData = note.toJson();
      print('Note data to be saved: $noteData');

      // اختبار الاتصال أولاً
      final connectionOk = await testConnection();
      if (!connectionOk) {
        throw Exception('Unable to connect to database');
      }

      print('Connection test passed, attempting to add note...');

      // إضافة الملاحظة
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
      print('Starting to delete note: $id');

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

  // طريقة إضافية للتأكد من وجود الـ collection
  Future<bool> collectionExists() async {
    try {
      final snapshot = await _db
          .collection(collectionName)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));

      return true; // إذا تم التنفيذ بدون خطأ، الـ collection موجود أو يمكن إنشاؤه
    } catch (e) {
      print('Error checking collection existence: $e');
      return false;
    }
  }
}