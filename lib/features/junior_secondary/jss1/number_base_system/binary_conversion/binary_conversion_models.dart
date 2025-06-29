class BinaryToDecimalResult {
  final String binaryInput;
  final int? decimalOutput;
  final String expandedNotation;
  final List<String> steps;
  final bool valid;
  final String? error;

  BinaryToDecimalResult({
    required this.binaryInput,
    required this.decimalOutput,
    required this.expandedNotation,
    required this.steps,
    required this.valid,
    this.error,
  });
}

enum DecimalToBinaryMethod {
  standard, // Division by 2
  sumOfPowers, // Sum of powers of 2
}

class DecimalToBinaryResult {
  final String decimalInput;
  final String? binaryOutput;
  final String expandedNotation;
  final List<String> steps;
  final bool valid;
  final String? error;

  DecimalToBinaryResult({
    required this.decimalInput,
    required this.binaryOutput,
    required this.expandedNotation,
    required this.steps,
    required this.valid,
    this.error,
  });
}