extension StringArroba on String {
  // Remove acentos e caracteres especiais
  String semAcentos() {
    const acentos = 'ÀÁÂÃÄÅàáâãäåÈÉÊËèéêëÌÍÎÏìíîïÒÓÔÕÖòóôõöÙÚÛÜùúûüÝýÿÑñÇç';
    const semAc   = 'AAAAAAaaaaaaEEEEeeeeIIIIiiiiOOOOOoooooUUUUuuuuYyyNnCc';
    String result = this;
    for (int i = 0; i < acentos.length; i++) {
      result = result.replaceAll(acentos[i], semAc[i]);
    }
    return result;
  }
}

String gerarArroba(String nomeCompleto, String curso, int turma) {
  final partes = nomeCompleto.trim().split(' ').where((p) => p.isNotEmpty).toList();
  final primeiro = partes.first.semAcentos().toLowerCase();
  final ultimo = partes.length > 1 ? partes.last.semAcentos().toLowerCase() : '';
  return '$primeiro$ultimo$curso$turma';
}