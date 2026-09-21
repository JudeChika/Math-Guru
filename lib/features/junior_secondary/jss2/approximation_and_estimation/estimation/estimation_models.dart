/// Represents a single pedagogical step during the estimation evaluation.
class EstimationStep {
  final String title;
  final String description;
  final String mathLaTeX;

  EstimationStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the completely evaluated results for BOTH estimation methods.
class EstimationResult {
  final String originalExpression;

  // Method 1: Round First
  final String m1RoundedExpressionLaTeX;
  final String m1FinalAnswerLaTeX;
  final List<String> m1WorkingsLaTeX;
  final List<EstimationStep> m1Steps;

  // Method 2: Calculate First
  final String m2ExactAnswerLaTeX;
  final String m2FinalAnswerLaTeX;
  final List<String> m2WorkingsLaTeX;
  final List<EstimationStep> m2Steps;

  final bool valid;
  final String? errorMessage;

  EstimationResult({
    required this.originalExpression,
    required this.m1RoundedExpressionLaTeX,
    required this.m1FinalAnswerLaTeX,
    required this.m1WorkingsLaTeX,
    required this.m1Steps,
    required this.m2ExactAnswerLaTeX,
    required this.m2FinalAnswerLaTeX,
    required this.m2WorkingsLaTeX,
    required this.m2Steps,
    this.valid = true,
    this.errorMessage,
  });
}