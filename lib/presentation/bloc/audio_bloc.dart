import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vrecorder/domain/usecases/delete_recording.dart';
import 'package:vrecorder/domain/usecases/get_current_level.dart';
import 'package:vrecorder/domain/usecases/get_recordings.dart';
import 'package:vrecorder/domain/usecases/start_recording.dart';
import 'package:vrecorder/domain/usecases/stop_recording.dart';
import 'audio_event.dart';
import 'audio_state.dart';
import 'dart:async';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final StartRecordingUseCase startRecordingUseCase;
  final StopRecordingUseCase stopRecordingUseCase;
  final GetRecordingsUseCase getRecordingsUseCase;
  final DeleteRecordingUseCase deleteRecordingUseCase;
  final GetCurrentLevelUseCase getCurrentLevelUseCase;

  Timer? _levelUpdateTimer;
  Timer? _elapsedTimeTimer;
  DateTime? _recordingStartTime;
  Duration _elapsedTime = Duration.zero;

  AudioBloc({
    required this.startRecordingUseCase,
    required this.stopRecordingUseCase,
    required this.getRecordingsUseCase,
    required this.deleteRecordingUseCase,
    required this.getCurrentLevelUseCase,
  }) : super(const AudioInitial()) {
    on<StartRecordingEvent>(_onStartRecording);
    on<StopRecordingEvent>(_onStopRecording);
    on<LoadRecordingsEvent>(_onLoadRecordings);
    on<DeleteRecordingEvent>(_onDeleteRecording);
    on<UpdateLevelEvent>(_onUpdateLevel);
  }

  Future<void> _onStartRecording(
    StartRecordingEvent event,
    Emitter<AudioState> emit,
  ) async {
    emit(const AudioLoading());
    try {
      // ignore: unused_local_variable
      final recordingId = await startRecordingUseCase();
      _recordingStartTime = DateTime.now();
      _elapsedTime = Duration.zero;

      // Start sound level updates
      _startLevelUpdates(emit);

      // Start elapsed time updates
      _startElapsedTimeUpdates(emit);

      emit(RecordingInProgress(
        currentLevel: 0.0,
        elapsedTime: Duration.zero,
      ));
    } catch (e) {
      emit(AudioError('Failed to start recording: ${e.toString()}'));
    }
  }

  Future<void> _onStopRecording(
    StopRecordingEvent event,
    Emitter<AudioState> emit,
  ) async {
    emit(const AudioLoading());
    try {
      _levelUpdateTimer?.cancel();
      _elapsedTimeTimer?.cancel();

      final recording = await stopRecordingUseCase();
      emit(RecordingCompleted(recording));

      // Load updated recordings
      add(const LoadRecordingsEvent());
    } catch (e) {
      emit(AudioError('Failed to stop recording: ${e.toString()}'));
    }
  }

  Future<void> _onLoadRecordings(
    LoadRecordingsEvent event,
    Emitter<AudioState> emit,
  ) async {
    emit(const AudioLoading());
    try {
      final recordings = await getRecordingsUseCase();
      emit(RecordingsLoaded(recordings));
    } catch (e) {
      emit(AudioError('Failed to load recordings: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteRecording(
    DeleteRecordingEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      final success = await deleteRecordingUseCase(event.recordingId);
      if (success) {
        // Load updated recordings immediately after deletion
        final recordings = await getRecordingsUseCase();
        emit(RecordingsLoaded(recordings));
      } else {
        emit(AudioError('Failed to delete recording'));
      }
    } catch (e) {
      emit(AudioError('Failed to delete recording: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateLevel(
    UpdateLevelEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      final level = await getCurrentLevelUseCase();
      if (state is RecordingInProgress) {
        emit(RecordingInProgress(
          currentLevel: level,
          elapsedTime: _elapsedTime,
        ));
      }
    } catch (e) {
      // Ignore level update errors
    }
  }

  void _startLevelUpdates(Emitter<AudioState> emit) {
    _levelUpdateTimer?.cancel();
    _levelUpdateTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        add(const UpdateLevelEvent());
      },
    );
  }

  void _startElapsedTimeUpdates(Emitter<AudioState> emit) {
    _elapsedTimeTimer?.cancel();
    _elapsedTimeTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        if (_recordingStartTime != null) {
          _elapsedTime = DateTime.now().difference(_recordingStartTime!);
          add(const UpdateLevelEvent()); // Update level and time together
        }
      },
    );
  }

  @override
  Future<void> close() {
    _levelUpdateTimer?.cancel();
    _elapsedTimeTimer?.cancel();
    return super.close();
  }
}
