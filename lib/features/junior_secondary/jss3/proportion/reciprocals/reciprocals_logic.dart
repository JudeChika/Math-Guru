import 'dart:math' as math;
import 'reciprocals_models.dart';

class ReciprocalsLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 40–43: Examples 6–9, Exercise 3.3 & Exercise 3.4)
  // ===========================================================================
  static const List<ReciprocalsPreset> textbookPresets = [
    ReciprocalsPreset(
      chipLabel: "Example 6a–d (Page 40): Reciprocals of 8, 4.5, 0.6, and 10",
      mode: 0,
      subMode: 0,
      input1: '4.5',
    ),
    ReciprocalsPreset(
      chipLabel: "Example 6c (Page 40): Reciprocal of 0.6 (Fraction & 3 d.p.)",
      mode: 0,
      subMode: 0,
      input1: '0.6',
    ),
    ReciprocalsPreset(
      chipLabel: "Ex 3.3 #1 (Table 3.13): Complete x and 1/x Table",
      mode: 0,
      subMode: 1, // Batch Table 3.13 completion
      input1: '2, 1.2, 2.5, 14, 5, 20, 12, 25, 0.2, 0.25, 0.5',
    ),
    ReciprocalsPreset(
      chipLabel: "Ex 3.3 #2i–l: Reciprocal of 5/6, 3/8, 4/5, 8/9 (to 3 d.p.)",
      mode: 0,
      subMode: 0,
      input1: '5/6',
    ),
    ReciprocalsPreset(
      chipLabel: "Example 9 (Page 42): Reciprocal of 5.348 Using Calculator [1/x]",
      mode: 0,
      subMode: 0,
      input1: '5.348',
    ),
    ReciprocalsPreset(
      chipLabel: "Example 7a–d (Page 40): Given 1/25 = 0.04, find for 2.5, 0.25, 0.025, 2500",
      mode: 1,
      input1: '25',
      input2: '0.04',
      input3: '2.5, 0.25, 0.025, 2500',
    ),
    ReciprocalsPreset(
      chipLabel: "Ex 3.3 #4a–c (Page 42): Given 1/4.21 = 0.2375, find for 0.421, 0.0421, 421",
      mode: 1,
      input1: '4.21',
      input2: '0.2375',
      input3: '0.421, 0.0421, 421',
    ),
    ReciprocalsPreset(
      chipLabel: "Ex 3.3 #5a–d (Page 42): Given 1/5.16 = 0.1938, find for 51.6, 516, 0.516, 0.0516",
      mode: 1,
      input1: '5.16',
      input2: '0.1938',
      input3: '51.6, 516, 0.516, 0.0516',
    ),
    ReciprocalsPreset(
      chipLabel: "Example 8 (Page 41): Long Division Method for Reciprocal of 0.45 (4 s.f.)",
      mode: 2,
      input1: '0.45',
    ),
    ReciprocalsPreset(
      chipLabel: "Ex 3.3 #3a: Long Division Method for Reciprocal of 1.57 (4 s.f.)",
      mode: 2,
      input1: '1.57',
    ),
    ReciprocalsPreset(
      chipLabel: "Ex 3.3 #3c: Long Division Method for Reciprocal of 17 (4 s.f.)",
      mode: 2,
      input1: '17',
    ),
    ReciprocalsPreset(
      chipLabel: "Ex 3.4 #1 (Page 42): Evaluate 14 / 4.7 Using Reciprocals",
      mode: 3,
      subMode: 0, // Evaluate N / D = N * (1 / D)
      input1: '14',
      input2: '4.7',
    ),
    ReciprocalsPreset(
      chipLabel: "Ex 3.4 #3 (Page 42): Evaluate 50 / 0.435 Using Reciprocals",
      mode: 3,
      subMode: 0,
      input1: '50',
      input2: '0.435',
    ),
    ReciprocalsPreset(
      chipLabel: "Ex 3.4 #11a & d (Page 42): Evaluate c / (2π) when c = 37 ½ and π = 3.142",
      mode: 3,
      subMode: 1, // Evaluate c / (2 * pi)
      input1: '37 1/2',
      input2: '3.142',
    ),
    ReciprocalsPreset(
      chipLabel: "Ex 3.4 #12 (Page 42): Mirror Formula 1/f = 1/u + 1/v (u = 6.9, v = 14.7)",
      mode: 3,
      subMode: 2, // Mirror formula 1/f = 1/u + 1/v
      input1: '6.9',
      input2: '14.7',
    ),
    ReciprocalsPreset(
      chipLabel: "Rev Ex 3 #5 (Page 43): Find f given 1/f = 1/4.63 + 1/7.52",
      mode: 3,
      subMode: 2,
      input1: '4.63',
      input2: '7.52',
    ),
  ];

  // ===========================================================================
  // UNIVERSAL RATIONAL, SIGNIFICANT-FIGURE & DECIMAL HELPERS (Math.tex Safe!)
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

  static String fmt(double v, {int maxDecimals = 5}) {
    if (v.abs() < 1e-12) return '0';
    if ((v - v.roundToDouble()).abs() < 1e-12) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// Formats a positive or negative number to `sf` significant figures (matching Page 41–42 rules!)
  static String fmtSF(double v, int sf) {
    if (v.abs() < 1e-12) return '0';
    final bool isNeg = v < 0;
    final double absV = v.abs();
    final int d = (math.log(absV) / math.ln10).floor();
    final int power = sf - 1 - d;
    final String sign = isNeg ? '-' : '';

    if (power >= 0) {
      final double scale = math.pow(10, power).toDouble();
      final double rounded = (absV * scale).roundToDouble() / scale;
      return '$sign${rounded.toStringAsFixed(power)}';
    } else {
      final double scale = math.pow(10, -power).toDouble();
      final double rounded = (absV / scale).roundToDouble() * scale;
      return '$sign${rounded.round()}';
    }
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
        'improperLaTeX': '\\frac{$sign$n}{1}',
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

  /// Parses integers, decimals, fractions ("5/6"), mixed fractions ("37 1/2"), or algebraic powers ("a^2")
  static Map<String, dynamic> parseFlexibleInput(String raw) {
    String s = raw
        .trim()
        .replaceAll('−', '-')
        .replaceAll('½', ' 1/2')
        .replaceAll('¼', ' 1/4')
        .replaceAll('¾', ' 3/4')
        .replaceAll(',', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (s.isEmpty) {
      throw const FormatException(
        "Please enter a number, decimal, fraction (e.g. 4.5, 0.6, 5/6), or algebraic power (e.g. a^2).",
      );
    }

    // Check if algebraic power like "a^2" or "x^3" (Page 40 top right!)
    final RegExp algReg = RegExp(r'^([a-zA-Z])(?:\^(\d+))?$');
    final Match? algM = algReg.firstMatch(s.replaceAll('²', '^2').replaceAll('³', '^3'));
    if (algM != null) {
      final String v = algM.group(1)!;
      final String exp = algM.group(2) ?? '1';
      final String termTex = exp == '1' ? v : '$v^{$exp}';
      return {
        'isAlgebraic': true,
        'termLaTeX': termTex,
        'recipLaTeX': '\\frac{1}{$termTex}',
      };
    }

    if (s.contains('/')) {
      final List<String> parts = s.split(' ');
      if (parts.length == 2) {
        final bool isNeg = parts[0].startsWith('-');
        final int wAbs = int.parse(parts[0].replaceAll('-', '').replaceAll('+', ''));
        final List<String> fp = parts[1].split('/');
        final int fN = int.parse(fp[0]);
        final int fD = int.parse(fp[1]);
        if (fD == 0) throw const FormatException("Denominator cannot be zero.");
        final int impAbs = wAbs * fD + fN;
        final int signedN = isNeg ? -impAbs : impAbs;
        final String sign = isNeg ? '-' : '';
        return {
          'isAlgebraic': false,
          'value': signedN / fD,
          'num': signedN,
          'den': fD,
          'isFractionInput': true,
          'displayLaTeX': '$sign$wAbs\\frac{$fN}{$fD}',
          'improperLaTeX': '$sign\\frac{$impAbs}{$fD}',
        };
      } else {
        final List<String> fp = parts[0].split('/');
        final int fN = int.parse(fp[0]);
        final int fD = int.parse(fp[1]);
        if (fD == 0) throw const FormatException("Denominator cannot be zero.");
        final int signedN = fD < 0 ? -fN : fN;
        final int posD = fD.abs();
        final String sign = signedN < 0 ? '-' : '';
        return {
          'isAlgebraic': false,
          'value': signedN / posD,
          'num': signedN,
          'den': posD,
          'isFractionInput': true,
          'displayLaTeX': '$sign\\frac{${signedN.abs()}}{$posD}',
          'improperLaTeX': '$sign\\frac{${signedN.abs()}}{$posD}',
        };
      }
    }

    final String noSpace = s.replaceAll(' ', '');
    final double? val = double.tryParse(noSpace);
    if (val == null || val.abs() < 1e-12) {
      throw const FormatException(
        "Please enter a non-zero number, decimal, or fraction (0 has no reciprocal!).",
      );
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
    final String sign = redN < 0 ? '-' : '';

    return {
      'isAlgebraic': false,
      'value': val,
      'num': redN,
      'den': redD,
      'rawNum10': scaledNum,
      'rawDen10': scaleDen,
      'isDecimalInput': decPlaces > 0,
      'isFractionInput': false,
      'displayLaTeX': fmt(val),
      'improperLaTeX': redD == 1 ? fmt(val) : '$sign\\frac{${redN.abs()}}{$redD}',
    };
  }

  // ===========================================================================
  // MODE 0: RECIPROCAL OF ANY NUMBER, FRACTION, DECIMAL, POWER & TABLE 3.13
  // Covers Examples 6(a–d), Example 9 (Calculator key) & Exercise 3.3 #1, #2(a–o)
  // ===========================================================================
  static ReciprocalsResult solveSingleOrTableReciprocal({
    required int subMode, // 0: Single Number/Fraction/Decimal/Power, 1: Complete Table 3.13 (Ex 3.3 #1)
    required String inputStr,
  }) {
    try {
      if (subMode == 1) {
        // Sub-Mode 0B: Complete Table 3.13 (Exercise 3.3 #1)
        final List<String> tokens = inputStr
            .split(RegExp(r'[,;]+'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        if (tokens.isEmpty) {
          throw const FormatException(
            "Please enter comma-separated numbers for Table 3.13 (e.g. 2, 1.2, 2.5, 14, 5, 20, 12, 25, 0.2, 0.25, 0.5).",
          );
        }

        final List<String> xCells = [];
        final List<String> fracRecipCells = [];
        final List<String> decRecipCells = [];
        final List<String> stepLinesLaTeX = [];
        final List<String> stepLinesPlain = [];
        final Map<String, String> answersLaTeX = {};

        for (final String tok in tokens) {
          final Map<String, dynamic> p = parseFlexibleInput(tok);
          final double val = p['value'] as double;
          final int n = p['num'] as int;
          final int d = p['den'] as int;
          final Map<String, String> recFmt = formatRational(d, n);
          final double recVal = 1.0 / val;
          final String rec3dp = recVal.toStringAsFixed(3);
          final String rec4sf = fmtSF(recVal, 4);

          xCells.add(p['displayLaTeX'] as String);
          fracRecipCells.add(recFmt['improperLaTeX']!);
          decRecipCells.add(fmt(recVal, maxDecimals: 4));

          stepLinesLaTeX.add(
              "\\bullet \\; x = ${p['displayLaTeX']} \\implies \\frac{1}{x} = \\frac{1}{${p['displayLaTeX']}} = \\mathbf{${recFmt['improperLaTeX']}} = \\mathbf{${fmt(recVal, maxDecimals: 4)}} \\quad (3\\text{ d.p.} = $rec3dp, \\; 4\\text{ s.f.} = $rec4sf)");
          stepLinesPlain.add(
              "• For x = $tok:  1/x = ${recFmt['plain']} = ${fmt(recVal, maxDecimals: 4)}  (3 d.p. = $rec3dp)");
          answersLaTeX["x = $tok"] =
          "\\frac{1}{x} = ${recFmt['improperLaTeX']} = ${fmt(recVal, maxDecimals: 4)}";
        }

        final String colSpec = List.filled(xCells.length + 1, 'c').join('|');
        final String table3_13LaTeX = "\\begin{array}{|$colSpec|} \\hline "
            "\\mathbf{x} & ${xCells.join(' & ')} \\\\ \\hline "
            "\\mathbf{\\frac{1}{x}} \\text{ (Exact)} & ${fracRecipCells.join(' & ')} \\\\ \\hline "
            "\\mathbf{\\frac{1}{x}} \\text{ (Decimal)} & ${decRecipCells.join(' & ')} \\\\ \\hline "
            "\\end{array}";

        final List<String> workings = [
          "\\text{\\textbf{Step 1: Calculate }} \\frac{1}{x} \\text{\\textbf{ for Each Value in Table 3.13 (Exercise 3.3 \\#1)}}",
          ...stepLinesLaTeX,
          "",
          "\\text{\\textbf{Step 2: Completed Table 3.13}}",
          table3_13LaTeX,
        ];

        return ReciprocalsResult(
          mode: 0,
          subMode: 1,
          finalAnswersLaTeX: answersLaTeX,
          workingsLaTeX: workings,
          steps: [
            ReciprocalsStep(
              title:
              "Step 1: Complete Table 3.13 Using the Multiplicative Inverse Rule (x × 1/x = 1)",
              description:
              "The reciprocal of any number x is 1/x (and the reciprocal of 1/x is x):\n\n"
                  "${stepLinesPlain.join('\n')}",
              mathLinesLaTeX: [...stepLinesLaTeX, table3_13LaTeX],
            ),
          ],
          canvasData: ReciprocalsCanvasData(
            visualType: 0,
            headerLaTeX:
            "\\text{Exercise 3.3 \\#1 (Table 3.13): Reciprocals } x \\longleftrightarrow \\frac{1}{x}",
            subHeaderLaTeX:
            "\\text{Multiplicative Identity Rule: } x \\times \\left(\\frac{1}{x}\\right) = 1",
            card1Title: "1st Entry",
            card1LaTeX:
            "x = ${xCells.first} \\implies \\frac{1}{x} = ${decRecipCells.first}",
            card2Title: "Inverse Property",
            card2LaTeX:
            "\\text{If } \\frac{1}{x} = k, \\text{ then } x = \\frac{1}{k}",
            card3Title: "Last Entry",
            card3LaTeX:
            "x = ${xCells.last} \\implies \\frac{1}{x} = ${decRecipCells.last}",
            middleBannerLaTeX:
            "\\text{Reciprocal of } x = \\frac{1}{x} \\qquad | \\qquad x \\times \\frac{1}{x} = 1",
            bottomSummaryLaTeX:
            "\\text{Completed } ${xCells.length} \\text{ Columns of Table 3.13}",
          ),
        );
      }

      // Sub-Mode 0A: Single Number, Decimal, Fraction, or Algebraic Power (Examples 6 & 9, Ex 3.3 #2a–o)
      final Map<String, dynamic> p = parseFlexibleInput(inputStr);
      if (p['isAlgebraic'] == true) {
        final String termTex = p['termLaTeX'] as String;
        final String recTex = p['recipLaTeX'] as String;
        final List<String> algLines = [
          "\\text{Recall (Page 40): When the product of two quantities equals } 1, \\text{ each is the \\textbf{reciprocal (multiplicative inverse)} of the other:}",
          "$termTex \\times \\left($recTex\\right) = 1",
          "\\therefore \\; \\text{The reciprocal of } $termTex = \\mathbf{$recTex}",
        ];
        return ReciprocalsResult(
          mode: 0,
          subMode: 0,
          finalAnswersLaTeX: {
            "Given Term": termTex,
            "Reciprocal": recTex,
            "Identity Check": "$termTex \\times $recTex = 1",
          },
          workingsLaTeX: algLines,
          steps: [
            ReciprocalsStep(
              title: "Step 1: Find the Reciprocal of the Algebraic Power (Page 40)",
              description:
              "The reciprocal of any non-zero quantity is 1 divided by that quantity, because multiplying them gives the multiplicative identity 1.",
              mathLinesLaTeX: algLines,
            ),
          ],
          canvasData: ReciprocalsCanvasData(
            visualType: 0,
            headerLaTeX:
            "\\text{Algebraic Reciprocal (Page 40): } $termTex \\longrightarrow $recTex",
            subHeaderLaTeX:
            "\\text{Multiplicative Inverse Identity: } $termTex \\times $recTex = 1",
            card1Title: "Given Quantity",
            card1LaTeX: termTex,
            card2Title: "Reciprocal (1 / x)",
            card2LaTeX: recTex,
            card3Title: "Product Check",
            card3LaTeX: "$termTex \\times $recTex = 1",
            middleBannerLaTeX: "\\text{The reciprocal of } $termTex = $recTex",
            bottomSummaryLaTeX: "\\text{Reciprocal} = $recTex",
          ),
        );
      }

      final double val = p['value'] as double;
      final int num = p['num'] as int;
      final int den = p['den'] as int;
      final String dispLaTeX = p['displayLaTeX'] as String;
      final String impLaTeX = p['improperLaTeX'] as String;

      // Reciprocal is den / num
      final Map<String, String> recFmt = formatRational(den, num);
      final double recVal = 1.0 / val;
      final String rec3dp = recVal.toStringAsFixed(3); // Exercise 3.3 #2 requirement!
      final String rec4sf = fmtSF(recVal, 4); // Reciprocal table / Example 9 requirement!

      // STEP 1: Multiplicative Inverse Definition & Exact Fraction Conversion (Example 6b & 6c Style!)
      final List<String> step1Lines = [
        "\\text{Definition (Page 40): When the product of two numbers gives } 1 \\text{ (the multiplicative identity), one number is the \\textbf{reciprocal} of the other:}",
        "$dispLaTeX \\times \\left(\\frac{1}{$dispLaTeX}\\right) = 1",
        "\\text{The reciprocal of } $dispLaTeX = \\frac{1}{$dispLaTeX}",
      ];

      if (p['isDecimalInput'] == true) {
        final int rawN10 = p['rawNum10'] as int;
        final int rawD10 = p['rawDen10'] as int;
        step1Lines.add(
            "\\text{Convert decimal } $dispLaTeX \\text{ to a fraction and invert (Example 6b \\& 6c Method):}");
        step1Lines.add(
            "\\frac{1}{$dispLaTeX} = \\frac{1}{\\frac{$rawN10}{$rawD10}} = \\frac{$rawD10}{$rawN10} = \\mathbf{${recFmt['improperLaTeX']}}"
                "${recFmt['latex'] != recFmt['improperLaTeX'] ? ' = \\mathbf{${recFmt['latex']}}' : ''}");
      } else if (p['isFractionInput'] == true) {
        step1Lines.add(
            "\\text{Invert the fraction } $impLaTeX \\text{ (swap numerator and denominator):}");
        step1Lines.add(
            "\\frac{1}{$impLaTeX} = \\mathbf{${recFmt['improperLaTeX']}}"
                "${recFmt['latex'] != recFmt['improperLaTeX'] ? ' = \\mathbf{${recFmt['latex']}}' : ''}");
      }

      // STEP 2: Decimal Evaluation to 3 Decimal Places (Ex 3.3 #2) & 4 Significant Figures (Example 9 Calculator Method)
      final List<String> step2Lines = [
        "\\text{Divide numerator by denominator to express as a decimal:}",
        "\\frac{1}{$dispLaTeX} = ${recFmt['improperLaTeX']} = \\mathbf{${fmt(recVal, maxDecimals: 6)}}",
        "\\bullet \\text{ Rounded to \\textbf{3 decimal places} (Exercise 3.3 \\#2): } \\mathbf{$rec3dp}",
        "\\bullet \\text{ Rounded to \\textbf{4 significant figures} (Example 9 / Four-figure table): } \\mathbf{$rec4sf}",
        "",
        "\\text{\\textbf{Calculator Method (Example 9, Page 42):}}",
        "\\text{Step 1: Press the number } $dispLaTeX",
        "\\text{Step 2: Press the reciprocal key } \\boxed{\\frac{1}{x}}",
        "\\therefore \\; $dispLaTeX \\longrightarrow \\boxed{\\frac{1}{x}} = \\frac{1}{$dispLaTeX} = \\mathbf{$rec4sf} \\text{ (to 4 s.f.)}",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Multiplicative Inverse \\& Exact Fractional Reciprocal (Example 6)}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Step 2: Decimal Form (3 d.p. \\& 4 s.f.) and Calculator }} \\boxed{\\frac{1}{x}} \\text{\\textbf{ Key (Example 9)}}",
        ...step2Lines,
      ];

      final List<ReciprocalsStep> steps = [
        ReciprocalsStep(
          title:
          "Step 1: Find the Exact Fractional Reciprocal (Example 6 Method)",
          description:
          "• Recall from Page 40 that when two numbers multiply to give 1, each number is the multiplicative inverse (reciprocal) of the other.\n"
              "• The reciprocal of $inputStr is 1 divided by $inputStr, which simplifies as an exact fraction to ${recFmt['plain']}.",
          mathLinesLaTeX: step1Lines,
        ),
        ReciprocalsStep(
          title:
          "Step 2: Express to 3 Decimal Places (Ex 3.3 #2) & 4 Significant Figures (Example 9)",
          description:
          "• Dividing the numerator by the denominator gives ${fmt(recVal, maxDecimals: 6)}.\n"
              "• Leaving the answer to 3 decimal places (as required in Exercise 3.3 #2a–o) gives $rec3dp.\n"
              "• Using a four-figure reciprocal table or pressing the [1/x] key on a calculator (Example 9, Page 42) gives $rec4sf (to 4 significant figures).",
          mathLinesLaTeX: step2Lines,
        ),
      ];

      return ReciprocalsResult(
        mode: 0,
        subMode: 0,
        finalAnswersLaTeX: {
          "Given Number (x)": dispLaTeX,
          "Exact Fraction (1/x)": recFmt['latex']!,
          "To 3 Decimal Places (Ex 3.3 #2)": rec3dp,
          "To 4 Significant Figures (Ex 9)": rec4sf,
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: ReciprocalsCanvasData(
          visualType: 0,
          headerLaTeX:
          "\\text{Reciprocal of } $dispLaTeX = \\frac{1}{$dispLaTeX} = ${recFmt['improperLaTeX']} = \\mathbf{$rec4sf}",
          subHeaderLaTeX:
          "\\text{Multiplicative Identity Check: } $dispLaTeX \\times \\left(${recFmt['improperLaTeX']}\\right) = 1",
          card1Title: "Given Number (x)",
          card1LaTeX: dispLaTeX,
          card2Title: "Exact Reciprocal (1/x)",
          card2LaTeX: "\\frac{1}{$dispLaTeX} = ${recFmt['latex']}",
          card3Title: "3 d.p. & 4 s.f.",
          card3LaTeX: "$rec3dp \\text{ (3 d.p.)} \\; | \\; $rec4sf \\text{ (4 s.f.)}",
          middleBannerLaTeX:
          "\\text{Calculator Method (Ex 9): } $dispLaTeX \\longrightarrow \\boxed{\\frac{1}{x}} = \\frac{1}{$dispLaTeX} = $rec4sf",
          bottomSummaryLaTeX:
          "\\frac{1}{$dispLaTeX} = ${recFmt['latex']} = $rec3dp \\text{ (to 3 d.p.)} = $rec4sf \\text{ (to 4 s.f.)}",
        ),
      );
    } catch (e) {
      return ReciprocalsResult.error(
        mode: 0,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid non-zero number, decimal, or fraction.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: SCALING RECIPROCALS BY POWERS OF 10
  // Covers Example 7(a–d) (Page 40–41) & Exercise 3.3 #4(a–c), #5(a–d) (Page 42)
  // "If the reciprocal of 25 is 0.04, find the reciprocal of: a) 2.5  b) 0.25  c) 0.025  d) 2,500"
  // ===========================================================================
  static ReciprocalsResult solveScaledReciprocals({
    required String baseNumberStr, // e.g., 25, 4.21, or 5.16
    required String givenRecipStr, // e.g., 0.04, 0.2375, or 0.1938
    required String targetsCsvStr, // e.g., "2.5, 0.25, 0.025, 2500"
  }) {
    try {
      final double? baseX =
      double.tryParse(baseNumberStr.trim().replaceAll(',', ''));
      if (baseX == null || baseX.abs() < 1e-12) {
        throw const FormatException(
          "Please enter a valid base number (e.g. 25, 4.21, or 5.16).",
        );
      }

      final double givenRecip = double.tryParse(givenRecipStr.trim()) ??
          double.parse(fmtSF(1.0 / baseX, 4));
      final String baseXDisp = fmt(baseX);
      final String givenRecipDisp =
      givenRecipStr.trim().isEmpty ? fmtSF(1.0 / baseX, 4) : givenRecipStr.trim();

      final List<String> targetTokens = targetsCsvStr
          .split(RegExp(r'[,;]+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (targetTokens.isEmpty) {
        throw const FormatException(
          "Please enter at least one target number (e.g. 2.5, 0.25, 0.025, 2500).",
        );
      }

      final List<String> workings = [
        "\\text{\\textbf{Given Base Reciprocal (Example 7 Method, Pages 40–41):}}",
        "\\text{The reciprocal of } $baseXDisp = \\frac{1}{$baseXDisp} = \\mathbf{$givenRecipDisp}",
        "",
      ];
      final List<ReciprocalsStep> steps = [];
      final Map<String, String> answersLaTeX = {
        "Given: 1 / $baseXDisp": givenRecipDisp,
      };

      const List<String> letters = ['a', 'b', 'c', 'd', 'e', 'f'];
      String firstTargetCardLaTeX = "";
      String lastTargetCardLaTeX = "";

      for (int i = 0; i < targetTokens.length; i++) {
        final String tok = targetTokens[i];
        final double? tVal = double.tryParse(tok.replaceAll(',', ''));
        if (tVal == null || tVal.abs() < 1e-12) {
          throw FormatException("Invalid target number '$tok'.");
        }

        final String let = letters[i % letters.length];
        final String tDisp = fmt(tVal, maxDecimals: 6);

        // Determine the power-of-10 relationship between tVal and baseX!
        // Ratio = baseX / tVal (if tVal is smaller than baseX, e.g. 2.5 = 25 / 10, then 1/2.5 = 10 / 25 = (1/25) * 10!)
        // If tVal is larger than baseX (e.g. 2500 = 25 * 100, then 1/2500 = (1/25) * (1/100) = (1/25) * 0.01!)
        final double ratio = baseX / tVal;
        final double log10Ratio = math.log(ratio.abs()) / math.ln10;
        final int pow10 = log10Ratio.round();
        final double scaleFactor = math.pow(10, pow10).toDouble();
        final double finalAns = givenRecip * scaleFactor;
        final String finalAnsStr = fmt(finalAns, maxDecimals: 7);

        final List<String> partLines = [];
        if (pow10 >= 0) {
          final int mult10 = math.pow(10, pow10).round();
          partLines.add(
              "\\textbf{$let) } \\text{The reciprocal of } $tDisp = \\frac{1}{$tDisp} = \\frac{$mult10}{$baseXDisp}");
          partLines.add(
              "= \\frac{1}{$baseXDisp} \\times $mult10");
          partLines.add(
              "= $givenRecipDisp \\times $mult10");
          partLines.add(
              "= \\mathbf{$finalAnsStr}");
        } else {
          final int div10 = math.pow(10, -pow10).round();
          final String decMult = fmt(1.0 / div10, maxDecimals: 6);
          partLines.add(
              "\\textbf{$let) } \\text{The reciprocal of } $tDisp = \\frac{1}{$tDisp} = \\frac{1}{$baseXDisp} \\times \\frac{1}{$div10}");
          partLines.add(
              "= $givenRecipDisp \\times $decMult");
          partLines.add(
              "= \\mathbf{$finalAnsStr}");
        }

        workings.addAll(partLines);
        if (i < targetTokens.length - 1) workings.add("");

        steps.add(ReciprocalsStep(
          title:
          "Part ($let): Find the Reciprocal of $tDisp from 1/$baseXDisp = $givenRecipDisp",
          description: pow10 >= 0
              ? "1. Write the reciprocal of $tDisp as 1/$tDisp.\n"
              "2. Multiply numerator and denominator by ${math.pow(10, pow10).round()} so the denominator becomes $baseXDisp: (${math.pow(10, pow10).round()})/$baseXDisp = (1/$baseXDisp) × ${math.pow(10, pow10).round()}.\n"
              "3. Substitute 1/$baseXDisp = $givenRecipDisp: $givenRecipDisp × ${math.pow(10, pow10).round()} = $finalAnsStr."
              : "1. Write $tDisp as $baseXDisp × ${math.pow(10, -pow10).round()}.\n"
              "2. Then 1/$tDisp = (1/$baseXDisp) × (1/${math.pow(10, -pow10).round()}) = $givenRecipDisp × ${fmt(scaleFactor, maxDecimals: 6)} = $finalAnsStr.",
          mathLinesLaTeX: partLines,
        ));

        answersLaTeX["$let) 1 / $tDisp"] = finalAnsStr;
        if (i == 0) {
          firstTargetCardLaTeX = "\\frac{1}{$tDisp} = \\mathbf{$finalAnsStr}";
        }
        lastTargetCardLaTeX = "\\frac{1}{$tDisp} = \\mathbf{$finalAnsStr}";
      }

      return ReciprocalsResult(
        mode: 1,
        finalAnswersLaTeX: answersLaTeX,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: ReciprocalsCanvasData(
          visualType: 1,
          headerLaTeX:
          "\\text{Example 7 Power-of-10 Reciprocal Scaling: Given } \\frac{1}{$baseXDisp} = $givenRecipDisp",
          subHeaderLaTeX:
          "\\text{Write each target reciprocal in terms of } \\frac{1}{$baseXDisp} \\times 10^n",
          card1Title: "Given Base Reciprocal",
          card1LaTeX: "\\frac{1}{$baseXDisp} = $givenRecipDisp",
          card2Title: "Part (a) Scaled",
          card2LaTeX: firstTargetCardLaTeX,
          card3Title: "Part (${letters[(targetTokens.length - 1) % letters.length]}) Scaled",
          card3LaTeX: lastTargetCardLaTeX,
          middleBannerLaTeX:
          "\\frac{1}{$baseXDisp \\div 10^k} = \\frac{10^k}{$baseXDisp} = \\frac{1}{$baseXDisp} \\times 10^k",
          bottomSummaryLaTeX:
          "\\text{All } ${targetTokens.length} \\text{ Reciprocals Found Using } \\frac{1}{$baseXDisp} = $givenRecipDisp",
        ),
      );
    } catch (e) {
      return ReciprocalsResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid numbers for the base reciprocal and target values.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: RECIPROCAL BY LONG DIVISION METHOD TO 4 SIGNIFICANT FIGURES
  // Covers Example 8 (Page 41: Reciprocal of 0.45) & Exercise 3.3 #3(a–d) (1.57, 1.96, 17, 4.54)
  // ===========================================================================
  static ReciprocalsResult solveLongDivisionReciprocal({
    required String numberStr,
  }) {
    try {
      final String clean = numberStr.trim().replaceAll(',', '');
      final double? val = double.tryParse(clean);
      if (val == null || val <= 0) {
        throw const FormatException(
          "Please enter a positive number or decimal for the long division method (e.g. 0.45, 1.57, 1.96, 17, or 4.54).",
        );
      }

      // Scale numerator (1) and denominator (val) by 10^d so the divisor is a whole number (Example 8: 1 / 0.45 = 100 / 45!)
      int decPlaces = 0;
      if (clean.contains('.')) {
        decPlaces = clean.split('.')[1].length.clamp(0, 5);
      }
      final int scale10 = math.pow(10, decPlaces).round();
      final int intDivisor = (val * scale10).round();
      final int intDividend = scale10;

      final double exactRecip = 1.0 / val;
      final String recip4sf = fmtSF(exactRecip, 4);
      final String recip3dp = exactRecip.toStringAsFixed(3);

      // Simulate step-by-step long division of intDividend by intDivisor to generate 5 digits (so we can round to 4 s.f.!)
      final List<String> divisionStepLinesLaTeX = [];
      final List<String> divisionStepLinesPlain = [];
      final List<String> arrayRowsLaTeX = [];

      int rem = intDividend;
      final StringBuffer quotientBuf = StringBuffer();
      int sigDigitsCount = 0;
      bool decimalPointPlaced = false;

      // Integer part of quotient first
      final int intQuot = rem ~/ intDivisor;
      quotientBuf.write(intQuot);
      if (intQuot > 0) {
        sigDigitsCount += intQuot.toString().length;
        final int prod = intQuot * intDivisor;
        final int nextRem = rem - prod;
        divisionStepLinesLaTeX.add(
            "\\bullet \\text{ Divide } $rem \\text{ by } $intDivisor: \\quad $rem \\div $intDivisor = \\mathbf{$intQuot} \\text{ remainder } $nextRem \\quad ($intQuot \\times $intDivisor = $prod, \\; $rem - $prod = $nextRem)");
        divisionStepLinesPlain.add(
            "• $rem ÷ $intDivisor = $intQuot remainder $nextRem (since $intQuot × $intDivisor = $prod, and $rem − $prod = $nextRem).");
        arrayRowsLaTeX.add("\\underline{$prod}");
        rem = nextRem;
      } else {
        divisionStepLinesLaTeX.add(
            "\\bullet \\text{ Since } $rem < $intDivisor, \\text{ the whole-number part is } \\mathbf{0}. \\text{ Place a decimal point and bring down a } 0:");
        divisionStepLinesPlain.add(
            "• Since $rem < $intDivisor, write 0 before the decimal point and annex a 0 to make ${rem * 10}.");
      }

      int safety = 0;
      while (sigDigitsCount < 5 && rem > 0 && safety < 8) {
        if (!decimalPointPlaced) {
          quotientBuf.write('.');
          decimalPointPlaced = true;
        }
        rem *= 10;
        final int digit = rem ~/ intDivisor;
        final int prod = digit * intDivisor;
        final int nextRem = rem - prod;

        quotientBuf.write(digit);
        if (digit > 0 || sigDigitsCount > 0) {
          sigDigitsCount++;
        }

        arrayRowsLaTeX.add("$rem");
        arrayRowsLaTeX.add("\\underline{$prod}");

        divisionStepLinesLaTeX.add(
            "\\bullet \\text{ Bring down } 0 \\text{ to get } $rem: \\quad $rem \\div $intDivisor = \\mathbf{$digit} \\text{ remainder } $nextRem \\quad ($digit \\times $intDivisor = $prod, \\; $rem - $prod = $nextRem)");
        divisionStepLinesPlain.add(
            "• Bring down 0 to make $rem:  $rem ÷ $intDivisor = $digit (since $digit × $intDivisor = $prod, leaving remainder $rem − $prod = $nextRem).");

        rem = nextRem;
        safety++;
      }

      final String rawQuotientStr =
      rem > 0 ? "${quotientBuf.toString()}\\dots" : quotientBuf.toString();

      // Build Textbook Long-Division Box in LaTeX (matching Example 8 on Page 41!)
      final String longDivBoxLaTeX = "\\begin{array}{r|l} "
          " & \\mathbf{$rawQuotientStr} \\\\ \\hline "
          "$intDivisor & $intDividend.0000 \\\\ "
          "${arrayRowsLaTeX.take(6).map((r) => ' & $r \\\\ ').join('')}"
          " & $rem "
          "\\end{array}";

      final List<String> step1Lines = [
        "\\text{The reciprocal of } ${fmt(val)} = \\frac{1}{${fmt(val)}}",
        if (decPlaces > 0)
          "\\text{Multiply numerator and denominator by } $scale10 \\text{ so the divisor is a whole number (Example 8):}",
        if (decPlaces > 0)
          "\\frac{1}{${fmt(val)}} = \\frac{1 \\times $scale10}{${fmt(val)} \\times $scale10} = \\mathbf{\\frac{$intDividend}{$intDivisor}}",
      ];

      final List<String> step2Lines = [
        longDivBoxLaTeX,
        ...divisionStepLinesLaTeX,
        "\\therefore \\; \\text{Reciprocal of } ${fmt(val)} = \\mathbf{$recip4sf \\text{ (4 sig. fig.)}}",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Set Up the Reciprocal Fraction with a Whole-Number Divisor (Example 8, Page 41)}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Step 2: Perform Step-by-Step Long Division ($intDividend \\div $intDivisor)}}",
        ...step2Lines,
      ];

      final List<ReciprocalsStep> steps = [
        ReciprocalsStep(
          title:
          "Step 1: Express 1 / ${fmt(val)} with a Whole-Number Divisor (Example 8)",
          description: decPlaces > 0
              ? "• Write the reciprocal of ${fmt(val)} as 1 / ${fmt(val)}.\n"
              "• Multiply both numerator and denominator by $scale10 to clear the decimal point in the divisor: 1 / ${fmt(val)} = $intDividend / $intDivisor."
              : "• Write the reciprocal of ${fmt(val)} as the fraction 1 / $intDivisor.",
          mathLinesLaTeX: step1Lines,
        ),
        ReciprocalsStep(
          title:
          "Step 2: Divide $intDividend by $intDivisor Using Long Division & Round to 4 s.f.",
          description:
          "Divide $intDividend.0000 by $intDivisor step-by-step:\n\n"
              "${divisionStepLinesPlain.join('\n')}\n\n"
              "• Rounding to 4 significant figures gives $recip4sf!",
          mathLinesLaTeX: step2Lines,
        ),
      ];

      return ReciprocalsResult(
        mode: 2,
        finalAnswersLaTeX: {
          "Whole-Number Fraction": "\\frac{$intDividend}{$intDivisor}",
          "Reciprocal (4 sig. fig.)": recip4sf,
          "Reciprocal (3 d.p.)": recip3dp,
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: ReciprocalsCanvasData(
          visualType: 1,
          headerLaTeX:
          "\\text{Example 8 Long Division Method: } \\frac{1}{${fmt(val)}} = \\frac{$intDividend}{$intDivisor} = \\mathbf{$recip4sf \\text{ (4 s.f.)}}",
          subHeaderLaTeX:
          "\\text{Clear decimals in divisor } (\\times $scale10) \\text{ then divide } $intDividend \\text{ by } $intDivisor",
          card1Title: "Reciprocal Setup",
          card1LaTeX: "\\frac{1}{${fmt(val)}} = \\frac{$intDividend}{$intDivisor}",
          card2Title: "Long Division Quotient",
          card2LaTeX: "$intDividend \\div $intDivisor = $rawQuotientStr",
          card3Title: "Rounded to 4 s.f.",
          card3LaTeX: "\\mathbf{$recip4sf \\text{ (4 sig. fig.)}}",
          middleBannerLaTeX: longDivBoxLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Reciprocal of } ${fmt(val)} = \\mathbf{$recip4sf \\text{ (4 sig. fig.)}}",
        ),
      );
    } catch (e) {
      return ReciprocalsResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter a valid positive number or decimal.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: EVALUATING DIVISIONS USING RECIPROCALS & MIRROR FORMULA (Exercise 3.4 #1–12)
  // Sub-Modes:
  // 0: Evaluate N / D Using Reciprocals: N / D = N * (1 / D) (Exercise 3.4 #1–10)
  // 1: Evaluate c / (2π) Using Reciprocals (Exercise 3.4 #11a–d)
  // 2: The Mirror Formula: 1/f = 1/u + 1/v (Exercise 3.4 #12 & Revision Exercise 3 #5)
  // ===========================================================================
  static ReciprocalsResult solveApplicationsOfReciprocals({
    required int subMode,
    required String input1Str,
    required String input2Str,
  }) {
    try {
      if (subMode == 0) {
        // Sub-Mode 3A: Evaluate N / D Using Reciprocals (Exercise 3.4 #1–10)
        final Map<String, dynamic> numMap = parseFlexibleInput(input1Str);
        final String denRaw = input2Str.trim();
        final bool denIsPi =
            denRaw.toLowerCase() == 'pi' || denRaw == 'π';
        final double numVal = numMap['value'] as double;
        final double denVal =
        denIsPi ? 3.142 : (parseFlexibleInput(denRaw)['value'] as double);

        final String numDispLaTeX = numMap['displayLaTeX'] as String;
        final String denDispLaTeX =
        denIsPi ? "\\pi \\; (3.142)" : (parseFlexibleInput(denRaw)['displayLaTeX'] as String);
        final String denSymLaTeX =
        denIsPi ? "\\pi" : (parseFlexibleInput(denRaw)['displayLaTeX'] as String);

        final double recipDenExact = 1.0 / denVal;
        final String recipDen4sfStr = fmtSF(recipDenExact, 4);
        final double recipDen4sfVal = double.parse(recipDen4sfStr);

        final double prodUsing4sf = numVal * recipDen4sfVal;
        final double prodExact = numVal * recipDenExact;
        final String final4sf = fmtSF(prodExact, 4);
        final String final3sf = fmtSF(prodExact, 3);

        final List<String> step1Lines = [
          "\\text{Rewrite the division as multiplication by the reciprocal of the denominator:}",
          "\\frac{$numDispLaTeX}{$denSymLaTeX} = $numDispLaTeX \\times \\left(\\frac{1}{$denSymLaTeX}\\right)",
          "\\text{Find the reciprocal of } $denDispLaTeX \\text{ (to 4 significant figures):}",
          "\\frac{1}{$denSymLaTeX} = \\mathbf{$recipDen4sfStr}",
        ];

        final List<String> step2Lines = [
          "\\text{Multiply } $numDispLaTeX \\text{ by the reciprocal } $recipDen4sfStr:",
          "\\frac{$numDispLaTeX}{$denSymLaTeX} = $numDispLaTeX \\times $recipDen4sfStr",
          "= ${fmt(prodUsing4sf, maxDecimals: 5)}",
          "\\bullet \\text{ Rounded to \\textbf{4 significant figures}: } \\mathbf{$final4sf}",
          "\\bullet \\text{ Rounded to \\textbf{3 significant figures}: } \\mathbf{$final3sf}",
        ];

        final List<String> workings = [
          "\\text{\\textbf{Step 1: Rewrite Division Using the Reciprocal of the Denominator (Exercise 3.4)}}",
          ...step1Lines,
          "",
          "\\text{\\textbf{Step 2: Multiply by the Reciprocal and Round}}",
          ...step2Lines,
        ];

        return ReciprocalsResult(
          mode: 3,
          subMode: 0,
          finalAnswersLaTeX: {
            "Given Expression": "\\frac{$numDispLaTeX}{$denSymLaTeX}",
            "Reciprocal (1 / $denSymLaTeX)": recipDen4sfStr,
            "Value (to 4 s.f.)": final4sf,
            "Value (to 3 s.f.)": final3sf,
          },
          workingsLaTeX: workings,
          steps: [
            ReciprocalsStep(
              title:
              "Step 1: Replace Division by $denRaw with Multiplication by Its Reciprocal (1/$denRaw)",
              description:
              "• Instead of dividing $input1Str by $denRaw directly, write it as $input1Str × (1/$denRaw).\n"
                  "• From the reciprocal table / calculator, 1/$denRaw = $recipDen4sfStr (to 4 s.f.).",
              mathLinesLaTeX: step1Lines,
            ),
            ReciprocalsStep(
              title:
              "Step 2: Multiply $input1Str by $recipDen4sfStr",
              description:
              "• Multiply $input1Str × $recipDen4sfStr = ${fmt(prodUsing4sf, maxDecimals: 5)}.\n"
                  "• Rounded to 4 significant figures = $final4sf (or $final3sf to 3 s.f.).",
              mathLinesLaTeX: step2Lines,
            ),
          ],
          canvasData: ReciprocalsCanvasData(
            visualType: 2,
            headerLaTeX:
            "\\text{Exercise 3.4 Division via Reciprocals: } \\frac{$numDispLaTeX}{$denSymLaTeX} = $numDispLaTeX \\times \\frac{1}{$denSymLaTeX}",
            subHeaderLaTeX:
            "\\frac{1}{$denSymLaTeX} = $recipDen4sfStr \\implies $numDispLaTeX \\times $recipDen4sfStr = \\mathbf{$final4sf}",
            card1Title: "Numerator (N)",
            card1LaTeX: numDispLaTeX,
            card2Title: "Reciprocal (1 / D)",
            card2LaTeX: "\\frac{1}{$denSymLaTeX} = $recipDen4sfStr",
            card3Title: "Product N × (1/D)",
            card3LaTeX: "\\mathbf{$final4sf \\text{ (4 s.f.)}}",
            middleBannerLaTeX:
            "\\frac{$numDispLaTeX}{$denSymLaTeX} = $numDispLaTeX \\times \\left(\\frac{1}{$denSymLaTeX}\\right) = $numDispLaTeX \\times $recipDen4sfStr",
            bottomSummaryLaTeX:
            "\\frac{$numDispLaTeX}{$denSymLaTeX} = \\mathbf{$final4sf \\text{ (4 s.f.)}} \\quad (\\text{or } \\mathbf{$final3sf \\text{ to 3 s.f.}})",
          ),
        );
      } else if (subMode == 1) {
        // Sub-Mode 3B: Evaluate c / (2π), given π = 3.142 (Exercise 3.4 #11a–d)
        final Map<String, dynamic> cMap = parseFlexibleInput(input1Str);
        final double cVal = cMap['value'] as double;
        final String cDispLaTeX = cMap['displayLaTeX'] as String;
        final double piVal =
            double.tryParse(input2Str.trim()) ?? 3.142;
        final double twoPi = 2.0 * piVal;
        final double recipTwoPi = 1.0 / twoPi;
        final String recipTwoPi4sf = fmtSF(recipTwoPi, 4);
        final double ansExact = cVal / twoPi;
        final String ans4sf = fmtSF(ansExact, 4);
        final String ans3sf = fmtSF(ansExact, 3);

        final List<String> lines = [
          "\\text{Given formula: } \\frac{c}{2\\pi} \\quad \\text{where } c = $cDispLaTeX \\; (${fmt(cVal)}) \\text{ and } \\pi = ${fmt(piVal)}",
          "\\text{1. Calculate the denominator } 2\\pi:",
          "2\\pi = 2 \\times ${fmt(piVal)} = \\mathbf{${fmt(twoPi)}}",
          "\\text{2. Find the reciprocal of } 2\\pi \\; \\left(\\frac{1}{${fmt(twoPi)}}\\right):",
          "\\frac{1}{2\\pi} = \\frac{1}{${fmt(twoPi)}} = \\mathbf{$recipTwoPi4sf \\text{ (to 4 s.f.)}}",
          "\\text{3. Multiply } c \\text{ by } \\frac{1}{2\\pi}:",
          "\\frac{c}{2\\pi} = $cDispLaTeX \\times \\left(\\frac{1}{2\\pi}\\right) = ${fmt(cVal)} \\times $recipTwoPi4sf",
          "= \\mathbf{$ans4sf \\text{ (to 4 s.f.)}} \\quad (\\text{or } \\mathbf{$ans3sf \\text{ to 3 s.f.}})",
        ];

        return ReciprocalsResult(
          mode: 3,
          subMode: 1,
          finalAnswersLaTeX: {
            "Denominator (2π)": fmt(twoPi),
            "Reciprocal 1/(2π)": recipTwoPi4sf,
            "Value of c/(2π) (4 s.f.)": ans4sf,
            "Value of c/(2π) (3 s.f.)": ans3sf,
          },
          workingsLaTeX: [
            "\\text{\\textbf{Evaluate }} \\frac{c}{2\\pi} \\text{\\textbf{ Using Reciprocals (Exercise 3.4 \\#11)}}",
            ...lines,
          ],
          steps: [
            ReciprocalsStep(
              title:
              "Step 1: Find 2π and Its Reciprocal 1/(2π), Then Multiply by c (Ex 3.4 #11)",
              description:
              "1. Multiply 2 × ${fmt(piVal)} = ${fmt(twoPi)}.\n"
                  "2. Find the reciprocal of ${fmt(twoPi)}: 1/${fmt(twoPi)} = $recipTwoPi4sf.\n"
                  "3. Multiply c (${fmt(cVal)}) by $recipTwoPi4sf to get $ans4sf (4 s.f.) or $ans3sf (3 s.f.).",
              mathLinesLaTeX: lines,
            ),
          ],
          canvasData: ReciprocalsCanvasData(
            visualType: 2,
            headerLaTeX:
            "\\text{Exercise 3.4 \\#11 Circle Radius Formula: } \\frac{c}{2\\pi} = c \\times \\left(\\frac{1}{2\\pi}\\right)",
            subHeaderLaTeX:
            "2\\pi = ${fmt(twoPi)}, \\quad \\frac{1}{2\\pi} = $recipTwoPi4sf \\implies \\frac{c}{2\\pi} = \\mathbf{$ans4sf}",
            card1Title: "Circumference (c)",
            card1LaTeX: "c = $cDispLaTeX",
            card2Title: "Reciprocal 1/(2π)",
            card2LaTeX: "\\frac{1}{${fmt(twoPi)}} = $recipTwoPi4sf",
            card3Title: "Result c / (2π)",
            card3LaTeX: "\\mathbf{$ans4sf \\text{ (4 s.f.)}}",
            middleBannerLaTeX:
            "\\frac{c}{2\\pi} = $cDispLaTeX \\times \\frac{1}{${fmt(twoPi)}} = ${fmt(cVal)} \\times $recipTwoPi4sf",
            bottomSummaryLaTeX:
            "\\frac{c}{2\\pi} = \\mathbf{$ans4sf \\text{ (4 s.f.)}} \\quad (\\mathbf{$ans3sf \\text{ to 3 s.f.}})",
          ),
        );
      } else {
        // Sub-Mode 3C: The Mirror Formula 1/f = 1/u + 1/v (Exercise 3.4 #12 & Revision Exercise 3 #5!)
        final Map<String, dynamic> uMap = parseFlexibleInput(input1Str);
        final Map<String, dynamic> vMap = parseFlexibleInput(input2Str);
        final double uVal = uMap['value'] as double;
        final double vVal = vMap['value'] as double;
        final String uDispLaTeX = uMap['displayLaTeX'] as String;
        final String vDispLaTeX = vMap['displayLaTeX'] as String;

        final double recipUExact = 1.0 / uVal;
        final double recipVExact = 1.0 / vVal;
        final String recipU4sfStr = fmtSF(recipUExact, 4);
        final String recipV4sfStr = fmtSF(recipVExact, 4);

        final double recipU4sf = double.parse(recipU4sfStr);
        final double recipV4sf = double.parse(recipV4sfStr);
        final double sumRecips4sf = recipU4sf + recipV4sf;
        final String sumRecipsStr = fmt(sumRecips4sf, maxDecimals: 5);

        final double fFrom4sf = 1.0 / sumRecips4sf;
        final double fExact = 1.0 / (recipUExact + recipVExact);
        final String f3sf = fmtSF(fExact, 3); // Exercise 3.4 #12 asks for 3 significant figures!
        final String f4sf = fmtSF(fExact, 4);

        final List<String> step1Lines = [
          "\\text{Mirror Formula (Exercise 3.4 \\#12 \\& Revision Exercise 3 \\#5):}",
          "\\mathbf{\\frac{1}{f} = \\frac{1}{u} + \\frac{1}{v}}",
          "\\text{Substitute } u = $uDispLaTeX \\text{ and } v = $vDispLaTeX:",
          "\\frac{1}{f} = \\frac{1}{$uDispLaTeX} + \\frac{1}{$vDispLaTeX}",
          "\\text{Find the reciprocal of } $uDispLaTeX \\text{ and the reciprocal of } $vDispLaTeX \\text{ (to 4 s.f.):}",
          "\\bullet \\; \\frac{1}{$uDispLaTeX} = \\mathbf{$recipU4sfStr}",
          "\\bullet \\; \\frac{1}{$vDispLaTeX} = \\mathbf{$recipV4sfStr}",
        ];

        final List<String> step2Lines = [
          "\\text{Add the two reciprocals together to find } \\frac{1}{f}:",
          "\\frac{1}{f} = $recipU4sfStr + $recipV4sfStr = \\mathbf{$sumRecipsStr}",
          "\\text{Since } \\frac{1}{f} = $sumRecipsStr, \\; f \\text{ is the \\textbf{reciprocal} of } $sumRecipsStr:",
          "f = \\frac{1}{$sumRecipsStr} = ${fmt(fFrom4sf, maxDecimals: 4)}",
          "\\bullet \\text{ Focal length } f \\text{ rounded to \\textbf{3 significant figures} (Ex 3.4 \\#12): } \\mathbf{f = $f3sf\\text{ cm}}",
          "\\bullet \\text{ Focal length } f \\text{ rounded to \\textbf{4 significant figures}: } \\mathbf{f = $f4sf\\text{ cm}}",
        ];

        final List<String> workings = [
          "\\text{\\textbf{Step 1: Substitute }} u \\text{\\textbf{ and }} v \\text{\\textbf{ into the Mirror Formula }} \\frac{1}{f} = \\frac{1}{u} + \\frac{1}{v}",
          ...step1Lines,
          "",
          "\\text{\\textbf{Step 2: Add the Reciprocals and Take the Reciprocal Again to Find }} f",
          ...step2Lines,
        ];

        final List<ReciprocalsStep> steps = [
          ReciprocalsStep(
            title:
            "Step 1: Find 1/u and 1/v Using Reciprocals (Ex 3.4 #12 & Rev Ex 3 #5)",
            description:
            "1. Start with the mirror formula: 1/f = 1/u + 1/v.\n"
                "2. Find the reciprocal of u ($uDispLaTeX): 1/$uDispLaTeX = $recipU4sfStr.\n"
                "3. Find the reciprocal of v ($vDispLaTeX): 1/$vDispLaTeX = $recipV4sfStr.",
            mathLinesLaTeX: step1Lines,
          ),
          ReciprocalsStep(
            title:
            "Step 2: Add 1/u + 1/v, Then Take the Reciprocal to Find f (to 3 s.f.)",
            description:
            "1. Add the two reciprocals: 1/f = $recipU4sfStr + $recipV4sfStr = $sumRecipsStr.\n"
                "2. Crucial Final Step: Because $sumRecipsStr equals 1/f (not f!), take the reciprocal of $sumRecipsStr to find f:\n"
                "   f = 1 / $sumRecipsStr = $f3sf cm (to 3 significant figures).",
            mathLinesLaTeX: step2Lines,
          ),
        ];

        return ReciprocalsResult(
          mode: 3,
          subMode: 2,
          finalAnswersLaTeX: {
            "1 / u": "\\frac{1}{$uDispLaTeX} = $recipU4sfStr",
            "1 / v": "\\frac{1}{$vDispLaTeX} = $recipV4sfStr",
            "Sum (1 / f)": "\\frac{1}{f} = $sumRecipsStr",
            "Focal Length f (3 s.f.)": "f = $f3sf\\text{ cm}",
            "Focal Length f (4 s.f.)": "f = $f4sf\\text{ cm}",
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: ReciprocalsCanvasData(
            visualType: 2,
            headerLaTeX:
            "\\text{Mirror Formula (Ex 3.4 \\#12): } \\frac{1}{f} = \\frac{1}{u} + \\frac{1}{v} \\implies f = \\mathbf{$f3sf\\text{ cm (3 s.f.)}}",
            subHeaderLaTeX:
            "\\frac{1}{f} = \\frac{1}{$uDispLaTeX} + \\frac{1}{$vDispLaTeX} = $recipU4sfStr + $recipV4sfStr = $sumRecipsStr",
            card1Title: "Reciprocal 1 / u",
            card1LaTeX: "\\frac{1}{$uDispLaTeX} = $recipU4sfStr",
            card2Title: "Reciprocal 1 / v",
            card2LaTeX: "\\frac{1}{$vDispLaTeX} = $recipV4sfStr",
            card3Title: "Sum 1 / f",
            card3LaTeX: "\\frac{1}{f} = $sumRecipsStr",
            middleBannerLaTeX:
            "\\frac{1}{f} = $sumRecipsStr \\implies f = \\frac{1}{$sumRecipsStr} = \\mathbf{$f3sf\\text{ cm (to 3 s.f.)}}",
            bottomSummaryLaTeX:
            "\\therefore \\; f = \\mathbf{$f3sf\\text{ cm (3 s.f.)}} \\quad (\\text{or } \\mathbf{$f4sf\\text{ cm to 4 s.f.}})",
          ),
        );
      }
    } catch (e) {
      return ReciprocalsResult.error(
        mode: 3,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid non-zero numbers in all fields.",
      );
    }
  }
}