/// Represents a single pedagogical step during the substitution evaluation.
class SubstitutionStep {
  final String title;
  final String description;
  final String mathLaTeX;

  SubstitutionStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the final evaluated results and the step-by-step breakdown.
class SubstitutionResult {
  final String originalExpression;
  final String substitutedExpressionLaTeX;
  final String finalAnswerLaTeX;
  final List<String> workingsLaTeX;
  final List<SubstitutionStep> steps;
  final bool valid;
  final String? errorMessage;

  SubstitutionResult({
    required this.originalExpression,
    required this.substitutedExpressionLaTeX,
    required this.finalAnswerLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}