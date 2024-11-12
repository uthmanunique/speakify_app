import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SavedRecordingsScreen extends StatelessWidget {
  final List<String> savedFiles; // A list to hold the paths of saved recordings

  SavedRecordingsScreen({required this.savedFiles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recordings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: savedFiles.length,
        itemBuilder: (context, index) {
          final filePath = savedFiles[index];
          final fileName = filePath.split('/').last;

          return Card(
            child: ListTile(
              title: Text(fileName),
              trailing: IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () {
                  final audioPlayer = AudioPlayer();
                  audioPlayer.play(DeviceFileSource(filePath));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
