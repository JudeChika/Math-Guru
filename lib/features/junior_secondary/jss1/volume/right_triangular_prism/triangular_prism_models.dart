class TriangularPrismStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  TriangularPrismStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class TriangularPrismResult {
  final List<TriangularPrismStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;

  TriangularPrismResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
  });
}