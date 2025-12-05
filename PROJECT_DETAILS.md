# 🏗️ Voice Notes Plus - Project Technical Documentation

**Project Name:** Voice Notes Plus  
**Language:** Dart / Flutter  
**Database:** Hive  
**Last Updated:** December 4, 2025

---

## 📚 Table of Contents
1. [Project Overview](#project-overview)
2. [Folder Structure](#folder-structure)
3. [Technology Stack](#technology-stack)
4. [Architecture Overview](#architecture-overview)
5. [File-by-File Guide](#file-by-file-guide)
6. [Data Flow](#data-flow)
7. [Key Concepts](#key-concepts)
8. [Development Guidelines](#development-guidelines)

---

## 🎯 Project Overview

**Voice Notes Plus** is a cross-platform Flutter application that enables users to:
- Record voice notes
- Convert speech to text
- Organize notes with tags
- Search and retrieve notes quickly
- Store audio recordings locally
- Share note transcripts

### Key Objectives
1. Provide a distraction-free voice note-taking experience
2. Ensure complete data privacy (local-first)
3. Support multiple platforms seamlessly
4. Maintain high performance with large note collections
5. Enable quick note retrieval through intelligent search

---

## 📁 Folder Structure

```
Voice-notes-plus/
├── lib/                          # Main Dart source code
│   ├── main.dart                # App entry point & theme
│   ├── home_screen.dart         # Home/list screen
│   ├── add_note_screen.dart     # Recording screen
│   ├── note_detail_screen.dart  # Note details & playback
│   ├── note_model.dart          # Data model
│   └── database_helper.dart     # Database operations
├── android/                      # Android-specific code
│   ├── app/
│   │   └── src/main/AndroidManifest.xml
│   ├── build.gradle
│   └── gradle.properties
├── ios/                          # iOS-specific code
│   ├── Runner/
│   │   └── Info.plist
│   └── Podfile
├── web/                          # Web build files
│   ├── index.html
│   └── manifest.json
├── windows/                      # Windows desktop build
├── linux/                        # Linux build
├── macos/                        # macOS build
├── pubspec.yaml                  # Project dependencies
├── pubspec.lock                  # Dependency lock file
├── analysis_options.yaml         # Dart linter rules
├── README.md                     # User-facing documentation
├── PRD.md                        # Product requirements
└── PROJECT_DETAILS.md            # This file

```

---

## 🛠️ Technology Stack

### Frontend Framework
| Technology | Version | Purpose |
|-----------|---------|---------|
| Flutter | 3.x | Cross-platform UI framework |
| Dart | 3.4.3+ | Programming language |
| Material Design 3 | Latest | UI components & design system |

### Backend & Storage
| Package | Version | Purpose |
|---------|---------|---------|
| Hive | 2.2.3 | Local NoSQL database |
| hive_flutter | 1.1.0 | Flutter integration for Hive |
| path_provider | 2.1.0 | Access device storage paths |

### Voice & Audio
| Package | Version | Purpose |
|---------|---------|---------|
| speech_to_text | 6.6.2 | Speech recognition |
| record | 5.0.0 | Audio recording |
| audio_players | 5.0.0 | Audio playback |

### Platform & Sharing
| Package | Version | Purpose |
|---------|---------|---------|
| share_plus | 7.2.0 | Native sharing dialog |
| permission_handler | 11.3.1 | Runtime permissions |
| intl | 0.19.0 | Internationalization |

### Development Tools
| Tool | Purpose |
|------|---------|
| Flutter SDK | Development & build |
| Dart SDK | Language runtime |
| Android SDK | Android builds |
| Xcode | iOS builds |
| Visual Studio | Windows builds |

---

## 🏛️ Architecture Overview

### Architecture Pattern: MVC (Model-View-Controller)

```
┌─────────────────────────────────────────────┐
│         UI Layer (Widgets)                  │
│  ┌──────────┬──────────┬──────────────────┐ │
│  │ HomeScreen  │ AddNoteScreen │ NoteDetailScreen │ │
│  └──────────┴──────────┴──────────────────┘ │
└─────────────────────────────────────────────┘
          ↓ setState / rebuild
┌─────────────────────────────────────────────┐
│      State Management Layer                  │
│  (StatefulWidget + Controllers)             │
│  ├─ TextEditingController                   │
│  ├─ AudioPlayer                             │
│  └─ SpeechToText                            │
└─────────────────────────────────────────────┘
          ↓ function calls
┌─────────────────────────────────────────────┐
│      Business Logic Layer                    │
│  (DatabaseHelper methods)                   │
│  ├─ insertNote()                            │
│  ├─ updateNote()                            │
│  ├─ deleteNote()                            │
│  └─ searchNotes()                           │
└─────────────────────────────────────────────┘
          ↓ CRUD operations
┌─────────────────────────────────────────────┐
│      Data Layer                              │
│  ├─ Hive Box (notes)                        │
│  ├─ Local Filesystem (audio)                │
│  └─ Device Storage (cache)                  │
└─────────────────────────────────────────────┘
```

### Design Patterns Used

1. **Singleton Pattern** - DatabaseHelper
   ```dart
   class DatabaseHelper {
     static final DatabaseHelper _instance = DatabaseHelper._internal();
     factory DatabaseHelper() => _instance;
   }
   ```

2. **Model-View-Controller** - Separation of concerns
   - Model: Note, database operations
   - View: Screens (home, add, detail)
   - Controller: State management in StatefulWidget

3. **Factory Pattern** - Note creation from maps
   ```dart
   factory Note.fromMap(Map<String, dynamic> map) { ... }
   ```

4. **Repository Pattern** - DatabaseHelper abstracts data source

---

## 📄 File-by-File Guide

### 1. **main.dart** - App Entry Point
**Purpose:** Application initialization and theme configuration

**Key Responsibilities:**
- Initialize Hive database
- Set up Material theme with custom colors
- Create MyApp root widget
- Configure app settings

**Key Code:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await DatabaseHelper().initialize();
  runApp(const MyApp());
}
```

**Theme Configuration:**
- Primary Color: #9575CD (Purple)
- Secondary Color: #B39DDB (Light Purple)
- Accent Color: #CE93D8 (Pink)
- Error Color: #EF9A9A (Red)
- Success Color: #A5D6A7 (Green)
- Warning Color: #FFE082 (Yellow)

**Import Dependencies:**
```dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'database_helper.dart';
import 'home_screen.dart';
```

---

### 2. **note_model.dart** - Data Model
**Purpose:** Define Note data structure

**Class Definition:**
```dart
class Note {
  final dynamic id;              // Unique identifier
  final String title;            // User-provided title
  final String content;          // Transcript text
  final String dateTime;         // ISO timestamp
  final String tags;             // Comma-separated
  final bool isLiked;            // Favorite flag
  final String recordingPath;    // Audio file path
}
```

**Methods:**
- `toMap()` - Convert to JSON/Map
- `fromMap()` - Create from JSON/Map (factory constructor)

**Usage Example:**
```dart
Note note = Note(
  id: 'note_1',
  title: 'Meeting Notes',
  content: 'This is the transcript...',
  dateTime: DateTime.now().toString(),
  tags: 'work, meeting',
  isLiked: false,
  recordingPath: '/path/to/audio.mp3',
);
```

---

### 3. **database_helper.dart** - Data Access Layer
**Purpose:** Handle all database operations

**Singleton Pattern:**
```dart
static final DatabaseHelper _instance = DatabaseHelper._internal();
factory DatabaseHelper() => _instance;
DatabaseHelper._internal();
```

**Core Methods:**

#### `initialize()`
- Opens Hive box 'notes'
- Handles database corruption recovery
- Initializes note counter

#### `insertNote(Map<String, dynamic> note)`
- Generates unique string ID
- Stores note in Hive
- Returns generated ID

#### `getNotes({bool likedOnly = false})`
- Retrieves all notes or favorites only
- Sorts by dateTime (newest first)
- Returns List<Map<String, dynamic>>

#### `searchNotes(String query)`
- Searches title, content, and tags
- Case-insensitive matching
- Returns filtered, sorted results

#### `updateNote(id, {title, content, tags})`
- Updates specific fields
- Retrieves note, modifies, saves
- Partial update support

#### `updateNoteLike(id, bool isLiked)`
- Toggles favorite status
- Updates and persists

#### `deleteNote(id)`
- Removes note from Hive
- Throws error if not found

**Data Structure:**
```dart
// Hive Box storage format
'note_1': {
  'id': 'note_1',
  'title': 'Meeting',
  'content': 'Transcript...',
  'dateTime': '2025-12-04 10:30:00',
  'tags': 'work',
  'isLiked': false,
  'recordingPath': '/path/to/audio.mp3'
}
```

---

### 4. **home_screen.dart** - Note List & Search
**Purpose:** Display notes, search, filter, and manage

**Key Components:**

#### State Variables
```dart
late Future<List<Map<String, dynamic>>> _notesFuture;
bool _showLikedOnly = false;
String _searchQuery = '';
TextEditingController _searchController;
```

#### Main Widgets
1. **AppBar** - Title and controls
2. **Search Bar** - Real-time search input
3. **Filter Buttons** - All/Liked toggle
4. **Note Cards** - Individual note display
5. **FAB** - Create new note button

#### Key Methods

`_refreshNotes()`
- Triggers note list rebuild
- Updates UI with latest data

`_getNotesList()`
- Fetches notes from database
- Applies search filter
- Applies favorite filter

`_toggleLike(id, state)`
- Updates note's like status
- Refreshes list

`_showDeleteConfirmation(id)`
- Shows confirmation dialog
- Deletes on confirm

`_showEditTagsDialog(id, tags)`
- Opens tag editor dialog
- Updates tags in database

**Navigation:**
- Tap FAB → AddNoteScreen (new note)
- Tap note card → NoteDetailScreen (view/edit)

---

### 5. **add_note_screen.dart** - Recording Interface
**Purpose:** Record voice, display transcript, save note

**Key State Variables:**
```dart
late SpeechToText _speech;
TextEditingController _contentController;      // Transcript
TextEditingController _titleController;        // Note title
TextEditingController _tagsController;         // Note tags
bool _isListening = false;
int _seconds = 0;                              // Timer
String _text = '';                             // Current speech
String _statusText = 'Ready to record';
```

#### Core Functionality

**Recording Flow:**
1. User taps microphone button
2. `_listen()` initializes speech recognition
3. `_startListening()` begins capturing audio
4. `onResult` updates `_contentController` with text
5. User taps button again to stop
6. `_showSaveDialog()` appears for metadata

**Timer Management:**
```dart
void _startTimer() {
  Timer.periodic(Duration(seconds: 1), (timer) {
    if (mounted) {
      setState(() => _seconds++);
    }
  });
}

void _stopTimer() {
  // Stops timer
}

String _formatTime(int seconds) {
  int minutes = seconds ~/ 60;
  int secs = seconds % 60;
  return '$minutes:${secs.toString().padLeft(2, '0')}';
}
```

**Save Mechanism:**
```dart
void _saveNote() async {
  final note = {
    'title': _titleController.text,
    'content': _contentController.text,
    'dateTime': DateTime.now().toString(),
    'tags': _tagsController.text,
  };
  
  final id = await DatabaseHelper().insertNote(note);
  Navigator.pop(context);
}
```

**Reset Function:**
```dart
void _resetRecording() {
  _stopTimer();
  setState(() {
    _seconds = 0;
    _text = '';
    _contentController.clear();
    _statusText = 'Recording reset. Tap to start.';
  });
}
```

#### UI Layout
1. Status text display
2. Timer display (MM:SS format)
3. Transcript area (editable TextField)
4. Control buttons (Reset, Mic, Save)
5. Auto-save dialog on stop

---

### 6. **note_detail_screen.dart** - Note View & Edit
**Purpose:** Display full note, playback audio, edit content

**Key State Variables:**
```dart
late Note _note;
late AudioPlayer _audioPlayer;
late TextEditingController _titleController;
late TextEditingController _contentController;
late TextEditingController _tagsController;
bool _isEditing = false;
bool _isPlaying = false;
Duration _duration = Duration.zero;
Duration _position = Duration.zero;
```

#### Audio Playback Implementation

**Initialization:**
```dart
_audioPlayer = AudioPlayer();

_audioPlayer.onPlayerStateChanged.listen((state) {
  if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
});

_audioPlayer.onDurationChanged.listen((duration) {
  if (mounted) setState(() => _duration = duration);
});

_audioPlayer.onPositionChanged.listen((position) {
  if (mounted) setState(() => _position = position);
});
```

**Playback Control:**
```dart
void _playAudio() async {
  if (_isPlaying) {
    await _audioPlayer.pause();
  } else {
    await _audioPlayer.play(AssetSource(_note.recordingPath));
  }
}
```

#### Editing System

**Edit Mode Toggle:**
```dart
if (_isEditing) {
  // Show TextField for editing
  TextField(controller: _contentController, ...)
} else {
  // Show SelectableText read-only
  SelectableText(_note.content, ...)
}
```

**Save Changes:**
```dart
void _saveChanges() async {
  await DatabaseHelper().updateNote(
    _note.id,
    title: _titleController.text,
    content: _contentController.text,
    tags: _tagsController.text,
  );
  
  setState(() => _isEditing = false);
  // Show success message
}
```

#### Sharing Feature

**Share Transcript:**
```dart
void _shareTranscript() async {
  final text = '''
Title: ${_note.title}
Date: ${_note.dateTime}
Tags: ${_note.tags}

Transcript:
${_note.content}
  ''';
  
  await Share.share(text, subject: _note.title);
}
```

#### UI Sections
1. **AppBar** - Title, Like, Edit, Share, Delete buttons
2. **Metadata** - Date, tags as chips
3. **Transcript** - Full note content (editable in edit mode)
4. **Audio Player** - Play/pause, slider, duration
5. **Recording Info** - File name, delete option

---

## 🔄 Data Flow Diagram

### Creating a Note
```
User Input
    ↓
[AddNoteScreen]
  - Record audio
  - Transcribe to text
  - Input title & tags
    ↓
_saveNote()
    ↓
DatabaseHelper.insertNote(noteMap)
    ↓
Hive Box write
    ↓
[HomeScreen]
  - Refresh UI
  - Display new note
```

### Searching Notes
```
User types in search bar
    ↓
TextField.onChanged
    ↓
_getNotesList()
    ↓
DatabaseHelper.searchNotes(query)
    ↓
Filter notes by title/content/tags
    ↓
setState() → rebuild
    ↓
Display filtered results
```

### Playing Audio
```
User taps play button
    ↓
_playAudio()
    ↓
AudioPlayer.play(recordingPath)
    ↓
Platform audio engine
    ↓
Device speaker/headphones
    ↓
onPositionChanged updates UI slider
    ↓
User can pause/seek/stop
```

### Sharing Note
```
User taps share button
    ↓
_shareTranscript()
    ↓
Format note content
    ↓
Share.share(text)
    ↓
Native share dialog
    ↓
User selects app (email, message, etc)
    ↓
External app receives content
```

---

## 🔑 Key Concepts & Patterns

### 1. Hive Database
**What:** Fast, efficient NoSQL database for Flutter  
**Why:** Local storage without complex setup  
**How Used:**
```dart
// Box is like a table/collection
Box<Map> notesBox = await Hive.openBox('notes');

// Store data
await notesBox.put('note_1', {'title': 'My Note', ...});

// Retrieve data
Map noteData = notesBox.get('note_1');

// Delete data
await notesBox.delete('note_1');

// Iterate
for (var note in notesBox.values) { ... }
```

### 2. StateManagement
**Pattern:** StatefulWidget with mounted checks  
**Why:** Simple for this app complexity  
**Implementation:**
```dart
setState(() {
  if (mounted) {
    // Update UI
  }
});
```

### 3. Speech Recognition
**Library:** speech_to_text  
**Flow:**
```
Initialize → Listen → onResult → Stop → Result ready
```

### 4. Local File Storage
**Path Provider:** Access device storage  
**Audio Storage:** Cache or documents folder  
**Advantage:** Private storage, persists with app

### 5. Error Handling
**Database Corruption:**
```dart
try {
  _notesBox = await Hive.openBox<Map>('notes');
} catch (e) {
  await Hive.deleteBoxFromDisk('notes');
  _notesBox = await Hive.openBox<Map>('notes'); // Fresh start
}
```

---

## 📚 Development Guidelines

### Code Style
- Follow Dart conventions
- Use camelCase for variables/functions
- Use PascalCase for classes
- Comment complex logic
- Use meaningful variable names

### Adding New Features
1. Update Note model if needed
2. Add method to DatabaseHelper
3. Create/update UI screen
4. Test on all platforms
5. Update README

### Database Operations
- Always check `if (!_isInitialized)` before operations
- Use try-catch for database errors
- Validate input data
- Test with corrupt database

### UI Updates
- Use `if (mounted)` before setState
- Dispose controllers/listeners
- Handle edge cases (empty list, null values)
- Test on different screen sizes

### Testing Checklist
- ✅ Record audio (mock if needed)
- ✅ Speech recognition
- ✅ Save note with all fields
- ✅ Search functionality
- ✅ Edit note fields
- ✅ Delete operations
- ✅ Share functionality
- ✅ Audio playback
- ✅ Tag management

---

## 🔗 Dependencies Deep Dive

### flutter: ^3.x
- **Purpose:** UI Framework
- **Usage:** Widgets, Material Design, routing
- **Key Classes:** StatefulWidget, MaterialApp, Scaffold

### dart: ^3.4.3
- **Purpose:** Language runtime
- **Usage:** All logic, models, utilities
- **Key Features:** Null safety, async/await

### hive: ^2.2.3
- **Purpose:** NoSQL database
- **Usage:** Store and retrieve notes
- **Benefits:** Fast, no setup required

### speech_to_text: ^6.6.2
- **Purpose:** Speech recognition
- **Usage:** Convert voice to text
- **Platform:** Android/iOS/Web native APIs

### record: ^5.0.0
- **Purpose:** Audio recording
- **Usage:** Capture voice from microphone
- **Platform:** Uses native audio APIs

### audio_players: ^5.0.0
- **Purpose:** Audio playback
- **Usage:** Play recorded audio files
- **Features:** Play/pause, seek, duration

### share_plus: ^7.2.0
- **Purpose:** Native sharing
- **Usage:** Share transcripts
- **Platform:** Uses native share dialogs

---

## 🚀 Build & Deployment

### Development Build
```bash
flutter run -d chrome           # Web
flutter run -d android          # Android emulator
flutter run -d ios              # iOS simulator
flutter run -d windows          # Windows
```

### Production Build
```bash
# Android
flutter build apk
flutter build appbundle

# iOS
flutter build ios

# Web
flutter build web

# Windows
flutter build windows
```

### Platform-Specific Notes
- **Android:** Requires microphone permission in AndroidManifest.xml
- **iOS:** Requires permission in Info.plist
- **Web:** Speech recognition available in Chrome/Edge
- **Windows:** Requires VC++ redistributable

---

## 📝 Important Files for Configuration

### pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  hive: ^2.2.3
  speech_to_text: ^6.6.2
  record: ^5.0.0
  audio_players: ^5.0.0
  share_plus: ^7.2.0
```

### Android/app/src/main/AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS/Runner/Info.plist
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access for voice recording</string>
<key>NSLocalNetworkUsageDescription</key>
<string>Voice Notes needs local network access</string>
```

---

## 🎓 Learning Resources

- **Flutter Documentation:** https://flutter.dev/docs
- **Dart Language:** https://dart.dev
- **Hive Database:** https://docs.hivedb.dev
- **Material Design 3:** https://m3.material.io

---

## 📞 Support & Contributing

**Repository:** https://github.com/raj-aryan-official/Voice-notes-plus  
**Issues:** Report bugs on GitHub  
**Contributions:** Fork, modify, submit PR

---

**Document Version:** 1.0  
**Last Updated:** December 4, 2025  
**Maintained By:** Raj Aryan  
**License:** MIT

Made with ❤️ for developers interested in voice-first applications
