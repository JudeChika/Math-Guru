/// Represents a single logical deduction or mathematical step.
class QuadrilateralAnglesStep {
  final String title;
  final String description;
  final String mathLaTeX;

  QuadrilateralAnglesStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the results of a solved quadrilateral geometry diagram.
class QuadrilateralAnglesResult {
  final String diagramType;
  final Map<String, String> finalAngles;
  final List<String> workings;
  final List<QuadrilateralAnglesStep> steps;
  final bool valid;
  final String? errorMessage;

  QuadrilateralAnglesResult({
    required this.diagramType,
    required this.finalAngles,
    required this.workings,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}