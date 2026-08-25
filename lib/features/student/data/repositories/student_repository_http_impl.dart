import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/entities/popularity_criteria.dart';
import '../../../../core/extensions/enum_extensions.dart';

class StudentRepositoryHttpImpl implements StudentRepository {
  final Dio _dio = ApiClient.instance.dio;

  @override
  Future<Result<List<Student>>> getAll() async {
    try {
      final response = await _dio.get('/students');
      final list = (response.data as List)
          .map((json) => _fromJson(json))
          .toList();
      return Result.success(list);
    } on DioException catch (e) {
      return Result.failure(Failure(
        e.response?.data?['message'] ?? 'Erro ao buscar alunos',
        exception: e,
      ));
    }
  }

  @override
  Future<Result<Student>> getById(String id) async {
    try {
      final response = await _dio.get('/students/$id');
      return Result.success(_fromJson(response.data));
    } on DioException catch (e) {
      return Result.failure(Failure(
        e.response?.data?['message'] ?? 'Aluno não encontrado',
        exception: e,
      ));
    }
  }

  @override
  Future<Result<void>> create(Student student) async {
    try {
      await _dio.post('/students', data: {
        'name': student.name,
        'nickname': student.nickname.isEmpty ? null : student.nickname,
        'course': student.course.label,
        'classYear': student.classYear,
        'birthDate': '${student.birthDate.year}-'
            '${student.birthDate.month.toString().padLeft(2, '0')}-'
            '${student.birthDate.day.toString().padLeft(2, '0')}',
      });
      return const Result.success(null);
    } on DioException catch (e) {
      return Result.failure(Failure(
        e.response?.data?['message'] ?? 'Erro ao cadastrar aluno',
        exception: e,
      ));
    }
  }

  @override
  Future<Result<void>> update(Student student) async {
    try {
      await _dio.put('/students/${student.id}', data: {
        'name': student.name,
        'nickname': student.nickname.isEmpty ? null : student.nickname,
        'course': student.course.label,
        'classYear': student.classYear,
        'birthDate': '${student.birthDate.year}-'
            '${student.birthDate.month.toString().padLeft(2, '0')}-'
            '${student.birthDate.day.toString().padLeft(2, '0')}',
      });
      return const Result.success(null);
    } on DioException catch (e) {
      return Result.failure(Failure(
        e.response?.data?['message'] ?? 'Erro ao atualizar aluno',
        exception: e,
      ));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _dio.delete('/students/$id');
      return const Result.success(null);
    } on DioException catch (e) {
      return Result.failure(Failure(
        e.response?.data?['message'] ?? 'Erro ao remover aluno',
        exception: e,
      ));
    }
  }

  Student _fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String? ?? '',
      course: Course.values.firstWhere(
        (c) => c.label == json['course'],
        orElse: () => Course.info,
      ),
      classYear: json['classYear'] as int,
      birthDate: DateTime.parse(json['birthDate'] as String),
      criteriaScores: _parseScores(json['criteriaScores']),
    );
  }

  Map<CriteriaType, double> _parseScores(dynamic scores) {
    if (scores == null || (scores as List).isEmpty) {
      return {for (final c in CriteriaType.values) c: 0.0};
    }
    final map = <CriteriaType, double>{};
    for (final score in scores) {
      final criteria = CriteriaType.values.byNameOrNull(
        score['criteriaKey'] as String,
      );
      if (criteria != null) {
        map[criteria] = (score['score'] as num).toDouble();
      }
    }
    // Garante que todos os 15 criterios existam no map
    for (final c in CriteriaType.values) {
      map.putIfAbsent(c, () => 0.0);
    }
    return map;
  }
}