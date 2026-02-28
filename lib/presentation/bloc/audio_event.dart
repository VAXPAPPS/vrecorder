import 'package:equatable/equatable.dart';

abstract class AudioEvent extends Equatable {
  const AudioEvent();

  @override
  List<Object?> get props => [];
}

// بدء التسجيل
class StartRecordingEvent extends AudioEvent {
  const StartRecordingEvent();
}

// إيقاف التسجيل
class StopRecordingEvent extends AudioEvent {
  const StopRecordingEvent();
}

// تحميل التسجيلات السابقة
class LoadRecordingsEvent extends AudioEvent {
  const LoadRecordingsEvent();
}

// حذف تسجيل
class DeleteRecordingEvent extends AudioEvent {
  final String recordingId;

  const DeleteRecordingEvent(this.recordingId);

  @override
  List<Object?> get props => [recordingId];
}

// تحديث مستوى الصوت
class UpdateLevelEvent extends AudioEvent {
  const UpdateLevelEvent();
}
