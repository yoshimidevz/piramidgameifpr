import 'popularity_criteria.dart';
import 'student_tier.dart';

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

class Student {
  final String id;
  final String name;
  final String nickname;
  final Course course;
  final int classYear;
  final DateTime birthDate;
  final Map<CriteriaType, double> criteriaScores;
  final String? criadoPor; // uid do usuario que cadastrou essa pessoa

  const Student({
    required this.id,
    required this.name,
    required this.nickname,
    required this.course,
    required this.classYear,
    required this.birthDate,
    required this.criteriaScores,
    this.criadoPor,
  });

  double get totalScore {
    return criteriaScores.values.fold(0.0, (sum, score) => sum + score);
  }

  StudentTier get tier => StudentTierInfo.fromScore(totalScore);

  // Retorna true se o uid passado for o mesmo que cadastrou essa pessoa
  bool isCriadoPor(String uid) => criadoPor == uid;

  Student copyWith({
    String? id,
    String? name,
    String? nickname,
    Course? course,
    int? classYear,
    DateTime? birthDate,
    Map<CriteriaType, double>? criteriaScores,
    String? criadoPor,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      course: course ?? this.course,
      classYear: classYear ?? this.classYear,
      birthDate: birthDate ?? this.birthDate,
      criteriaScores: criteriaScores ?? this.criteriaScores,
      criadoPor: criadoPor ?? this.criadoPor,
    );
  }
}