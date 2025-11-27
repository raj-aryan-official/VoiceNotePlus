import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'note_model.dart';
import 'database_helper.dart';

/// NoteDetailScreen - Detailed view and editing interface for a single voice note
/// Features:
///   - Display full note transcript with title, tags, and metadata
///   - Real-time sharing of note content via native share dialog
///   - Like/unlike toggle for marking favorites
///   - Edit note title, transcript, and tags inline
///   - Delete note with confirmation dialog
///   - Toggle between view and edit modes
///   - Back button that respects edit state (prevents accidental loss)
class NoteDetailScreen extends StatefulWidget {
  /// The Note object passed from HomeScreen or other navigation
  /// Contains all note data: ID, title, content, tags, like status, etc.
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

/// State class for NoteDetailScreen
/// Manages:
///   - View vs Edit mode toggling
///   - Text field controllers for title, content, and tags
///   - Like/unlike functionality with database persistence
///   - Note sharing via native share dialogs
///   - Note deletion with confirmation
///   - Saving edited content back to database
class _NoteDetailScreenState extends State<NoteDetailScreen> {
  // ====== STATE VARIABLES ======
  /// Current Note object being displayed/edited
  /// Updated when note data changes (like, edit, delete)
  late Note _note;
  
  /// Controller for the note title TextField
  /// Pre-populated with current title on init
  late TextEditingController _titleController;
  
  /// Controller for the transcript/content TextField
  /// Pre-populated with current content on init
  late TextEditingController _contentController;
  
  /// Controller for the tags TextField
  /// Pre-populated with comma-separated tags on init
  late TextEditingController _tagsController;
  
  /// Toggle flag for view vs edit mode
  /// true = edit mode (show editable fields, hide share/like buttons)
  /// false = view mode (show static display, show action buttons)
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Initialize note from widget parameter
    _note = widget.note;
    // Create text controllers pre-populated with current note data
    _titleController = TextEditingController(text: _note.title);
    _contentController = TextEditingController(text: _note.content);
    _tagsController = TextEditingController(text: _note.tags);
  }

