import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_helper.dart';
import 'dart:async';

/// ====== CUSTOM WAVEFORM VISUALIZATION ======
/// 
/// WaveformPainter - Custom painter for animated audio waveform
/// Displays visual feedback during voice recording with animated bars
/// 
/// Features:
///   - Animated wave effect: bars move left to right
///   - Height variation based on position from wave center
///   - Randomized heights for audio-like appearance
///   - Only renders when actively listening/recording
///   - Efficient repainting based on animation value changes
class WaveformPainter extends CustomPainter {
  /// Current animation frame value (0.0 to 1.0)
  /// Controls the position of the animated wave
  final double animationValue;
  
  /// Recording state flag
  /// true = actively listening, render waveform
  /// false = not listening, skip rendering
  final bool isListening;
  
  WaveformPainter({required this.animationValue, required this.isListening});
  
  /// Paint the animated waveform bars on canvas
  /// 
  /// Algorithm:
  ///   1. Skip if not listening (optimize rendering)
  ///   2. Calculate bar dimensions and spacing
  ///   3. For each bar, calculate height based on distance from wave
  ///   4. Add randomness for natural audio effect
  ///   5. Draw vertical lines (bars) on canvas
  @override
  void paint(Canvas canvas, Size size) {
    if (!isListening) return;
    
    // Paint configuration for bars
    final paint = Paint()
      ..color = Colors.white          // White bars
      ..strokeWidth = 3               // Bar thickness
      ..strokeCap = StrokeCap.round;  // Rounded ends
    
    final centerY = size.height / 2;  // Center vertical position
    final width = size.width;          // Canvas width
    final barWidth = 4.0;              // Individual bar width
    final spacing = 6.0;               // Space between bars
    final numBars = ((width / (barWidth + spacing))).toInt();  // Total bars to draw
    
    // Draw each bar
    for (int i = 0; i < numBars; i++) {
      final x = i * (barWidth + spacing) + barWidth / 2;
      
      // ====== WAVE EFFECT CALCULATION ======
      // Create left-to-right wave by calculating distance from wave position
      final waveOffset = (animationValue * numBars) % numBars;
      final distanceFromWave = ((i - waveOffset).abs() % numBars).toInt();
      
      // ====== HEIGHT VARIATION ======
      // Bars closest to wave are tallest, gradually decrease away from wave
      double height = 8 + (1 - (distanceFromWave / (numBars / 2))) * 30;
      if (distanceFromWave > numBars / 2) {
        height = 8;  // Reset to minimum after halfway point
      }
      
      // ====== RANDOMNESS FOR AUDIO EFFECT ======
      // Add subtle variation based on bar index for natural audio-like appearance
      height += (i % 3) * 4.0;
      
      // Draw vertical line (bar) at position x
      canvas.drawLine(
        Offset(x, centerY - height / 2),       // Top point
        Offset(x, centerY + height / 2),       // Bottom point
        paint,
      );
    }
  }
  
  /// Determine if repainting is needed
  /// Repaints when animation value or listening state changes
  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isListening != isListening;
  }
}

/// ====== ADD NOTE SCREEN WIDGET ======
/// 
/// AddNoteScreen - Screen for recording voice notes with real-time transcription
/// Features:
///   - Real-time speech-to-text conversion (via speech_to_text plugin)
///   - Animated waveform visualization during recording
///   - Three-state recording: stopped, recording, paused
///   - Manual transcript editing
///   - Title, content, and tags management
///   - Save with database persistence
class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

/// State class for AddNoteScreen
/// Manages:
///   - Speech recognition lifecycle
///   - Timer for recording duration
///   - Waveform animation
///   - Three-state recording control (stopped/recording/paused)
///   - Text field controllers and content
class _AddNoteScreenState extends State<AddNoteScreen> with TickerProviderStateMixin {
  // ====== SPEECH RECOGNITION ======
  /// SpeechToText instance for converting voice to text
  /// Lazy initialized in initState
  late stt.SpeechToText _speech;
  
  /// Recording state: true when actively listening to microphone
  /// Used to control mic button color and appearance
  bool _isListening = false;
  
