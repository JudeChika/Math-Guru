class Fraction {
  int numerator;
  int denominator;

  Fraction(this.numerator, this.denominator);
}

class FractionSolution {
  final String finalLatex;
  final List<FractionWorkingStep> workings;
  final List<FractionExplanation> explanations;

  FractionSolution({
    required this.finalLatex,
    required this.workings,
    required this.explanations,
  });
}

class FractionWorkingStep {
  final String latexMath;

  FractionWorkingStep({
    required this.latexMath,
  });
}

class FractionExplanation {
  final String description;
  final String? latexMath;

  FractionExplanation({
    required this.description,
    this.latexMath,
  });
}
