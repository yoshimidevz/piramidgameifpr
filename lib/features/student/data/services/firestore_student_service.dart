import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/popularity_criteria.dart';
import '../../domain/entities/student.dart';
import '../../../../core/extensions/enum_extensions.dart';

class FirestoreStudentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _pessoas => _db.collection('pessoas');

  Future<Result<List<Student>>> getAll() async {
    try {
      final snapshot = await _pessoas.get();
      final students = snapshot.docs
          .map((doc) => _fromDoc(doc))
          .whereType<Student>()
          .toList();
      return Result.success(students);
    } catch (e) {
      return Result.failure(Failure('Erro ao buscar pessoas: $e'));
    }
  }

  Future<Result<Student>> getById(String id) async {
    try {
      final doc = await _pessoas.doc(id).get();
      if (!doc.exists) {
        return Result.failure(Failure('Pessoa não encontrada'));
      }
      final student = _fromDoc(doc);
      if (student == null) {
        return Result.failure(Failure('Erro ao converter dados da pessoa'));
      }
      return Result.success(student);
    } catch (e) {
      return Result.failure(Failure('Erro ao buscar pessoa: $e'));
    }
  }
  
  Future<Result<Student?>> buscarPorArroba(String arroba) async {
    try {
      final snapshot = await _pessoas
          .where('arroba', isEqualTo: arroba)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return const Result.success(null);
      final student = _fromDoc(snapshot.docs.first);
      return Result.success(student);
    } catch (e) {
      return Result.failure(Failure('Erro ao buscar por @: $e'));
    }
  }

  Future<Result<void>> create(Student student) async {
    try {
      await _pessoas.doc(student.id).set(_toMap(student));
      return const Result.success(null);
    } catch (e) {
      return Result.failure(Failure('Erro ao cadastrar pessoa: $e'));
    }
  }

  Future<Result<void>> update(Student student) async {
    try {
      await _pessoas.doc(student.id).update(_toMap(student));
      return const Result.success(null);
    } catch (e) {
      return Result.failure(Failure('Erro ao atualizar pessoa: $e'));
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      await _pessoas.doc(id).delete();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(Failure('Erro ao remover pessoa: $e'));
    }
  }

  Map<String, dynamic> _toMap(Student student) {
    return {
      'nome': student.name,
      'apelido': student.nickname,
      'curso': student.course.name,
      'turma': student.classYear,
      'dataNascimento': student.birthDate.toIso8601String(),
      'criadoPor': student.criadoPor,
      'arroba': student.arroba,
      'contaVinculada': student.contaVinculada,
    };
  }

  Student? _fromDoc(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      return Student(
        id: doc.id,
        name: data['nome'] as String,
        nickname: data['apelido'] as String? ?? '',
        course: Course.values.byNameOrNull(data['curso'] as String) ?? Course.info,
        classYear: data['turma'] as int,
        birthDate: DateTime.parse(data['dataNascimento'] as String),
        criteriaScores: {
          for (final c in CriteriaType.values) c: 0.0
        },
        criadoPor: data['criadoPor'] as String?,
        arroba: data['arroba'] as String?,
        contaVinculada: data['contaVinculada'] as bool? ?? false,
      );
    } catch (e) {
      return null;
    }
  }
}