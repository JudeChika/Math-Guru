class BinaryDivisionStep {
  final int step;
  final String value;
  final String operation;
  final String quotientOrIntPart;
  final String remainderOrFraction;

  BinaryDivisionStep({
    required this.step,
    required this.value,
    required this.operation,
    required this.quotientOrIntPart,
    required this.remainderOrFraction,
  });
}

class DecimalToBinaryResult {
  final String originalInput;
  final String? binaryResult;
  final String expandedNotation;
  final String expandedValues;
  final String finalResult;
  final List<BinaryDivisionStep> integerSteps;
  final List<BinaryDivisionStep> fractionSteps;
  final List<String> stepByStep;
  final bool valid;
  final String? error;

  // Added for LaTeX rendering
  final String? expandedNotationLaTeX;
  final String? expandedValuesLaTeX;
  final String? finalResultLaTeX;
  final List<String>? stepByStepLaTeX;

  DecimalToBinaryResult({
    required this.originalInput,
    required this.binaryResult,
    required this.expandedNotation,
    required this.expandedValues,
    required this.finalResult,
    required this.integerSteps,
    required this.fractionSteps,
    required this.stepByStep,
    required this.valid,
    this.error,
    this.expandedNotationLaTeX,
    this.expandedValuesLaTeX,
    this.finalResultLaTeX,
    this.stepByStepLaTeX,
  });
}

class DecimalToBinaryLogic {
  static List<String> parseDecimalInputs(String input) {
    final cleaned = input.replaceAll(',', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) return [];
    return cleaned
        .split(' ')
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  static double? parseNumber(String s) {
    s = s.trim();
    if (s.contains('/')) {
      final parts = s.split('/');
      if (parts.length == 2) {
        final num = double.tryParse(parts[0]);
        final den = double.tryParse(parts[1]);
        if (num != null && den != null && den != 0) {
          return num / den;
        }
      }
      return null;
    }
    return double.tryParse(s);
  }

  static DecimalToBinaryResult convert(String input, {int fractionBits = 8}) {
    final numVal = parseNumber(input);
    if (numVal == null) {
      return DecimalToBinaryResult(
        originalInput: input,
        binaryResult: null,
        expandedNotation: "",
        expandedValues: "",
        finalResult: "",
        integerSteps: [],
        fractionSteps: [],
        stepByStep: ["Invalid input: '$input' is not a valid decimal or fraction."],
        valid: false,
        error: "Invalid decimal input.",
        expandedNotationLaTeX: null,
        expandedValuesLaTeX: null,
        finalResultLaTeX: null,
        stepByStepLaTeX: null,
      );
    }

    int intPart = numVal.truncate();
    double fracPart = numVal - intPart;

    // Integer part: Division by 2
    List<BinaryDivisionStep> intSteps = [];
    List<int> intRemainders = [];
    int tempInt = intPart;
    int step = 1;
    if (intPart == 0) {
      intSteps.add(BinaryDivisionStep(
        step: step,
        value: "0",
        operation: "÷ 2",
        quotientOrIntPart: "0",
        remainderOrFraction: "0",
      ));
      intRemainders.add(0);
      step++;
    } else {
      while (tempInt > 0) {
        int quotient = tempInt ~/ 2;
        int remainder = tempInt % 2;
        intSteps.add(BinaryDivisionStep(
          step: step,
          value: tempInt.toString(),
          operation: "÷ 2",
          quotientOrIntPart: quotient.toString(),
          remainderOrFraction: remainder.toString(),
        ));
        intRemainders.add(remainder);
        tempInt = quotient;
        step++;
      }
    }

    // Fraction part: Multiplication by 2
    List<BinaryDivisionStep> fracSteps = [];
    List<int> fracDigits = [];
    double tempFrac = fracPart;
    int fracStep = 1;
    int precision = fractionBits;
    bool recurring = false;
    Set<double> seenRemainders = {};

    while (tempFrac > 0 && fracDigits.length < precision) {
      double multiplied = tempFrac * 2;
      int digit = multiplied.floor();
      double newFrac = multiplied - digit;

      // Format the fractional values to avoid precision issues in display
      String tempFracStr = tempFrac.toStringAsFixed(6);
      String newFracStr = newFrac.toStringAsFixed(6);

      fracSteps.add(BinaryDivisionStep(
        step: fracStep,
        value: tempFracStr,
        operation: "× 2",
        quotientOrIntPart: digit.toString(),
        remainderOrFraction: newFracStr,
      ));
      fracDigits.add(digit);

      // Detect recurring binary fraction
      if (seenRemainders.contains(newFrac)) {
        recurring = true;
        break;
      }
      seenRemainders.add(newFrac);

      tempFrac = newFrac;
      fracStep++;
    }

    // Compose binary string
    String intBinary = intRemainders.reversed.join('');
    String fracBinary = fracDigits.join('');
    String binaryResult = fracBinary.isNotEmpty ? "$intBinary.$fracBinary" : intBinary;

    // Expanded Notation and LaTeX versions
    List<String> expandedTerms = [];
    List<String> expandedValues = [];
    List<String> expandedTermsLaTeX = [];
    List<String> expandedValuesListLaTeX = [];
    int intLen = intRemainders.length;
    List<int> intRemaindersReversed = intRemainders.reversed.toList();

    for (int i = 0; i < intLen; i++) {
      int pow = intLen - 1 - i;
      int bit = intRemaindersReversed[i];
      int actualValue = bit * (1 << pow);
      expandedTerms.add("($bit×2${_superscript(pow)})");
      expandedValues.add("$actualValue");
      // Fixed LaTeX - simplified syntax
      expandedTermsLaTeX.add("$bit \\times 2^{$pow}");
      expandedValuesListLaTeX.add("$actualValue");
    }

    List<String> expandedFracTerms = [];
    List<String> expandedFracValues = [];
    List<String> expandedFracTermsLaTeX = [];
    List<String> expandedFracValuesListLaTeX = [];

    for (int i = 0; i < fracDigits.length; i++) {
      int bit = fracDigits[i];
      double value = bit * (1 / (1 << (i + 1)));
      expandedFracTerms.add("($bit×2${_subscript(-(i + 1))})");
      expandedFracValues.add(value.toStringAsFixed(6));
      // Fixed LaTeX - simplified negative exponent syntax
      expandedFracTermsLaTeX.add("$bit \\times 2^{-${i + 1}}");
      expandedFracValuesListLaTeX.add(value.toStringAsFixed(6));
    }

    String expandedNotation = "$input₁₀ = ${expandedTerms.join(' + ')}${expandedFracTerms.isNotEmpty
        ? " + ${expandedFracTerms.join(' + ')}"
        : ""}";
    String expandedValuesStr = "= ${expandedValues.join(' + ')}${expandedFracValues.isNotEmpty
        ? " + ${expandedFracValues.join(' + ')}"
        : ""}";
    String finalResult = "= $binaryResult\u2082";

