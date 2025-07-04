class PercentageConversionSolution {
  final String finalLatex;
  final List<String> workingLatex;
  final List<PercentageConversionExplanationStep> explanations;

  PercentageConversionSolution({
    required this.finalLatex,
    required this.workingLatex,
    required this.explanations,
  });
}

class PercentageConversionExplanationStep {
  final String description;
  final String? latexMath;
  PercentageConversionExplanationStep({
    required this.description,
    this.latexMath,
  });
}