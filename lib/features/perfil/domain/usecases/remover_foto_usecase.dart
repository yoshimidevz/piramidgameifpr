import '../../../../core/result/result.dart';
import '../repositories/foto_repository.dart';

class RemoverFotoUseCase {
  final FotoRepository _repository;

  RemoverFotoUseCase(this._repository);

  Future<Result<void>> call(String uid) {
    return _repository.removerFotoPerfil(uid);
  }
}