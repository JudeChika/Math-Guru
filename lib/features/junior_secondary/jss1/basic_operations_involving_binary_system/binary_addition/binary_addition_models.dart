// Update your existing binary_conversion_models.dart file to include these new classes

class BinaryAdditionStep {
  final int column;
  final List<int> bits;
  final int carry;
  final int sum;
  final int resultBit;
  final int newCarry;
  final String explanation;

  BinaryAdditionStep({
    required this.column,
    required this.bits,
    required this.carry,
    required this.sum,
    required this.resultBit,
    required this.newCarry,
    required this.explanation,
  });
}

class BinaryAdditionResult {
  final List<String> binaryInputs;
  final String binarySum;
  final int decimalSum;
  final List<BinaryAdditionStep> steps;
  final String workingDisplay;
  final List<String> stepByStepExplanation;
  final bool valid;
  final String? error;

  // Added for LaTeX rendering
  final String? workingDisplayLaTeX;
  final List<String>? stepByStepLaTeX;

  BinaryAdditionResult({
    required this.binaryInputs,
    required this.binarySum,
    required this.decimalSum,
    required this.steps,
    required this.workingDisplay,
    required this.stepByStepExplanation,
    required this.valid,
    this.error,
    this.workingDisplayLaTeX,
    this.stepByStepLaTeX,
  });
}