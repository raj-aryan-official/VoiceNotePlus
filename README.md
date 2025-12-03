# 🎙️ Voice Notes Plus

A powerful, intuitive Flutter mobile application that lets you capture your thoughts through voice, automatically converts speech to text, and helps you organize and search through your notes effortlessly.

## 📱 Overview

**Voice Notes Plus** is a feature-rich note-taking application designed for users who prefer voice input. Whether you're on the go, driving, or just prefer speaking over typing, this app captures your voice, converts it to text instantly, and organizes everything with smart tagging and search capabilities.

### Perfect For:
- 🚗 Recording voice memos while driving
- 📚 Quick lecture notes during classes
- 💼 Meeting summaries and action items
- 🧠 Voice journaling and personal thoughts
- 📝 Hands-free note-taking

---

## ✨ Key Features

### 🎤 **Voice Recording & Speech-to-Text**
- Real-time voice recording with visual feedback
- Automatic speech recognition converts audio to text instantly
- Live transcript display as you speak
- Manual transcript editing for corrections
- Recording timer shows duration of each note

### 🎵 **Audio Playback & Local Storage**
- Play recorded audio directly from the app
- Professional audio player with play/pause controls
- Progress slider to seek through audio
- Time duration display (current/total)
- All audio files stored locally on device
- No cloud dependency for recordings

### 🏷️ **Smart Organization & Tag Management**
- **Tagging System**: Add comma-separated tags to categorize notes
- **Quick Tag Editing**: Edit tags directly from home screen with one tap
- **Title Management**: Create meaningful titles for quick identification
- **Timestamps**: Automatic date and time recording for each note
- **Custom Tags**: Organize by project, priority, category, or any custom tag

### 🔍 **Quick Search & Filter**
- Real-time search across titles, content, and tags
- Search results appear instantly as you type
- Filter by keywords to find specific notes quickly
- Case-insensitive search for better usability

### ❤️ **Favorites & Rating**
- Mark important notes as favorites with one tap
- Filter to view only your favorite notes
- Quick access to frequently referenced information

### ✏️ **Full Editing Capabilities**
- Edit note titles after creation
- Modify transcript text if speech recognition needs corrections
- Update tags to reorganize notes
- All changes are instantly saved to the database

### 🗑️ **Note Management**
- Delete individual notes with confirmation
- Delete recording files while keeping the note
- Full note removal capability
- Undo support through note history

### 📤 **Share Transcript**
- Share note content via email, messaging, and social media
- Share includes title, date, tags, and full transcript
- Formatted sharing for better readability
- Platform-native sharing dialog

### 💾 **Local Storage**
- All data stored locally using Hive database
- All audio files stored in device storage
- No cloud dependency - your notes and recordings stay private
- Fast, reliable offline-first operation
- Automatic data persistence

---

## 🎯 User Interface

### Home Screen
- Clean, minimalist design with card-based layout
- Search bar at the top for quick note discovery
- Filter buttons: "All Notes" and "Liked Notes"
- Note cards display:
  - 📌 Title and content preview
  - 🏷️ Tags as interactive chips
  - 📅 Creation date
  - ❤️ Like/Unlike button
  - 🗑️ Delete option

### Recording Screen
- Large, accessible microphone button
- Real-time timer showing recording duration
- Live transcript display area
- Control buttons:
  - 🎤 **Start/Stop Recording** - Toggle voice input
  - 🔄 **Reset** - Clear recording and start over
  - 💾 **Save** - Save with title, tags, and timestamp
- Editable text field for manual transcript adjustments

### Note Detail Screen
- Full transcript view
- Note metadata (date, tags)
- Edit button to modify any field:
  - Change title
  - Edit transcript
  - Update tags
- Like/Unlike button for favoriting
- Delete options for recording or entire note
- Beautiful purple/pink themed interface

---

## 🛠️ Technical Stack

### Framework & Language
- **Flutter 3.x** - Cross-platform mobile development
- **Dart** - Flutter's programming language

### Core Dependencies
- **Hive 2.2.3** - Fast, efficient local database
- **hive_flutter 1.1.0** - Flutter integration for Hive
- **speech_to_text 6.6.2** - Voice recognition engine
- **record 5.0.0** - Audio recording library
- **audio_players 5.0.0** - Audio playback library
- **share_plus 7.2.0** - Platform-native sharing
- **path_provider 2.1.0** - Access device storage paths
- **Material Design 3** - Modern UI components

### Architecture
- **StatefulWidget** - Dynamic UI state management
- **Factory Pattern** - Singleton database helper
- **Local-First Data** - All storage on device

---

## 🎨 Design & UX

