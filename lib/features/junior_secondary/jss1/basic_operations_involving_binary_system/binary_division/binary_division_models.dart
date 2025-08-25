class BinaryDivisionStep {
  final String dividend;
  final String divisor;
  final String quotientBit;
  final String remainder;
  final String explanation;

  BinaryDivisionStep({
    required this.dividend,
    required this.divisor,
    required this.quotientBit,
    required this.remainder,
    required this.explanation,
  });
}

class BinarySubtractionStep {
  final String minuend;
  final String subtrahend;
  final String difference;
  final int stepNumber;
  final String explanation;

  BinarySubtractionStep({
    required this.minuend,
    required this.subtrahend,
    required this.difference,
    required this.stepNumber,
    required this.explanation,
  });
}

class BinaryDivisionResult {
  final String dividend;
  final String divisor;
  final String binaryQuotient;
  final String binaryRemainder;
  final int decimalQuotient;
  final int decimalRemainder;
  final List<BinaryDivisionStep> longDivisionSteps;
  final List<BinarySubtractionStep> subtractionSteps;
  final String workingDisplay;
  final List<String> stepByStepExplanation;
  final bool valid;
  final String? error;
  final String method; // "long_division" or "repeated_subtraction"

  // Added for LaTeX rendering
  final String? workingDisplayLaTeX;
  final List<String>? stepByStepLaTeX;

  BinaryDivisionResult({
    required this.dividend,
    required this.divisor,
    required this.binaryQuotient,
    required this.binaryRemainder,
    required this.decimalQuotient,
    required this.decimalRemainder,
    required this.longDivisionSteps,
    required this.subtractionSteps,
    required this.workingDisplay,
    required this.stepByStepExplanation,
    required this.valid,
    required this.method,
    this.error,
    this.workingDisplayLaTeX,
    this.stepByStepLaTeX,
  });
}

class BinaryDivisionExplanationStep {
  final String description;
  final String? latexMath;

  BinaryDivisionExplanationStep({
    required this.description,
    this.latexMath,
  });
}

