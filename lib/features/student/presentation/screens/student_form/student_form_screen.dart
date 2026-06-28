import 'package:flutter/material.dart';

class StudentFormScreen extends StatelessWidget {
  final String? studentId;

  const StudentFormScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(studentId == null
            ? 'Cadastro - em construção'
            : 'Editar aluno $studentId - em construção'),
      ),
    );
  }
}