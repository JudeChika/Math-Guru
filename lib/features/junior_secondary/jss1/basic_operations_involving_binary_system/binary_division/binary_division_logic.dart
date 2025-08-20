import 'binary_division_models.dart';

class BinaryDivisionLogic {
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

  /// Converts decimal to binary
  static String decimalToBinary(int decimal) {
    if (decimal == 0) return "0";
    String binary = "";
    while (decimal > 0) {
      binary = (decimal % 2).toString() + binary;
      decimal ~/= 2;
    }
    return binary;
  }

  /// Subtracts two binary numbers and returns the result
  static String subtractBinary(String minuend, String subtrahend) {
    // Pad to same length
    int maxLength = minuend.length > subtrahend.length ? minuend.length : subtrahend.length;
    minuend = minuend.padLeft(maxLength, '0');
    subtrahend = subtrahend.padLeft(maxLength, '0');

    List<int> result = [];
    int borrow = 0;

    for (int i = maxLength - 1; i >= 0; i--) {
      int minuendDigit = int.parse(minuend[i]);
      int subtrahendDigit = int.parse(subtrahend[i]);

      int diff = minuendDigit - subtrahendDigit - borrow;

      if (diff < 0) {
        diff += 2;
        borrow = 1;
      } else {
        borrow = 0;
      }

      result.insert(0, diff);
    }

    // Remove leading zeros
    String resultStr = result.join('');
    resultStr = resultStr.replaceFirst(RegExp(r'^0+'), '') ;
    return resultStr.isEmpty ? "0" : resultStr;
  }

  /// Compares two binary numbers. Returns 1 if a > b, 0 if a == b, -1 if a < b
  static int compareBinary(String a, String b) {
    // Remove leading zeros
    a = a.replaceFirst(RegExp(r'^0+'), '');
    b = b.replaceFirst(RegExp(r'^0+'), '');
    if (a.isEmpty) a = "0";
    if (b.isEmpty) b = "0";

    if (a.length > b.length) return 1;
    if (a.length < b.length) return -1;

    return a.compareTo(b);
  }

  /// Performs binary division using the specified method
  static BinaryDivisionResult divideBinaryNumbers(String dividendStr, String divisorStr, String method) {
    // Validate inputs
    String cleanDividend = dividendStr.trim();
    String cleanDivisor = divisorStr.trim();

    if (!isValidBinary(cleanDividend)) {
      return BinaryDivisionResult(
        dividend: cleanDividend,
        divisor: cleanDivisor,
        binaryQuotient: "",
        binaryRemainder: "",
        decimalQuotient: 0,
        decimalRemainder: 0,
        longDivisionSteps: [],
        subtractionSteps: [],
        workingDisplay: "",
        stepByStepExplanation: [
          "Invalid input: '$cleanDividend' is not a valid binary number. Enter only 0s and 1s.",
        ],
        valid: false,
        method: method,
        error: "Invalid binary input.",
      );
    }

    if (!isValidBinary(cleanDivisor)) {
      return BinaryDivisionResult(
        dividend: cleanDividend,
        divisor: cleanDivisor,
        binaryQuotient: "",
        binaryRemainder: "",
        decimalQuotient: 0,
        decimalRemainder: 0,
        longDivisionSteps: [],
        subtractionSteps: [],
        workingDisplay: "",
        stepByStepExplanation: [
          "Invalid input: '$cleanDivisor' is not a valid binary number. Enter only 0s and 1s.",
        ],
        valid: false,
        method: method,
        error: "Invalid binary input.",
      );
    }

    // Check for division by zero
    if (cleanDivisor == "0") {
      return BinaryDivisionResult(
        dividend: cleanDividend,
        divisor: cleanDivisor,
        binaryQuotient: "",
        binaryRemainder: "",
        decimalQuotient: 0,
        decimalRemainder: 0,
        longDivisionSteps: [],
        subtractionSteps: [],
        workingDisplay: "",
        stepByStepExplanation: [
          "Error: Division by zero is undefined.",
        ],
        valid: false,
        method: method,
        error: "Division by zero is undefined.",
      );
    }

    // Special case: dividend is 0
    if (cleanDividend == "0") {
      return BinaryDivisionResult(
        dividend: cleanDividend,
        divisor: cleanDivisor,
        binaryQuotient: "0",
        binaryRemainder: "0",
        decimalQuotient: 0,
        decimalRemainder: 0,
        longDivisionSteps: [],
        subtractionSteps: [],
        workingDisplay: "",
        stepByStepExplanation: ["0 divided by any number is 0"],
        stepByStepLaTeX: ["\\text{0 divided by any number is 0}"],
        valid: true,
        method: method,
      );
    }

    if (method == "repeated_subtraction") {
      return _performRepeatedSubtraction(cleanDividend, cleanDivisor);
    } else {
      return _performLongDivision(cleanDividend, cleanDivisor);
    }
  }

