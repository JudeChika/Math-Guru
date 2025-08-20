import 'binary_subtraction_models.dart';

class BinarySubtractionLogic {
  /// Checks if a given string is a valid binary number.
  static bool isValidBinary(String s) => RegExp(r'^[01]+$').hasMatch(s);

  /// Converts binary string to decimal for verification
  static int binaryToDecimal(String binary) {
    int decimal = 0;
    for (int i = 0; i < binary.length; i++) {
      int power = binary.length - 1 - i;
      int digit = int.parse(binary[i]);
      decimal += digit * (1 << power);
    }
    return decimal;
  }

  /// Converts decimal to binary for verification
  static String decimalToBinary(int decimal) {
    if (decimal == 0) return "0";
    String binary = "";
    while (decimal > 0) {
      binary = (decimal % 2).toString() + binary;
      decimal ~/= 2;
    }
    return binary;
  }

  static BinarySubtractionResult subtractBinaryNumbers(String minuendStr, String subtrahendStr) {
    // Validate inputs
    String cleanMinuend = minuendStr.trim();
    String cleanSubtrahend = subtrahendStr.trim();

    if (!isValidBinary(cleanMinuend)) {
      return BinarySubtractionResult(
        minuend: cleanMinuend,
        subtrahend: cleanSubtrahend,
        binaryDifference: "",
        decimalDifference: 0,
        steps: [],
        workingDisplay: "",
        stepByStepExplanation: [
          "Invalid input: '$cleanMinuend' is not a valid binary number. Enter only 0s and 1s.",
        ],
        valid: false,
        error: "Invalid binary input.",
      );
    }

    if (!isValidBinary(cleanSubtrahend)) {
      return BinarySubtractionResult(
        minuend: cleanMinuend,
        subtrahend: cleanSubtrahend,
        binaryDifference: "",
        decimalDifference: 0,
        steps: [],
        workingDisplay: "",
        stepByStepExplanation: [
          "Invalid input: '$cleanSubtrahend' is not a valid binary number. Enter only 0s and 1s.",
        ],
        valid: false,
        error: "Invalid binary input.",
      );
    }

    // Check if minuend is smaller than subtrahend
    int minuendDecimal = binaryToDecimal(cleanMinuend);
    int subtrahendDecimal = binaryToDecimal(cleanSubtrahend);

    if (minuendDecimal < subtrahendDecimal) {
      return BinarySubtractionResult(
        minuend: cleanMinuend,
        subtrahend: cleanSubtrahend,
        binaryDifference: "",
        decimalDifference: 0,
        steps: [],
        workingDisplay: "",
        stepByStepExplanation: [
          "Error: Cannot subtract a larger number ($subtrahendDecimal) from a smaller number ($minuendDecimal).",
        ],
        valid: false,
        error: "Minuend must be greater than or equal to subtrahend.",
      );
    }

    // Find the maximum length to pad both numbers
    int maxLength = [cleanMinuend.length, cleanSubtrahend.length].reduce((a, b) => a > b ? a : b);

    // Pad both binary numbers with leading zeros
    String paddedMinuend = cleanMinuend.padLeft(maxLength, '0');
    String paddedSubtrahend = cleanSubtrahend.padLeft(maxLength, '0');

    // Perform subtraction column by column (right to left)
    List<BinarySubtractionStep> steps = [];
    List<int> result = [];
    List<int> minuendDigits = paddedMinuend.split('').map((s) => int.parse(s)).toList();
    List<int> subtrahendDigits = paddedSubtrahend.split('').map((s) => int.parse(s)).toList();

    int borrow = 0;

    for (int col = maxLength - 1; col >= 0; col--) {
      int minuendBit = minuendDigits[col];
      int subtrahendBit = subtrahendDigits[col];

      // Apply previous borrow
      minuendBit -= borrow;

      int resultBit;
      int newBorrow = 0;

      if (minuendBit >= subtrahendBit) {
        // No borrow needed
        resultBit = minuendBit - subtrahendBit;
      } else {
        // Need to borrow
        resultBit = (minuendBit + 2) - subtrahendBit;
        newBorrow = 1;
      }

      // Create explanation
      String explanation = _createStepExplanation(
          maxLength - 1 - col,
          minuendDigits[col], // Original minuend bit
          subtrahendBit,
          borrow,
          resultBit,
          newBorrow
      );

      steps.add(BinarySubtractionStep(
        column: maxLength - 1 - col,
        minuend: minuendDigits[col],
        subtrahend: subtrahendBit,
        borrow: borrow,
        result: resultBit,
        newBorrow: newBorrow,
        explanation: explanation,
      ));

      result.insert(0, resultBit);
      borrow = newBorrow;
    }

    // Remove leading zeros from result
    while (result.length > 1 && result[0] == 0) {
      result.removeAt(0);
    }

    String binaryDifference = result.join('');
    int decimalDifference = binaryToDecimal(binaryDifference);

    // Create working display
    String workingDisplay = _createWorkingDisplay(cleanMinuend, cleanSubtrahend, binaryDifference);
    String workingDisplayLaTeX = _createWorkingDisplayLaTeX(cleanMinuend, cleanSubtrahend, binaryDifference);

    // Create step-by-step explanation
    List<String> stepByStepExplanation = [];
    List<String> stepByStepLaTeX = [];

    stepByStepExplanation.add("Step-by-step Subtraction (right to left):");
    stepByStepLaTeX.add("\\text{Step-by-step Subtraction (right to left):}");

    for (BinarySubtractionStep step in steps) {
      stepByStepExplanation.add("• ${step.explanation}");
      stepByStepLaTeX.add(step.explanation);
    }

    stepByStepExplanation.add("Final Result: $binaryDifference₂ = $decimalDifference₁₀");
    stepByStepLaTeX.add("\\text{Final Result: } ${binaryDifference}_2 = ${decimalDifference}_{10}");

    // Verification
    int expectedDifference = minuendDecimal - subtrahendDecimal;
    if (decimalDifference == expectedDifference) {
      stepByStepExplanation.add("Verification: $cleanMinuend₂ - $cleanSubtrahend₂ = $minuendDecimal₁₀ - $subtrahendDecimal₁₀ = $expectedDifference₁₀ ✓");
      stepByStepLaTeX.add("\\text{Verification: } ${cleanMinuend}_2 - ${cleanSubtrahend}_2 = ${minuendDecimal}_{10} - ${subtrahendDecimal}_{10} = ${expectedDifference}_{10} \\checkmark");
    }

    return BinarySubtractionResult(
      minuend: cleanMinuend,
      subtrahend: cleanSubtrahend,
      binaryDifference: binaryDifference,
      decimalDifference: decimalDifference,
      steps: steps,
      workingDisplay: workingDisplay,
      stepByStepExplanation: stepByStepExplanation,
      valid: true,
      workingDisplayLaTeX: workingDisplayLaTeX,
      stepByStepLaTeX: stepByStepLaTeX,
    );
  }

