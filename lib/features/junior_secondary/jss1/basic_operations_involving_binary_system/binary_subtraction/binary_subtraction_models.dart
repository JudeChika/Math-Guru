class BinarySubtractionStep {
  final int column;
  final int minuend;
  final int subtrahend;
  final int borrow;
  final int result;
  final int newBorrow;
  final String explanation;

  BinarySubtractionStep({
    required this.column,
    required this.minuend,
    required this.subtrahend,
    required this.borrow,
    required this.result,
    required this.newBorrow,
    required this.explanation,
  });
}

class BinarySubtractionResult {
  final String minuend;
  final String subtrahend;
  final String binaryDifference;
  final int decimalDifference;
  final List<BinarySubtractionStep> steps;
  final String workingDisplay;
  final List<String> stepByStepExplanation;
  final bool valid;
  final String? error;

  // Added for LaTeX rendering
  final String? workingDisplayLaTeX;
  final List<String>? stepByStepLaTeX;

  BinarySubtractionResult({
    required this.minuend,
    required this.subtrahend,
    required this.binaryDifference,
    required this.decimalDifference,
    required this.steps,
    required this.workingDisplay,
    required this.stepByStepExplanation,
    required this.valid,
    this.error,
    this.workingDisplayLaTeX,
    this.stepByStepLaTeX,
  });
}