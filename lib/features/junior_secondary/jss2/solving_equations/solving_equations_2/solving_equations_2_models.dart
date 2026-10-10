/// Represents a single pedagogical step during the equation solving process.
class Equation2Step {
  final String title;
  final String description;
  final String mathLaTeX;

  Equation2Step({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the final evaluated results and the step-by-step breakdown.
class Equation2Result {
  final String originalEquationLaTeX;
  final String finalAnswerLaTeX;
  final List<String> workingsLaTeX;
  final List<Equation2Step> steps;
  final bool valid;
  final String? errorMessage;

  Equation2Result({
    required this.originalEquationLaTeX,
    required this.finalAnswerLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}