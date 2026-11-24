import 'dart:typed_data';
import '../../../../core/result/result.dart';
import '../../domain/repositories/foto_repository.dart';
import '../services/photo_storage_service.dart';

class FotoRepositoryImpl implements FotoRepository {
  final PhotoStorageService _service;

  FotoRepositoryImpl(this._service);

  @override
  Future<Result<String>> uploadFotoPerfil(String uid, Uint8List bytes) =>
      _service.uploadFotoPerfil(uid, bytes);

  @override
  Future<Result<void>> removerFotoPerfil(String uid) =>
      _service.removerFotoPerfil(uid);

  @override
  Future<Result<String?>> buscarUrlFoto(String uid) =>
      _service.buscarUrlFoto(uid);
}