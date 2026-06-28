enum StudentTier { novato, popular, idolo, lenda }

extension StudentTierInfo on StudentTier {
  String get label {
    switch (this) {
      case StudentTier.novato:
        return 'Novato';
      case StudentTier.popular:
        return 'Popular';
      case StudentTier.idolo:
        return 'Ídolo';
      case StudentTier.lenda:
        return 'Lenda';
    }
  }

  // Calcula o tier a partir da pontuacao total (15 a 75).
  static StudentTier fromScore(double score) {
    if (score >= 61) return StudentTier.lenda;
    if (score >= 46) return StudentTier.idolo;
    if (score >= 31) return StudentTier.popular;
    return StudentTier.novato;
  }
}