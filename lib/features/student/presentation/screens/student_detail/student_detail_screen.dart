import 'package:flutter/material.dart';

class StudentDetailScreen extends StatelessWidget {
  final String? studentId;

  const StudentDetailScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(studentId == null
            ? 'Aluno - nenhum selecionado ainda'
            : 'Detalhes do aluno $studentId - em construção'),
      ),
    );
  }
}