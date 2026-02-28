import 'package:vrecorder/domain/repositories/audio_repository.dart';

class StartRecordingUseCase {
  final AudioRepository repository;

  StartRecordingUseCase(this.repository);

  Future<String> call() async {
    return await repository.startRecording();
  }
}
