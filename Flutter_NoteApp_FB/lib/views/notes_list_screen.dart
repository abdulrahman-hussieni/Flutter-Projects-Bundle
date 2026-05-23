import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/note_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/note_item.dart';
import 'create_note_screen.dart';
import 'note_details_screen.dart';
import 'profile_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {

  @override
  void initState() {
    super.initState();
    print('=== NotesListScreen initState ===');
    // NoteController automatically loads notes via auth state listener
    // But we can trigger a load just to be sure
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final noteController = context.read<NoteController>();
      final authController = context.read<AuthController>();

      print('Current user: ${authController.currentUser?.uid}');
      print('Notes count: ${noteController.notes.length}');
      print('Is loading: ${noteController.isLoading}');

      // If notes are empty and not loading, trigger a load
      if (noteController.notes.isEmpty && !noteController.isLoading) {
        print('No notes found, triggering load...');
        noteController.loadNotes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Notes List',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20.0,
          ),
        ),
        centerTitle: true,
        leading: Consumer<AuthController>(
          builder: (context, authController, child) {
            return IconButton(
              icon: CircleAvatar(
                radius: 16.0,
                backgroundColor: const Color(0xFF00BCD4),
                child: authController.currentUser?.photoURL != null
                    ? ClipOval(
                  child: Image.network(
                    authController.currentUser!.photoURL!,
                    width: 32.0,
                    height: 32.0,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        authController.displayName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                )
                    : Text(
                  authController.displayName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              onPressed: () => _navigateToProfile(),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToCreateNote(),
          ),
        ],
      ),
      body: Consumer<NoteController>(
        builder: (context, noteController, child) {
          print('=== NotesListScreen Consumer Rebuilding ===');
          print('Notes count: ${noteController.notes.length}');
          print('Is loading: ${noteController.isLoading}');
          print('Error: ${noteController.errorMessage}');
          print('==========================================');

          if (noteController.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF00BCD4),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Loading notes...',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          if (noteController.errorMessage != null) {
            return _buildErrorState(noteController);
          }

          if (noteController.notes.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<NoteController>().loadNotes();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: noteController.notes.length,
                itemBuilder: (context, index) {
                  final note = noteController.notes[index];
                  return NoteItem(
                    note: note,
                    onTap: () => _navigateToNoteDetails(note.id),
                    onDelete: () => _deleteNote(note.id),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateNote(),
        backgroundColor: const Color(0xFF00BCD4),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 80.0,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16.0),
          Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Tap the + button to create your first note',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24.0),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateNote(),
            icon: const Icon(Icons.add),
            label: const Text('Create Note'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCD4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(NoteController noteController) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80.0,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16.0),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              noteController.errorMessage!,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24.0),
          ElevatedButton.icon(
            onPressed: () async {
              context.read<NoteController>().clearError();
              await context.read<NoteController>().loadNotes();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCD4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToCreateNote() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateNoteScreen(),
      ),
    );
  }

  void _navigateToNoteDetails(String noteId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteDetailsScreen(noteId: noteId),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  Future<void> _deleteNote(String noteId) async {
    final success = await context.read<NoteController>().deleteNote(noteId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Note deleted successfully' : 'Failed to delete note'),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}