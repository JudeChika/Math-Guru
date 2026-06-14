class TriangleAreaStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  TriangleAreaStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class TriangleAreaResult {
  final List<TriangleAreaStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;

  TriangleAreaResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
  });
}