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
  final List<BinaryDivisionStep> integerSteps;
  final List<BinaryDivisionStep> fractionSteps;
  final String expandedNotation;
  final List<String> stepByStep;
  final bool valid;
  final String? error;

  DecimalToBinaryResult({
    required this.originalInput,
    required this.binaryResult,
    required this.integerSteps,
    required this.fractionSteps,
    required this.expandedNotation,
    required this.stepByStep,
    required this.valid,
    this.error,
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
        integerSteps: [],
        fractionSteps: [],
        expandedNotation: "",
        stepByStep: ["Invalid input: '$input' is not a valid decimal or fraction."],
        valid: false,
        error: "Invalid decimal input.",
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
    int recurringStartIndex = -1;

    while (tempFrac > 0 && fracDigits.length < precision) {
      double multiplied = tempFrac * 2;
      int digit = multiplied.floor();
      double newFrac = multiplied - digit;
      fracSteps.add(BinaryDivisionStep(
        step: fracStep,
        value: tempFrac.toStringAsPrecision(precision),
        operation: "× 2",
        quotientOrIntPart: digit.toString(),
        remainderOrFraction: newFrac.toStringAsPrecision(precision),
      ));
      fracDigits.add(digit);

      // Detect recurring binary fraction
      if (seenRemainders.contains(newFrac)) {
        recurring = true;
        recurringStartIndex = fracDigits.indexOf(digit);
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

    // Expanded Notation
    List<String> expandedTerms = [];
    int intLen = intRemainders.length;
    for (int i = 0; i < intLen; i++) {
      int pow = intLen - 1 - i;
      int bit = intRemainders.reversed.toList()[i];
      expandedTerms.add("(${bit}×2${_superscript(pow)})");
    }
    List<String> expandedFracTerms = [];
    for (int i = 0; i < fracDigits.length; i++) {
      int bit = fracDigits[i];
      expandedFracTerms.add("(${bit}×2${_subscript(-(i + 1))})");
    }
    String expandedNotation = "$input₁₀ = " +
        expandedTerms.join(' + ') +
        (expandedFracTerms.isNotEmpty
            ? " + " + expandedFracTerms.join(' + ')
            : "") +
        "\n= $binaryResult₂";

    // Step-by-step description
    List<String> stepByStep = [];
    stepByStep.add("Integer Part Conversion:");
    for (final s in intSteps) {
      stepByStep.add(
          "Step ${s.step}: ${s.value} ${s.operation} = ${s.quotientOrIntPart}, remainder = ${s.remainderOrFraction}");
    }
    stepByStep.add(
        "Reading the remainders upwards gives the integer binary part: $intBinary");

    if (fracDigits.isNotEmpty) {
      stepByStep.add("Fractional Part Conversion:");
      for (final s in fracSteps) {
        stepByStep.add(
            "Step ${s.step}: ${s.value} ${s.operation} = ${s.quotientOrIntPart} (integer part), fractional remainder = ${s.remainderOrFraction}");
      }
      stepByStep.add(
          "The binary fraction is formed by taking the integer part from each multiplication in order: $fracBinary");
      if (recurring) {
        stepByStep.add(
            "Note: The binary fraction is recurring and truncated for display.");
      }
    }

    stepByStep.add(
        "Final Solution: $input in base ten is $binaryResult in base two.");

    return DecimalToBinaryResult(
      originalInput: input,
      binaryResult: binaryResult,
      integerSteps: intSteps,
      fractionSteps: fracSteps,
      expandedNotation: expandedNotation,
      stepByStep: stepByStep,
      valid: true,
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
      if (ch == '-') s += '\u207B';
      else s += sups[int.parse(ch)];
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
      if (ch == '-') s += '\u208B';
      else s += subs[int.parse(ch)];
    }
    return s;
  }
}