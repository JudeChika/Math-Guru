/// Represents a single pedagogical step during the rate evaluation.
class RateStep {
  final String title;
  final String description;
  final String mathLaTeX;

  RateStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the final evaluated results and the step-by-step breakdown.
class RateResult {
  final String mode; // 'Standard' or 'Reduction'
  final String finalAnswerLaTeX;
  final List<String> workingsLaTeX;
  final List<RateStep> steps;
  final bool valid;
  final String? errorMessage;

  RateResult({
    required this.mode,
    required this.finalAnswerLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}