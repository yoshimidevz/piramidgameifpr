class Usuario {
  final String uid;
  final String nome;
  final String email;
  final String? fotoUrl;
  final String curso;
  final int turma;
  final String? pessoaId; // id da pessoa vinculada no ranking

  const Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    this.fotoUrl,
    required this.curso,
    required this.turma,
    this.pessoaId,
  });
}