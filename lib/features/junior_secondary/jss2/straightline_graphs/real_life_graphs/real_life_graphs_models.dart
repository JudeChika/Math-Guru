/// Represents a single question/query to read from the graph
class RealLifeGraphQuestion {
  final String type; // 'findY' (given X) or 'findX' (given Y)
  final double givenValue;

  RealLifeGraphQuestion({required this.type, required this.givenValue});
}

/// Represents a single pedagogical step
class RealLifeGraphStep {
  final String title;
  final String description;
  final String? mathLaTeX;

  RealLifeGraphStep({
    required this.title,
    required this.description,
    this.mathLaTeX,
  });
}

/// Holds the final evaluated results, graph plotting data, and steps
class RealLifeGraphResult {
  final String mode; // 'FixedVariable', 'DirectConversion', or 'TwoPoint'
  final String xLabel;
  final String yLabel;

  // The line equation: y = mx + c
  final double m; // Gradient / Rate
  final double c; // Y-Intercept / Standing Charge

  final double scaleX;
  final double scaleY;

  final List<Map<String, double>> tableOfValues;
  final List<RealLifeGraphQuestion> questions;
  final Map<String, String> finalAnswers;

  final List<String> workingsLaTeX;
  final List<RealLifeGraphStep> steps;

  final bool valid;
  final String? errorMessage;

  RealLifeGraphResult({
    required this.mode,
    required this.xLabel,
    required this.yLabel,
    required this.m,
    required this.c,
    required this.scaleX,
    required this.scaleY,
    required this.tableOfValues,
    required this.questions,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}