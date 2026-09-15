/// Represents a single logical deduction or mathematical step.
class HexagonAnglesStep {
  final String title;
  final String description;
  final String mathLaTeX;

  HexagonAnglesStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the results of a solved hexagon geometry diagram.
class HexagonAnglesResult {
  final String diagramType;
  final Map<String, String> finalAngles;
  final List<String> workings;
  final List<HexagonAnglesStep> steps;
  final bool valid;
  final String? errorMessage;

  HexagonAnglesResult({
    required this.diagramType,
    required this.finalAngles,
    required this.workings,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}