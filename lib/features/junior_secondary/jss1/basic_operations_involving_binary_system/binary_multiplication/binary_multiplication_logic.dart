import 'binary_multiplication_models.dart';

class BinaryMultiplicationLogic {
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

  /// Adds multiple binary numbers (for partial products)
  static String addBinaryNumbers(List<String> binaryNumbers) {
    if (binaryNumbers.isEmpty) return "0";
    if (binaryNumbers.length == 1) return binaryNumbers[0];

    // Find max length
    int maxLength = binaryNumbers.map((s) => s.length).reduce((a, b) => a > b ? a : b);

    // Pad all numbers
    List<String> paddedNumbers = binaryNumbers.map((s) => s.padLeft(maxLength, '0')).toList();

    List<int> result = [];
    int carry = 0;

    for (int col = maxLength - 1; col >= 0; col--) {
      int columnSum = carry;

      for (String number in paddedNumbers) {
        columnSum += int.parse(number[col]);
      }

      int resultBit = columnSum % 2;
      carry = columnSum ~/ 2;

      result.insert(0, resultBit);
    }

    // Handle final carry
    while (carry > 0) {
      result.insert(0, carry % 2);
      carry ~/= 2;
    }

    return result.join('');
  }

  static BinaryMultiplicationResult multiplyBinaryNumbers(String multiplicandStr, String multiplierStr) {
    // Validate inputs
    String cleanMultiplicand = multiplicandStr.trim();
    String cleanMultiplier = multiplierStr.trim();

    if (!isValidBinary(cleanMultiplicand)) {
      return BinaryMultiplicationResult(
        multiplicand: cleanMultiplicand,
        multiplier: cleanMultiplier,
        binaryProduct: "",
        decimalProduct: 0,
        steps: [],
        partialProducts: [],
        workingDisplay: "",
        stepByStepExplanation: [
          "Invalid input: '$cleanMultiplicand' is not a valid binary number. Enter only 0s and 1s.",
        ],
        valid: false,
        error: "Invalid binary input.",
      );
    }

    if (!isValidBinary(cleanMultiplier)) {
      return BinaryMultiplicationResult(
        multiplicand: cleanMultiplicand,
        multiplier: cleanMultiplier,
        binaryProduct: "",
        decimalProduct: 0,
        steps: [],
        partialProducts: [],
        workingDisplay: "",
        stepByStepExplanation: [
          "Invalid input: '$cleanMultiplier' is not a valid binary number. Enter only 0s and 1s.",
        ],
        valid: false,
        error: "Invalid binary input.",
      );
    }

    // Special cases
    if (cleanMultiplicand == "0" || cleanMultiplier == "0") {
      return BinaryMultiplicationResult(
        multiplicand: cleanMultiplicand,
        multiplier: cleanMultiplier,
        binaryProduct: "0",
        decimalProduct: 0,
        steps: [],
        partialProducts: ["0"],
        workingDisplay: "",
        stepByStepExplanation: ["Result is 0 since one operand is 0"],
        stepByStepLaTeX: ["\\text{Result is 0 since one operand is 0}"],
        valid: true,
      );
    }

    // Perform long multiplication
    List<BinaryMultiplicationStep> steps = [];
    List<String> partialProducts = [];

    // Generate partial products (right to left)
    for (int i = cleanMultiplier.length - 1; i >= 0; i--) {
      int multiplierBit = int.parse(cleanMultiplier[i]);
      int position = cleanMultiplier.length - 1 - i;

      String partialProduct;
      String explanation;

      if (multiplierBit == 0) {
        // Multiplying by 0 gives zeros with proper positioning
        int productLength = cleanMultiplicand.length + position;
        partialProduct = "0" * productLength;
        explanation = "\\text{Step ${steps.length + 1}: } ${cleanMultiplicand}_2 \\times $multiplierBit = ${"0" * productLength}_2 \\text{ (all zeros)}";
      } else {
        // Multiplying by 1 gives the multiplicand shifted left by position
        partialProduct = cleanMultiplicand + ("0" * position);
        explanation = "\\text{Step ${steps.length + 1}: } ${cleanMultiplicand}_2 \\times $multiplierBit = ${cleanMultiplicand}_2 \\text{ shifted $position positions} = ${partialProduct}_2";
      }

      steps.add(BinaryMultiplicationStep(
        multiplierBit: multiplierBit,
        position: position,
        partialProduct: partialProduct,
        explanation: explanation,
      ));

      // Add all partial products (including zeros) for display
      partialProducts.add(partialProduct);
    }

    // Add all partial products (including those with zeros)
    String binaryProduct = addBinaryNumbers(partialProducts);
    int decimalProduct = binaryToDecimal(binaryProduct);

    // Create working display
    String workingDisplay = _createWorkingDisplay(cleanMultiplicand, cleanMultiplier, partialProducts, binaryProduct);
    String workingDisplayLaTeX = _createWorkingDisplayLaTeX(cleanMultiplicand, cleanMultiplier, partialProducts, binaryProduct);

    // Create step-by-step explanation
    List<String> stepByStepExplanation = [];
    List<String> stepByStepLaTeX = [];

    stepByStepExplanation.add("Step-by-step Multiplication (long multiplication method):");
    stepByStepLaTeX.add("\\text{Step-by-step Multiplication (long multiplication method):}");

    for (BinaryMultiplicationStep step in steps) {
      stepByStepExplanation.add("• ${step.explanation}");
      stepByStepLaTeX.add(step.explanation);
    }

    if (partialProducts.length > 1) {
      stepByStepExplanation.add("• Add all partial products: ${partialProducts.join(' + ')} = $binaryProduct₂");
      stepByStepLaTeX.add("\\text{Add all partial products: } ${partialProducts.join(' + ')}_2 = ${binaryProduct}_2");
    }

    stepByStepExplanation.add("Final Result: $binaryProduct₂ = $decimalProduct₁₀");
    stepByStepLaTeX.add("\\text{Final Result: } ${binaryProduct}_2 = ${decimalProduct}_{10}");

    // Verification
    int multiplicandDecimal = binaryToDecimal(cleanMultiplicand);
    int multiplierDecimal = binaryToDecimal(cleanMultiplier);
    int expectedProduct = multiplicandDecimal * multiplierDecimal;

    if (decimalProduct == expectedProduct) {
      stepByStepExplanation.add("Verification: $cleanMultiplicand₂ × $cleanMultiplier₂ = $multiplicandDecimal₁₀ × $multiplierDecimal₁₀ = $expectedProduct₁₀ ✓");
      stepByStepLaTeX.add("\\text{Verification: } ${cleanMultiplicand}_2 \\times ${cleanMultiplier}_2 = ${multiplicandDecimal}_{10} \\times ${multiplierDecimal}_{10} = ${expectedProduct}_{10} \\checkmark");
    }

    return BinaryMultiplicationResult(
      multiplicand: cleanMultiplicand,
      multiplier: cleanMultiplier,
      binaryProduct: binaryProduct,
      decimalProduct: decimalProduct,
      steps: steps,
      partialProducts: partialProducts,
      workingDisplay: workingDisplay,
      stepByStepExplanation: stepByStepExplanation,
      valid: true,
      workingDisplayLaTeX: workingDisplayLaTeX,
      stepByStepLaTeX: stepByStepLaTeX,
    );
  }

