import 'package:vrecorder/core/audio/audio_ffi.dart';
import 'package:vrecorder/data/datasources/audio_local_datasource.dart';
import 'package:vrecorder/data/datasources/audio_local_datasource_impl.dart';
import 'package:vrecorder/data/repositories/audio_repository_impl.dart';
// ignore: unused_import
import 'package:vrecorder/domain/entities/recording.dart';
import 'package:vrecorder/domain/repositories/audio_repository.dart';
import 'package:vrecorder/domain/usecases/delete_recording.dart';
import 'package:vrecorder/domain/usecases/get_current_level.dart';
import 'package:vrecorder/domain/usecases/get_recordings.dart';
import 'package:vrecorder/domain/usecases/start_recording.dart';
import 'package:vrecorder/domain/usecases/stop_recording.dart';
import 'package:vrecorder/presentation/bloc/audio_bloc.dart';

/// حاوية Dependency Injection بسيطة
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() {
    return _instance;
  }

  ServiceLocator._internal();

  // تخزين الخدمات
  late AudioLocalDataSource _audioLocalDataSource;
  late AudioRepository _audioRepository;
  late StartRecordingUseCase _startRecordingUseCase;
  late StopRecordingUseCase _stopRecordingUseCase;
  late GetRecordingsUseCase _getRecordingsUseCase;
  late DeleteRecordingUseCase _deleteRecordingUseCase;
  late GetCurrentLevelUseCase _getCurrentLevelUseCase;
  late AudioBloc _audioBloc;

  /// تهيئة جميع الخدمات
  static Future<void> setupServiceLocator() async {
    final instance = ServiceLocator();

    // تهيئة FFI
    await AudioFFI.initialize();

    // تهيئة DataSource مع الحفظ الدائم
    final dataSource = AudioLocalDataSourceImpl();
    await dataSource.init();
    instance._audioLocalDataSource = dataSource;

    // تهيئة Repository
    instance._audioRepository = AudioRepositoryImpl(
      localDataSource: instance._audioLocalDataSource,
    );

    // تهيئة UseCases
    instance._startRecordingUseCase = StartRecordingUseCase(instance._audioRepository);
    instance._stopRecordingUseCase = StopRecordingUseCase(instance._audioRepository);
    instance._getRecordingsUseCase = GetRecordingsUseCase(instance._audioRepository);
    instance._deleteRecordingUseCase = DeleteRecordingUseCase(instance._audioRepository);
    instance._getCurrentLevelUseCase = GetCurrentLevelUseCase(instance._audioRepository);

    // تهيئة BLoC
    instance._audioBloc = AudioBloc(
      startRecordingUseCase: instance._startRecordingUseCase,
      stopRecordingUseCase: instance._stopRecordingUseCase,
      getRecordingsUseCase: instance._getRecordingsUseCase,
      deleteRecordingUseCase: instance._deleteRecordingUseCase,
      getCurrentLevelUseCase: instance._getCurrentLevelUseCase,
    );
  }

  // Getters
  static AudioBloc get audioBloc => _instance._audioBloc;
  static AudioRepository get audioRepository => _instance._audioRepository;
}
