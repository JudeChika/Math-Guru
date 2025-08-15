class BinaryToDecimalResult {
  final String binaryInput;
  final int? decimalOutput;
  final String expandedNotation;
  final String expandedValues;
  final String finalResult;
  final List<String> steps;
  final bool valid;
  final String? error;

  // Added for LaTeX rendering
  final String? expandedNotationLaTeX;
  final String? expandedValuesLaTeX;
  final String? finalResultLaTeX;
  final List<String>? stepsLaTeX;

  BinaryToDecimalResult({
    required this.binaryInput,
    required this.decimalOutput,
    required this.expandedNotation,
    required this.expandedValues,
    required this.finalResult,
    required this.steps,
    required this.valid,
    this.error,
    this.expandedNotationLaTeX,
    this.expandedValuesLaTeX,
    this.finalResultLaTeX,
    this.stepsLaTeX,
  });
}

class BinaryToDecimalLogic {
  /// Parses user input into a list of binary string values.
  static List<String> parseBinaryInputs(String input) {
    final cleaned = input.replaceAll(',', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) return [];
    return cleaned
        .split(' ')
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  /// Checks if a given string is a valid binary number.
  static bool isValidBinary(String s) => RegExp(r'^[01]+$').hasMatch(s);

  static BinaryToDecimalResult convert(String input) {
    final binary = input.trim();
    if (!isValidBinary(binary)) {
      return BinaryToDecimalResult(
        binaryInput: binary,
        decimalOutput: null,
        expandedNotation: "",
        expandedValues: "",
        finalResult: "",
        steps: [
          "Invalid input: '$binary' is not a valid binary number. Enter only 0s and 1s.",
        ],
        valid: false,
        error: "Invalid binary input.",
        expandedNotationLaTeX: null,
        expandedValuesLaTeX: null,
        finalResultLaTeX: null,
        stepsLaTeX: null,
      );
    }

    final digits = binary.split('');
    int len = digits.length;
    int decimal = 0;
    List<String> terms = [];
    List<String> values = [];
    List<String> stepDetails = [];
    List<String> termsLaTeX = [];
    List<String> valuesLaTeX = [];
    List<String> stepsLaTeX = [];

    for (int i = 0; i < len; i++) {
      int power = len - 1 - i;
      int digit = int.parse(digits[i]);
      int value = digit * (1 << power);
      terms.add("($digit×2${_superscript(power)})");
      values.add("$value");
      termsLaTeX.add("($digit \\times 2^{$power})");
      valuesLaTeX.add("$value");
      stepDetails.add(
          "Step ${i + 1}: $digit × 2${_superscript(power)} = $value");
      stepsLaTeX.add("Step ${i + 1}: $digit \\times 2^{$power} = $value");
      decimal += value;
    }

    final expandedNotation = "${_formatBinaryBase2(binary)} = ${terms.join(' + ')}";
    final expandedValues = "= ${values.join(' + ')}";
    final finalResult = "= $decimal";
    final expandedNotationLaTeX = "${binary}_2 = ${termsLaTeX.join(' + ')}";
    final expandedValuesLaTeX = "= ${valuesLaTeX.join(' + ')}";
    final finalResultLaTeX = "= $decimal";

    stepDetails.add("Final Solution: $binary in base two is $decimal in base ten.");
    stepsLaTeX.add("Final\\ Solution:\\ $binary\\ in\\ base\\ two\\ is\\ $decimal\\ in\\ base\\ ten.");

    return BinaryToDecimalResult(
      binaryInput: binary,
      decimalOutput: decimal,
      expandedNotation: expandedNotation,
      expandedValues: expandedValues,
      finalResult: finalResult,
      steps: stepDetails,
      valid: true,
      expandedNotationLaTeX: expandedNotationLaTeX,
      expandedValuesLaTeX: expandedValuesLaTeX,
      finalResultLaTeX: finalResultLaTeX,
      stepsLaTeX: stepsLaTeX,
    );
  }

  static String _powerSup(int n) {
    // Only works for 0-9
    const sups = [
      "\u2070", "\u00b9", "\u00b2", "\u00b3", "\u2074", "\u2075",
      "\u2076", "\u2077", "\u2078", "\u2079"
    ];
    if (n == 0) return sups[0];
    String s = "";
    for (final ch in n.toString().split('')) {
      s += sups[int.parse(ch)];
    }
    return s;
  }

  static String _superscript(int n) => _powerSup(n);

  /// Formats a string such as "11011" as "11011₂"
  static String _formatBinaryBase2(String binary) {
    return "$binary\u2082";
  }
}