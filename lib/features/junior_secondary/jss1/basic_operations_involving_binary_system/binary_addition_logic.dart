import 'binary_addition_models.dart';

class BinaryAdditionLogic {
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

  static BinaryAdditionResult addBinaryNumbers(List<String> inputs) {
    // Validate all inputs
    for (String input in inputs) {
      if (!isValidBinary(input.trim())) {
        return BinaryAdditionResult(
          binaryInputs: inputs,
          binarySum: "",
          decimalSum: 0,
          steps: [],
          workingDisplay: "",
          stepByStepExplanation: [
            "Invalid input: '$input' is not a valid binary number. Enter only 0s and 1s.",
          ],
          valid: false,
          error: "Invalid binary input.",
        );
      }
    }

    if (inputs.length < 2) {
      return BinaryAdditionResult(
        binaryInputs: inputs,
        binarySum: "",
        decimalSum: 0,
        steps: [],
        workingDisplay: "",
        stepByStepExplanation: [
          "Please enter at least 2 binary numbers to add.",
        ],
        valid: false,
        error: "Insufficient inputs.",
      );
    }

    // Clean and prepare inputs
    List<String> cleanInputs = inputs.map((s) => s.trim()).toList();

    // Find the maximum length to pad all numbers
    int maxLength = cleanInputs.map((s) => s.length).reduce((a, b) => a > b ? a : b);

    // Pad all binary numbers with leading zeros
    List<String> paddedInputs = cleanInputs.map((s) => s.padLeft(maxLength, '0')).toList();

    // Perform addition column by column (right to left)
    List<BinaryAdditionStep> steps = [];
    List<int> result = [];
    int carry = 0;

    for (int col = maxLength - 1; col >= 0; col--) {
      List<int> columnBits = [];

      // Get bits from each number at this column
      for (String paddedInput in paddedInputs) {
        columnBits.add(int.parse(paddedInput[col]));
      }

      // Calculate sum including carry
      int columnSum = columnBits.reduce((a, b) => a + b) + carry;
      int resultBit = columnSum % 2;
      int newCarry = columnSum ~/ 2;

      // Create explanation
      String explanation = _createStepExplanation(
          maxLength - 1 - col,
          columnBits,
          carry,
          columnSum,
          resultBit,
          newCarry
      );

      steps.add(BinaryAdditionStep(
        column: maxLength - 1 - col,
        bits: columnBits,
        carry: carry,
        sum: columnSum,
        resultBit: resultBit,
        newCarry: newCarry,
        explanation: explanation,
      ));

      result.insert(0, resultBit);
      carry = newCarry;
    }

    // Handle final carry
    if (carry > 0) {
      String carryBinary = decimalToBinary(carry);
      for (int i = carryBinary.length - 1; i >= 0; i--) {
        result.insert(0, int.parse(carryBinary[i]));
      }

      steps.add(BinaryAdditionStep(
        column: maxLength,
        bits: [],
        carry: carry,
        sum: carry,
        resultBit: carry,
        newCarry: 0,
        explanation: "Leftover carry becomes the new most-significant bit(s): $carry = $carryBinary₂",
      ));
    }

    String binarySum = result.join('');
    int decimalSum = binaryToDecimal(binarySum);

    // Create working display
    String workingDisplay = _createWorkingDisplay(cleanInputs, binarySum);
    String workingDisplayLaTeX = _createWorkingDisplayLaTeX(cleanInputs, binarySum);

    // Create step-by-step explanation
    List<String> stepByStepExplanation = [];
    List<String> stepByStepLaTeX = [];

    stepByStepExplanation.add("Step-by-step Addition (right to left):");
    stepByStepLaTeX.add("\\text{Step-by-step Addition (right to left):}");

    for (BinaryAdditionStep step in steps) {
      stepByStepExplanation.add("• ${step.explanation}");
      // Fixed LaTeX - properly escape special characters and avoid problematic subscripts
      String cleanExplanation = step.explanation
          .replaceAll('₀', '0').replaceAll('₁', '1').replaceAll('₂', '2')
          .replaceAll('₃', '3').replaceAll('₄', '4').replaceAll('₅', '5')
          .replaceAll('**', '')
          .replaceAll('→', 'then');
      stepByStepLaTeX.add("\\text{• $cleanExplanation}");
    }

    stepByStepExplanation.add("Final Result: $binarySum₂ = $decimalSum₁₀");
    stepByStepLaTeX.add("\\text{Final Result: } ${binarySum}_2 = ${decimalSum}_{10}");

    // Verification
    int expectedSum = cleanInputs.map(binaryToDecimal).reduce((a, b) => a + b);
    if (decimalSum != expectedSum) {
      stepByStepExplanation.add("Verification: ${cleanInputs.map((s) => '$s₂ = ${binaryToDecimal(s)}₁₀').join(' + ')} = $expectedSum₁₀ ✓");
    }

    return BinaryAdditionResult(
      binaryInputs: cleanInputs,
      binarySum: binarySum,
      decimalSum: decimalSum,
      steps: steps,
      workingDisplay: workingDisplay,
      stepByStepExplanation: stepByStepExplanation,
      valid: true,
      workingDisplayLaTeX: workingDisplayLaTeX,
      stepByStepLaTeX: stepByStepLaTeX,
    );
  }

  static String _createStepExplanation(int colIndex, List<int> bits, int carry, int sum, int resultBit, int newCarry) {
    String bitsStr = bits.join(' + ');
    String carryStr = carry > 0 ? " + carry$carry" : "";
    String sumInBinary = decimalToBinary(sum);

    return "Col${_subscript(colIndex)}: $bitsStr$carryStr = $sum = $sumInBinary₂ → write **$resultBit**${newCarry > 0 ? ', carry **$newCarry**' : ''}";
  }

  static String _createWorkingDisplay(List<String> inputs, String result) {
    List<String> lines = [];
    int maxLength = result.length;

    // Pad all inputs to result length for display
    for (int i = 0; i < inputs.length; i++) {
      String paddedInput = inputs[i].padLeft(maxLength, ' ');
      String prefix = i == 0 ? "  " : (i == 1 ? "+ " : "+ ");
      lines.add("$prefix$paddedInput   (${inputs[i]}₂)");
    }

    lines.add("=" * (maxLength + 2));
    lines.add("  $result = $result₂");

    return lines.join('\n');
  }

  static String _createWorkingDisplayLaTeX(List<String> inputs, String result) {
    List<String> lines = [];

    for (int i = 0; i < inputs.length; i++) {
      String prefix = i == 0 ? "" : "+\\ ";
      lines.add("$prefix${inputs[i]}_2");
    }

    lines.add("\\overline{\\phantom{$result}}");
    lines.add("${result}_2");

    return "\\begin{array}{r} ${lines.join(' \\\\ ')} \\end{array}";
  }

  static String _subscript(int n) {
    const subs = [
      "\u2080", "\u2081", "\u2082", "\u2083", "\u2084",
      "\u2085", "\u2086", "\u2087", "\u2088", "\u2089"
    ];
    String s = "";
    final str = n.toString();
    for (final ch in str.split('')) {
      s += subs[int.parse(ch)];
    }
    return s;
  }
}