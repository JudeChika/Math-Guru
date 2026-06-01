// lib/features/junior_secondary/jss1/algebra/algebra_operations_models.dart

class OperationSolutionStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  OperationSolutionStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class OperationResult {
  final List<OperationSolutionStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;
  final String operationType; // e.g., "Addition/Subtraction", "Multiplication", "Division"

  OperationResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
    this.operationType = "Simplification",
  });
}