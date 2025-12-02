import 'package:hive/hive.dart';

/// ====== DATABASE HELPER - SINGLETON CLASS ======
/// 
/// DatabaseHelper - Central database management for Voice Notes Plus
/// Implements singleton pattern to ensure single database instance across app
/// 
/// Features:
///   - Manages Hive local database for persistent note storage
///   - CRUD operations (Create, Read, Update, Delete) for notes
///   - Automatic unique ID generation for each note
///   - Search and filtering capabilities
///   - Like/favorite marking persistence
///   - Lazy initialization on first use
///   - Error recovery (corrupted box deletion)
/// 
/// Hive Details:
///   - Box name: 'notes' - stores all note data as Maps
///   - Uses string keys: 'note_1', 'note_2', etc.
///   - Persists to application documents directory
///   - Fast key-value storage, suitable for mobile apps
class DatabaseHelper {
  // ====== SINGLETON PATTERN ======
  /// Static instance - ensures only one DatabaseHelper exists
  /// Created once, reused throughout app lifetime
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  
  /// Static reference to Hive Box containing all notes
  /// Box<Map> stores note data as key-value pairs
  /// Late initialization: created during initialize() method
  static late Box<Map> _notesBox;
  
  /// Initialization flag to prevent duplicate setup
  /// Checked before running initialize() to save resources
  static bool _isInitialized = false;
  
  /// Counter for generating unique note IDs
  /// Incremented for each new note added
  /// Initialized from existing database keys count
  /// Ensures IDs are never reused even after app restart
  static int _noteCounter = 0;

  /// ====== FACTORY CONSTRUCTOR ======
  /// Returns the singleton instance
  /// Ensures only one DatabaseHelper throughout app
  /// Usage: DatabaseHelper() always returns same instance
  factory DatabaseHelper() {
    return _instance;
  }

  /// ====== PRIVATE CONSTRUCTOR ======
  /// Called only once via factory
  /// Private to prevent direct instantiation
  DatabaseHelper._internal();

