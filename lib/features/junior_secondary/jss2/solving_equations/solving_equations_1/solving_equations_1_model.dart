/// Represents a single pedagogical step during the equation solving process.
class EquationStep {
  final String title;
  final String description;
  final String mathLaTeX;

  EquationStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the final evaluated results and the step-by-step breakdown.
class EquationResult {
  final String originalEquationLaTeX;
  final String finalAnswerLaTeX;
  final List<String> workingsLaTeX;
  final List<EquationStep> steps;
  final bool valid;
  final String? errorMessage;

  EquationResult({
    required this.originalEquationLaTeX,
    required this.finalAnswerLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}