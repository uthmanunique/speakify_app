import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speakify_app/widgets/audio_bars_visualizer.dart';

class TranscriptionScreen extends StatefulWidget {
  final String transcription;
  final String audioPath;

  TranscriptionScreen({required this.transcription, required this.audioPath});

  @override
  _TranscriptionScreenState createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends State<TranscriptionScreen> {
  bool isPlaying = false;
  String _displayedText = '';
  final AudioPlayer _audioPlayer = AudioPlayer();
  IconData playPauseIcon = Icons.play_arrow;

  @override
  void initState() {
    super.initState();
    _displayedText = widget.transcription;
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
        playPauseIcon = isPlaying ? Icons.pause : Icons.play_arrow;
      });
    });
  }

  void _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(widget.audioPath));
    }
  }

  void _stopPlayback() async {
    await _audioPlayer.stop();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
              'Transcription',
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
                  _displayedText,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 98),
            if (isPlaying)
              Container(
                width: 361,
                height: 58,  // Updated height to match RecordScreen
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
                  'Playing',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
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
                  onTap: _togglePlayPause,
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
                      playPauseIcon,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _stopPlayback,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE9F6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.stop, size: 32, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 38),
          ],
        ),
      ),
    );
  }
}
