import 'package:equatable/equatable.dart';
import 'package:vrecorder/domain/entities/recording.dart';

abstract class AudioState extends Equatable {
  const AudioState();

  @override
  List<Object?> get props => [];
}

// الحالة الأولية
class AudioInitial extends AudioState {
  const AudioInitial();
}

// جاري التحميل
class AudioLoading extends AudioState {
  const AudioLoading();
}

// جاري التسجيل
class RecordingInProgress extends AudioState {
  final double currentLevel;
  final Duration elapsedTime;

  const RecordingInProgress({
    required this.currentLevel,
    required this.elapsedTime,
  });

  @override
  List<Object?> get props => [currentLevel, elapsedTime];
}

// التسجيل متوقف
class RecordingPaused extends AudioState {
  const RecordingPaused();
}

// التسجيل انتهى بنجاح
class RecordingCompleted extends AudioState {
  final Recording recording;

  const RecordingCompleted(this.recording);

  @override
  List<Object?> get props => [recording];
}

// قائمة التسجيلات
class RecordingsLoaded extends AudioState {
  final List<Recording> recordings;

  const RecordingsLoaded(this.recordings);

  @override
  List<Object?> get props => [recordings];
}

// خطأ
class AudioError extends AudioState {
  final String message;

  const AudioError(this.message);

  @override
  List<Object?> get props => [message];
}

// تم الحذف بنجاح
class RecordingDeleted extends AudioState {
  final String recordingId;

  const RecordingDeleted(this.recordingId);

  @override
  List<Object?> get props => [recordingId];
}
