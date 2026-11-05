import 'dart:math' as math;
import 'direct_proportion_models.dart';

class DirectProportionLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 31–37: Activity 3.1, Examples 1–3 & Exercise 3.1 #1–11)
  // ===========================================================================
  static const List<DirectProportionPreset> textbookPresets = [
    DirectProportionPreset(
      chipLabel: "Activity 3.1 (Table 3.1 & Fig 3.1): 1 packet of tea costs ₦50",
      mode: 1,
      xLabel: 'No. of packets',
      yLabel: 'Cost (N)',
      varX: 'x',
      varY: 'y',
      input1: '1',
      input2: '50',
      tableXValuesCsv: '1, 2, 3, 4, 5, 6',
      extraQueriesCsv: 'x=3',
    ),
    DirectProportionPreset(
      chipLabel: "Example 1 (Table 3.2 & Fig 3.2): 4 people use 20 g baking powder; find for 7",
      mode: 0,
      subMode: 0,
      xLabel: 'people',
      yLabel: 'g',
      varX: 'p',
      varY: 'b',
      input1: '4',
      input2: '20',
      input3: '7',
    ),
    DirectProportionPreset(
      chipLabel: "Example 2 (Table 3.3 & Fig 3.3): Blue & Red Paint (5 l to 2 l; find for 8 l)",
      mode: 1,
      xLabel: 'Blue paint (l)',
      yLabel: 'Red paint (l)',
      varX: 'b',
      varY: 'r',
      input1: '5',
      input2: '2',
      tableXValuesCsv: '5, 10, 15, 20, 25, 30',
      extraQueriesCsv: 'x=8',
    ),
    DirectProportionPreset(
      chipLabel: "Example 3 (Page 35): R varies directly as S² (R=25 when S=4; find S when R=36)",
      mode: 2,
      subMode: 0, // Y ∝ X² (Find X given Y)
      varY: 'R',
      varX: 'S',
      input1: '25', // R1
      input2: '4', // S1
      input3: '36', // Target R2 = 36 -> Find S2
    ),
    DirectProportionPreset(
      chipLabel: "Ex 3.1 #1 (Table 3.4): Car travels 50 km on 2 l (Petrol for 88, 130, 60, 195 km)",
      mode: 1,
      xLabel: 'No. of litres (l)',
      yLabel: 'Distance (km)',
      varX: 'l',
      varY: 'd',
      input1: '2',
      input2: '50',
      tableXValuesCsv: '1, 2, 3, 4, 5, 6, 7, 8',
      extraQueriesCsv: 'y=88, y=130, y=60, y=195',
    ),
    DirectProportionPreset(
      chipLabel: "Ex 3.1 #2 (Table 3.5): 4 l yellow paint to 5 l blue (Find blue for 18 l & 26 l)",
      mode: 1,
      xLabel: 'Yellow paint (l)',
      yLabel: 'Blue paint (l)',
      varX: 'y',
      varY: 'b',
      input1: '4',
      input2: '5',
      tableXValuesCsv: '4, 8, 12, 16, 20, 24, 28, 32, 36, 40',
      extraQueriesCsv: 'x=18, x=26',
    ),
    DirectProportionPreset(
      chipLabel: "Ex 3.1 #3 (Table 3.6): Yewande jogs 4 m/s (Time to run 100 m)",
      mode: 1,
      xLabel: 'Time (s)',
      yLabel: 'Distance (m)',
      varX: 't',
      varY: 'd',
      input1: '1',
      input2: '4',
      tableXValuesCsv: '1, 2, 3, 4, 5, 6, 7, 8, 9, 10',
      extraQueriesCsv: 'y=100',
    ),
    DirectProportionPreset(
      chipLabel: "Ex 3.1 #4 (Table 3.7): Single cupcake costs ₦65 (How many at ₦780?)",
      mode: 1,
      xLabel: 'No. of cupcakes (n)',
      yLabel: 'Cost (N)',
      varX: 'n',
      varY: 'C',
      input1: '1',
      input2: '65',
      tableXValuesCsv: '1, 2, 3, 4, 5, 6, 7, 8',
      extraQueriesCsv: 'y=780',
    ),
    DirectProportionPreset(
      chipLabel: "Ex 3.1 #5: 12 nights camp costs ₦6,720. What will 7 nights cost?",
      mode: 0,
      subMode: 0,
      xLabel: 'nights',
      yLabel: 'N',
      varX: 'n',
      varY: 'C',
      input1: '12',
      input2: '6720',
      input3: '7',
    ),
    DirectProportionPreset(
      chipLabel: "Ex 3.1 #6: 5 pies cost ₦730. How much will 9 pies cost?",
      mode: 0,
      subMode: 0,
      xLabel: 'pies',
      yLabel: 'N',
      varX: 'p',
      varY: 'C',
      input1: '5',
      input2: '730',
      input3: '9',
    ),
    DirectProportionPreset(
      chipLabel: "Ex 3.1 #7: 6 chairs cost ₦16,560. Find the cost of 11 chairs",
      mode: 0,
      subMode: 0,
      xLabel: 'chairs',
      yLabel: 'N',
      varX: 'c',
      varY: 'C',
      input1: '6',
      input2: '16560',
      input3: '11',
    ),
    DirectProportionPreset(
      chipLabel: "Ex 3.1 #8: 450 g of mushrooms cost ₦697.50. Cost of 1 kg (1000 g)?",
      mode: 0,
      subMode: 1, // Convert 1 kg = 1000 g first!
      xLabel: 'g',
      yLabel: 'N',
      varX: 'm',
      varY: 'C',
      input1: '450',
      input2: '697.50',
      input3: '1000',
    ),
    DirectProportionPreset(
      chipLabel: "Ex 3.1 #9: 11 pens cost ₦5,197.50. Find the cost of 6 pens",
      mode: 0,
      subMode: 0,
      xLabel: 'pens',
      yLabel: 'N',
      varX: 'p',
      varY: 'C',
      input1: '11',
      input2: '5197.50',
      input3: '6',
    ),
    DirectProportionPreset(
      chipLabel: "Ex 3.1 #10 (Table 3.8): 5 miles to 8 km (Find km in 45 & 115 miles)",
      mode: 1,
      xLabel: 'Mile (x)',
      yLabel: 'Kilometre (y)',
      varX: 'x',
      varY: 'y',
      input1: '5',
      input2: '8',
      tableXValuesCsv: '5, 10, 15, 20, 25, 30, 35, 40',
      extraQueriesCsv: 'x=45, x=115',
    ),
    DirectProportionPreset(
      chipLabel: "Ex 3.1 #11a: Kelechi biked 21 miles (5 miles = 8 km). How many km?",
      mode: 0,
      subMode: 0,
      xLabel: 'miles',
      yLabel: 'km',
      varX: 'x',
      varY: 'y',
      input1: '5',
      input2: '8',
      input3: '21',
    ),
    DirectProportionPreset(
      chipLabel: "Ex 3.1 #11b: Puncture after 18 ½ km (8 km = 5 miles). How many miles?",
      mode: 0,
      subMode: 0,
      xLabel: 'km',
      yLabel: 'miles',
      varX: 'y',
      varY: 'x',
      input1: '8',
      input2: '5',
      input3: '18 1/2',
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

  static String cleanTexText(String s) {
    return s
        .replaceAll('₦', 'N')
        .replaceAll('\\', '')
        .replaceAll('{', '(')
        .replaceAll('}', ')')
        .replaceAll('\$', '')
        .replaceAll('_', ' ')
        .trim();
  }

  static String displayUnitPlain(String u) {
    final String t = u.trim();
    if (t == 'N' || t == '₦') return '₦';
    return t;
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

  static ParsedQuantity parseQuantity(
      String raw, {
        String fieldName = 'quantity',
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
        "Please enter a valid $fieldName (e.g. 4, 20, 697.50, or 18 1/2).",
      );
    }

    if (s.contains('/')) {
      final List<String> parts = s.split(' ');
      if (parts.length == 2) {
        final int whole = int.parse(parts[0]);
        final List<String> fp = parts[1].split('/');
        final int fNum = int.parse(fp[0]);
        final int fDen = int.parse(fp[1]);
        if (fDen <= 0) {
          throw const FormatException("Denominator must be greater than zero.");
        }
        final int impNum = whole * fDen + fNum;
        final int g = gcd(impNum, fDen);
        final int redN = impNum ~/ g;
        final int redD = fDen ~/ g;

        return ParsedQuantity(
          rawInput: raw.trim(),
          value: impNum / fDen,
          num: redN,
          den: redD,
          isFractionOrMixed: true,
          isMixedInput: true,
          displayPlain: '$whole $fNum/$fDen',
          displayLaTeX: '$whole\\frac{$fNum}{$fDen}',
          improperLaTeX: '\\frac{$redN}{$redD}',
        );
      } else if (parts.length == 1) {
        final List<String> fp = parts[0].split('/');
        final int fNum = int.parse(fp[0]);
        final int fDen = int.parse(fp[1]);
        if (fDen <= 0) {
          throw const FormatException("Denominator must be greater than zero.");
        }
        final int g = gcd(fNum, fDen);
        final int redN = fNum ~/ g;
        final int redD = fDen ~/ g;

        return ParsedQuantity(
          rawInput: raw.trim(),
          value: fNum / fDen,
          num: redN,
          den: redD,
          isFractionOrMixed: true,
          isMixedInput: false,
          displayPlain: '$redN/$redD',
          displayLaTeX: '\\frac{$redN}{$redD}',
          improperLaTeX: '\\frac{$redN}{$redD}',
        );
      }
    }

    final String noSpace = s.replaceAll(' ', '');
    final double? val = double.tryParse(noSpace);
    if (val == null || val <= 0) {
      throw FormatException(
        "Please enter a positive number or fraction for $fieldName.",
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
    final String cleanStr = fmt(val);

    return ParsedQuantity(
      rawInput: raw.trim(),
      value: val,
      num: redN,
      den: redD,
      isFractionOrMixed: redD > 1,
      isMixedInput: false,
      displayPlain: cleanStr,
      displayLaTeX: cleanStr,
      improperLaTeX: redD == 1 ? cleanStr : '\\frac{$redN}{$redD}',
    );
  }

  // ===========================================================================
  // MODE 0: UNITARY METHOD & RATIO METHOD WORD PROBLEMS
  // Covers Example 1 (Page 33) & Exercise 3.1 #5, #6, #7, #8, #9, #11
  // ===========================================================================
  static DirectProportionResult solveUnitaryAndRatioProblem({
    required int subMode, // 0: Standard Unitary/Ratio, 1: With g <-> kg Conversion (Ex 3.1 #8)
    required String x1Str,
    required String y1Str,
    required String x2Str,
    required String xUnitStr,
    required String yUnitStr,
    required String varXStr,
    required String varYStr,
  }) {
    try {
      final ParsedQuantity x1 =
      parseQuantity(x1Str, fieldName: 'Given Quantity 1 (x₁)');
      final ParsedQuantity y1 =
      parseQuantity(y1Str, fieldName: 'Given Value 1 (y₁)');
      final ParsedQuantity x2 =
      parseQuantity(x2Str, fieldName: 'Target Quantity 2 (x₂)');

      final String uxPlain =
      xUnitStr.trim().isEmpty ? 'units' : cleanTexText(xUnitStr);
      final String uyRaw = yUnitStr.trim().isEmpty ? 'N' : yUnitStr.trim();
      final bool isNairaY = uyRaw == 'N' || uyRaw == '₦';
      final String vx = varXStr.trim().isEmpty ? 'x' : varXStr.trim()[0];
      final String vy = varYStr.trim().isEmpty ? 'y' : varYStr.trim()[0];

      // Constant of proportionality k = y1 / x1 (as exact rational kNum / kDen)
      final int kNumRaw = y1.num * x1.den;
      final int kDenRaw = y1.den * x1.num;
      final int gk = gcd(kNumRaw, kDenRaw);
      final int kNum = kNumRaw ~/ gk;
      final int kDen = kDenRaw ~/ gk;
      final Map<String, String> kFmt = formatRational(kNum, kDen);
      final double kVal = y1.value / x1.value;

      // Target result y2 = k * x2 = (kNum * x2.num) / (kDen * x2.den)
      final int y2NumRaw = kNum * x2.num;
      final int y2DenRaw = kDen * x2.den;
      final Map<String, String> y2Fmt = formatRational(y2NumRaw, y2DenRaw);
      final double y2Val = kVal * x2.value;

      String formatWithYUnitPlain(String numStr) =>
          isNairaY ? '₦$numStr' : '$numStr ${displayUnitPlain(uyRaw)}';

      String formatWithYUnitLaTeX(String numTex) =>
          isNairaY
              ? '\\text{N}$numTex'
              : '$numTex\\text{ ${cleanTexText(uyRaw)}}';

      final List<String> workings = [];
      final List<DirectProportionStep> steps = [];

      // Optional Unit Conversion Step (Exercise 3.1 #8: 450 g vs 1 kg = 1,000 g)
      if (subMode == 1 || (uxPlain == 'g' && (x2.value - 1000.0).abs() < 1e-9)) {
        final List<String> convLines = [
          "\\text{Convert } 1\\text{ kg to grams so both masses have the same unit (g):}",
          "1\\text{ kg} = \\mathbf{1\\,000\\text{ g}}",
        ];
        workings.add(
            "\\text{\\textbf{Preliminary Step: Convert Units to Match (Exercise 3.1 \\#8)}}");
        workings.addAll(convLines);
        workings.add("");

        steps.add(DirectProportionStep(
          title: "Step 1: Harmonize Units (1 kg = 1,000 g)",
          description:
          "In Exercise 3.1 #8, the known mass is in grams (${x1.displayPlain} g) while the target mass is 1 kg. Convert 1 kg to 1,000 g first so both quantities use the same unit.",
          mathLinesLaTeX: convLines,
        ));
      }

      // METHOD 1: Unitary Method (Example 1 Style — Find for 1 Unit First!)
      final String unsimpUnitFracLaTeX =
      (x1.den == 1 && y1.den == 1)
          ? "\\frac{${y1.num}}{${x1.num}}"
          : "${y1.improperLaTeX} \\div ${x1.improperLaTeX}";

      final List<String> method1Lines = [
        "${x1.displayLaTeX}\\text{ $uxPlain} = ${formatWithYUnitLaTeX(y1.displayLaTeX)}",
        "\\text{Divide by } ${x1.displayLaTeX} \\text{ to find for } 1\\text{ $uxPlain (Unitary Method):}",
        "1\\text{ $uxPlain} = $unsimpUnitFracLaTeX = ${formatWithYUnitLaTeX(kDen == 1 ? fmt(kVal) : '${kFmt['improperLaTeX']} \\quad (\\text{or } ${fmt(kVal)})')}",
        "\\text{Multiply the value for } 1\\text{ $uxPlain by } ${x2.displayLaTeX}:",
        "\\therefore \\; ${x2.displayLaTeX}\\text{ $uxPlain} = ${kFmt['improperLaTeX']} \\times ${x2.improperLaTeX}",
        if (x2.isMixedInput)
          "= \\frac{$kNum}{$kDen} \\times \\frac{${x2.num}}{${x2.den}} = \\frac{${kNum * x2.num}}{${kDen * x2.den}}",
        "= \\mathbf{${formatWithYUnitLaTeX(y2Fmt['latex']!)}}"
            "${y2Fmt['plain'] != fmt(y2Val) ? ' \\quad \\left(\\text{or } \\mathbf{${formatWithYUnitLaTeX(fmt(y2Val))}}\\right)' : ''}",
      ];

      workings.add(
          "\\text{\\textbf{Method 1: Unitary Method (Find for 1 Unit First — Example 1 Style)}}");
      workings.addAll(method1Lines);
      workings.add("");

      steps.add(DirectProportionStep(
        title:
        "Step ${steps.length + 1}: Method 1 — The Unitary Method (Example 1)",
        description:
        "1. Start with the known relationship: ${x1.displayPlain} $uxPlain corresponds to ${formatWithYUnitPlain(y1.displayPlain)}.\n"
            "2. Divide by ${x1.displayPlain} to find the value for 1 unit (the constant of proportionality k): 1 unit = ${formatWithYUnitPlain(fmt(kVal))} (or ${kFmt['improperPlain']}).\n"
            "3. Multiply by ${x2.displayPlain} to find the value for ${x2.displayPlain} $uxPlain: ${formatWithYUnitPlain(y2Fmt['plain']!)}${y2Fmt['plain'] != fmt(y2Val) ? ' (${formatWithYUnitPlain(fmt(y2Val))})' : ''}.",
        mathLinesLaTeX: method1Lines,
      ));

      // METHOD 2: Direct Proportion Formula (y = kx) & Ratio Equality (y1 : y2 = x1 : x2)
      final String kCoeffLaTeX =
      kDen == 1 ? fmt(kVal) : "\\frac{$kNum}{$kDen}";
      final List<String> method2Lines = [
        "\\text{Since } $vy \\text{ is in direct proportion to } $vx \\; ($vy \\propto $vx):",
        "$vy = k$vx \\qquad \\text{where } k = \\frac{$vy}{$vx} = \\frac{${y1.displayLaTeX}}{${x1.displayLaTeX}} = $kCoeffLaTeX",
        "\\text{Connecting Equation: } \\mathbf{$vy = $kCoeffLaTeX $vx}",
        "\\text{Substitute } $vx = ${x2.displayLaTeX}:",
        "$vy = $kCoeffLaTeX \\times ${x2.improperLaTeX} = \\mathbf{${formatWithYUnitLaTeX(y2Fmt['latex']!)}}",
        "\\text{Ratio Check (Page 31): } ${x1.displayLaTeX} : ${x2.displayLaTeX} = ${y1.displayLaTeX} : ${fmt(y2Val)}",
      ];

      workings.add(
          "\\text{\\textbf{Method 2: Direct Proportion Formula ($vy = k$vx) \\& Ratio Check}}");
      workings.addAll(method2Lines);

      steps.add(DirectProportionStep(
        title:
        "Step ${steps.length + 1}: Method 2 — Direct Proportion Equation ($vy = k$vx) & Ratio Check",
        description:
        "• Because the two quantities increase/decrease at the same rate, they satisfy $vy = k$vx, where k = ${kFmt['plain']} is the constant of proportionality.\n"
            "• Connecting equation: $vy = ${kDen == 1 ? fmt(kVal) : '($kNum/$kDen)'}$vx.\n"
            "• Substituting $vx = ${x2.displayPlain} gives $vy = ${formatWithYUnitPlain(y2Fmt['plain']!)}.",
        mathLinesLaTeX: method2Lines,
      ));

      // Generate points along the line y = kx so the Millimetre Graph Paper shows the straight line through (0,0)!
      final double maxX = math.max(x1.value, x2.value);
      final List<ProportionPlotPoint> graphPts = [
        const ProportionPlotPoint(x: 0, y: 0, label: '(0, 0)'),
        ProportionPlotPoint(
          x: x1.value,
          y: y1.value,
          label: '(${x1.displayPlain}, ${fmt(y1.value)})',
        ),
        ProportionPlotPoint(
          x: x2.value,
          y: y2Val,
          label: '(${x2.displayPlain}, ${fmt(y2Val)})',
        ),
      ];

      final String ansFinalStr = y2Fmt['plain'] != fmt(y2Val)
          ? "${formatWithYUnitPlain(y2Fmt['plain']!)} (or ${formatWithYUnitPlain(fmt(y2Val))})"
          : formatWithYUnitPlain(fmt(y2Val));

      return DirectProportionResult(
        mode: 0,
        subMode: subMode,
        finalAnswers: {
          "Unit Rate (k = $vy/$vx)":
          "${formatWithYUnitPlain(fmt(kVal))} per 1 $uxPlain",
          "Connecting Equation":
          "$vy = ${kDen == 1 ? fmt(kVal) : '($kNum/$kDen)'}$vx",
          "For ${x2.displayPlain} $uxPlain": ansFinalStr,
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: DirectProportionCanvasData(
          visualType: 0,
          xAxisLabel: "$uxPlain ($vx)",
          yAxisLabel: "${displayUnitPlain(uyRaw)} ($vy)",
          equationBanner:
          "$vy = ${kDen == 1 ? fmt(kVal) : '($kNum/$kDen)'}$vx",
          slopeK: kVal,
          points: graphPts,
          traces: [
            ProportionGraphTrace(
              xVal: x2.value,
              yVal: y2Val,
              givenX: true,
              badgeLabel: "(${x2.displayPlain}, ${fmt(y2Val)})",
            ),
          ],
          headerBadge:
          "Direct Proportion:  ${x1.displayPlain} $uxPlain ➔ ${formatWithYUnitPlain(y1.displayPlain)}   |   ${x2.displayPlain} $uxPlain ➔ $ansFinalStr",
          subBadge:
          "Constant of Proportionality k = ${fmt(kVal)}   |   Equation: $vy = ${kDen == 1 ? fmt(kVal) : '($kNum/$kDen)'}$vx   |   Straight Line Through (0, 0)",
          bottomSummaryBanner:
          "Answer for ${x2.displayPlain} $uxPlain = $ansFinalStr   (maxX = ${fmt(maxX)})",
        ),
      );
    } catch (e) {
      return DirectProportionResult.error(
        mode: 0,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers or fractions.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: DIRECT PROPORTION TABLE BUILDER, RATIO VERIFIER & GRAPH READER
  // Covers Activity 3.1, Example 2 (Table 3.3, Fig. 3.3) & Exercise 3.1 #1, #2, #3, #4, #10
  // ===========================================================================
  static List<double> _parseTableXList(String rawCsv, double fallbackBaseX) {
    final String clean = rawCsv.trim();
    if (clean.isEmpty) {
      return [for (int i = 1; i <= 6; i++) fallbackBaseX * i];
    }
    final List<double> vals = [];
    for (final String tok in clean.split(RegExp(r'[,;\s]+'))) {
      if (tok.trim().isEmpty) continue;
      final double? v = double.tryParse(tok.trim());
      if (v != null && v > 0) vals.add(v);
    }
    if (vals.isEmpty) {
      return [for (int i = 1; i <= 6; i++) fallbackBaseX * i];
    }
    return vals;
  }

  static DirectProportionResult solveTableRatioAndGraph({
    required String xLabelStr,
    required String yLabelStr,
    required String varXStr,
    required String varYStr,
    required String knownXStr,
    required String knownYStr,
    required String tableXValuesCsv,
    required String extraQueriesCsv, // e.g., "x=8" or "y=88, y=130, y=60, y=195"
  }) {
    try {
      final ParsedQuantity x0 =
      parseQuantity(knownXStr, fieldName: 'Known x-value');
      final ParsedQuantity y0 =
      parseQuantity(knownYStr, fieldName: 'Known y-value');

      final String xLbl =
      xLabelStr.trim().isEmpty ? 'x' : cleanTexText(xLabelStr);
      final String yLbl =
      yLabelStr.trim().isEmpty ? 'y' : cleanTexText(yLabelStr);
      final String vx = varXStr.trim().isEmpty ? 'x' : varXStr.trim()[0];
      final String vy = varYStr.trim().isEmpty ? 'y' : varYStr.trim()[0];

      // Reduced constant ratio k = y / x = kNum / kDen
      final int kNumRaw = y0.num * x0.den;
      final int kDenRaw = y0.den * x0.num;
      final int gk = gcd(kNumRaw, kDenRaw);
      final int kNum = kNumRaw ~/ gk;
      final int kDen = kDenRaw ~/ gk;
      final double kVal = y0.value / x0.value;

      final List<double> xCols = _parseTableXList(tableXValuesCsv, x0.value);
      final List<String> xColCells = [];
      final List<String> yColCells = [];
      final List<String> ratioFractionsLaTeX = [];
      final List<ProportionPlotPoint> plotPts = [
        const ProportionPlotPoint(x: 0, y: 0, label: '(0, 0)'),
      ];

      for (final double xv in xCols) {
        final double yv = kVal * xv;
        xColCells.add(fmt(xv));
        yColCells.add(fmt(yv));
        plotPts.add(ProportionPlotPoint(
          x: xv,
          y: yv,
          label: '(${fmt(xv)}, ${fmt(yv)})',
        ));
        ratioFractionsLaTeX.add("\\frac{${fmt(yv)}}{${fmt(xv)}}");
      }

      final List<String> workings = [];
      final List<DirectProportionStep> steps = [];

      // STEP 1: Copy and Complete the Table of Values (Tables 3.1 to 3.8 Style)
      final String colSpec = List.filled(xCols.length + 1, 'c').join('|');
      final String tableLaTeX = "\\begin{array}{|$colSpec|} \\hline "
          "\\textbf{$xLbl} & ${xColCells.join(' & ')} \\\\ \\hline "
          "\\textbf{$yLbl} & ${yColCells.join(' & ')} \\\\ \\hline "
          "\\end{array}";

      final String kFracLaTeX =
      kDen == 1 ? "$kNum" : "\\frac{$kNum}{$kDen}";
      final String invKFracLaTeX =
      kNum == 1 ? "$kDen" : "\\frac{$kDen}{$kNum}";

      final List<String> step1Lines = [
        "\\text{Given that when } $vx = ${x0.displayLaTeX}, \\; $vy = ${y0.displayLaTeX}:",
        "\\text{Unit Rate (Constant of Proportionality } k\\text{)} = \\frac{$vy}{$vx} = \\frac{${y0.displayLaTeX}}{${x0.displayLaTeX}} = \\mathbf{$kFracLaTeX}"
            "${kDen > 1 ? ' \\quad (\\text{or } ${fmt(kVal)})' : ''}",
        "\\text{Completed Table of Values:}",
        tableLaTeX,
      ];

      workings.add(
          "\\text{\\textbf{Part (a): Complete the Table of Values (Tables 3.1–3.8 Method)}}");
      workings.addAll(step1Lines);
      workings.add("");

      steps.add(DirectProportionStep(
        title: "Step 1: Part (a) — Find the Unit Rate (k) & Complete the Table",
        description:
        "• For every ${x0.displayPlain} of '$xLbl', there is ${y0.displayPlain} of '$yLbl'.\n"
            "• Therefore, for 1 unit of '$xLbl', there is ${y0.displayPlain} ÷ ${x0.displayPlain} = ${kDen == 1 ? '$kNum' : '$kNum/$kDen (${fmt(kVal)})'} of '$yLbl'.\n"
            "• Multiply each value of $vx in the top row by ${kDen == 1 ? '$kNum' : '$kNum/$kDen'} to complete the bottom row of the table:",
        mathLinesLaTeX: step1Lines,
      ));

      // STEP 2: Work Out the Ratio for Each Pair to Justify Direct Proportion (Example 2a & 2b!)
      final String ratioChainLaTeX =
          "${ratioFractionsLaTeX.join(' = ')} = \\mathbf{\\frac{$kNum}{$kDen}}";
      final List<String> step2Lines = [
        "\\text{Work out the ratio } $vy : $vx \\text{ for each column in the table:}",
        ratioChainLaTeX,
        "\\text{Since the ratio } \\frac{$vy}{$vx} = \\frac{$kNum}{$kDen} \\text{ is \\textbf{constant}, } $vy \\text{ and } $vx \\text{ are in \\textbf{direct proportion}!}",
        "\\text{Graphical Justification (Figures 3.1–3.3): The graph of } $vy \\text{ against } $vx \\text{ is a \\textbf{straight line passing through the origin } (0, 0).}",
      ];

      workings.add(
          "\\text{\\textbf{Part (b) \\& (c): Ratio Justification \\& Straight-Line Graph Through (0, 0)}}");
      workings.addAll(step2Lines);
      workings.add("");

      steps.add(DirectProportionStep(
        title:
        "Step 2: Parts (b) & (c) — Constant Ratio Proof & Straight-Line Graph Justification",
        description:
        "• Ratio Proof (Example 2a & 2b): Dividing each value in the second row by the corresponding value in the first row gives the exact same simplified fraction ($kNum/$kDen) every time! Because the ratio is constant, the two quantities are in direct proportion.\n"
            "• Graph Proof (Example 1 & Figures 3.1–3.3): Plotting the points on millimetre graph paper gives a straight line passing through the origin (0, 0).",
        mathLinesLaTeX: step2Lines,
      ));

      // STEP 3: Write the Connecting Equation (Both y in terms of x AND x in terms of y!)
      final List<String> step3Lines = [
        "\\text{Since } $vy \\propto $vx, \\text{ the equation connecting } $vy \\text{ and } $vx \\text{ is:}",
        "\\mathbf{$vy = $kFracLaTeX $vx}"
            "${kDen > 1 ? ' \\quad (\\text{or } $vy = ${fmt(kVal)}$vx)' : ''}",
        "\\text{In reverse (expressing } $vx \\text{ in terms of } $vy\\text{):}",
        "\\mathbf{$vx = $invKFracLaTeX $vy}",
      ];

      workings.add(
          "\\text{\\textbf{Part (d): Write the Relationship as an Algebraic Equation ($vy = k$vx)}}");
      workings.addAll(step3Lines);

      steps.add(DirectProportionStep(
        title:
        "Step 3: Part (d) — Write the Connecting Equation ($vy = k$vx)",
        description:
        "• Using the constant of proportionality k = ${kDen == 1 ? '$kNum' : '$kNum/$kDen'}, the equation connecting '$yLbl' ($vy) and '$xLbl' ($vx) is $vy = ${kDen == 1 ? '$kNum' : '($kNum/$kDen)'}$vx.\n"
            "• Note: If you make $vx the subject instead, the inverse relationship is $vx = ${kNum == 1 ? '$kDen' : '($kDen/$kNum)'}$vy.",
        mathLinesLaTeX: step3Lines,
      ));

      // STEP 4: Evaluate Follow-Up Sub-Questions (Part e / f: i, ii, iii, iv) & Add Graph Traces!
      final List<ProportionGraphTrace> traces = [];
      final Map<String, String> answers = {
        "Constant Ratio ($vy : $vx)": "$kNum : $kDen (k = ${fmt(kVal)})",
        "Connecting Equation":
        "$vy = ${kDen == 1 ? '$kNum' : '($kNum/$kDen)'}$vx",
        "Is Graph a Straight Line?": "Yes, through (0, 0)",
      };

      if (extraQueriesCsv.trim().isNotEmpty) {
        final List<String> qTokens = extraQueriesCsv
            .split(RegExp(r'[,;]+'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        final List<String> queryLinesLaTeX = [];
        final List<String> queryLinesPlain = [];
        const List<String> romanNumerals = ['i', 'ii', 'iii', 'iv', 'v', 'vi'];

        for (int qIdx = 0; qIdx < qTokens.length; qIdx++) {
          final String tok = qTokens[qIdx];
          final String rom =
          qIdx < romanNumerals.length ? "${romanNumerals[qIdx]}) " : "• ";

          final bool isGivenY = tok.toLowerCase().startsWith('y=') ||
              tok.toLowerCase().startsWith('${vy.toLowerCase()}=');
          final String numPart = tok.contains('=')
              ? tok.split('=').last.trim()
              : tok.trim();
          final ParsedQuantity qVal =
          parseQuantity(numPart, fieldName: 'Query Value');

          if (!isGivenY) {
            // Given x -> Find y = (kNum / kDen) * x
            final int ansN = kNum * qVal.num;
            final int ansD = kDen * qVal.den;
            final Map<String, String> ansFmt = formatRational(ansN, ansD);
            final double ansDec = kVal * qVal.value;

            queryLinesLaTeX.add(
                "\\text{$rom When } $vx = ${qVal.displayLaTeX}: \\quad $vy = $kFracLaTeX \\times ${qVal.improperLaTeX} = \\frac{$ansN}{$ansD} = \\mathbf{${ansFmt['latex']}}"
                    "${ansFmt['plain'] != fmt(ansDec) ? ' \\; (\\mathbf{${fmt(ansDec)}})' : ''}");
            queryLinesPlain.add(
                "$rom When $vx = ${qVal.displayPlain}:  $vy = (${kDen == 1 ? '$kNum' : '$kNum/$kDen'}) × ${qVal.displayPlain} = ${ansFmt['plain']} (or ${fmt(ansDec)}).");
            answers["${romanNumerals[qIdx % romanNumerals.length]}) When $vx = ${qVal.displayPlain}"] =
            ansFmt['plain'] != fmt(ansDec)
                ? "${ansFmt['plain']} (${fmt(ansDec)})"
                : fmt(ansDec);

            traces.add(ProportionGraphTrace(
              xVal: qVal.value,
              yVal: ansDec,
              givenX: true,
              badgeLabel: "(${qVal.displayPlain}, ${fmt(ansDec)})",
            ));
          } else {
            // Given y -> Find x = (kDen / kNum) * y
            final int ansN = kDen * qVal.num;
            final int ansD = kNum * qVal.den;
            final Map<String, String> ansFmt = formatRational(ansN, ansD);
            final double ansDec = qVal.value / kVal;

            queryLinesLaTeX.add(
                "\\text{$rom When } $vy = ${qVal.displayLaTeX}: \\quad $vx = $invKFracLaTeX \\times ${qVal.improperLaTeX} = \\frac{$ansN}{$ansD} = \\mathbf{${ansFmt['latex']}}"
                    "${ansFmt['plain'] != fmt(ansDec) ? ' \\; (\\mathbf{${fmt(ansDec)}})' : ''}");
            queryLinesPlain.add(
                "$rom When $vy = ${qVal.displayPlain}:  $vx = ${qVal.displayPlain} ÷ ${fmt(kVal)} = ${ansFmt['plain']} (or ${fmt(ansDec)}).");
            answers["${romanNumerals[qIdx % romanNumerals.length]}) When $vy = ${qVal.displayPlain}"] =
            ansFmt['plain'] != fmt(ansDec)
                ? "${ansFmt['plain']} (${fmt(ansDec)})"
                : fmt(ansDec);

            traces.add(ProportionGraphTrace(
              xVal: ansDec,
              yVal: qVal.value,
              givenX: false,
              badgeLabel: "(${fmt(ansDec)}, ${qVal.displayPlain})",
            ));
          }
        }

        if (queryLinesLaTeX.isNotEmpty) {
          workings.add("");
          workings.add(
              "\\text{\\textbf{Part (e): Calculate Required Values Using the Formula \\& Graph}}");
          workings.addAll(queryLinesLaTeX);

          steps.add(DirectProportionStep(
            title:
            "Step 4: Part (e) — Calculate Required Values from the Equation & Graph (Dotted Lines)",
            description:
            "Using the connecting equation (and tracing the dotted lines on the graph as in Figure 3.3):\n"
                "${queryLinesPlain.join('\n')}",
            mathLinesLaTeX: queryLinesLaTeX,
          ));
        }
      }

      return DirectProportionResult(
        mode: 1,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: DirectProportionCanvasData(
          visualType: 0,
          xAxisLabel: xLbl,
          yAxisLabel: yLbl,
          equationBanner:
          "$vy = ${kDen == 1 ? '$kNum' : '($kNum/$kDen)'}$vx",
          slopeK: kVal,
          points: plotPts,
          traces: traces,
          headerBadge:
          "Direct Proportion Table & Graph:   $vy = ${kDen == 1 ? '$kNum' : '($kNum/$kDen)'}$vx",
          subBadge:
          "Constant Ratio = $kNum : $kDen   |   Straight Line Through (0, 0)   |   Dotted Lines = Graph Readings",
          bottomSummaryBanner:
          "Connecting Equation:  $vy = ${kDen == 1 ? '$kNum' : '($kNum/$kDen)'}$vx   (or $vx = ${kNum == 1 ? '$kDen' : '($kDen/$kNum)'}$vy)",
        ),
      );
    } catch (e) {
      return DirectProportionResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid numbers for the table and queries.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: NON-LINEAR DIRECT VARIATION (Y ∝ X², Y ∝ X³, Y ∝ √X) — EXAMPLE 3
  // Specifically covers Example 3 on Page 35:
  // "The resistance R newtons to the motion of a car varies directly as the square of the speed S.
  //  a) Write the equation connecting R and S.
  //  b) Given that R = 25 N and S = 4, find S given that R = 36."
  // ===========================================================================
  static DirectProportionResult solvePowerDirectVariation({
    required int subMode,
    // 0: Y varies directly as X² (Find X₂ given Y₂ — Example 3!)
    // 1: Y varies directly as X² (Find Y₂ given X₂)
    // 2: Y varies directly as X³ (Cube of X)
    // 3: Y varies directly as √X (Square root of X)
    required String varYStr,
    required String varXStr,
    required String givenY1Str,
    required String givenX1Str,
    required String targetInputStr,
  }) {
    try {
      final String Y = varYStr.trim().isEmpty ? 'R' : varYStr.trim()[0];
      final String X = varXStr.trim().isEmpty ? 'S' : varXStr.trim()[0];

      final ParsedQuantity y1 =
      parseQuantity(givenY1Str, fieldName: 'Initial Value $Y₁');
      final ParsedQuantity x1 =
      parseQuantity(givenX1Str, fieldName: 'Initial Value $X₁');
      final ParsedQuantity target =
      parseQuantity(targetInputStr, fieldName: 'Target Value');

      final List<String> workings = [];
      final List<DirectProportionStep> steps = [];
      final Map<String, String> answers = {};

      if (subMode == 0 || subMode == 1) {
        // Y varies directly as the SQUARE of X: Y ∝ X² => Y = kX² (Example 3!)
        final int x1SqNum = x1.num * x1.num;
        final int x1SqDen = x1.den * x1.den;

        // k = y1 / x1² = (y1.num * x1SqDen) / (y1.den * x1SqNum)
        final int kNumRaw = y1.num * x1SqDen;
        final int kDenRaw = y1.den * x1SqNum;
        final int gk = gcd(kNumRaw, kDenRaw);
        final int kNum = kNumRaw ~/ gk;
        final int kDen = kDenRaw ~/ gk;
        final double kVal = kNum / kDen;
        final String kLaTeX =
        kDen == 1 ? "$kNum" : "\\frac{$kNum}{$kDen}";
        final String kPlain = kDen == 1 ? "$kNum" : "$kNum/$kDen";

        // STEP 1 (Part a & Finding k — Exact Example 3 Page 35 Layout!)
        final List<String> step1Lines = [
          "$Y \\propto $X^2 \\quad \\therefore \\; \\mathbf{$Y = k$X^2} \\quad (k \\text{ is a constant.})",
          "\\text{Given that } $Y = ${y1.displayLaTeX} \\text{ when } $X = ${x1.displayLaTeX}:",
          "${y1.displayLaTeX} = k \\times ${x1.displayLaTeX}^2",
          "${y1.displayLaTeX} = ${fmt(x1.value * x1.value)}k",
          "k = $kLaTeX",
          "\\therefore \\; \\mathbf{$Y = $kLaTeX $X^2}",
        ];

        workings.add(
            "\\text{\\textbf{Part (a) \\& Finding Constant }} k \\text{\\textbf{ (Example 3 Method, Page 35)}}");
        workings.addAll(step1Lines);
        workings.add("");

        steps.add(DirectProportionStep(
          title:
          "Step 1: Write the Variation Equation ($Y = k$X²) & Find the Constant k (Example 3)",
          description:
          "1. '$Y varies directly as the square of $X' is written mathematically as $Y ∝ $X², so $Y = k$X² where k is the constant of proportionality.\n"
              "2. Substitute $Y = ${y1.displayPlain} and $X = ${x1.displayPlain}: ${y1.displayPlain} = k × ${x1.displayPlain}² = ${fmt(x1.value * x1.value)}k.\n"
              "3. Divide by ${fmt(x1.value * x1.value)} to get k = $kPlain.\n"
              "4. Therefore, the connecting formula is $Y = ${kDen == 1 ? kPlain : '($kPlain)'}$X².",
          mathLinesLaTeX: step1Lines,
        ));

        answers["a) General Variation"] = "$Y = k$X²";
        answers["Constant (k)"] = kPlain;
        answers["Formula Connecting $Y & $X"] =
        "$Y = ${kDen == 1 ? kPlain : '($kPlain)'}$X²";

        if (subMode == 0) {
          // Given Y2 (e.g. R = 36), find X2 (e.g. S) using the Textbook Factored Square-Root Method!
          final int y2N = target.num;
          final int y2D = target.den;

          // S² = (y2 * kDen) / kNum
          final int sSqNum = y2N * kDen;
          final int sSqDen = y2D * kNum;
          final int rNum = math.sqrt(sSqNum).round();
          final int rDen = math.sqrt(sSqDen).round();
          final bool isExactSquare =
              (rNum * rNum == sSqNum) && (rDen * rDen == sSqDen);

          final int rootY2 = math.sqrt(y2N).round();
          final int rootKDen = math.sqrt(kDen).round();
          final int rootKNum = math.sqrt(kNum).round();
          final bool canFactorSquareRoot = (y2D == 1) &&
              (rootY2 * rootY2 == y2N) &&
              (rootKDen * rootKDen == kDen) &&
              (rootKNum * rootKNum == kNum);

          final Map<String, String> sFmt = formatRational(rNum, rDen);
          final double exactS = math.sqrt(target.value / kVal);

          final List<String> step2Lines = [
            "\\text{Given that } $Y = ${target.displayLaTeX}:",
            "${target.displayLaTeX} = $kLaTeX $X^2",
            if (kDen > 1)
              "${target.displayLaTeX} \\times $kDen = $kNum $X^2",
            if (y2D == 1 && kDen > 1)
              "\\frac{${target.displayLaTeX} \\times $kDen}{$kNum} = $X^2"
            else
              "$X^2 = \\frac{$sSqNum}{$sSqDen}",
            if (canFactorSquareRoot && kDen > 1) ...[
              "\\text{Take the square root of each factor directly (Example 3 Shortcut!):}",
              "\\therefore \\; $X = \\sqrt{\\frac{$y2N \\times $kDen}{$kNum}} = \\frac{$rootY2 \\times $rootKDen}{$rootKNum}",
              "= \\frac{$rNum}{$rDen}",
              "= \\mathbf{${sFmt['latex']}} \\quad \\left(\\text{or } \\mathbf{${fmt(exactS)}}\\right)",
            ] else if (isExactSquare) ...[
              "\\therefore \\; $X = \\sqrt{\\frac{$sSqNum}{$sSqDen}} = \\frac{$rNum}{$rDen} = \\mathbf{${sFmt['latex']}} \\quad \\left(\\text{or } \\mathbf{${fmt(exactS)}}\\right)",
            ] else ...[
              "\\therefore \\; $X = \\sqrt{${fmt(target.value / kVal)}} \\approx \\mathbf{${fmt(exactS)}}",
            ],
          ];

          workings.add(
              "\\text{\\textbf{Part (b): Find }} $X \\text{\\textbf{ Given That }} $Y = ${target.displayLaTeX} \\text{\\textbf{ (Page 35 Top)}}");
          workings.addAll(step2Lines);

          steps.add(DirectProportionStep(
            title:
            "Step 2: Substitute $Y = ${target.displayPlain} and Solve for $X Using Square Roots",
            description: canFactorSquareRoot
                ? "1. Substitute $Y = ${target.displayPlain} into $Y = ($kPlain)$X²: ${target.displayPlain} = ($kNum/$kDen)$X².\n"
                "2. Multiply by $kDen and divide by $kNum: $X² = ($y2N × $kDen) / $kNum.\n"
                "3. Textbook Factor Trick (Page 35): Instead of multiplying $y2N × $kDen first, take the square root of each perfect square directly: √$y2N = $rootY2, √$kDen = $rootKDen, and √$kNum = $rootKNum!\n"
                "4. Thus $X = ($rootY2 × $rootKDen) / $rootKNum = $rNum/$rDen = ${sFmt['plain']} (or ${fmt(exactS)})."
                : "Isolate $X² and take the positive square root of both sides to find $X = ${isExactSquare ? '${sFmt['plain']} (${fmt(exactS)})' : fmt(exactS)}.",
            mathLinesLaTeX: step2Lines,
          ));

          answers["b) Value of $X (when $Y = ${target.displayPlain})"] =
          isExactSquare
              ? "${sFmt['plain']} (or ${fmt(exactS)})"
              : fmt(exactS);

          return DirectProportionResult(
            mode: 2,
            subMode: 0,
            finalAnswers: answers,
            workingsLaTeX: workings,
            steps: steps,
            canvasData: DirectProportionCanvasData(
              visualType: 1,
              xAxisLabel: X,
              yAxisLabel: Y,
              equationBanner: "$Y = ($kPlain)$X²",
              slopeK: kVal,
              powerN: 2,
              points: [
                const ProportionPlotPoint(x: 0, y: 0, label: '(0, 0)'),
                ProportionPlotPoint(
                  x: x1.value,
                  y: y1.value,
                  label: '(${x1.displayPlain}, ${y1.displayPlain})',
                ),
                ProportionPlotPoint(
                  x: exactS,
                  y: target.value,
                  label: '(${fmt(exactS)}, ${target.displayPlain})',
                ),
              ],
              headerBadge:
              "Example 3 Square Variation ($Y ∝ $X²):   $Y = ($kPlain)$X²",
              subBadge:
              "When $Y = ${target.displayPlain}:   $X² = ($y2N × $kDen)/$kNum   ➔   $X = ${isExactSquare ? sFmt['plain'] : fmt(exactS)}",
              bottomSummaryBanner:
              "When $Y = ${target.displayPlain},   $X = ${isExactSquare ? '${sFmt['plain']} (or ${fmt(exactS)})' : fmt(exactS)}",
            ),
          );
        } else {
          // Sub-Mode 1: Given X2, find Y2 = k * X2²
          final int x2SqNum = target.num * target.num;
          final int x2SqDen = target.den * target.den;
          final int ansNum = kNum * x2SqNum;
          final int ansDen = kDen * x2SqDen;
          final Map<String, String> ansFmt = formatRational(ansNum, ansDen);
          final double ansDec = kVal * target.value * target.value;

          final List<String> step2Lines = [
            "\\text{Substitute } $X = ${target.displayLaTeX} \\text{ into } $Y = $kLaTeX $X^2:",
            "$Y = $kLaTeX \\times \\left(${target.improperLaTeX}\\right)^2",
            "$Y = $kLaTeX \\times \\frac{$x2SqNum}{$x2SqDen} = \\mathbf{${ansFmt['latex']}}"
                "${ansFmt['plain'] != fmt(ansDec) ? ' \\quad (\\mathbf{${fmt(ansDec)}})' : ''}",
          ];

          workings.add(
              "\\text{\\textbf{Part (b): Find }} $Y \\text{\\textbf{ When }} $X = ${target.displayLaTeX}");
          workings.addAll(step2Lines);

          steps.add(DirectProportionStep(
            title: "Step 2: Substitute $X = ${target.displayPlain} into $Y = ($kPlain)$X²",
            description:
            "Square ${target.displayPlain} (${target.displayPlain}² = ${fmt(target.value * target.value)}) and multiply by k = $kPlain to get $Y = ${ansFmt['plain']}.",
            mathLinesLaTeX: step2Lines,
          ));

          answers["b) Value of $Y (when $X = ${target.displayPlain})"] =
          ansFmt['plain']!;

          return DirectProportionResult(
            mode: 2,
            subMode: 1,
            finalAnswers: answers,
            workingsLaTeX: workings,
            steps: steps,
            canvasData: DirectProportionCanvasData(
              visualType: 1,
              xAxisLabel: X,
              yAxisLabel: Y,
              equationBanner: "$Y = ($kPlain)$X²",
              slopeK: kVal,
              powerN: 2,
              points: [
                const ProportionPlotPoint(x: 0, y: 0, label: '(0, 0)'),
                ProportionPlotPoint(
                  x: x1.value,
                  y: y1.value,
                  label: '(${x1.displayPlain}, ${y1.displayPlain})',
                ),
                ProportionPlotPoint(
                  x: target.value,
                  y: ansDec,
                  label: '(${target.displayPlain}, ${fmt(ansDec)})',
                ),
              ],
              headerBadge: "Square Variation ($Y = ($kPlain)$X²)",
              subBadge:
              "When $X = ${target.displayPlain},  $Y = ${ansFmt['plain']}",
              bottomSummaryBanner:
              "When $X = ${target.displayPlain},   $Y = ${ansFmt['plain']}",
            ),
          );
        }
      } else {
        // Sub-Mode 2 (Cube: Y = kX³) or Sub-Mode 3 (Square Root: Y = k√X)
        final bool isCube = subMode == 2;
        final double fnX1 = isCube
            ? (x1.value * x1.value * x1.value)
            : math.sqrt(x1.value);
        final double kVal = y1.value / fnX1;
        final double fnX2 = isCube
            ? (target.value * target.value * target.value)
            : math.sqrt(target.value);
        final double y2Val = kVal * fnX2;

        final String powerExpr = isCube ? "$X^3" : "\\sqrt{$X}";
        final String powerPlain = isCube ? "$X³" : "√$X";

        final List<String> lines = [
          "$Y \\propto $powerExpr \\implies \\mathbf{$Y = k$powerExpr}",
          "\\text{When } $Y = ${y1.displayLaTeX} \\text{ and } $X = ${x1.displayLaTeX}:",
          "${y1.displayLaTeX} = k \\times ${fmt(fnX1)} \\implies k = \\frac{${y1.displayLaTeX}}{${fmt(fnX1)}} = \\mathbf{${fmt(kVal)}}",
          "\\text{Connecting Formula: } \\mathbf{$Y = ${fmt(kVal)}$powerExpr}",
          "\\text{When } $X = ${target.displayLaTeX}: \\quad $Y = ${fmt(kVal)} \\times ${fmt(fnX2)} = \\mathbf{${fmt(y2Val)}}",
        ];

        workings.add(
            "\\text{\\textbf{Direct Variation with }} $powerExpr");
        workings.addAll(lines);

        steps.add(DirectProportionStep(
          title: "Step 1: Find Constant k and Evaluate for $X = ${target.displayPlain}",
          description:
          "1. Set up $Y = k$powerPlain and substitute ($X = ${x1.displayPlain}, $Y = ${y1.displayPlain}) to find k = ${fmt(kVal)}.\n"
              "2. Substitute $X = ${target.displayPlain} into $Y = ${fmt(kVal)}$powerPlain to get $Y = ${fmt(y2Val)}.",
          mathLinesLaTeX: lines,
        ));

        return DirectProportionResult(
          mode: 2,
          subMode: subMode,
          finalAnswers: {
            "Constant (k)": fmt(kVal),
            "Formula": "$Y = ${fmt(kVal)}$powerPlain",
            "When $X = ${target.displayPlain}": "$Y = ${fmt(y2Val)}",
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: DirectProportionCanvasData(
            visualType: 1,
            xAxisLabel: X,
            yAxisLabel: Y,
            equationBanner: "$Y = ${fmt(kVal)}$powerPlain",
            slopeK: kVal,
            powerN: isCube ? 3 : 1,
            points: [
              const ProportionPlotPoint(x: 0, y: 0, label: '(0, 0)'),
              ProportionPlotPoint(
                x: x1.value,
                y: y1.value,
                label: '(${x1.displayPlain}, ${y1.displayPlain})',
              ),
              ProportionPlotPoint(
                x: target.value,
                y: y2Val,
                label: '(${target.displayPlain}, ${fmt(y2Val)})',
              ),
            ],
            headerBadge:
            "Direct Variation:  $Y = ${fmt(kVal)}$powerPlain",
            subBadge:
            "k = ${fmt(kVal)}   |   When $X = ${target.displayPlain}, $Y = ${fmt(y2Val)}",
            bottomSummaryBanner:
            "When $X = ${target.displayPlain},   $Y = ${fmt(y2Val)}",
          ),
        );
      }
    } catch (e) {
      return DirectProportionResult.error(
        mode: 2,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers in all fields.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: CUSTOM TABLE PROPORTIONALITY INSPECTOR
  // Tests whether any custom list of x-values and y-values is in Direct Proportion!
  // ===========================================================================
  static DirectProportionResult solveCustomTableInspector({
    required String xRowCsv,
    required String yRowCsv,
    required String varXStr,
    required String varYStr,
  }) {
    try {
      final List<ParsedQuantity> xList = xRowCsv
          .split(RegExp(r'[,;\s]+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .map((s) => parseQuantity(s, fieldName: 'x-value'))
          .toList();

      final List<ParsedQuantity> yList = yRowCsv
          .split(RegExp(r'[,;\s]+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .map((s) => parseQuantity(s, fieldName: 'y-value'))
          .toList();

      if (xList.length < 2 || xList.length != yList.length) {
        throw const FormatException(
          "Please enter at least 2 values in the x-row and the exact same number of values in the y-row (separated by commas).",
        );
      }

      final String vx = varXStr.trim().isEmpty ? 'x' : varXStr.trim()[0];
      final String vy = varYStr.trim().isEmpty ? 'y' : varYStr.trim()[0];

      final List<String> ratioCheckLinesLaTeX = [];
      final List<String> ratioCheckLinesPlain = [];
      final List<ProportionPlotPoint> pts = [
        const ProportionPlotPoint(x: 0, y: 0, label: '(0, 0)'),
      ];

      int? firstKNum;
      int? firstKDen;
      bool isDirectlyProportional = true;

      for (int i = 0; i < xList.length; i++) {
        final ParsedQuantity xi = xList[i];
        final ParsedQuantity yi = yList[i];
        final int rN = yi.num * xi.den;
        final int rD = yi.den * xi.num;
        final int g = gcd(rN, rD);
        final int redN = rN ~/ g;
        final int redD = rD ~/ g;

        if (firstKNum == null) {
          firstKNum = redN;
          firstKDen = redD;
        } else if (redN != firstKNum || redD != firstKDen) {
          isDirectlyProportional = false;
        }

        ratioCheckLinesLaTeX.add(
            "\\bullet \\text{ Column ${i + 1}: } \\frac{$vy}{$vx} = \\frac{${yi.displayLaTeX}}{${xi.displayLaTeX}} = \\mathbf{\\frac{$redN}{$redD}} \\quad (${fmt(yi.value / xi.value)})");
        ratioCheckLinesPlain.add(
            "• Column ${i + 1} (${xi.displayPlain}, ${yi.displayPlain}):  $vy/$vx = ${yi.displayPlain}/${xi.displayPlain} = $redN/$redD (${fmt(yi.value / xi.value)})");

        pts.add(ProportionPlotPoint(
          x: xi.value,
          y: yi.value,
          label: '(${xi.displayPlain}, ${yi.displayPlain})',
        ));
      }

      final double kVal = firstKNum! / firstKDen!;
      final String kLaTeX =
      firstKDen == 1 ? "$firstKNum" : "\\frac{$firstKNum}{$firstKDen}";

      final List<String> verdictLines = [
        ...ratioCheckLinesLaTeX,
        if (isDirectlyProportional) ...[
          "\\text{Every column simplifies to the exact same ratio } k = $kLaTeX.",
          "\\therefore \\; \\mathbf{$vy \\text{ and } $vx \\text{ ARE in direct proportion } ($vy = $kLaTeX $vx)!}",
        ] else ...[
          "\\text{The ratios } \\frac{$vy}{$vx} \\text{ are NOT all equal across the table.}",
          "\\therefore \\; \\mathbf{$vy \\text{ and } $vx \\text{ are NOT in direct proportion!}}",
        ],
      ];

      final List<String> workings = [
        "\\text{\\textbf{Test Whether the Table of Values Is in Direct Proportion (Example 2 Method)}}",
        ...verdictLines,
      ];

      final List<DirectProportionStep> steps = [
        DirectProportionStep(
          title:
          "Step 1: Calculate the Ratio ($vy / $vx) for Every Column in the Table",
          description:
          "For two quantities to be in direct proportion, the ratio $vy : $vx must be constant across every pair in the table:\n\n"
              "${ratioCheckLinesPlain.join('\n')}\n\n"
              "• Verdict: ${isDirectlyProportional ? 'Because all ratios are equal to $firstKNum/$firstKDen, $vy and $vx ARE in direct proportion ($vy = ($firstKNum/$firstKDen)$vx)!' : 'Because the ratios are not constant, $vy and $vx are NOT in direct proportion.'}",
          mathLinesLaTeX: verdictLines,
        ),
      ];

      return DirectProportionResult(
        mode: 3,
        finalAnswers: {
          "In Direct Proportion?": isDirectlyProportional ? "YES (Constant Ratio)" : "NO (Ratio Changes)",
          if (isDirectlyProportional) ...{
            "Constant Ratio (k)": "$firstKNum : $firstKDen (${fmt(kVal)})",
            "Connecting Equation":
            "$vy = ${firstKDen == 1 ? '$firstKNum' : '($firstKNum/$firstKDen)'}$vx",
          },
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: DirectProportionCanvasData(
          visualType: 0,
          xAxisLabel: vx,
          yAxisLabel: vy,
          equationBanner: isDirectlyProportional
              ? "$vy = ${firstKDen == 1 ? '$firstKNum' : '($firstKNum/$firstKDen)'}$vx"
              : "Not Proportional",
          slopeK: kVal,
          points: pts,
          headerBadge: isDirectlyProportional
              ? "Direct Proportion Verified:   $vy = ${firstKDen == 1 ? '$firstKNum' : '($firstKNum/$firstKDen)'}$vx"
              : "Table Inspector:   Not in Direct Proportion",
          subBadge: isDirectlyProportional
              ? "All ${xList.length} points lie on a straight line passing through the origin (0, 0)"
              : "Ratios y/x are not equal across all columns",
          bottomSummaryBanner: isDirectlyProportional
              ? "Constant of Proportionality k = $firstKNum/$firstKDen (${fmt(kVal)})"
              : "Ratios Are Not Constant",
        ),
      );
    } catch (e) {
      return DirectProportionResult.error(
        mode: 3,
        message: e is FormatException
            ? e.message
            : "Please enter comma-separated numbers for both rows of the table.",
      );
    }
  }
}