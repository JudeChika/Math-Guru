// lib/features/junior_secondary/jss1/algebra/algebra_models.dart

class AlgebraSolutionStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  AlgebraSolutionStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class AlgebraResult {
  final List<AlgebraSolutionStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;
  final List<String> availableVariables;
  final String? subjectUsed;

  AlgebraResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
    this.availableVariables = const [],
    this.subjectUsed,
  });
}