  static String _createWorkingDisplay(String multiplicand, String multiplier, List<String> partialProducts, String result) {
    List<String> lines = [];

    // Find max length for alignment
    List<String> allNumbers = [multiplicand, multiplier, result, ...partialProducts];
    int maxLength = allNumbers.map((s) => s.length).reduce((a, b) => a > b ? a : b);

    lines.add("  ${multiplicand.padLeft(maxLength, ' ')}   ($multiplicand₂)");
    lines.add("× ${multiplier.padLeft(maxLength, ' ')}   ($multiplier₂)");
    lines.add("${'─' * (maxLength + 2)}");

    for (String partial in partialProducts) {
      lines.add("  ${partial.padLeft(maxLength, ' ')}");
    }

    if (partialProducts.length > 1) {
      lines.add("${'─' * (maxLength + 2)}");
    }

    lines.add("  ${result.padLeft(maxLength, ' ')} = $result₂");

    return lines.join('\n');
  }

  static String _createWorkingDisplayLaTeX(String multiplicand, String multiplier, List<String> partialProducts, String result) {
    List<String> lines = [];

    lines.add("${multiplicand}_2");
    lines.add("\\times\\ ${multiplier}_2");
    lines.add("\\overline{\\phantom{$result}}");

    for (String partial in partialProducts) {
      lines.add("${partial}_2");
    }

    if (partialProducts.length > 1) {
      lines.add("\\overline{\\phantom{$result}}");
    }

    lines.add("${result}_2");

    return "\\begin{array}{r} ${lines.join(' \\\\ ')} \\end{array}";
  }
}