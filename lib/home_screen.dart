import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'note_model.dart';
import 'add_note_screen.dart';
import 'note_detail_screen.dart';

/// HomeScreen - Main dashboard showing all user voice notes
/// Features:
///   - Display list of recorded voice notes with titles, previews, and metadata
///   - Real-time search across note titles, content, and tags
///   - Filter notes by liked status for quick access to favorites
///   - Edit tags, like/unlike, and delete individual notes
///   - Navigate to note details or create new notes
///   - Pull-to-refresh or auto-refresh after adding/editing notes
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State class for HomeScreen
/// Manages:
///   - Notes list loading and caching via FutureBuilder
///   - Search query state and filtering logic
///   - Like/unlike toggle functionality
///   - Note deletion with confirmation dialog
///   - Tag editing dialog and persistence
///   - UI refresh when data changes
class _HomeScreenState extends State<HomeScreen> {
  // ====== STATE VARIABLES ======
  /// Future that loads notes from database based on current filter/search
  /// Rebuilds when _refreshNotes() is called
  late Future<List<Map<String, dynamic>>> _notesFuture;
  
  /// Filter flag: true = show only liked notes, false = show all notes
  /// User-controlled via "Liked" button in filter row
  bool _showLikedOnly = false;
  
  /// Current search query from user input
  /// Empty string means no search filtering (show all/liked)
  String _searchQuery = '';
  
