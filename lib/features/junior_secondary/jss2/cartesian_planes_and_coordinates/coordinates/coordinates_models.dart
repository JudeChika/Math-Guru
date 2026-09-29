/// Represents a single pedagogical step during the coordinate evaluation.
class CoordinateStep {
  final String title;
  final String description;
  final String? mathLaTeX;

  CoordinateStep({
    required this.title,
    required this.description,
    this.mathLaTeX,
  });
}

/// A simple class to hold an inputted coordinate point.
class CoordinatePoint {
  final String name;
  final double x;
  final double y;

  CoordinatePoint({required this.name, required this.x, required this.y});
}

/// Holds the final evaluated results and the step-by-step breakdown.
class CoordinateResult {
  final List<CoordinatePoint> points;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<CoordinateStep> steps;
  final bool valid;
  final String? errorMessage;

  CoordinateResult({
    required this.points,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}