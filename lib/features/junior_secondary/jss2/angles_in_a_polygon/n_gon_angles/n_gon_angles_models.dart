/// Represents a single logical deduction or mathematical step.
class NSidedStep {
  final String title;
  final String description;
  final String mathLaTeX;

  NSidedStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the results of a solved n-sided polygon problem.
class NSidedResult {
  final int nSides;
  final String mode; // 'Regular' or 'Irregular'
  final Map<String, String> finalAngles;
  final List<String> workings;
  final List<NSidedStep> steps;
  final bool valid;
  final String? errorMessage;

  NSidedResult({
    required this.nSides,
    required this.mode,
    required this.finalAngles,
    required this.workings,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}