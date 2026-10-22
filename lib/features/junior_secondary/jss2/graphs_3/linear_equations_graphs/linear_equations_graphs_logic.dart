import 'package:flutter/material.dart';
import 'linear_equations_graphs_models.dart';

/// Internal parsed representation of a 2-variable linear equation: a*x + b*y + c = 0
class _ParsedLinearEq {
  final String rawInput;
  final double a; // Coefficient of x in ax + by + c = 0
  final double b; // Coefficient of y in ax + by + c = 0
  final double c; // Constant term in ax + by + c = 0

  const _ParsedLinearEq({
    required this.rawInput,
    required this.a,
    required this.b,
    required this.c,
  });

  bool get isVertical => b.abs() < 1e-9;
  bool get isHorizontal => a.abs() < 1e-9;

  /// Slope m in y = mx + c
  double get m => isVertical ? 0.0 : (-a / b);

  /// y-intercept c_explicit in y = mx + c_explicit
  double get yIntercept => isVertical ? 0.0 : (-c / b);

  /// x-intercept when y = 0
  double? get xIntercept => isHorizontal ? null : (-c / a);

  double evaluateY(double xVal) => isVertical ? 0.0 : (-a * xVal - c) / b;
  double evaluateX(double yVal) => isHorizontal ? 0.0 : (-b * yVal - c) / a;
}

class LinearEquationsGraphsLogic {
  // ===========================================================================
  // 12 TEXTBOOK PRESETS (Covers Tables 23.1–23.6, Figs 23.1–23.5, Ex 1–2, Ex 23a & 23b)
  // ===========================================================================
  static const List<LinearEqGraphPreset> textbookPresets = [
    LinearEqGraphPreset(
      chipLabel: "Table 23.1 (Fig 23.1): y = 2x - 5 (x from -2 to 4)",
      mode: 0,
      equationStr: 'y = 2x - 5',
      xValuesCsv: '-2, -1, 0, 1, 2, 3, 4',
      queryXStr: '1.5',
      queryYStr: '',
      scaleXStr: '2',
      scaleYStr: '5',
    ),
    LinearEqGraphPreset(
      chipLabel: "Ex 1 (Fig 23.2): y = 4x - 7 (Read x=2.5 & y=-13)",
      mode: 0,
      equationStr: 'y = 4x - 7',
      xValuesCsv: '-3, -2, -1, 0, 1, 2, 3',
      queryXStr: '2.5',
      queryYStr: '-13',
      scaleXStr: '1',
      scaleYStr: '5',
    ),
    LinearEqGraphPreset(
      chipLabel: "Ex 23a #1 (Fig 23.3): Check Points A, B, C on y = x - 2",
      mode: 2,
      subMode: 0,
      equationStr: 'y = x - 2',
      pointAStr: '-3;-5',
      pointBStr: '-1;1',
      pointCStr: '3;5',
      scaleXStr: '1',
      scaleYStr: '5',
    ),
    LinearEqGraphPreset(
      chipLabel: "Ex 23a #2 (Table 23.4): y = x - 4 (Read x=1 & y=-5)",
      mode: 0,
      equationStr: 'y = x - 4',
      xValuesCsv: '-3, 0, 3',
      queryXStr: '1',
      queryYStr: '-5',
      scaleXStr: '1',
      scaleYStr: '1',
    ),
    LinearEqGraphPreset(
      chipLabel: "Ex 23a #3 (Table 23.5): y = 4x - 5 (x from -2 to 4)",
      mode: 0,
      equationStr: 'y = 4x - 5',
      xValuesCsv: '-2, -1, 0, 1, 2, 3, 4',
      scaleXStr: '1',
      scaleYStr: '5',
    ),
    LinearEqGraphPreset(
      chipLabel: "Ex 23a #4: y = 7 - 3x (x from -3 to 3)",
      mode: 0,
      equationStr: 'y = 7 - 3x',
      xValuesCsv: '-3, -2, -1, 0, 1, 2, 3',
      scaleXStr: '1',
      scaleYStr: '5',
    ),
    LinearEqGraphPreset(
      chipLabel: "Ex 23a #5: Find A(-3;a), B(0;b), C(3;c) on y = 5x - 2",
      mode: 2,
      subMode: 1,
      equationStr: 'y = 5x - 2',
      xValuesCsv: '-3, 0, 3',
      scaleXStr: '1',
      scaleYStr: '5',
    ),
    LinearEqGraphPreset(
      chipLabel: "Ex 23a #6: Parallel Family (y = 2x+5, 2x-1, 2x, 2x-3)",
      mode: 3,
      xValuesCsv: '-3, -2, -1, 0, 1, 2, 3',
      scaleXStr: '2',
      scaleYStr: '5',
      multiEquations: [
        'y = 2x + 5',
        'y = 2x - 1',
        'y = 2x',
        'y = 2x - 3',
      ],
    ),
    LinearEqGraphPreset(
      chipLabel: "Ex 23a #7: Common Intercept (y = x+5, -x+5, 5+2x, 5-3x)",
      mode: 3,
      xValuesCsv: '-3, -2, -1, 0, 1, 2, 3',
      scaleXStr: '2',
      scaleYStr: '5',
      multiEquations: [
        'y = x + 5',
        'y = -x + 5',
        'y = 5 + 2x',
        'y = 5 - 3x',
      ],
    ),
    LinearEqGraphPreset(
      chipLabel: "Ex 23a #8: Intersection of y = 4x and y = 9",
      mode: 3,
      xValuesCsv: '-1, 0, 1, 2, 3',
      scaleXStr: '1',
      scaleYStr: '5',
      multiEquations: [
        'y = 4x',
        'y = 9',
      ],
    ),
    LinearEqGraphPreset(
      chipLabel: "Ex 2 (Fig 23.4): 5x + 2y - 6 = 0 (x = -2, 0, +2)",
      mode: 1,
      equationStr: '5x + 2y - 6 = 0',
      xValuesCsv: '-2, 0, 2',
      scaleXStr: '1',
      scaleYStr: '5',
    ),
    LinearEqGraphPreset(
      chipLabel: "Ex 23b #7: 4x - 3y = 5 (General Form & x-Intercept)",
      mode: 1,
      equationStr: '4x - 3y = 5',
      xValuesCsv: '-1, 2, 5',
      scaleXStr: '1',
      scaleYStr: '5',
    ),
  ];

