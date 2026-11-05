import 'dart:math' as math;
import 'simplify_calculations_models.dart';

class SimplifyCalculationsLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 68–70: Example 5a–c, Exercise 7.4 #1–20 & QR #10–15)
  // ===========================================================================
  static const List<SimplifyCalculationsPreset> textbookPresets = [
    SimplifyCalculationsPreset(
      chipLabel: "Example 5a (Page 68): 35 × 38 + 35 × 62",
      mode: 0,
      subMode: 0,
      input1: '35',
      input2: '38',
      input3: '62',
    ),
    SimplifyCalculationsPreset(
      chipLabel: "Example 5b (Page 68): 118 × 107 − 18 × 107",
      mode: 0,
      subMode: 1,
      input1: '107',
      input2: '118',
      input3: '18',
    ),
    SimplifyCalculationsPreset(
      chipLabel: "Example 5c (Page 68): 5/6 × 230 − 5/6 × 14",
      mode: 0,
      subMode: 1,
      input1: '5/6',
      input2: '230',
      input3: '14',
    ),
    SimplifyCalculationsPreset(
      chipLabel: "Ex 7.4 #2 (Page 69): 199 × 19 + 19 (Implicit × 1)",
      mode: 1,
      subMode: 0,
      input1: '19',
      input2: '199',
    ),
    SimplifyCalculationsPreset(
      chipLabel: "Ex 7.4 #5 (Page 69): 3 ¼ × 100 + 3 ¼ × 12",
      mode: 0,
      subMode: 0,
      input1: '3 1/4',
      input2: '100',
      input3: '12',
    ),
    SimplifyCalculationsPreset(
      chipLabel: "Ex 7.4 #8 (Page 69): 2/3 × 100 − 2/3 × 49",
      mode: 0,
      subMode: 1,
      input1: '2/3',
      input2: '100',
      input3: '49',
    ),
    SimplifyCalculationsPreset(
      chipLabel: "Ex 7.4 #10 (Page 69): 31/35 × 82 + 31/35 × 23",
      mode: 0,
      subMode: 0,
      input1: '31/35',
      input2: '82',
      input3: '23',
    ),
    SimplifyCalculationsPreset(
      chipLabel: "Ex 7.4 #12 (Page 69): 25/19 × 61 − 25/19 × 4",
      mode: 0,
      subMode: 1,
      input1: '25/19',
      input2: '61',
      input3: '4',
    ),
    SimplifyCalculationsPreset(
      chipLabel: "Ex 7.4 #14 (Page 69): 67/75 × 125 + 67/75 × 25",
      mode: 0,
      subMode: 0,
      input1: '67/75',
      input2: '125',
      input3: '25',
    ),
    SimplifyCalculationsPreset(
      chipLabel: "Ex 7.4 #15 (Page 69): 1 6/11 × 999/17 + 1 6/11 × 211/17",
      mode: 0,
      subMode: 0,
      input1: '1 6/11',
      input2: '999/17',
      input3: '211/17',
    ),
    SimplifyCalculationsPreset(
      chipLabel: "Ex 7.4 #16 (Page 69): 39 × 139 − 39² (Square Term)",
      mode: 2,
      subMode: 1,
      input1: '39',
      input2: '139',
    ),
    SimplifyCalculationsPreset(
      chipLabel: "Ex 7.4 #20 (Page 69): 11/36 × 102 + 11/36 × 42",
      mode: 0,
      subMode: 0,
      input1: '11/36',
      input2: '102',
      input3: '42',
    ),
    SimplifyCalculationsPreset(
      chipLabel: "QR Roof #10 (Page 70): Peak 100, Left 105, Right 45, Bottom ?",
      mode: 3,
      input1: '100', // Peak
      input2: '105', // Left Wing
      input3: '45', // Right Wing
      input4: '', // Missing Bottom
    ),
    SimplifyCalculationsPreset(
      chipLabel: "QR Roof #11 (Page 70): Peak 49, Left 149, Right −49, Bottom ?",
      mode: 3,
      input1: '49',
      input2: '149',
      input3: '-49',
      input4: '',
    ),
    SimplifyCalculationsPreset(
      chipLabel: "QR Roof #13 (Page 70): Peak 25, Left 145, Right ?, Bottom 625",
      mode: 3,
      input1: '25',
      input2: '145',
      input3: '',
      input4: '625',
    ),
    SimplifyCalculationsPreset(
      chipLabel: "QR Roof #15 (Page 70): Peak ?, Left 116, Right 44, Bottom 520",
      mode: 3,
      input1: '',
      input2: '116',
      input3: '44',
      input4: '520',
    ),
  ];

  // ===========================================================================
  // UNIVERSAL RATIONAL & FRACTION PARSING / FORMATTING ENGINE (Math.tex Safe!)
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
    if (v.abs() < 1e-12) return '0';
    if ((v - v.roundToDouble()).abs() < 1e-12) {
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
    }
    return {
      'plain': '$sign$n/$d',
      'latex': impTex,
      'improperLaTeX': impTex,
    };
  }

  static ParsedCalcTerm parseTerm(
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
        .replaceAll(',', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (s.isEmpty) {
      throw FormatException(
        "Please enter a valid $fieldName (e.g. 35, 5/6, 3 1/4, or 1 6/11).",
      );
    }

    if (s.contains('/')) {
      final List<String> parts = s.split(' ');
      if (parts.length == 2) {
        final bool isNeg = parts[0].startsWith('-');
        final int wAbs =
        int.parse(parts[0].replaceAll('-', '').replaceAll('+', ''));
        final List<String> fp = parts[1].split('/');
        final int fN = int.parse(fp[0]);
        final int fD = int.parse(fp[1]);
        if (fD <= 0) {
          throw const FormatException("Denominator must be greater than zero.");
        }
        final int impAbs = wAbs * fD + fN;
        final int signedN = isNeg ? -impAbs : impAbs;
        final int g = gcd(signedN, fD);
        final int redN = signedN ~/ g;
        final int redD = fD ~/ g;
        final String sign = isNeg ? '-' : '';

        return ParsedCalcTerm(
          rawInput: raw.trim(),
          value: signedN / fD,
          num: redN,
          den: redD,
          isFractionOrMixed: true,
          isMixedInput: true,
          displayPlain: '$sign$wAbs $fN/$fD',
          displayLaTeX: '$sign$wAbs\\frac{$fN}{$fD}',
          improperLaTeX: '$sign\\frac{${redN.abs()}}{$redD}',
        );
      } else {
        final List<String> fp = parts[0].split('/');
        final int fN = int.parse(fp[0]);
        final int fD = int.parse(fp[1]);
        if (fD == 0) {
          throw const FormatException("Denominator cannot be zero.");
        }
        final int signedN = fD < 0 ? -fN : fN;
        final int posD = fD.abs();
        final int g = gcd(signedN, posD);
        final int redN = signedN ~/ g;
        final int redD = posD ~/ g;
        final String sign = redN < 0 ? '-' : '';

        return ParsedCalcTerm(
          rawInput: raw.trim(),
          value: signedN / posD,
          num: redN,
          den: redD,
          isFractionOrMixed: true,
          isMixedInput: false,
          displayPlain: '$sign${redN.abs()}/$redD',
          displayLaTeX: '$sign\\frac{${redN.abs()}}{$redD}',
          improperLaTeX: '$sign\\frac{${redN.abs()}}{$redD}',
        );
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
    final int redN = scaledNum ~/ g;
    final int redD = scaleDen ~/ g;
    final String cleanStr = fmt(val);

    return ParsedCalcTerm(
      rawInput: raw.trim(),
      value: val,
      num: redN,
      den: redD,
      isFractionOrMixed: redD > 1,
      isMixedInput: false,
      displayPlain: cleanStr,
      displayLaTeX: cleanStr,
      improperLaTeX: redD == 1
          ? cleanStr
          : '${redN < 0 ? '-' : ''}\\frac{${redN.abs()}}{$redD}',
    );
  }

  // ===========================================================================
  // MODES 0, 1 & 2: SIMPLIFYING CALCULATIONS BY FACTORISATION
  // Covers Example 5(a–c) (Page 68) and All 20 Questions in Exercise 7.4 (#1–20)
  // ===========================================================================
  static SimplifyCalculationsResult solveFactorisationShortcut({
    required int mode,
    // 0: Standard Two-Product k × a ± k × b = k(a ± b) (Ex 5a–c & Ex 7.4 #1, #3–15, #17–20)
    // 1: Implicit × 1 Term: k × a ± k = k × a ± k × 1 = k(a ± 1) (Ex 7.4 #2: 199 × 19 + 19)
    // 2: Square Term: k × a ± k² = k × a ± k × k = k(a ± k) (Ex 7.4 #16: 39 × 139 − 39²)
    required int subMode, // 0: Addition (+), 1: Subtraction (−)
    required String commonKStr,
    required String termAStr,
    required String termBStr,
  }) {
    try {
      final ParsedCalcTerm k =
      parseTerm(commonKStr, fieldName: 'Common Factor (k)');
      final ParsedCalcTerm a =
      parseTerm(termAStr, fieldName: 'First Multiplied Number (a)');

      final ParsedCalcTerm b = mode == 1
          ? const ParsedCalcTerm(
        rawInput: '1',
        value: 1.0,
        num: 1,
        den: 1,
        displayPlain: '1',
        displayLaTeX: '1',
        improperLaTeX: '1',
      )
          : (mode == 2
          ? k
          : parseTerm(termBStr, fieldName: 'Second Multiplied Number (b)'));

      final bool isAdd = subMode == 0;
      final String opSym = isAdd ? "+" : "-";

      // Compute exact rational sum/difference inside bracket: a ± b
      final int lcmAB = lcm(a.den, b.den);
      final int scaledA = a.num * (lcmAB ~/ a.den);
      final int scaledB = b.num * (lcmAB ~/ b.den);
      final int brkNum = isAdd ? (scaledA + scaledB) : (scaledA - scaledB);
      final Map<String, String> brkFmt = formatRational(brkNum, lcmAB);

      // Final product: k * (a ± b)
      final int finalNum = k.num * brkNum;
      final int finalDen = k.den * lcmAB;
      final Map<String, String> finalFmt = formatRational(finalNum, finalDen);

      String givenExprLaTeX = "";
      String rewriteLineLaTeX = "";
      if (mode == 0) {
        givenExprLaTeX =
        "${k.displayLaTeX} \\times ${a.displayLaTeX} $opSym ${k.displayLaTeX} \\times ${b.displayLaTeX}";
      } else if (mode == 1) {
        givenExprLaTeX =
        "${a.displayLaTeX} \\times ${k.displayLaTeX} $opSym ${k.displayLaTeX}";
        rewriteLineLaTeX =
        "= ${a.displayLaTeX} \\times ${k.displayLaTeX} $opSym 1 \\times ${k.displayLaTeX}";
      } else {
        givenExprLaTeX =
        "${k.displayLaTeX} \\times ${a.displayLaTeX} $opSym ${k.displayLaTeX}^2";
        rewriteLineLaTeX =
        "= ${k.displayLaTeX} \\times ${a.displayLaTeX} $opSym ${k.displayLaTeX} \\times ${k.displayLaTeX}";
      }

      final List<String> step1Lines = [
        "\\text{Given numerical calculation:}",
        "\\mathbf{$givenExprLaTeX}",
        if (rewriteLineLaTeX.isNotEmpty) ...[
          "\\text{Write the second term explicitly as a product with } ${k.displayLaTeX}:",
          rewriteLineLaTeX,
        ],
        "\\text{Take out the common factor } \\mathbf{${k.displayLaTeX}} \\text{ (Example 5, Page 68):}",
        "= ${k.displayLaTeX}\\left(${a.displayLaTeX} $opSym ${b.displayLaTeX}\\right)",
      ];

      // Step 2: Evaluate Inside the Brackets & Multiply by Common Factor k
      final List<String> step2Lines = [];
      if (a.isFractionOrMixed || b.isFractionOrMixed) {
        step2Lines.add(
            "\\text{Evaluate the fractions inside the bracket first:}");
        step2Lines.add(
            "= ${k.displayLaTeX}\\left(\\frac{$scaledA $opSym $scaledB}{$lcmAB}\\right)");
      }
      step2Lines.add(
          "= ${k.displayLaTeX} \\times ${brkFmt['improperLaTeX']}");

      if (k.isMixedInput) {
        step2Lines.add(
            "\\text{Convert mixed number } ${k.displayLaTeX} \\text{ to improper fraction } ${k.improperLaTeX}:");
        step2Lines.add(
            "= ${k.improperLaTeX} \\times ${brkFmt['improperLaTeX']}");
      }

      // Show cross-cancellation if k is a fraction (like 5/6 × 216 = 5 × 36 = 180 in Example 5c, or 17/11 × 1210/17 = 1210/11 = 110 in Ex 7.4 #15!)
      if (k.den > 1 || lcmAB > 1) {
        final int redBrkN = brkNum ~/ gcd(brkNum, lcmAB);
        final int redBrkD = lcmAB ~/ gcd(brkNum, lcmAB);
        if (redBrkD == 1 && redBrkN % k.den == 0) {
          final int quot = redBrkN ~/ k.den;
          step2Lines.add(
              "\\text{Cancel common factor } ${k.den} \\; \\left($redBrkN \\div ${k.den} = $quot\\right):");
          step2Lines.add("= ${k.num} \\times $quot");
        } else {
          step2Lines.add(
              "= \\frac{${k.num} \\times $redBrkN}{${k.den} \\times $redBrkD}");
        }
      }

      step2Lines.add("= \\mathbf{${finalFmt['latex']}}");

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Factor Out the Common Multiplier }} \\mathbf{${k.displayLaTeX}} \\text{\\textbf{ (Example 5, Page 68)}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Step 2: Simplify the Bracket First, Then Multiply}}",
        ...step2Lines,
      ];

      final List<SimplifyCalculationsStep> steps = [
        SimplifyCalculationsStep(
          title:
          "Step 1: Factor Out the Common Multiplier (${k.displayPlain})",
          description:
          "• Instead of multiplying out both products separately, notice that ${k.displayPlain} is a common factor in both terms.\n"
              "• Factoring out ${k.displayPlain} leaves (${a.displayPlain} $opSym ${b.displayPlain}) inside the bracket.",
          mathLinesLaTeX: step1Lines,
        ),
        SimplifyCalculationsStep(
          title:
          "Step 2: Evaluate (${a.displayPlain} $opSym ${b.displayPlain} = ${brkFmt['plain']}) First, Then Multiply by ${k.displayPlain}",
          description:
          "1. Inside the bracket: ${a.displayPlain} $opSym ${b.displayPlain} = ${brkFmt['plain']}.\n"
              "2. Multiply ${k.displayPlain} by ${brkFmt['plain']} to get the final answer: ${finalFmt['plain']}!",
          mathLinesLaTeX: step2Lines,
        ),
      ];

      return SimplifyCalculationsResult(
        mode: mode,
        subMode: subMode,
        finalAnswersLaTeX: {
          "Common Factor (k)": k.displayLaTeX,
          "Inside Bracket (a $opSym b)": brkFmt['latex']!,
          "Factored Expression":
          "${k.displayLaTeX} \\times ${brkFmt['improperLaTeX']}",
          "Simplified Value": "\\mathbf{${finalFmt['latex']}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SimplifyCalculationsCanvasData(
          visualType: 0,
          headerLaTeX:
          "\\text{Example 5 Simplify by Factorisation: } $givenExprLaTeX = \\mathbf{${finalFmt['latex']}}",
          subHeaderLaTeX:
          "= ${k.displayLaTeX}\\left(${a.displayLaTeX} $opSym ${b.displayLaTeX}\\right) = ${k.displayLaTeX} \\times ${brkFmt['improperLaTeX']} = \\mathbf{${finalFmt['latex']}}",
          card1Title: "1. Common Factor",
          card1LaTeX: k.displayLaTeX,
          card2Title: "2. Bracket ($opSym)",
          card2LaTeX:
          "${a.displayLaTeX} $opSym ${b.displayLaTeX} = \\mathbf{${brkFmt['latex']}}",
          card3Title: "3. Final Value",
          card3LaTeX: "\\mathbf{${finalFmt['latex']}}",
          middleBannerLaTeX:
          "$givenExprLaTeX = ${k.displayLaTeX}\\left(${a.displayLaTeX} $opSym ${b.displayLaTeX}\\right) = ${k.displayLaTeX} \\times ${brkFmt['improperLaTeX']}",
          bottomSummaryLaTeX:
          "\\therefore \\; $givenExprLaTeX = \\mathbf{${finalFmt['latex']}}",
        ),
      );
    } catch (e) {
      return SimplifyCalculationsResult.error(
        mode: mode,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid numbers or fractions.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: QUANTITATIVE REASONING ROOF / TRIANGLE PUZZLES (Page 70 #10–15)
  // Sample Rule (Page 70 Top Right):
  //   Peak × (Left Wing + Right Wing) = Bottom Base
  //   Sample 1: 84 × (49 + 53) = 84 × 102 = 8,568
  //   Sample 2: 15 × (181 + (-81)) = 15 × 100 = 1,500
  // ===========================================================================
  static SimplifyCalculationsResult solveQuantitativeRoofPuzzle({
    required String peakStr,
    required String leftWingStr,
    required String rightWingStr,
    required String bottomBaseStr,
  }) {
    try {
      final String pRaw = peakStr.trim().replaceAll('?', '');
      final String lRaw = leftWingStr.trim().replaceAll('?', '');
      final String rRaw = rightWingStr.trim().replaceAll('?', '');
      final String bRaw = bottomBaseStr.trim().replaceAll('?', '');

      final int emptyCount = (pRaw.isEmpty ? 1 : 0) +
          (lRaw.isEmpty ? 1 : 0) +
          (rRaw.isEmpty ? 1 : 0) +
          (bRaw.isEmpty ? 1 : 0);

      if (emptyCount != 1) {
        throw const FormatException(
          "In Quantitative Reasoning Roof mode, enter the 3 known numbers and leave the 1 missing position blank (or type '?').",
        );
      }

      ParsedCalcTerm? P = pRaw.isNotEmpty ? parseTerm(pRaw) : null;
      ParsedCalcTerm? L = lRaw.isNotEmpty ? parseTerm(lRaw) : null;
      ParsedCalcTerm? R = rRaw.isNotEmpty ? parseTerm(rRaw) : null;
      ParsedCalcTerm? B = bRaw.isNotEmpty ? parseTerm(bRaw) : null;

      final List<String> calcLinesLaTeX = [];
      String missingName = "";
      String missingAnsLaTeX = "";

      if (B == null) {
        // Bottom Base is missing (#10 & #11): B = P * (L + R)
        final int lcmLR = lcm(L!.den, R!.den);
        final int sumLRNum =
            L.num * (lcmLR ~/ L.den) + R.num * (lcmLR ~/ R.den);
        final Map<String, String> sumLRFmt = formatRational(sumLRNum, lcmLR);

        final int bNum = P!.num * sumLRNum;
        final int bDen = P.den * lcmLR;
        final Map<String, String> bFmt = formatRational(bNum, bDen);
        B = parseTerm(bFmt['plain']!);
        missingName = "Bottom Base";
        missingAnsLaTeX = bFmt['latex']!;

        calcLinesLaTeX.addAll([
          "\\text{Missing Bottom Base} = \\text{Peak} \\times (\\text{Left Wing} + \\text{Right Wing})",
          "= ${P.displayLaTeX} \\times \\left(${L.displayLaTeX} ${R.value >= 0 ? '+ ${R.displayLaTeX}' : '- ${fmt(R.value.abs())}'} \\right)",
          "= ${P.displayLaTeX} \\times ${sumLRFmt['latex']}",
          "= \\mathbf{$missingAnsLaTeX}",
        ]);
      } else if (P == null) {
        // Peak is missing (#12 & #15): P = B / (L + R)
        final int lcmLR = lcm(L!.den, R!.den);
        final int sumLRNum =
            L.num * (lcmLR ~/ L.den) + R.num * (lcmLR ~/ R.den);
        if (sumLRNum == 0) {
          throw const FormatException("Left Wing + Right Wing cannot equal 0.");
        }
        final Map<String, String> sumLRFmt = formatRational(sumLRNum, lcmLR);

        final int pNum = B.num * lcmLR;
        final int pDen = B.den * sumLRNum;
        final Map<String, String> pFmt = formatRational(pNum, pDen);
        P = parseTerm(pFmt['plain']!);
        missingName = "Top Peak";
        missingAnsLaTeX = pFmt['latex']!;

        calcLinesLaTeX.addAll([
          "\\text{Since } \\text{Peak} \\times (\\text{Left} + \\text{Right}) = \\text{Bottom}:",
          "\\text{Peak} \\times \\left(${L.displayLaTeX} ${R.value >= 0 ? '+ ${R.displayLaTeX}' : '- ${fmt(R.value.abs())}'}\\right) = ${B.displayLaTeX}",
          "\\text{Peak} \\times ${sumLRFmt['latex']} = ${B.displayLaTeX}",
          "\\text{Peak} = \\frac{${B.displayLaTeX}}{${sumLRFmt['improperLaTeX']}} = \\mathbf{$missingAnsLaTeX}",
        ]);
      } else if (R == null) {
        // Right Wing is missing (#13): L + R = B / P => R = (B / P) - L
        final int bpNum = B.num * P.den;
        final int bpDen = B.den * P.num;
        final Map<String, String> bpFmt = formatRational(bpNum, bpDen);

        final int lcmDen = lcm(bpDen, L!.den);
        final int rNum =
            bpNum * (lcmDen ~/ bpDen) - L.num * (lcmDen ~/ L.den);
        final Map<String, String> rFmt = formatRational(rNum, lcmDen);
        R = parseTerm(rFmt['plain']!);
        missingName = "Right Wing";
        missingAnsLaTeX = rFmt['latex']!;

        calcLinesLaTeX.addAll([
          "${P.displayLaTeX} \\times \\left(${L.displayLaTeX} + \\text{Right Wing}\\right) = ${B.displayLaTeX}",
          "\\text{Divide both sides by } ${P.displayLaTeX}:",
          "${L.displayLaTeX} + \\text{Right Wing} = \\frac{${B.displayLaTeX}}{${P.displayLaTeX}} = ${bpFmt['latex']}",
          "\\text{Right Wing} = ${bpFmt['latex']} - ${L.displayLaTeX} = \\mathbf{$missingAnsLaTeX}",
        ]);
      } else {
        // Left Wing is missing (#14): L = (B / P) - R
        final int bpNum = B.num * P.den;
        final int bpDen = B.den * P.num;
        final Map<String, String> bpFmt = formatRational(bpNum, bpDen);

        final int lcmDen = lcm(bpDen, R.den);
        final int lNum =
            bpNum * (lcmDen ~/ bpDen) - R.num * (lcmDen ~/ R.den);
        final Map<String, String> lFmt = formatRational(lNum, lcmDen);
        L = parseTerm(lFmt['plain']!);
        missingName = "Left Wing";
        missingAnsLaTeX = lFmt['latex']!;

        calcLinesLaTeX.addAll([
          "${P.displayLaTeX} \\times \\left(\\text{Left Wing} ${R.value >= 0 ? '+ ${R.displayLaTeX}' : '- ${fmt(R.value.abs())}'}\\right) = ${B.displayLaTeX}",
          "\\text{Divide both sides by } ${P.displayLaTeX}:",
          "\\text{Left Wing} ${R.value >= 0 ? '+ ${R.displayLaTeX}' : '- ${fmt(R.value.abs())}'} = \\frac{${B.displayLaTeX}}{${P.displayLaTeX}} = ${bpFmt['latex']}",
          "\\text{Left Wing} = ${bpFmt['latex']} ${R.value >= 0 ? '- ${R.displayLaTeX}' : '+ ${fmt(R.value.abs())}'} = \\mathbf{$missingAnsLaTeX}",
        ]);
      }

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Quantitative Reasoning Roof Rule (Page 70 Top Right, Samples 1 \\& 2)}}",
        "\\text{Sample 1: } 84 \\times (49 + 53) = 84 \\times 102 = 8\\,568",
        "\\text{Sample 2: } 15 \\times (181 + (-81)) = 15 \\times 100 = 1\\,500",
        "\\text{Rule: } \\mathbf{\\text{Peak} \\times (\\text{Left Wing} + \\text{Right Wing}) = \\text{Bottom Base}}",
        "",
        "\\text{\\textbf{Step 2: Calculate the Missing $missingName}}",
        ...calcLinesLaTeX,
      ];

      return SimplifyCalculationsResult(
        mode: 3,
        finalAnswersLaTeX: {
          "Top Peak": P.displayLaTeX,
          "Left & Right Wings":
          "${L.displayLaTeX} \\text{ and } ${R.displayLaTeX}",
          "Bottom Base": B.displayLaTeX,
          "Missing $missingName (?)": "\\mathbf{$missingAnsLaTeX}",
        },
        workingsLaTeX: workings,
        steps: [
          SimplifyCalculationsStep(
            title:
            "Step 1: Apply the Page 70 Roof Rule — Peak × (Left Wing + Right Wing) = Bottom",
            description:
            "• In the Page 70 Quantitative Reasoning roof diagrams (#10–15), the number at the top peak is the common factor multiplying the sum of the two side wings to produce the bottom base.",
            mathLinesLaTeX: workings,
          ),
        ],
        canvasData: SimplifyCalculationsCanvasData(
          visualType: 1,
          headerLaTeX:
          "\\text{Page 70 Quantitative Reasoning Roof (#10–15): } \\text{Peak} \\times (\\text{Left} + \\text{Right}) = \\text{Bottom}",
          subHeaderLaTeX:
          "${P.displayLaTeX} \\times \\left(${L.displayLaTeX} ${R.value >= 0 ? '+ ${R.displayLaTeX}' : '- ${fmt(R.value.abs())}'}\\right) = \\mathbf{${B.displayLaTeX}}",
          peakLaTeX: P.displayLaTeX,
          leftWingLaTeX: L.displayLaTeX,
          rightWingLaTeX: R.displayLaTeX,
          bottomBaseLaTeX: B.displayLaTeX,
          middleBannerLaTeX:
          "${P.displayLaTeX}\\left(${L.displayLaTeX} ${R.value >= 0 ? '+ ${R.displayLaTeX}' : '- ${fmt(R.value.abs())}'}\\right) = ${B.displayLaTeX} \\implies \\text{Missing $missingName} = \\mathbf{$missingAnsLaTeX}",
          bottomSummaryLaTeX:
          "\\text{Missing $missingName } (?) = \\mathbf{$missingAnsLaTeX}",
        ),
      );
    } catch (e) {
      return SimplifyCalculationsResult.error(
        mode: 3,
        message: e is FormatException
            ? e.message
            : "Please enter valid numbers in 3 of the 4 roof positions.",
      );
    }
  }
}