/// Represents a single logical deduction or mathematical step.
class HeptagonAnglesStep {
  final String title;
  final String description;
  final String mathLaTeX;

  HeptagonAnglesStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the results of a solved heptagon geometry diagram.
class HeptagonAnglesResult {
  final String diagramType;
  final Map<String, String> finalAngles;
  final List<String> workings;
  final List<HeptagonAnglesStep> steps;
  final bool valid;
  final String? errorMessage;

  HeptagonAnglesResult({
    required this.diagramType,
    required this.finalAngles,
    required this.workings,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}