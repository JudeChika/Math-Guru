class PolygonAreaStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  PolygonAreaStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class PolygonAreaResult {
  final List<PolygonAreaStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;

  PolygonAreaResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
  });
}