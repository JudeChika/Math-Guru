import 'dart:math' as math;
import 'sum_and_difference_models.dart';

class SumAndDifferenceLogic {
  // ===========================================================================
  // 14 TEXTBOOK PRESETS (Pages 19–22: Exercise 2.1 #13–25 & Teacher's Guide)
  // ===========================================================================
  static const List<SumAndDifferencePreset> textbookPresets = [
    SumAndDifferencePreset(
      chipLabel: "Ex 2.1 #13: Positive difference between -16 and -69",
      mode: 0,
      subMode: 0,
      input1: '-16',
      input2: '-69',
    ),
    SumAndDifferencePreset(
      chipLabel: "Ex 2.1 #14: Positive difference between 114 and -14",
      mode: 0,
      subMode: 0,
      input1: '114',
      input2: '-14',
    ),
    SumAndDifferencePreset(
      chipLabel: "Ex 2.1 #19: Positive difference between -11.9 and 2.8",
      mode: 0,
      subMode: 0,
      input1: '-11.9',
      input2: '2.8',
    ),
    SumAndDifferencePreset(
      chipLabel: "Ex 2.1 #15: Sum of 3 consecutive odd numbers = 177",
      mode: 2,
      consecutiveCount: 3,
      consecutiveType: 2, // Odd
      input1: '177',
    ),
    SumAndDifferencePreset(
      chipLabel: "Ex 2.1 #16: 3 consecutive even numbers add up to 258",
      mode: 2,
      consecutiveCount: 3,
      consecutiveType: 3, // Even
      input1: '258',
    ),
    SumAndDifferencePreset(
      chipLabel: "Ex 2.1 #17: Difference is 9; one number is 18.5",
      mode: 1,
      subMode: 1,
      input1: '18.5',
      input2: '9',
    ),
    SumAndDifferencePreset(
      chipLabel: "Ex 2.1 #18: Difference between 28.2 and x is 21.2 (2 values)",
      mode: 1,
      subMode: 1,
      input1: '28.2',
      input2: '21.2',
    ),
    SumAndDifferencePreset(
      chipLabel: "Ex 2.1 #20: Sum of x and 7 ¾ is -2 ½",
      mode: 1,
      subMode: 0,
      input1: '7 3/4',
      input2: '-2 1/2',
    ),
    SumAndDifferencePreset(
      chipLabel: "Ex 2.1 #21: Sum is -4.36; one number is 7.23",
      mode: 1,
      subMode: 0,
      input1: '7.23',
      input2: '-4.36',
    ),
    SumAndDifferencePreset(
      chipLabel: "Ex 2.1 #22: -10 is the difference between 7 and x (2 values)",
      mode: 1,
      subMode: 1,
      input1: '7',
      input2: '-10',
    ),
    SumAndDifferencePreset(
      chipLabel: "Ex 2.1 #23: Sum of a number and 15 is 24",
      mode: 1,
      subMode: 0,
      input1: '15',
      input2: '24',
    ),
    SumAndDifferencePreset(
      chipLabel: "Ex 2.1 #24: Three integers (x-1), x, (x+1) sum to 105",
      mode: 2,
      consecutiveCount: 3,
      consecutiveType: 1, // Centered (x-1), x, (x+1)
      input1: '105',
    ),
    SumAndDifferencePreset(
      chipLabel: "Ex 2.1 #25: Sum of 4 consecutive negative numbers = -258",
      mode: 2,
      consecutiveCount: 4,
      consecutiveType: 0, // Standard consecutive integers x, x+1, x+2, x+3
      input1: '-258',
    ),
    SumAndDifferencePreset(
      chipLabel: "Simultaneous: Sum of two numbers is 42, difference is 10",
      mode: 3,
      subMode: 0,
      input1: '42',
      input2: '10',
    ),
  ];

