class DecimalToFractionSolution {
  final String finalLatex;
  final List<String> workingLatex;
  final List<DecimalToFractionExplanationStep> explanations;

  DecimalToFractionSolution({
    required this.finalLatex,
    required this.workingLatex,
    required this.explanations,
  });
}

class DecimalToFractionExplanationStep {
  final String description;
  final String? latexMath;
  DecimalToFractionExplanationStep({
    required this.description,
    this.latexMath,
  });
}