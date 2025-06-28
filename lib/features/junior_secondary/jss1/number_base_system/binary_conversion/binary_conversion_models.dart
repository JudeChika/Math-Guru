class BinaryToDecimalResult {
  final String binary;
  final int decimal;
  final List<String> expandedSteps;
  final List<String> stepByStep;

  BinaryToDecimalResult({
    required this.binary,
    required this.decimal,
    required this.expandedSteps,
    required this.stepByStep,
  });
}

class DecimalToBinaryResult {
  final int decimal;
  final String binary;
  final List<String> expandedSteps;
  final List<String> stepByStep;
  final String method; // 'Division' or 'SumOfPowers'

  DecimalToBinaryResult({
    required this.decimal,
    required this.binary,
    required this.expandedSteps,
    required this.stepByStep,
    required this.method,
  });
}