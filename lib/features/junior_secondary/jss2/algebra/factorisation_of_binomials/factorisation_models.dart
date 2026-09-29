/// Represents a single pedagogical step during the evaluation.
class FactorisationStep {
  final String title;
  final String description;
  final String mathLaTeX;

  FactorisationStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the results of a solved Factorisation or Complete Bracket problem.
class FactorisationResult {
  final String mode; // 'Factorise' or 'Complete Bracket'
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<FactorisationStep> steps;
  final bool valid;
  final String? errorMessage;

  FactorisationResult({
    required this.mode,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}