  /// ====== INITIALIZATION ======
  /// Initialize Hive database and open notes box
  /// 
  /// Called from main.dart during app startup
  /// Must be awaited before any database operations
  /// 
  /// Steps:
  ///   1. Check if already initialized (skip if true)
  ///   2. Open 'notes' box from Hive (or create if missing)
  ///   3. If box is corrupted, delete and recreate it
  ///   4. Initialize _noteCounter from existing notes count
  ///   5. Set _isInitialized flag to true
  /// 
  /// Error Handling:
  ///   - Catches errors when opening box
  ///   - Deletes corrupted box from disk
  ///   - Attempts to recreate fresh box
  ///   - Logs errors to console
  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        // Open or create 'notes' box in Hive
        // Type: Box<Map> - stores note data as maps
        _notesBox = await Hive.openBox<Map>('notes');
      } catch (e) {
        // Handle corrupted box error
        print('Error opening notes box: $e');
        // Delete corrupted box and try again
        await Hive.deleteBoxFromDisk('notes');
        _notesBox = await Hive.openBox<Map>('notes');
      }
      
      // Initialize counter based on existing notes in database
      // Ensures new notes don't reuse existing IDs
      // Example: If 5 notes exist, counter starts at 5
      _noteCounter = _notesBox.keys.length;
      
      _isInitialized = true;
    }
  }

  /// ====== ID GENERATION ======
  /// Generate unique string ID for new note
  /// 
  /// Flow:
  ///   1. Increment _noteCounter
  ///   2. Format as string: 'note_' + counter
  ///   3. Return formatted string ID
  /// 
  /// Example IDs:
  ///   - First note: 'note_1'
  ///   - Second note: 'note_2'
  ///   - Tenth note: 'note_10'
  /// 
  /// Why String IDs:
  ///   - Hive keys are strings
  ///   - Human-readable for debugging
  ///   - Easy to search/filter by ID
  ///   - Consistent format across app
  /// 
  /// Safety:
  ///   - Counter persists in _noteCounter
  ///   - Counter initialized from database size
  ///   - IDs never reused (monotonically increasing)
  String _generateId() {
    _noteCounter++;
    return 'note_$_noteCounter';
  }

  /// ====== INSERT NEW NOTE ======
  /// Add a new note to the database
  /// 
  /// Called from: add_note_screen.dart when user saves recording
  /// 
  /// Parameters:
  ///   - note: Map<String, dynamic> containing note data
  ///     Expected keys: title, content, dateTime, tags (optional)
  /// 
  /// Process:
  ///   1. Ensure database is initialized
  ///   2. Generate unique ID for note
  ///   3. Add ID to note map
  ///   4. Set default values for optional fields:
  ///      - isLiked: false (not favorite by default)
  ///      - tags: '' (empty string if not provided)
  ///      - recordingPath: '' (recording file path)
  ///   5. Save note to Hive box using put()
  ///   6. Return generated ID
  /// 
  /// Return value: String - unique note ID (e.g., 'note_5')
  /// 
  /// Error Handling:
  ///   - Auto-initializes if not already initialized
  ///   - Map null coalescing ensures all fields exist
  /// 
  /// Example Usage:
  ///   final noteData = {
  ///     'title': 'My Meeting',
  ///     'content': 'Discussed project timeline...',
  ///     'dateTime': '2025-12-04 14:30:00',
  ///   };
  ///   final id = await DatabaseHelper().insertNote(noteData);
  ///   // Returns: 'note_5'
  Future<String> insertNote(Map<String, dynamic> note) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    // Generate a unique ID using string key
    final id = _generateId();
    note['id'] = id;
    note['isLiked'] = note['isLiked'] ?? false;
    note['tags'] = note['tags'] ?? '';
    note['recordingPath'] = note['recordingPath'] ?? '';
    
    await _notesBox.put(id, note);
    return id;
  }

  /// ====== RETRIEVE ALL NOTES ======
  /// Fetch notes from database with optional filtering
  /// 
  /// Called from: home_screen.dart to load notes list
  /// 
  /// Parameters:
  ///   - likedOnly: bool (default: false)
  ///     - false: Return all notes
  ///     - true: Return only notes marked as liked/favorite
  /// 
  /// Process:
  ///   1. Ensure database is initialized
  ///   2. Iterate through all values in _notesBox
  ///   3. Convert each Hive map to mutable Map
  ///   4. If likedOnly=true, skip notes where isLiked=false
  ///   5. Add filtered notes to results list
  ///   6. Sort by dateTime descending (newest first)
  ///   7. Return sorted notes list
  /// 
  /// Sorting:
  ///   - Parse dateTime strings to DateTime objects
  ///   - Compare using dateTime.compareTo() (newest first)
  ///   - Use safe default date if parsing fails
  ///   - Maintains chronological order for display
  /// 
  /// Return value: List<Map<String, dynamic>> - sorted notes
  /// 
  /// Example Usage:
  ///   // Get all notes
  ///   final allNotes = await DatabaseHelper().getNotes();
  ///   
  ///   // Get only favorite notes
  ///   final favorites = await DatabaseHelper().getNotes(likedOnly: true);
  Future<List<Map<String, dynamic>>> getNotes({bool likedOnly = false}) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    final notes = <Map<String, dynamic>>[];
    for (var value in _notesBox.values) {
      final note = Map<String, dynamic>.from(value);
      if (likedOnly && !(note['isLiked'] ?? false)) {
        continue;
      }
      notes.add(note);
    }
    
    // Sort by dateTime descending (newest first)
    notes.sort((a, b) {
      try {
        final dateA = DateTime.parse(a['dateTime'] ?? '2000-01-01');
        final dateB = DateTime.parse(b['dateTime'] ?? '2000-01-01');
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });
    
    return notes;
  }

  /// ====== DELETE NOTE ======
  /// Permanently remove a note from database
  /// 
  /// Called from: note_detail_screen.dart via delete button
  /// 
  /// Parameters:
  ///   - id: dynamic (String) - unique note identifier
  ///     Example: 'note_5'
  /// 
  /// Process:
  ///   1. Ensure database is initialized
  ///   2. Delete note from _notesBox using id
  ///   3. Note is permanently removed from disk
  /// 
  /// Important Notes:
  ///   - Action is irreversible (no undo)
  ///   - ID counter is NOT decremented (IDs never reused)
  ///   - Deletion is synchronous to database
  ///   - Called after user confirms deletion in dialog
  /// 
  /// Example Usage:
  ///   await DatabaseHelper().deleteNote('note_5');
  Future<void> deleteNote(dynamic id) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    await _notesBox.delete(id);
  }

  /// ====== TOGGLE LIKE/FAVORITE ======
  /// Update like status of a note
  /// 
  /// Called from:
  ///   - home_screen.dart: heart icon in note list
  ///   - note_detail_screen.dart: heart icon in detail view
  /// 
  /// Parameters:
  ///   - id: dynamic (String) - unique note identifier
  ///   - isLiked: bool - new like status
  ///     - true: mark as favorite
  ///     - false: remove from favorites
  /// 
  /// Process:
  ///   1. Ensure database is initialized
  ///   2. Retrieve note from _notesBox using id
  ///   3. If note exists, update isLiked field
  ///   4. Save updated note back to database
  ///   5. Changes persist to disk
  /// 
  /// Usage:
  ///   - User clicks heart icon in home list
  ///   - Triggers setState with new like value
  ///   - Calls this method to persist change
  ///   - Shows green SnackBar confirmation
  /// 
  /// Example Usage:
  ///   // Mark note as favorite
  ///   await DatabaseHelper().updateNoteLike('note_5', true);
  ///   
  ///   // Remove from favorites
  ///   await DatabaseHelper().updateNoteLike('note_5', false);
  Future<void> updateNoteLike(dynamic id, bool isLiked) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    final note = _notesBox.get(id);
    if (note != null) {
      note['isLiked'] = isLiked;
      await _notesBox.put(id, note);
    }
  }

  /// ====== UPDATE NOTE CONTENT ======
  /// Modify note title, transcript, or tags
  /// 
  /// Called from: note_detail_screen.dart via Save button in edit mode
  /// 
  /// Parameters:
  ///   - id: dynamic (String) - unique note identifier
  ///   - title: String? (optional) - new title or null to skip
  ///   - content: String? (optional) - new transcript or null to skip
  ///   - tags: String? (optional) - new tags or null to skip
  /// 
  /// Process:
  ///   1. Ensure database is initialized
  ///   2. Retrieve note from _notesBox using id
  ///   3. If note exists, selectively update fields
  ///      - Only update fields that are not null
  ///      - Preserves other fields (id, dateTime, like status)
  ///   4. Save updated note back to database
  ///   5. Changes persist to disk
  /// 
  /// Selective Update Pattern:
  ///   - Uses null checks to update only provided fields
  ///   - Allows partial updates (update title only, content only, etc.)
  ///   - Preserves unchanged fields
  /// 
  /// Example Usage:
  ///   // Update only title
  ///   await DatabaseHelper().updateNote('note_5', title: 'New Title');
  ///   
  ///   // Update title and content
  ///   await DatabaseHelper().updateNote('note_5',
  ///     title: 'Meeting Notes',
  ///     content: 'Discussed Q4 goals...'
  ///   );
  ///   
  ///   // Update only tags
  ///   await DatabaseHelper().updateNote('note_5', tags: 'important,work');
  Future<void> updateNote(dynamic id, {String? title, String? content, String? tags}) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    final note = _notesBox.get(id);
    if (note != null) {
      if (title != null) note['title'] = title;
      if (content != null) note['content'] = content;
      if (tags != null) note['tags'] = tags;
      await _notesBox.put(id, note);
    }
  }

  /// ====== SEARCH NOTES ======
  /// Find notes matching search query
  /// 
  /// Called from: home_screen.dart in real-time as user types
  /// 
  /// Parameters:
  ///   - query: String - search text entered by user
  ///     Example: 'meeting', 'urgent', 'project'
  /// 
  /// Search Scope:
  ///   - Searches note title, content, and tags
  ///   - Case-insensitive (converts to lowercase)
  ///   - Partial matching (substring search)
  /// 
  /// Process:
  ///   1. Ensure database is initialized
  ///   2. Convert query to lowercase for case-insensitive search
  ///   3. Iterate through all notes in database
  ///   4. For each note, check if query appears in:
  ///      - title: note subject/heading
  ///      - content: transcript text
  ///      - tags: comma-separated categories
  ///   5. If query found in any field, add note to results
  ///   6. Sort results by dateTime descending (newest first)
  ///   7. Return matching notes
  /// 
  /// Search Examples:
  ///   - 'meeting' matches: "Meeting with client", "team meetings discussed"
  ///   - 'bug' matches: notes tagged with "bug-fix" or content with "bug"
  ///   - 'project-alpha' matches: tags containing "project-alpha"
  /// 
  /// Return value: List<Map<String, dynamic>> - sorted search results
  /// 
  /// Example Usage:
  ///   final results = await DatabaseHelper().searchNotes('meeting');
  ///   // Returns all notes with 'meeting' in title, content, or tags
  Future<List<Map<String, dynamic>>> searchNotes(String query) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    final notes = <Map<String, dynamic>>[];
    final lowerQuery = query.toLowerCase();
    
    for (var value in _notesBox.values) {
      final note = Map<String, dynamic>.from(value);
      final title = (note['title'] ?? '').toString().toLowerCase();
      final content = (note['content'] ?? '').toString().toLowerCase();
      final tags = (note['tags'] ?? '').toString().toLowerCase();
      
      if (title.contains(lowerQuery) || content.contains(lowerQuery) || tags.contains(lowerQuery)) {
        notes.add(note);
      }
    }
    
    // Sort by dateTime descending (newest first)
    notes.sort((a, b) {
      try {
        final dateA = DateTime.parse(a['dateTime'] ?? '2000-01-01');
        final dateB = DateTime.parse(b['dateTime'] ?? '2000-01-01');
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });
    
    return notes;
  }
}