  static String _createStepExplanation(int colIndex, int originalMinuend, int subtrahend, int borrow, int result, int newBorrow) {
    String borrowStr = borrow > 0 ? " (borrowed  from  previous  column)" : "";
    int effectiveMinuend = originalMinuend - borrow;

    if (newBorrow > 0) {
      // Had to borrow
      return "\\text{Col}_{$colIndex}: $originalMinuend$borrowStr - $subtrahend \\rightarrow \\text{borrow 1: } ($effectiveMinuend + 2) - $subtrahend = $result, \\text{borrow } $newBorrow";
    } else {
      // No borrow needed
      return "\\text{Col}_{$colIndex}: $originalMinuend$borrowStr - $subtrahend = $result";
    }
  }

  static String _createWorkingDisplay(String minuend, String subtrahend, String result) {
    List<String> lines = [];
    int maxLength = [minuend.length, subtrahend.length, result.length].reduce((a, b) => a > b ? a : b);

    String paddedMinuend = minuend.padLeft(maxLength, ' ');
    String paddedSubtrahend = subtrahend.padLeft(maxLength, ' ');
    String paddedResult = result.padLeft(maxLength, ' ');

    lines.add("  $paddedMinuend   ($minuend₂)");
    lines.add("- $paddedSubtrahend   ($subtrahend₂)");
    lines.add("=" * (maxLength + 2));
    lines.add("  $paddedResult = $result₂");

    return lines.join('\n');
  }

  static String _createWorkingDisplayLaTeX(String minuend, String subtrahend, String result) {
    List<String> lines = [];

    lines.add("${minuend}_2");
    lines.add("-\\ ${subtrahend}_2");
    lines.add("\\overline{\\phantom{$result}}");
    lines.add("${result}_2");

    return "\\begin{array}{r} ${lines.join(' \\\\ ')} \\end{array}";
  }
}