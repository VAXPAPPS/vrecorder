import 'package:vrecorder/domain/repositories/audio_repository.dart';

class GetCurrentLevelUseCase {
  final AudioRepository repository;

  GetCurrentLevelUseCase(this.repository);

  Future<double> call() async {
    return await repository.getCurrentLevel();
  }
}