  /// ====== CLEANUP ======
  /// Dispose of all TextEditingControllers to prevent memory leaks
  /// Called when widget is removed from widget tree
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  /// ====== SHARING FUNCTIONALITY ======
  /// Share the complete note transcript via native share dialog
  /// Flow:
  ///   1. Format note data (title, date, tags, content) into readable text
  ///   2. Call Share.share() from share_plus plugin
  ///   3. Shows OS-native share menu (email, messaging, notes, etc.)
  ///   4. User selects destination app to share to
  /// 
  /// Error Handling:
  ///   - Catches exceptions if share fails
  ///   - Shows red SnackBar with error message
  ///   - Checks mounted flag before showing UI (prevents crashes on unmount)
  void _shareTranscript() async {
    try {
      final text = '''
Title: ${_note.title.isNotEmpty ? _note.title : 'Untitled Note'}
Date: ${_note.dateTime}
Tags: ${_note.tags.isNotEmpty ? _note.tags : 'No tags'}

Transcript:
${_note.content}
      ''';
      
      await Share.share(text, subject: _note.title.isNotEmpty ? _note.title : 'Note Transcript');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: ${e.toString()}')),
        );
      }
    }
  }

  /// ====== LIKE/FAVORITE TOGGLE ======
  /// Toggle the like/favorite status of current note
  /// Updates database and UI with flipped like status
  /// Shows colored SnackBar: green for favorite, orange for unfavorite
  void _toggleLike() async {
    try {
      await DatabaseHelper().updateNoteLike(_note.id, !_note.isLiked);
      if (mounted) {
        setState(() {
          _note = Note(
            id: _note.id,
            title: _note.title,
            content: _note.content,
            dateTime: _note.dateTime,
            tags: _note.tags,
            isLiked: !_note.isLiked,
            recordingPath: _note.recordingPath,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_note.isLiked ? 'Added to favorites' : 'Removed from favorites'),
            backgroundColor: _note.isLiked ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }



  /// ====== DELETE NOTE WITH CONFIRMATION ======
  /// Show confirmation dialog before permanently deleting note
  /// Prevents accidental deletion by requiring explicit confirmation
  void _deleteNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await DatabaseHelper().deleteNote(_note.id);
                if (mounted) {
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Note deleted successfully'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFF44336))),
          ),
        ],
      ),
    );
  }

  /// ====== SAVE EDITED CHANGES ======
  /// Persist all edits (title, content, tags) back to database
  /// Updates database, refreshes UI, and returns to view mode
  void _saveChanges() async {
    try {
      await DatabaseHelper().updateNote(
        _note.id,
        title: _titleController.text,
        content: _contentController.text,
        tags: _tagsController.text,
      );

      setState(() {
        _note = Note(
          id: _note.id,
          title: _titleController.text,
          content: _contentController.text,
          dateTime: _note.dateTime,
          tags: _tagsController.text,
          isLiked: _note.isLiked,
          recordingPath: _note.recordingPath,
        );
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note updated successfully'),
              backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  /// ====== UI BUILD METHOD ======
  /// Main build method creating detail screen with view/edit modes
  /// WillPopScope handles back button to prevent accidental loss of edits
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isEditing) {
          _isEditing = false;
          setState(() {});
          return false;
        }
        return true;
      },
      child: Scaffold(
        // ====== APP BAR ======
        // Dynamic title based on editing state
        appBar: AppBar(
          title: _isEditing
              ? const Text('Edit Note')
              : Text(_note.title.isNotEmpty ? _note.title : 'Untitled Note'),
          elevation: 0,
          // Context-dependent action buttons
          actions: [
            // View mode buttons: share, like, edit, delete
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareTranscript,
                tooltip: 'Share transcript',
              ),
            if (!_isEditing)
              IconButton(
                icon: Icon(
                  _note.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _note.isLiked ? const Color(0xFF26A69A) : Colors.white,
                ),
                onPressed: _toggleLike,
              ),
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => setState(() => _isEditing = true),
              ),
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.delete),
                color: const Color(0xFFF44336),
                onPressed: _deleteNote,
              ),
            // Edit mode buttons: cancel, save
            if (_isEditing)
              TextButton(
                onPressed: () => setState(() => _isEditing = false),
                child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
            if (_isEditing)
              TextButton(
                onPressed: _saveChanges,
                child: const Text('Save', style: TextStyle(color: Color(0xFF4CAF50))),
              ),
          ],
        ),
        // ====== BODY ======
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ====== METADATA HEADER ======
              // Shows date and tags in light teal background
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2F1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date/time display
                    Text(
                      _note.dateTime,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    // Tags as chips (view mode only)
                    if (!_isEditing && _note.tags.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        children: _note.tags.split(',').map((tag) {
                          return Chip(
                            label: Text(tag.trim()),
                            backgroundColor: const Color(0xFFE0BEE7),
                            labelStyle: const TextStyle(fontSize: 12),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),

              // ====== CONTENT SECTION ======
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Edit mode: Title field
                    if (_isEditing)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Title',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: 'Enter title',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.all(12.0),
                              filled: true,
                              fillColor: const Color(0xFFE0F2F1),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    // Transcript header
                    const Text(
                      'Transcript',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Edit/View mode transcript
                    if (_isEditing)
                      TextField(
                        controller: _contentController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText: 'Edit transcript',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12.0),
                          filled: true,
                          fillColor: const Color(0xFFE0F2F1),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF00897B), width: 1),
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFE0F2F1),
                        ),
                        child: SelectableText(
                          _note.content,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                    const SizedBox(height: 24),
                    
                    // Edit mode: Tags field
                    if (_isEditing)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tags (comma-separated)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _tagsController,
                            decoration: InputDecoration(
                              hintText: 'e.g., important, work, personal',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.all(12.0),
                              filled: true,
                              fillColor: const Color(0xFFE0F2F1),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
