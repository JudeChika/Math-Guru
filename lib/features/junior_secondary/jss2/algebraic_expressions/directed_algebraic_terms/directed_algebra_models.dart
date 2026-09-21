/// Represents a single logical deduction or mathematical step.
class DirectedAlgebraStep {
  final String title;
  final String description;
  final String? mathLaTeX;

  DirectedAlgebraStep({
    required this.title,
    required this.description,
    this.mathLaTeX,
  });
}

/// Holds the results of a solved directed algebra operation.
class DirectedAlgebraResult {
  final String operation; // 'Multiply' or 'Divide'
  final String finalAnswerLaTeX;
  final List<String> workings;
  final List<DirectedAlgebraStep> steps;
  final bool valid;
  final String? errorMessage;

  DirectedAlgebraResult({
    required this.operation,
    required this.finalAnswerLaTeX,
    required this.workings,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}