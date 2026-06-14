class TrapeziumAreaStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  TrapeziumAreaStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class TrapeziumAreaResult {
  final List<TrapeziumAreaStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;

  TrapeziumAreaResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
  });
}