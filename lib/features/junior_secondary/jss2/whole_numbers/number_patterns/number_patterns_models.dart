/// Represents a single step in the step-by-step breakdown.
class PatternSolutionStep {
  final String description;
  final String? workingLaTeX;
  final bool isFinalAnswer;

  PatternSolutionStep({
    required this.description,
    this.workingLaTeX,
    this.isFinalAnswer = false,
  });
}

/// Holds the results for finding multiples within a range.
class MultiplesResult {
  final int start;
  final int end;
  final int multipleOf;
  final List<int> multiples;
  final List<PatternSolutionStep> steps;
  final bool valid;
  final String? errorMessage;

  MultiplesResult({
    required this.start,
    required this.end,
    required this.multipleOf,
    required this.multiples,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}

/// Holds the results for finding the Next Terms in a sequence.
class SequenceResult {
  final List<double> originalSequence;
  final String patternType; // e.g., "Arithmetic", "Geometric", "Changing Difference"
  final double commonDifferenceOrRatio;
  final int nextTermsRequested;
  final List<double> nextTerms;
  final List<PatternSolutionStep> steps;
  final bool valid;
  final String? errorMessage;

  SequenceResult({
    required this.originalSequence,
    required this.patternType,
    required this.commonDifferenceOrRatio,
    required this.nextTermsRequested,
    required this.nextTerms,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}

/// Holds the generated rows for Pascal's Triangle.
class PascalResult {
  final int numberOfRows;
  final List<List<int>> triangleRows;
  final List<PatternSolutionStep> steps;
  final bool valid;
  final String? errorMessage;

  PascalResult({
    required this.numberOfRows,
    required this.triangleRows,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}