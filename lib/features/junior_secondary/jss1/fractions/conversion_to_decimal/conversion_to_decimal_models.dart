class DecimalConversionExplanationStep {
  final String description;
  final String? latexMath;
  DecimalConversionExplanationStep({
    required this.description,
    this.latexMath,
  });
}

enum DecimalConversionMethod {
  knownFacts,
  longDivision,
}