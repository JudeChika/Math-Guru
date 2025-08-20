class BinaryMultiplicationStep {
  final int multiplierBit;
  final int position;
  final String partialProduct;
  final String explanation;

  BinaryMultiplicationStep({
    required this.multiplierBit,
    required this.position,
    required this.partialProduct,
    required this.explanation,
  });
}

class BinaryMultiplicationResult {
  final String multiplicand;
  final String multiplier;
  final String binaryProduct;
  final int decimalProduct;
  final List<BinaryMultiplicationStep> steps;
  final List<String> partialProducts;
  final String workingDisplay;
  final List<String> stepByStepExplanation;
  final bool valid;
  final String? error;

  // Added for LaTeX rendering
  final String? workingDisplayLaTeX;
  final List<String>? stepByStepLaTeX;

  BinaryMultiplicationResult({
    required this.multiplicand,
    required this.multiplier,
    required this.binaryProduct,
    required this.decimalProduct,
    required this.steps,
    required this.partialProducts,
    required this.workingDisplay,
    required this.stepByStepExplanation,
    required this.valid,
    this.error,
    this.workingDisplayLaTeX,
    this.stepByStepLaTeX,
  });
}