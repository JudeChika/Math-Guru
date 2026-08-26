/// Represents a single step in the algebraic breakdown.
class DirectedStep {
  final String description;
  final String workingLaTeX;

  DirectedStep({
    required this.description,
    required this.workingLaTeX,
  });
}

/// Represents a single jump (arrow) on the number line graph.
class NumberLineJump {
  final double start;
  final double amount;
  final double end;
  final bool isResult;

  NumberLineJump({
    required this.start,
    required this.amount,
    required this.end,
    this.isResult = false,
  });
}

/// Holds the completely evaluated results, steps, and graphical jumps.
class DirectedResult {
  final String originalExpression;
  final double finalValue;
  final String finalValueLaTeX;
  final List<String> workingsLaTeX;
  final List<DirectedStep> steps;
  final List<NumberLineJump> jumps;
  final bool valid;
  final String? errorMessage;

  DirectedResult({
    required this.originalExpression,
    required this.finalValue,
    required this.finalValueLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.jumps,
    this.valid = true,
    this.errorMessage,
  });
}