    // Fixed LaTeX - cleaner syntax without problematic double braces
    String expandedNotationLaTeX =
        "${input}_{10} = ${expandedTermsLaTeX.join(' + ')}${expandedFracTermsLaTeX.isNotEmpty ? " + ${expandedFracTermsLaTeX.join(' + ')}" : ""}";
    String expandedValuesLaTeX =
        "${expandedValuesListLaTeX.join(' + ')}${expandedFracValuesListLaTeX.isNotEmpty ? " + ${expandedFracValuesListLaTeX.join(' + ')}" : ""}";
    String finalResultLaTeX = "${binaryResult}_2";

    // Step-by-step description
    List<String> stepByStep = [];
    List<String> stepByStepLaTeX = [];
    stepByStep.add("Integer Part Conversion:");
    stepByStepLaTeX.add("\\text{Integer Part Conversion:}");

    for (final s in intSteps) {
      stepByStep.add(
          "Step ${s.step}: ${s.value} ${s.operation} = ${s.quotientOrIntPart}, remainder = ${s.remainderOrFraction}");
      stepByStepLaTeX.add(
          "\\text{Step } ${s.step}: ${s.value} \\div 2 = ${s.quotientOrIntPart}, \\text{ remainder } = ${s.remainderOrFraction}");
    }
    stepByStep.add(
        "Reading the remainders upwards gives the integer binary part: $intBinary");
    stepByStepLaTeX.add(
        "\\text{Reading the remainders upwards gives the integer binary part: } $intBinary");

    if (fracDigits.isNotEmpty) {
      stepByStep.add("Fractional Part Conversion:");
      stepByStepLaTeX.add("\\text{Fractional Part Conversion:}");

      for (final s in fracSteps) {
        stepByStep.add(
            "Step ${s.step}: ${s.value} ${s.operation} = ${s.quotientOrIntPart} (integer part), fractional remainder = ${s.remainderOrFraction}");
        stepByStepLaTeX.add(
            "\\text{Step } ${s.step}: ${s.value} \\times 2 = ${s.quotientOrIntPart} \\text{ (integer part), fractional remainder } = ${s.remainderOrFraction}");
      }
      stepByStep.add(
          "The binary fraction is formed by taking the integer part from each multiplication in order: $fracBinary");
      stepByStepLaTeX.add(
          "\\text{The binary fraction is formed by taking the integer part from each multiplication in order: } $fracBinary");
      if (recurring) {
        stepByStep.add(
            "Note: The binary fraction is recurring and truncated for display.");
        stepByStepLaTeX.add(
            "\\text{Note: The binary fraction is recurring and truncated for display.}");
      }
    }

    stepByStep.add(
        "Final Solution: $input in base ten is $binaryResult in base two.");
    stepByStepLaTeX.add(
        "\\text{Final Solution: } $input \\text{ in base ten is } $binaryResult \\text{ in base two.}");

    return DecimalToBinaryResult(
      originalInput: input,
      binaryResult: binaryResult,
      expandedNotation: expandedNotation,
      expandedValues: expandedValuesStr,
      finalResult: finalResult,
      integerSteps: intSteps,
      fractionSteps: fracSteps,
      stepByStep: stepByStep,
      valid: true,
      expandedNotationLaTeX: expandedNotationLaTeX,
      expandedValuesLaTeX: expandedValuesLaTeX,
      finalResultLaTeX: finalResultLaTeX,
      stepByStepLaTeX: stepByStepLaTeX,
    );
  }

  static String _superscript(int n) {
    const sups = [
      "\u2070",
      "\u00b9",
      "\u00b2",
      "\u00b3",
      "\u2074",
      "\u2075",
      "\u2076",
      "\u2077",
      "\u2078",
      "\u2079"
    ];
    if (n == 0) return sups[0];
    String s = "";
    for (final ch in n.toString().split('')) {
      if (ch == '-') {
        s += '\u207B';
      } else {
        s += sups[int.parse(ch)];
      }
    }
    return s;
  }

  static String _subscript(int n) {
    const subs = [
      "\u2080",
      "\u2081",
      "\u2082",
      "\u2083",
      "\u2084",
      "\u2085",
      "\u2086",
      "\u2087",
      "\u2088",
      "\u2089"
    ];
    String s = "";
    final str = n.toString();
    for (final ch in str.split('')) {
      if (ch == '-') {
        s += '\u208B';
      } else {
        s += subs[int.parse(ch)];
      }
    }
    return s;
  }
}