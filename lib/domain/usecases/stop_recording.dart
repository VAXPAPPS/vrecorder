import 'package:vrecorder/domain/entities/recording.dart';
import 'package:vrecorder/domain/repositories/audio_repository.dart';

class StopRecordingUseCase {
  final AudioRepository repository;

  StopRecordingUseCase(this.repository);

  Future<Recording> call() async {
    return await repository.stopRecording();
  }
}
