class ConversionStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  ConversionStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class ConversionResult {
  final List<ConversionStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;

  ConversionResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
  });
}