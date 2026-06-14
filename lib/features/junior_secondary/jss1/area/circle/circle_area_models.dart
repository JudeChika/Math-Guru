class CircleAreaStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  CircleAreaStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class CircleAreaResult {
  final List<CircleAreaStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;

  CircleAreaResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
  });
}