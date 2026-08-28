/// Represents a single logical deduction or mathematical step.
class AnglesRuleStep {
  final String title;
  final String description;
  final String mathLaTeX;

  AnglesRuleStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the results of a solved geometry diagram.
class AnglesRuleResult {
  final String diagramType;
  final Map<String, String> finalAngles;
  final List<String> workings;
  final List<AnglesRuleStep> steps;
  final bool valid;
  final String? errorMessage;

  AnglesRuleResult({
    required this.diagramType,
    required this.finalAngles,
    required this.workings,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}