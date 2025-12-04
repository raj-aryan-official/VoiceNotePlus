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
- Share transcript functionality
- Beautiful teal-themed Material Design 3 interface

---

## 🛠️ Technical Stack

### Framework & Language
- **Flutter 3.x** - Cross-platform mobile development
- **Dart** - Flutter's programming language

### Core Dependencies
- **Hive 2.2.3** - Fast, efficient local database
- **hive_flutter 1.1.0** - Flutter integration for Hive
- **speech_to_text 6.6.1** - Voice recognition engine
- **permission_handler 11.3.1** - Handle device permissions
- **intl 0.19.0** - Internationalization and date formatting
- **share_plus 7.2.0** - Platform-native sharing
- **path_provider 2.1.0** - Access device storage paths
- **Material Design 3** - Modern UI components

### Architecture
- **StatefulWidget** - Dynamic UI state management
- **Singleton Pattern** - DatabaseHelper for centralized data access
- **Local-First Data** - All storage on device (Hive database)
- **Splash Screen** - Branding and initialization
- **Material Design 3** - Modern UI components and theming

---

## 🎨 Design & UX

### Color Scheme
- **Primary**: Dark Teal (#00695C)
- **Secondary**: Medium Teal (#00897B)
- **Tertiary**: Light Teal (#26A69A)
- **Surface**: Very Light Teal (#E0F2F1)
- **Error**: Red (#F44336)
- **Material Design 3**: Modern, adaptive design system

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
git clone https://github.com/raj-aryan-official/VoiceNotePlus.git
cd Voice-notes-plus

# Install dependencies
flutter pub get

# Run the app
flutter run -d chrome --web-port=5005    # For web browser (port 5005)
flutter run -d android                  # For Android emulator/device
flutter run -d ios                      # For iOS simulator
flutter run -d windows                  # For Windows desktop
```

### Development Setup

1. **Install Flutter SDK:**
   - Download from: https://flutter.dev/docs/get-started/install
   - Add Flutter to your PATH

2. **Verify Installation:**
   ```bash
   flutter doctor
   ```

3. **Get Dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run in Development Mode:**
   ```bash
   flutter run -d chrome --web-port=5005
   ```

### Build for Production

```bash
# Android APK (Release)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Android APK (Split by architecture - smaller size)
flutter build apk --split-per-abi --release

# Android App Bundle (for Google Play Store)
flutter build appbundle --release

# Web (for deployment)
flutter build web --release
# Output: build/web/

# Windows
flutter build windows --release

# iOS (requires macOS and Xcode)
flutter build ios --release
```

📖 **Detailed build instructions:** See [BUILD_APK_GUIDE.md](BUILD_APK_GUIDE.md) for APK building guide.

---

## 🌐 Deployment

### Web Deployment (Vercel)

The app is configured for easy deployment on Vercel:

1. **Automatic Deployment:**
   - Push to GitHub: `git push origin main`
   - Vercel automatically builds and deploys

2. **Manual Deployment:**
   ```bash
   # Install Vercel CLI
   npm install -g vercel
   
   # Login
   vercel login
   
   # Deploy
   vercel --prod
   ```

3. **Configuration:**
   - Build Command: `bash build.sh`
   - Output Directory: `build/web`
   - Framework Preset: Other

📖 **Full deployment guide:** See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed instructions.

### Live Demo

🌐 **Web App:** [Deployed on Vercel](https://voice-notes-plus.vercel.app) (if deployed)

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

- **Microphone Permission**: Recording requires microphone permission on all platforms
- **Speech Recognition**: Quality depends on audio clarity, background noise, and accent
- **Web Platform**: Microphone access requires HTTPS (works automatically on Vercel)
- **Language Support**: Speech recognition works best with languages supported by device
- **Performance**: Large note collections (1000+) may have slight performance impact
- **Android SDK**: Required for building APK (see [BUILD_APK_GUIDE.md](BUILD_APK_GUIDE.md))

---

## 📈 Future Enhancements

- 📤 Cloud sync option (optional, privacy-preserving)
- 🌍 Multi-language support
- 📊 Analytics dashboard (local only)
- 🎨 Theme customization
- 📤 Export notes as PDF/Text
- 🔐 Biometric authentication
- 🤖 AI-powered note summaries
- 📱 Progressive Web App (PWA) features
- 🔄 Auto-backup to local storage

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

## 📚 Additional Documentation

- 📖 [Deployment Guide](DEPLOYMENT.md) - Deploy to Vercel
- 📱 [APK Build Guide](BUILD_APK_GUIDE.md) - Build Android APK
- 🏗️ [Project Details](PROJECT_DETAILS.md) - Technical documentation
- 📋 [Product Requirements](PRD.md) - Product specifications

---

## 👨‍💻 Author

**Raj Aryan**
- GitHub: [@raj-aryan-official](https://github.com/raj-aryan-official)
- Repository: [VoiceNotePlus](https://github.com/raj-aryan-official/VoiceNotePlus)

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
