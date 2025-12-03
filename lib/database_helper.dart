import 'package:hive/hive.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static late Box<Map> _notesBox;
  static bool _isInitialized = false;
  static int _noteCounter = 0;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        _notesBox = await Hive.openBox<Map>('notes');
      } catch (e) {
        print('Error opening notes box: $e');
        // Delete corrupted box and try again
        await Hive.deleteBoxFromDisk('notes');
        _notesBox = await Hive.openBox<Map>('notes');
      }
      _isInitialized = true;
    }
  }

  String _generateId() {
    _noteCounter++;
    return 'note_$_noteCounter';
  }

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
    
    // Sort by dateTime descending
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

  Future<void> deleteNote(dynamic id) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    await _notesBox.delete(id);
  }

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
    
    // Sort by dateTime descending
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
