import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  Future<void> saveTranscription(String transcription) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? transcriptions = prefs.getStringList('transcriptions');
    transcriptions = transcriptions ?? [];
    transcriptions.add(transcription);
    await prefs.setStringList('transcriptions', transcriptions);
  }

  Future<List<String>> getTranscriptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('transcriptions') ?? [];
  }

  Future<void> deleteTranscription(String transcription) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? transcriptions = prefs.getStringList('transcriptions');
    transcriptions?.remove(transcription);
    await prefs.setStringList('transcriptions', transcriptions ?? []);
  }
}
