/// Represents a single step in the divisibility solution.
class DivisibilityStep {
  final String description;
  final String? workingLaTeX;

  DivisibilityStep({
    required this.description,
    this.workingLaTeX,
  });
}

/// Holds all mathematical results and step-by-step breakdowns for the divisibility check.
class DivisibilityResult {
  final String number;
  final int divisor;
  final bool isDivisible;
  final String ruleApplied;
  final List<DivisibilityStep> steps;
  final bool valid;
  final String? error;

  DivisibilityResult({
    required this.number,
    required this.divisor,
    required this.isDivisible,
    required this.ruleApplied,
    required this.steps,
    required this.valid,
    this.error,
  });
}