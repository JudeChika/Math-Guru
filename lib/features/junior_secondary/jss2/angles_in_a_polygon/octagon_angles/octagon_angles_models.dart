/// Represents a single logical deduction or mathematical step.
class OctagonAnglesStep {
  final String title;
  final String description;
  final String mathLaTeX;

  OctagonAnglesStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the results of a solved octagon geometry diagram.
class OctagonAnglesResult {
  final String diagramType;
  final Map<String, String> finalAngles;
  final List<String> workings;
  final List<OctagonAnglesStep> steps;
  final bool valid;
  final String? errorMessage;

  OctagonAnglesResult({
    required this.diagramType,
    required this.finalAngles,
    required this.workings,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}