import 'package:vrecorder/domain/entities/recording.dart';

abstract class AudioRepository {
  /// بدء التسجيل
  /// يرجع معرف التسجيل الفريد
  Future<String> startRecording();

  /// إيقاف التسجيل
  /// يرجع Recording object مكتمل
  Future<Recording> stopRecording();

  /// الحصول على جميع التسجيلات المحفوظة
  Future<List<Recording>> getAllRecordings();

  /// حذف تسجيل معين
  Future<bool> deleteRecording(String recordingId);

  /// الحصول على مستوى الصوت الحالي (0.0 - 1.0)
  Future<double> getCurrentLevel();

  /// حفظ ملف التسجيل
  Future<void> saveRecording(String recordingId, String filename);
}
