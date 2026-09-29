/// Represents a single pedagogical step during the evaluation.
class AlgFractionsStep {
  final String title;
  final String description;
  final String mathLaTeX;

  AlgFractionsStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Represents a single fraction inputted by the user
class AlgFractionItem {
  String sign;
  String numStr;
  String denStr;

  AlgFractionItem({
    required this.sign,
    required this.numStr,
    required this.denStr,
  });
}

/// Holds the results of a solved Algebraic Fractions problem.
class AlgFractionsResult {
  final String mode; // 'Equivalent' or 'AddSub'
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<AlgFractionsStep> steps;
  final bool valid;
  final String? errorMessage;

  AlgFractionsResult({
    required this.mode,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}