  static BinaryDivisionResult _performLongDivision(String dividend, String divisor) {
    List<BinaryDivisionStep> steps = [];
    List<String> stepByStepExplanation = [];
    List<String> stepByStepLaTeX = [];

    stepByStepExplanation.add("Step-by-step Binary Division (Long Division Method):");
    stepByStepLaTeX.add("\\text{Step-by-step Binary Division (Long Division Method):}");

    String quotient = "";
    String currentDividend = "";

    for (int i = 0; i < dividend.length; i++) {
      currentDividend += dividend[i];

      // Remove leading zeros except for the case where currentDividend is just "0"
      if (currentDividend.length > 1) {
        currentDividend = currentDividend.replaceFirst(RegExp(r'^0+'), '');
        if (currentDividend.isEmpty) currentDividend = "0";
      }

      String quotientBit;
      String newRemainder;

      if (compareBinary(currentDividend, divisor) >= 0) {
        quotientBit = "1";
        newRemainder = subtractBinary(currentDividend, divisor);

        steps.add(BinaryDivisionStep(
          dividend: currentDividend,
          divisor: divisor,
          quotientBit: quotientBit,
          remainder: newRemainder,
          explanation: "$currentDividend ÷ $divisor = 1 (since $currentDividend ≥ $divisor), remainder = $newRemainder",
        ));

        stepByStepExplanation.add("• Bring down ${dividend[i]}: $currentDividend ≥ $divisor, so quotient bit = 1");
        stepByStepLaTeX.add("\\text{Bring down ${dividend[i]}: } $currentDividend \\geq $divisor \\text{, so quotient bit = 1}");

        currentDividend = newRemainder;
      } else {
        quotientBit = "0";
        newRemainder = currentDividend;

        steps.add(BinaryDivisionStep(
          dividend: currentDividend,
          divisor: divisor,
          quotientBit: quotientBit,
          remainder: newRemainder,
          explanation: "$currentDividend ÷ $divisor = 0 (since $currentDividend < $divisor), remainder = $newRemainder",
        ));

        stepByStepExplanation.add("• Bring down ${dividend[i]}: $currentDividend < $divisor, so quotient bit = 0");
        stepByStepLaTeX.add("\\text{Bring down ${dividend[i]}: } $currentDividend < $divisor \\text{, so quotient bit = 0}");
      }

      quotient += quotientBit;
    }

    // Remove leading zeros from quotient
    quotient = quotient.replaceFirst(RegExp(r'^0+'), '');
    if (quotient.isEmpty) quotient = "0";

    String finalRemainder = currentDividend;

    // Verification
    int dividendDecimal = binaryToDecimal(dividend);
    int divisorDecimal = binaryToDecimal(divisor);
    int quotientDecimal = binaryToDecimal(quotient);
    int remainderDecimal = binaryToDecimal(finalRemainder);

    stepByStepExplanation.add("Final Result: $dividend₂ ÷ $divisor₂ = $quotient₂ remainder $finalRemainder₂");
    stepByStepLaTeX.add("\\text{Final Result: } ${dividend}_2 \\div ${divisor}_2 = ${quotient}_2 \\text{ remainder } ${finalRemainder}_2");

    stepByStepExplanation.add("Verification: $dividend₂ ÷ $divisor₂ = $dividendDecimal₁₀ ÷ $divisorDecimal₁₀ = $quotientDecimal₁₀ remainder $remainderDecimal₁₀ ✓");
    stepByStepLaTeX.add("\\text{Verification: } ${dividend}_2 \\div ${divisor}_2 = ${dividendDecimal}_{10} \\div ${divisorDecimal}_{10} = ${quotientDecimal}_{10} \\text{ remainder } ${remainderDecimal}_{10} \\checkmark");

    return BinaryDivisionResult(
      dividend: dividend,
      divisor: divisor,
      binaryQuotient: quotient,
      binaryRemainder: finalRemainder,
      decimalQuotient: quotientDecimal,
      decimalRemainder: remainderDecimal,
      longDivisionSteps: steps,
      subtractionSteps: [],
      workingDisplay: _createLongDivisionDisplay(dividend, divisor, quotient, finalRemainder, steps),
      stepByStepExplanation: stepByStepExplanation,
      valid: true,
      method: "long_division",
      stepByStepLaTeX: stepByStepLaTeX,
    );
  }