  // ===========================================================================
  // UNIVERSAL NUMBER & FRACTION PARSING / FORMATTING ENGINE
  // ===========================================================================
  static int gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final int t = b;
      b = a % b;
      a = t;
    }
    return a == 0 ? 1 : a;
  }

  static int lcm(int a, int b) {
    if (a == 0 || b == 0) return 1;
    return ((a.abs() * b.abs()) ~/ gcd(a, b));
  }

  static String fmt(double v, {int maxDecimals = 4}) {
    if (v.abs() < 1e-9) return '0';
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// Wraps a negative number in parentheses when it follows an operator (e.g. "- (-69)")
  static String wrapNegLaTeX(ParsedNumber n) {
    return n.value < 0 ? "\\left(${n.displayLaTeX}\\right)" : n.displayLaTeX;
  }

  static String wrapNegPlain(ParsedNumber n) {
    return n.value < 0 ? "(${n.displayPlain})" : n.displayPlain;
  }

  /// Formats any rational fraction `num / den` as both plain and LaTeX mixed/proper fraction
  static Map<String, String> formatRational(int num, int den) {
    if (den == 0) return {'plain': '0', 'latex': '0', 'improperLaTeX': '0'};
    if (num == 0) return {'plain': '0', 'latex': '0', 'improperLaTeX': '0'};

    final bool isNeg = (num < 0) ^ (den < 0);
    int n = num.abs();
    int d = den.abs();
    final int g = gcd(n, d);
    n ~/= g;
    d ~/= g;
    final String sign = isNeg ? '-' : '';

    if (d == 1) {
      return {
        'plain': '$sign$n',
        'latex': '$sign$n',
        'improperLaTeX': '$sign$n',
      };
    }

    final String impTex = '$sign\\frac{$n}{$d}';
    if (n > d) {
      final int w = n ~/ d;
      final int rem = n % d;
      return {
        'plain': '$sign$w $rem/$d',
        'latex': '$sign$w\\frac{$rem}{$d}',
        'improperLaTeX': impTex,
      };
    } else {
      return {
        'plain': '$sign$n/$d',
        'latex': impTex,
        'improperLaTeX': impTex,
      };
    }
  }

  /// Parses any user number string: integers ("-16"), decimals ("-11.9", "18.5"),
  /// proper/improper fractions ("-5/2"), or mixed fractions ("7 3/4", "-2 1/2", "7¾").
  static ParsedNumber parseFlexibleNumber(String raw, {String fieldName = 'number'}) {
    String s = raw
        .trim()
        .replaceAll('−', '-')
        .replaceAll('½', ' 1/2')
        .replaceAll('¼', ' 1/4')
        .replaceAll('¾', ' 3/4')
        .replaceAll('⅓', ' 1/3')
        .replaceAll('⅔', ' 2/3')
        .replaceAll(',', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (s.isEmpty) {
      throw FormatException("Please enter a valid $fieldName (e.g. -16, 18.5, or 7 3/4).");
    }

    if (s.contains('/')) {
      final List<String> parts = s.split(' ');
      if (parts.length == 2) {
        // Mixed number like "7 3/4" or "-2 1/2"
        final bool isNeg = parts[0].startsWith('-');
        final int wholeAbs = int.parse(parts[0].replaceAll('-', '').replaceAll('+', ''));
        final List<String> fParts = parts[1].split('/');
        final int fNum = int.parse(fParts[0]);
        final int fDen = int.parse(fParts[1]);
        if (fDen <= 0) {
          throw const FormatException("Fraction denominator must be greater than zero.");
        }
        final int impAbs = wholeAbs * fDen + fNum;
        final int signedNum = isNeg ? -impAbs : impAbs;
        final double val = signedNum / fDen;
        final String signStr = isNeg ? '-' : '';

        return ParsedNumber(
          rawInput: raw.trim(),
          value: val,
          num: signedNum,
          den: fDen,
          isFractionOrMixed: true,
          isMixedInput: true,
          displayPlain: '$signStr$wholeAbs $fNum/$fDen',
          displayLaTeX: '$signStr$wholeAbs\\frac{$fNum}{$fDen}',
          improperLaTeX: '$signStr\\frac{$impAbs}{$fDen}',
        );
      } else if (parts.length == 1) {
        // Proper or improper fraction like "3/4" or "-5/2"
        final List<String> fParts = parts[0].split('/');
        final int fNum = int.parse(fParts[0]);
        final int fDen = int.parse(fParts[1]);
        if (fDen == 0) {
          throw const FormatException("Fraction denominator cannot be zero.");
        }
        final Map<String, String> fmtMap = formatRational(fNum, fDen);
        return ParsedNumber(
          rawInput: raw.trim(),
          value: fNum / fDen,
          num: fDen < 0 ? -fNum : fNum,
          den: fDen.abs(),
          isFractionOrMixed: true,
          isMixedInput: false,
          displayPlain: fmtMap['plain']!,
          displayLaTeX: fmtMap['latex']!,
          improperLaTeX: fmtMap['improperLaTeX']!,
        );
      } else {
        throw FormatException("Invalid fraction format '$raw'. Try '7 3/4' or '-2 1/2'.");
      }
    }

    // Standard integer or decimal
    final String noSpace = s.replaceAll(' ', '');
    final double? val = double.tryParse(noSpace);
    if (val == null) {
      throw FormatException("Could not read '$raw' as a valid number.");
    }

    // Represent as exact rational for unified arithmetic if needed
    int decPlaces = 0;
    if (noSpace.contains('.')) {
      decPlaces = noSpace.split('.')[1].length.clamp(0, 6);
    }
    final int scaleDen = math.pow(10, decPlaces).round();
    final int scaledNum = (val * scaleDen).round();
    final int g = gcd(scaledNum, scaleDen);

    final String cleanStr = fmt(val);
    return ParsedNumber(
      rawInput: raw.trim(),
      value: val,
      num: scaledNum ~/ g,
      den: scaleDen ~/ g,
      isFractionOrMixed: false,
      isMixedInput: false,
      displayPlain: cleanStr,
      displayLaTeX: cleanStr,
      improperLaTeX: cleanStr,
    );
  }

  // ===========================================================================
  // MODE 0: DIRECT SUM, POSITIVE DIFFERENCE & NEGATIVE DIFFERENCE SOLVER
  // Covers Exercise 2.1 #1–14 & #19 (e.g., #13: -16 and -69; #14: 114 and -14; #19: -11.9 and 2.8)
  // ===========================================================================
  static SumAndDifferenceResult solveDirectSumAndDifference({
    required String numAStr,
    required String numBStr,
    required int operationType,
    // 0: Positive Difference (Larger - Smaller) [Ex 2.1 #13, #14, #19]
    // 1: Negative Difference (Smaller - Larger) [Teacher's Guide p.19]
    // 2: Sum of the Two Numbers (A + B)
    // 3: Compare All Three (Sum, Positive Difference & Negative Difference)
  }) {
    try {
      final ParsedNumber a =
      parseFlexibleNumber(numAStr, fieldName: 'First Number (A)');
      final ParsedNumber b =
      parseFlexibleNumber(numBStr, fieldName: 'Second Number (B)');

      final bool useFractions = a.isFractionOrMixed || b.isFractionOrMixed;
      final ParsedNumber larger = a.value >= b.value ? a : b;
      final ParsedNumber smaller = a.value >= b.value ? b : a;

      final double posDiffVal = larger.value - smaller.value;
      final double negDiffVal = smaller.value - larger.value;
      final double sumVal = a.value + b.value;

      final List<String> workings = [];
      final List<SumAndDifferenceStep> steps = [];
      final Map<String, String> answers = {};

      // Step 1: Teacher's Guide Distinction (Operation vs. Result) & Number-Line Comparison
      final List<String> step1Math = [
        "\\text{First Number (A)} = ${a.displayLaTeX}, \\qquad \\text{Second Number (B)} = ${b.displayLaTeX}",
        "\\text{Compare on the Number Line: } \\mathbf{${larger.displayLaTeX} > ${smaller.displayLaTeX}}",
        "\\text{Larger Number} = \\mathbf{${larger.displayLaTeX}}, \\qquad \\text{Smaller Number} = \\mathbf{${smaller.displayLaTeX}}",
      ];

      workings.add(
          "\\text{\\textbf{Step 1: Identify the Larger and Smaller Number on the Number Line}}");
      workings.addAll(step1Math);
      workings.add("");

      steps.add(SumAndDifferenceStep(
        title:
        "Step 1: Compare ${a.displayPlain} and ${b.displayPlain} on the Directed Number Line",
        description:
        "• Teacher's Guide Rule (Page 19): Addition (+) and subtraction (−) are operations, whereas 'sum' and 'difference' are the results obtained.\n"
            "• On a horizontal number line, numbers increase from left to right. Because ${larger.displayPlain} lies to the RIGHT of ${smaller.displayPlain}, ${larger.displayPlain} is the LARGER number and ${smaller.displayPlain} is the SMALLER number!",
        mathLinesLaTeX: step1Math,
      ));

      // Helper for fraction vs decimal/integer subtraction/addition lines
      List<String> buildBinaryOpLines({
        required String titleFormulaLaTeX,
        required ParsedNumber left,
        required ParsedNumber right,
        required bool isAddition,
      }) {
        final List<String> lines = [titleFormulaLaTeX];
        final String opSym = isAddition ? "+" : "-";
        lines.add("= ${left.displayLaTeX} $opSym ${wrapNegLaTeX(right)}");

        // Explain directed-number sign simplification when right is negative!
        if (!isAddition && right.value < 0) {
          lines.add(
              "\\text{Directed-number rule: Subtracting a negative number is the same as adding its positive opposite } (-(-k) = +k):");
          lines.add("= ${left.displayLaTeX} + ${fmt(right.value.abs())}");
        } else if (isAddition && right.value < 0) {
          lines.add(
              "\\text{Directed-number rule: Adding a negative number is the same as subtracting its positive opposite } (+(-k) = -k):");
          lines.add("= ${left.displayLaTeX} - ${fmt(right.value.abs())}");
        }

        if (useFractions) {
          final int commonDen = lcm(left.den, right.den);
          final int scaledL = left.num * (commonDen ~/ left.den);
          final int scaledR = right.num * (commonDen ~/ right.den);
          final int resNum = isAddition ? (scaledL + scaledR) : (scaledL - scaledR);
          final Map<String, String> resFmt = formatRational(resNum, commonDen);

          if (left.isMixedInput || right.isMixedInput) {
            lines.add(
                "\\text{Convert mixed numbers to improper fractions: } = ${left.improperLaTeX} $opSym \\left(${right.improperLaTeX}\\right)");
          }
          lines.add(
              "\\text{Express over the LCM of the denominators } ($commonDen): \\quad = \\frac{$scaledL $opSym (${scaledR < 0 ? scaledR : '$scaledR'})}{$commonDen} = \\frac{$resNum}{$commonDen}");
          lines.add(
              "= \\mathbf{${resFmt['latex']}} \\quad \\left(\\text{or } \\mathbf{${fmt(resNum / commonDen)}}\\right)");
        } else {
          final double res =
          isAddition ? (left.value + right.value) : (left.value - right.value);
          lines.add("= \\mathbf{${fmt(res)}}");
        }
        return lines;
      }

      // Step 2: Perform the Requested Calculation(s)
      if (operationType == 0 || operationType == 3) {
        final List<String> posLines = buildBinaryOpLines(
          titleFormulaLaTeX:
          "\\text{Positive Difference} = \\text{Larger Number} - \\text{Smaller Number}",
          left: larger,
          right: smaller,
          isAddition: false,
        );

        workings.add(
            "\\text{\\textbf{Step 2: Calculate the Positive Difference (Larger - Smaller)}}");
        workings.addAll(posLines);
        if (operationType == 3) workings.add("");

        steps.add(SumAndDifferenceStep(
          title:
          "Step 2: Find the Positive Difference (Larger − Smaller)",
          description:
          "• Rule (Page 19): We obtain a POSITIVE difference when the smaller number (${smaller.displayPlain}) is subtracted from the larger number (${larger.displayPlain}).\n"
              "${smaller.value < 0 ? '• Watch the signs carefully: ${larger.displayPlain} − (${smaller.displayPlain}) becomes ${larger.displayPlain} + ${fmt(smaller.value.abs())} because subtracting a negative number is the same as adding a positive number!\n' : ''}"
              "• Therefore, the positive difference is ${fmt(posDiffVal)}.",
          mathLinesLaTeX: posLines,
        ));

        answers["Larger Number"] = larger.displayPlain;
        answers["Smaller Number"] = smaller.displayPlain;
        answers["Positive Difference"] = fmt(posDiffVal);
      }

      if (operationType == 1 || operationType == 3) {
        final List<String> negLines = buildBinaryOpLines(
          titleFormulaLaTeX:
          "\\text{Negative Difference} = \\text{Smaller Number} - \\text{Larger Number}",
          left: smaller,
          right: larger,
          isAddition: false,
        );

        workings.add(
            "\\text{\\textbf{Calculate the Negative Difference (Smaller - Larger)}}");
        workings.addAll(negLines);
        if (operationType == 3) workings.add("");

        steps.add(SumAndDifferenceStep(
          title:
          "Step ${steps.length + 1}: Find the Negative Difference (Smaller − Larger)",
          description:
          "• Rule (Page 19): We obtain a NEGATIVE difference when the larger number (${larger.displayPlain}) is subtracted from the smaller number (${smaller.displayPlain}).\n"
              "• Calculation: ${smaller.displayPlain} − ${wrapNegPlain(larger)} = ${fmt(negDiffVal)}.",
          mathLinesLaTeX: negLines,
        ));

        answers["Negative Difference"] = fmt(negDiffVal);
      }

      if (operationType == 2 || operationType == 3) {
        final List<String> sumLines = buildBinaryOpLines(
          titleFormulaLaTeX:
          "\\text{Sum} = \\text{First Number} + \\text{Second Number}",
          left: a,
          right: b,
          isAddition: true,
        );

        workings.add(
            "\\text{\\textbf{Calculate the Sum of the Two Numbers (A + B)}}");
        workings.addAll(sumLines);

        steps.add(SumAndDifferenceStep(
          title:
          "Step ${steps.length + 1}: Find the Sum of ${a.displayPlain} and ${b.displayPlain}",
          description:
          "• Rule (Page 19): The 'sum' is the result obtained when two or more quantities are added together.\n"
              "• Calculation: ${a.displayPlain} + ${wrapNegPlain(b)} = ${fmt(sumVal)}.",
          mathLinesLaTeX: sumLines,
        ));

        answers["Sum (A + B)"] = fmt(sumVal);
      }

      return SumAndDifferenceResult(
        mode: 0,
        subMode: operationType,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SumAndDifferenceCanvasData(
          visualType: 0,
          markers: [
            NumberLineMarker(
              value: smaller.value,
              topLabel: "Smaller (${smaller.displayPlain})",
              bottomValueLabel: smaller.displayPlain,
              isPrimaryHighlight: false,
            ),
            NumberLineMarker(
              value: larger.value,
              topLabel: "Larger (${larger.displayPlain})",
              bottomValueLabel: larger.displayPlain,
              isPrimaryHighlight: true,
            ),
          ],
          arcs: [
            NumberLineArc(
              fromVal: smaller.value,
              toVal: larger.value,
              label: operationType == 1
                  ? "Negative Diff = ${fmt(negDiffVal)}"
                  : "Positive Diff = +${fmt(posDiffVal)}",
              isPositiveJump: operationType != 1,
            ),
          ],
          headerBadge:
          "Numbers: ${a.displayPlain} and ${b.displayPlain}   |   Larger = ${larger.displayPlain}, Smaller = ${smaller.displayPlain}",
          subBadge:
          "Positive Difference = ${larger.displayPlain} − ${wrapNegPlain(smaller)} = ${fmt(posDiffVal)}   |   Sum = ${fmt(sumVal)}",
          bottomSummaryBanner:
          "Positive Difference = ${fmt(posDiffVal)}   |   Negative Difference = ${fmt(negDiffVal)}   |   Sum = ${fmt(sumVal)}",
        ),
      );
    } catch (e) {
      return SumAndDifferenceResult.error(
        mode: 0,
        subMode: operationType,
        message: e is FormatException
            ? e.message
            : "Please enter two valid numbers, decimals, or mixed fractions.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: FIND UNKNOWN NUMBER(S) GIVEN THE SUM OR THE DIFFERENCE
  // Sub-Mode 0: Given the Sum (x + a = S) — Ex 2.1 #20, #21, #23
  // Sub-Mode 1: Given the Difference (Finds BOTH Possible Values!) — Ex 2.1 #17, #18, #22
  // ===========================================================================
  static SumAndDifferenceResult solveUnknownFromSumOrDifference({
    required int subMode, // 0: Given Sum (x + a = S), 1: Given Difference (Two Possible Values)
    required String knownNumberStr,
    required String targetSumOrDiffStr,
  }) {
    try {
      final ParsedNumber a =
      parseFlexibleNumber(knownNumberStr, fieldName: 'Known Number');
      final ParsedNumber target = parseFlexibleNumber(
        targetSumOrDiffStr,
        fieldName: subMode == 0 ? 'Given Sum' : 'Given Difference',
      );

      final bool useFractions =
          a.isFractionOrMixed || target.isFractionOrMixed;
      final List<String> workings = [];
      final List<SumAndDifferenceStep> steps = [];
      final Map<String, String> answers = {};

      if (subMode == 0) {
        // Sub-Mode 1A: The sum of a number x and 'a' is 'S' -> x + a = S (Ex 2.1 #20, #21, #23)
        final String eqSetup = a.value >= 0
            ? "x + ${a.displayLaTeX} = ${target.displayLaTeX}"
            : "x - ${fmt(a.value.abs())} = ${target.displayLaTeX}";
        final String opWord = a.value >= 0
            ? "Subtract ${a.displayLaTeX} from both sides"
            : "Add ${fmt(a.value.abs())} to both sides";

        final List<String> step1Lines = [
          "\\text{Let the unknown number be } x.",
          "\\text{Given that the sum of } x \\text{ and } ${a.displayLaTeX} \\text{ is } ${target.displayLaTeX}:",
          "\\mathbf{$eqSetup}",
        ];

        workings.add(
            "\\text{\\textbf{Step 1: Translate the Word Problem into an Algebraic Equation}}");
        workings.addAll(step1Lines);
        workings.add("");

        steps.add(SumAndDifferenceStep(
          title: "Step 1: Choose a Variable (x) and Form the Sum Equation",
          description:
          "• Let the unknown number be represented by the letter x.\n"
              "• 'The sum of a number and ${a.displayPlain} is ${target.displayPlain}' translates directly to adding x and ${a.displayPlain} and equating the result to ${target.displayPlain}.",
          mathLinesLaTeX: step1Lines,
        ));

        final List<String> step2Lines = [
          eqSetup,
          "\\text{$opWord to isolate } x:",
          "x = ${target.displayLaTeX} - ${wrapNegLaTeX(a)}",
        ];

        String finalAnsPlain = "";
        String finalAnsLaTeX = "";
        final double xVal = target.value - a.value;

        if (useFractions) {
          // Unabridged Fraction & Mixed-Number Arithmetic (Matches Ex 2.1 #20: x + 7 3/4 = -2 1/2)
          final int lcmDen = lcm(target.den, a.den);
          final int scaledS = target.num * (lcmDen ~/ target.den);
          final int scaledA = a.num * (lcmDen ~/ a.den);
          final int resNum = scaledS - scaledA;
          final Map<String, String> resMap = formatRational(resNum, lcmDen);

          if (target.isMixedInput || a.isMixedInput) {
            step2Lines.add(
                "\\text{Convert each mixed number into an improper fraction:}");
            if (target.isMixedInput) {
              final int wAbs = (target.num.abs() ~/ target.den);
              final int remAbs = target.num.abs() % target.den;
              final String sSign = target.num < 0 ? "-" : "";
              step2Lines.add(
                  "${target.displayLaTeX} = $sSign\\frac{($wAbs \\times ${target.den}) + $remAbs}{${target.den}} = ${target.improperLaTeX}");
            }
            if (a.isMixedInput) {
              final int wAbs = (a.num.abs() ~/ a.den);
              final int remAbs = a.num.abs() % a.den;
              final String aSign = a.num < 0 ? "-" : "";
              step2Lines.add(
                  "${a.displayLaTeX} = $aSign\\frac{($wAbs \\times ${a.den}) + $remAbs}{${a.den}} = ${a.improperLaTeX}");
            }
            step2Lines.add(
                "x = ${target.improperLaTeX} - ${a.value < 0 ? '\\left(${a.improperLaTeX}\\right)' : a.improperLaTeX}");
          }

          step2Lines.add(
              "\\text{Find the LCM of the denominators } (${target.den} \\text{ and } ${a.den}), \\text{ which is } \\mathbf{$lcmDen}:");
          step2Lines.add(
              "x = \\frac{$scaledS}{$lcmDen} - \\frac{$scaledA}{$lcmDen}");
          step2Lines.add(
              "x = \\frac{$scaledS - ${scaledA < 0 ? '($scaledA)' : '$scaledA'}}{$lcmDen} = \\frac{$resNum}{$lcmDen}");
          step2Lines.add(
              "\\therefore \\; \\mathbf{x = ${resMap['latex']}} \\quad \\left(\\text{or } \\mathbf{${fmt(xVal)}}\\right)");

          finalAnsPlain = "${resMap['plain']} (or ${fmt(xVal)})";
          finalAnsLaTeX = resMap['latex']!;
        } else {
          if (a.value < 0) {
            step2Lines.add("x = ${target.displayLaTeX} + ${fmt(a.value.abs())}");
          }
          step2Lines.add("\\therefore \\; \\mathbf{x = ${fmt(xVal)}}");
          finalAnsPlain = fmt(xVal);
          finalAnsLaTeX = fmt(xVal);
        }

        workings.add(
            "\\text{\\textbf{Step 2: Solve the Equation Step-by-Step for }} x");
        workings.addAll(step2Lines);
        workings.add("");

        steps.add(SumAndDifferenceStep(
          title: "Step 2: Isolate x and Calculate the Exact Value",
          description: useFractions
              ? "1. Subtract ${a.displayPlain} from both sides: x = ${target.displayPlain} − ${wrapNegPlain(a)}.\n"
              "2. Convert mixed fractions into improper fractions.\n"
              "3. Express both fractions over their Lowest Common Multiple (LCM) denominator (${lcm(target.den, a.den)}), combine the numerators, and convert back to a mixed fraction: x = $finalAnsPlain."
              : "1. Subtract ${a.displayPlain} from both sides of the equation: x = ${target.displayPlain} − ${wrapNegPlain(a)}.\n"
              "2. Evaluate the directed-number arithmetic: x = $finalAnsPlain.",
          mathLinesLaTeX: step2Lines,
        ));

        // Step 3: Verification Check
        final List<String> step3Lines = [
          "\\text{Check: } x + ${wrapNegLaTeX(a)} = $finalAnsLaTeX + ${wrapNegLaTeX(a)} = \\mathbf{${target.displayLaTeX}} \\quad (\\text{Verified!})",
        ];
        workings.add("\\text{\\textbf{Step 3: Verification Check}}");
        workings.addAll(step3Lines);

        steps.add(SumAndDifferenceStep(
          title: "Step 3: Check Your Answer in the Original Statement",
          description:
          "Add the unknown number ($finalAnsPlain) and the known number (${a.displayPlain}) to verify that their sum equals ${target.displayPlain}.",
          mathLinesLaTeX: step3Lines,
        ));

        answers["Equation"] = "x + ${wrapNegPlain(a)} = ${target.displayPlain}";
        answers["Required Number (x)"] = finalAnsPlain;

        return SumAndDifferenceResult(
          mode: 1,
          subMode: 0,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          canvasData: SumAndDifferenceCanvasData(
            visualType: 0,
            markers: [
              NumberLineMarker(
                value: target.value,
                topLabel: "Given Sum = ${target.displayPlain}",
                bottomValueLabel: target.displayPlain,
                isPrimaryHighlight: false,
              ),
              NumberLineMarker(
                value: xVal,
                topLabel: "Unknown x = $finalAnsPlain",
                bottomValueLabel: fmt(xVal),
                isPrimaryHighlight: true,
              ),
            ],
            arcs: [
              NumberLineArc(
                fromVal: target.value,
                toVal: xVal,
                label: "Subtract ${a.displayPlain}",
                isPositiveJump: xVal >= target.value,
              ),
            ],
            headerBadge:
            "Sum Problem:  x + ${wrapNegPlain(a)} = ${target.displayPlain}   ➔   x = $finalAnsPlain",
            subBadge:
            "To find the unknown addend x, subtract the known number (${a.displayPlain}) from the sum (${target.displayPlain})",
            bottomSummaryBanner: "Required Number: x = $finalAnsPlain",
          ),
        );
      } else {
        // Sub-Mode 1B: Given the Difference Between Two Numbers (Finds BOTH Possible Values! — Ex 2.1 #17, #18, #22)
        final double dAbs = target.value.abs();
        final double xCase1 = a.value + dAbs; // When x is the larger number
        final double xCase2 = a.value - dAbs; // When x is the smaller number
        final bool givenNegativeDiff = target.value < 0;

        final List<String> step1Lines = [
          "\\text{Let the unknown number be } x.",
          "\\text{Known number} = ${a.displayLaTeX}, \\qquad \\text{Given difference} = ${target.displayLaTeX}",
          if (givenNegativeDiff)
            "\\text{Note (Page 19): A negative difference } (${target.displayLaTeX}) \\text{ is obtained when the LARGER number is subtracted from the SMALLER number: } \\text{Smaller} - \\text{Larger} = ${target.displayLaTeX}"
          else
            "\\text{Because we are not told whether } x \\text{ is larger or smaller than } ${a.displayLaTeX}, \\text{ there are \\textbf{two possible cases}:}",
          if (givenNegativeDiff)
            "\\bullet \\text{ Possibility 1 (If } ${a.displayLaTeX} \\text{ is the smaller number): } ${a.displayLaTeX} - x = ${target.displayLaTeX}"
          else
            "\\bullet \\text{ Case 1 (If } x \\text{ is LARGER than } ${a.displayLaTeX}\\text{): } x - ${wrapNegLaTeX(a)} = ${fmt(dAbs)}",
          if (givenNegativeDiff)
            "\\bullet \\text{ Possibility 2 (If } x \\text{ is the smaller number): } x - ${wrapNegLaTeX(a)} = ${target.displayLaTeX}"
          else
            "\\bullet \\text{ Case 2 (If } x \\text{ is SMALLER than } ${a.displayLaTeX}\\text{): } ${a.displayLaTeX} - x = ${fmt(dAbs)}",
        ];

        workings.add(
            "\\text{\\textbf{Step 1: Why There Are Two Possible Values for }} x \\text{\\textbf{ (Ex 2.1 \\#17, \\#18, \\#22)}}");
        workings.addAll(step1Lines);
        workings.add("");

        steps.add(SumAndDifferenceStep(
          title:
          "Step 1: Set Up the Two Possible Cases (Is x Larger or Smaller than ${a.displayPlain}?)",
          description: givenNegativeDiff
              ? "• Teacher's Guide Rule (Page 19): When a larger number is subtracted from a smaller number, we get a negative difference (${target.displayPlain}).\n"
              "• Since we do not know whether ${a.displayPlain} is the smaller number or x is the smaller number, we form two equations:\n"
              "  1. ${a.displayPlain} − x = ${target.displayPlain} (if ${a.displayPlain} is smaller than x)\n"
              "  2. x − ${wrapNegPlain(a)} = ${target.displayPlain} (if x is smaller than ${a.displayPlain})."
              : "• In questions like Exercise 2.1 #17 and #18, we are told that the difference between ${a.displayPlain} and another number x is ${fmt(dAbs)}, without specifying which number is larger.\n"
              "• Therefore, there are TWO possible equations:\n"
              "  1. Case 1 (x is larger than ${a.displayPlain}): x − ${wrapNegPlain(a)} = ${fmt(dAbs)}\n"
              "  2. Case 2 (x is smaller than ${a.displayPlain}): ${a.displayPlain} − x = ${fmt(dAbs)}.",
          mathLinesLaTeX: step1Lines,
        ));

        // Step 2: Solve Case 1 (x is the Larger Number -> x = a + |d|)
        final List<String> step2Lines = givenNegativeDiff
            ? [
          "\\text{Possibility 1: Suppose } ${a.displayLaTeX} \\text{ is the smaller number:}",
          "${a.displayLaTeX} - x = ${target.displayLaTeX}",
          "\\text{Subtract } ${a.displayLaTeX} \\text{ from both sides:}",
          "-x = ${target.displayLaTeX} - ${wrapNegLaTeX(a)} = ${fmt(target.value - a.value)}",
          "\\text{Multiply both sides by } -1:",
          "\\mathbf{x = ${fmt(xCase1)}}",
        ]
            : [
          "\\text{Case 1: Suppose } x \\text{ is the LARGER number:}",
          "x - ${wrapNegLaTeX(a)} = ${fmt(dAbs)}",
          "\\text{Add } ${a.displayLaTeX} \\text{ to both sides:}",
          "x = ${a.displayLaTeX} + ${fmt(dAbs)}",
          "\\mathbf{x = ${fmt(xCase1)}}",
        ];

        workings.add(
            "\\text{\\textbf{Step 2: Solve for the First Possible Value (}}${fmt(xCase1)}\\text{\\textbf{)}}");
        workings.addAll(step2Lines);
        workings.add("");

        steps.add(SumAndDifferenceStep(
          title:
          "Step 2: Solve Case 1 — When x is Larger than ${a.displayPlain} (x = ${fmt(xCase1)})",
          description:
          "Add the positive difference (${fmt(dAbs)}) to ${a.displayPlain}:\n"
              "• x = ${a.displayPlain} + ${fmt(dAbs)} = ${fmt(xCase1)}.\n"
              "• Check: The difference between ${fmt(xCase1)} and ${a.displayPlain} is ${fmt(xCase1)} − ${wrapNegPlain(a)} = ${fmt(dAbs)} (and ${a.displayPlain} − ${fmt(xCase1)} = −${fmt(dAbs)}).",
          mathLinesLaTeX: step2Lines,
        ));

        // Step 3: Solve Case 2 (x is the Smaller Number -> x = a - |d|)
        final List<String> step3Lines = givenNegativeDiff
            ? [
          "\\text{Possibility 2: Suppose } x \\text{ is the smaller number:}",
          "x - ${wrapNegLaTeX(a)} = ${target.displayLaTeX}",
          "\\text{Add } ${a.displayLaTeX} \\text{ to both sides:}",
          "x = ${target.displayLaTeX} + ${wrapNegLaTeX(a)}",
          "\\mathbf{x = ${fmt(xCase2)}}",
        ]
            : [
          "\\text{Case 2: Suppose } x \\text{ is the SMALLER number:}",
          "${a.displayLaTeX} - x = ${fmt(dAbs)}",
          "\\text{Rearrange to isolate } x:",
          "x = ${a.displayLaTeX} - ${fmt(dAbs)}",
          "\\mathbf{x = ${fmt(xCase2)}}",
        ];

        workings.add(
            "\\text{\\textbf{Step 3: Solve for the Second Possible Value (}}${fmt(xCase2)}\\text{\\textbf{)}}");
        workings.addAll(step3Lines);
        workings.add("");

        final List<String> conclusionLines = [
          "\\therefore \\; \\text{The two possible values for the number are } \\mathbf{${fmt(xCase1)}} \\text{ or } \\mathbf{${fmt(xCase2)}}.",
        ];
        workings.addAll(conclusionLines);

        steps.add(SumAndDifferenceStep(
          title:
          "Step 3: Solve Case 2 — When x is Smaller than ${a.displayPlain} (x = ${fmt(xCase2)})",
          description:
          "Subtract the positive difference (${fmt(dAbs)}) from ${a.displayPlain}:\n"
              "• x = ${a.displayPlain} − ${fmt(dAbs)} = ${fmt(xCase2)}.\n"
              "• Check: ${fmt(xCase2)} − ${wrapNegPlain(a)} = −${fmt(dAbs)} (and ${a.displayPlain} − ${fmt(xCase2)} = +${fmt(dAbs)}).\n"
              "• Conclusion: The two possible values for the number are ${fmt(xCase1)} and ${fmt(xCase2)}!",
          mathLinesLaTeX: [...step3Lines, ...conclusionLines],
        ));

        answers["1st Possible Value (Larger)"] = "x = ${fmt(xCase1)}";
        answers["2nd Possible Value (Smaller)"] = "x = ${fmt(xCase2)}";
        answers["Both Possible Values"] = "${fmt(xCase1)} or ${fmt(xCase2)}";

        return SumAndDifferenceResult(
          mode: 1,
          subMode: 1,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          canvasData: SumAndDifferenceCanvasData(
            visualType: 0,
            markers: [
              NumberLineMarker(
                value: xCase2,
                topLabel: "Case 2: x = ${fmt(xCase2)}",
                bottomValueLabel: fmt(xCase2),
                isPrimaryHighlight: true,
              ),
              NumberLineMarker(
                value: a.value,
                topLabel: "Known = ${a.displayPlain}",
                bottomValueLabel: a.displayPlain,
                isPrimaryHighlight: false,
              ),
              NumberLineMarker(
                value: xCase1,
                topLabel: "Case 1: x = ${fmt(xCase1)}",
                bottomValueLabel: fmt(xCase1),
                isPrimaryHighlight: true,
              ),
            ],
            arcs: [
              NumberLineArc(
                fromVal: a.value,
                toVal: xCase1,
                label: "+${fmt(dAbs)}",
                isPositiveJump: true,
              ),
              NumberLineArc(
                fromVal: a.value,
                toVal: xCase2,
                label: "−${fmt(dAbs)}",
                isPositiveJump: false,
              ),
            ],
            headerBadge:
            "Two Possible Values:  x = ${fmt(xCase1)}   or   x = ${fmt(xCase2)}",
            subBadge:
            "Both ${fmt(xCase2)} and ${fmt(xCase1)} lie at a distance of ${fmt(dAbs)} units from ${a.displayPlain} on the number line!",
            bottomSummaryBanner:
            "Case 1 (Larger): x = ${fmt(xCase1)}   |   Case 2 (Smaller): x = ${fmt(xCase2)}",
          ),
        );
      }
    } catch (e) {
      return SumAndDifferenceResult.error(
        mode: 1,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid numbers or fractions.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: SUM OF CONSECUTIVE NUMBERS SOLVER
  // Covers Exercise 2.1 #15 (3 consecutive odd = 177), #16 (3 consecutive even = 258),
  // #24 (Three integers (x-1), x, (x+1) = 105) & #25 (4 consecutive negative numbers = -258)
  // ===========================================================================
  static SumAndDifferenceResult solveConsecutiveNumbersSum({
    required int countN, // 2, 3, 4, or 5
    required int consecutiveType,
    // 0: Standard Consecutive Integers: x, x+1, x+2, ... (Ex 2.1 #25)
    // 1: Centered Consecutive Integers: (x-1), x, (x+1) (Ex 2.1 #24)
    // 2: Consecutive Odd Numbers: x, x+2, x+4, ... (Ex 2.1 #15)
    // 3: Consecutive Even Numbers: x, x+2, x+4, ... (Ex 2.1 #16)
    required String totalSumStr,
  }) {
    try {
      final int n = countN.clamp(2, 6);
      final double? totalSum =
      double.tryParse(totalSumStr.trim().replaceAll('−', '-'));
      if (totalSum == null) {
        throw const FormatException(
            "Please enter a valid number for the total sum (e.g. 177, 258, 105, or -258).");
      }

      // Build the algebraic offsets for each term
      final List<int> offsets = [];
      String typeTitle = "";
      String step1RuleExplain = "";

      if (consecutiveType == 1 && n == 3) {
        offsets.addAll([-1, 0, 1]);
        typeTitle = "Three Consecutive Integers (x − 1), x, (x + 1)";
        step1RuleExplain =
        "• As given in Exercise 2.1 #24, the three consecutive integers are represented in terms of the middle integer x as (x − 1), x, and (x + 1).";
      } else if (consecutiveType == 2) {
        for (int i = 0; i < n; i++) {
          offsets.add(2 * i);
        }
        typeTitle = "$n Consecutive Odd Numbers";
        step1RuleExplain =
        "• Consecutive odd numbers (like 1, 3, 5, 7, …) always differ by 2 from one odd number to the next.\n"
            "• Therefore, if we let the first (smallest) odd number be x, the $n consecutive odd numbers are ${offsets.map((k) => k == 0 ? 'x' : 'x + $k').join(', ')}.";
      } else if (consecutiveType == 3) {
        for (int i = 0; i < n; i++) {
          offsets.add(2 * i);
        }
        typeTitle = "$n Consecutive Even Numbers";
        step1RuleExplain =
        "• Consecutive even numbers (like 2, 4, 6, 8, …) also differ by 2 from one even number to the next.\n"
            "• Therefore, if we let the first (smallest) even number be x, the $n consecutive even numbers are ${offsets.map((k) => k == 0 ? 'x' : 'x + $k').join(', ')}.";
      } else {
        for (int i = 0; i < n; i++) {
          offsets.add(i);
        }
        typeTitle = totalSum < 0
            ? "$n Consecutive Negative Integers"
            : "$n Consecutive Integers";
        step1RuleExplain =
        "• Consecutive whole numbers / integers (even when negative, like −66, −65, −64, −63 in Exercise 2.1 #25) increase by 1 each time.\n"
            "• Let the first (smallest) integer be x. Then the $n consecutive integers are ${offsets.map((k) => k == 0 ? 'x' : 'x + $k').join(', ')}.";
      }

      String formatTermLaTeX(int offset, {bool withBrackets = false}) {
        if (offset == 0) return 'x';
        final String inner = offset > 0 ? 'x + $offset' : 'x - ${offset.abs()}';
        return withBrackets ? '($inner)' : inner;
      }

      String formatTermPlain(int offset) {
        if (offset == 0) return 'x';
        return offset > 0 ? 'x + $offset' : 'x − ${offset.abs()}';
      }

      final int sumOffsets = offsets.fold(0, (a, b) => a + b);
      final double rhsAfterSubtract = totalSum - sumOffsets;
      final double xVal = rhsAfterSubtract / n;

      final List<double> foundNumbers =
      offsets.map((k) => xVal + k).toList();
      final List<String> foundNumbersStr =
      foundNumbers.map(fmt).toList();

      // Parity / Integer validity warning note if user enters an incompatible sum
      String validityNote = "";
      final bool isWholeX = (xVal - xVal.roundToDouble()).abs() < 1e-9;
      if (!isWholeX) {
        validityNote =
        "\n• Note: Because ${fmt(rhsAfterSubtract)} is not evenly divisible by $n, x = ${fmt(xVal)} is a fraction/decimal rather than a whole integer.";
      } else if (consecutiveType == 2 && xVal.round().abs() % 2 == 0) {
        validityNote =
        "\n• Note: With a sum of ${fmt(totalSum)}, solving gives even integers (${foundNumbersStr.join(', ')}). For $n consecutive odd numbers, the sum must leave an odd value for x (e.g. 177 gives 57, 59, 61).";
      } else if (consecutiveType == 3 && xVal.round().abs() % 2 != 0) {
        validityNote =
        "\n• Note: With a sum of ${fmt(totalSum)}, solving gives odd integers (${foundNumbersStr.join(', ')}). For $n consecutive even numbers, the sum must leave an even value for x (e.g. 258 gives 84, 86, 88).";
      }

      // Step 1: Represent Each Consecutive Number in Terms of x
      final List<String> step1Math = [
        for (int i = 0; i < n; i++)
          "\\text{${i + 1}${i == 0 ? 'st' : (i == 1 ? 'nd' : (i == 2 ? 'rd' : 'th'))} Number} = \\mathbf{${formatTermLaTeX(offsets[i])}}",
        "\\text{Given Sum} = \\mathbf{${fmt(totalSum)}}",
      ];

      // Step 2: Form the Sum Equation and Solve for x Without Skipping a Single Step
      final String sumTermsLaTeX = offsets
          .map((k) => formatTermLaTeX(k, withBrackets: k != 0))
          .join(' + ');
      final String collectXPart = List.filled(n, 'x').join(' + ');
      final List<int> nonZeroOffsets =
      offsets.where((k) => k != 0).toList();
      final String collectConstPart = nonZeroOffsets.isEmpty
          ? '0'
          : nonZeroOffsets
          .map((k) => k > 0 ? '+ $k' : '- ${k.abs()}')
          .join(' ')
          .replaceFirst(RegExp(r'^\+\s*'), '');

      final List<String> step2Math = [
        "$sumTermsLaTeX = ${fmt(totalSum)}",
        "\\text{Remove brackets and group like terms together:}",
        if (nonZeroOffsets.isNotEmpty)
          "($collectXPart) + ($collectConstPart) = ${fmt(totalSum)}",
        if (sumOffsets == 0)
          "${n}x = ${fmt(totalSum)}"
        else ...[
          "${n}x ${sumOffsets > 0 ? '+ $sumOffsets' : '- ${sumOffsets.abs()}'} = ${fmt(totalSum)}",
          "\\text{${sumOffsets > 0 ? 'Subtract $sumOffsets from' : 'Add ${sumOffsets.abs()} to'} both sides of the equation:}",
          "${n}x = ${fmt(totalSum)} ${sumOffsets > 0 ? '- $sumOffsets' : '+ ${sumOffsets.abs()}'}",
          "${n}x = ${fmt(rhsAfterSubtract)}",
        ],
        "\\text{Divide both sides by } $n:",
        "x = \\frac{${fmt(rhsAfterSubtract)}}{$n}",
        "\\mathbf{x = ${fmt(xVal)}}",
      ];

      // Step 3: Substitute x to Find Each Number & Verify Sum
      final List<String> step3Math = [
        for (int i = 0; i < n; i++)
          if (offsets[i] == 0)
            "\\bullet \\text{ ${i + 1}${i == 0 ? 'st' : (i == 1 ? 'nd' : (i == 2 ? 'rd' : 'th'))} Number } (x) = \\mathbf{${fmt(xVal)}}"
          else
            "\\bullet \\text{ ${i + 1}${i == 0 ? 'st' : (i == 1 ? 'nd' : (i == 2 ? 'rd' : 'th'))} Number } (${formatTermLaTeX(offsets[i])}) = ${fmt(xVal)} ${offsets[i] > 0 ? '+ ${offsets[i]}' : '- ${offsets[i].abs()}'} = \\mathbf{${fmt(foundNumbers[i])}}",
        "\\text{Check Sum: } ${foundNumbers.map((v) => v < 0 ? '(${fmt(v)})' : fmt(v)).join(' + ')} = \\mathbf{${fmt(totalSum)}} \\quad (\\text{Verified!})",
        "\\therefore \\; \\text{The numbers are } \\mathbf{${foundNumbersStr.join(', \\; ')}}.",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Represent the $typeTitle Algebraically}}",
        ...step1Math,
        "",
        "\\text{\\textbf{Step 2: Form the Sum Equation and Solve for }} x",
        ...step2Math,
        "",
        "\\text{\\textbf{Step 3: Substitute }} x = ${fmt(xVal)} \\text{\\textbf{ to Find All $n Numbers}}",
        ...step3Math,
      ];

      final List<SumAndDifferenceStep> steps = [
        SumAndDifferenceStep(
          title: "Step 1: Represent the $typeTitle in Terms of x",
          description: "$step1RuleExplain$validityNote",
          mathLinesLaTeX: step1Math,
        ),
        SumAndDifferenceStep(
          title: "Step 2: Add the Algebraic Terms and Solve for x",
          description:
          "1. Add the $n algebraic expressions and set their sum equal to ${fmt(totalSum)}.\n"
              "2. Collect like terms: adding the $n 'x' terms gives ${n}x, and adding the constants gives $sumOffsets.\n"
              "${sumOffsets != 0 ? '3. Subtract $sumOffsets from both sides: ${n}x = ${fmt(totalSum)} − $sumOffsets = ${fmt(rhsAfterSubtract)}.\n' : ''}"
              "4. Divide both sides by $n: x = ${fmt(rhsAfterSubtract)} ÷ $n = ${fmt(xVal)}.",
          mathLinesLaTeX: step2Math,
        ),
        SumAndDifferenceStep(
          title:
          "Step 3: Substitute x = ${fmt(xVal)} to List the $n Numbers & Check",
          description:
          "Substitute x = ${fmt(xVal)} into each expression (${offsets.map(formatTermPlain).join(', ')}) to find all $n numbers:\n"
              "• The required numbers are: ${foundNumbersStr.join(', ')}.\n"
              "• Check: ${foundNumbersStr.join(' + ')} = ${fmt(totalSum)} (Verified!).",
          mathLinesLaTeX: step3Math,
        ),
      ];

      final List<AlgebraicBarItem> barItems = [
        for (int i = 0; i < n; i++)
          AlgebraicBarItem(
            termLabel: "Term ${i + 1} (${formatTermPlain(offsets[i])})",
            baseBlockLabel: "x = ${fmt(xVal)}",
            baseVal: xVal,
            offsetConst: offsets[i],
            evaluatedText: "= ${fmt(foundNumbers[i])}",
          ),
      ];

      return SumAndDifferenceResult(
        mode: 2,
        subMode: consecutiveType,
        finalAnswers: {
          "Value of x": "x = ${fmt(xVal)}",
          "The $n Numbers": foundNumbersStr.join(', '),
          "Smallest Number": fmt(foundNumbers.first),
          "Largest Number": fmt(foundNumbers.last),
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SumAndDifferenceCanvasData(
          visualType: 1,
          bars: barItems,
          totalBraceLabel: "Sum = ${fmt(totalSum)}",
          headerBadge:
          "$typeTitle (Sum = ${fmt(totalSum)})   ➔   ${foundNumbersStr.join(', ')}",
          subBadge:
          "Equation: ${n}x ${sumOffsets == 0 ? '' : (sumOffsets > 0 ? '+ $sumOffsets ' : '− ${sumOffsets.abs()} ')}= ${fmt(totalSum)}   ➔   ${n}x = ${fmt(rhsAfterSubtract)}   ➔   x = ${fmt(xVal)}",
          bottomSummaryBanner:
          "The $n Numbers Are:  ${foundNumbersStr.join(', ')}   (Check Sum = ${fmt(totalSum)})",
        ),
      );
    } catch (e) {
      return SumAndDifferenceResult.error(
        mode: 2,
        subMode: consecutiveType,
        message: e is FormatException
            ? e.message
            : "Please enter a valid total sum.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: SIMULTANEOUS SUM & DIFFERENCE / COMBINED SUM & DIFFERENCE OF PAIRS
  // Sub-Mode 0: Given Sum (S) & Difference (D) of Two Numbers -> Find Both Numbers
  // Sub-Mode 1: Add the Sum of (A and B) to the Positive Difference Between (C and D) [Teacher's Guide p.22]
  // ===========================================================================
  static SumAndDifferenceResult solveSimultaneousOrCombined({
    required int subMode,
    required String input1Str,
    required String input2Str,
    required String input3Str,
    required String input4Str,
  }) {
    try {
      if (subMode == 0) {
        // Sub-Mode 3A: The sum of two numbers is S and their difference is D. Find the numbers.
        final ParsedNumber sNum =
        parseFlexibleNumber(input1Str, fieldName: 'Sum (S)');
        final ParsedNumber dNum =
        parseFlexibleNumber(input2Str, fieldName: 'Difference (D)');

        final double S = sNum.value;
        final double D = dNum.value.abs();
        final double twoX = S + D;
        final double xLarger = twoX / 2.0;
        final double ySmaller = S - xLarger;

        final List<String> step1Math = [
          "\\text{Let the larger number be } x \\text{ and the smaller number be } y.",
          "\\text{Equation (1) — Sum: } \\mathbf{x + y = ${fmt(S)}}",
          "\\text{Equation (2) — Difference: } \\mathbf{x - y = ${fmt(D)}}",
        ];

        final List<String> step2Math = [
          "\\text{Add Equation (1) and Equation (2) to eliminate } y:",
          "(x + y) + (x - y) = ${fmt(S)} + ${fmt(D)}",
          "2x = ${fmt(twoX)}",
          "x = \\frac{${fmt(twoX)}}{2}",
          "\\mathbf{x = ${fmt(xLarger)}} \\quad (\\text{Larger Number})",
        ];

        final List<String> step3Math = [
          "\\text{Substitute } x = ${fmt(xLarger)} \\text{ into Equation (1) } (x + y = ${fmt(S)}):",
          "${fmt(xLarger)} + y = ${fmt(S)}",
          "y = ${fmt(S)} - ${fmt(xLarger)}",
          "\\mathbf{y = ${fmt(ySmaller)}} \\quad (\\text{Smaller Number})",
          "\\text{Check: Sum} = ${fmt(xLarger)} + ${fmt(ySmaller)} = ${fmt(S)}, \\quad \\text{Difference} = ${fmt(xLarger)} - ${fmt(ySmaller)} = ${fmt(D)}",
        ];

        final List<String> workings = [
          "\\text{\\textbf{Step 1: Form Two Equations for the Sum and Difference}}",
          ...step1Math,
          "",
          "\\text{\\textbf{Step 2: Add Both Equations to Find the Larger Number (}}x\\text{\\textbf{)}}",
          ...step2Math,
          "",
          "\\text{\\textbf{Step 3: Substitute }} x = ${fmt(xLarger)} \\text{\\textbf{ to Find the Smaller Number (}}y\\text{\\textbf{)}}",
          ...step3Math,
        ];

        final List<SumAndDifferenceStep> steps = [
          SumAndDifferenceStep(
            title: "Step 1: Set Up the Sum Equation and Difference Equation",
            description:
            "• Let the larger number be x and the smaller number be y.\n"
                "• Their sum is ${fmt(S)} → x + y = ${fmt(S)}.\n"
                "• Their difference is ${fmt(D)} → x − y = ${fmt(D)}.",
            mathLinesLaTeX: step1Math,
          ),
          SumAndDifferenceStep(
            title: "Step 2: Add the Two Equations to Find the Larger Number (x)",
            description:
            "• Adding (x + y) and (x − y) cancels out +y and −y, leaving 2x:\n"
                "• 2x = ${fmt(S)} + ${fmt(D)} = ${fmt(twoX)}.\n"
                "• Divide both sides by 2: x = ${fmt(twoX)} ÷ 2 = ${fmt(xLarger)}.",
            mathLinesLaTeX: step2Math,
          ),
          SumAndDifferenceStep(
            title:
            "Step 3: Substitute x = ${fmt(xLarger)} to Find the Smaller Number (y)",
            description:
            "• Substitute x = ${fmt(xLarger)} into x + y = ${fmt(S)}:\n"
                "• y = ${fmt(S)} − ${fmt(xLarger)} = ${fmt(ySmaller)}.\n"
                "• Verification: ${fmt(xLarger)} + ${fmt(ySmaller)} = ${fmt(S)} and ${fmt(xLarger)} − ${fmt(ySmaller)} = ${fmt(D)}.",
            mathLinesLaTeX: step3Math,
          ),
        ];

        return SumAndDifferenceResult(
          mode: 3,
          subMode: 0,
          finalAnswers: {
            "Larger Number (x)": fmt(xLarger),
            "Smaller Number (y)": fmt(ySmaller),
            "Check Sum (x + y)": "${fmt(xLarger)} + ${fmt(ySmaller)} = ${fmt(S)}",
            "Check Diff (x − y)": "${fmt(xLarger)} − ${fmt(ySmaller)} = ${fmt(D)}",
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: SumAndDifferenceCanvasData(
            visualType: 1,
            bars: [
              AlgebraicBarItem(
                termLabel: "Larger (x = y + ${fmt(D)})",
                baseBlockLabel: "y = ${fmt(ySmaller)}",
                baseVal: ySmaller,
                offsetConst: D.round(),
                evaluatedText: "= ${fmt(xLarger)}",
              ),
              AlgebraicBarItem(
                termLabel: "Smaller (y)",
                baseBlockLabel: "y = ${fmt(ySmaller)}",
                baseVal: ySmaller,
                offsetConst: 0,
                evaluatedText: "= ${fmt(ySmaller)}",
              ),
            ],
            totalBraceLabel: "Sum = ${fmt(S)}",
            headerBadge:
            "Sum = ${fmt(S)}, Difference = ${fmt(D)}   ➔   Numbers are ${fmt(xLarger)} and ${fmt(ySmaller)}",
            subBadge:
            "Larger x = (${fmt(S)} + ${fmt(D)}) ÷ 2 = ${fmt(xLarger)}   |   Smaller y = (${fmt(S)} − ${fmt(D)}) ÷ 2 = ${fmt(ySmaller)}",
            bottomSummaryBanner:
            "The Two Numbers Are ${fmt(xLarger)} and ${fmt(ySmaller)}",
          ),
        );
      } else {
        // Sub-Mode 3B: Combined Sum of (A and B) & Positive Difference Between (C and D) [Teacher's Guide p.22]
        final ParsedNumber a =
        parseFlexibleNumber(input1Str, fieldName: 'First Number (A)');
        final ParsedNumber b =
        parseFlexibleNumber(input2Str, fieldName: 'Second Number (B)');
        final ParsedNumber c =
        parseFlexibleNumber(input3Str, fieldName: 'Third Number (C)');
        final ParsedNumber d =
        parseFlexibleNumber(input4Str, fieldName: 'Fourth Number (D)');

        final double sumAB = a.value + b.value;
        final ParsedNumber largerCD = c.value >= d.value ? c : d;
        final ParsedNumber smallerCD = c.value >= d.value ? d : c;
        final double posDiffCD = largerCD.value - smallerCD.value;
        final double combinedAdd = sumAB + posDiffCD;
        final double combinedSub = sumAB - posDiffCD;

        final List<String> step1Math = [
          "\\text{Sum of } ${a.displayLaTeX} \\text{ and } ${b.displayLaTeX} = ${a.displayLaTeX} + ${wrapNegLaTeX(b)} = \\mathbf{${fmt(sumAB)}}",
        ];
        final List<String> step2Math = [
          "\\text{Compare } ${c.displayLaTeX} \\text{ and } ${d.displayLaTeX}: \\quad ${largerCD.displayLaTeX} > ${smallerCD.displayLaTeX}",
          "\\text{Positive Difference} = ${largerCD.displayLaTeX} - ${wrapNegLaTeX(smallerCD)} = \\mathbf{${fmt(posDiffCD)}}",
        ];
        final List<String> step3Math = [
          "\\bullet \\text{ Sum of (A and B) + Positive Difference of (C and D)} = ${fmt(sumAB)} + ${fmt(posDiffCD)} = \\mathbf{${fmt(combinedAdd)}}",
          "\\bullet \\text{ Sum of (A and B) - Positive Difference of (C and D)} = ${fmt(sumAB)} - ${fmt(posDiffCD)} = \\mathbf{${fmt(combinedSub)}}",
        ];

        final List<String> workings = [
          "\\text{\\textbf{Step 1: Find the Sum of the First Pair (A and B)}}",
          ...step1Math,
          "",
          "\\text{\\textbf{Step 2: Find the Positive Difference of the Second Pair (C and D)}}",
          ...step2Math,
          "",
          "\\text{\\textbf{Step 3: Combine the Sum and the Difference}}",
          ...step3Math,
        ];

        final List<SumAndDifferenceStep> steps = [
          SumAndDifferenceStep(
            title:
            "Step 1: Find the Sum of ${a.displayPlain} and ${b.displayPlain}",
            description:
            "Add the first pair of numbers together: ${a.displayPlain} + ${wrapNegPlain(b)} = ${fmt(sumAB)}.",
            mathLinesLaTeX: step1Math,
          ),
          SumAndDifferenceStep(
            title:
            "Step 2: Find the Positive Difference Between ${c.displayPlain} and ${d.displayPlain}",
            description:
            "Subtract the smaller number (${smallerCD.displayPlain}) from the larger number (${largerCD.displayPlain}): ${largerCD.displayPlain} − ${wrapNegPlain(smallerCD)} = ${fmt(posDiffCD)}.",
            mathLinesLaTeX: step2Math,
          ),
          SumAndDifferenceStep(
            title: "Step 3: Combine Both Results (Add or Subtract)",
            description:
            "• Adding the sum (${fmt(sumAB)}) and the positive difference (${fmt(posDiffCD)}) gives: ${fmt(sumAB)} + ${fmt(posDiffCD)} = ${fmt(combinedAdd)}.\n"
                "• Subtracting the positive difference (${fmt(posDiffCD)}) from the sum (${fmt(sumAB)}) gives: ${fmt(sumAB)} − ${fmt(posDiffCD)} = ${fmt(combinedSub)}.",
            mathLinesLaTeX: step3Math,
          ),
        ];

        return SumAndDifferenceResult(
          mode: 3,
          subMode: 1,
          finalAnswers: {
            "Sum of A & B": fmt(sumAB),
            "Pos. Diff of C & D": fmt(posDiffCD),
            "Sum + Diff": fmt(combinedAdd),
            "Sum − Diff": fmt(combinedSub),
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: SumAndDifferenceCanvasData(
            visualType: 0,
            markers: [
              NumberLineMarker(
                value: sumAB,
                topLabel: "Sum(A,B) = ${fmt(sumAB)}",
                bottomValueLabel: fmt(sumAB),
                isPrimaryHighlight: false,
              ),
              NumberLineMarker(
                value: combinedAdd,
                topLabel: "Sum + Diff = ${fmt(combinedAdd)}",
                bottomValueLabel: fmt(combinedAdd),
                isPrimaryHighlight: true,
              ),
            ],
            arcs: [
              NumberLineArc(
                fromVal: sumAB,
                toVal: combinedAdd,
                label: "+ Diff (${fmt(posDiffCD)})",
                isPositiveJump: true,
              ),
            ],
            headerBadge:
            "Combined Pairs:  Sum(${a.displayPlain}, ${b.displayPlain}) = ${fmt(sumAB)}  |  Diff(${c.displayPlain}, ${d.displayPlain}) = ${fmt(posDiffCD)}",
            subBadge:
            "Sum + Diff = ${fmt(combinedAdd)}   |   Sum − Diff = ${fmt(combinedSub)}",
            bottomSummaryBanner:
            "Sum + Difference = ${fmt(combinedAdd)}   |   Sum − Difference = ${fmt(combinedSub)}",
          ),
        );
      }
    } catch (e) {
      return SumAndDifferenceResult.error(
        mode: 3,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid numbers in all fields.",
      );
    }
  }
}