### Color Scheme
- **Primary**: Purple (#9575CD)
- **Secondary**: Light Purple (#B39DDB)
- **Accent**: Pink (#CE93D8)
- **Surface**: Very Light Purple (#F3E5F5)
- **Success**: Green (#A5D6A7)
- **Warning**: Yellow (#FFE082)
- **Error**: Red (#EF9A9A)

### Responsive Design
- Optimized for various screen sizes
- Works seamlessly on phones and tablets
- Portrait and landscape orientation support
- Touch-optimized buttons and controls

---

## 📋 How to Use

### 1. **Creating a Note**
```
1. Tap the "+" button to go to recording screen
2. Tap the microphone button to start recording
3. Speak your thoughts - transcript appears in real-time
4. When done, tap the microphone again to stop
5. Tap "Save" and enter optional title and tags
6. Note is automatically saved with timestamp
```

### 2. **Searching Notes**
```
1. From home screen, use the search bar at the top
2. Type keywords, tag names, or titles
3. Results filter in real-time
4. Tap a note to view full details
```

### 3. **Managing Notes**
```
1. View all notes on home screen
2. Tap like icon to add/remove from favorites
3. Tap edit icon to modify title, transcript, or tags
4. Tap delete icon to remove a note
5. Use "Liked Notes" filter to see favorites
```

### 4. **Editing a Note**
```
1. Open note details
2. Tap edit button in top-right corner
3. Modify title, transcript, or tags
4. Tap "Save" to persist changes
5. Tap "Cancel" to discard changes
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x installed
- Dart 3.x runtime
- Android Studio or Xcode for mobile development
- Chrome browser for web testing

### Installation

```bash
# Clone the repository
git clone https://github.com/raj-aryan-official/Voice-notes-plus.git
cd Voice-notes-plus

# Install dependencies
flutter pub get

# Run the app
flutter run -d chrome        # For web browser
flutter run -d android       # For Android emulator
flutter run -d ios          # For iOS simulator
flutter run -d windows      # For Windows desktop
```

### Build for Production

```bash
# Android APK
flutter build apk

# iOS App
flutter build ios

# Web
flutter build web

# Windows
flutter build windows
```

---

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| 🔵 **Android** | ✅ Supported | Requires Android 5.0+ |
| 🍎 **iOS** | ✅ Supported | Requires iOS 11.0+ |
| 🌐 **Web** | ✅ Supported | Chrome, Firefox, Safari compatible |
| 🪟 **Windows** | ✅ Supported | Windows 10+ required |
| 🐧 **Linux** | ✅ Supported | Ubuntu 20.04+ compatible |
| 🍎 **macOS** | ✅ Supported | macOS 10.15+ required |

---

## 📊 Database Schema

### Notes Collection (Hive Box)
```dart
{
  'id': 'note_1',                    // Unique string identifier
  'title': 'Meeting Notes',          // User-provided title
  'content': 'Transcript text...',   // Speech-to-text content
  'dateTime': '2025-12-03 10:30',   // Creation timestamp
  'tags': 'work, important',         // Comma-separated tags
  'isLiked': true,                   // Favorite flag
  'recordingPath': 'path/to/audio'   // Optional recording file
}
```

---

## 🔐 Privacy & Security

- ✅ **Local-Only Storage**: All notes stored on device only
- ✅ **No Cloud Sync**: Eliminates third-party data exposure
- ✅ **No Account Required**: Use app without login
- ✅ **No Tracking**: Zero analytics or user tracking
- ✅ **Offline First**: Works completely offline

---

## 🐛 Known Limitations

- Recording requires microphone permission
- Speech recognition quality depends on audio clarity and background noise
- Some accents and languages may require training data
- Large note collections (1000+) may have slight performance impact

---

## 📈 Future Enhancements

- 🎵 Audio playback feature for recordings
- 📤 Cloud sync option (optional, privacy-preserving)
- 🌍 Multi-language support
- 📊 Analytics dashboard (local only)
- 🎨 Theme customization
- 📤 Export notes as PDF/Text
- 🔐 Biometric authentication
- 🤖 AI-powered note summaries

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 👨‍💻 Author

**Raj Aryan**
- GitHub: [@raj-aryan-official](https://github.com/raj-aryan-official)
- Repository: [Voice-notes-plus](https://github.com/raj-aryan-official/Voice-notes-plus)

---

## 📞 Support & Feedback

Have questions or found a bug? Please open an [issue](https://github.com/raj-aryan-official/Voice-notes-plus/issues) on GitHub.

---

## 🎉 Acknowledgments

- Flutter team for the amazing framework
- Speech-to-Text library maintainers
- Hive database for local storage
- Material Design for UI inspiration

---

**Made with ❤️ for voice-first note-taking**
