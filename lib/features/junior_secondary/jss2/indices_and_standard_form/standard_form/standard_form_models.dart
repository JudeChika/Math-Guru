class StandardFormSolutionStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  StandardFormSolutionStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class StandardFormResult {
  final List<StandardFormSolutionStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;

  StandardFormResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
  });
}