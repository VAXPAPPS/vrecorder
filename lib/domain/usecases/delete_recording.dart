import 'package:vrecorder/domain/repositories/audio_repository.dart';

class DeleteRecordingUseCase {
  final AudioRepository repository;

  DeleteRecordingUseCase(this.repository);

  Future<bool> call(String recordingId) async {
    return await repository.deleteRecording(recordingId);
  }
}
