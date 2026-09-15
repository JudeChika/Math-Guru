/// Represents a single logical deduction or mathematical step.
class PentagonAnglesStep {
  final String title;
  final String description;
  final String mathLaTeX;

  PentagonAnglesStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the results of a solved pentagon geometry diagram.
class PentagonAnglesResult {
  final String diagramType;
  final Map<String, String> finalAngles;
  final List<String> workings;
  final List<PentagonAnglesStep> steps;
  final bool valid;
  final String? errorMessage;

  PentagonAnglesResult({
    required this.diagramType,
    required this.finalAngles,
    required this.workings,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}