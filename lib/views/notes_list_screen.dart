import 'package:flutter/material.dart';
import '../controllers/note_controller.dart';
import '../widgets/note_item.dart';
import 'create_note_screen.dart';
import 'note_details_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final NoteController _noteController = NoteController();

  @override
  void initState() {
    super.initState();
    // Fixed: properly await the init method
    _initController();
  }

  Future<void> _initController() async {
    try {
      await _noteController.init();
    } catch (e) {
      print('Error initializing controller: $e');
      // The error will be handled by the controller and shown in the UI
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToCreateNote(),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _noteController,
        builder: (context, child) {
          if (_noteController.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
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

          // Show error message if there's an error
          if (_noteController.errorMessage != null) {
            return _buildErrorState();
          }

          if (_noteController.notes.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await _noteController.loadNotes();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: _noteController.notes.length,
                itemBuilder: (context, index) {
                  final note = _noteController.notes[index];
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

  Widget _buildErrorState() {
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
              _noteController.errorMessage!,
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
              _noteController.clearError();
              await _noteController.loadNotes();
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
        builder: (context) => CreateNoteScreen(
          noteController: _noteController,
        ),
      ),
    );

    // Refresh the notes list when returning from create screen
    // This ensures newly created notes are visible
    if (mounted) {
      await _noteController.refreshNotes();
    }
  }

  void _navigateToNoteDetails(String noteId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteDetailsScreen(
          noteId: noteId,
          noteController: _noteController,
        ),
      ),
    );
  }

  Future<void> _deleteNote(String noteId) async {
    final success = await _noteController.deleteNote(noteId);
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