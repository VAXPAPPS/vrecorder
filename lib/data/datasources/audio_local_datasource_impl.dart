import 'dart:convert';
import 'dart:io';
import 'package:vrecorder/data/datasources/audio_local_datasource.dart';
import 'package:vrecorder/domain/entities/recording.dart';

/// Implementation of AudioLocalDataSource with persistent storage
class AudioLocalDataSourceImpl implements AudioLocalDataSource {
  static const String _fileName = 'recordings.json';
  late Directory _dataDir;
  late File _recordingsFile;

  /// Initialize the data source and load existing recordings
  Future<void> init() async {
    // Create .local/share/venom directory
    final homeDir = Platform.environment['HOME'];
    _dataDir = Directory('$homeDir/.local/share/venom');
    
    if (!await _dataDir.exists()) {
      await _dataDir.create(recursive: true);
    }
    
    _recordingsFile = File('${_dataDir.path}/$_fileName');
  }

  @override
  Future<void> saveRecording(Recording recording) async {
    try {
      List<Recording> recordings = await getAllRecordings();
      
      // Check if recording already exists and update it
      final existingIndex = recordings.indexWhere((r) => r.id == recording.id);
      if (existingIndex >= 0) {
        recordings[existingIndex] = recording;
      } else {
        recordings.add(recording);
      }
      
      // Save to file
      await _saveToFile(recordings);
    } catch (e) {
      throw Exception('Failed to save recording: $e');
    }
  }

  @override
  Future<List<Recording>> getAllRecordings() async {
    try {
      if (!await _recordingsFile.exists()) {
        return [];
      }

      final jsonString = await _recordingsFile.readAsString();
      if (jsonString.isEmpty) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => Recording.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading recordings: $e');
      return [];
    }
  }

  @override
  Future<void> deleteRecording(String recordingId) async {
    try {
      List<Recording> recordings = await getAllRecordings();
      
      // Find and delete the file if it exists
      final recording = recordings.firstWhere(
        (r) => r.id == recordingId,
        orElse: () => Recording.empty(),
      );
      
      if (recording.filePath.isNotEmpty) {
        final file = File(recording.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      // Remove from list
      recordings.removeWhere((r) => r.id == recordingId);
      
      // Save updated list
      await _saveToFile(recordings);
    } catch (e) {
      throw Exception('Failed to delete recording: $e');
    }
  }

  @override
  Future<void> updateRecording(Recording recording) async {
    await saveRecording(recording);
  }

  Future<void> _saveToFile(List<Recording> recordings) async {
    try {
      final jsonList = recordings.map((r) => r.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _recordingsFile.writeAsString(jsonString);
    } catch (e) {
      throw Exception('Failed to write recordings to file: $e');
    }
  }
}
