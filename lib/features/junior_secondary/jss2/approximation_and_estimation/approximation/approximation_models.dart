/// Represents a single logical deduction or mathematical step.
class ApproximationStep {
  final String title;
  final String description;
  final String? mathLaTeX;

  ApproximationStep({
    required this.title,
    required this.description,
    this.mathLaTeX,
  });
}

/// Holds the results of a solved approximation problem.
class ApproximationResult {
  final String originalNumber;
  final String mode; // 'd.p.', 's.f.', 'Whole Number', 'False Accuracy'
  final int? precision;
  final String finalAnswer;
  final List<ApproximationStep> steps;
  final bool valid;
  final String? errorMessage;

  ApproximationResult({
    required this.originalNumber,
    required this.mode,
    this.precision,
    required this.finalAnswer,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}