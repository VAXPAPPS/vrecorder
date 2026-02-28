import 'package:vrecorder/core/audio/audio_ffi.dart';
import 'package:vrecorder/data/datasources/audio_local_datasource.dart';
import 'package:vrecorder/domain/entities/recording.dart';
import 'package:vrecorder/domain/repositories/audio_repository.dart';
import 'dart:async';
import 'dart:io';

class AudioRepositoryImpl implements AudioRepository {
  final AudioLocalDataSource localDataSource;

  int? _currentRecordingId;
  DateTime? _recordingStartTime;
  Timer? _levelUpdateTimer;

  AudioRepositoryImpl({required this.localDataSource});

  @override
  Future<String> startRecording() async {
    try {
      final recordingId = AudioFFI.startRecording();
      _currentRecordingId = recordingId;
      _recordingStartTime = DateTime.now();
      return recordingId.toString();
    } catch (e) {
      throw Exception('Failed to start recording: $e');
    }
  }

  @override
  Future<Recording> stopRecording() async {
    try {
      if (_currentRecordingId == null) {
        throw Exception('No recording in progress');
      }

      final recordingId = _currentRecordingId!;
      final result = AudioFFI.stopRecording(recordingId);

      if (result != 0) {
        throw Exception('Failed to stop recording');
      }

      final durationMs = AudioFFI.getRecordingDuration(recordingId);
      final duration = Duration(milliseconds: durationMs);

      // Create Music directory if it doesn't exist
      final musicDir = Directory('${Platform.environment['HOME']}/Music');
      if (!await musicDir.exists()) {
        await musicDir.create(recursive: true);
      }

      final filename = 'recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      final filePath = '${musicDir.path}/$filename';
      
      AudioFFI.saveRecording(recordingId, filePath);

      // Wait briefly to ensure file is written
      await Future.delayed(const Duration(milliseconds: 500));

      // Read actual file size
      final file = File(filePath);
      final fileSize = await file.length();

      final recording = Recording(
        id: recordingId.toString(),
        filename: filename,
        filePath: filePath,
        createdAt: _recordingStartTime ?? DateTime.now(),
        duration: duration,
        fileSize: fileSize,
      );

      await localDataSource.saveRecording(recording);

      _currentRecordingId = null;
      _recordingStartTime = null;

      return recording;
    } catch (e) {
      throw Exception('Failed to stop recording: $e');
    }
  }

  @override
  Future<List<Recording>> getAllRecordings() async {
    try {
      return await localDataSource.getAllRecordings();
    } catch (e) {
      throw Exception('Failed to get recordings: $e');
    }
  }

  @override
  Future<bool> deleteRecording(String recordingId) async {
    try {
      await localDataSource.deleteRecording(recordingId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete recording: $e');
    }
  }

  @override
  Future<double> getCurrentLevel() async {
    try {
      if (_currentRecordingId == null) {
        return 0.0;
      }
      final level = AudioFFI.getCurrentLevel();
      return level.clamp(0.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Future<void> saveRecording(String recordingId, String filename) async {
    try {
      final id = int.parse(recordingId);
      AudioFFI.saveRecording(id, filename);
    } catch (e) {
      throw Exception('Failed to save recording: $e');
    }
  }

  void dispose() {
    _levelUpdateTimer?.cancel();
  }
}
