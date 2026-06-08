// lib/features/junior_secondary/jss1/algebra/brackets_operations/brackets_operations_models.dart

class BracketSolutionStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  BracketSolutionStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class BracketResult {
  final List<BracketSolutionStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;
  final List<String> availableVariables;
  final String? subjectUsed;

  BracketResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
    this.availableVariables = const [],
    this.subjectUsed,
  });
}