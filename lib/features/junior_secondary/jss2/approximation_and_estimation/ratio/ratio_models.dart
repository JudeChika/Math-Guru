/// Represents a single pedagogical step during the ratio evaluation.
class RatioStep {
  final String title;
  final String description;
  final String mathLaTeX;

  RatioStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the final evaluated results and the step-by-step breakdown.
class RatioResult {
  final String mode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<RatioStep> steps;
  final bool valid;
  final String? errorMessage;

  RatioResult({
    required this.mode,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}