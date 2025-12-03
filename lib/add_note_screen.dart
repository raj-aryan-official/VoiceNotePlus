import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_helper.dart';
import 'dart:async';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  String _previousText = '';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String _statusText = 'Tap microphone to start recording';
  
  // Timer variables
  Timer? _timer;
  int _seconds = 0;
  
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
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
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _resetRecording() {
    _stopTimer();
    if (mounted) {
      setState(() {
        _seconds = 0;
        _text = '';
        _previousText = '';
        _contentController.clear();
        _statusText = 'Recording reset. Tap microphone to start again.';
      });
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          if (val == 'done' || val == 'notListening') {
            if (_isListening && mounted) {
              _startListening();
            } else if (mounted) {
              _stopTimer();
              setState(() {
                _statusText = 'Recording stopped. Tap microphone to continue.';
              });
              // Auto-show save dialog if there's content
              if (_contentController.text.isNotEmpty) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    _showSaveDialog();
                  }
                });
              }
            }
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available && mounted) {
        setState(() {
          _isListening = true;
        });
        _startListening();
      }
    } else {
      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }
      _speech.stop();
      _stopTimer();
      if (mounted) {
        setState(() {
          _statusText = 'Recording stopped. Tap microphone to continue.';
        });
        // Auto-show save dialog if there's content
        if (_contentController.text.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _showSaveDialog();
            }
          });
        }
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
              child: const Text('Discard', style: TextStyle(color: Color(0xFFEF9A9A))),
            ),
            TextButton(
              onPressed: () {
                _saveNote();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
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

    await DatabaseHelper().insertNote(note);
  }

  @override
  void dispose() {
    _stopTimer();
    _speech.stop();
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
          // Timer Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF9575CD),
                  Color(0xFFB39DDB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text(
                  _formatTime(_seconds),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
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
                border: Border.all(color: const Color(0xFFB39DDB), width: 2),
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
                  fillColor: Color(0xFFF3E5F5),
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
                
                // Mic Button (Main)
                FloatingActionButton(
                  heroTag: 'fab_mic',
                  onPressed: _listen,
                  backgroundColor: _isListening ? const Color(0xFFEF9A9A) : const Color(0xFF9575CD),
                  child: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 28),
                ),
                
                // Save Button
                FloatingActionButton.extended(
                  heroTag: 'fab_save',
                  onPressed: () {
                    if (_contentController.text.isNotEmpty) {
                      _showSaveDialog();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please record some audio before saving'),
                          backgroundColor: Color(0xFFEF9A9A),
                        ),
                      );
                    }
                  },
                  backgroundColor: const Color(0xFFA5D6A7),
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