  // ===========================================================================
  // REUSABLE FORMATTING & ALGEBRAIC PARSING HELPERS
  // ===========================================================================
  static String fmt(double v, {int maxDecimals = 2}) {
    if (v.abs() < 1e-9) return '0';
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static String fmtSigned(double v, {bool leadingPlus = true}) {
    if (v.abs() < 1e-9) return leadingPlus ? '+0' : '0';
    final String absStr = fmt(v.abs());
    if (v > 0) return leadingPlus ? '+$absStr' : absStr;
    return '-$absStr';
  }

  /// Textbook semicolon coordinate notation: `(x;y)` (e.g. `(-2;-9)` or `(1.75;0)`)
  static String fmtCoord(double x, double y) {
    return "(${fmt(x)};${fmt(y)})";
  }

  /// Parses comma-separated x-values or a range string like "-3 to 3"
  static List<double> parseXValues(String raw) {
    final String s = raw.trim().replaceAll('+', '');
    if (s.isEmpty) return [-3, -2, -1, 0, 1, 2, 3];

    final RegExp rangeReg =
    RegExp(r'^(-?\d+\.?\d*)\s*(?:to|\.\.)\s*(-?\d+\.?\d*)$', caseSensitive: false);
    final Match? rm = rangeReg.firstMatch(s);
    if (rm != null) {
      final int start = double.parse(rm.group(1)!).round();
      final int end = double.parse(rm.group(2)!).round();
      if (start <= end && (end - start) <= 20) {
        return [for (int i = start; i <= end; i++) i.toDouble()];
      }
    }

    final List<double> vals = [];
    for (final String tok in s.split(RegExp(r'[,;\s]+'))) {
      if (tok.trim().isEmpty) continue;
      final double? v = double.tryParse(tok.trim());
      if (v != null) vals.add(v);
    }
    if (vals.length < 2) {
      throw const FormatException(
          "Please enter at least 2 values of x separated by commas (e.g. -3, -2, -1, 0, 1, 2, 3).");
    }
    return vals;
  }

  /// Parses one side of a linear equation in x and y into {'x': coeffX, 'y': coeffY, 'c': const}
  static Map<String, double> _parseLinearSide(String side) {
    final String s = side
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll('--', '+')
        .replaceAll('+-', '-')
        .replaceAll('-', '+-');

    final List<String> chunks =
    s.split('+').where((c) => c.trim().isNotEmpty).toList();

    double cx = 0.0;
    double cy = 0.0;
    double cc = 0.0;

    for (final String chunk in chunks) {
      if (chunk.contains('x') && chunk.contains('y')) {
        throw const FormatException(
            "A linear equation cannot contain 'xy' product terms.");
      }
      if (chunk.contains('^') || chunk.contains('²') || chunk.contains('³')) {
        throw const FormatException(
            "Variables in a linear equation must have a power (index) of 1.");
      }
      if (chunk.contains('x')) {
        final String numPart = chunk.replaceAll('x', '').trim();
        if (numPart.isEmpty || numPart == '+') {
          cx += 1.0;
        } else if (numPart == '-') {
          cx -= 1.0;
        } else {
          cx += double.parse(numPart);
        }
      } else if (chunk.contains('y')) {
        final String numPart = chunk.replaceAll('y', '').trim();
        if (numPart.isEmpty || numPart == '+') {
          cy += 1.0;
        } else if (numPart == '-') {
          cy -= 1.0;
        } else {
          cy += double.parse(numPart);
        }
      } else {
        cc += double.parse(chunk);
      }
    }
    return {'x': cx, 'y': cy, 'c': cc};
  }

  /// Parses any linear equation (`y = 4x - 7`, `y = 7 - 3x`, `5x + 2y - 6 = 0`, `4x - 3y = 5`, `y = 9`)
  static _ParsedLinearEq parseLinearEquation(String raw) {
    final String clean = raw.trim();
    if (!clean.contains('=')) {
      throw const FormatException(
          "Equation must contain an '=' sign (e.g. y = 4x - 7 or 5x + 2y - 6 = 0).");
    }
    final List<String> sides = clean.split('=');
    if (sides.length != 2 || sides[0].trim().isEmpty || sides[1].trim().isEmpty) {
      throw const FormatException("Invalid linear equation format.");
    }

    final Map<String, double> lhs = _parseLinearSide(sides[0]);
    final Map<String, double> rhs = _parseLinearSide(sides[1]);

    double a = lhs['x']! - rhs['x']!;
    double b = lhs['y']! - rhs['y']!;
    double c = lhs['c']! - rhs['c']!;

    if (a.abs() < 1e-9 && b.abs() < 1e-9) {
      throw const FormatException(
          "Equation must contain at least one variable (x or y).");
    }

    // Normalize sign so that in general form ax + by + c = 0, 'a' is positive (like 4x - y - 7 = 0 on page 208)
    if (a < -1e-9 || (a.abs() < 1e-9 && b < -1e-9)) {
      a = -a;
      b = -b;
      c = -c;
    }

    return _ParsedLinearEq(rawInput: clean, a: a, b: b, c: c);
  }

  /// Formats `y = mx + c` cleanly in LaTeX
  static String formatExplicitLaTeX(_ParsedLinearEq eq) {
    if (eq.isVertical) {
      return "x = ${fmt(-eq.c / eq.a)}";
    }
    final double m = eq.m;
    final double c = eq.yIntercept;
    if (m.abs() < 1e-9) {
      return "y = ${fmt(c)}";
    }
    String mPart = "";
    if ((m - 1.0).abs() < 1e-9) {
      mPart = "x";
    } else if ((m + 1.0).abs() < 1e-9) {
      mPart = "-x";
    } else {
      mPart = "${fmt(m)}x";
    }

    if (c.abs() < 1e-9) return "y = $mPart";
    final String cPart = c > 0 ? "+ ${fmt(c)}" : "- ${fmt(c.abs())}";
    return "y = $mPart $cPart";
  }

  /// Formats `ax + by + c = 0` cleanly in LaTeX (alphabetical order as taught on page 208)
  static String formatGeneralFormLaTeX(_ParsedLinearEq eq) {
    final List<String> parts = [];
    if (eq.a.abs() > 1e-9) {
      if ((eq.a - 1.0).abs() < 1e-9) {
        parts.add("x");
      } else if ((eq.a + 1.0).abs() < 1e-9) {
        parts.add("-x");
      } else {
        parts.add("${fmt(eq.a)}x");
      }
    }
    if (eq.b.abs() > 1e-9) {
      final String sign = parts.isEmpty
          ? (eq.b < 0 ? "-" : "")
          : (eq.b < 0 ? "- " : "+ ");
      final double absB = eq.b.abs();
      final String bCoeff = (absB - 1.0).abs() < 1e-9 ? "" : fmt(absB);
      parts.add("$sign${bCoeff}y");
    }
    if (eq.c.abs() > 1e-9) {
      final String sign = eq.c < 0 ? "- " : "+ ";
      parts.add("$sign${fmt(eq.c.abs())}");
    }
    return "${parts.join(' ')} = 0";
  }

  // ===========================================================================
  // MODE 0: EXPLICIT LINEAR EQUATION GRAPHER (y = mx + c) & GRAPH READER
  // Matches Tables 23.1, 23.2, 23.4, 23.5, Example 1, and Exercise 23a #2–4
  // ===========================================================================
  static LinearEqGraphResult solveExplicitEquation({
    required String equationStr,
    required String xValuesCsv,
    required String queryXStr,
    required String queryYStr,
    required String scaleXStr,
    required String scaleYStr,
  }) {
    try {
      final _ParsedLinearEq eq = parseLinearEquation(equationStr);
      if (eq.isVertical) {
        throw const FormatException(
            "Mode 0 is for equations containing y (y = mx + c). Use Mode 3 for vertical lines.");
      }

      final List<double> xList = parseXValues(xValuesCsv);
      final double scaleX =
      (double.tryParse(scaleXStr.trim()) ?? 1.0).clamp(0.2, 50.0);
      final double scaleY =
      (double.tryParse(scaleYStr.trim()) ?? 5.0).clamp(0.2, 100.0);

      final double m = eq.m;
      final double c = eq.yIntercept;
      final String explicitTex = formatExplicitLaTeX(eq);
      final String generalTex = formatGeneralFormLaTeX(eq);

      final List<String> workings = [];
      final List<LinearEqGraphStep> steps = [];
      final Map<String, String> answers = {};

      // Step 1: Identify Independent/Dependent Variables, m, c & Form of Linear Equation
      workings.add(
          "\\text{\\textbf{Step 1: Identify Variables, Coefficient of }} x \\text{\\textbf{ (m), and Constant (c)}}");
      workings.add(
          "\\text{Equation in Slope-Intercept Form } (y = mx + c): \\quad $explicitTex");
      workings.add(
          "\\bullet \\; x \\text{ is the \\textbf{independent variable}; } y \\text{ is the \\textbf{dependent variable}.}");
      workings.add(
          "\\bullet \\; \\text{Coefficient of } x \\; (m) = ${fmt(m)} \\quad ; \\quad \\text{Constant term } (c) = ${fmt(c)}");
      workings.add(
          "\\bullet \\; \\text{Equivalent General Form } (ax + by + c = 0): \\quad $generalTex");
      workings.add("");

      steps.add(LinearEqGraphStep(
        title: "Step 1: Inspect the Linear Equation ($explicitTex)",
        description:
        "• A linear equation in two variables (x and y) has variables with a power (index) of 1 and no 'xy' terms. Its graph is always a straight line.\n"
            "• We say that y is the dependent variable (because its value depends on x) and x is the independent variable.\n"
            "• Comparing '$explicitTex' with y = mx + c gives m = ${fmt(m)} and c = ${fmt(c)}.\n"
            "• Putting variables in alphabetical order and equating to zero gives the general form: $generalTex.",
        mathLaTeX:
        "$explicitTex \\iff $generalTex \\quad (m = ${fmt(m)}, \\; c = ${fmt(c)})",
      ));

      // Step 2: Explicit Substitution for Every Single x-Value
      workings.add(
          "\\text{\\textbf{Step 2: Calculate }} y \\text{\\textbf{ for Each Value of }} x \\text{\\textbf{ Step-by-Step}}");
      final List<String> subDescriptions = [];
      final List<String> subMathLines = [];
      final List<PlottedPointData> plottedPoints = [];
      final List<String> orderedPairsList = [];

      for (final double xVal in xList) {
        final double mxVal = m * xVal;
        final double yVal = mxVal + c;
        final String coordStr = fmtCoord(xVal, yVal);
        orderedPairsList.add(coordStr);
        plottedPoints.add(PlottedPointData(x: xVal, y: yVal, label: coordStr));

        final String xWrap = xVal < 0 ? "(${fmt(xVal)})" : fmt(xVal);
        final String cSignStr =
        c >= 0 ? "+ ${fmt(c)}" : "- ${fmt(c.abs())}";
        final String stepLine =
            "\\text{When } x = ${fmt(xVal)}: \\quad y = ${fmt(m)}$xWrap $cSignStr = ${fmt(mxVal)} $cSignStr = ${fmt(yVal)} \\implies \\text{$coordStr}";
        workings.add(stepLine);
        subMathLines.add(stepLine);
        subDescriptions.add(
            "• When x = ${fmt(xVal)}: Multiply ${fmt(m)} × ${fmt(xVal)} = ${fmt(mxVal)}, then ${c >= 0 ? 'add ${fmt(c)}' : 'subtract ${fmt(c.abs())}'} → y = ${fmt(mxVal)} $cSignStr = ${fmt(yVal)}. Ordered pair = $coordStr.");
      }
      workings.add("");

      steps.add(LinearEqGraphStep(
        title: "Step 2: Substitute Each Value of x to Find Corresponding y",
        description:
        "Substitute each chosen value of x into '$explicitTex' one by one, multiplying by ${fmt(m)} first and then combining with ${fmt(c)}:\n\n"
            "${subDescriptions.join('\n')}",
        mathLaTeX: subMathLines.join('\n'),
      ));

      // Step 3: Build the 4-Row Textbook Breakdown Table (Tables 23.1, 23.2 & 23.5)
      final int colCount = xList.length;
      final String colSpec = List.filled(colCount + 1, 'c').join('|');
      final String rowX = xList.map(fmt).join(' & ');
      final String rowMx = xList.map((x) => fmt(m * x)).join(' & ');
      final String rowC =
      xList.map((_) => fmtSigned(c, leadingPlus: false)).join(' & ');
      final String rowY = xList.map((x) => fmt(m * x + c)).join(' & ');
      final String mxHeader =
      (m - 1.0).abs() < 1e-9 ? "x" : ((m + 1.0).abs() < 1e-9 ? "-x" : "${fmt(m)}x");
      final String cHeader = fmtSigned(c, leadingPlus: true);

      final String tableLatex = "\\begin{array}{|$colSpec|} \\hline "
          "x & $rowX \\\\ \\hline "
          "$mxHeader & $rowMx \\\\ "
          "$cHeader & $rowC \\\\ \\hline "
          "$explicitTex & $rowY \\\\ \\hline "
          "\\end{array}";

      workings.add(
          "\\text{\\textbf{Step 3: Textbook 4-Row Table of Values (Tables 23.1 \\& 23.2)}}");
      workings.add(tableLatex);
      workings.add(
          "\\text{Ordered Pairs (Coordinates): } ${orderedPairsList.join(', \\; ')}");
      workings.add("");

      steps.add(LinearEqGraphStep(
        title:
        "Step 3: Construct the 4-Row Table of Values & Write Ordered Pairs (x;y)",
        description:
        "Just like Tables 23.1, 23.2, and 23.5 in the textbook:\n"
            "• Row 1 lists the given values of x.\n"
            "• Row 2 calculates '$mxHeader' for each column.\n"
            "• Row 3 writes the constant '$cHeader' across every column.\n"
            "• Row 4 adds Row 2 and Row 3 vertically to get y!\n"
            "• Ordered pairs (using textbook semicolon notation so decimals are never confused with commas): ${orderedPairsList.join(', ')}.\n"
            "• Note: Always plot at least 3 points. Since all ${plottedPoints.length} points lie in a straight line, our working is correct!",
        mathLaTeX: tableLatex,
      ));

      answers["Equation"] = explicitTex.replaceAll('\\', '');
      answers["Ordered Pairs"] =
      "${orderedPairsList.first}, ..., ${orderedPairsList.last}";

      // Step 4: Graphical Interpolation Queries (Example 1a & 1b: Find y when x = ..., Find x when y = ...)
      final List<GraphTraceQuery> traces = [];
      final double? qX = double.tryParse(queryXStr.trim());
      final double? qY = double.tryParse(queryYStr.trim());

      if (qX != null || qY != null) {
        workings.add(
            "\\text{\\textbf{Step 4: Reading Values from the Graph (Example 1a \\& 1b)}}");
        final List<String> readDesc = [];
        final List<String> readMath = [];

        if (qX != null) {
          final double ansY = eq.evaluateY(qX);
          traces.add(GraphTraceQuery(
            markerLabel: 'a',
            givenX: true,
            xVal: qX,
            yVal: ansY,
          ));
          final String cSign = c >= 0 ? "+ ${fmt(c)}" : "- ${fmt(c.abs())}";
          workings.add(
              "\\text{(a) When } x = ${fmt(qX)}: \\quad y = ${fmt(m)}(${fmt(qX)}) $cSign = ${fmt(m * qX)} $cSign = ${fmt(ansY)} \\implies \\text{${fmtCoord(qX, ansY)}}");
          readDesc.add(
              "• (a) To find y when x = ${fmt(qX)} from the graph (dotted line 'a'):\n"
                  "  Start at ${fmt(qX)} on the x-axis, move vertically to meet the line, then move horizontally to the y-axis to read y = ${fmt(ansY)} (Point ${fmtCoord(qX, ansY)}).");
          readMath.add(
              "\\text{When } x = ${fmt(qX)}, \\; y = ${fmt(m)}(${fmt(qX)}) $cSign = ${fmt(ansY)}");
          answers["When x = ${fmt(qX)}"] = "y = ${fmt(ansY)}";
        }

        if (qY != null && !eq.isHorizontal) {
          final double ansX = eq.evaluateX(qY);
          traces.add(GraphTraceQuery(
            markerLabel: 'b',
            givenX: false,
            xVal: ansX,
            yVal: qY,
          ));
          final double rhsAfterC = qY - c;
          final String oppCSign =
          c < 0 ? "+ ${fmt(c.abs())}" : "- ${fmt(c)}";
          workings.add(
              "\\text{(b) When } y = ${fmt(qY)}: \\quad ${fmt(m)}x ${c >= 0 ? '+ ${fmt(c)}' : '- ${fmt(c.abs())}'} = ${fmt(qY)} \\implies ${fmt(m)}x = ${fmt(qY)} $oppCSign = ${fmt(rhsAfterC)} \\implies x = \\frac{${fmt(rhsAfterC)}}{${fmt(m)}} = ${fmt(ansX)}");
          readDesc.add(
              "• (b) To find x when y = ${fmt(qY)} from the graph (dotted line 'b'):\n"
                  "  Start at ${fmt(qY)} on the y-axis, move horizontally to meet the line, then move vertically to the x-axis to read x = ${fmt(ansX)} (Point ${fmtCoord(ansX, qY)}).");
          readMath.add(
              "\\text{When } y = ${fmt(qY)}, \\; ${fmt(m)}x = ${fmt(rhsAfterC)} \\implies x = \\frac{${fmt(rhsAfterC)}}{${fmt(m)}} = ${fmt(ansX)}");
          answers["When y = ${fmt(qY)}"] = "x = ${fmt(ansX)}";
        }
        workings.add("");

        steps.add(LinearEqGraphStep(
          title: "Step 4: Read Values from the Graph (Dotted Trace Lines)",
          description: readDesc.join('\n\n'),
          mathLaTeX: readMath.join('\n'),
        ));
      }

      // Step 5: Coordinates Where the Line Cuts the Axes (x-intercept & y-intercept)
      final PlottedPointData yIntPt = PlottedPointData(
        x: 0.0,
        y: c,
        label: fmtCoord(0.0, c),
      );
      PlottedPointData? xIntPt;

      workings.add(
          "\\text{\\textbf{Step ${traces.isNotEmpty ? 5 : 4}: Coordinates Where the Line Cuts the Axes (Intercepts)}}");
      workings.add(
          "\\bullet \\text{ Cuts the } y\\text{-axis when } x = 0: \\quad y = ${fmt(m)}(0) ${c >= 0 ? '+ ${fmt(c)}' : '- ${fmt(c.abs())}'} = ${fmt(c)} \\implies \\text{\\textbf{${fmtCoord(0, c)}}}");

      String xIntDesc = "The line is horizontal and does not cross the x-axis.";
      String xIntMath = "\\text{Cuts } y\\text{-axis at } ${fmtCoord(0, c)}";

      if (eq.xIntercept != null) {
        final double xIntVal = eq.xIntercept!;
        xIntPt = PlottedPointData(
          x: xIntVal,
          y: 0.0,
          label: fmtCoord(xIntVal, 0.0),
        );
        workings.add(
            "\\bullet \\text{ Cuts the } x\\text{-axis when } y = 0: \\quad ${fmt(m)}x ${c >= 0 ? '+ ${fmt(c)}' : '- ${fmt(c.abs())}'} = 0 \\implies ${fmt(m)}x = ${fmt(-c)} \\implies x = \\frac{${fmt(-c)}}{${fmt(m)}} = ${fmt(xIntVal)} \\implies \\text{\\textbf{${fmtCoord(xIntVal, 0)}}}");
        xIntDesc =
        "• Where the line cuts the x-axis (set y = 0): Solve ${fmt(m)}x ${c >= 0 ? '+ ${fmt(c)}' : '- ${fmt(c.abs())}'} = 0 → ${fmt(m)}x = ${fmt(-c)} → x = ${fmt(-c)} ÷ ${fmt(m)} = ${fmt(xIntVal)}. Coordinates = ${fmtCoord(xIntVal, 0)}.";
        xIntMath =
        "\\text{Cuts } y\\text{-axis } (x=0): \\; ${fmtCoord(0, c)} \\quad ; \\quad \\text{Cuts } x\\text{-axis } (y=0): \\; ${fmtCoord(xIntVal, 0)}";
        answers["Cuts x-axis at"] = fmtCoord(xIntVal, 0);
      }
      answers["Cuts y-axis at"] = fmtCoord(0, c);

      steps.add(LinearEqGraphStep(
        title:
        "Step ${traces.isNotEmpty ? 5 : 4}: Find Where the Line Cuts the Axes (Example 1c)",
        description:
        "• Where the line cuts the y-axis (set x = 0): Substitute x = 0 into '$explicitTex' to get y = ${fmt(c)}. Coordinates = ${fmtCoord(0, c)}.\n"
            "$xIntDesc",
        mathLaTeX: xIntMath,
      ));

      return LinearEqGraphResult(
        mode: 0,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: CartesianCanvasData(
          lines: [
            LineSeriesData(
              equationLabel: explicitTex.replaceAll('\\', ''),
              a: eq.a,
              b: eq.b,
              c: eq.c,
              points: plottedPoints,
              color: Colors.deepPurple,
            ),
          ],
          traces: traces,
          xIntercept: xIntPt,
          yIntercept: yIntPt,
          scaleXUnitsPer2Cm: scaleX,
          scaleYUnitsPer2Cm: scaleY,
          scaleBannerText:
          "Scale: 2 cm to ${fmt(scaleX)} unit(s) on x-axis; 2 cm to ${fmt(scaleY)} unit(s) on y-axis",
          headerBadge: "Graph of  ${explicitTex.replaceAll('\\', '')}",
        ),
      );
    } catch (e) {
      return LinearEqGraphResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter a valid linear equation (e.g. y = 4x - 7 or y = 7 - 3x).",
      );
    }
  }

