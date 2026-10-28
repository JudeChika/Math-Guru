import 'dart:math' as math;
import 'fraction_word_problems_models.dart';

class FractionWordProblemsLogic {
  // ===========================================================================
  // 16 TEXTBOOK & BECE PRESETS (Pages 25–28: Examples 8–12 & Exercise 2.4)
  // ===========================================================================
  static const List<FractionWordProblemPreset> textbookPresets = [
    FractionWordProblemPreset(
      chipLabel: "Ex 2.4 #1: 4 subtracted from ¾ of a number gives 11",
      mode: 0,
      subMode: 0, // (p/q)x + b = c
      input1: '3/4',
      input2: '-4',
      input3: '11',
    ),
    FractionWordProblemPreset(
      chipLabel: "Ex 2.4 #2: 7 added to ⅔ of a number gives 19",
      mode: 0,
      subMode: 0,
      input1: '2/3',
      input2: '7',
      input3: '19',
    ),
    FractionWordProblemPreset(
      chipLabel: "Ex 2.4 #3: Sum of ½ of a number and ⅓ of it is 15",
      mode: 0,
      subMode: 1, // (p1/q1)x + (p2/q2)x = c
      input1: '1/2',
      input2: '1/3',
      input3: '15',
    ),
    FractionWordProblemPreset(
      chipLabel: "Ex 2.4 #4: Difference between ¾ of x and ⅖ of x is 14",
      mode: 0,
      subMode: 2, // (p1/q1)x - (p2/q2)x = c
      input1: '3/4',
      input2: '2/5',
      input3: '14',
    ),
    FractionWordProblemPreset(
      chipLabel: "Ex 2.4 #5: ⅔ of a number minus 3 equals ½ of it plus 2",
      mode: 0,
      subMode: 3, // (p1/q1)x + b = (p2/q2)x + d
      input1: '2/3',
      input2: '-3',
      input3: '1/2',
      input4: '2',
    ),
    FractionWordProblemPreset(
      chipLabel: "Ex 2.4 #6: Add 5 to a number and divide the sum by 4 gives 7",
      mode: 1,
      subMode: 0, // (a*x + b) / d = c
      input1: '1',
      input2: '5',
      input3: '4',
      input4: '7',
    ),
    FractionWordProblemPreset(
      chipLabel: "Ex 2.4 #7: One-third of (2x − 4) is equal to 6",
      mode: 1,
      subMode: 0,
      input1: '2',
      input2: '-4',
      input3: '3',
      input4: '6',
    ),
    FractionWordProblemPreset(
      chipLabel: "Ex 2.4 #8: One-quarter of (x + 7) equals one-third of (x + 3)",
      mode: 1,
      subMode: 1, // (x + b1)/d1 = (x + b2)/d2
      input1: '7',
      input2: '4',
      input3: '3',
      input4: '3',
    ),
    FractionWordProblemPreset(
      chipLabel: "Ex 2.4 #9: Sum of (x + 2)/3 and (x − 1)/4 is 5",
      mode: 1,
      subMode: 2, // (x + b1)/d1 + (x + b2)/d2 = c
      input1: '2',
      input2: '3',
      input3: '-1',
      input4: '4',
    ),
    FractionWordProblemPreset(
      chipLabel: "Ex 2.4 #10: When 24 is divided by x, the result is 1 ½",
      mode: 2,
      subMode: 0, // a / (x + b) = c
      input1: '24',
      input2: '0',
      input3: '1 1/2',
    ),
    FractionWordProblemPreset(
      chipLabel: "Ex 2.4 #11: 15 divided by (x + 2) gives 3/5",
      mode: 2,
      subMode: 0,
      input1: '15',
      input2: '2',
      input3: '3/5',
    ),
    FractionWordProblemPreset(
      chipLabel: "Ex 2.4 #12: Denom is 5 more than num; +2 to both gives ½",
      mode: 2,
      subMode: 1, // x / (x + diff) -> (x + change) / (x + diff + change) = p/q
      input1: '5',
      input2: '2',
      input3: '1/2',
    ),
    FractionWordProblemPreset(
      chipLabel: "Ex 2.4 #13: Denom is 3 more than num; −1 from both gives ½",
      mode: 2,
      subMode: 1,
      input1: '3',
      input2: '-1',
      input3: '1/2',
    ),
    FractionWordProblemPreset(
      chipLabel: "Ex 2.4 #14: Spent ¼ on books & ⅓ on food; ₦500 left",
      mode: 3,
      subMode: 0, // Direct shares from original whole: (p1/q1)x + (p2/q2)x + R = x
      input1: '1/4',
      input2: '1/3',
      input3: '500',
    ),
    FractionWordProblemPreset(
      chipLabel: "Ex 2.4 #15: Spent ⅓ on rent & ⅖ OF REMAINDER on food; 18000 left",
      mode: 3,
      subMode: 1, // 2nd share is OF THE REMAINDER
      input1: '1/3',
      input2: '2/5',
      input3: '18000',
    ),
    FractionWordProblemPreset(
      chipLabel: "Ex 2.4 #16: Read ⅖ of a book Day 1, ½ of remainder Day 2; 45 pages left",
      mode: 3,
      subMode: 1,
      input1: '2/5',
      input2: '1/2',
      input3: '45',
    ),
  ];

  // ===========================================================================
  // UNIVERSAL RATIONAL & FRACTION PARSING / FORMATTING ENGINE
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
    return (a.abs() * b.abs()) ~/ gcd(a, b);
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

