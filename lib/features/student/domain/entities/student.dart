import 'popularity_criteria.dart';

// Cursos disponíveis no campus, conforme especificação.
enum Course { info, mec, mamb, prod, tads, tga }

extension CourseLabel on Course {
  String get label {
    switch (this) {
      case Course.info:
        return 'INFO';
      case Course.mec:
        return 'MEC';
      case Course.mamb:
        return 'MAMB';
      case Course.prod:
        return 'PROD';
      case Course.tads:
        return 'TADS';
      case Course.tga:
        return 'TGA';
    }
  }
}

// Entidade de domínio. Sem dependência de Flutter, JSON ou SharedPreferences.
class Student {
  final String id;
  final String name;
  final String nickname;
  final Course course;
  final int classYear; // turma/ano, ex: 2024
  final DateTime birthDate;
  final Map<CriteriaType, double> criteriaScores;

  const Student({
    required this.id,
    required this.name,
    required this.nickname,
    required this.course,
    required this.classYear,
    required this.birthDate,
    required this.criteriaScores,
  });

  // Soma das notas dos 15 critérios = Nível Lenda.
  double get totalScore {
    return criteriaScores.values.fold(0.0, (sum, score) => sum + score);
  }

  Student copyWith({
    String? name,
    String? nickname,
    Course? course,
    int? classYear,
    DateTime? birthDate,
    Map<CriteriaType, double>? criteriaScores,
  }) {
    return Student(
      id: id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      course: course ?? this.course,
      classYear: classYear ?? this.classYear,
      birthDate: birthDate ?? this.birthDate,
      criteriaScores: criteriaScores ?? this.criteriaScores,
    );
  }
}