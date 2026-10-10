/// Represents a single pedagogical step during the construction.
class ConstructionStep {
  final String title;
  final String description;
  final String mathLaTeX;

  ConstructionStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Represents an arc drawn by a compass.
class ConstructionArc {
  final double centerX;
  final double centerY;
  final double radius;
  final double startAngle; // In radians
  final double sweepAngle; // In radians

  ConstructionArc({
    required this.centerX,
    required this.centerY,
    required this.radius,
    required this.startAngle,
    required this.sweepAngle,
  });
}

/// Represents a vertex on the triangle.
class TrianglePoint {
  final String name;
  final double x;
  final double y;

  TrianglePoint({required this.name, required this.x, required this.y});
}

/// Holds the results of a constructed triangle.
class TriangleConstructionResult {
  final String mode; // 'SAS', 'ASA', or 'SSS'
  final List<TrianglePoint> vertices;
  final List<ConstructionArc> arcs;
  final Map<String, String> measurements;
  final List<String> workingsLaTeX;
  final List<ConstructionStep> steps;
  final bool valid;
  final String? errorMessage;

  TriangleConstructionResult({
    required this.mode,
    required this.vertices,
    this.arcs = const [],
    required this.measurements,
    this.workingsLaTeX = const [],
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}