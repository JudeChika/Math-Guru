import 'dart:math' as math;
import 'indirect_proportion_models.dart';

class IndirectProportionLogic {
  // ===========================================================================
  // 11 TEXTBOOK PRESETS (Pages 37–40 & 43: Tables 3.9–3.15, Fig 3.4, Ex 4–5 & Ex 3.2 #1–7)
  // ===========================================================================
  static const List<IndirectProportionPreset> textbookPresets = [
    IndirectProportionPreset(
      chipLabel: "Table 3.9 (Fig 3.4): 120 km Journey (Time vs Speed)",
      mode: 1,
      xLabel: 'Time (h)',
      yLabel: 'Speed (km/h)',
      input1: '1',
      input2: '120',
      tableRow1Csv: '1, 2, 3, 4, 5, 6',
      graphQueriesCsv: 'x=2.5',
    ),
    IndirectProportionPreset(
      chipLabel: "Example 4 (Page 38): 18 farmers cultivate farmland in 20 days; find for 6 farmers",
      mode: 0,
      xLabel: 'farmers',
      yLabel: 'days',
      input1: '18',
      input2: '20',
      input3: '6',
    ),
    IndirectProportionPreset(
      chipLabel: "Example 5 (Page 38): 40 students consume beans in 6 weeks; find for 16, 30, 60",
      mode: 0,
      xLabel: 'students',
      yLabel: 'weeks',
      input1: '40',
      input2: '6',
      input3: '16, 30, 60',
    ),
    IndirectProportionPreset(
      chipLabel: "Ex 3.2 #1a–d: 15 boys cut grass in 12 days; find for 9, 12, 18, 45 boys",
      mode: 0,
      xLabel: 'boys',
      yLabel: 'days',
      input1: '15',
      input2: '12',
      input3: '9, 12, 18, 45',
    ),
    IndirectProportionPreset(
      chipLabel: "Ex 3.2 #2a–c: Kadri travels 48 km; find time at 5, 60, and 100 km/h",
      mode: 0,
      xLabel: 'km/h',
      yLabel: 'hours',
      input1: '1',
      input2: '48',
      input3: '5, 60, 100',
    ),
    IndirectProportionPreset(
      chipLabel: "Ex 3.2 #3 (Compound): 15 men dig 90 m in 3 h; how long for 16 men to dig 48 m?",
      mode: 2,
      xLabel: 'men',
      yLabel: 'hours',
      input1: '15', // M1
      input2: '90', // W1 (m)
      input3: '3', // T1 (hours)
      input4: '16', // M2
      input5: '48', // W2 (m)
    ),
    IndirectProportionPreset(
      chipLabel: "Ex 3.2 #4: 10 labourers complete job in 15 days; how long for 12 labourers?",
      mode: 0,
      xLabel: 'labourers',
      yLabel: 'days',
      input1: '10',
      input2: '15',
      input3: '12',
    ),
    IndirectProportionPreset(
      chipLabel: "Ex 3.2 #5a–d: Car travels 175 km in 3 ½ h (Find for 1 ½ h, 1 h, 100 km, 7 ½ h)",
      mode: 3,
      input1: '175', // Distance 1 (km)
      input2: '3 1/2', // Time 1 (hours)
      input3: '1 1/2', // Query a: Time = 1 1/2 h
      input4: '100', // Query c: Distance = 100 km
      input5: '7 1/2', // Query d: Time = 7 1/2 h
    ),
    IndirectProportionPreset(
      chipLabel: "Ex 3.2 #6 (Table 3.11): Bus travels 180 km (Speed 90, 45, 36, 22 ½, 18)",
      mode: 1,
      xLabel: 'Speed (km/h)',
      yLabel: 'Time (h)',
      input1: '90',
      input2: '2',
      tableRow1Csv: '90, 45, 36, 22 1/2, 18',
      graphQueriesCsv: 'x=40, y=6',
    ),
    IndirectProportionPreset(
      chipLabel: "Ex 3.2 #7 (Table 3.12): Mrs Kasali spends ₦16,000 (Price per item vs No. of items x)",
      mode: 1,
      xLabel: 'Price per item (N)',
      yLabel: 'No. of items (x)',
      input1: '800',
      input2: '20',
      tableRow1Csv: '800, 1000, 1600, 3200, 4000',
      graphQueriesCsv: 'x=320, y=25',
    ),
    IndirectProportionPreset(
      chipLabel: "Rev Ex 3 #3 (Page 43, Table 3.15): Bus travels 100 km (Speed 10, 25, 40, 50, 80)",
      mode: 1,
      xLabel: 'Speed (km/h)',
      yLabel: 'Time (t)',
      input1: '10',
      input2: '10',
      tableRow1Csv: '10, 25, 40, 50, 80',
      graphQueriesCsv: 'x=30, y=6',
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

  static String fmt(double v, {int maxDecimals = 3}) {
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

  /// Formats any rational fraction `num / den` into plain, mixed LaTeX, and improper LaTeX
  /// (All `\frac{...}{...}` are kept strictly OUTSIDE `\text{...}` blocks!)
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

  static ParsedInvQuantity parseQuantity(
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
        "Please enter a valid $fieldName (e.g. 18, 20, 22 1/2, or 3 1/2).",
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

        return ParsedInvQuantity(
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

        return ParsedInvQuantity(
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

    return ParsedInvQuantity(
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
  // MODE 0: INVERSE UNITARY METHOD WORD PROBLEMS (x₁ * y₁ = x₂ * y₂)
  // Covers Examples 4 & 5 (Page 38) and Exercise 3.2 #1a–d, #2a–c, #4
  // ===========================================================================
  static IndirectProportionResult solveInverseUnitaryProblem({
    required String x1Str,
    required String y1Str,
    required String targetX2Csv, // Supports 1 or multiple targets like "9, 12, 18, 45"
    required String xUnitStr,
    required String yUnitStr,
  }) {
    try {
      final ParsedInvQuantity x1 =
      parseQuantity(x1Str, fieldName: 'Initial Quantity 1 (x₁)');
      final ParsedInvQuantity y1 =
      parseQuantity(y1Str, fieldName: 'Initial Time/Value 1 (y₁)');

      final List<String> targetTokens = targetX2Csv
          .split(RegExp(r'[,;]+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (targetTokens.isEmpty) {
        throw const FormatException(
          "Please enter at least one target quantity x₂ (e.g. 6, or 16, 30, 60).",
        );
      }

      final List<ParsedInvQuantity> targets = targetTokens
          .map((t) => parseQuantity(t, fieldName: 'Target Quantity (x₂)'))
          .toList();

      final String ux =
      xUnitStr.trim().isEmpty ? 'units' : cleanTexText(xUnitStr);
      final String uy =
      yUnitStr.trim().isEmpty ? 'days' : cleanTexText(yUnitStr);

      // Constant product k = x1 * y1 (for 1 unit!)
      final int kNumRaw = x1.num * y1.num;
      final int kDenRaw = x1.den * y1.den;
      final Map<String, String> kFmt = formatRational(kNumRaw, kDenRaw);
      final double kVal = x1.value * y1.value;

      // STEP 1: Find the Value for 1 Unit Using the Textbook Inverse Unitary Rule (Examples 4 & 5!)
      final List<String> step1Lines = [
        "\\text{Rule (Page 37): As the number of $ux decreases, the number of $uy increases at the same rate (Indirect Proportion).}",
        "${x1.displayLaTeX}\\text{ $ux take } ${y1.displayLaTeX}\\text{ $uy}",
        "\\text{Therefore, } 1\\text{ unit ($ux) will take } \\left(${x1.displayLaTeX} \\times ${y1.displayLaTeX}\\right)\\text{ $uy:}",
        "1\\text{ unit} = ${x1.displayLaTeX} \\times ${y1.displayLaTeX} = \\mathbf{${kFmt['latex']}\\text{ $uy}} \\quad (\\text{Constant product } k = ${fmt(kVal)})",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Find How Long 1 Unit Will Take (Examples 4 \\& 5 Method)}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Step 2: Divide by Each Target Quantity to Find the Required Time/Value}}",
      ];

      final List<IndirectProportionStep> steps = [
        IndirectProportionStep(
          title:
          "Step 1: Multiply to Find What 1 Unit Takes (Inverse Unitary Method)",
          description:
          "• Crucial Indirect Proportion Rule (Examples 4 & 5, Page 38): If ${x1.displayPlain} $ux take ${y1.displayPlain} $uy, then 1 single unit working alone will take ${x1.displayPlain} TIMES as long (NOT divided by ${x1.displayPlain}!).\n"
              "• 1 unit takes (${x1.displayPlain} × ${y1.displayPlain}) = ${kFmt['plain']} $uy.",
          mathLinesLaTeX: step1Lines,
        ),
      ];

      final List<String> step2LinesLaTeX = [];
      final List<String> step2LinesPlain = [];
      final Map<String, String> answersLaTeX = {
        "1 Unit Product (k)": "${kFmt['latex']}\\text{ $uy}",
        "Inverse Formula": "y = \\frac{${kFmt['latex']}}{x}",
      };

      final List<InversePlotPoint> plotPts = [
        InversePlotPoint(
          x: x1.value,
          y: y1.value,
          pointLaTeX: "\\left(${x1.displayLaTeX},\\; ${y1.displayLaTeX}\\right)",
        ),
      ];
      final List<InverseGraphTrace> traces = [];
      const List<String> letters = ['a', 'b', 'c', 'd', 'e', 'f'];

      for (int i = 0; i < targets.length; i++) {
        final ParsedInvQuantity x2 = targets[i];
        final int y2Num = kNumRaw * x2.den;
        final int y2Den = kDenRaw * x2.num;
        final Map<String, String> y2Fmt = formatRational(y2Num, y2Den);
        final double y2Dec = kVal / x2.value;

        final String prefix =
        targets.length > 1 ? "\\textbf{${letters[i % letters.length]}) } " : "";
        final String prefixPlain =
        targets.length > 1 ? "${letters[i % letters.length]}) " : "• ";

        // Textbook fraction layout: \frac{18 \times 20}{6} days = 60 days
        final String textbookFractionLaTeX =
        (x1.den == 1 && y1.den == 1 && x2.den == 1)
            ? "\\frac{${x1.num} \\times ${y1.num}}{${x2.num}}"
            : "\\frac{${kFmt['improperLaTeX']}}{${x2.improperLaTeX}}";

        final String decimalAlt = y2Fmt['plain'] != fmt(y2Dec)
            ? " \\quad \\left(\\text{or } \\mathbf{${fmt(y2Dec)}\\text{ $uy}}\\right)"
            : "";

        step2LinesLaTeX.add(
            "$prefix\\therefore \\; ${x2.displayLaTeX}\\text{ $ux will take: } $textbookFractionLaTeX\\text{ $uy} = \\frac{$y2Num}{$y2Den}\\text{ $uy} = \\mathbf{${y2Fmt['latex']}\\text{ $uy}}$decimalAlt");

        // Inverse Ratio Verification (Page 37 bottom rule!)
        final int ratioXNum = x1.num * x2.den;
        final int ratioXDen = x1.den * x2.num;
        final Map<String, String> ratioXFmt =
        formatRational(ratioXNum, ratioXDen);
        final Map<String, String> ratioYFmt =
        formatRational(ratioXDen, ratioXNum);
        step2LinesLaTeX.add(
            "\\quad \\text{Inverse Ratio Check (Page 37): Ratio of $ux} = ${ratioXFmt['improperLaTeX']}, \\; \\text{Ratio of $uy} = ${ratioYFmt['improperLaTeX']} \\; (\\text{Inverted Ratio!})");

        step2LinesPlain.add(
            "$prefixPlain For ${x2.displayPlain} $ux:  (${x1.displayPlain} × ${y1.displayPlain}) ÷ ${x2.displayPlain} = ${kFmt['plain']} ÷ ${x2.displayPlain} = ${y2Fmt['plain']} $uy${y2Fmt['plain'] != fmt(y2Dec) ? ' (${fmt(y2Dec)} $uy)' : ''}.");

        final String ansKey = targets.length > 1
            ? "${letters[i % letters.length]}) For ${x2.displayPlain} $ux"
            : "For ${x2.displayPlain} $ux";
        answersLaTeX[ansKey] = y2Fmt['plain'] != fmt(y2Dec)
            ? "${y2Fmt['latex']}\\text{ $uy} \\; (${fmt(y2Dec)})"
            : "${y2Fmt['latex']}\\text{ $uy}";

        plotPts.add(InversePlotPoint(
          x: x2.value,
          y: y2Dec,
          pointLaTeX:
          "\\left(${x2.displayLaTeX},\\; ${y2Fmt['latex']}\\right)",
        ));
        traces.add(InverseGraphTrace(
          xVal: x2.value,
          yVal: y2Dec,
          badgeLaTeX:
          "\\left(${x2.displayLaTeX},\\; ${y2Fmt['latex']}\\right)",
        ));
      }

      workings.addAll(step2LinesLaTeX);

      steps.add(IndirectProportionStep(
        title:
        "Step 2: Divide the 1-Unit Product (${kFmt['plain']}) by Each Target Quantity",
        description:
        "Divide the total 1-unit work product (${x1.displayPlain} × ${y1.displayPlain} = ${kFmt['plain']}) by the new number of $ux:\n\n"
            "${step2LinesPlain.join('\n')}",
        mathLinesLaTeX: step2LinesLaTeX,
      ));

      final ParsedInvQuantity firstTarget = targets.first;
      final Map<String, String> firstAnsFmt = formatRational(
        kNumRaw * firstTarget.den,
        kDenRaw * firstTarget.num,
      );

      return IndirectProportionResult(
        mode: 0,
        finalAnswersLaTeX: answersLaTeX,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: IndirectProportionCanvasData(
          visualType: 0,
          constantProductK: kVal,
          xAxisLaTeX: "\\text{$ux}",
          yAxisLaTeX: "\\text{$uy}",
          curveEquationLaTeX:
          "\\text{$uy} = \\frac{${kFmt['latex']}}{\\text{$ux}}",
          points: plotPts,
          traces: traces,
          headerLaTeX:
          "\\text{Indirect Proportion: } \\frac{${x1.displayLaTeX} \\times ${y1.displayLaTeX}}{${firstTarget.displayLaTeX}} = \\mathbf{${firstAnsFmt['latex']}\\text{ $uy}}",
          subHeaderLaTeX:
          "\\text{Constant Product } k = ${x1.displayLaTeX} \\times ${y1.displayLaTeX} = ${kFmt['latex']} \\quad | \\quad y = \\frac{${kFmt['latex']}}{x}",
          bottomSummaryLaTeX:
          "\\text{For } ${firstTarget.displayLaTeX}\\text{ $ux: } \\frac{${x1.displayLaTeX} \\times ${y1.displayLaTeX}}{${firstTarget.displayLaTeX}} = \\mathbf{${firstAnsFmt['latex']}\\text{ $uy}}",
        ),
      );
    } catch (e) {
      return IndirectProportionResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers or fractions.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: 2-ROW INDIRECT PROPORTION TABLE & HYPERBOLA CURVE GRAPH
  // Covers Table 3.9 (Figure 3.4), Ex 3.2 #6 (Table 3.11),
  // Ex 3.2 #7 (Table 3.12), and Revision Exercise 3 #3 (Table 3.15)
  // ===========================================================================
  static List<ParsedInvQuantity> _parseTableRow1Quantities(
      String rawCsv,
      ParsedInvQuantity fallbackX0,
      ) {
    final String clean = rawCsv.trim();
    if (clean.isEmpty) {
      return [
        for (int i = 1; i <= 6; i++)
          parseQuantity(fmt(fallbackX0.value * i), fieldName: 'Table Value')
      ];
    }
    final List<ParsedInvQuantity> list = [];
    for (final String tok in clean.split(RegExp(r'[,;]+'))) {
      if (tok.trim().isEmpty) continue;
      list.add(parseQuantity(tok.trim(), fieldName: 'Table Row 1 Value'));
    }
    return list.isEmpty ? [fallbackX0] : list;
  }

  static IndirectProportionResult solveTableAndCurveGraph({
    required String row1LabelStr,
    required String row2LabelStr,
    required String knownXStr,
    required String knownYStr,
    required String tableRow1Csv,
    required String graphQueriesCsv, // e.g., "x=40, y=6" or "x=320, y=25"
  }) {
    try {
      final ParsedInvQuantity x0 =
      parseQuantity(knownXStr, fieldName: 'Known Row 1 Value');
      final ParsedInvQuantity y0 =
      parseQuantity(knownYStr, fieldName: 'Known Row 2 Value');

      final String lbl1 =
      row1LabelStr.trim().isEmpty ? 'Time (h)' : cleanTexText(row1LabelStr);
      final String lbl2 = row2LabelStr.trim().isEmpty
          ? 'Speed (km/h)'
          : cleanTexText(row2LabelStr);

      // Constant product k = x0 * y0
      final int kNumRaw = x0.num * y0.num;
      final int kDenRaw = x0.den * y0.den;
      final Map<String, String> kFmt = formatRational(kNumRaw, kDenRaw);
      final double kVal = x0.value * y0.value;

      final List<ParsedInvQuantity> row1Items =
      _parseTableRow1Quantities(tableRow1Csv, x0);

      final List<String> row1CellsLaTeX = [];
      final List<String> row2CellsLaTeX = [];
      final List<String> colCalcLinesLaTeX = [];
      final List<String> colCalcLinesPlain = [];
      final List<InversePlotPoint> plotPts = [];

      for (int i = 0; i < row1Items.length; i++) {
        final ParsedInvQuantity r1 = row1Items[i];
        // Row 2 value y = k / r1 = (kNumRaw * r1.den) / (kDenRaw * r1.num)
        final int r2Num = kNumRaw * r1.den;
        final int r2Den = kDenRaw * r1.num;
        final Map<String, String> r2Fmt = formatRational(r2Num, r2Den);
        final double r2Val = kVal / r1.value;

        row1CellsLaTeX.add(r1.displayLaTeX);
        row2CellsLaTeX.add("\\mathbf{${r2Fmt['latex']}}");

        colCalcLinesLaTeX.add(
            "\\bullet \\text{ When $lbl1} = ${r1.displayLaTeX}: \\quad \\text{$lbl2} = \\frac{${kFmt['latex']}}{${r1.improperLaTeX}} = \\mathbf{${r2Fmt['latex']}}");
        colCalcLinesPlain.add(
            "• Column ${i + 1} ($lbl1 = ${r1.displayPlain}):  $lbl2 = ${kFmt['plain']} ÷ ${r1.displayPlain} = ${r2Fmt['plain']}");

        plotPts.add(InversePlotPoint(
          x: r1.value,
          y: r2Val,
          pointLaTeX:
          "\\left(${r1.displayLaTeX},\\; ${r2Fmt['latex']}\\right)",
        ));
      }

      // Build the 2-Row Textbook Table (matching Table 3.9 on Page 37!)
      final String colSpec = List.filled(row1Items.length + 1, 'c').join('|');
      final String fullTableLaTeX = "\\begin{array}{|$colSpec|} \\hline "
          "\\textbf{$lbl1} & ${row1CellsLaTeX.join(' & ')} \\\\ \\hline "
          "\\textbf{$lbl2} & ${row2CellsLaTeX.join(' & ')} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [];
      final List<IndirectProportionStep> steps = [];

      // STEP 1: Constant Product k & Completing the Indirect Proportion Table
      final List<String> step1Lines = [
        "\\text{In indirect proportion, the product of the two quantities is constant } (x \\times y = k):",
        "k = ${x0.displayLaTeX} \\times ${y0.displayLaTeX} = \\mathbf{${kFmt['latex']}}",
        ...colCalcLinesLaTeX,
        fullTableLaTeX,
      ];

      workings.add(
          "\\text{\\textbf{Part (a): Complete the Indirect Proportion Table (Table 3.9 Method)}}");
      workings.addAll(step1Lines);
      workings.add("");

      steps.add(IndirectProportionStep(
        title:
        "Step 1: Part (a) — Find the Constant Product (k = ${kFmt['plain']}) & Complete the Table",
        description:
        "1. Multiply the known pair (${x0.displayPlain} × ${y0.displayPlain}) to find the constant product k = ${kFmt['plain']}.\n"
            "2. For each column in Row 1, divide ${kFmt['plain']} by the Row 1 value to get Row 2 ($lbl2 = ${kFmt['plain']} ÷ $lbl1):\n\n"
            "${colCalcLinesPlain.join('\n')}",
        mathLinesLaTeX: step1Lines,
      ));

      // STEP 2: Why the Graph of Indirect Proportion is a Curve (Figure 3.4)!
      final List<String> step2Lines = [
        "\\text{As } \\text{$lbl1} \\text{ increases, } \\text{$lbl2} \\text{ decreases at the same rate.}",
        "\\text{Hence, the shape of the graph obtained when } \\text{$lbl2} \\text{ is plotted against } \\text{$lbl1} \\text{ is a \\textbf{smooth downward-sloping curve} (Figure 3.4):}",
        "\\mathbf{\\text{$lbl2} = \\frac{${kFmt['latex']}}{\\text{$lbl1}}}",
      ];

      workings.add(
          "\\text{\\textbf{Part (b): Graphical Representation of Indirect Proportion (Figure 3.4)}}");
      workings.addAll(step2Lines);

      steps.add(IndirectProportionStep(
        title:
        "Step 2: Part (b) — Why the Graph of Indirect Proportion is a Curve (Figure 3.4)",
        description:
        "• Textbook Rule (Page 38): As '$lbl1' increases, '$lbl2' decreases at a corresponding rate, so plotting '$lbl2' against '$lbl1' produces a smooth downward-sloping hyperbola curve (Figure 3.4).",
        mathLinesLaTeX: step2Lines,
      ));

      final Map<String, String> answersLaTeX = {
        "Constant Product (k)": kFmt['latex']!,
        "Inverse Formula":
        "\\text{$lbl2} = \\frac{${kFmt['latex']}}{\\text{$lbl1}}",
        "Graph Shape (Fig 3.4)": "\\text{Hyperbola Curve}",
      };

      // STEP 3: Evaluate Follow-Up Graph Readings (Part c: i & ii — Ex 3.2 #6c, #7b & Rev Ex 3 #3c)
      final List<InverseGraphTrace> traces = [];
      if (graphQueriesCsv.trim().isNotEmpty) {
        final List<String> qTokens = graphQueriesCsv
            .split(RegExp(r'[,;]+'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        final List<String> qLinesLaTeX = [];
        final List<String> qLinesPlain = [];
        const List<String> romans = ['i', 'ii', 'iii', 'iv'];

        for (int qIdx = 0; qIdx < qTokens.length; qIdx++) {
          final String tok = qTokens[qIdx];
          final String rom =
          qIdx < romans.length ? "${romans[qIdx]}) " : "• ";
          final bool isGivenRow2 = tok.toLowerCase().startsWith('y=');
          final String numStr = tok.contains('=')
              ? tok.split('=').last.trim()
              : tok.trim();
          final ParsedInvQuantity qVal =
          parseQuantity(numStr, fieldName: 'Graph Query Value');

          if (!isGivenRow2) {
            final int ansN = kNumRaw * qVal.den;
            final int ansD = kDenRaw * qVal.num;
            final Map<String, String> ansFmt = formatRational(ansN, ansD);
            final double ansDec = kVal / qVal.value;

            qLinesLaTeX.add(
                "\\text{$rom When $lbl1} = ${qVal.displayLaTeX}: \\quad \\text{$lbl2} = \\frac{${kFmt['latex']}}{${qVal.improperLaTeX}} = \\mathbf{${ansFmt['latex']}}"
                    "${ansFmt['plain'] != fmt(ansDec) ? ' \\; (\\mathbf{${fmt(ansDec)}})' : ''}");
            qLinesPlain.add(
                "$rom When $lbl1 = ${qVal.displayPlain}:  $lbl2 = ${kFmt['plain']} ÷ ${qVal.displayPlain} = ${ansFmt['plain']} (${fmt(ansDec)}).");

            answersLaTeX["${romans[qIdx % romans.length]}) At $lbl1 = ${qVal.displayPlain}"] =
            ansFmt['plain'] != fmt(ansDec)
                ? "${ansFmt['latex']} \\; (${fmt(ansDec)})"
                : ansFmt['latex']!;

            traces.add(InverseGraphTrace(
              xVal: qVal.value,
              yVal: ansDec,
              badgeLaTeX:
              "\\left(${qVal.displayLaTeX},\\; ${ansFmt['latex']}\\right)",
            ));
          } else {
            final int ansN = kNumRaw * qVal.den;
            final int ansD = kDenRaw * qVal.num;
            final Map<String, String> ansFmt = formatRational(ansN, ansD);
            final double ansDec = kVal / qVal.value;

            qLinesLaTeX.add(
                "\\text{$rom When $lbl2} = ${qVal.displayLaTeX}: \\quad \\text{$lbl1} = \\frac{${kFmt['latex']}}{${qVal.improperLaTeX}} = \\mathbf{${ansFmt['latex']}}"
                    "${ansFmt['plain'] != fmt(ansDec) ? ' \\; (\\mathbf{${fmt(ansDec)}})' : ''}");
            qLinesPlain.add(
                "$rom When $lbl2 = ${qVal.displayPlain}:  $lbl1 = ${kFmt['plain']} ÷ ${qVal.displayPlain} = ${ansFmt['plain']} (${fmt(ansDec)}).");

            answersLaTeX["${romans[qIdx % romans.length]}) At $lbl2 = ${qVal.displayPlain}"] =
            ansFmt['plain'] != fmt(ansDec)
                ? "${ansFmt['latex']} \\; (${fmt(ansDec)})"
                : ansFmt['latex']!;

            traces.add(InverseGraphTrace(
              xVal: ansDec,
              yVal: qVal.value,
              badgeLaTeX:
              "\\left(${ansFmt['latex']},\\; ${qVal.displayLaTeX}\\right)",
            ));
          }
        }

        if (qLinesLaTeX.isNotEmpty) {
          workings.add("");
          workings.add(
              "\\text{\\textbf{Part (c): Find Required Values from the Graph \\& Inverse Formula}}");
          workings.addAll(qLinesLaTeX);

          steps.add(IndirectProportionStep(
            title:
            "Step 3: Part (c) — Read Required Values Using the Graph & Inverse Formula",
            description:
            "On the indirect proportion graph (Figure 3.4), locate the value on the axis, trace to the curve, and read the corresponding value:\n\n"
                "${qLinesPlain.join('\n')}",
            mathLinesLaTeX: qLinesLaTeX,
          ));
        }
      }

      return IndirectProportionResult(
        mode: 1,
        finalAnswersLaTeX: answersLaTeX,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: IndirectProportionCanvasData(
          visualType: 0,
          constantProductK: kVal,
          xAxisLaTeX: "\\text{$lbl1}",
          yAxisLaTeX: "\\text{$lbl2}",
          curveEquationLaTeX:
          "\\text{$lbl2} = \\frac{${kFmt['latex']}}{\\text{$lbl1}}",
          points: plotPts,
          traces: traces,
          headerLaTeX:
          "\\text{Indirect Proportion Table \\& Graph: } \\text{$lbl1} \\times \\text{$lbl2} = ${kFmt['latex']}",
          subHeaderLaTeX:
          "\\text{Figure 3.4 Hyperbola Curve: } \\text{$lbl2} = \\frac{${kFmt['latex']}}{\\text{$lbl1}}",
          bottomSummaryLaTeX:
          "\\text{Constant Product } k = ${kFmt['latex']} \\quad | \\quad y = \\frac{${kFmt['latex']}}{x}",
        ),
      );
    } catch (e) {
      return IndirectProportionResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers or mixed fractions for the table.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: COMPOUND PROPORTION — WORKERS, WORK/LENGTH & TIME (Exercise 3.2 #3)
  // "15 men can dig a trench of 90 m long in 3 hours. How long will it take 16 men to dig a trench 48 m long?"
  // ===========================================================================
  static IndirectProportionResult solveCompoundProportion({
    required String workers1Str, // e.g., 15 men
    required String work1Str, // e.g., 90 m
    required String time1Str, // e.g., 3 hours
    required String workers2Str, // e.g., 16 men
    required String work2Str, // e.g., 48 m
  }) {
    try {
      final ParsedInvQuantity m1 =
      parseQuantity(workers1Str, fieldName: 'Initial Workers (M₁)');
      final ParsedInvQuantity w1 =
      parseQuantity(work1Str, fieldName: 'Initial Work/Length (W₁)');
      final ParsedInvQuantity t1 =
      parseQuantity(time1Str, fieldName: 'Initial Time (T₁)');
      final ParsedInvQuantity m2 =
      parseQuantity(workers2Str, fieldName: 'New Workers (M₂)');
      final ParsedInvQuantity w2 =
      parseQuantity(work2Str, fieldName: 'New Work/Length (W₂)');

      // Step 1: 1 man digging W1 takes M1 * T1 hours (Indirect Proportion!)
      final int oneManW1Num = m1.num * t1.num;
      final int oneManW1Den = m1.den * t1.den;
      final Map<String, String> oneManW1Fmt =
      formatRational(oneManW1Num, oneManW1Den);

      // Step 2: 1 man digging 1 unit of work takes (M1 * T1) / W1 hours (Direct Proportion!)
      final int oneMan1mNum = oneManW1Num * w1.den;
      final int oneMan1mDen = oneManW1Den * w1.num;
      final Map<String, String> oneMan1mFmt =
      formatRational(oneMan1mNum, oneMan1mDen);

      // Step 3: M2 men digging W2 units of work take: T2 = (M1 * T1 * W2) / (W1 * M2)
      final int t2NumRaw = oneMan1mNum * w2.num * m2.den;
      final int t2DenRaw = oneMan1mDen * w2.den * m2.num;
      final Map<String, String> t2Fmt = formatRational(t2NumRaw, t2DenRaw);
      final double t2Dec =
          (m1.value * t1.value * w2.value) / (w1.value * m2.value);

      final List<String> step1Lines = [
        "\\text{Keep trench length fixed at } ${w1.displayLaTeX}\\text{ m first (Indirect Proportion between Men and Time):}",
        "${m1.displayLaTeX}\\text{ men dig } ${w1.displayLaTeX}\\text{ m in } ${t1.displayLaTeX}\\text{ hours}",
        "\\therefore \\; 1\\text{ man digs } ${w1.displayLaTeX}\\text{ m in } \\left(${t1.displayLaTeX} \\times ${m1.displayLaTeX}\\right)\\text{ hours} = \\mathbf{${oneManW1Fmt['latex']}\\text{ hours}}",
      ];

      final List<String> step2Lines = [
        "\\text{Now reduce to } 1\\text{ m of trench (Direct Proportion between Trench Length and Time):}",
        "1\\text{ man digs } ${w1.displayLaTeX}\\text{ m in } ${oneManW1Fmt['latex']}\\text{ hours}",
        "\\therefore \\; 1\\text{ man digs } 1\\text{ m in } \\frac{${t1.displayLaTeX} \\times ${m1.displayLaTeX}}{${w1.displayLaTeX}}\\text{ hours} = \\mathbf{${oneMan1mFmt['improperLaTeX']}\\text{ hour(s)}}",
      ];

      final List<String> step3Lines = [
        "\\text{Now scale to } ${m2.displayLaTeX}\\text{ men (divide by } ${m2.displayLaTeX}\\text{) digging } ${w2.displayLaTeX}\\text{ m (multiply by } ${w2.displayLaTeX}\\text{):}",
        "${m2.displayLaTeX}\\text{ men dig } 1\\text{ m in } \\frac{${t1.displayLaTeX} \\times ${m1.displayLaTeX}}{${w1.displayLaTeX} \\times ${m2.displayLaTeX}}\\text{ hours}",
        "\\therefore \\; ${m2.displayLaTeX}\\text{ men dig } ${w2.displayLaTeX}\\text{ m in:}",
        "\\text{Time } (T_2) = \\frac{${t1.displayLaTeX} \\times ${m1.displayLaTeX} \\times ${w2.displayLaTeX}}{${w1.displayLaTeX} \\times ${m2.displayLaTeX}}\\text{ hours}",
        "= \\frac{$t2NumRaw}{$t2DenRaw}\\text{ hours}",
        "= \\mathbf{${t2Fmt['latex']}\\text{ hours}}"
            "${t2Fmt['plain'] != fmt(t2Dec) ? ' \\quad \\left(\\text{or } \\mathbf{${fmt(t2Dec)}\\text{ hours}}\\right)' : ''}",
      ];

      final List<String> step4Lines = [
        "\\text{General Compound Work Formula: } \\frac{M_1 \\times T_1}{W_1} = \\frac{M_2 \\times T_2}{W_2}",
        "\\frac{${m1.displayLaTeX} \\times ${t1.displayLaTeX}}{${w1.displayLaTeX}} = \\frac{${m2.displayLaTeX} \\times T_2}{${w2.displayLaTeX}} \\implies T_2 = \\mathbf{${t2Fmt['latex']}\\text{ hours}} \\quad (\\text{Verified!})",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Time for 1 Man to Dig }} ${w1.displayLaTeX}\\text{\\textbf{ m (Indirect Proportion)}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Step 2: Time for 1 Man to Dig 1 m (Direct Proportion)}}",
        ...step2Lines,
        "",
        "\\text{\\textbf{Step 3: Time for }} ${m2.displayLaTeX}\\text{\\textbf{ Men to Dig }} ${w2.displayLaTeX}\\text{\\textbf{ m (Exercise 3.2 \\#3)}}",
        ...step3Lines,
        "",
        "\\text{\\textbf{Step 4: Verification Using the Man-Hours Formula}}",
        ...step4Lines,
      ];

      final List<IndirectProportionStep> steps = [
        IndirectProportionStep(
          title:
          "Step 1: Find Time for 1 Man to Dig ${w1.displayPlain} m (Indirect Proportion)",
          description:
          "• Fewer men take MORE time for the same ${w1.displayPlain} m trench (Indirect Proportion).\n"
              "• Since ${m1.displayPlain} men take ${t1.displayPlain} hours, 1 man working alone takes ${t1.displayPlain} × ${m1.displayPlain} = ${oneManW1Fmt['plain']} hours.",
          mathLinesLaTeX: step1Lines,
        ),
        IndirectProportionStep(
          title:
          "Step 2: Find Time for 1 Man to Dig 1 m of Trench (Direct Proportion)",
          description:
          "• Shorter trench length takes LESS time (Direct Proportion).\n"
              "• To dig just 1 m of trench, 1 man takes ${oneManW1Fmt['plain']} ÷ ${w1.displayPlain} = ${oneMan1mFmt['plain']} hour(s).",
          mathLinesLaTeX: step2Lines,
        ),
        IndirectProportionStep(
          title:
          "Step 3: Scale to ${m2.displayPlain} Men Digging ${w2.displayPlain} m",
          description:
          "• Divide by ${m2.displayPlain} men (since ${m2.displayPlain} men share the work) and multiply by ${w2.displayPlain} m:\n"
              "• Time = (${t1.displayPlain} × ${m1.displayPlain} × ${w2.displayPlain}) ÷ (${w1.displayPlain} × ${m2.displayPlain}) = ${t2Fmt['plain']} hours (${fmt(t2Dec)} hours).",
          mathLinesLaTeX: [...step3Lines, ...step4Lines],
        ),
      ];

      return IndirectProportionResult(
        mode: 2,
        finalAnswersLaTeX: {
          "1 Man for ${w1.displayPlain} m":
          "${oneManW1Fmt['latex']}\\text{ hours}",
          "1 Man for 1 m": "${oneMan1mFmt['improperLaTeX']}\\text{ hour}",
          "Time for ${m2.displayPlain} Men (${w2.displayPlain} m)":
          t2Fmt['plain'] != fmt(t2Dec)
              ? "${t2Fmt['latex']}\\text{ h} \\; (${fmt(t2Dec)}\\text{ h})"
              : "${t2Fmt['latex']}\\text{ hours}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: IndirectProportionCanvasData(
          visualType: 1,
          topCard1Title: "Initial Team & Trench",
          topCard1LaTeX:
          "${m1.displayLaTeX}\\text{ men},\\; ${w1.displayLaTeX}\\text{ m},\\; ${t1.displayLaTeX}\\text{ h}",
          topCard2Title: "1 Man for 1 m Rate",
          topCard2LaTeX:
          "\\frac{${t1.displayLaTeX} \\times ${m1.displayLaTeX}}{${w1.displayLaTeX}} = ${oneMan1mFmt['improperLaTeX']}\\text{ h/m}",
          middleFormulaLaTeX:
          "T_2 = \\frac{${t1.displayLaTeX} \\times ${m1.displayLaTeX} \\times ${w2.displayLaTeX}}{${w1.displayLaTeX} \\times ${m2.displayLaTeX}}",
          bottomResultLaTeX:
          "T_2 = \\frac{$t2NumRaw}{$t2DenRaw} = \\mathbf{${t2Fmt['latex']}\\text{ hours}} \\quad (${fmt(t2Dec)}\\text{ h})",
          headerLaTeX:
          "\\text{Exercise 3.2 \\#3 Compound Proportion: } T_2 = \\mathbf{${t2Fmt['latex']}\\text{ hours}}",
          subHeaderLaTeX:
          "\\text{Men \\& Time = Indirect Proportion} \\quad | \\quad \\text{Trench Length \\& Time = Direct Proportion}",
          bottomSummaryLaTeX:
          "${m2.displayLaTeX}\\text{ men dig } ${w2.displayLaTeX}\\text{ m in } \\mathbf{${t2Fmt['latex']}\\text{ hours}}",
        ),
      );
    } catch (e) {
      return IndirectProportionResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers in all 5 fields.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: CONSTANT-SPEED MULTI-PART JOURNEY (Exercise 3.2 #5a–d)
  // "A car travels 175 km in 3 ½ hours.
  //  a) How far will it travel in 1 ½ hours?
  //  b) How far will it travel in 1 hour?
  //  c) How long will it take the car to travel 100 km?
  //  d) How many kilometres will have been travelled at the end of 7 ½ hours?"
  // ===========================================================================
  static IndirectProportionResult solveConstantSpeedJourney({
    required String dist1Str, // e.g., 175 km
    required String time1Str, // e.g., 3 1/2 hours
    required String queryTimeAStr, // e.g., 1 1/2 hours
    required String queryDistCStr, // e.g., 100 km
    required String queryTimeDStr, // e.g., 7 1/2 hours
  }) {
    try {
      final ParsedInvQuantity d1 =
      parseQuantity(dist1Str, fieldName: 'Initial Distance (km)');
      final ParsedInvQuantity t1 =
      parseQuantity(time1Str, fieldName: 'Initial Time (hours)');
      final ParsedInvQuantity tA =
      parseQuantity(queryTimeAStr, fieldName: 'Part (a) Time (hours)');
      final ParsedInvQuantity dC =
      parseQuantity(queryDistCStr, fieldName: 'Part (c) Distance (km)');
      final ParsedInvQuantity tD =
      parseQuantity(queryTimeDStr, fieldName: 'Part (d) Time (hours)');

      // Constant Speed (Distance in 1 hour — Part b!) = d1 / t1 = (d1.num * t1.den) / (d1.den * t1.num)
      final int speedNumRaw = d1.num * t1.den;
      final int speedDenRaw = d1.den * t1.num;
      final int gs = gcd(speedNumRaw, speedDenRaw);
      final int speedNum = speedNumRaw ~/ gs;
      final int speedDen = speedDenRaw ~/ gs;
      final Map<String, String> speedFmt = formatRational(speedNum, speedDen);
      final double speedVal = d1.value / t1.value;

      // Part (a): Distance in tA hours = Speed * tA
      final int distANum = speedNum * tA.num;
      final int distADen = speedDen * tA.den;
      final Map<String, String> distAFmt = formatRational(distANum, distADen);

      // Part (c): Time to travel dC km = dC / Speed
      final int timeCNum = dC.num * speedDen;
      final int timeCDen = dC.den * speedNum;
      final Map<String, String> timeCFmt = formatRational(timeCNum, timeCDen);

      // Part (d): Distance at the end of tD hours = Speed * tD
      final int distDNum = speedNum * tD.num;
      final int distDDen = speedDen * tD.den;
      final Map<String, String> distDFmt = formatRational(distDNum, distDDen);

      final List<String> step1Lines = [
        "\\text{In } ${t1.displayLaTeX}\\text{ hours, the car travels } ${d1.displayLaTeX}\\text{ km.}",
        if (t1.isMixedInput)
          "\\text{Convert mixed number to improper fraction: } ${t1.displayLaTeX}\\text{ hours} = ${t1.improperLaTeX}\\text{ hours}",
        "\\text{\\textbf{Part (b) — Distance in 1 hour (Constant Speed):}}",
        "\\text{Distance in } 1\\text{ hour} = ${d1.displayLaTeX} \\div ${t1.displayLaTeX} = ${d1.improperLaTeX} \\div ${t1.improperLaTeX}",
        "= ${d1.improperLaTeX} \\times \\frac{${t1.den}}{${t1.num}} = \\frac{${d1.num * t1.den}}{${d1.den * t1.num}} = \\mathbf{${speedFmt['latex']}\\text{ km}}",
      ];

      final List<String> step2Lines = [
        "\\text{\\textbf{Part (a) — Distance in }} ${tA.displayLaTeX}\\text{\\textbf{ hours:}}",
        if (tA.isMixedInput)
          "${tA.displayLaTeX}\\text{ hours} = ${tA.improperLaTeX}\\text{ hours}",
        "\\text{Distance} = \\text{Distance in } 1\\text{ hour} \\times \\text{Time} = ${speedFmt['improperLaTeX']} \\times ${tA.improperLaTeX}",
        "= \\frac{$distANum}{$distADen} = \\mathbf{${distAFmt['latex']}\\text{ km}}",
      ];

      final List<String> step3Lines = [
        "\\text{\\textbf{Part (c) — Time taken to travel }} ${dC.displayLaTeX}\\text{\\textbf{ km:}}",
        "\\text{Time} = \\frac{\\text{Distance}}{\\text{Speed}} = ${dC.improperLaTeX} \\div ${speedFmt['improperLaTeX']}",
        "= \\frac{$timeCNum}{$timeCDen} = \\mathbf{${timeCFmt['latex']}\\text{ hours}}",
        "",
        "\\text{\\textbf{Part (d) — Distance travelled at the end of }} ${tD.displayLaTeX}\\text{\\textbf{ hours:}}",
        if (tD.isMixedInput)
          "${tD.displayLaTeX}\\text{ hours} = ${tD.improperLaTeX}\\text{ hours}",
        "\\text{Distance} = ${speedFmt['improperLaTeX']} \\times ${tD.improperLaTeX} = \\frac{$distDNum}{$distDDen} = \\mathbf{${distDFmt['latex']}\\text{ km}}",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Find the Distance in 1 Hour — Part (b) (Exercise 3.2 \\#5)}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Step 2: Find the Distance in }} ${tA.displayLaTeX}\\text{\\textbf{ Hours — Part (a)}}",
        ...step2Lines,
        "",
        "\\text{\\textbf{Step 3: Solve Part (c) and Part (d)}}",
        ...step3Lines,
      ];

      final List<IndirectProportionStep> steps = [
        IndirectProportionStep(
          title:
          "Step 1: Find the Distance Travelled in 1 Hour — Answers Part (b)",
          description:
          "• First divide the given distance (${d1.displayPlain} km) by the given time (${t1.displayPlain} hours) to find how far the car travels in 1 hour (its constant speed):\n"
              "• ${d1.displayPlain} ÷ ${t1.displayPlain} = ${speedFmt['plain']} km in 1 hour.",
          mathLinesLaTeX: step1Lines,
        ),
        IndirectProportionStep(
          title:
          "Step 2: Multiply the 1-Hour Distance by ${tA.displayPlain} Hours — Answers Part (a)",
          description:
          "• Since the car travels ${speedFmt['plain']} km in 1 hour, in ${tA.displayPlain} hours it travels ${speedFmt['plain']} × ${tA.displayPlain} = ${distAFmt['plain']} km.",
          mathLinesLaTeX: step2Lines,
        ),
        IndirectProportionStep(
          title:
          "Step 3: Solve Part (c) (${dC.displayPlain} km) & Part (d) (${tD.displayPlain} hours)",
          description:
          "• Part (c): Divide ${dC.displayPlain} km by ${speedFmt['plain']} km/h to get ${timeCFmt['plain']} hours.\n"
              "• Part (d): Multiply ${speedFmt['plain']} km/h by ${tD.displayPlain} hours to get ${distDFmt['plain']} km.",
          mathLinesLaTeX: step3Lines,
        ),
      ];

      return IndirectProportionResult(
        mode: 3,
        finalAnswersLaTeX: {
          "a) In ${tA.displayPlain} hours": "${distAFmt['latex']}\\text{ km}",
          "b) In 1 hour (Speed)": "${speedFmt['latex']}\\text{ km}",
          "c) Time for ${dC.displayPlain} km":
          "${timeCFmt['latex']}\\text{ hours}",
          "d) In ${tD.displayPlain} hours": "${distDFmt['latex']}\\text{ km}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: IndirectProportionCanvasData(
          visualType: 1,
          topCard1Title: "Given Journey",
          topCard1LaTeX:
          "${d1.displayLaTeX}\\text{ km in } ${t1.displayLaTeX}\\text{ h}",
          topCard2Title: "b) In 1 Hour (Speed)",
          topCard2LaTeX:
          "${d1.displayLaTeX} \\div ${t1.displayLaTeX} = \\mathbf{${speedFmt['latex']}\\text{ km/h}}",
          middleFormulaLaTeX:
          "\\text{a) } ${speedFmt['latex']} \\times ${tA.displayLaTeX} = \\mathbf{${distAFmt['latex']}\\text{ km}} \\quad | \\quad \\text{c) } \\frac{${dC.displayLaTeX}}{${speedFmt['latex']}} = \\mathbf{${timeCFmt['latex']}\\text{ h}}",
          bottomResultLaTeX:
          "\\text{d) At end of } ${tD.displayLaTeX}\\text{ h: } ${speedFmt['latex']} \\times ${tD.displayLaTeX} = \\mathbf{${distDFmt['latex']}\\text{ km}}",
          headerLaTeX:
          "\\text{Exercise 3.2 \\#5 Multi-Part Journey: } \\text{Speed} = \\mathbf{${speedFmt['latex']}\\text{ km/h}}",
          subHeaderLaTeX:
          "\\text{a) } ${distAFmt['latex']}\\text{ km} \\quad | \\quad \\text{b) } ${speedFmt['latex']}\\text{ km} \\quad | \\quad \\text{c) } ${timeCFmt['latex']}\\text{ h} \\quad | \\quad \\text{d) } ${distDFmt['latex']}\\text{ km}",
          bottomSummaryLaTeX:
          "\\text{a) } ${distAFmt['latex']}\\text{ km}, \\; \\text{b) } ${speedFmt['latex']}\\text{ km}, \\; \\text{c) } ${timeCFmt['latex']}\\text{ h}, \\; \\text{d) } ${distDFmt['latex']}\\text{ km}",
        ),
      );
    } catch (e) {
      return IndirectProportionResult.error(
        mode: 3,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers or mixed fractions.",
      );
    }
  }
}