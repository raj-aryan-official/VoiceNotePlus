import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'note_model.dart';
import 'add_note_screen.dart';
import 'note_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _notesFuture;
  bool _showLikedOnly = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() {
    setState(() {
      _notesFuture = _getNotesList();
    });
  }

  Future<List<Map<String, dynamic>>> _getNotesList() async {
    if (_searchQuery.isNotEmpty) {
      return await DatabaseHelper().searchNotes(_searchQuery);
    }
    return await DatabaseHelper().getNotes(likedOnly: _showLikedOnly);
  }

  void _deleteNote(dynamic id) async {
    await DatabaseHelper().deleteNote(id);
    _refreshNotes();
  }

  void _toggleLike(dynamic id, bool currentLikeState) async {
    await DatabaseHelper().updateNoteLike(id, !currentLikeState);
    _refreshNotes();
  }

  void _showDeleteConfirmation(dynamic id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteNote(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFF44336))),
          ),
        ],
      ),
    );
  }

  void _showEditTagsDialog(dynamic id, String currentTags) {
    final controller = TextEditingController(text: currentTags);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tags'),
        content: SingleChildScrollView(
          child: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter tags separated by commas (e.g., work, important)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: const Color(0xFFE0F2F1),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              DatabaseHelper().updateNote(id, tags: controller.text);
              controller.dispose();
              Navigator.pop(context);
              _refreshNotes();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tags updated'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Notes Plus'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _refreshNotes();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by title, content, or tags...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF00695C)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _refreshNotes();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00897B)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showLikedOnly = false;
                            _searchQuery = '';
                            _searchController.clear();
                            _refreshNotes();
                          });
                        },
                        icon: const Icon(Icons.dashboard),
                        label: const Text('All Notes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !_showLikedOnly ? const Color(0xFF00695C) : const Color(0xFFE0E0E0),
                          foregroundColor: !_showLikedOnly ? Colors.white : Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showLikedOnly = true;
                            _searchQuery = '';
                            _searchController.clear();
                            _refreshNotes();
                          });
                        },
                        icon: const Icon(Icons.favorite),
                        label: const Text('Liked'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showLikedOnly ? const Color(0xFF26A69A) : const Color(0xFFE0E0E0),
                          foregroundColor: _showLikedOnly ? Colors.white : Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Notes List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _notesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showLikedOnly ? Icons.favorite_border : Icons.note_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showLikedOnly
                              ? 'No liked notes yet'
                              : _searchQuery.isNotEmpty
                                  ? 'No notes found'
                                  : 'No notes yet. Tap + to add one.',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final notes = snapshot.data!.map((e) => Note.fromMap(e)).toList();

                return ListView.builder(
                  itemCount: notes.length,
                  padding: const EdgeInsets.all(8.0),
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF9575CD),
                          child: Text(
                            note.title.isNotEmpty ? note.title[0].toUpperCase() : 'N',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          note.title.isNotEmpty ? note.title : 'Untitled Note',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              note.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            if (note.tags.isNotEmpty)
                              Wrap(
                                spacing: 4,
                                children: note.tags.split(',').map((tag) {
                                  return Chip(
                                    label: Text(tag.trim()),
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: const Color(0xFFE0BEE7),
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              note.dateTime,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: SizedBox(
                          width: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  note.isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: note.isLiked ? const Color(0xFFCE93D8) : Colors.grey,
                                ),
                                onPressed: () => _toggleLike(note.id, note.isLiked),
                                iconSize: 20,
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.label_outline, color: Color(0xFF9575CD)),
                                onPressed: () => _showEditTagsDialog(note.id, note.tags),
                                iconSize: 20,
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                tooltip: 'Edit tags',
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Color(0xFFEF9A9A)),
                                onPressed: () => _showDeleteConfirmation(note.id),
                                iconSize: 20,
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteDetailScreen(note: note),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_home',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          );
          _refreshNotes();
        },
        backgroundColor: const Color(0xFF9575CD),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