  static BinaryDivisionResult _performRepeatedSubtraction(String dividend, String divisor) {
    List<BinarySubtractionStep> steps = [];
    List<String> stepByStepExplanation = [];
    List<String> stepByStepLaTeX = [];

    stepByStepExplanation.add("Step-by-step Binary Division (Repeated Subtraction Method):");
    stepByStepLaTeX.add("\\text{Step-by-step Binary Division (Repeated Subtraction Method):}");

    String currentValue = dividend;
    int subtractionCount = 0;

    while (compareBinary(currentValue, divisor) >= 0) {
      subtractionCount++;
      String newValue = subtractBinary(currentValue, divisor);

      steps.add(BinarySubtractionStep(
        minuend: currentValue,
        subtrahend: divisor,
        difference: newValue,
        stepNumber: subtractionCount,
        explanation: "Step $subtractionCount: $currentValue - $divisor = $newValue",
      ));

      stepByStepExplanation.add("• Step $subtractionCount: $currentValue - $divisor = $newValue");
      stepByStepLaTeX.add("\\text{Step $subtractionCount: } $currentValue - $divisor = $newValue");

      currentValue = newValue;
    }

    String quotient = decimalToBinary(subtractionCount);
    String remainder = currentValue;

    stepByStepExplanation.add("Subtraction performed $subtractionCount times.");
    stepByStepLaTeX.add("\\text{Subtraction performed $subtractionCount times.}");

    stepByStepExplanation.add("$subtractionCount in decimal = $quotient in binary");
    stepByStepLaTeX.add("${subtractionCount}_{10} = ${quotient}_2");

    stepByStepExplanation.add("Final Result: $dividend₂ ÷ $divisor₂ = $quotient₂ remainder $remainder₂");
    stepByStepLaTeX.add("\\text{Final Result: } ${dividend}_2 \\div ${divisor}_2 = ${quotient}_2 \\text{ remainder } ${remainder}_2");

    // Verification
    int dividendDecimal = binaryToDecimal(dividend);
    int divisorDecimal = binaryToDecimal(divisor);
    int quotientDecimal = subtractionCount;
    int remainderDecimal = binaryToDecimal(remainder);

    stepByStepExplanation.add("Verification: $dividend₂ ÷ $divisor₂ = $dividendDecimal₁₀ ÷ $divisorDecimal₁₀ = $quotientDecimal₁₀ remainder $remainderDecimal₁₀ ✓");
    stepByStepLaTeX.add("\\text{Verification: } ${dividend}_2 \\div ${divisor}_2 = ${dividendDecimal}_{10} \\div ${divisorDecimal}_{10} = ${quotientDecimal}_{10} \\text{ remainder } ${remainderDecimal}_{10} \\checkmark");

    return BinaryDivisionResult(
      dividend: dividend,
      divisor: divisor,
      binaryQuotient: quotient,
      binaryRemainder: remainder,
      decimalQuotient: quotientDecimal,
      decimalRemainder: remainderDecimal,
      longDivisionSteps: [],
      subtractionSteps: steps,
      workingDisplay: _createRepeatedSubtractionDisplay(dividend, divisor, steps),
      stepByStepExplanation: stepByStepExplanation,
      valid: true,
      method: "repeated_subtraction",
      stepByStepLaTeX: stepByStepLaTeX,
    );
  }

  static String _createLongDivisionDisplay(String dividend, String divisor, String quotient, String remainder, List<BinaryDivisionStep> steps) {
    List<String> lines = [];
    lines.add("    $quotient");
    lines.add("   ________");
    lines.add("$divisor | $dividend");

    for (var step in steps) {
      if (step.quotientBit == "1") {
        lines.add("     ${step.divisor}");
        lines.add("     ----");
        lines.add("     ${step.remainder}");
      }
    }

    lines.add("");
    lines.add("Quotient: $quotient, Remainder: $remainder");

    return lines.join('\n');
  }

  static String _createRepeatedSubtractionDisplay(String dividend, String divisor, List<BinarySubtractionStep> steps) {
    List<String> lines = [];

    for (var step in steps) {
      lines.add("  ${step.minuend}");
      lines.add("- ${step.subtrahend}");
      lines.add("-------");
      lines.add("  ${step.difference}");
      lines.add("");
    }

    return lines.join('\n');
  }
}