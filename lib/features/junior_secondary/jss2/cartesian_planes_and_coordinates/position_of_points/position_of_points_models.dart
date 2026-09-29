/// Represents a point on a 1D number line.
class Point1D {
  final String name;
  final double x;

  Point1D({required this.name, required this.x});
}

/// Represents a point on a 2D Cartesian plane.
class Point2D {
  final String name;
  final double x;
  final double y;

  Point2D({required this.name, required this.x, required this.y});
}

/// Represents a single pedagogical step during the plotting process.
class PositionStep {
  final String title;
  final String description;
  final String? mathLaTeX;

  PositionStep({
    required this.title,
    required this.description,
    this.mathLaTeX,
  });
}

/// Holds the final evaluated results and the step-by-step breakdown.
class PositionResult {
  final String mode; // '1D' or '2D'
  final List<Point1D> points1D;
  final List<Point2D> points2D;

  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<PositionStep> steps;
  final bool valid;
  final String? errorMessage;

  PositionResult({
    required this.mode,
    this.points1D = const [],
    this.points2D = const [],
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}