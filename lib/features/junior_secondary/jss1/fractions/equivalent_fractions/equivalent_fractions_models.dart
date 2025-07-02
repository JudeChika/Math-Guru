class EquivalentFractionExplanationStep {
  final String description;
  final String? latexMath;

  EquivalentFractionExplanationStep({
    required this.description,
    this.latexMath,
  });
}

enum FractionUnknownPosition {
  numerator1,
  denominator1,
  numerator2,
  denominator2,
}