  static Map<String, String> formatRational(int num, int den) {
    if (den == 0 || num == 0) {
      return {
        'plain': '0',
        'latex': '0',
        'improperLaTeX': '0',
        'improperPlain': '0',
      };
    }

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
        'improperPlain': '$sign$n',
      };
    }

    final String impTex = '$sign\\frac{$n}{$d}';
    final String impPlain = '$sign$n/$d';
    if (n > d) {
      final int w = n ~/ d;
      final int rem = n % d;
      return {
        'plain': '$sign$w $rem/$d',
        'latex': '$sign$w\\frac{$rem}{$d}',
        'improperLaTeX': impTex,
        'improperPlain': impPlain,
      };
    } else {
      return {
        'plain': impPlain,
        'latex': impTex,
        'improperLaTeX': impTex,
        'improperPlain': impPlain,
      };
    }
  }

  static ParsedRational parseRational(
      String raw, {
        String fieldName = 'number or fraction',
      }) {
    String s = raw
        .trim()
        .replaceAll('−', '-')
        .replaceAll('½', ' 1/2')
        .replaceAll('¼', ' 1/4')
        .replaceAll('¾', ' 3/4')
        .replaceAll('⅓', ' 1/3')
        .replaceAll('⅔', ' 2/3')
        .replaceAll('⅕', ' 1/5')
        .replaceAll('⅖', ' 2/5')
        .replaceAll('⅗', ' 3/5')
        .replaceAll('⅘', ' 4/5')
        .replaceAll(',', '')
        .replaceAll('₦', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (s.isEmpty) {
      throw FormatException(
        "Please enter a valid $fieldName (e.g. 3/4, 2/3, 1 1/2, or 15).",
      );
    }

    if (s.contains('/')) {
      final List<String> parts = s.split(' ');
      if (parts.length == 2) {
        final bool isNeg = parts[0].startsWith('-');
        final int wholeAbs =
        int.parse(parts[0].replaceAll('-', '').replaceAll('+', ''));
        final List<String> fParts = parts[1].split('/');
        final int fNum = int.parse(fParts[0]);
        final int fDen = int.parse(fParts[1]);
        if (fDen <= 0) {
          throw const FormatException(
              "Fraction denominator must be greater than zero.");
        }
        final int impAbs = wholeAbs * fDen + fNum;
        final int signedNum = isNeg ? -impAbs : impAbs;
        final int g = gcd(signedNum, fDen);
        final int redN = signedNum ~/ g;
        final int redD = fDen ~/ g;
        final String signStr = isNeg ? '-' : '';

        return ParsedRational(
          rawInput: raw.trim(),
          value: signedNum / fDen,
          num: redN,
          den: redD,
          isFractionOrMixed: true,
          isMixedInput: true,
          displayPlain: '$signStr$wholeAbs $fNum/$fDen',
          displayLaTeX: '$signStr$wholeAbs\\frac{$fNum}{$fDen}',
          improperLaTeX: '$signStr\\frac{${redN.abs()}}{$redD}',
        );
      } else if (parts.length == 1) {
        final List<String> fParts = parts[0].split('/');
        final int fNum = int.parse(fParts[0]);
        final int fDen = int.parse(fParts[1]);
        if (fDen == 0) {
          throw const FormatException("Fraction denominator cannot be zero.");
        }
        final int signedN = fDen < 0 ? -fNum : fNum;
        final int posD = fDen.abs();
        final int g = gcd(signedN, posD);
        final int redN = signedN ~/ g;
        final int redD = posD ~/ g;
        final String signStr = redN < 0 ? '-' : '';

        return ParsedRational(
          rawInput: raw.trim(),
          value: signedN / posD,
          num: redN,
          den: redD,
          isFractionOrMixed: true,
          isMixedInput: false,
          displayPlain: '$signStr${redN.abs()}/$redD',
          displayLaTeX: '$signStr\\frac{${redN.abs()}}{$redD}',
          improperLaTeX: '$signStr\\frac{${redN.abs()}}{$redD}',
        );
      } else {
        throw FormatException(
            "Invalid fraction format '$raw'. Try '3/4' or '1 1/2'.");
      }
    }

    final String noSpace = s.replaceAll(' ', '');
    final double? val = double.tryParse(noSpace);
    if (val == null) {
      throw FormatException("Could not read '$raw' as a valid number.");
    }

    int decPlaces = 0;
    if (noSpace.contains('.')) {
      decPlaces = noSpace.split('.')[1].length.clamp(0, 6);
    }
    final int scaleDen = math.pow(10, decPlaces).round();
    final int scaledNum = (val * scaleDen).round();
    final int g = gcd(scaledNum, scaleDen);
    final int redNum = scaledNum ~/ g;
    final int redDen = scaleDen ~/ g;
    final String cleanStr = fmt(val);

    return ParsedRational(
      rawInput: raw.trim(),
      value: val,
      num: redNum,
      den: redDen,
      isFractionOrMixed: redDen > 1,
      isMixedInput: false,
      displayPlain: cleanStr,
      displayLaTeX: cleanStr,
      improperLaTeX: redDen == 1
          ? cleanStr
          : '${redNum < 0 ? '-' : ''}\\frac{${redNum.abs()}}{$redDen}',
    );
  }

  static String formatFracCoeffXLaTeX(ParsedRational f) {
    if (f.den == 1) {
      if (f.num == 1) return "x";
      if (f.num == -1) return "-x";
      return "${f.num}x";
    }
    final String sign = f.num < 0 ? "-" : "";
    return "$sign\\frac{${f.num.abs()}}{${f.den}}x";
  }

  static String formatFracCoeffXPlain(ParsedRational f) {
    if (f.den == 1) {
      if (f.num == 1) return "x";
      if (f.num == -1) return "-x";
      return "${f.num}x";
    }
    final String sign = f.num < 0 ? "−" : "";
    return "$sign(${f.num.abs()}/${f.den})x";
  }

  // ===========================================================================
  // MODE 0: FRACTIONS OF AN UNKNOWN NUMBER (x)
  // Sub-Modes:
  // 0: Single Fraction of x Plus/Minus a Constant: (p/q)x + b = c
  // 1: Sum of Two Fractions of x: (p1/q1)x + (p2/q2)x = c
  // 2: Difference Between Two Fractions of x: (p1/q1)x - (p2/q2)x = c
  // 3: Two-Sided Fractional Equation: (p1/q1)x + b = (p2/q2)x + d
  // ===========================================================================
  static FractionWordProblemResult solveFractionsOfUnknownNumber({
    required int subMode,
    required String input1Str,
    required String input2Str,
    required String input3Str,
    required String input4Str,
  }) {
    try {
      final List<String> workings = [];
      final List<FractionWordProblemStep> steps = [];

      if (subMode == 0) {
        // Sub-Mode 0: (p/q)x + b = c  (e.g., 4 subtracted from 3/4 of x gives 11 -> (3/4)x - 4 = 11)
        final ParsedRational f =
        parseRational(input1Str, fieldName: 'Fraction of x (p/q)');
        final ParsedRational b = parseRational(
          input2Str,
          fieldName: 'Added/Subtracted Constant (b)',
        );
        final ParsedRational c =
        parseRational(input3Str, fieldName: 'Given Result (c)');

        if (f.num == 0) {
          throw const FormatException("The fraction of x cannot be zero.");
        }

        final int lcmAll = lcm(f.den, lcm(b.den, c.den));
        final int coeffAfterLCM = f.num * (lcmAll ~/ f.den);
        final int constBAfterLCM = b.num * (lcmAll ~/ b.den);
        final int rhsCAfterLCM = c.num * (lcmAll ~/ c.den);
        final int netRhsInt = rhsCAfterLCM - constBAfterLCM;

        final Map<String, String> xFmt =
        formatRational(netRhsInt, coeffAfterLCM);
        final double exactX = netRhsInt / coeffAfterLCM;

        final String fxLaTeX = formatFracCoeffXLaTeX(f);
        final String fxPlain = formatFracCoeffXPlain(f);
        final String bTermLaTeX = b.value >= 0
            ? "+ ${b.improperLaTeX}"
            : "- ${b.improperLaTeX.replaceFirst('-', '')}";
        final String bTermPlain = b.value >= 0
            ? "+ ${b.displayPlain}"
            : "− ${b.displayPlain.replaceFirst('-', '')}";

        final String eqLaTeX =
        b.num == 0 ? "$fxLaTeX = ${c.improperLaTeX}" : "$fxLaTeX $bTermLaTeX = ${c.improperLaTeX}";
        final String eqPlain =
        b.num == 0 ? "$fxPlain = ${c.displayPlain}" : "$fxPlain $bTermPlain = ${c.displayPlain}";

        // STEP 1: Form the Fractional Equation
        final List<String> step1Lines = [
          "\\text{Let the unknown number be } x.",
          "\\text{'${f.displayLaTeX} of the number' means } ${f.improperLaTeX} \\times x = $fxLaTeX.",
          "\\text{Form the equation:}",
          "\\mathbf{$eqLaTeX}",
        ];

        // STEP 2: Clear Fractions Using the LCM of Denominators
        final String clearedBPart = constBAfterLCM == 0
            ? ""
            : (constBAfterLCM > 0
            ? "+ $constBAfterLCM"
            : "- ${constBAfterLCM.abs()}");
        final List<String> step2Lines = [
          "\\text{Multiply every term on both sides by the LCM of the denominators } (\\text{LCM} = \\mathbf{$lcmAll}) \\text{ to clear fractions:}",
          if (b.num != 0)
            "$lcmAll \\times \\left($fxLaTeX\\right) ${b.value >= 0 ? '+' : '-'} $lcmAll \\times \\left(${b.improperLaTeX.replaceFirst('-', '')}\\right) = $lcmAll \\times \\left(${c.improperLaTeX}\\right)"
          else
            "$lcmAll \\times \\left($fxLaTeX\\right) = $lcmAll \\times \\left(${c.improperLaTeX}\\right)",
          "${coeffAfterLCM == 1 ? 'x' : '${coeffAfterLCM}x'} $clearedBPart = $rhsCAfterLCM",
          if (constBAfterLCM != 0) ...[
            "\\text{${constBAfterLCM > 0 ? 'Subtract $constBAfterLCM from' : 'Add ${constBAfterLCM.abs()} to'} both sides:}",
            "${coeffAfterLCM == 1 ? 'x' : '${coeffAfterLCM}x'} = $rhsCAfterLCM ${constBAfterLCM > 0 ? '- $constBAfterLCM' : '+ ${constBAfterLCM.abs()}'}",
            "${coeffAfterLCM == 1 ? 'x' : '${coeffAfterLCM}x'} = $netRhsInt",
          ],
          if (coeffAfterLCM != 1) ...[
            "\\text{Divide both sides by } $coeffAfterLCM:",
            "x = \\frac{$netRhsInt}{$coeffAfterLCM}",
          ],
          "\\therefore \\; \\mathbf{x = ${xFmt['latex']}}"
              "${xFmt['plain'] != fmt(exactX) ? ' \\quad \\left(\\text{or } \\mathbf{${fmt(exactX)}}\\right)' : ''}",
        ];

        // STEP 3: Verification Check
        final List<String> step3Lines = [
          "\\text{Check in } $eqLaTeX:",
          "\\text{Substitute } x = ${xFmt['latex']}: \\quad ${f.improperLaTeX} \\times \\left(${xFmt['improperLaTeX']}\\right) $bTermLaTeX = ${fmt(f.value * exactX)} $bTermLaTeX = \\mathbf{${c.displayLaTeX}} \\quad (\\text{Verified!})",
        ];

        workings.add(
            "\\text{\\textbf{Step 1: Translate the Word Problem into a Fractional Equation}}");
        workings.addAll(step1Lines);
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 2: Multiply Every Term by the LCM ($lcmAll) to Clear Fractions}}");
        workings.addAll(step2Lines);
        workings.add("");
        workings.add("\\text{\\textbf{Step 3: Verification Check}}");
        workings.addAll(step3Lines);

        steps.add(FractionWordProblemStep(
          title: "Step 1: Represent the Unknown as x and Form the Equation",
          description:
          "• Let the required number be x.\n"
              "• '${f.displayPlain} of the number' is written as $fxPlain.\n"
              "• Combining with ${b.displayPlain} and equating to ${c.displayPlain} gives: $eqPlain.",
          mathLinesLaTeX: step1Lines,
        ));

        steps.add(FractionWordProblemStep(
          title:
          "Step 2: Multiply Every Term by the LCM ($lcmAll) to Clear Denominators",
          description:
          "1. Find the Lowest Common Multiple (LCM) of all denominators, which is $lcmAll.\n"
              "2. Multiply EVERY term on both sides of the equation by $lcmAll to eliminate all fractions: ${coeffAfterLCM}x $clearedBPart = $rhsCAfterLCM.\n"
              "3. Isolate x to find x = ${xFmt['plain']}.",
          mathLinesLaTeX: [...step2Lines, ...step3Lines],
        ));

        return FractionWordProblemResult(
          mode: 0,
          subMode: 0,
          finalAnswers: {
            "Fractional Equation": eqPlain,
            "LCM of Denominators": "$lcmAll",
            "Required Number (x)": xFmt['plain']!,
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: FractionWordProblemsCanvasData(
            visualType: 0,
            topFractionalEqText: "Fractional Equation:   $eqPlain",
            lcmBridgeBadgeText:
            "Multiply Every Term on Both Sides by LCM = $lcmAll",
            clearedIntegerEqText:
            "Cleared Equation:   ${coeffAfterLCM}x $clearedBPart = $rhsCAfterLCM   ➔   ${coeffAfterLCM}x = $netRhsInt",
            finalSolutionBannerText: "Solution:   x = ${xFmt['plain']}",
            headerBadge:
            "Single Fraction of x:   $eqPlain   ➔   x = ${xFmt['plain']}",
            subBadge:
            "Clear denominator(s) using LCM = $lcmAll   ➔   ${coeffAfterLCM}x = $netRhsInt   ➔   x = ${xFmt['plain']}",
            bottomSummaryBanner: "Required Number:  x = ${xFmt['plain']}",
          ),
        );
      } else if (subMode == 1 || subMode == 2) {
        // Sub-Mode 1: Sum of Two Fractions of x: (p1/q1)x + (p2/q2)x = c
        // Sub-Mode 2: Difference Between Two Fractions of x: (p1/q1)x - (p2/q2)x = c
        final bool isSum = subMode == 1;
        final ParsedRational f1 =
        parseRational(input1Str, fieldName: 'First Fraction (p₁/q₁)');
        final ParsedRational f2 =
        parseRational(input2Str, fieldName: 'Second Fraction (p₂/q₂)');
        final ParsedRational c =
        parseRational(input3Str, fieldName: 'Given Result (c)');

        final int lcmAll = lcm(f1.den, lcm(f2.den, c.den));
        final int term1Coeff = f1.num * (lcmAll ~/ f1.den);
        final int term2Coeff = f2.num * (lcmAll ~/ f2.den);
        final int netXCoeff =
        isSum ? (term1Coeff + term2Coeff) : (term1Coeff - term2Coeff);
        final int rhsAfterLCM = c.num * (lcmAll ~/ c.den);

        if (netXCoeff == 0) {
          throw const FormatException(
              "The two fractional terms of x cancel each other out to 0.");
        }

        final Map<String, String> xFmt =
        formatRational(rhsAfterLCM, netXCoeff);
        final double exactX = rhsAfterLCM / netXCoeff;
        final String opSym = isSum ? "+" : "-";
        final String eqLaTeX =
            "${formatFracCoeffXLaTeX(f1)} $opSym ${formatFracCoeffXLaTeX(f2)} = ${c.improperLaTeX}";
        final String eqPlain =
            "${formatFracCoeffXPlain(f1)} $opSym ${formatFracCoeffXPlain(f2)} = ${c.displayPlain}";

        final List<String> step1Lines = [
          "\\text{Let the unknown number be } x.",
          "\\bullet \\text{ First fractional part} = ${formatFracCoeffXLaTeX(f1)}",
          "\\bullet \\text{ Second fractional part} = ${formatFracCoeffXLaTeX(f2)}",
          "\\text{Their ${isSum ? 'sum' : 'difference'} is } ${c.displayLaTeX}:",
          "\\mathbf{$eqLaTeX}",
        ];

        final List<String> step2Lines = [
          "\\text{Find the LCM of the denominators } (${f1.den} \\text{ and } ${f2.den}), \\text{ which is } \\mathbf{$lcmAll}.",
          "\\text{Multiply every term on both sides of the equation by } $lcmAll:",
          "$lcmAll \\times \\left(${formatFracCoeffXLaTeX(f1)}\\right) $opSym $lcmAll \\times \\left(${formatFracCoeffXLaTeX(f2)}\\right) = $lcmAll \\times ${c.improperLaTeX}",
          "${term1Coeff}x $opSym ${term2Coeff}x = $rhsAfterLCM",
          "\\text{Combine like terms in } x:",
          "${netXCoeff}x = $rhsAfterLCM",
          "\\text{Divide both sides by } $netXCoeff:",
          "x = \\frac{$rhsAfterLCM}{$netXCoeff}",
          "\\therefore \\; \\mathbf{x = ${xFmt['latex']}}"
              "${xFmt['plain'] != fmt(exactX) ? ' \\quad \\left(\\text{or } \\mathbf{${fmt(exactX)}}\\right)' : ''}",
        ];

        final List<String> step3Lines = [
          "\\text{Check:}",
          "\\bullet \\text{ 1st part: } ${f1.improperLaTeX} \\times ${xFmt['improperLaTeX']} = ${fmt(f1.value * exactX)}",
          "\\bullet \\text{ 2nd part: } ${f2.improperLaTeX} \\times ${xFmt['improperLaTeX']} = ${fmt(f2.value * exactX)}",
          "\\bullet \\text{ ${isSum ? 'Sum' : 'Difference'}} = ${fmt(f1.value * exactX)} $opSym ${fmt(f2.value * exactX)} = \\mathbf{${c.displayLaTeX}} \\quad (\\text{Verified!})",
        ];

        workings.add(
            "\\text{\\textbf{Step 1: Set Up the Fractional Equation}}");
        workings.addAll(step1Lines);
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 2: Clear Fractions Using LCM = $lcmAll and Solve for }} x");
        workings.addAll(step2Lines);
        workings.add("");
        workings.add("\\text{\\textbf{Step 3: Verification Check}}");
        workings.addAll(step3Lines);

        steps.add(FractionWordProblemStep(
          title:
          "Step 1: Write Both Fractions of x and Form the ${isSum ? 'Sum' : 'Difference'} Equation",
          description:
          "• Let the unknown number be x.\n"
              "• The ${isSum ? 'sum' : 'difference'} of ${f1.displayPlain} of x and ${f2.displayPlain} of x is ${c.displayPlain} → $eqPlain.",
          mathLinesLaTeX: step1Lines,
        ));

        steps.add(FractionWordProblemStep(
          title:
          "Step 2: Multiply Every Term by the LCM ($lcmAll) & Solve for x",
          description:
          "1. The LCM of denominators ${f1.den} and ${f2.den} is $lcmAll.\n"
              "2. Multiply every term by $lcmAll to clear the denominators: ${term1Coeff}x $opSym ${term2Coeff}x = $rhsAfterLCM.\n"
              "3. Simplify to ${netXCoeff}x = $rhsAfterLCM and divide by $netXCoeff to get x = ${xFmt['plain']}.",
          mathLinesLaTeX: [...step2Lines, ...step3Lines],
        ));

        return FractionWordProblemResult(
          mode: 0,
          subMode: subMode,
          finalAnswers: {
            "Fractional Equation": eqPlain,
            "LCM of Denominators": "$lcmAll",
            "Required Number (x)": xFmt['plain']!,
            "1st & 2nd Parts":
            "${fmt(f1.value * exactX)} & ${fmt(f2.value * exactX)}",
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: FractionWordProblemsCanvasData(
            visualType: 0,
            topFractionalEqText: "Fractional Equation:   $eqPlain",
            lcmBridgeBadgeText:
            "Multiply Every Term by LCM(${f1.den}, ${f2.den}) = $lcmAll",
            clearedIntegerEqText:
            "Cleared Equation:   ${term1Coeff}x $opSym ${term2Coeff}x = $rhsAfterLCM   ➔   ${netXCoeff}x = $rhsAfterLCM",
            finalSolutionBannerText: "Solution:   x = ${xFmt['plain']}",
            headerBadge:
            "${isSum ? 'Sum' : 'Difference'} of Two Fractions:   $eqPlain   ➔   x = ${xFmt['plain']}",
            subBadge:
            "LCM = $lcmAll   ➔   ${term1Coeff}x $opSym ${term2Coeff}x = $rhsAfterLCM   ➔   ${netXCoeff}x = $rhsAfterLCM   ➔   x = ${xFmt['plain']}",
            bottomSummaryBanner: "Required Number:  x = ${xFmt['plain']}",
          ),
        );
      } else {
        // Sub-Mode 3: Two-Sided Fractional Equation: (p1/q1)x + b = (p2/q2)x + d
        final ParsedRational f1 =
        parseRational(input1Str, fieldName: 'LHS Fraction (p₁/q₁)');
        final ParsedRational b =
        parseRational(input2Str, fieldName: 'LHS Constant (b)');
        final ParsedRational f2 =
        parseRational(input3Str, fieldName: 'RHS Fraction (p₂/q₂)');
        final ParsedRational d =
        parseRational(input4Str, fieldName: 'RHS Constant (d)');

        final int lcmAll = lcm(lcm(f1.den, b.den), lcm(f2.den, d.den));
        final int A = f1.num * (lcmAll ~/ f1.den);
        final int B = b.num * (lcmAll ~/ b.den);
        final int C = f2.num * (lcmAll ~/ f2.den);
        final int D = d.num * (lcmAll ~/ d.den);

        final int netX = A - C;
        final int netConst = D - B;
        if (netX == 0) {
          throw const FormatException(
              "The x-terms on both sides have equal coefficients, so there is no unique solution.");
        }

        final Map<String, String> xFmt = formatRational(netConst, netX);
        final double exactX = netConst / netX;

        final String lhsLaTeX =
            "${formatFracCoeffXLaTeX(f1)} ${b.num == 0 ? '' : (b.value > 0 ? '+ ${b.improperLaTeX}' : '- ${b.improperLaTeX.replaceFirst('-', '')}')}";
        final String rhsLaTeX =
            "${formatFracCoeffXLaTeX(f2)} ${d.num == 0 ? '' : (d.value > 0 ? '+ ${d.improperLaTeX}' : '- ${d.improperLaTeX.replaceFirst('-', '')}')}";
        final String eqLaTeX = "$lhsLaTeX = $rhsLaTeX";
        final String eqPlain =
            "${formatFracCoeffXPlain(f1)} ${b.num == 0 ? '' : (b.value > 0 ? '+ ${b.displayPlain}' : '− ${b.displayPlain.replaceFirst('-', '')}')} = ${formatFracCoeffXPlain(f2)} ${d.num == 0 ? '' : (d.value > 0 ? '+ ${d.displayPlain}' : '− ${d.displayPlain.replaceFirst('-', '')}')}";

        final List<String> step1Lines = [
          "\\text{Let the unknown number be } x.",
          "\\text{Equate the two fractional expressions:}",
          "\\mathbf{$eqLaTeX}",
        ];

        final List<String> step2Lines = [
          "\\text{Multiply every single term on both sides by the LCM of all denominators } (\\text{LCM} = \\mathbf{$lcmAll}):",
          "$lcmAll\\left($lhsLaTeX\\right) = $lcmAll\\left($rhsLaTeX\\right)",
          "${A}x ${B == 0 ? '' : (B > 0 ? '+ $B' : '- ${B.abs()}')} = ${C}x ${D == 0 ? '' : (D > 0 ? '+ $D' : '- ${D.abs()}')}",
          "\\text{Collect like terms in } x \\text{ on the LHS and constants on the RHS:}",
          "${A}x ${C >= 0 ? '- ${C}x' : '+ ${C.abs()}x'} = $D ${B >= 0 ? '- $B' : '+ ${B.abs()}'}",
          "${netX}x = $netConst",
          "x = \\frac{$netConst}{$netX} = \\mathbf{${xFmt['latex']}}",
        ];

        workings.add(
            "\\text{\\textbf{Step 1: Form the Two-Sided Fractional Equation}}");
        workings.addAll(step1Lines);
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 2: Multiply Every Term by LCM ($lcmAll) and Solve for }} x");
        workings.addAll(step2Lines);

        steps.add(FractionWordProblemStep(
          title: "Step 1: Set Up the Two-Sided Fractional Equation",
          description:
          "Translate both fractional expressions in terms of x and equate them:\n• $eqPlain.",
          mathLinesLaTeX: step1Lines,
        ));

        steps.add(FractionWordProblemStep(
          title:
          "Step 2: Multiply Every Term by the LCM ($lcmAll) & Collect Like Terms",
          description:
          "1. Multiply every term on both sides by LCM = $lcmAll to clear all fractions: ${A}x ${B >= 0 ? '+ $B' : '− ${B.abs()}'} = ${C}x ${D >= 0 ? '+ $D' : '− ${D.abs()}'}.\n"
              "2. Collect x-terms on the LHS (${netX}x) and constants on the RHS ($netConst) to find x = ${xFmt['plain']}.",
          mathLinesLaTeX: step2Lines,
        ));

        return FractionWordProblemResult(
          mode: 0,
          subMode: 3,
          finalAnswers: {
            "Fractional Equation": eqPlain,
            "LCM of Denominators": "$lcmAll",
            "Required Number (x)": xFmt['plain']!,
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: FractionWordProblemsCanvasData(
            visualType: 0,
            topFractionalEqText: "Fractional Equation:   $eqPlain",
            lcmBridgeBadgeText:
            "Multiply Every Term on Both Sides by LCM = $lcmAll",
            clearedIntegerEqText:
            "Cleared:  ${A}x ${B >= 0 ? '+ $B' : '− ${B.abs()}'} = ${C}x ${D >= 0 ? '+ $D' : '− ${D.abs()}'}   ➔   ${netX}x = $netConst",
            finalSolutionBannerText: "Solution:   x = ${xFmt['plain']}",
            headerBadge:
            "Two-Sided Fractional Equation   ➔   x = ${xFmt['plain']}",
            subBadge:
            "LCM = $lcmAll   ➔   ${netX}x = $netConst   ➔   x = ${xFmt['plain']}",
            bottomSummaryBanner: "Required Number:  x = ${xFmt['plain']}",
          ),
        );
      }
    } catch (e) {
      return FractionWordProblemResult.error(
        mode: 0,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid fractions or numbers in all fields.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: ALGEBRAIC NUMERATORS / BINOMIAL EXPRESSIONS OVER A DENOMINATOR
  // Sub-Modes:
  // 0: Single Algebraic Fraction: (a*x + b) / d = c
  // 1: Equating Two Algebraic Fractions: (x + b1) / d1 = (x + b2) / d2
  // 2: Sum of Two Algebraic Fractions: (x + b1) / d1 + (x + b2) / d2 = 5 (or custom c)
  // ===========================================================================
  static FractionWordProblemResult solveAlgebraicNumeratorProblem({
    required int subMode,
    required String input1Str,
    required String input2Str,
    required String input3Str,
    required String input4Str,
  }) {
    try {
      final List<String> workings = [];
      final List<FractionWordProblemStep> steps = [];

      if (subMode == 0) {
        // Sub-Mode 0: (a*x + b) / d = c
        final ParsedRational a =
        parseRational(input1Str, fieldName: 'Coefficient of x (a)');
        final ParsedRational b =
        parseRational(input2Str, fieldName: 'Added/Subtracted Constant (b)');
        final ParsedRational d =
        parseRational(input3Str, fieldName: 'Divisor / Denominator (d)');
        final ParsedRational c =
        parseRational(input4Str, fieldName: 'Given Result (c)');

        if (a.value.abs() < 1e-12 || d.value.abs() < 1e-12) {
          throw const FormatException(
              "The coefficient of x and the denominator d cannot be zero.");
        }

        final String axPart =
        (a.value - 1.0).abs() < 1e-9 ? "x" : "${fmt(a.value)}x";
        final String numExprLaTeX = b.value >= 0
            ? "$axPart + ${fmt(b.value)}"
            : "$axPart - ${fmt(b.value.abs())}";
        final String numExprPlain = numExprLaTeX.replaceAll('-', '−');

        final String eqLaTeX =
            "\\frac{$numExprLaTeX}{${fmt(d.value)}} = ${c.displayLaTeX}";
        final String eqPlain =
            "($numExprPlain) / ${fmt(d.value)} = ${c.displayPlain}";

        final double cdVal = c.value * d.value;
        final double rhsAfterB = cdVal - b.value;
        final double exactX = rhsAfterB / a.value;

        final List<String> step1Lines = [
          "\\text{Let the unknown number be } x.",
          "\\text{Numerator expression} = $numExprLaTeX",
          "\\text{Divide the entire expression by } ${fmt(d.value)} \\text{ and equate to } ${c.displayLaTeX}:",
          "\\mathbf{$eqLaTeX}",
        ];

        final List<String> step2Lines = [
          eqLaTeX,
          "\\text{Multiply both sides by the denominator } ${fmt(d.value)} \\text{ to clear the fraction:}",
          "${fmt(d.value)} \\times \\frac{$numExprLaTeX}{${fmt(d.value)}} = ${fmt(d.value)} \\times ${c.displayLaTeX}",
          "$numExprLaTeX = ${fmt(cdVal)}",
          "\\text{${b.value >= 0 ? 'Subtract ${fmt(b.value)} from' : 'Add ${fmt(b.value.abs())} to'} both sides:}",
          "$axPart = ${fmt(cdVal)} ${b.value >= 0 ? '- ${fmt(b.value)}' : '+ ${fmt(b.value.abs())}'}",
          "$axPart = ${fmt(rhsAfterB)}",
          if ((a.value - 1.0).abs() > 1e-9) ...[
            "\\text{Divide both sides by } ${fmt(a.value)}:",
            "x = \\frac{${fmt(rhsAfterB)}}{${fmt(a.value)}}",
          ],
          "\\therefore \\; \\mathbf{x = ${fmt(exactX)}}",
          "\\text{Check: } \\frac{${(a.value - 1.0).abs() < 1e-9 ? fmt(exactX) : '${fmt(a.value)}(${fmt(exactX)})'} ${b.value >= 0 ? '+ ${fmt(b.value)}' : '- ${fmt(b.value.abs())}'}}{${fmt(d.value)}} = \\frac{${fmt(cdVal)}}{${fmt(d.value)}} = \\mathbf{${c.displayLaTeX}} \\quad (\\text{Verified!})",
        ];

        workings.add(
            "\\text{\\textbf{Step 1: Form the Algebraic Fraction Equation}}");
        workings.addAll(step1Lines);
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 2: Multiply Both Sides by Denominator (${fmt(d.value)}) and Solve for }} x");
        workings.addAll(step2Lines);

        steps.add(FractionWordProblemStep(
          title:
          "Step 1: Place ($numExprPlain) Over the Denominator ${fmt(d.value)}",
          description:
          "Because the entire expression ($numExprPlain) is divided by ${fmt(d.value)} (or multiplied by 1/${fmt(d.value)}), write ($numExprPlain) as the numerator over ${fmt(d.value)}:\n• $eqPlain.",
          mathLinesLaTeX: step1Lines,
        ));

        steps.add(FractionWordProblemStep(
          title:
          "Step 2: Multiply Both Sides by ${fmt(d.value)} to Clear the Fraction",
          description:
          "1. Multiply both sides by ${fmt(d.value)}: $numExprPlain = ${fmt(d.value)} × ${c.displayPlain} = ${fmt(cdVal)}.\n"
              "2. Solve the resulting linear equation to get x = ${fmt(exactX)}.",
          mathLinesLaTeX: step2Lines,
        ));

        return FractionWordProblemResult(
          mode: 1,
          subMode: 0,
          finalAnswers: {
            "Fractional Equation": eqPlain,
            "Cleared Equation": "$numExprPlain = ${fmt(cdVal)}",
            "Required Number (x)": fmt(exactX),
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: FractionWordProblemsCanvasData(
            visualType: 0,
            topFractionalEqText: "Fractional Equation:   $eqPlain",
            lcmBridgeBadgeText:
            "Multiply Both Sides by Denominator d = ${fmt(d.value)}",
            clearedIntegerEqText:
            "Cleared:   $numExprPlain = ${fmt(cdVal)}   ➔   $axPart = ${fmt(rhsAfterB)}",
            finalSolutionBannerText: "Solution:   x = ${fmt(exactX)}",
            headerBadge:
            "Algebraic Numerator:   $eqPlain   ➔   x = ${fmt(exactX)}",
            subBadge:
            "Multiply by ${fmt(d.value)}   ➔   $numExprPlain = ${fmt(cdVal)}   ➔   x = ${fmt(exactX)}",
            bottomSummaryBanner: "Required Number:  x = ${fmt(exactX)}",
          ),
        );
      } else {
        // Sub-Mode 1: Equating Two Algebraic Fractions: (x + b1)/d1 = (x + b2)/d2
        // Sub-Mode 2: Sum of Two Algebraic Fractions: (x + b1)/d1 + (x + b2)/d2 = 5
        final ParsedRational b1 =
        parseRational(input1Str, fieldName: '1st Numerator Constant (b₁)');
        final ParsedRational d1 =
        parseRational(input2Str, fieldName: '1st Denominator (d₁)');
        final ParsedRational b2 =
        parseRational(input3Str, fieldName: '2nd Numerator Constant (b₂)');
        final ParsedRational d2 =
        parseRational(input4Str, fieldName: '2nd Denominator (d₂)');

        final int den1 = d1.value.round();
        final int den2 = d2.value.round();
        if (den1 == 0 || den2 == 0) {
          throw const FormatException("Denominators cannot be zero.");
        }

        final int lcmDen = lcm(den1, den2);
        final int mult1 = lcmDen ~/ den1;
        final int mult2 = lcmDen ~/ den2;

        final String num1LaTeX = b1.value >= 0
            ? "x + ${fmt(b1.value)}"
            : "x - ${fmt(b1.value.abs())}";
        final String num2LaTeX = b2.value >= 0
            ? "x + ${fmt(b2.value)}"
            : "x - ${fmt(b2.value.abs())}";
        final String num1Plain = num1LaTeX.replaceAll('-', '−');
        final String num2Plain = num2LaTeX.replaceAll('-', '−');

        if (subMode == 1) {
          // (x + b1)/d1 = (x + b2)/d2
          final int netX = mult1 - mult2;
          if (netX == 0) {
            throw const FormatException(
                "Both fractions have equal denominators, so x cancels out.");
          }
          final double const1 = mult1 * b1.value;
          final double const2 = mult2 * b2.value;
          final double netConst = const2 - const1;
          final double exactX = netConst / netX;

          final String eqLaTeX =
              "\\frac{$num1LaTeX}{$den1} = \\frac{$num2LaTeX}{$den2}";
          final String eqPlain = "($num1Plain)/$den1 = ($num2Plain)/$den2";

          final List<String> step1Lines = [
            "\\text{Equate the two algebraic fractions:}",
            "\\mathbf{$eqLaTeX}",
          ];

          final List<String> step2Lines = [
            "\\text{Multiply both sides by } \\text{LCM}($den1, $den2) = \\mathbf{$lcmDen} \\text{ (or cross-multiply):}",
            "$lcmDen \\times \\frac{$num1LaTeX}{$den1} = $lcmDen \\times \\frac{$num2LaTeX}{$den2}",
            "$mult1($num1LaTeX) = $mult2($num2LaTeX)",
            "\\text{Expand the brackets on both sides:}",
            "${mult1}x ${const1 >= 0 ? '+ ${fmt(const1)}' : '- ${fmt(const1.abs())}'} = ${mult2}x ${const2 >= 0 ? '+ ${fmt(const2)}' : '- ${fmt(const2.abs())}'}",
            "\\text{Collect like terms:}",
            "${mult1}x - ${mult2}x = ${fmt(const2)} ${const1 >= 0 ? '- ${fmt(const1)}' : '+ ${fmt(const1.abs())}'}",
            "${netX}x = ${fmt(netConst)}",
            "\\therefore \\; \\mathbf{x = ${fmt(exactX)}}",
          ];

          workings.add("\\text{\\textbf{Step 1: Form the Equation}}");
          workings.addAll(step1Lines);
          workings.add("");
          workings.add(
              "\\text{\\textbf{Step 2: Multiply by LCM ($lcmDen), Expand Brackets \\& Solve}}");
          workings.addAll(step2Lines);

          steps.add(FractionWordProblemStep(
            title: "Step 1: Equate the Two Algebraic Fractions",
            description:
            "Write the two fractional expressions equal to each other:\n• $eqPlain.",
            mathLinesLaTeX: step1Lines,
          ));

          steps.add(FractionWordProblemStep(
            title:
            "Step 2: Multiply by LCM ($lcmDen), Expand Brackets & Solve for x",
            description:
            "1. Multiply both sides by LCM($den1, $den2) = $lcmDen: $mult1($num1Plain) = $mult2($num2Plain).\n"
                "2. Expand brackets and collect like terms to get x = ${fmt(exactX)}.",
            mathLinesLaTeX: step2Lines,
          ));

          return FractionWordProblemResult(
            mode: 1,
            subMode: 1,
            finalAnswers: {
              "Equation": eqPlain,
              "LCM of Denominators": "$lcmDen",
              "Required Number (x)": fmt(exactX),
            },
            workingsLaTeX: workings,
            steps: steps,
            canvasData: FractionWordProblemsCanvasData(
              visualType: 0,
              topFractionalEqText: "Fractional Equation:   $eqPlain",
              lcmBridgeBadgeText:
              "Multiply Both Sides by LCM($den1, $den2) = $lcmDen",
              clearedIntegerEqText:
              "Cleared:   $mult1($num1Plain) = $mult2($num2Plain)   ➔   ${netX}x = ${fmt(netConst)}",
              finalSolutionBannerText: "Solution:   x = ${fmt(exactX)}",
              headerBadge:
              "Equating Two Algebraic Fractions   ➔   x = ${fmt(exactX)}",
              subBadge:
              "LCM = $lcmDen   ➔   $mult1($num1Plain) = $mult2($num2Plain)   ➔   x = ${fmt(exactX)}",
              bottomSummaryBanner: "Required Number:  x = ${fmt(exactX)}",
            ),
          );
        } else {
          // Sub-Mode 2: Sum of Two Algebraic Fractions: (x + b1)/d1 + (x + b2)/d2 = 5
          const int targetSumC = 5;
          final int rhsScaled = lcmDen * targetSumC;
          final int netX = mult1 + mult2;
          final int const1 = (mult1 * b1.value).round();
          final int const2 = (mult2 * b2.value).round();
          final int netConstLHS = const1 + const2;
          final int rhsAfterConst = rhsScaled - netConstLHS;
          final Map<String, String> xFmt =
          formatRational(rhsAfterConst, netX);

          final String eqLaTeX =
              "\\frac{$num1LaTeX}{$den1} + \\frac{$num2LaTeX}{$den2} = $targetSumC";
          final String eqPlain =
              "($num1Plain)/$den1 + ($num2Plain)/$den2 = $targetSumC";

          final List<String> step1Lines = [
            "\\text{Write the sum of the two algebraic fractions equal to } $targetSumC:",
            "\\mathbf{$eqLaTeX}",
          ];

          final List<String> step2Lines = [
            "\\text{Multiply every term by } \\text{LCM}($den1, $den2) = \\mathbf{$lcmDen}:",
            "$lcmDen \\times \\frac{$num1LaTeX}{$den1} + $lcmDen \\times \\frac{$num2LaTeX}{$den2} = $lcmDen \\times $targetSumC",
            "$mult1($num1LaTeX) + $mult2($num2LaTeX) = $rhsScaled",
            "\\text{Expand brackets (watch signs carefully!):}",
            "${mult1}x ${const1 >= 0 ? '+ $const1' : '- ${const1.abs()}'} + ${mult2}x ${const2 >= 0 ? '+ $const2' : '- ${const2.abs()}'} = $rhsScaled",
            "\\text{Group like terms:}",
            "${netX}x ${netConstLHS >= 0 ? '+ $netConstLHS' : '- ${netConstLHS.abs()}'} = $rhsScaled",
            "${netX}x = $rhsScaled ${netConstLHS >= 0 ? '- $netConstLHS' : '+ ${netConstLHS.abs()}'} = $rhsAfterConst",
            "x = \\frac{$rhsAfterConst}{$netX} = \\mathbf{${xFmt['latex']}}",
          ];

          workings.add(
              "\\text{\\textbf{Step 1: Set Up the Sum of Two Algebraic Fractions}}");
          workings.addAll(step1Lines);
          workings.add("");
          workings.add(
              "\\text{\\textbf{Step 2: Multiply by LCM ($lcmDen), Expand Brackets \\& Solve}}");
          workings.addAll(step2Lines);

          steps.add(FractionWordProblemStep(
            title: "Step 1: Write the Sum of Both Algebraic Fractions",
            description:
            "Enclose each binomial numerator over its denominator:\n• $eqPlain.",
            mathLinesLaTeX: step1Lines,
          ));

          steps.add(FractionWordProblemStep(
            title:
            "Step 2: Multiply Every Term by LCM ($lcmDen) & Expand Brackets",
            description:
            "1. Multiply every term by LCM($den1, $den2) = $lcmDen: $mult1($num1Plain) + $mult2($num2Plain) = $rhsScaled.\n"
                "2. Expand brackets, collect like terms (${netX}x = $rhsAfterConst), and divide by $netX to get x = ${xFmt['plain']}.",
            mathLinesLaTeX: step2Lines,
          ));

          return FractionWordProblemResult(
            mode: 1,
            subMode: 2,
            finalAnswers: {
              "Equation": eqPlain,
              "LCM of Denominators": "$lcmDen",
              "Required Number (x)": xFmt['plain']!,
            },
            workingsLaTeX: workings,
            steps: steps,
            canvasData: FractionWordProblemsCanvasData(
              visualType: 0,
              topFractionalEqText: "Fractional Equation:   $eqPlain",
              lcmBridgeBadgeText:
              "Multiply Every Term by LCM($den1, $den2) = $lcmDen",
              clearedIntegerEqText:
              "Cleared:   $mult1($num1Plain) + $mult2($num2Plain) = $rhsScaled   ➔   ${netX}x = $rhsAfterConst",
              finalSolutionBannerText: "Solution:   x = ${xFmt['plain']}",
              headerBadge:
              "Sum of Two Algebraic Fractions   ➔   x = ${xFmt['plain']}",
              subBadge:
              "LCM = $lcmDen   ➔   ${netX}x = $rhsAfterConst   ➔   x = ${xFmt['plain']}",
              bottomSummaryBanner: "Required Number:  x = ${xFmt['plain']}",
            ),
          );
        }
      }
    } catch (e) {
      return FractionWordProblemResult.error(
        mode: 1,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid numbers in all fields.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: UNKNOWN IN THE DENOMINATOR & FINDING AN ORIGINAL FRACTION (N / D)
  // Sub-Modes:
  // 0: Unknown in the Denominator: a / (x + b) = c
  // 1: Finding an Original Fraction: Denominator is k more than numerator; adding m to both gives p/q
  // ===========================================================================
  static FractionWordProblemResult solveDenominatorOrOriginalFraction({
    required int subMode,
    required String input1Str,
    required String input2Str,
    required String input3Str,
  }) {
    try {
      final List<String> workings = [];
      final List<FractionWordProblemStep> steps = [];

      if (subMode == 0) {
        // Sub-Mode 0: a / (x + b) = p / q
        final ParsedRational a =
        parseRational(input1Str, fieldName: 'Numerator (a)');
        final ParsedRational b = parseRational(
          input2Str,
          fieldName: 'Added/Subtracted Constant in Denominator (b)',
        );
        final ParsedRational c =
        parseRational(input3Str, fieldName: 'Given Result (c)');

        if (c.num == 0) {
          throw const FormatException("The result c cannot be zero.");
        }

        final String denExprLaTeX = b.num == 0
            ? "x"
            : (b.value > 0
            ? "x + ${fmt(b.value)}"
            : "x - ${fmt(b.value.abs())}");
        final String denExprPlain = denExprLaTeX.replaceAll('-', '−');

        final String eqLaTeX =
            "\\frac{${a.displayLaTeX}}{$denExprLaTeX} = ${c.displayLaTeX}";
        final String eqPlain =
            "${a.displayPlain} / ($denExprPlain) = ${c.displayPlain}";

        // Cross-multiply: c.num * (x + b) = a.value * c.den
        final int pCoeff = c.num;
        final double rhsCross = a.value * c.den;
        final double pbVal = pCoeff * b.value;
        final double rhsAfterB = rhsCross - pbVal;
        final double exactX = rhsAfterB / pCoeff;

        final List<String> step1Lines = [
          "\\text{Let the unknown number be } x.",
          "\\text{Dividing } ${a.displayLaTeX} \\text{ by } ($denExprLaTeX) \\text{ gives } ${c.displayLaTeX}:",
          "\\mathbf{$eqLaTeX}",
          if (c.isMixedInput)
            "\\text{Convert mixed number to improper fraction: } \\quad \\frac{${a.displayLaTeX}}{$denExprLaTeX} = ${c.improperLaTeX}",
        ];

        final List<String> step2Lines = [
          "\\frac{${a.displayLaTeX}}{$denExprLaTeX} = ${c.improperLaTeX}",
          "\\text{Cross-multiply (multiply both sides by } ${c.den}($denExprLaTeX)\\text{):}",
          "$pCoeff($denExprLaTeX) = ${a.displayLaTeX} \\times ${c.den}",
          if (b.num != 0) ...[
            "${pCoeff}x ${pbVal >= 0 ? '+ ${fmt(pbVal)}' : '- ${fmt(pbVal.abs())}'} = ${fmt(rhsCross)}",
            "${pCoeff}x = ${fmt(rhsCross)} ${pbVal >= 0 ? '- ${fmt(pbVal)}' : '+ ${fmt(pbVal.abs())}'}",
          ],
          "${pCoeff}x = ${fmt(rhsAfterB)}",
          "x = \\frac{${fmt(rhsAfterB)}}{$pCoeff} = \\mathbf{${fmt(exactX)}}",
        ];

        workings.add(
            "\\text{\\textbf{Step 1: Form the Equation with }} x \\text{\\textbf{ in the Denominator}}");
        workings.addAll(step1Lines);
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 2: Cross-Multiply to Clear the Denominator and Solve for }} x");
        workings.addAll(step2Lines);

        steps.add(FractionWordProblemStep(
          title: "Step 1: Place ($denExprPlain) in the Denominator",
          description:
          "When ${a.displayPlain} is divided by ($denExprPlain), ($denExprPlain) is the denominator:\n• $eqPlain.",
          mathLinesLaTeX: step1Lines,
        ));

        steps.add(FractionWordProblemStep(
          title: "Step 2: Cross-Multiply and Solve for x",
          description:
          "1. Cross-multiply: $pCoeff($denExprPlain) = ${a.displayPlain} × ${c.den} = ${fmt(rhsCross)}.\n"
              "2. Solve for x to find x = ${fmt(exactX)}.",
          mathLinesLaTeX: step2Lines,
        ));

        return FractionWordProblemResult(
          mode: 2,
          subMode: 0,
          finalAnswers: {
            "Equation": eqPlain,
            "Cross-Multiplied": "$pCoeff($denExprPlain) = ${fmt(rhsCross)}",
            "Required Number (x)": fmt(exactX),
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: FractionWordProblemsCanvasData(
            visualType: 0,
            topFractionalEqText: "Unknown in Denominator:   $eqPlain",
            lcmBridgeBadgeText:
            "Cross-Multiply Both Sides by ${c.den}($denExprPlain)",
            clearedIntegerEqText:
            "Cleared:   $pCoeff($denExprPlain) = ${fmt(rhsCross)}   ➔   ${pCoeff}x = ${fmt(rhsAfterB)}",
            finalSolutionBannerText: "Solution:   x = ${fmt(exactX)}",
            headerBadge:
            "Unknown in Denominator:   $eqPlain   ➔   x = ${fmt(exactX)}",
            subBadge:
            "Cross-multiply   ➔   $pCoeff($denExprPlain) = ${fmt(rhsCross)}   ➔   x = ${fmt(exactX)}",
            bottomSummaryBanner: "Required Number:  x = ${fmt(exactX)}",
          ),
        );
      } else {
        // Sub-Mode 1: Finding an Original Fraction:
        // Denominator is k more than numerator: Original = x / (x + k)
        // When m is added/subtracted from both top and bottom, result is p/q:
        // (x + m) / (x + k + m) = p / q
        final ParsedRational kDiff = parseRational(
          input1Str,
          fieldName: 'Difference (Denominator − Numerator)',
        );
        final ParsedRational mChange = parseRational(
          input2Str,
          fieldName: 'Number Added/Subtracted to Both (m)',
        );
        final ParsedRational targetRatio =
        parseRational(input3Str, fieldName: 'Resulting Fraction (p/q)');

        final int k = kDiff.value.round();
        final int m = mChange.value.round();
        final int p = targetRatio.num;
        final int q = targetRatio.den;

        if (q == p) {
          throw const FormatException(
              "The resulting fraction p/q cannot equal 1 when numerator and denominator differ.");
        }

        final int newDenConst = k + m;
        // Cross-multiply: q(x + m) = p(x + newDenConst)
        // q*x + q*m = p*x + p*newDenConst  =>  (q - p)x = p*newDenConst - q*m
        final int netXCoeff = q - p;
        final int netRhsConst = p * newDenConst - q * m;
        final double exactX = netRhsConst / netXCoeff;
        final double origDen = exactX + k;

        final String origDenExpr = k >= 0 ? "x + $k" : "x - ${k.abs()}";
        final String newNumExpr =
        m >= 0 ? "x + $m" : "x - ${m.abs()}";
        final String newDenExpr = newDenConst >= 0
            ? "x + $newDenConst"
            : "x - ${newDenConst.abs()}";

        final List<String> step1Lines = [
          "\\text{Let the numerator of the original fraction be } x.",
          "\\text{Since the denominator is } $k \\text{ more than the numerator, denominator} = ($origDenExpr).",
          "\\text{Original Fraction} = \\mathbf{\\frac{x}{$origDenExpr}}",
          "\\text{${m >= 0 ? 'Add $m to' : 'Subtract ${m.abs()} from'} both the numerator and the denominator:}",
          "\\frac{$newNumExpr}{($origDenExpr) ${m >= 0 ? '+ $m' : '- ${m.abs()}'}} = ${targetRatio.improperLaTeX}",
          "\\mathbf{\\frac{$newNumExpr}{$newDenExpr} = ${targetRatio.improperLaTeX}}",
        ];

        final List<String> step2Lines = [
          "\\frac{$newNumExpr}{$newDenExpr} = \\frac{$p}{$q}",
          "\\text{Cross-multiply to clear the denominators:}",
          "$q($newNumExpr) = $p($newDenExpr)",
          "${q}x ${q * m >= 0 ? '+ ${q * m}' : '- ${(q * m).abs()}'} = ${p}x ${p * newDenConst >= 0 ? '+ ${p * newDenConst}' : '- ${(p * newDenConst).abs()}'}",
          "\\text{Collect like terms:}",
          "${q}x - ${p}x = ${p * newDenConst} ${q * m >= 0 ? '- ${q * m}' : '+ ${(q * m).abs()}'}",
          "${netXCoeff}x = $netRhsConst",
          "x = \\frac{$netRhsConst}{$netXCoeff} = \\mathbf{${fmt(exactX)}} \\quad (\\text{Original Numerator})",
        ];

        final List<String> step3Lines = [
          "\\bullet \\text{ Original Numerator } (x) = \\mathbf{${fmt(exactX)}}",
          "\\bullet \\text{ Original Denominator } ($origDenExpr) = ${fmt(exactX)} ${k >= 0 ? '+ $k' : '- ${k.abs()}'} = \\mathbf{${fmt(origDen)}}",
          "\\therefore \\; \\text{Original Fraction} = \\mathbf{\\frac{${fmt(exactX)}}{${fmt(origDen)}}}",
          "\\text{Check: } \\frac{${fmt(exactX)} ${m >= 0 ? '+ $m' : '- ${m.abs()}'}}{${fmt(origDen)} ${m >= 0 ? '+ $m' : '- ${m.abs()}'}} = \\frac{${fmt(exactX + m)}}{${fmt(origDen + m)}} = \\mathbf{\\frac{$p}{$q}} \\quad (\\text{Verified!})",
        ];

        workings.add(
            "\\text{\\textbf{Step 1: Express the Original Fraction and Modified Fraction in Terms of }} x");
        workings.addAll(step1Lines);
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 2: Cross-Multiply and Solve for the Numerator (}}x\\text{\\textbf{)}}");
        workings.addAll(step2Lines);
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 3: Substitute }} x = ${fmt(exactX)} \\text{\\textbf{ to State the Original Fraction}}");
        workings.addAll(step3Lines);

        steps.add(FractionWordProblemStep(
          title:
          "Step 1: Represent the Original Fraction as x / ($origDenExpr)",
          description:
          "• Let the numerator be x, so the denominator is ($origDenExpr) and the original fraction is x / ($origDenExpr).\n"
              "• Modifying both top and bottom by ${m >= 0 ? '+$m' : '$m'} gives ($newNumExpr) / ($newDenExpr) = $p/$q.",
          mathLinesLaTeX: step1Lines,
        ));

        steps.add(FractionWordProblemStep(
          title:
          "Step 2: Cross-Multiply, Find x, and Write the Original Fraction",
          description:
          "1. Cross-multiply: $q($newNumExpr) = $p($newDenExpr).\n"
              "2. Solve for x to get numerator x = ${fmt(exactX)} and denominator = ${fmt(origDen)}.\n"
              "3. Therefore, the original fraction is ${fmt(exactX)}/${fmt(origDen)}!",
          mathLinesLaTeX: [...step2Lines, ...step3Lines],
        ));

        return FractionWordProblemResult(
          mode: 2,
          subMode: 1,
          finalAnswers: {
            "Original Numerator (x)": fmt(exactX),
            "Original Denominator": fmt(origDen),
            "Original Fraction": "${fmt(exactX)}/${fmt(origDen)}",
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: FractionWordProblemsCanvasData(
            visualType: 0,
            topFractionalEqText:
            "Modified Fraction:   ($newNumExpr) / ($newDenExpr) = $p/$q",
            lcmBridgeBadgeText:
            "Cross-Multiply:   $q($newNumExpr) = $p($newDenExpr)",
            clearedIntegerEqText:
            "Solve:   ${netXCoeff}x = $netRhsConst   ➔   Numerator x = ${fmt(exactX)},  Denominator = ${fmt(origDen)}",
            finalSolutionBannerText:
            "Original Fraction = ${fmt(exactX)}/${fmt(origDen)}",
            headerBadge:
            "Find Original Fraction:   x / ($origDenExpr) = ${fmt(exactX)}/${fmt(origDen)}",
            subBadge:
            "($newNumExpr)/($newDenExpr) = $p/$q   ➔   x = ${fmt(exactX)}   ➔   Original Fraction = ${fmt(exactX)}/${fmt(origDen)}",
            bottomSummaryBanner:
            "Original Fraction = ${fmt(exactX)}/${fmt(origDen)}",
          ),
        );
      }
    } catch (e) {
      return FractionWordProblemResult.error(
        mode: 2,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid numbers and fractions.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: REAL-LIFE FRACTIONAL SHARES OF A WHOLE & "OF THE REMAINDER" PROBLEMS
  // Sub-Modes:
  // 0: Direct Fractional Shares Taken from Original Whole: f1*x + f2*x + Rem = x
  // 1: Successive Fractional Shares ("f2 OF THE REMAINDER"): f1*x, then f2*(1 - f1)x, leaving Rem
  // ===========================================================================
  static FractionWordProblemResult solveRealLifeSharesAndRemainder({
    required int subMode,
    required String frac1Str,
    required String frac2Str,
    required String amountLeftStr,
  }) {
    try {
      final ParsedRational f1 =
      parseRational(frac1Str, fieldName: '1st Fraction Share');
      final ParsedRational f2 =
      parseRational(frac2Str, fieldName: '2nd Fraction Share');
      final ParsedRational remGiven =
      parseRational(amountLeftStr, fieldName: 'Remaining Amount Left');

      if (f1.value <= 0 ||
          f1.value >= 1 ||
          f2.value <= 0 ||
          f2.value >= 1) {
        throw const FormatException(
            "Each fractional share must be a proper fraction between 0 and 1 (e.g. 1/3, 1/4, or 2/5).");
      }
      if (remGiven.value <= 0) {
        throw const FormatException(
            "The remaining amount left must be greater than zero.");
      }

      // Effective 2nd fraction of the ORIGINAL whole:
      // In Sub-Mode 0 (Direct): eff2 = f2
      // In Sub-Mode 1 ("Of the Remainder"): Remainder after 1st = 1 - f1 = (f1.den - f1.num)/f1.den
      //   so eff2 = f2 * (1 - f1)
      final int remAfter1Num = f1.den - f1.num;
      final int remAfter1Den = f1.den;

      final int eff2Num =
      subMode == 0 ? f2.num : (f2.num * remAfter1Num);
      final int eff2Den =
      subMode == 0 ? f2.den : (f2.den * remAfter1Den);
      final Map<String, String> eff2Fmt = formatRational(eff2Num, eff2Den);

      // Total fraction used = f1 + eff2
      final int commonDen = lcm(f1.den, eff2Den);
      final int scaled1 = f1.num * (commonDen ~/ f1.den);
      final int scaled2 = eff2Num * (commonDen ~/ eff2Den);
      final int usedNum = scaled1 + scaled2;

      if (usedNum >= commonDen) {
        throw const FormatException(
            "The sum of the fractional shares is 1 or more, leaving nothing remaining! Please enter smaller fractions.");
      }

      final int leftFracNum = commonDen - usedNum;
      final Map<String, String> usedFmt = formatRational(usedNum, commonDen);
      final Map<String, String> leftFmt =
      formatRational(leftFracNum, commonDen);

      // Equation: (leftFracNum / commonDen) * x = remGiven
      final int gLeft = gcd(leftFracNum, commonDen);
      final int redLeftN = leftFracNum ~/ gLeft;
      final int redLeftD = commonDen ~/ gLeft;

      final double exactTotalX =
          (remGiven.value * redLeftD) / redLeftN;
      final double share1Val = (f1.num / f1.den) * exactTotalX;
      final double share2Val = (eff2Num / eff2Den) * exactTotalX;

      final List<String> workings = [];
      final List<FractionWordProblemStep> steps = [];

      if (subMode == 0) {
        // Sub-Mode 0: Direct Fractional Shares from the Original Whole
        final List<String> step1Lines = [
          "\\text{Let the total original amount (whole) be } x.",
          "\\bullet \\text{ 1st share} = ${f1.improperLaTeX}x",
          "\\bullet \\text{ 2nd share} = ${f2.improperLaTeX}x",
          "\\text{Total fraction used} = ${f1.improperLaTeX}x + ${f2.improperLaTeX}x = \\frac{$scaled1 + $scaled2}{$commonDen}x = ${usedFmt['improperLaTeX']}x",
          "\\text{Fraction remaining} = x - ${usedFmt['improperLaTeX']}x = \\left(1 - ${usedFmt['improperLaTeX']}\\right)x = \\mathbf{${leftFmt['improperLaTeX']}x}",
        ];

        final List<String> step2Lines = [
          "\\text{Equate the remaining fraction of } x \\text{ to the given amount left } (${remGiven.displayLaTeX}):",
          "\\mathbf{\\frac{$redLeftN}{$redLeftD}x = ${remGiven.displayLaTeX}}",
          "\\text{Multiply both sides by the denominator } $redLeftD:",
          "${redLeftN}x = ${remGiven.displayLaTeX} \\times $redLeftD = ${fmt(remGiven.value * redLeftD)}",
          if (redLeftN > 1) ...[
            "\\text{Divide both sides by } $redLeftN:",
            "x = \\frac{${fmt(remGiven.value * redLeftD)}}{$redLeftN}",
          ],
          "\\therefore \\; \\text{Total Original Amount } (x) = \\mathbf{${fmt(exactTotalX)}}",
        ];

        final List<String> step3Lines = [
          "\\bullet \\text{ 1st Share } \\left(${f1.improperLaTeX} \\text{ of } ${fmt(exactTotalX)}\\right) = \\mathbf{${fmt(share1Val)}}",
          "\\bullet \\text{ 2nd Share } \\left(${f2.improperLaTeX} \\text{ of } ${fmt(exactTotalX)}\\right) = \\mathbf{${fmt(share2Val)}}",
          "\\bullet \\text{ Amount Left} = \\mathbf{${remGiven.displayLaTeX}}",
          "\\text{Check Total: } ${fmt(share1Val)} + ${fmt(share2Val)} + ${remGiven.displayLaTeX} = \\mathbf{${fmt(exactTotalX)}} \\quad (\\text{Verified!})",
        ];

        workings.add(
            "\\text{\\textbf{Step 1: Find the Combined Fraction Used and the Fraction Remaining}}");
        workings.addAll(step1Lines);
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 2: Equate Remaining Fraction to ${remGiven.displayLaTeX} and Solve for }} x");
        workings.addAll(step2Lines);
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 3: Breakdown of Each Share and Verification}}");
        workings.addAll(step3Lines);

        steps.add(FractionWordProblemStep(
          title:
          "Step 1: Add the Fractional Shares & Subtract from 1 Whole",
          description:
          "1. Let the original total be x.\n"
              "2. Add the two fractional shares over their LCM ($commonDen): ${f1.displayPlain}x + ${f2.displayPlain}x = ${usedFmt['plain']}x.\n"
              "3. Subtract from 1 whole to find the fraction left: 1 − ${usedFmt['plain']} = ${leftFmt['plain']} of x.",
          mathLinesLaTeX: step1Lines,
        ));

        steps.add(FractionWordProblemStep(
          title:
          "Step 2: Equate (${leftFmt['plain']})x to ${remGiven.displayPlain} & Solve for x",
          description:
          "Since ${leftFmt['plain']} of the original total equals ${remGiven.displayPlain}, multiply ${remGiven.displayPlain} by $redLeftD and divide by $redLeftN to find the original total x = ${fmt(exactTotalX)}.",
          mathLinesLaTeX: [...step2Lines, ...step3Lines],
        ));
      } else {
        // Sub-Mode 1: Successive Shares — "2nd Fraction OF THE REMAINDER"
        final Map<String, String> rem1Fmt =
        formatRational(remAfter1Num, remAfter1Den);

        final List<String> step1Lines = [
          "\\text{Let the total original amount (whole) be } x.",
          "\\bullet \\text{ 1st Share} = ${f1.improperLaTeX}x",
          "\\bullet \\text{ \\textbf{Remainder after 1st share}} = x - ${f1.improperLaTeX}x = \\mathbf{${rem1Fmt['improperLaTeX']}x}",
          "\\bullet \\text{ 2nd Share } \\left(${f2.improperLaTeX} \\text{ \\textbf{of the remainder}}\\right) = ${f2.improperLaTeX} \\times ${rem1Fmt['improperLaTeX']}x = \\mathbf{${eff2Fmt['improperLaTeX']}x}",
        ];

        final List<String> step2Lines = [
          "\\text{Subtract the 2nd share from the remainder to find the final fraction left:}",
          "\\text{Final Fraction Left} = ${rem1Fmt['improperLaTeX']}x - ${eff2Fmt['improperLaTeX']}x",
          "= \\frac{${remAfter1Num * (commonDen ~/ remAfter1Den)}x - ${scaled2}x}{$commonDen} = \\frac{${leftFracNum}x}{$commonDen} = \\mathbf{${leftFmt['improperLaTeX']}x}",
          "\\text{Equate to the given amount left } (${remGiven.displayLaTeX}):",
          "\\mathbf{\\frac{$redLeftN}{$redLeftD}x = ${remGiven.displayLaTeX}}",
          "${redLeftN}x = ${remGiven.displayLaTeX} \\times $redLeftD = ${fmt(remGiven.value * redLeftD)}",
          "\\therefore \\; \\text{Total Original Whole } (x) = \\frac{${fmt(remGiven.value * redLeftD)}}{$redLeftN} = \\mathbf{${fmt(exactTotalX)}}",
        ];

        final List<String> step3Lines = [
          "\\bullet \\text{ 1st Share } \\left(${f1.improperLaTeX} \\text{ of } ${fmt(exactTotalX)}\\right) = \\mathbf{${fmt(share1Val)}}",
          "\\bullet \\text{ Remainder after 1st share} = ${fmt(exactTotalX)} - ${fmt(share1Val)} = ${fmt(exactTotalX - share1Val)}",
          "\\bullet \\text{ 2nd Share } \\left(${f2.improperLaTeX} \\text{ of } ${fmt(exactTotalX - share1Val)}\\right) = \\mathbf{${fmt(share2Val)}}",
          "\\bullet \\text{ Final Amount Left} = ${fmt(exactTotalX - share1Val)} - ${fmt(share2Val)} = \\mathbf{${remGiven.displayLaTeX}} \\quad (\\text{Verified!})",
        ];

        workings.add(
            "\\text{\\textbf{Step 1: Calculate the Remainder and the 'Of the Remainder' Share}}");
        workings.addAll(step1Lines);
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 2: Find Final Fraction Left and Solve for the Total Whole (}}x\\text{\\textbf{)}}");
        workings.addAll(step2Lines);
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 3: Breakdown of Each Share and Verification}}");
        workings.addAll(step3Lines);

        steps.add(FractionWordProblemStep(
          title:
          "Step 1: Find the First Remainder & Multiply by ${f2.displayPlain} ('Of the Remainder')",
          description:
          "• Crucial Exam Rule: The 2nd share (${f2.displayPlain}) is NOT taken from the original whole x—it is taken OF THE REMAINDER!\n"
              "• After removing ${f1.displayPlain}x, the remainder is 1 − ${f1.displayPlain} = ${rem1Fmt['plain']}x.\n"
              "• Therefore, the 2nd share is ${f2.displayPlain} × ${rem1Fmt['plain']}x = ${eff2Fmt['plain']}x of the original whole.",
          mathLinesLaTeX: step1Lines,
        ));

        steps.add(FractionWordProblemStep(
          title:
          "Step 2: Equate Final Fraction Left (${leftFmt['plain']}x) to ${remGiven.displayPlain} & Solve",
          description:
          "1. Subtract the 2nd share (${eff2Fmt['plain']}x) from the remainder (${rem1Fmt['plain']}x) to get ${leftFmt['plain']}x left.\n"
              "2. Solve (${leftFmt['plain']})x = ${remGiven.displayPlain} to find the original whole x = ${fmt(exactTotalX)}.",
          mathLinesLaTeX: [...step2Lines, ...step3Lines],
        ));
      }

      return FractionWordProblemResult(
        mode: 3,
        subMode: subMode,
        finalAnswers: {
          "Original Total (x)": fmt(exactTotalX),
          "1st Share (${f1.displayPlain})": fmt(share1Val),
          "2nd Share (${eff2Fmt['plain']} of Whole)": fmt(share2Val),
          "Fraction Left (${leftFmt['plain']})": remGiven.displayPlain,
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: FractionWordProblemsCanvasData(
          visualType: 1,
          totalWholeTitle:
          "Total Original Whole:  x = ${fmt(exactTotalX)}  (100%)",
          segments: [
            WholeBarSegment(
              title: "1st Share (${f1.displayPlain})",
              fractionOfWholeText: "${f1.displayPlain}x",
              valueText: fmt(share1Val),
              proportion: f1.value,
              colorIndex: 0,
            ),
            WholeBarSegment(
              title: subMode == 0
                  ? "2nd Share (${f2.displayPlain})"
                  : "2nd (${f2.displayPlain} of Rem = ${eff2Fmt['plain']})",
              fractionOfWholeText: "${eff2Fmt['plain']}x",
              valueText: fmt(share2Val),
              proportion: eff2Num / eff2Den,
              colorIndex: 1,
            ),
            WholeBarSegment(
              title: "Left (${leftFmt['plain']})",
              fractionOfWholeText: "${leftFmt['plain']}x",
              valueText: remGiven.displayPlain,
              proportion: leftFracNum / commonDen,
              colorIndex: 2,
            ),
          ],
          headerBadge:
          "Fractional Shares of a Whole:  (${leftFmt['plain']})x = ${remGiven.displayPlain}   ➔   Total x = ${fmt(exactTotalX)}",
          subBadge:
          "1st Share = ${fmt(share1Val)}   |   2nd Share = ${fmt(share2Val)}   |   Left = ${remGiven.displayPlain}",
          bottomSummaryBanner:
          "Original Total Whole (x) = ${fmt(exactTotalX)}",
        ),
      );
    } catch (e) {
      return FractionWordProblemResult.error(
        mode: 3,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid proper fractions and a positive remaining amount.",
      );
    }
  }
}