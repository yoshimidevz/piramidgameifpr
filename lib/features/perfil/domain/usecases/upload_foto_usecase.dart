import 'dart:typed_data';
import '../../../../core/result/result.dart';
import '../repositories/foto_repository.dart';

class UploadFotoUseCase {
  final FotoRepository _repository;

  UploadFotoUseCase(this._repository);

  Future<Result<String>> call(String uid, Uint8List bytes) {
    // Regra de negocio: limite de 5MB por foto
    const limiteBytes = 5 * 1024 * 1024;
    if (bytes.lengthInBytes > limiteBytes) {
      return Future.value(
        Result.failure(Failure('A foto deve ter no máximo 5MB')),
      );
    }
    return _repository.uploadFotoPerfil(uid, bytes);
  }
}