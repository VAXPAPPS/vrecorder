import 'dart:ffi' as ffi;
import 'dart:ffi';
import 'package:ffi/ffi.dart';

// تعريف النوع للدوال الأصلية
typedef StartRecordingC = ffi.Int64 Function();
typedef StopRecordingC = ffi.Int32 Function(ffi.Int64 recordingId);
typedef GetCurrentLevelC = ffi.Double Function();
typedef SaveRecordingC = ffi.Int32 Function(
  ffi.Int64 recordingId,
  ffi.Pointer<Utf8> filename,
);
typedef GetRecordingDurationC = ffi.Int64 Function(ffi.Int64 recordingId);

// تعريف الدوال Dart
typedef StartRecording = int Function();
typedef StopRecording = int Function(int recordingId);
typedef GetCurrentLevel = double Function();
typedef SaveRecording = int Function(
  int recordingId,
  Pointer<Utf8> filename,
);
typedef GetRecordingDuration = int Function(int recordingId);

class AudioFFI {
  static late DynamicLibrary _lib;
  static bool _initialized = false;

  static late StartRecording _startRecording;
  static late StopRecording _stopRecording;
  static late GetCurrentLevel _getCurrentLevel;
  static late SaveRecording _saveRecording;
  static late GetRecordingDuration _getRecordingDuration;

  /// تهيئة مكتبة FFI
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // تحميل المكتبة المشترکة من Linux
      _lib = DynamicLibrary.open('libaudio_recorder.so');

      // ربط الدوال
      _startRecording =
          _lib.lookup<NativeFunction<StartRecordingC>>('start_recording').asFunction();
      _stopRecording =
          _lib.lookup<NativeFunction<StopRecordingC>>('stop_recording').asFunction();
      _getCurrentLevel =
          _lib.lookup<NativeFunction<GetCurrentLevelC>>('get_current_level').asFunction();
      _saveRecording =
          _lib.lookup<NativeFunction<SaveRecordingC>>('save_recording').asFunction();
      _getRecordingDuration = _lib
          .lookup<NativeFunction<GetRecordingDurationC>>('get_recording_duration')
          .asFunction();

      _initialized = true;
    } catch (e) {
      throw Exception('Failed to initialize AudioFFI: $e');
    }
  }

  /// بدء التسجيل
  static int startRecording() {
    if (!_initialized) throw Exception('AudioFFI not initialized');
    return _startRecording();
  }

  /// إيقاف التسجيل
  static int stopRecording(int recordingId) {
    if (!_initialized) throw Exception('AudioFFI not initialized');
    return _stopRecording(recordingId);
  }

  /// الحصول على مستوى الصوت الحالي
  static double getCurrentLevel() {
    if (!_initialized) throw Exception('AudioFFI not initialized');
    return _getCurrentLevel();
  }

  /// حفظ ملف التسجيل
  static int saveRecording(int recordingId, String filename) {
    if (!_initialized) throw Exception('AudioFFI not initialized');
    final filenamePtr = filename.toNativeUtf8();
    try {
      return _saveRecording(recordingId, filenamePtr);
    } finally {
      malloc.free(filenamePtr);
    }
  }

  /// الحصول على مدة التسجيل بالميلي ثانية
  static int getRecordingDuration(int recordingId) {
    if (!_initialized) throw Exception('AudioFFI not initialized');
    return _getRecordingDuration(recordingId);
  }
}
