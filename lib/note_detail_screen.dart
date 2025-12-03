import 'package:flutter/material.dart';
import 'note_model.dart';
import 'database_helper.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late Note _note;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _titleController = TextEditingController(text: _note.title);
    _contentController = TextEditingController(text: _note.content);
    _tagsController = TextEditingController(text: _note.tags);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

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
            backgroundColor: _note.isLiked ? const Color(0xFFA5D6A7) : const Color(0xFFFFE082),
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

  void _deleteRecording() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recording'),
        content: const Text('Are you sure you want to delete the recording? The note will still be kept.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _note = Note(
                  id: _note.id,
                  title: _note.title,
                  content: _note.content,
                  dateTime: _note.dateTime,
                  tags: _note.tags,
                  isLiked: _note.isLiked,
                  recordingPath: '',
                );
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Recording deleted'),
                  backgroundColor: Color(0xFFA5D6A7),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF9A9A))),
          ),
        ],
      ),
    );
  }

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
                      backgroundColor: Color(0xFFA5D6A7),
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
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF9A9A))),
          ),
        ],
      ),
    );
  }

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
            backgroundColor: Color(0xFFA5D6A7),
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
        appBar: AppBar(
          title: _isEditing
              ? const Text('Edit Note')
              : Text(_note.title.isNotEmpty ? _note.title : 'Untitled Note'),
          elevation: 0,
          actions: [
            if (!_isEditing)
              IconButton(
                icon: Icon(
                  _note.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _note.isLiked ? const Color(0xFFCE93D8) : Colors.white,
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
                color: const Color(0xFFEF9A9A),
                onPressed: _deleteNote,
              ),
            if (_isEditing)
              TextButton(
                onPressed: () => setState(() => _isEditing = false),
                child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
            if (_isEditing)
              TextButton(
                onPressed: _saveChanges,
                child: const Text('Save', style: TextStyle(color: Color(0xFFA5D6A7))),
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and tags
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3E5F5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _note.dateTime,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
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

              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              fillColor: const Color(0xFFF3E5F5),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    const Text(
                      'Transcript',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                          fillColor: const Color(0xFFF3E5F5),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFB39DDB), width: 1),
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFF3E5F5),
                        ),
                        child: SelectableText(
                          _note.content,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                    const SizedBox(height: 24),
                    
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
                              fillColor: const Color(0xFFF3E5F5),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    
                    // Recording Section
                    if (_note.recordingPath.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recording',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFB39DDB)),
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFFF3E5F5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(Icons.audio_file, color: Color(0xFF9575CD)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _note.recordingPath.split('/').last,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Color(0xFFEF9A9A)),
                                  onPressed: _deleteRecording,
                                ),
                              ],
                            ),
                          ),
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
