# Voice Notes Plus

Voice Notes Plus is a powerful and intuitive Flutter application designed for seamless voice recording and real-time transcription. Capture your thoughts, meetings, and ideas effortlessly with continuous recording, automatic transcription, and easy organization.

## Features

*   **Real-time Transcription:** Instantly converts your speech to text as you record.
*   **Continuous Recording:** Records and transcribes continuously, handling pauses and silence intelligently without stopping until you're done.
*   **Visual Feedback:** Features a custom animated waveform that reacts to your recording status.
*   **Organization:**
    *   **Tagging:** Add custom tags to your notes for easy categorization (e.g., "work", "ideas", "urgent").
    *   **Favorites:** Mark important notes as "Liked" for quick access.
    *   **Search:** Powerful search functionality to find notes by title, content, or tags.
*   **Note Management:**
    *   Edit transcripts, titles, and tags at any time.
    *   Delete unwanted notes with confirmation.
    *   Share your note transcripts directly to other apps (email, messaging, etc.).
*   **Local Storage:** All notes are saved locally on your device using Hive for fast and offline access.
*   **Modern UI:** Built with Material Design 3, featuring a clean Teal color scheme and smooth animations.

## Getting Started

### Prerequisites

*   [Flutter SDK](https://flutter.dev/docs/get-started/install)
*   Android Studio or VS Code with Flutter extensions
*   An Android device or emulator (for microphone access)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/raj-aryan-official/VoiceNotePlus.git
    cd VoiceNotePlus
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    flutter run
    ```

### Building the APK

To build a release APK for Android:

```bash
flutter build apk --release
```

The APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

## Dependencies

*   [flutter](https://flutter.dev/)
*   [speech_to_text](https://pub.dev/packages/speech_to_text) - For speech recognition.
*   [hive](https://pub.dev/packages/hive) & [hive_flutter](https://pub.dev/packages/hive_flutter) - For local database storage.
*   [permission_handler](https://pub.dev/packages/permission_handler) - For managing microphone permissions.
*   [intl](https://pub.dev/packages/intl) - For date formatting.
*   [share_plus](https://pub.dev/packages/share_plus) - For sharing content.
*   [path_provider](https://pub.dev/packages/path_provider) - For filesystem access.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
