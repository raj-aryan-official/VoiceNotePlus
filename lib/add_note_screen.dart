import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_helper.dart';
import 'dart:async';

// Custom Waveform Painter
class WaveformPainter extends CustomPainter {
  final double animationValue;
  final bool isListening;
  
  WaveformPainter({required this.animationValue, required this.isListening});
  
  @override
  void paint(Canvas canvas, Size size) {
    if (!isListening) return;
    
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    final centerY = size.height / 2;
    final width = size.width;
    final barWidth = 4.0;
    final spacing = 6.0;
    final numBars = ((width / (barWidth + spacing))).toInt();
    
    for (int i = 0; i < numBars; i++) {
      final x = i * (barWidth + spacing) + barWidth / 2;
      
      // Create wave effect - bars move from left to right
      final waveOffset = (animationValue * numBars) % numBars;
      final distanceFromWave = ((i - waveOffset).abs() % numBars).toInt();
      
      // Height varies based on distance from wave
      double height = 8 + (1 - (distanceFromWave / (numBars / 2))) * 30;
      if (distanceFromWave > numBars / 2) {
        height = 8;
      }
      
      // Add some randomness for audio-like effect
      height += (i % 3) * 4.0;
      
      canvas.drawLine(
        Offset(x, centerY - height / 2),
        Offset(x, centerY + height / 2),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isListening != isListening;
  }
}

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> with TickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isPaused = false;
  String _text = '';
  String _previousText = '';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String _statusText = 'Tap microphone to start recording';
  
  // Timer variables
  Timer? _timer;
  int _seconds = 0;
  
  // Animation variables
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
    
    // Initialize waveform animation
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );
  }

  void _initSpeech() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
    
    // Start waveform animation
    if (!_waveController.isAnimating) {
      _waveController.repeat();
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _waveController.stop();
  }

  void _resetRecording() {
    _stopTimer();
    if (mounted) {
      setState(() {
        _seconds = 0;
        _text = '';
        _previousText = '';
        _contentController.clear();
        _isListening = false;
        _isPaused = false;
        _statusText = 'Recording reset. Tap microphone to start again.';
      });
    }
  }

  void _listen() async {
    if (!_isListening && !_isPaused) {
      // Start recording
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
        },
        onError: (val) => print('onError: $val'),
      );
      if (available && mounted) {
        setState(() {
          _isListening = true;
          _isPaused = false;
        });
        _startListening();
      }
    } else if (_isListening && !_isPaused) {
      // Pause recording
      _speech.stop();
      _stopTimer();
      if (mounted) {
        setState(() {
          _isListening = false;
          _isPaused = true;
          _statusText = 'Recording paused. Tap to resume or save.';
        });
      }
    } else if (_isPaused) {
      // Resume recording
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
        },
        onError: (val) => print('onError: $val'),
      );
      if (available && mounted) {
        setState(() {
          _isListening = true;
          _isPaused = false;
        });
        _startListening();
      }
    }
  }

  void _startListening() {
    if (!mounted) return;
    _startTimer();
    setState(() {
      _statusText = 'Recording...';
      _previousText = _contentController.text;
    });
    _speech.listen(
      pauseFor: const Duration(seconds: 30),
      onResult: (val) {
        if (mounted) {
          setState(() {
            _text = val.recognizedWords;
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

  void _showSaveDialog() {
    if (_titleController.text.isEmpty) {
      _titleController.text = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Recording'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter note title',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags',
                    hintText: 'e.g., work, personal, urgent',
                    prefixIcon: Icon(Icons.local_offer),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Duration: ${_formatTime(_seconds)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
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
            TextButton(
              onPressed: () {
                _stopTimer();
                Navigator.of(context).pop();
                _saveNote();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveNote() async {
    if (_contentController.text.isEmpty) return;

    // Stop timer and recording
    _stopTimer();
    _speech.stop();

    String title = _titleController.text.isNotEmpty
        ? _titleController.text
        : 'Note ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}';

    Map<String, dynamic> note = {
      'title': title,
      'content': _contentController.text,
      'dateTime': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'tags': _tagsController.text,
      'isLiked': false,
      'recordingPath': '',
    };

    if (mounted) {
      await DatabaseHelper().insertNote(note);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note saved successfully'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      // Clear fields
      _contentController.clear();
      _titleController.clear();
      _tagsController.clear();
      _text = '';
      _previousText = '';
      _seconds = 0;
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _speech.stop();
    _waveController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Note'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Recording Indicator with Waveform Animation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00695C),
                  Color(0xFF00897B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // Waveform Visualization
                AnimatedBuilder(
                  animation: _waveAnimation,
                  builder: (context, child) {
                    return SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: WaveformPainter(
                          animationValue: _waveAnimation.value,
                          isListening: _isListening,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Status Text
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
          
          // Transcript Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00897B), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                readOnly: false,
                decoration: const InputDecoration(
                  hintText: 'Your speech will appear here... (You can also edit manually)',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12.0),
                  filled: true,
                  fillColor: Color(0xFFE0F2F1),
                ),
              ),
            ),
          ),

          // Control Buttons
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reset Button
                FloatingActionButton.extended(
                  heroTag: 'fab_reset',
                  onPressed: _resetRecording,
                  backgroundColor: const Color(0xFFFFE082),
                  foregroundColor: Colors.black87,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
                
                // Mic Button (Record/Pause/Resume)
                FloatingActionButton(
                  heroTag: 'fab_mic',
                  onPressed: _listen,
                  backgroundColor: _isListening ? const Color(0xFFF44336) : const Color(0xFF00695C),
                  child: Icon(
                    _isListening ? Icons.pause : (_isPaused ? Icons.play_arrow : Icons.mic_none),
                    size: 28,
                  ),
                ),
                
                // Save Button (always visible when paused or has content)
                if (_isPaused || _contentController.text.isNotEmpty)
                  FloatingActionButton.extended(
                    heroTag: 'fab_save',
                    onPressed: () {
                      if (_contentController.text.isNotEmpty) {
                        _showSaveDialog();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please record some audio before saving'),
                            backgroundColor: Color(0xFFF44336),
                          ),
                        );
                      }
                    },
                    backgroundColor: const Color(0xFF4CAF50),
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