  /// Pause state: true when recording is paused (not listening but can resume)
  /// Enables three-state control: stopped → recording → paused → recording
  bool _isPaused = false;
  
  /// Current recognized text from speech recognition
  /// Gets cleared and combined with _previousText
  String _text = '';
  
  /// Accumulated text from previous recognition sessions
  /// Preserves content when recording is paused and resumed
  String _previousText = '';
  
  // ====== TEXT CONTROLLERS ======
  /// Controller for note title TextField
  /// Auto-populated with current date/time if not provided
  final TextEditingController _titleController = TextEditingController();
  
  /// Controller for transcript/content TextArea
  /// Pre-populated with recognized speech in real-time
  /// Can be manually edited by user
  final TextEditingController _contentController = TextEditingController();
  
  /// Controller for tags TextField
  /// Comma-separated tags for categorizing notes
  final TextEditingController _tagsController = TextEditingController();
  
  /// Current status message displayed to user
  /// Updated with recording state changes
  String _statusText = 'Tap microphone to start recording';
  
  // ====== TIMER VARIABLES ======
  /// Timer object for tracking recording duration
  /// Null when not recording, active when recording
  Timer? _timer;
  
  /// Elapsed seconds since recording started
  /// Displayed to user and reset on new recording
  int _seconds = 0;
  
  // ====== ANIMATION VARIABLES ======
  /// AnimationController for waveform bar animation
  /// Duration: 1500ms for smooth continuous animation
  late AnimationController _waveController;
  
  /// Animation value (0.0 to 1.0) driving waveform visual effect
  /// Value passed to WaveformPainter for bar height calculation
  late Animation<double> _waveAnimation;
  
  /// ====== LIFECYCLE: INITIALIZATION ======
  @override
  void initState() {
    super.initState();
    
    // Initialize SpeechToText plugin
    _speech = stt.SpeechToText();
    _initSpeech();  // Request microphone permission
    
    // ====== WAVEFORM ANIMATION SETUP ======
    // Create animation controller for 1500ms continuous loop
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,  // Using TickerProviderStateMixin
    );
    
