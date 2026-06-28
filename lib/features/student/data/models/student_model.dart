import '../../domain/entities/student.dart';
import '../../domain/entities/popularity_criteria.dart';

// Exception específica de falha ao converter JSON em StudentModel.
// O Service vai capturar essa exception e converter em Result.failure.
class StudentModelParseException implements Exception {
  final String message;
  const StudentModelParseException(this.message);

  @override
  String toString() => 'StudentModelParseException: $message';
}

// Envolve a entidade Student, adicionando conversão pra JSON.
// O domínio (Student) nunca conhece JSON - só este Model conhece.
class StudentModel extends Student {
  const StudentModel({
    required super.id,
    required super.name,
    required super.nickname,
    required super.course,
    required super.classYear,
    required super.birthDate,
    required super.criteriaScores,
  });

  // Cria um StudentModel a partir de uma entidade Student pura.
  factory StudentModel.fromEntity(Student student) {
    return StudentModel(
      id: student.id,
      name: student.name,
      nickname: student.nickname,
      course: student.course,
      classYear: student.classYear,
      birthDate: student.birthDate,
      criteriaScores: student.criteriaScores,
    );
  }

  // Map -> StudentModel (vindo do JSON decodificado).
  // Lança StudentModelParseException se algo estiver corrompido/inválido.
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    try {
      final scoresJson = json['criteriaScores'] as Map<String, dynamic>;

      final scores = <CriteriaType, double>{};
      for (final entry in scoresJson.entries) {
        final criteria = CriteriaType.values.byNameOrNull(entry.key);
        if (criteria == null) {
          continue;
        }
        scores[criteria] = (entry.value as num).toDouble();
      }

      final courseRaw = json['course'] as String;
      final course = Course.values.byNameOrNull(courseRaw);
      if (course == null) {
        throw StudentModelParseException('Curso desconhecido: "$courseRaw"');
      }

      return StudentModel(
        id: json['id'] as String,
        name: json['name'] as String,
        nickname: json['nickname'] as String,
        course: course,
        classYear: json['classYear'] as int,
        birthDate: DateTime.parse(json['birthDate'] as String),
        criteriaScores: scores,
      );
    } on StudentModelParseException {
      rethrow;
    } catch (e) {
      throw StudentModelParseException(
        'Falha ao converter aluno a partir do JSON: $e',
      );
    }
  }

  // StudentModel -> Map (pra depois ser codificado em JSON string).
  Map<String, dynamic> toJson() {
    final scoresJson = <String, dynamic>{};
    for (final entry in criteriaScores.entries) {
      scoresJson[entry.key.name] = entry.value;
    }

    return {
      'id': id,
      'name': name,
      'nickname': nickname,
      'course': course.name,
      'classYear': classYear,
      'birthDate': birthDate.toIso8601String(),
      'criteriaScores': scoresJson,
    };
  }
}

extension _SafeEnumByName<T extends Enum> on List<T> {
  T? byNameOrNull(String name) {
    for (final value in this) {
      if (value.name == name) return value;
    }
    return null;
  }
}