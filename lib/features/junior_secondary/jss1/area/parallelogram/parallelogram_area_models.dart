class ParallelogramAreaStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  ParallelogramAreaStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class ParallelogramAreaResult {
  final List<ParallelogramAreaStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;

  ParallelogramAreaResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
  });
}