  /// Controller for search TextField
  /// Allows clearing search and listening to text changes
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load initial notes list when screen first builds
    _refreshNotes();
  }

  /// ====== DATA LOADING METHODS ======
  /// Refresh the notes list by triggering FutureBuilder to reload data
  /// Called when:
  ///   - User applies/changes filter (Liked vs All)
  ///   - User performs search
  ///   - User clears search
  ///   - User returns from adding/editing note
  ///   - User deletes a note
  /// This rebuilds _notesFuture which triggers FutureBuilder rebuild
  void _refreshNotes() {
    setState(() {
      _notesFuture = _getNotesList();
    });
  }

  /// ====== DATABASE QUERY LOGIC ======
  /// Fetch notes from database with applied filters
  /// FILTERING PRIORITY:
  ///   1. If search query exists: Search database across title, content, tags
  ///      Returns only notes matching search terms
  ///   2. If no search: Apply liked-only filter if enabled
  ///      Returns all notes or only liked notes based on _showLikedOnly flag
  /// 
  /// RETURN VALUE: List of note maps from Hive database
  /// Empty list if no matches found (shows "No notes" message)
  Future<List<Map<String, dynamic>>> _getNotesList() async {
    if (_searchQuery.isNotEmpty) {
      // Search mode: ignore liked-only filter, search all notes
      return await DatabaseHelper().searchNotes(_searchQuery);
    }
    // Filter mode: get all or liked only based on flag
    return await DatabaseHelper().getNotes(likedOnly: _showLikedOnly);
  }

  /// ====== NOTE MODIFICATION METHODS ======
  /// Delete a note by ID from database and refresh UI
  /// Parameters:
  ///   - id: Unique identifier of the note to delete
  /// Flow:
  ///   1. Call DatabaseHelper.deleteNote(id) to remove from Hive
  ///   2. Call _refreshNotes() to reload list
  ///   3. FutureBuilder rebuilds showing updated list
  /// Note: Deletion is immediate without showing confirmation here
  ///       (confirmation happens in _showDeleteConfirmation before calling)
  void _deleteNote(dynamic id) async {
    await DatabaseHelper().deleteNote(id);
    // Refresh UI to reflect deletion
    _refreshNotes();
  }

  /// Toggle like/unlike status for a note
  /// Parameters:
  ///   - id: Unique identifier of the note
  ///   - currentLikeState: Boolean indicating current like status
  /// Logic:
  ///   - Flips current like state to opposite value
  ///   - Example: If liked=true, becomes liked=false (unlike)
  ///   - Persists to database via DatabaseHelper.updateNoteLike()
  ///   - Refreshes UI to show updated like icon and status
  /// UI Changes:
  ///   - Heart icon changes: filled (liked) ↔ outline (not liked)
  ///   - Color changes: pink/purple (liked) ↔ grey (not liked)
  void _toggleLike(dynamic id, bool currentLikeState) async {
    // Update database with opposite like state
    await DatabaseHelper().updateNoteLike(id, !currentLikeState);
    // Refresh list to show updated like status
    _refreshNotes();
  }

  /// ====== DIALOG & CONFIRMATION METHODS ======
  /// Show confirmation dialog before deleting a note
  /// Prevents accidental deletion by requiring explicit confirmation
  /// 
  /// Dialog Layout:
  ///   - Title: "Delete Note"
  ///   - Message: Confirmation question
  ///   - Actions: Cancel button (grey) and Delete button (red)
  ///
  /// Button Behavior:
  ///   - Cancel: Closes dialog without action
  ///   - Delete: Calls _deleteNote(id) then closes dialog
  ///   
  /// Visual Design:
  ///   - Delete button colored RED (#F44336) to indicate destructive action
  ///   - Modal dialog blocks interaction with list until action taken
  void _showDeleteConfirmation(dynamic id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          // CANCEL button - closes dialog without deleting
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          // DELETE button - red color warns of destructive action
          TextButton(
            onPressed: () {
              _deleteNote(id);  // Perform deletion
              Navigator.pop(context);  // Close dialog
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFF44336))),
          ),
        ],
      ),
    );
  }

  /// ====== TAG EDITING DIALOG ======
  /// Show dialog to edit tags for a specific note
  /// Parameters:
  ///   - id: Unique identifier of the note to edit
  ///   - currentTags: Current comma-separated tags string
  /// 
  /// Dialog Workflow:
  ///   1. TextField pre-populated with current tags
  ///   2. User can add, remove, or modify tags
  ///   3. Tags format: comma-separated strings (e.g., "work, meeting, urgent")
  ///   4. Cancel button discards changes and closes
  ///   5. Save button:
  ///      - Updates database via DatabaseHelper.updateNote()
  ///      - Shows green success SnackBar
  ///      - Refreshes note list to show updated tags
  ///      - Closes dialog
  ///
  /// UI Styling:
  ///   - Light teal background (#E0F2F1) matching app theme
  ///   - Rounded borders for modern appearance
  ///   - Scrollable content for long tag lists
  ///   - Clear hint text explaining comma-separated format
  void _showEditTagsDialog(dynamic id, String currentTags) {
    final controller = TextEditingController(text: currentTags);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tags'),
        content: SingleChildScrollView(
          child: TextField(
            controller: controller,
            maxLines: 3,  // Allow up to 3 lines for multiple tags
            decoration: InputDecoration(
              hintText: 'Enter tags separated by commas (e.g., work, important)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: const Color(0xFFE0F2F1),  // Light teal background
            ),
          ),
        ),
        actions: [
          // CANCEL button - discards changes
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          // SAVE button - persists tag changes
          TextButton(
            onPressed: () {
              // Update database with new tags
              DatabaseHelper().updateNote(id, tags: controller.text);
              controller.dispose();
              Navigator.pop(context);  // Close dialog
              _refreshNotes();  // Reload list to show updated tags
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tags updated'),
                  backgroundColor: Color(0xFF4CAF50),  // Green success color
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// ====== UI BUILD METHOD ======
  /// Main build method that creates the home screen layout
  /// Consists of:
  ///   1. AppBar with title
  ///   2. Search and filter section (Container with controls)
  ///   3. Notes list area (FutureBuilder for async data loading)
  ///   4. Floating action button for adding new notes
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar - Top navigation bar with title
      appBar: AppBar(
        title: const Text('Voice Notes Plus'),
        centerTitle: true,
        elevation: 0,  // No shadow for flat design
      ),
      // Main content - Column with search, filter, and list
      body: Column(
        children: [
          // ====== SEARCH & FILTER SECTION ======
          // Header area containing search field and filter buttons
          // Light teal background (#E0F2F1) separates it from note list
          // Sticky position allows scrolling through notes while keeping search visible
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),  // Light teal background
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
                // ====== SEARCH TEXTFIELD ======
                // Real-time search across note titles, content, and tags
                // Features:
                //   - Teal border (#00897B) matching app theme
                //   - Search icon on left for visual clarity
                //   - Clear (X) button on right to quickly reset search
                // Behavior:
                //   - On text change: updates _searchQuery and refreshes notes list
                //   - Filters shown notes to matches only (ignores like-only filter when searching)
                //   - Clear button: resets search field and shows all/liked notes again
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;  // Store search query
                      _refreshNotes();  // Reload list with search filter applied
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by title, content, or tags...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF00695C)),
                    // Show clear button only when search is active
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';  // Clear search
                                _refreshNotes();  // Show all/liked notes again
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
                
                // ====== FILTER BUTTONS ROW ======
                // Two toggle buttons for filtering notes
                // "All Notes" - show all notes (highlighted when active)
                // "Liked" - show only liked/favorited notes
                // Only one filter active at a time (mutual exclusivity)
                // When search is active, filters are bypassed (search takes priority)
                Row(
                  children: [
                    // "ALL NOTES" BUTTON - Shows all notes regardless of like status
                    // Color: TEAL (#00695C) when active, grey when inactive
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showLikedOnly = false;  // Disable like-only filter
                            _searchQuery = '';  // Clear any active search
                            _searchController.clear();
                            _refreshNotes();  // Reload showing all notes
                          });
                        },
                        icon: const Icon(Icons.dashboard),
                        label: const Text('All Notes'),
                        style: ElevatedButton.styleFrom(
                          // Active color (teal) when _showLikedOnly is false
                          backgroundColor: !_showLikedOnly ? const Color(0xFF00695C) : const Color(0xFFE0E0E0),
                          foregroundColor: !_showLikedOnly ? Colors.white : Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // "LIKED" BUTTON - Shows only favorited notes
                    // Color: Teal variant (#26A69A) when active, grey when inactive
                    // Heart icon indicates favorites/likes functionality
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showLikedOnly = true;  // Enable like-only filter
                            _searchQuery = '';  // Clear any active search
                            _searchController.clear();
                            _refreshNotes();  // Reload showing only liked notes
                          });
                        },
                        icon: const Icon(Icons.favorite),
                        label: const Text('Liked'),
                        style: ElevatedButton.styleFrom(
                          // Active color (teal variant) when _showLikedOnly is true
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
          // ====== NOTES LIST SECTION ======
          // Displays all notes using async FutureBuilder pattern
          // Handles loading, error, and empty states gracefully
          // Each note shown as a Material Card with swipe-friendly ListTile
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _notesFuture,  // Future that loads notes with current filter
              builder: (context, snapshot) {
                // ====== LOADING STATE ======
                // Show spinner while data is being fetched from database
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } 
                // ====== ERROR STATE ======
                // Display error message if database query fails
                else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } 
                // ====== EMPTY STATE ======
                // Show friendly message when no notes exist
                // Message varies based on current filter:
                //   - "No liked notes yet" if filtering by likes but none found
                //   - "No notes found" if search returned no results
                //   - "No notes yet..." if database is completely empty
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon changes based on state (heart for liked, note for all)
                        Icon(
                          _showLikedOnly ? Icons.favorite_border : Icons.note_outlined,
                          size: 64,
                          color: Colors.grey[300],  // Light grey for subtle appearance
                        ),
                        const SizedBox(height: 16),
                        // Dynamic message text based on current filter/search
                        Text(
                          _showLikedOnly
                              ? 'No liked notes yet'  // Showing liked filter but none liked
                              : _searchQuery.isNotEmpty
                                  ? 'No notes found'  // Search query matched nothing
                                  : 'No notes yet. Tap + to add one.',  // Database completely empty
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // ====== NOTES LOADED STATE ======
                // Convert raw database maps to Note objects for type safety
                final notes = snapshot.data!.map((e) => Note.fromMap(e)).toList();

                // Build scrollable list of note cards
                return ListView.builder(
                  itemCount: notes.length,
                  padding: const EdgeInsets.all(8.0),
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    // ====== NOTE CARD LAYOUT ======
                    // Material Design Card displaying single note summary
                    // Shows: Avatar, Title, Preview, Tags, Date, Action buttons
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      elevation: 2,  // Subtle shadow for depth
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),  // Rounded corners
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        // ====== LEADING AVATAR ======
                        // Purple circle with first letter of title
                        // Shows 'N' if note is untitled for consistency
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF9575CD),  // Purple background
                          child: Text(
                            note.title.isNotEmpty ? note.title[0].toUpperCase() : 'N',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        // ====== NOTE TITLE ======
                        // Bold, larger text showing note title
                        // Shows "Untitled Note" if no title provided
                        title: Text(
                          note.title.isNotEmpty ? note.title : 'Untitled Note',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        // ====== SUBTITLE SECTION (COMPACT NOTE METADATA) ======
                        // Displays preview, tags, and metadata in vertical stack
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            // Note content preview - first 2 lines, truncated with ellipsis
                            Text(
                              note.content,
                              maxLines: 2,  // Show at most 2 lines
                              overflow: TextOverflow.ellipsis,  // ... if longer
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            // Tags display - comma-separated split into individual chips
                            if (note.tags.isNotEmpty)
                              Wrap(
                                spacing: 4,  // Space between chips
                                children: note.tags.split(',').map((tag) {
                                  return Chip(
                                    label: Text(tag.trim()),  // Remove whitespace around tag
                                    visualDensity: VisualDensity.compact,  // Small chip size
                                    backgroundColor: const Color(0xFFE0BEE7),  // Light purple background
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 4),
                            // Timestamp - shows when note was created/saved
                            Text(
                              note.dateTime,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        // ====== ACTION BUTTONS (TRAILING) ======
                        // Three action icons for quick operations on note
                        // Layout: Row of 3 compact IconButtons (like, tags, delete)
                        trailing: SizedBox(
                          width: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // LIKE/UNLIKE BUTTON
                              // Heart icon: filled (pink #CE93D8) if liked, outline (grey) if not
                              // Toggles like status and updates database
                              IconButton(
                                icon: Icon(
                                  note.isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: note.isLiked ? const Color(0xFFCE93D8) : Colors.grey,
                                ),
                                onPressed: () => _toggleLike(note.id, note.isLiked),
                                iconSize: 20,
                                constraints: const BoxConstraints(),  // Compact size
                                padding: EdgeInsets.zero,
                              ),
                              const SizedBox(width: 8),
                              // EDIT TAGS BUTTON
                              // Label/tag icon (purple) opens dialog to modify tags
                              // Shows tooltip on long press
                              IconButton(
                                icon: const Icon(Icons.label_outline, color: Color(0xFF9575CD)),
                                onPressed: () => _showEditTagsDialog(note.id, note.tags),
                                iconSize: 20,
                                constraints: const BoxConstraints(),  // Compact size
                                padding: EdgeInsets.zero,
                                tooltip: 'Edit tags',
                              ),
                              const SizedBox(width: 8),
                              // DELETE BUTTON
                              // Trash icon (red #EF9A9A) opens confirmation dialog
                              // Prevents accidental deletion
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Color(0xFFEF9A9A)),
                                onPressed: () => _showDeleteConfirmation(note.id),
                                iconSize: 20,
                                constraints: const BoxConstraints(),  // Compact size
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                        // ====== NOTE CARD TAP ======
                        // Tapping note card navigates to detailed view
                        // Passes Note object to NoteDetailScreen
                        // Allows user to view full transcript, edit details, or share
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
      
      // ====== FLOATING ACTION BUTTON (ADD NOTE) ======
      // Purple circle button in bottom-right corner
      // Opens AddNoteScreen to create new voice note
      // On return: refreshes list to show newly added note
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_home',  // Unique ID to prevent animation conflicts
        onPressed: () async {
          // Navigate to recording screen and wait for return
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          );
          // Refresh list after potentially adding new note
          _refreshNotes();
        },
        backgroundColor: const Color(0xFF9575CD),  // Purple color
        child: const Icon(Icons.add),  // Plus icon
      ),
    );
  }

  /// ====== CLEANUP ======
  /// Dispose of resources when screen is destroyed
  /// Releases TextEditingController to prevent memory leaks
  @override
  void dispose() {
    _searchController.dispose();  // Clean up search text controller
    super.dispose();
  }
}
