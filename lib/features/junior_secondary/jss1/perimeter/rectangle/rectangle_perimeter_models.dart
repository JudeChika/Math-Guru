class GeometrySolutionStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  GeometrySolutionStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class GeometryResult {
  final List<GeometrySolutionStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;

  GeometryResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
  });
}