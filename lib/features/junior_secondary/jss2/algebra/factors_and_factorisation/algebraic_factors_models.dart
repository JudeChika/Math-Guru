/// Represents a single pedagogical step during the evaluation.
class FactorsStep {
  final String title;
  final String description;
  final String mathLaTeX;

  FactorsStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the results of a solved Factors, HCF, or LCM problem.
class FactorsResult {
  final String mode; // 'All Factors', 'HCF', or 'LCM'
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<FactorsStep> steps;
  final bool valid;
  final String? errorMessage;

  FactorsResult({
    required this.mode,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}