import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:speakify_app/screens/transcription_screen.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart' as p;

import '../widgets/audio_bars_visualizer.dart';

class RecordScreen extends StatefulWidget {
  @override
  _RecordScreenState createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  bool isRecording = false;
  bool isPaused = false;
  String recordingText = 'Start recording to get text';
  IconData recordIcon = Icons.mic;
  Timer? _timer;
  int _recordDuration = 0;
  String _formattedTime = "00:00:00";
  String? _audioPath;
  String? _saveDirectory;

  late stt.SpeechToText _speechToText;
  bool _speechEnabled = false;
  String _lastWords = '';

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final micPermissionStatus = await Permission.microphone.status;
    final storagePermissionStatus = await Permission.storage.status;

    if (!micPermissionStatus.isGranted || !storagePermissionStatus.isGranted) {
      final status = await [
        Permission.microphone,
        Permission.storage,
      ].request();

      if (status[Permission.microphone]!.isGranted && status[Permission.storage]!.isGranted) {
        _initializeRecorder();
        _initSpeech();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone and storage permissions are required.')),
        );
      }
    } else {
      _initializeRecorder();
      _initSpeech();
    }
  }

  Future<void> _initializeRecorder() async {
    if (_isRecorderInitialized) return;
    try {
      await _recorder.openRecorder();
      _isRecorderInitialized = true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize recorder: $e')),
      );
    }
  }

  @override
  void dispose() {
    if (_isRecorderInitialized) {
      _recorder.closeRecorder();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) => print('Speech recognition status: $status'),
      onError: (errorNotification) => print('Speech recognition error: ${errorNotification.errorMsg}'),
    );
    setState(() {
      if (!_speechEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition is not available on this device.')),
        );
      }
    });
  }

  Future<void> _startRecording() async {
    if (_saveDirectory == null) {
      await _selectSaveDirectory();
    }

    if (_saveDirectory != null && _speechEnabled && _isRecorderInitialized) {
      final filePath = p.join(_saveDirectory!, 'temp_audio.aac');
      print('Saving recording to: $filePath');
      await _recorder.startRecorder(toFile: filePath);

      setState(() {
        isRecording = true;
        isPaused = false;
        recordIcon = Icons.pause;
        recordingText = 'Recording...';
        _startListening();
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordDuration++;
          _formattedTime = _formatDuration(_recordDuration);
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording setup failed. Please try again.')),
      );
    }
  }

  Future<void> _pauseRecording() async {
    if (!_isRecorderInitialized) return;

    await _recorder.pauseRecorder();
    setState(() {
      isPaused = true;
      recordIcon = Icons.play_arrow;  // Change to play arrow
      recordingText = 'Recording paused';
      _timer?.cancel();
      _stopListening();
    });
  }

  Future<void> _resumeRecording() async {
    if (!_isRecorderInitialized) return;

    await _recorder.resumeRecorder();
    setState(() {
      isPaused = false;
      recordIcon = Icons.pause;  // Change to pause icon
      recordingText = 'Recording...';
      _startListening();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
        _formattedTime = _formatDuration(_recordDuration);
      });
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecorderInitialized) return;

    final path = await _recorder.stopRecorder();
    _audioPath = path;

    setState(() {
      isRecording = false;
      isPaused = false;
      recordIcon = Icons.mic;
      recordingText = 'Recording stopped';
      _recordDuration = 0;  // Reset the timer
      _formattedTime = "00:00:00";  // Reset the display time
    });

    _timer?.cancel();
    _stopListening();
  }

  String _formatDuration(int totalSeconds) {
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void _startListening() async {
    await _speechToText.listen(onResult: (result) {
      setState(() {
        _lastWords = result.recognizedWords;
        recordingText = _lastWords.isEmpty ? recordingText : _lastWords;
      });
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
  }

  void _saveTranscription() {
    if (_lastWords.isNotEmpty && _audioPath != null) {
      setState(() {
        // Reset state after saving
        _recordDuration = 0;
        _formattedTime = "00:00:00";
        recordingText = 'Start recording to get text';
        _lastWords = '';
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TranscriptionScreen(
            transcription: _lastWords,
            audioPath: _audioPath!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transcription or audio available to save.')),
      );
    }
  }

  Future<void> _selectSaveDirectory() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath != null) {
      setState(() {
        _saveDirectory = directoryPath;
        _initializeRecorder();
      });
      print('Selected directory: $_saveDirectory');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No directory selected.')),
      );
    }
  }

  void _playLastRecording() async {
    if (_audioPath != null) {
      await _audioPlayer.play(DeviceFileSource(_audioPath!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recording available to play.')),
      );
    }
  }

  void _onRecordIconPressed() {
    if (isRecording) {
      if (isPaused) {
        _resumeRecording();  // Resume the recording if it's paused
      } else {
        _pauseRecording();  // Pause the recording if it's currently recording
      }
    } else {
      _startRecording();  // Start a new recording if not already recording
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.cancel, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Speakify',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Voice-to-text',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 361,
              height: 236,
              padding: const EdgeInsets.only(left: 16.0, top: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F8FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  recordingText,
                  style: TextStyle(
                    fontSize: 16,
                    color: isRecording ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 98),
            if (isRecording && !isPaused)
              Container(
                width: 361,
                height: 58,  // Updated height
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: AudioBarsVisualizer(),  // Use the updated AudioBarsVisualizer widget
                ),
              ),
            const Spacer(),
            Column(
              children: [
                const Text(
                  'Recording',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formattedTime,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE9F6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.settings, size: 32, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _onRecordIconPressed,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF5364F6), Color(0xFF29E2FE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      recordIcon,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _playLastRecording,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE9F6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, size: 32, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 38),
            if (isRecording)
              GestureDetector(
                onTap: _saveTranscription,
                child: Container(
                  width: 361,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF357ABD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }
}