    // Create animation: 0.0 → 1.0 with linear curve (constant speed)
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );
  }

  /// ====== MICROPHONE PERMISSION ======
  /// Request microphone permission from user
  /// Called during initialization before any recording
  void _initSpeech() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  /// ====== TIME FORMATTING ======
  /// Convert seconds to MM:SS format for display
  /// 
  /// Example:
  ///   - 5 seconds → "00:05"
  ///   - 65 seconds → "01:05"
  ///   - 125 seconds → "02:05"
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// ====== TIMER MANAGEMENT ======
  /// Start a 1-second repeating timer to track recording duration
  /// Also starts the waveform animation
  void _startTimer() {
    _timer?.cancel();  // Cancel any existing timer
    // Create new timer: increments _seconds every 1 second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
    
    // Start waveform animation (repeats continuously)
    if (!_waveController.isAnimating) {
      _waveController.repeat();  // Loop animation until stopped
    }
  }

  /// ====== TIMER STOP ======
  /// Stop the recording timer and waveform animation
  void _stopTimer() {
    _timer?.cancel();
    _waveController.stop();
  }

  /// ====== RECORDING RESET ======
  /// Reset all recording state and controllers
  /// Called when user clicks "Reset" button
  void _resetRecording() {
    _stopTimer();
    if (mounted) {
      setState(() {
        _seconds = 0;              // Reset timer
        _text = '';                // Clear current recognition
        _previousText = '';        // Clear accumulated text
        _contentController.clear();    // Clear transcript
        _isListening = false;      // Not recording
        _isPaused = false;         // Not paused
        _statusText = 'Recording reset. Tap microphone to start again.';
      });
    }
  }

  /// ====== THREE-STATE RECORDING CONTROL ======
  /// 
  /// Main method handling all recording state transitions
  /// Implements three-state recording: STOPPED → RECORDING → PAUSED
  /// 
  /// STATE 1 (Stopped): _isListening=false, _isPaused=false
  ///   - User taps mic → START RECORDING
  /// 
  /// STATE 2 (Recording): _isListening=true, _isPaused=false
  ///   - User taps mic → PAUSE RECORDING
  /// 
  /// STATE 3 (Paused): _isListening=false, _isPaused=true
  ///   - User taps mic → RESUME RECORDING
  ///   - User clicks save → SAVE NOTE
  void _listen() async {
    if (!_isListening && !_isPaused) {
      // ====== STATE 1 → STATE 2: START RECORDING ======
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          if ((val == 'done' || val == 'notListening') && _isListening && !_isPaused) {
            _startListening();
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available && mounted) {
        setState(() {
          _isListening = true;    // Now recording
          _isPaused = false;      // Not paused
        });
        _startListening();  // Begin speech recognition
      }
    } else if (_isListening && !_isPaused) {
      // ====== STATE 2 → STATE 3: PAUSE RECORDING ======
      _speech.stop();     // Stop listening
      _stopTimer();       // Stop timer (waveform stops)
      if (mounted) {
        setState(() {
          _isListening = false;   // Not listening
          _isPaused = true;       // In paused state
          _statusText = 'Recording paused. Tap to resume or save.';
        });
      }
    } else if (_isPaused) {
      // ====== STATE 3 → STATE 2: RESUME RECORDING ======
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          if ((val == 'done' || val == 'notListening') && _isListening && !_isPaused) {
            _startListening();
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available && mounted) {
        setState(() {
          _isListening = true;    // Resume listening
          _isPaused = false;      // No longer paused
        });
        _startListening();  // Resume speech recognition
      }
    }
  }

  /// ====== START SPEECH RECOGNITION ======
  /// Begin listening to microphone and converting speech to text
  /// Callback processes recognized words continuously
  void _startListening() {
    if (!mounted) return;
    
    _startTimer();  // Start recording timer and waveform animation
    
    setState(() {
      _statusText = 'Recording...';
      _previousText = _contentController.text;  // Save current content
    });
    
    // Listen to microphone with 60-second silence timeout
    _speech.listen(
      pauseFor: const Duration(seconds: 60),  // Stop listening after 60s silence
      onResult: (val) {
        if (mounted) {
          setState(() {
            _text = val.recognizedWords;  // Get recognized text
            // Combine previous accumulated text with new text
            if (_previousText.isNotEmpty) {
              _contentController.text = '$_previousText $_text';
            } else {
              _contentController.text = _text;
            }
          });
        }
      },
    );
  }

  /// ====== SAVE NOTE DIALOG ======
  /// Show dialog for user to confirm title, tags, and save recording
  /// 
  /// Dialog features:
  ///   - Title TextField: edit or auto-fill with current date/time
  ///   - Tags TextField: comma-separated categories
  ///   - Duration display: shows recording length
  ///   - Discard button: cancels save and resets recording
  ///   - Save button: persists note to database
  void _showSaveDialog() {
    if (_titleController.text.isEmpty) {
      // Auto-fill title with current date/time if not provided
      _titleController.text = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    }

    showDialog(
      context: context,
      barrierDismissible: false,  // Must explicitly dismiss dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Recording'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title field
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter note title',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                // Tags field
                TextField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags',
                    hintText: 'e.g., work, personal, urgent',
                    prefixIcon: Icon(Icons.local_offer),
                  ),
                ),
                const SizedBox(height: 16),
                // Recording duration display
                Text(
                  'Duration: ${_formatTime(_seconds)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            // Discard button
            TextButton(
              onPressed: () {
                _contentController.clear();
                _tagsController.clear();
                _titleController.clear();
                _text = '';
                _previousText = '';
                _resetRecording();
                Navigator.of(context).pop();
              },
              child: const Text('Discard', style: TextStyle(color: Color(0xFFF44336))),
            ),
            // Save button
            TextButton(
              onPressed: () {
                _stopTimer();
                Navigator.of(context).pop();
                _saveNote();  // Call save after dialog closes
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// ====== SAVE NOTE TO DATABASE ======
  /// 
  /// Process:
  ///   1. Stop recording and speech recognition
  ///   2. Format note data (title, content, timestamp, tags)
  ///   3. Save to database via DatabaseHelper
  ///   4. Show success SnackBar
  ///   5. Clear all fields and reset state
  ///   6. Return to home screen
  void _saveNote() async {
    if (_contentController.text.isEmpty) return;

    // Stop timer and recording
    _stopTimer();
    _speech.stop();

    // Generate title if empty
    String title = _titleController.text.isNotEmpty
        ? _titleController.text
        : 'Note ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}';

    // Prepare note data map
    Map<String, dynamic> note = {
      'title': title,
      'content': _contentController.text,
      'dateTime': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'tags': _tagsController.text,
      'isLiked': false,
      'recordingPath': '',
    };

    if (mounted) {
      // Save to database (auto-generates unique ID)
      await DatabaseHelper().insertNote(note);
      
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note saved successfully'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      
      // Clear all fields
      _contentController.clear();
      _titleController.clear();
      _tagsController.clear();
      _text = '';
      _previousText = '';
      _seconds = 0;
      
      if (mounted) {
        // Pop screen and return to home with true flag (indicates note was saved)
        Navigator.of(context).pop(true);
      }
    }
  }

  /// ====== CLEANUP ======
  /// Called when widget is disposed
  /// Stops recording and disposes all resources
  @override
  void dispose() {
    _stopTimer();               // Cancel timer if running
    _speech.stop();             // Stop speech recognition
    _waveController.dispose();  // Dispose animation controller
    _titleController.dispose();      // Dispose text controllers
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  /// ====== UI BUILD METHOD ======
  /// Main method creating the add note screen layout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ====== APP BAR ======
      appBar: AppBar(
        title: const Text('Add New Note'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // ====== RECORDING VISUALIZATION SECTION ======
          // Teal gradient background with waveform animation and status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00695C),  // Dark teal
                  Color(0xFF00897B),  // Medium teal
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // ====== WAVEFORM ANIMATION ======
                // Animated bars showing recording activity
                AnimatedBuilder(
                  animation: _waveAnimation,
                  builder: (context, child) {
                    return SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: WaveformPainter(
                          animationValue: _waveAnimation.value,
                          isListening: _isListening,  // Only renders when recording
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // ====== STATUS TEXT ======
                // Current recording state message
                Text(
                  _statusText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // ====== TRANSCRIPT TEXTAREA ======
          // Main content area for speech-to-text and manual editing
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00897B), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: null,         // Unlimited lines
                expands: true,          // Fill available space
                readOnly: false,        // User can edit
                decoration: const InputDecoration(
                  hintText: 'Your speech will appear here... (You can also edit manually)',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12.0),
                  filled: true,
                  fillColor: Color(0xFFE0F2F1),  // Light teal
                ),
              ),
            ),
          ),

          // ====== CONTROL BUTTONS ======
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ====== RESET BUTTON ======
                // Yellow button: clears all content and resets recording
                FloatingActionButton.extended(
                  heroTag: 'fab_reset',
                  onPressed: _resetRecording,
                  backgroundColor: const Color(0xFFFFE082),  // Yellow
                  foregroundColor: Colors.black87,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
                
                // ====== MIC BUTTON (THREE-STATE) ======
                // Red when recording, teal when stopped/paused
                // Icon changes: mic → pause → play
                FloatingActionButton(
                  heroTag: 'fab_mic',
                  onPressed: _listen,  // Handles all state transitions
                  // Red when recording, teal otherwise
                  backgroundColor: _isListening ? const Color(0xFFF44336) : const Color(0xFF00695C),
                  // Icon based on state: pause (recording), play (paused), mic (stopped)
                  child: Icon(
                    _isListening ? Icons.pause : (_isPaused ? Icons.play_arrow : Icons.mic_none),
                    size: 28,
                  ),
                ),
                
                // ====== SAVE BUTTON ======
                // Green button: only visible when paused or has content
                // Conditionally rendered based on recording state
                if (_isPaused || _contentController.text.isNotEmpty)
                  FloatingActionButton.extended(
                    heroTag: 'fab_save',
                    onPressed: () {
                      if (_contentController.text.isNotEmpty) {
                        _showSaveDialog();  // Show save confirmation dialog
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please record some audio before saving'),
                            backgroundColor: Color(0xFFF44336),  // Red error
                          ),
                        );
                      }
                    },
                    backgroundColor: const Color(0xFF4CAF50),  // Green
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.check),
                    label: const Text('Save'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
