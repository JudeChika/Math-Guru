/// Represents a single logical deduction or mathematical step.
class TriangleAnglesStep {
  final String title;
  final String description;
  final String mathLaTeX;

  TriangleAnglesStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the results of a solved triangle geometry diagram.
class TriangleAnglesResult {
  final String diagramType;
  final Map<String, String> finalAngles;
  final List<String> workings;
  final List<TriangleAnglesStep> steps;
  final bool valid;
  final String? errorMessage;

  TriangleAnglesResult({
    required this.diagramType,
    required this.finalAngles,
    required this.workings,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}