  // ===========================================================================
  // MODE 1: GENERAL FORM EQUATION GRAPHER (ax + by + c = 0 / ax + by = d)
  // Matches Example 2 (Table 23.6, Figure 23.4) & Exercise 23b #1–10
  // ===========================================================================
  static LinearEqGraphResult solveGeneralFormEquation({
    required String equationStr,
    required String xValuesCsv,
    required String scaleXStr,
    required String scaleYStr,
  }) {
    try {
      final _ParsedLinearEq eq = parseLinearEquation(equationStr);
      if (eq.isVertical) {
        throw const FormatException(
            "Please include both x and y in the general linear equation.");
      }

      final List<double> xList = parseXValues(xValuesCsv);
      final double scaleX =
      (double.tryParse(scaleXStr.trim()) ?? 1.0).clamp(0.2, 50.0);
      final double scaleY =
      (double.tryParse(scaleYStr.trim()) ?? 5.0).clamp(0.2, 100.0);

      final String generalTex = formatGeneralFormLaTeX(eq);
      final String explicitTex = formatExplicitLaTeX(eq);

      final List<String> workings = [];
      final List<LinearEqGraphStep> steps = [];
      final Map<String, String> answers = {};

      // Step 1: Inspect General Form ax + by + c = 0
      workings.add(
          "\\text{\\textbf{Step 1: Arrange in General Form }} ax + by + c = 0 \\text{\\textbf{ (Page 208)}}");
      workings.add(
          "\\text{Given Equation: } ${eq.rawInput} \\implies \\text{General Form: } $generalTex");
      workings.add(
          "a = ${fmt(eq.a)}, \\quad b = ${fmt(eq.b)}, \\quad c = ${fmt(eq.c)} \\quad (\\text{Explicit form: } $explicitTex)");
      workings.add("");

      steps.add(LinearEqGraphStep(
        title: "Step 1: Identify a, b, and c in General Form ($generalTex)",
        description:
        "Putting the variables in alphabetical order (x then y) and equating to zero gives the general form ax + by + c = 0:\n"
            "• Here a = ${fmt(eq.a)}, b = ${fmt(eq.b)}, and c = ${fmt(eq.c)}.\n"
            "• (Making y the subject also gives $explicitTex).",
        mathLaTeX:
        "$generalTex \\quad (a = ${fmt(eq.a)}, \\; b = ${fmt(eq.b)}, \\; c = ${fmt(eq.c)})",
      ));

      // Step 2: Calculate y for Each Chosen x Using the Example 2 Balance Method
      workings.add(
          "\\text{\\textbf{Step 2: Calculate Values in the Table of Values (Example 2 Method)}}");
      final List<String> calcDescriptions = [];
      final List<String> calcMathLines = [];
      final List<PlottedPointData> plottedPoints = [];
      final List<String> orderedPairs = [];

      for (final double xVal in xList) {
        final double axVal = eq.a * xVal;
        final double constSum = axVal + eq.c;
        final double rhsVal = -constSum;
        final double yVal = rhsVal / eq.b;
        final String coordStr = fmtCoord(xVal, yVal);
        orderedPairs.add(coordStr);
        plottedPoints.add(PlottedPointData(x: xVal, y: yVal, label: coordStr));

        final String bTerm = (eq.b - 1.0).abs() < 1e-9
            ? "+ y"
            : ((eq.b + 1.0).abs() < 1e-9
            ? "- y"
            : "${fmtSigned(eq.b)}y");
        final String cTerm =
        eq.c.abs() < 1e-9 ? "" : " ${fmtSigned(eq.c)}";

        final String lineTex =
            "\\text{When } x = ${fmt(xVal)}: \\quad ${fmt(axVal)} $bTerm$cTerm = 0 \\implies ${fmt(eq.b)}y = ${fmt(rhsVal)} \\implies y = \\frac{${fmt(rhsVal)}}{${fmt(eq.b)}} = ${fmt(yVal)} \\implies \\text{$coordStr}";
        workings.add(lineTex);
        calcMathLines.add(lineTex);
        calcDescriptions.add(
            "• When x = ${fmt(xVal)}: Substitute x = ${fmt(xVal)} into '$generalTex':\n"
                "  ${fmt(eq.a)}(${fmt(xVal)}) $bTerm$cTerm = 0 → ${fmt(eq.b)}y ${fmtSigned(constSum)} = 0 → ${fmt(eq.b)}y = ${fmt(rhsVal)} → y = ${fmt(rhsVal)} ÷ ${fmt(eq.b)} = ${fmt(yVal)}. Point = $coordStr.");
      }
      workings.add("");

      steps.add(LinearEqGraphStep(
        title:
        "Step 2: Substitute Each Value of x and Solve for y (Example 2)",
        description:
        "Just as in Example 2 on page 208, substitute each chosen x-value into '$generalTex' and solve the resulting linear equation for y:\n\n"
            "${calcDescriptions.join('\n\n')}",
        mathLaTeX: calcMathLines.join('\n'),
      ));

      // Step 3: Table 23.6 Style Table of Values
      final String colSpec = List.filled(xList.length + 1, 'c').join('|');
      final String rowX = xList.map(fmt).join(' & ');
      final String rowY = xList.map((x) => fmt(eq.evaluateY(x))).join(' & ');
      final String table23_6 = "\\begin{array}{|$colSpec|} \\hline "
          "x & $rowX \\\\ \\hline "
          "y & $rowY \\\\ \\hline "
          "\\end{array}";

      workings.add("\\text{\\textbf{Step 3: Completed Table of Values (Table 23.6 Style)}}");
      workings.add(table23_6);
      workings.add(
          "\\text{Coordinates to Plot: } ${orderedPairs.join(', \\; ')}");
      workings.add("");

      steps.add(LinearEqGraphStep(
        title: "Step 3: Complete the Table of Values & Plot the 3+ Points",
        description:
        "Record the corresponding values of x and y in the table of values (Table 23.6 style) and plot the coordinates ${orderedPairs.join(', ')} on the Cartesian plane. Join them with a straight ruler line.",
        mathLaTeX: table23_6,
      ));

      // Step 4: Find Where the Graph Cuts the x-Axis and y-Axis (Example 2b & Exercise 23b)
      final double yIntVal = eq.yIntercept;
      final PlottedPointData yIntPt = PlottedPointData(
        x: 0.0,
        y: yIntVal,
        label: fmtCoord(0.0, yIntVal),
      );
      PlottedPointData? xIntPt;

      workings.add(
          "\\text{\\textbf{Step 4: Find Where the Graph Crosses the }} x\\text{\\textbf{-Axis and }} y\\text{\\textbf{-Axis}}");
      String xCrossTex = "";
      String xCrossDesc = "";

      if (eq.xIntercept != null) {
        final double xIntVal = eq.xIntercept!;
        xIntPt = PlottedPointData(
          x: xIntVal,
          y: 0.0,
          label: fmtCoord(xIntVal, 0.0),
        );
        xCrossTex =
        "\\text{Crosses } x\\text{-axis when } y = 0: \\quad ${fmt(eq.a)}x + ${fmt(eq.b)}(0) ${eq.c.abs() < 1e-9 ? '' : fmtSigned(eq.c)} = 0 \\implies ${fmt(eq.a)}x = ${fmt(-eq.c)} \\implies x = \\frac{${fmt(-eq.c)}}{${fmt(eq.a)}} = ${fmt(xIntVal)} \\implies \\text{\\textbf{${fmtCoord(xIntVal, 0)}}}";
        workings.add(xCrossTex);
        xCrossDesc =
        "• Crosses the x-axis (set y = 0): Substitute y = 0 into '$generalTex' → ${fmt(eq.a)}x = ${fmt(-eq.c)} → x = ${fmt(-eq.c)} ÷ ${fmt(eq.a)} = ${fmt(xIntVal)}. Therefore, the graph cuts the x-axis at ${fmtCoord(xIntVal, 0)}!";
        answers["Crosses x-axis at"] = fmtCoord(xIntVal, 0);
      }

      workings.add(
          "\\text{Crosses } y\\text{-axis when } x = 0: \\quad ${fmt(eq.a)}(0) + ${fmt(eq.b)}y ${eq.c.abs() < 1e-9 ? '' : fmtSigned(eq.c)} = 0 \\implies ${fmt(eq.b)}y = ${fmt(-eq.c)} \\implies y = ${fmt(yIntVal)} \\implies \\text{\\textbf{${fmtCoord(0, yIntVal)}}}");

      steps.add(LinearEqGraphStep(
        title:
        "Step 4: Find Where the Line Crosses the x-Axis (Example 2b & Exercise 23b)",
        description:
        "$xCrossDesc\n"
            "• Crosses the y-axis (set x = 0): Substitute x = 0 into '$generalTex' → ${fmt(eq.b)}y = ${fmt(-eq.c)} → y = ${fmt(yIntVal)}. Coordinates = ${fmtCoord(0, yIntVal)}.",
        mathLaTeX:
        "$xCrossTex\n\\text{Crosses } y\\text{-axis at } ${fmtCoord(0, yIntVal)}",
      ));

      answers["Crosses y-axis at"] = fmtCoord(0, yIntVal);
      answers["Ordered Pairs"] = orderedPairs.join(', ');
      answers["Explicit Form"] = explicitTex.replaceAll('\\', '');

      return LinearEqGraphResult(
        mode: 1,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: CartesianCanvasData(
          lines: [
            LineSeriesData(
              equationLabel: eq.rawInput,
              a: eq.a,
              b: eq.b,
              c: eq.c,
              points: plottedPoints,
              color: Colors.deepPurple,
            ),
          ],
          xIntercept: xIntPt,
          yIntercept: yIntPt,
          scaleXUnitsPer2Cm: scaleX,
          scaleYUnitsPer2Cm: scaleY,
          scaleBannerText:
          "Scale: 2 cm to ${fmt(scaleX)} unit(s) on x-axis; 2 cm to ${fmt(scaleY)} unit(s) on y-axis",
          headerBadge: "Graph of  ${eq.rawInput}",
        ),
      );
    } catch (e) {
      return LinearEqGraphResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter a valid general linear equation (e.g. 5x + 2y - 6 = 0 or 4x - 3y = 5).",
      );
    }
  }

  // ===========================================================================
  // MODE 2: POINT INSPECTOR & MISSING COORDINATES SOLVER
  // Sub-Mode 0: Check Plotted Points A, B, C for Errors (Exercise 23a #1 / Fig 23.3)
  // Sub-Mode 1: Calculate Unknown Coordinates A(x1;a), B(x2;b), C(x3;c) (Ex 23a #5)
  // ===========================================================================
  static Map<String, double> _parseCoordPair(String raw, String ptName) {
    final String s = raw
        .trim()
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(RegExp(r'^[a-zA-Z]\s*'), '');
    final List<String> parts = s.split(RegExp(r'[;,]'));
    if (parts.length != 2) {
      throw FormatException(
          "Enter point $ptName as x;y or x,y (e.g. -3;-5).");
    }
    return {
      'x': double.parse(parts[0].trim()),
      'y': double.parse(parts[1].trim()),
    };
  }

  static LinearEqGraphResult solvePointInspector({
    required int subMode, // 0: Spot Wrong Point (Ex 23a #1), 1: Find a, b, c (Ex 23a #5)
    required String equationStr,
    required String pointAStr,
    required String pointBStr,
    required String pointCStr,
    required String xValuesCsv,
    required String scaleXStr,
    required String scaleYStr,
  }) {
    try {
      final _ParsedLinearEq eq = parseLinearEquation(equationStr);
      final String explicitTex = formatExplicitLaTeX(eq);
      final double scaleX =
      (double.tryParse(scaleXStr.trim()) ?? 1.0).clamp(0.2, 50.0);
      final double scaleY =
      (double.tryParse(scaleYStr.trim()) ?? 5.0).clamp(0.2, 100.0);

      final List<String> workings = [];
      final List<LinearEqGraphStep> steps = [];
      final Map<String, String> answers = {};

      if (subMode == 0) {
        // Sub-Mode 2A: Exercise 23a #1 (Figure 23.3 & Table 23.3)
        final Map<String, double> pA = _parseCoordPair(pointAStr, 'A');
        final Map<String, double> pB = _parseCoordPair(pointBStr, 'B');
        final Map<String, double> pC = _parseCoordPair(pointCStr, 'C');

        final List<Map<String, dynamic>> rawPts = [
          {'name': 'A', 'x': pA['x']!, 'y': pA['y']!},
          {'name': 'B', 'x': pB['x']!, 'y': pB['y']!},
          {'name': 'C', 'x': pC['x']!, 'y': pC['y']!},
        ];

        workings.add(
            "\\text{\\textbf{Step 1: Complete Table 23.3 for }} $explicitTex");
        final List<String> checkDesc = [];
        final List<String> checkMath = [];
        final List<PlottedPointData> canvasPts = [];
        final List<String> wrongNames = [];
        final List<String> correctNames = [];

        for (final pt in rawPts) {
          final String name = pt['name'] as String;
          final double x = pt['x'] as double;
          final double plottedY = pt['y'] as double;
          final double trueY = eq.evaluateY(x);
          final bool isWrong = (plottedY - trueY).abs() > 1e-6;

          if (isWrong) {
            wrongNames.add("$name${fmtCoord(x, plottedY)} → should be ${fmtCoord(x, trueY)}");
          } else {
            correctNames.add("$name${fmtCoord(x, plottedY)}");
          }

          canvasPts.add(PlottedPointData(
            x: x,
            y: plottedY,
            label: "$name${fmtCoord(x, plottedY)}",
            isErrorPoint: isWrong,
            correctedY: trueY,
          ));

          final String verdict = isWrong
              ? "\\text{INCORRECT (Plotted } ${fmt(plottedY)} \\text{ instead of } ${fmt(trueY)}\\text{)}"
              : "\\text{CORRECT}";
          final String line =
              "\\text{Point } $name \\; (x = ${fmt(x)}): \\quad \\text{True } y = ${fmt(trueY)}, \\; \\text{Plotted } y = ${fmt(plottedY)} \\implies $verdict";
          workings.add(line);
          checkMath.add(line);
          checkDesc.add(
              "• Point $name${fmtCoord(x, plottedY)}: When x = ${fmt(x)}, the equation '$explicitTex' gives y = ${fmt(trueY)}. "
                  "${isWrong ? 'Since the student plotted y = ${fmt(plottedY)}, Point $name is INCORRECT (should be ${fmtCoord(x, trueY)})!' : 'This matches the student\'s point, so Point $name is CORRECT!'}");
        }

        final String table23_3 = "\\begin{array}{|c|c|c|c|} \\hline "
            "x & ${fmt(pA['x']!)} & ${fmt(pB['x']!)} & ${fmt(pC['x']!)} \\\\ \\hline "
            "$explicitTex & ${fmt(eq.evaluateY(pA['x']!))} & ${fmt(eq.evaluateY(pB['x']!))} & ${fmt(eq.evaluateY(pC['x']!))} \\\\ \\hline "
            "\\end{array}";

        workings.add("");
        workings.add("\\text{\\textbf{Step 2: Completed Table 23.3}}");
        workings.add(table23_3);

        steps.add(LinearEqGraphStep(
          title:
          "Step 1: Why We Plot 3 Points to Catch Mistakes (Exercise 23a #1)",
          description:
          "Since the graph of a linear equation is always a straight line, if three plotted points A, B, C do NOT lie on a straight line, one or more of them must be incorrect!\n\n"
              "${checkDesc.join('\n\n')}",
          mathLaTeX: checkMath.join('\n'),
        ));

        steps.add(LinearEqGraphStep(
          title: "Step 2: Complete Table 23.3 & Identify the Incorrect Point(s)",
          description: wrongNames.isEmpty
              ? "All three points A, B, and C satisfy '$explicitTex' and lie on a straight line!"
              : "Completing Table 23.3 proves:\n"
              "• Correct point(s): ${correctNames.isEmpty ? 'None' : correctNames.join(', ')}\n"
              "• Incorrect point(s): ${wrongNames.join('; ')}",
          mathLaTeX: table23_3,
        ));

        answers["Incorrect Point(s)"] =
        wrongNames.isEmpty ? "None (All Correct!)" : wrongNames.join('; ');
        answers["Correct Point(s)"] =
        correctNames.isEmpty ? "None" : correctNames.join(', ');

        return LinearEqGraphResult(
          mode: 2,
          subMode: 0,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          canvasData: CartesianCanvasData(
            lines: [
              LineSeriesData(
                equationLabel: explicitTex.replaceAll('\\', ''),
                a: eq.a,
                b: eq.b,
                c: eq.c,
                points: canvasPts,
                color: Colors.deepPurple,
              ),
            ],
            scaleXUnitsPer2Cm: scaleX,
            scaleYUnitsPer2Cm: scaleY,
            scaleBannerText:
            "Red Cross = Student Mistake | Green Cross = Corrected Point on Line",
            headerBadge:
            "Point Inspector (Fig 23.3):  ${explicitTex.replaceAll('\\', '')}",
          ),
        );
      } else {
        // Sub-Mode 2B: Calculate Unknown Coordinates A(x1;a), B(x2;b), C(x3;c) (Exercise 23a #5)
        final List<double> xVals = parseXValues(xValuesCsv);
        final List<String> ptNames = ['A', 'B', 'C', 'D', 'E'];
        final List<String> unkVars = ['a', 'b', 'c', 'd', 'e'];

        workings.add(
            "\\text{\\textbf{Step 1: Substitute Each }} x\\text{\\textbf{-Coordinate into }} $explicitTex \\text{\\textbf{ (Ex 23a \\#5)}}");
        final List<String> descLines = [];
        final List<String> mathLines = [];
        final List<PlottedPointData> pts = [];

        for (int i = 0; i < xVals.length && i < 5; i++) {
          final double x = xVals[i];
          final double y = eq.evaluateY(x);
          final String pName = ptNames[i];
          final String uVar = unkVars[i];
          final String coord = "$pName${fmtCoord(x, y)}";

          pts.add(PlottedPointData(x: x, y: y, label: coord));
          final String cSign =
          eq.yIntercept >= 0 ? "+ ${fmt(eq.yIntercept)}" : "- ${fmt(eq.yIntercept.abs())}";
          final String mLine =
              "\\text{For } $pName(${fmt(x)};$uVar): \\quad $uVar = ${fmt(eq.m)}(${fmt(x)}) $cSign = ${fmt(eq.m * x)} $cSign = ${fmt(y)} \\implies $coord";
          workings.add(mLine);
          mathLines.add(mLine);
          descLines.add(
              "• Point $pName(${fmt(x)};$uVar): Substitute x = ${fmt(x)} and y = $uVar into '$explicitTex' → $uVar = ${fmt(y)}. Thus $coord.");
          answers["$uVar (for $pName)"] = "$uVar = ${fmt(y)}  →  $coord";
        }

        steps.add(LinearEqGraphStep(
          title:
          "Step 1: Calculate Unknown Coordinates a, b, c on Line ($explicitTex)",
          description:
          "Since the points lie on the straight line '$explicitTex', their coordinates must satisfy the equation:\n\n"
              "${descLines.join('\n\n')}\n\n"
              "• Plotting these points and joining them gives the straight line ABC!",
          mathLaTeX: mathLines.join('\n'),
        ));

        return LinearEqGraphResult(
          mode: 2,
          subMode: 1,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          canvasData: CartesianCanvasData(
            lines: [
              LineSeriesData(
                equationLabel: explicitTex.replaceAll('\\', ''),
                a: eq.a,
                b: eq.b,
                c: eq.c,
                points: pts,
                color: Colors.deepPurple,
              ),
            ],
            scaleXUnitsPer2Cm: scaleX,
            scaleYUnitsPer2Cm: scaleY,
            headerBadge:
            "Line ABC:  ${explicitTex.replaceAll('\\', '')}",
          ),
        );
      }
    } catch (e) {
      return LinearEqGraphResult.error(
        mode: 2,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please check your equation and point coordinates (e.g. -3;-5).",
      );
    }
  }

  // ===========================================================================
  // MODE 3: MULTI-LINE COMPARATOR (Parallel Families, Common Intercepts & Intersection)
  // Matches Exercise 23a #6, #7, #8 & Figure 23.5
  // ===========================================================================
  static LinearEqGraphResult solveMultiLineComparator({
    required List<String> equationStrings,
    required String xValuesCsv,
    required String scaleXStr,
    required String scaleYStr,
  }) {
    try {
      final List<String> nonEmpty = equationStrings
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (nonEmpty.length < 2) {
        throw const FormatException(
            "Please enter at least 2 linear equations to compare on the same axes.");
      }

      final List<_ParsedLinearEq> parsedList =
      nonEmpty.map(parseLinearEquation).toList();
      final List<double> xList = parseXValues(xValuesCsv);
      final double scaleX =
      (double.tryParse(scaleXStr.trim()) ?? 2.0).clamp(0.2, 50.0);
      final double scaleY =
      (double.tryParse(scaleYStr.trim()) ?? 5.0).clamp(0.2, 100.0);

      const List<Color> palette = [
        Colors.deepPurple,
        Color(0xFF2E7D32), // Green 800
        Color(0xFFE65100), // Orange 900
        Color(0xFF1565C0), // Blue 800
      ];

      final List<String> workings = [];
      final List<LinearEqGraphStep> steps = [];
      final Map<String, String> answers = {};
      final List<LineSeriesData> seriesList = [];

      // Step 1: Inspect m and c for Each Line
      workings.add(
          "\\text{\\textbf{Step 1: Compare Slope-Intercept Form }} (y = mx + c) \\text{\\textbf{ of Each Line}}");
      final List<String> inspectDesc = [];
      final List<String> inspectMath = [];

      for (int i = 0; i < parsedList.length; i++) {
        final _ParsedLinearEq eq = parsedList[i];
        final String expTex = formatExplicitLaTeX(eq);
        final String line =
            "\\text{Line ${i + 1} } (${eq.rawInput}): \\quad $expTex \\implies m = ${fmt(eq.m)}, \\; c = ${fmt(eq.yIntercept)}";
        workings.add(line);
        inspectMath.add(line);
        inspectDesc.add(
            "• Line ${i + 1} (${eq.rawInput}): Arranged as $expTex → coefficient of x (m) = ${fmt(eq.m)}, y-intercept (c) = ${fmt(eq.yIntercept)}.");

        final List<PlottedPointData> pts = xList.map((x) {
          final double y = eq.evaluateY(x);
          return PlottedPointData(x: x, y: y, label: fmtCoord(x, y));
        }).toList();

        seriesList.add(LineSeriesData(
          equationLabel: eq.rawInput,
          a: eq.a,
          b: eq.b,
          c: eq.c,
          points: pts,
          color: palette[i % palette.length],
        ));
      }
      workings.add("");

      steps.add(LinearEqGraphStep(
        title: "Step 1: Compare the Coefficient of x (m) and Constant (c) of Each Equation",
        description: inspectDesc.join('\n'),
        mathLaTeX: inspectMath.join('\n'),
      ));

      // Step 2: Combined Multi-Line Table of Values
      final String colSpec = List.filled(xList.length + 1, 'c').join('|');
      final String headerRow = "x & ${xList.map(fmt).join(' & ')} \\\\ \\hline ";
      final List<String> bodyRows = [];
      for (final _ParsedLinearEq eq in parsedList) {
        final String yCells =
        xList.map((x) => fmt(eq.evaluateY(x))).join(' & ');
        bodyRows.add("${eq.rawInput} & $yCells \\\\ \\hline ");
      }
      final String combinedTable =
          "\\begin{array}{|$colSpec|} \\hline $headerRow${bodyRows.join('')}\\end{array}";

      workings.add("\\text{\\textbf{Step 2: Combined Table of Values for All Lines}}");
      workings.add(combinedTable);
      workings.add("");

      steps.add(LinearEqGraphStep(
        title: "Step 2: Prepare the Combined Table of Values on the Same Range",
        description:
        "Calculate the corresponding values of y for each equation from x = ${fmt(xList.first)} to x = ${fmt(xList.last)} and plot all lines on the same Cartesian axes.",
        mathLaTeX: combinedTable,
      ));

      // Step 3: "What Do You Notice?" Pattern Detection (Parallel vs Common Intercept vs Intersection)
      final double firstM = parsedList.first.m;
      final double firstC = parsedList.first.yIntercept;
      final bool allSameM =
      parsedList.every((e) => !e.isVertical && (e.m - firstM).abs() < 1e-6);
      final bool allSameC =
      parsedList.every((e) => !e.isVertical && (e.yIntercept - firstC).abs() < 1e-6);

      PlottedPointData? intersectionPt;
      workings.add(
          "\\text{\\textbf{Step 3: What Do You Notice About the Lines? (Geometric Conclusion)}}");

      if (allSameM) {
        workings.add(
            "\\bullet \\text{ Every equation has the exact same coefficient of } x \\; (m = ${fmt(firstM)}).");
        workings.add(
            "\\bullet \\text{ \\textbf{Conclusion:} All the lines are \\textbf{PARALLEL} to each other and never meet!}");

        steps.add(LinearEqGraphStep(
          title:
          "Step 3: What Do You Notice? — Parallel Lines (Exercise 23a #6 & Fig 23.5)",
          description:
          "• Notice that all ${parsedList.length} equations have the exact same coefficient of x (m = ${fmt(firstM)}).\n"
              "• Textbook Rule (page 208): 'If linear equations in the form y = mx + c have the same coefficients of x, then their graphs will be parallel.'\n"
              "• Therefore, all the lines are parallel to each other!",
          mathLaTeX:
          "m_1 = m_2 = ${fmt(firstM)} \\implies \\text{\\textbf{The lines are PARALLEL}}",
        ));

        answers["What You Notice"] = "All lines are PARALLEL";
        answers["Common Slope (m)"] = "m = ${fmt(firstM)}";
      } else if (allSameC) {
        final String commonPt = fmtCoord(0, firstC);
        intersectionPt = PlottedPointData(x: 0, y: firstC, label: commonPt);
        workings.add(
            "\\bullet \\text{ Every equation has the exact same constant term } (c = ${fmt(firstC)}).");
        workings.add(
            "\\bullet \\text{ \\textbf{Conclusion:} All the lines pass through (intersect at) the exact same point on the } y\\text{-axis: \\textbf{$commonPt}!}");

        steps.add(LinearEqGraphStep(
          title:
          "Step 3: What Do You Notice? — Common y-Intercept (Exercise 23a #7)",
          description:
          "• Notice that when x = 0, every single equation gives y = ${fmt(firstC)} (they all share the same constant term c = ${fmt(firstC)}).\n"
              "• Therefore, all the lines pass through (meet at) the exact same point on the y-axis: $commonPt!",
          mathLaTeX:
          "\\text{When } x = 0, \\; y = ${fmt(firstC)} \\implies \\text{All lines pass through } \\mathbf{$commonPt}",
        ));

        answers["What You Notice"] = "All cut y-axis at $commonPt";
        answers["Common Point"] = commonPt;
      } else {
        // Solve for intersection of first two lines (e.g. Exercise 23a #8: y = 4x and y = 9)
        final _ParsedLinearEq L1 = parsedList[0];
        final _ParsedLinearEq L2 = parsedList[1];
        final double det = L1.a * L2.b - L2.a * L1.b;

        if (det.abs() > 1e-9) {
          final double ix = (L1.b * L2.c - L2.b * L1.c) / det;
          final double iy = (L2.a * L1.c - L1.a * L2.c) / det;
          final String meetCoord = fmtCoord(ix, iy);
          intersectionPt = PlottedPointData(x: ix, y: iy, label: meetCoord);

          workings.add(
              "\\text{At the point where } (${L1.rawInput}) \\text{ and } (${L2.rawInput}) \\text{ meet:}");
          workings.add(
              "${fmt(L1.m)}x ${fmtSigned(L1.yIntercept)} = ${fmt(L2.m)}x ${fmtSigned(L2.yIntercept)} \\implies x = ${fmt(ix)}, \\; y = ${fmt(iy)}");
          workings.add(
              "\\text{Coordinates of Point of Intersection} = \\mathbf{$meetCoord}");

          steps.add(LinearEqGraphStep(
            title:
            "Step 3: Find the Coordinates of the Point Where the Lines Meet (Ex 23a #8)",
            description:
            "Read the coordinates of the point where '${L1.rawInput}' and '${L2.rawInput}' cross each other on the graph:\n"
                "• Setting the two equations equal gives x = ${fmt(ix)} and y = ${fmt(iy)}.\n"
                "• Therefore, the lines meet at the point $meetCoord!",
            mathLaTeX:
            "\\text{Point of Intersection} = \\boxed{$meetCoord}",
          ));

          answers["Point Where Lines Meet"] = meetCoord;
          answers["At Intersection, x"] = fmt(ix);
          answers["At Intersection, y"] = fmt(iy);
        }
      }

      return LinearEqGraphResult(
        mode: 3,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: CartesianCanvasData(
          lines: seriesList,
          intersectionPoint: intersectionPt,
          scaleXUnitsPer2Cm: scaleX,
          scaleYUnitsPer2Cm: scaleY,
          scaleBannerText:
          "Scale: 2 cm to ${fmt(scaleX)} unit(s) on x-axis; 2 cm to ${fmt(scaleY)} unit(s) on y-axis",
          headerBadge:
          "Multi-Line Graph (${seriesList.map((s) => s.equationLabel).join(' , ')})",
        ),
      );
    } catch (e) {
      return LinearEqGraphResult.error(
        mode: 3,
        message: e is FormatException
            ? e.message
            : "Please enter valid linear equations (e.g. y = 2x + 5, y = 2x - 1).",
      );
    }
  }
}