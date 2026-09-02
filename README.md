# 🎙️ Voice Notes Plus

<div align="center">

![Voice Notes Plus Banner](https://img.shields.io/badge/Voice_Notes_Plus-v1.0.0-teal?style=for-the-badge&logo=flutter&logoColor=white)

**A high-performance, offline-first voice recording & real-time speech-to-text note-taking application.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4.3+-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Database](https://img.shields.io/badge/Database-Hive%20NoSQL-FFA000?style=flat-square&logo=hive&logoColor=white)](https://pub.dev/packages/hive)
[![Platform Support](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-4CAF50?style=flat-square)](#-platform-support)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)

</div>

---

## 📖 Table of Contents
- [✨ Overview](#-overview)
- [🎯 Real-World Use Cases](#-real-world-use-cases)
- [🚀 Key Features](#-key-features)
- [🛠️ Tech Stack & Dependencies](#️-tech-stack--dependencies)
- [🏛️ Architecture & Design Patterns](#️-architecture--design-patterns)
- [📁 Project & Directory Structure](#-project--directory-structure)
- [📱 Platform Support](#-platform-support)
- [⚡ Quick Start Guide](#-quick-start-guide)
- [📦 Building & Deployment](#-building--deployment)
  - [Android APK Build](#android-apk-build)
  - [Web Release (Vercel Deployment)](#web-release-vercel-deployment)
- [🔒 Security & Privacy First](#-security--privacy-first)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## ✨ Overview

**Voice Notes Plus** is an intuitive, distraction-free voice productivity application designed for effortless thought capture. By combining continuous voice recording, instantaneous speech-to-text conversion, and local-first persistence, Voice Notes Plus eliminates friction between thinking and recording. 

Whether you are in a boardroom, a lecture hall, or on the road, Voice Notes Plus transcribes your voice in real time with an animated visual waveform, organizes notes through smart tagging, and stores everything securely on your local device with zero cloud dependency.

---

## 🎯 Real-World Use Cases

| Persona / Context | Practical Application |
|---|---|
| 💼 **Busy Professionals & Executives** | Instantly record meeting summaries, capture rapid action items, and dictate follow-up emails right after calls. |
| 🎓 **Students & Researchers** | Transcribe lectures, record research insights, capture study notes, and organize them by subjects via tags. |
| 🚗 **Commuters & Drivers** | Hands-free note capture on the move without having to look at or type on a keyboard. |
| ✍️ **Writers, Journalists & Creators** | Capture stream-of-consciousness ideas, story drafts, interview dialogues, and podcast outlines anytime. |
| 📋 **Everyday Personal Productivity** | Maintain daily voice journals, shopping checklists, quick reminders, and categorized to-do lists. |

---

## 🚀 Key Features

### 🎙️ Real-Time Speech-to-Text
- Real-time conversion powered by the device's native speech recognition engine.
- Instant transcript rendering as you speak.
- Editable transcript text area for quick post-recording corrections.

### 🌊 Dynamic Animated Audio Waveform
- Custom canvas-painted sinusoidal waveform visualization (`WaveformPainter`).
- Reacts actively to recording state changes for rich visual feedback.

### 🏷️ Smart Categorization & Tagging
- Assign unlimited comma-separated tags (e.g., `work`, `meeting`, `ideas`, `urgent`).
- Dedicated tag badges and chips for rapid visual identification.
- Edit tags directly from the home screen or detail view.

### ❤️ Quick Access & Favorites
- One-tap "Liked" toggle to bookmark crucial notes.
- Instant filtering to isolate starred notes from general entries.

### 🔍 Instant Multi-Field Search
- High-speed real-time search across note **titles**, **transcripts**, and **tags**.
- Dynamic query execution directly on the local Hive database.

### 📤 Native Sharing & Export
- Integrated with the OS-level native share sheet (`share_plus`).
- Export formatted transcripts to WhatsApp, Slack, Gmail, Google Drive, or any messaging app.

### 🔒 100% Offline & Private
- **Local-First Architecture**: All database operations and recordings reside strictly on your device.
- Zero tracking, zero telemetry, and zero mandatory cloud accounts.

### 🎨 Material Design 3 Aesthetics
- Clean and modern Teal palette (`#00695C`, `#00897B`, `#26A69A`, `#E0F2F1`).
- Custom animated Splash Screen, fluid transitions, and responsive widgets.

---

## 🛠️ Tech Stack & Dependencies

### Core Framework & Language
- **[Flutter 3.x](https://flutter.dev/)**: Cross-platform UI toolkit.
- **[Dart 3.4.3+](https://dart.dev/)**: Strongly typed, sound null-safe client language.
- **Material Design 3**: Modern component styling and thematic design system.

### Packages & Libraries

| Package | Version | Purpose |
|---|---|---|
| **`speech_to_text`** | `^7.3.0` | Native speech recognition and real-time audio transcription |
| **`hive`** | `^2.2.3` | Lightweight, blazingly fast NoSQL key-value database |
| **`hive_flutter`** | `^1.1.0` | Flutter extension and lifecycle management for Hive |
| **`permission_handler`**| `^12.0.0` | Cross-platform runtime permission handling (Microphone, Storage) |
| **`share_plus`** | `^10.0.0` | Access to native OS sharing dialogs |
| **`path_provider`** | `^2.1.0` | Device filesystem path resolution for app storage |
| **`intl`** | `^0.19.0` | Timestamp formatting and internationalization helpers |
| **`cupertino_icons`** | `^1.0.6` | iOS-styled iconography |

---

## 🏛️ Architecture & Design Patterns

Voice Notes Plus adopts the **Model-View-Controller (MVC)** and **Repository** architectural patterns to guarantee maintainability, high testability, and clear separation of concerns.

```
┌──────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER (UI)                │
│  ┌──────────────┐   ┌───────────────┐   ┌──────────────┐ │
│  │ SplashScreen │   │  HomeScreen   │   │ AddNoteScreen│ │
│  └──────┬───────┘   └───────┬───────┘   └──────┬───────┘ │
│         │                   │                  │         │
│         └───────────────────┼──────────────────┘         │
│                             │                            │
│                   ┌─────────▼──────────┐                 │
│                   │  NoteDetailScreen  │                 │
│                   └─────────┬──────────┘                 │
└─────────────────────────────┼────────────────────────────┘
                              │
┌─────────────────────────────▼────────────────────────────┐
│                  STATE & SERVICE LAYER                   │
│  ├─ SpeechToText Controller (Continuous Recognition)     │
│  ├─ Waveform Animation Controller (CustomPainter)        │
│  └─ SharePlus Service (Native Sharing)                   │
└─────────────────────────────┬────────────────────────────┘
                              │
┌─────────────────────────────▼────────────────────────────┐
│               BUSINESS LOGIC & DATA ACCESS               │
│  ┌────────────────────────────────────────────────────┐  │
│  │     DatabaseHelper (Thread-Safe Singleton)         │  │
│  │  ├─ initialize()      ├─ searchNotes()             │  │
│  │  ├─ addNote()         ├─ toggleLike()              │  │
│  │  ├─ getNotes()        ├─ deleteNote()              │  │
│  │  └─ updateNote()      └─ updateTags()              │  │
│  └──────────────────────────┬─────────────────────────┘  │
└─────────────────────────────┼────────────────────────────┘
                              │
┌─────────────────────────────▼────────────────────────────┐
│                    PERSISTENCE LAYER                     │
│  ├─ Hive Box<Map> ('notes') [Encrypted/Key-Value NoSQL]  │
│  └─ Device File System (App Documents Directory)         │
└──────────────────────────────────────────────────────────┘
```

### Key Architectural Highlights:
1. **Singleton Database Manager (`DatabaseHelper`)**: Single-point database controller with built-in corrupt-box recovery and monotonic ID sequencing.
2. **Type-Safe Data Model (`Note`)**: Immutable model with comprehensive `toMap()` serialization and `fromMap()` null-safe deserialization.
3. **Custom Canvas Rendering (`WaveformPainter`)**: Hardware-accelerated 60fps waveform animation rendered directly to canvas without heavy third-party audio visualizers.

---

## 📁 Project & Directory Structure

```
VoiceNotePlus/
├── android/                  # Android native project & Manifest permissions
├── ios/                      # iOS native project, Podfile & Info.plist
├── web/                      # Web support entrypoints and manifest
├── windows/                  # Windows desktop configuration
├── macos/                    # macOS native configuration
├── linux/                    # Linux desktop configuration
├── lib/                      # Core Flutter source code
│   ├── main.dart             # App initialization, Hive init & Theme setup
│   ├── splash_screen.dart    # Animated branding splash screen (3s delay)
│   ├── home_screen.dart      # Main dashboard, search bar & note cards
│   ├── add_note_screen.dart  # Voice recording, waveform & STT engine
│   ├── note_detail_screen.dart # Transcript view, inline editor & sharing
│   ├── note_model.dart       # Note data class with serialization
│   └── database_helper.dart  # Hive database singleton & CRUD methods
├── pubspec.yaml              # Package dependencies & configuration
├── PRD.md                    # Detailed Product Requirements Document
├── PROJECT_DETAILS.md        # Comprehensive technical documentation
├── BUILD_APK_GUIDE.md        # Android release build manual
└── README.md                 # Project README
```

---

## 📱 Platform Support

| Platform | Minimum Version | Status |
|---|---|---|
| 🤖 **Android** | Android 5.0 (API Level 21+) | ✅ Fully Supported & Tested |
| 🍎 **iOS** | iOS 11.0+ | ✅ Supported |
| 🌐 **Web** | Chrome, Firefox, Safari, Edge | ✅ Supported |
| 💻 **Windows** | Windows 10+ | ✅ Supported |
| 🐧 **Linux** | Ubuntu 20.04+ | ✅ Supported |
| 🍏 **macOS** | macOS 10.15+ | ✅ Supported |

---

## ⚡ Quick Start Guide

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>= 3.4.3`)
- [Dart SDK](https://dart.dev/get-dart) (`>= 3.4.3 < 4.0.0`)
- Android Studio / VS Code with Flutter extensions
- Physical device or emulator with microphone support

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/raj-aryan-official/VoiceNotePlus.git
   cd VoiceNotePlus
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify Flutter setup:**
   ```bash
   flutter doctor
   ```

4. **Launch the application:**
   ```bash
   flutter run
   ```

---

## 📦 Building & Deployment

### Android APK Build

To generate an optimized, standalone release APK:

```bash
# Clean previous builds
flutter clean

# Fetch dependencies
flutter pub get

# Build release APK
flutter build apk --release
```

The output APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

*(For split-per-ABI builds to reduce APK size to ~15MB, run `flutter build apk --split-per-abi`)*

---

### Web Release (Vercel Deployment)

1. **Build Flutter Web bundle:**
   ```bash
   flutter build web --release
   ```

2. **Deploy using Vercel CLI:**
   ```bash
   npm install -g vercel
   vercel login
   vercel --prod
   ```

---

## 🔒 Security & Privacy First

- 🛡️ **Zero Cloud Storage**: Notes and audio data are never uploaded to any remote server.
- 🎤 **Explicit Permissions**: Microphone access is requested only when the recording screen is active.
- 🗄️ **Sandboxed Database**: Hive data boxes are stored strictly within the application's secure documents directory.

---

## 🤝 Contributing

Contributions, bug reports, and feature requests are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Made with ❤️ by [Raj Aryan](https://github.com/raj-aryan-official)

</div>
