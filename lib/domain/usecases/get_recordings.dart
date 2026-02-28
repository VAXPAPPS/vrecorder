import 'package:vrecorder/domain/entities/recording.dart';
import 'package:vrecorder/domain/repositories/audio_repository.dart';

class GetRecordingsUseCase {
  final AudioRepository repository;

  GetRecordingsUseCase(this.repository);

  Future<List<Recording>> call() async {
    return await repository.getAllRecordings();
  }
}
