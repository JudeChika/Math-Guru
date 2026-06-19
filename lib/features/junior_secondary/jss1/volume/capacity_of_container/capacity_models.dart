class CapacityStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  CapacityStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class CapacityResult {
  final List<CapacityStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;

  CapacityResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
  });
}