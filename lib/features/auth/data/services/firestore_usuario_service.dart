import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/usuario.dart';

class FirestoreUsuarioService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _usuarios => _db.collection('usuarios');

  Future<Result<Usuario?>> buscarPorUid(String uid) async {
    try {
      final doc = await _usuarios.doc(uid).get();
      if (!doc.exists) return const Result.success(null);
      final data = doc.data() as Map<String, dynamic>;
      return Result.success(Usuario(
        uid: uid,
        nome: data['nome'] as String,
        email: data['email'] as String,
        fotoUrl: data['fotoUrl'] as String?,
        curso: data['curso'] as String,
        turma: data['turma'] as int,
        pessoaId: data['pessoaId'] as String?,
        arroba: data['arroba'] as String?,
      ));
    } catch (e) {
      return Result.failure(Failure('Erro ao buscar usuário: $e'));
    }
  }

  Future<Result<void>> salvar(Usuario usuario) async {
    try {
      await _usuarios.doc(usuario.uid).set({
        'nome': usuario.nome,
        'email': usuario.email,
        'fotoUrl': usuario.fotoUrl,
        'curso': usuario.curso,
        'turma': usuario.turma,
        'pessoaId': usuario.pessoaId,
        'arroba': usuario.arroba,
      });
      return const Result.success(null);
    } catch (e) {
      return Result.failure(Failure('Erro ao salvar usuário: $e'));
    }
  }

  Future<bool> perfilCompleto(String uid) async {
    final result = await buscarPorUid(uid);
    return result.when(
      onSuccess: (usuario) => usuario != null,
      onFailure: (_) => false,
    );
  }
} 