class RectangleAreaStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  RectangleAreaStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class RectangleAreaResult {
  final List<RectangleAreaStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;

  RectangleAreaResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
  });
}