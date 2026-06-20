class AngleRotationStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  AngleRotationStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class AngleRotationResult {
  final List<AngleRotationStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;

  AngleRotationResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
  });
}