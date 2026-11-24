import 'dart:typed_data';
import '../../../core/result/result.dart';
import '../domain/usecases/upload_foto_usecase.dart';
import '../domain/usecases/remover_foto_usecase.dart';

class FotoFacade {
  final UploadFotoUseCase _upload;
  final RemoverFotoUseCase _remover;

  FotoFacade({
    required UploadFotoUseCase upload,
    required RemoverFotoUseCase remover,
  })  : _upload = upload,
        _remover = remover;

  Future<Result<String>> upload(String uid, Uint8List bytes) =>
      _upload(uid, bytes);

  Future<Result<void>> remover(String uid) => _remover(uid);
}