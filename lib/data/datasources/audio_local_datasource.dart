import 'package:vrecorder/domain/entities/recording.dart';

abstract class AudioLocalDataSource {
  /// حفظ التسجيل في الذاكرة المحلية
  Future<void> saveRecording(Recording recording);

  /// الحصول على جميع التسجيلات
  Future<List<Recording>> getAllRecordings();

  /// حذف تسجيل من قائمة التسجيلات
  Future<void> deleteRecording(String recordingId);

  /// تحديث بيانات التسجيل
  Future<void> updateRecording(Recording recording);
}
