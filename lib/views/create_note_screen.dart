import 'package:flutter/material.dart';
import '../controllers/note_controller.dart';

class CreateNoteScreen extends StatefulWidget {
  final NoteController noteController;

  const CreateNoteScreen({
    super.key,
    required this.noteController,
  });

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Create Note',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20.0,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Note Title',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'Enter note title',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16.0,
                ),
                filled: true,
                fillColor: _isLoading ? Colors.grey[100] : Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.blue.shade300,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _contentFocusNode.requestFocus(),
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Content',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: TextField(
                controller: _contentController,
                focusNode: _contentFocusNode,
                enabled: !_isLoading,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: 'Enter note content',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16.0,
                  ),
                  filled: true,
                  fillColor: _isLoading ? Colors.grey[100] : Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Colors.blue.shade300,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16.0),
                  alignLabelWithHint: true,
                ),
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20.0,
                width: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text(
                'Save Note',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            OutlinedButton(
              onPressed: _isLoading
                  ? null
                  : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.grey),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Back to Notes',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveNote() async {
    // مسح أي أخطاء سابقة
    widget.noteController.clearError();

    // التحقق من صحة البيانات
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Please enter a note title', Colors.red);
      _titleFocusNode.requestFocus();
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      _showSnackBar('Please enter note content', Colors.red);
      _contentFocusNode.requestFocus();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('Attempting to save note...');
      print('Title: ${_titleController.text.trim()}');
      print('Content length: ${_contentController.text.trim().length}');

      final success = await widget.noteController.createNote(
        _titleController.text.trim(),
        _contentController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          _showSnackBar('Note saved successfully!', Colors.green);

          // تأخير قصير لإظهار الرسالة ثم العودة للشاشة الرئيسية
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            // العودة للشاشة السابقة مع تمرير true لتأكيد النجاح
            Navigator.of(context).pop(true);
          }
        } else {
          // عرض رسالة الخطأ من الـ controller
          final errorMessage = widget.noteController.errorMessage ??
              'Failed to save note. Please try again.';
          _showSnackBar(errorMessage, Colors.red);
          print('Failed to save note: $errorMessage');
        }
      }
    } catch (e) {
      print('Unexpected error in _saveNote: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = 'An unexpected error occurred.';

        if (e.toString().toLowerCase().contains('timeout')) {
          errorMessage = 'Save operation timed out. Please check your connection and try again.';
        } else if (e.toString().toLowerCase().contains('network')) {
          errorMessage = 'Network error. Please check your internet connection.';
        }

        _showSnackBar(errorMessage, Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 2), // تقليل المدة
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          margin: const EdgeInsets.all(16.0),
        ),
      );
    }
  }
}