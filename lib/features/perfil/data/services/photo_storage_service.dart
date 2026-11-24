import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/result/result.dart';

/// Service responsavel pelo acesso ao Firebase Storage.
/// Guarda as fotos de perfil em /fotos_perfil/{uid}.jpg
///
/// NOTA: o Firebase Storage exige plano Blaze (pago). O codigo esta
/// implementado e pronto, mas so funciona com o plano ativo no projeto.
class PhotoStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String _pastaFotos = 'fotos_perfil';

  /// Faz upload da foto e devolve a URL publica de download.
  Future<Result<String>> uploadFotoPerfil(String uid, Uint8List bytes) async {
    try {
      final ref = _storage.ref().child('$_pastaFotos/$uid.jpg');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uid': uid},
      );

      await ref.putData(bytes, metadata);
      final url = await ref.getDownloadURL();

      return Result.success(url);
    } on FirebaseException catch (e) {
      return Result.failure(Failure(_mensagemErro(e.code)));
    } catch (e) {
      return Result.failure(Failure('Erro ao enviar foto: $e'));
    }
  }

  /// Remove a foto de perfil do Storage.
  Future<Result<void>> removerFotoPerfil(String uid) async {
    try {
      final ref = _storage.ref().child('$_pastaFotos/$uid.jpg');
      await ref.delete();
      return const Result.success(null);
    } on FirebaseException catch (e) {
      // Se a foto nao existe, nao e erro de verdade
      if (e.code == 'object-not-found') return const Result.success(null);
      return Result.failure(Failure(_mensagemErro(e.code)));
    } catch (e) {
      return Result.failure(Failure('Erro ao remover foto: $e'));
    }
  }

  /// Busca a URL da foto ja armazenada, se existir.
  Future<Result<String?>> buscarUrlFoto(String uid) async {
    try {
      final ref = _storage.ref().child('$_pastaFotos/$uid.jpg');
      final url = await ref.getDownloadURL();
      return Result.success(url);
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return const Result.success(null);
      return Result.failure(Failure(_mensagemErro(e.code)));
    } catch (e) {
      return Result.failure(Failure('Erro ao buscar foto: $e'));
    }
  }

  String _mensagemErro(String code) {
    switch (code) {
      case 'unauthorized':
        return 'Sem permissão para acessar o Storage';
      case 'canceled':
        return 'Envio cancelado';
      case 'quota-exceeded':
        return 'Cota do Storage excedida';
      case 'unauthenticated':
        return 'Faça login novamente para enviar a foto';
      default:
        return 'Erro no Storage: $code';
    }
  }
}