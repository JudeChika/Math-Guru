/// Represents a single pedagogical step in the expansion breakdown.
class ExpandingExpressionsStep {
  final String title;
  final String description;
  final String mathLaTeX;

  ExpandingExpressionsStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the final evaluated results and the step-by-step breakdown.
class ExpandingExpressionsResult {
  final String originalProblemLaTeX;
  final String finalAnswerLaTeX;
  final List<String> workingsLaTeX;
  final List<ExpandingExpressionsStep> steps;
  final bool valid;
  final String? errorMessage;

  ExpandingExpressionsResult({
    required this.originalProblemLaTeX,
    required this.finalAnswerLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}