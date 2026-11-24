import 'dart:typed_data';
import '../../../../core/result/result.dart';

abstract class FotoRepository {
  Future<Result<String>> uploadFotoPerfil(String uid, Uint8List bytes);
  Future<Result<void>> removerFotoPerfil(String uid);
  Future<Result<String?>> buscarUrlFoto(String uid);
}