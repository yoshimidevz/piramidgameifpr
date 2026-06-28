// Os 15 critérios de avaliação, conforme especificação do projeto.
enum CriteriaType {
  resenha,
  presencaVip,
  aura,
  modoParceiro,
  carismaNatural,
  humorDeMilhoes,
  energiaDeGrupo,
  criatividadeCaotica,
  modoAtleta,
  talentoDePalco,
  dripEscolar,
  coracaoDeDorama,
  queridinhoDosProfessores,
  cerebroTurbo,
  caosControlado,
}

// Nome e descrição de cada critério, pra exibir na UI sem strings soltas.
extension CriteriaTypeInfo on CriteriaType {
  String get label {
    switch (this) {
      case CriteriaType.resenha:
        return 'Resenha';
      case CriteriaType.presencaVip:
        return 'Presença VIP';
      case CriteriaType.aura:
        return 'Aura';
      case CriteriaType.modoParceiro:
        return 'Modo Parceiro';
      case CriteriaType.carismaNatural:
        return 'Carisma Natural';
      case CriteriaType.humorDeMilhoes:
        return 'Humor de Milhões';
      case CriteriaType.energiaDeGrupo:
        return 'Energia de Grupo';
      case CriteriaType.criatividadeCaotica:
        return 'Criatividade Caótica';
      case CriteriaType.modoAtleta:
        return 'Modo Atleta';
      case CriteriaType.talentoDePalco:
        return 'Talento de Palco';
      case CriteriaType.dripEscolar:
        return 'Drip Escolar';
      case CriteriaType.coracaoDeDorama:
        return 'Coração de Dorama';
      case CriteriaType.queridinhoDosProfessores:
        return 'Queridinho dos Professores';
      case CriteriaType.cerebroTurbo:
        return 'Cérebro Turbo';
      case CriteriaType.caosControlado:
        return 'Caos Controlado';
    }
  }

  String get description {
    switch (this) {
      case CriteriaType.resenha:
        return 'Mede o quanto o aluno anima a turma, puxa conversa e contribui para deixar o ambiente mais descontraído.';
      case CriteriaType.presencaVip:
        return 'Avalia o quanto o aluno é lembrado, percebido ou reconhecido pelos colegas no dia a dia da turma.';
      case CriteriaType.aura:
        return 'Representa a energia geral do aluno: presença, estilo, jeito de ser e impacto que causa no ambiente.';
      case CriteriaType.modoParceiro:
        return 'Mede o quanto o aluno ajuda os colegas, colabora nas atividades e demonstra espírito de parceria.';
      case CriteriaType.carismaNatural:
        return 'Avalia a facilidade do aluno para socializar, conversar e criar boas relações com os colegas.';
      case CriteriaType.humorDeMilhoes:
        return 'Representa o quanto o aluno contribui com bom humor, brincadeiras saudáveis e momentos divertidos.';
      case CriteriaType.energiaDeGrupo:
        return 'Mede a participação do aluno em trabalhos, eventos, jogos, dinâmicas e atividades coletivas da turma.';
      case CriteriaType.criatividadeCaotica:
        return 'Avalia a capacidade do aluno de ter ideias diferentes, soluções inesperadas e comentários geniais.';
      case CriteriaType.modoAtleta:
        return 'Representa a aptidão esportiva, a disposição física e o espírito competitivo saudável do aluno.';
      case CriteriaType.talentoDePalco:
        return 'Mede a aptidão artística do aluno, como música, canto, instrumentos, dança, ritmo ou presença em apresentações.';
      case CriteriaType.dripEscolar:
        return 'Avalia o estilo pessoal do aluno, considerando roupas, tênis, cabelo, acessórios e presença visual.';
      case CriteriaType.coracaoDeDorama:
        return 'Representa o carisma afetivo, a gentileza e aquela vibe de protagonista romântico, sem expor relacionamentos reais.';
      case CriteriaType.queridinhoDosProfessores:
        return 'Mede a boa relação do aluno com os professores, considerando respeito, participação, educação e responsabilidade.';
      case CriteriaType.cerebroTurbo:
        return 'Avalia o desempenho nos estudos, a facilidade para aprender, resolver problemas e se destacar academicamente.';
      case CriteriaType.caosControlado:
        return 'Mede o quanto o aluno é bagunceiro, zoeiro ou imprevisível, mas ainda dentro dos limites do respeito e da convivência saudável.';
    }
  }
}

// Limites de nota por critério (star rating).
class CriteriaScoreLimits {
  static const double min = 1.0;
  static const double max = 5.0;
}