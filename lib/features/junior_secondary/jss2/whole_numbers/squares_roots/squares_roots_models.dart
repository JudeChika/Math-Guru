/// Represents a single explanatory step in the solution breakdown.
class SquareRootStep {
  final String explanation;
  final String? mathLaTeX;

  SquareRootStep({
    required this.explanation,
    this.mathLaTeX,
  });
}

/// Holds the completely formatted results for the UI to display.
class SquaresRootsResult {
  final String finalAnswerLaTeX;
  final List<String> workingsLaTeX;
  final List<SquareRootStep> steps;
  final bool valid;
  final String? errorMessage;

  SquaresRootsResult({
    required this.finalAnswerLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}