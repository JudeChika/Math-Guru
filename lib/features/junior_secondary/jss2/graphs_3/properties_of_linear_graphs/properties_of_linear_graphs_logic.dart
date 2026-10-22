import 'package:flutter/material.dart';
import 'properties_of_linear_graphs_models.dart';

/// Internal parsed representation of a linear equation: a*x + b*y + c = 0
class _ParsedEq {
  final String rawInput;
  final double a; // Coefficient of x in ax + by + c = 0
  final double b; // Coefficient of y in ax + by + c = 0
  final double c; // Constant in ax + by + c = 0
  final bool hadBrackets;
  final String? expandedDisplay;

  const _ParsedEq({
    required this.rawInput,
    required this.a,
    required this.b,
    required this.c,
    this.hadBrackets = false,
    this.expandedDisplay,
  });

  bool get isVertical => b.abs() < 1e-9;
  bool get isHorizontal => a.abs() < 1e-9;

  /// Coefficient of x (m) when written as y = mx + c
  double get m => isVertical ? 0.0 : (-a / b);

  /// Constant term (c) when written as y = mx + c (the y-intercept)
  double get yIntercept => isVertical ? 0.0 : (-c / b);

  /// x-intercept when y = 0
  double? get xIntercept => isHorizontal ? null : (-c / a);

  double evaluateY(double xVal) => isVertical ? 0.0 : (-a * xVal - c) / b;
}

class PropertiesOfLinearGraphsLogic {
  // ===========================================================================
  // 13 TEXTBOOK PRESETS (Covers Table 23.7, Figs 23.5–23.6, Ex 3–4, Ex 23c #1–10)
  // ===========================================================================
  static const List<LinearGraphPropPreset> textbookPresets = [
    LinearGraphPropPreset(
      chipLabel: "Table 23.7g: 10x + y = 3 (Rearrange & Coefficient of x)",
      mode: 0,
      equationStr: '10x + y = 3',
      xValuesCsv: '-1, 0, 1, 2',
      scaleXStr: '1',
      scaleYStr: '5',
    ),
    LinearGraphPropPreset(
      chipLabel: "Example 3: Which Lines Are Parallel? (4 Equations)",
      mode: 2,
      xValuesCsv: '-2, 0, 2',
      scaleXStr: '1',
      scaleYStr: '5',
      multiEquations: [
        'y = 4x - 9',
        '5 + 4x = y',
        'y + 4x = 3',
        '4x = y',
      ],
    ),
    LinearGraphPropPreset(
      chipLabel: "Example 4: x- and y-Intercepts of y = 4x - 9",
      mode: 0,
      equationStr: 'y = 4x - 9',
      xValuesCsv: '-1, 0, 1, 2, 3',
      scaleXStr: '1',
      scaleYStr: '5',
    ),
    LinearGraphPropPreset(
      chipLabel: "Ex 23c #1d: Coefficient of x in y = 2 - x",
      mode: 0,
      equationStr: 'y = 2 - x',
      xValuesCsv: '-2, -1, 0, 1, 2, 3',
      scaleXStr: '1',
      scaleYStr: '1',
    ),
    LinearGraphPropPreset(
      chipLabel: "Ex 23c #2: Write 3 Lines Parallel to y = 2x - 5",
      mode: 1,
      subMode: 0,
      equationStr: 'y = 2x - 5',
      scaleXStr: '1',
      scaleYStr: '5',
    ),
    LinearGraphPropPreset(
      chipLabel: "Ex 23c #3: Write 3 Lines NOT Parallel to y = 4x - 7",
      mode: 1,
      subMode: 1,
      equationStr: 'y = 4x - 7',
      scaleXStr: '1',
      scaleYStr: '5',
    ),
    LinearGraphPropPreset(
      chipLabel: "Ex 23c #4: Write Lines Parallel to 5x + 2y - 6 = 0",
      mode: 1,
      subMode: 0,
      equationStr: '5x + 2y - 6 = 0',
      scaleXStr: '1',
      scaleYStr: '5',
    ),
    LinearGraphPropPreset(
      chipLabel: "Ex 23c #5: x- and y-Intercepts of y = 2x - 5 (Fig 23.1)",
      mode: 0,
      equationStr: 'y = 2x - 5',
      xValuesCsv: '-2, -1, 0, 1, 2, 3, 4',
      scaleXStr: '1',
      scaleYStr: '5',
    ),
    LinearGraphPropPreset(
      chipLabel: "Ex 23c #6 (Fig 23.5): y = 20 - 10x & y = -10 - 10x",
      mode: 2,
      xValuesCsv: '-2, -1, 0, 1, 2, 3',
      scaleXStr: '1',
      scaleYStr: '10',
      multiEquations: [
        'y = 20 - 10x',
        'y = -10 - 10x',
        'y = 3x + 8',
        'y = 3x - 10',
      ],
    ),
    LinearGraphPropPreset(
      chipLabel: "Ex 23c #7: y = 6x - 9 & Parallel Line Through Origin",
      mode: 0,
      equationStr: 'y = 6x - 9',
      xValuesCsv: '-2, -1, 0, 1, 2, 3, 4',
      drawParallelOrigin: true,
      scaleXStr: '1',
      scaleYStr: '5',
    ),
    LinearGraphPropPreset(
      chipLabel: "Ex 23c #8: Family y = 1-x, 3-x, 5-x vs y = 2+x",
      mode: 2,
      xValuesCsv: '-3, -2, -1, 0, 1, 2, 3',
      scaleXStr: '1',
      scaleYStr: '1',
      multiEquations: [
        'y = 1 - x',
        'y = 3 - x',
        'y = 5 - x',
        'y = 2 + x',
      ],
    ),
    LinearGraphPropPreset(
      chipLabel: "Ex 23c #9: Bracket Equation y = 1/2(x + 4) & Intercepts",
      mode: 0,
      equationStr: 'y = 1/2(x + 4)',
      xValuesCsv: '-4, -2, 0, 2, 4',
      scaleXStr: '1',
      scaleYStr: '1',
    ),
    LinearGraphPropPreset(
      chipLabel: "Ex 23c #10 (Fig 23.6 Challenge): Find Equations of M & N",
      mode: 3,
      subMode: 1,
      line1Name: 'Line M',
      line1Pt1: '0;0',
      line1Pt2: '2;2',
      line2Name: 'Line N',
      line2Pt1: '0;3',
      line2Pt2: '2;0',
      scaleXStr: '1',
      scaleYStr: '1',
    ),
  ];

  // ===========================================================================
  // REUSABLE FORMATTING, MIXED-FRACTION & ALGEBRAIC PARSING HELPERS
  // ===========================================================================
  static int _gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final int t = b;
      b = a % b;
      a = t;
    }
    return a == 0 ? 1 : a;
  }

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
    if (v.abs() < 1e-9) return leadingPlus ? '+ 0' : '0';
    final String absStr = fmt(v.abs());
    if (v > 0) return leadingPlus ? '+ $absStr' : absStr;
    return '- $absStr';
  }

  static String fmtCoord(double x, double y) => "(${fmt(x)};${fmt(y)})";

  /// Formats a ratio num/den as both LaTeX mixed fraction (e.g. `2\frac{1}{4}`) and plain display (`2¼ (2.25)`)
  static Map<String, String> formatExactFractionAndDecimal(
      double numVal, double denVal) {
    final double exact = numVal / denVal;
    if ((exact - exact.roundToDouble()).abs() < 1e-9) {
      final String s = exact.round().toString();
      return {'latex': s, 'display': s};
    }

    // Scale to integer numerator/denominator
    final int scNum = (numVal * 100).round();
    final int scDen = (denVal * 100).round();
    if (scDen == 0) {
      return {'latex': fmt(exact), 'display': fmt(exact)};
    }

    final bool isNeg = (scNum < 0) ^ (scDen < 0);
    int n = scNum.abs();
    int d = scDen.abs();
    final int g = _gcd(n, d);
    n ~/= g;
    d ~/= g;
    final String sign = isNeg ? "-" : "";

    if (d == 1) {
      return {'latex': '$sign$n', 'display': '$sign$n'};
    }
    if (d <= 20) {
      if (n > d) {
        final int w = n ~/ d;
        final int rem = n % d;
        return {
          'latex': '$sign\\frac{$n}{$d} = $sign$w\\frac{$rem}{$d} \\; (${fmt(exact)})',
          'display': '$sign$w $rem/$d (${fmt(exact)})',
        };
      } else {
        return {
          'latex': '$sign\\frac{$n}{$d} \\; (${fmt(exact)})',
          'display': '$sign$n/$d (${fmt(exact)})',
        };
      }
    }
    return {'latex': fmt(exact), 'display': fmt(exact)};
  }

  static double _parseCoefficientToken(String raw) {
    final String s = raw.trim();
    if (s.isEmpty || s == '+') return 1.0;
    if (s == '-') return -1.0;
    if (s.contains('/')) {
      final List<String> p = s.split('/');
      return double.parse(p[0].trim()) / double.parse(p[1].trim());
    }
    return double.parse(s);
  }

  /// Expands bracketed expressions like `1/2(x + 4)` or `2(3x - 1)` on a side of an equation
  static Map<String, dynamic> _expandBracketsInSide(String side) {
    String s = side
        .replaceAll(' ', '')
        .replaceAll('½', '1/2')
        .replaceAll('¼', '1/4')
        .replaceAll('¾', '3/4')
        .replaceAll('−', '-');

    bool expanded = false;
    final RegExp bracketReg =
    RegExp(r'([+-]?(?:\d+\/\d+|\d+\.?\d*)?)\(([^()]+)\)');

    while (bracketReg.hasMatch(s)) {
      expanded = true;
      s = s.replaceFirstMapped(bracketReg, (Match m) {
        final String factorStr = m.group(1) ?? '';
        final String inside = m.group(2)!;
        final double k = _parseCoefficientToken(factorStr);

        final Map<String, double> inner = _parseFlatLinearSide(inside);
        final double nx = k * inner['x']!;
        final double ny = k * inner['y']!;
        final double nc = k * inner['c']!;

        final List<String> built = [];
        if (nx.abs() > 1e-9) {
          built.add("${nx >= 0 ? '+' : ''}${fmt(nx, maxDecimals: 4)}x");
        }
        if (ny.abs() > 1e-9) {
          built.add("${ny >= 0 ? '+' : ''}${fmt(ny, maxDecimals: 4)}y");
        }
        if (nc.abs() > 1e-9) {
          built.add("${nc >= 0 ? '+' : ''}${fmt(nc, maxDecimals: 4)}");
        }
        return built.isEmpty ? '+0' : built.join('');
      });
    }

    return {'text': s, 'hadBrackets': expanded};
  }

  static Map<String, double> _parseFlatLinearSide(String side) {
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
        throw const FormatException("Linear equations cannot contain 'xy' terms.");
      }
      if (chunk.contains('^') || chunk.contains('²')) {
        throw const FormatException("Variables must have a power (index) of 1.");
      }
      if (chunk.contains('x')) {
        final String numPart = chunk.replaceAll('x', '').trim();
        cx += _parseCoefficientToken(numPart);
      } else if (chunk.contains('y')) {
        final String numPart = chunk.replaceAll('y', '').trim();
        cy += _parseCoefficientToken(numPart);
      } else {
        cc += _parseCoefficientToken(chunk);
      }
    }
    return {'x': cx, 'y': cy, 'c': cc};
  }

  /// Parses any linear equation including bracketed/fractional forms like `y = 1/2(x + 4)`
  static _ParsedEq parseLinearEquation(String raw) {
    final String clean = raw.trim();
    if (!clean.contains('=')) {
      throw const FormatException(
          "Equation must contain an '=' sign (e.g. y = 4x - 9, 10x + y = 3, or y = 1/2(x + 4)).");
    }
    final List<String> sides = clean.split('=');
    if (sides.length != 2 || sides[0].trim().isEmpty || sides[1].trim().isEmpty) {
      throw const FormatException("Invalid linear equation format.");
    }

    final Map<String, dynamic> expL = _expandBracketsInSide(sides[0]);
    final Map<String, dynamic> expR = _expandBracketsInSide(sides[1]);
    final bool hadBrackets =
        (expL['hadBrackets'] as bool) || (expR['hadBrackets'] as bool);

    final Map<String, double> lhs = _parseFlatLinearSide(expL['text'] as String);
    final Map<String, double> rhs = _parseFlatLinearSide(expR['text'] as String);

    double a = lhs['x']! - rhs['x']!;
    double b = lhs['y']! - rhs['y']!;
    double c = lhs['c']! - rhs['c']!;

    if (a.abs() < 1e-9 && b.abs() < 1e-9) {
      throw const FormatException(
          "Equation must contain at least one variable (x or y).");
    }

    if (a < -1e-9 || (a.abs() < 1e-9 && b < -1e-9)) {
      a = -a;
      b = -b;
      c = -c;
    }

    return _ParsedEq(
      rawInput: clean,
      a: a,
      b: b,
      c: c,
      hadBrackets: hadBrackets,
      expandedDisplay: hadBrackets ? "${expL['text']} = ${expR['text']}" : null,
    );
  }

  /// Formats `y = mx + c` cleanly in LaTeX (showing fractions like `\frac{1}{2}x` when appropriate)
  static String formatSlopeInterceptLaTeX(_ParsedEq eq) {
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
    } else if ((m - 0.5).abs() < 1e-9) {
      mPart = "\\frac{1}{2}x";
    } else if ((m + 0.5).abs() < 1e-9) {
      mPart = "-\\frac{1}{2}x";
    } else if ((m - 1.5).abs() < 1e-9) {
      mPart = "\\frac{3}{2}x";
    } else if ((m + 1.5).abs() < 1e-9) {
      mPart = "-\\frac{3}{2}x";
    } else if ((m - 2.5).abs() < 1e-9) {
      mPart = "\\frac{5}{2}x";
    } else if ((m + 2.5).abs() < 1e-9) {
      mPart = "-\\frac{5}{2}x";
    } else {
      mPart = "${fmt(m)}x";
    }

    if (c.abs() < 1e-9) return "y = $mPart";
    final String cPart = c > 0 ? "+ ${fmt(c)}" : "- ${fmt(c.abs())}";
    return "y = $mPart $cPart";
  }

  static String formatSlopeInterceptPlain(_ParsedEq eq) {
    return formatSlopeInterceptLaTeX(eq)
        .replaceAll('\\frac{1}{2}', '½')
        .replaceAll('\\frac{3}{2}', '1½')
        .replaceAll('\\frac{5}{2}', '2½')
        .replaceAll('\\', '');
  }

  static List<double> parseXValues(String raw) {
    final String s = raw.trim().replaceAll('+', '');
    if (s.isEmpty) return [-2, -1, 0, 1, 2, 3, 4];

    final RegExp rangeReg = RegExp(
        r'^(-?\d+\.?\d*)\s*(?:to|\.\.)\s*(-?\d+\.?\d*)$',
        caseSensitive: false);
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
    return vals.length >= 2 ? vals : [-2, -1, 0, 1, 2, 3, 4];
  }

  // ===========================================================================
  // MODE 0: COEFFICIENT OF x, x- & y-INTERCEPTS & PARALLEL LINE THROUGH ORIGIN
  // Matches Table 23.7, Example 4, and Exercise 23c #1, #5, #7, #9
  // ===========================================================================
  static LinearGraphPropResult solvePropertiesAndIntercepts({
    required String equationStr,
    required String xValuesCsv,
    required bool drawParallelOrigin,
    required String scaleXStr,
    required String scaleYStr,
  }) {
    try {
      final _ParsedEq eq = parseLinearEquation(equationStr);
      if (eq.isVertical) {
        throw const FormatException(
            "Please enter a linear equation containing y (e.g. y = 4x - 9 or 10x + y = 3).");
      }

      final List<double> xList = parseXValues(xValuesCsv);
      final double scaleX =
      (double.tryParse(scaleXStr.trim()) ?? 1.0).clamp(0.2, 50.0);
      final double scaleY =
      (double.tryParse(scaleYStr.trim()) ?? 5.0).clamp(0.2, 100.0);

      final double m = eq.m;
      final double c = eq.yIntercept;
      final String stdTex = formatSlopeInterceptLaTeX(eq);
      final String stdPlain = formatSlopeInterceptPlain(eq);

      final List<String> workings = [];
      final List<LinearGraphPropStep> steps = [];
      final Map<String, String> answers = {};

      // Step 1: Rearrange into y = mx + c and Identify the Coefficient of x (Table 23.7 Rule)
      workings.add(
          "\\text{\\textbf{Step 1: Arrange Equation in the Form }} y = mx + c \\text{\\textbf{ (Table 23.7 Rule)}}");
      workings.add("\\text{Given Equation: } ${eq.rawInput}");

      String rearrangeNarrative = "";
      if (eq.hadBrackets) {
        workings.add(
            "\\text{Expand brackets: } ${eq.rawInput} \\implies $stdTex");
        rearrangeNarrative =
        "• First, expand the brackets by multiplying every term inside the bracket by the factor outside to get '$stdPlain'.\n";
      } else if (!eq.rawInput.trim().startsWith('y') ||
          eq.rawInput.indexOf('=') > 3) {
        workings.add(
            "\\text{Rearrange so } y \\text{ is the subject on the LHS: } $stdTex");
        rearrangeNarrative =
        "• Just like Table 23.7g (10x + y = 3 → y = -10x + 3) and Example 3, it is necessary to rearrange the equation first so that y is alone on the left-hand side in the form y = mx + c: '$stdPlain'.\n";
      } else {
        workings.add("\\text{In } y = mx + c \\text{ form: } $stdTex");
      }

      String coeffUnitNote = "";
      if ((m - 1.0).abs() < 1e-9) {
        coeffUnitNote =
        "\n• Textbook Note (Table 23.7d): Think of '+x' as '+1x', so the coefficient of x is 1.";
        workings.add(
            "\\text{Think of } x \\text{ as } 1x \\implies \\text{Coefficient of } x \\; (m) = 1");
      } else if ((m + 1.0).abs() < 1e-9) {
        coeffUnitNote =
        "\n• Textbook Note (Table 23.7e & f): Think of '-x' as '-1x', so the coefficient of x is -1.";
        workings.add(
            "\\text{Think of } -x \\text{ as } -1x \\implies \\text{Coefficient of } x \\; (m) = -1");
      } else {
        workings.add(
            "\\text{Comparing with } y = mx + c: \\quad \\text{Coefficient of } x \\; (m) = ${fmt(m)}, \\quad \\text{Constant term } (c) = ${fmt(c)}");
      }
      workings.add("");

      steps.add(LinearGraphPropStep(
        title: "Step 1: Arrange in the Form y = mx + c & Find Coefficient of x",
        description:
        "$rearrangeNarrative"
            "• Comparing '$stdPlain' with y = mx + c:\n"
            "  – The coefficient of x (the number multiplying x) is m = ${fmt(m)}.$coeffUnitNote\n"
            "  – The constant term is c = ${fmt(c)}.",
        mathLaTeX:
        "$stdTex \\implies \\text{Coefficient of } x \\; (m) = ${fmt(m)}, \\quad c = ${fmt(c)}",
      ));

      answers["Standard Form"] = stdPlain;
      answers["Coefficient of x (m)"] = fmt(m);

      // Step 2: Find the y-Intercept (Distance from Origin Where Line Cuts the y-Axis)
      workings.add(
          "\\text{\\textbf{Step 2: Find the }} y\\text{\\textbf{-Intercept (Where the Line Cuts the }} y\\text{\\textbf{-Axis)}}");
      workings.add(
          "\\text{The } y\\text{-intercept is where } x = 0 \\text{ (the constant term } c \\text{ in } y = mx + c\\text{):}");
      workings.add(
          "\\text{When } x = 0: \\quad y = ${fmt(m)}(0) ${fmtSigned(c)} = ${fmt(c)}");
      workings.add(
          "\\therefore \\; y\\text{-intercept} = ${fmt(c)} \\quad \\text{at point } \\mathbf{${fmtCoord(0, c)}}");
      workings.add("");

      steps.add(LinearGraphPropStep(
        title: "Step 2: Find the y-Intercept (Where x = 0)",
        description:
        "• Definition (page 208): 'The distance of the point where the line cuts the y-axis from the origin is called the y-intercept. The y-intercept is where x = 0.'\n"
            "• In the equation y = mx + c, the y-intercept has the exact value of the constant term, c.\n"
            "• When x = 0, y = ${fmt(m)}(0) ${fmtSigned(c)} = ${fmt(c)}.\n"
            "• Thus, the y-intercept is ${fmt(c)}, and the line cuts the y-axis at ${fmtCoord(0, c)}.",
        mathLaTeX:
        "\\text{When } x = 0, \\; y = ${fmt(c)} \\implies y\\text{-intercept} = \\mathbf{${fmt(c)}} \\; \\text{at } ${fmtCoord(0, c)}",
      ));

      answers["y-Intercept (x = 0)"] = "${fmt(c)}  at  ${fmtCoord(0, c)}";

      // Step 3: Find the x-Intercept (Example 4 Method — Where y = 0)
      final List<PropPlottedPoint> interceptMarkers = [
        PropPlottedPoint(
          x: 0.0,
          y: c,
          label: "y-int ${fmtCoord(0, c)}",
          isIntercept: true,
        ),
      ];

      workings.add(
          "\\text{\\textbf{Step 3: Find the }} x\\text{\\textbf{-Intercept (Example 4 Method — Where }} y = 0\\text{\\textbf{)}}");
      if (eq.xIntercept != null) {
        final double xIntVal = eq.xIntercept!;
        final Map<String, String> fracData =
        formatExactFractionAndDecimal(-c, m);

        workings.add(
            "\\text{The } x\\text{-intercept is the point on the } x\\text{-axis where } y = 0.");
        workings.add(
            "\\text{When } y = 0: \\quad 0 = ${fmt(m)}x ${fmtSigned(c)}");
        workings.add("${fmt(m)}x = ${fmt(-c)}");
        workings.add(
            "x = \\frac{${fmt(-c)}}{${fmt(m)}} = ${fracData['latex']} \\text{ (the } x\\text{-intercept)}");
        workings.add(
            "\\therefore \\; \\text{Line cuts the } x\\text{-axis at } \\mathbf{${fmtCoord(xIntVal, 0)}}");
        workings.add("");

        steps.add(LinearGraphPropStep(
          title: "Step 3: Calculate the x-Intercept by Making y = 0 (Example 4)",
          description:
          "• Definition (page 209): 'The x-intercept is the point on the x-axis where y = 0.'\n"
              "• Substitute y = 0 into '$stdPlain':\n"
              "  1. 0 = ${fmt(m)}x ${fmtSigned(c)}\n"
              "  2. Rearrange to isolate the x-term: ${fmt(m)}x = ${fmt(-c)}\n"
              "  3. Divide both sides by ${fmt(m)}: x = ${fmt(-c)} ÷ ${fmt(m)} = ${fracData['display']}.\n"
              "• Therefore, the x-intercept is ${fracData['display']}, and the line cuts the x-axis at ${fmtCoord(xIntVal, 0)}.",
          mathLaTeX:
          "0 = ${fmt(m)}x ${fmtSigned(c)} \\implies ${fmt(m)}x = ${fmt(-c)} \\implies x = ${fracData['latex']}",
        ));

        interceptMarkers.add(PropPlottedPoint(
          x: xIntVal,
          y: 0.0,
          label: "x-int ${fmtCoord(xIntVal, 0)}",
          isIntercept: true,
        ));
        answers["x-Intercept (y = 0)"] =
        "${fracData['display']}  at  ${fmtCoord(xIntVal, 0)}";
      } else {
        workings.add(
            "\\text{Since } m = 0, \\text{ the line is horizontal and parallel to the } x\\text{-axis (no } x\\text{-intercept).}");
        workings.add("");
        answers["x-Intercept (y = 0)"] = "None (Horizontal Line)";
      }

      // Step 4: Table of Values & Optional Parallel Line Through the Origin (Ex 23c #7b)
      final List<PropPlottedPoint> tablePts = xList.map((x) {
        final double y = eq.evaluateY(x);
        return PropPlottedPoint(x: x, y: y, label: fmtCoord(x, y));
      }).toList();

      final String colSpec = List.filled(xList.length + 1, 'c').join('|');
      final String rowX = xList.map(fmt).join(' & ');
      final String rowY = xList.map((x) => fmt(eq.evaluateY(x))).join(' & ');
      final String tableTex = "\\begin{array}{|$colSpec|} \\hline "
          "x & $rowX \\\\ \\hline "
          "y & $rowY \\\\ \\hline "
          "\\end{array}";

      workings.add("\\text{\\textbf{Step 4: Table of Values for Plotting}}");
      workings.add(tableTex);

      final List<PropLineSeries> canvasLines = [
        PropLineSeries(
          equationLabel: stdPlain,
          a: eq.a,
          b: eq.b,
          c: eq.c,
          points: tablePts,
          color: Colors.deepPurple,
        ),
      ];

      String originParallelNote = "";
      String originParallelMath = tableTex;

      if (drawParallelOrigin) {
        final _ParsedEq originEq =
        _ParsedEq(rawInput: "y = ${fmt(m)}x", a: m, b: -1.0, c: 0.0);
        final String originPlain = formatSlopeInterceptPlain(originEq);
        final String originTex = formatSlopeInterceptLaTeX(originEq);

        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 5: Line Through the Origin }} (0;0) \\text{\\textbf{ Parallel to }} $stdTex \\text{\\textbf{ (Ex 23c \\#7b)}}");
        workings.add(
            "\\text{A parallel line must have the same coefficient of } x \\; (m = ${fmt(m)}) \\text{ and pass through } (0;0) \\implies c = 0:");
        workings.add("\\text{Parallel Line Through Origin: } \\mathbf{$originTex}");

        originParallelNote =
        "\n\n• Parallel Line Through the Origin (Ex 23c #7b): Any line parallel to '$stdPlain' must have the same coefficient of x (m = ${fmt(m)}). Since it passes through the origin (0;0), its y-intercept is c = 0. Thus its equation is '$originPlain'!";
        originParallelMath =
        "$tableTex\n\\text{Parallel Line Through Origin } (0;0): \\quad \\mathbf{$originTex}";
        answers["Parallel Through (0;0)"] = originPlain;

        canvasLines.add(PropLineSeries(
          equationLabel: "$originPlain (Origin)",
          a: originEq.a,
          b: originEq.b,
          c: originEq.c,
          points: [
            const PropPlottedPoint(x: 0, y: 0, label: "(0;0)"),
          ],
          color: Colors.green.shade700,
          isDashed: true,
        ));
      }

      steps.add(LinearGraphPropStep(
        title:
        "Step 4: Complete the Table of Values${drawParallelOrigin ? ' & Parallel Line Through Origin' : ''}",
        description:
        "Substitute each value of x from ${fmt(xList.first)} to ${fmt(xList.last)} into '$stdPlain' to build the table of values and plot the straight line.$originParallelNote",
        mathLaTeX: originParallelMath,
      ));

      return LinearGraphPropResult(
        mode: 0,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: PropCartesianCanvasData(
          lines: canvasLines,
          highlightIntercepts: interceptMarkers,
          scaleXUnitsPer2Cm: scaleX,
          scaleYUnitsPer2Cm: scaleY,
          scaleBannerText:
          "Scale: 2 cm to ${fmt(scaleX)} unit(s) on x-axis; 2 cm to ${fmt(scaleY)} unit(s) on y-axis",
          headerBadge:
          "Intercepts & Slope of  $stdPlain  (m = ${fmt(m)}, c = ${fmt(c)})",
        ),
      );
    } catch (e) {
      return LinearGraphPropResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter a valid linear equation (e.g. y = 4x - 9, 10x + y = 3, or y = 1/2(x + 4)).",
      );
    }
  }

  // ===========================================================================
  // MODE 1: PARALLEL VS. NON-PARALLEL LINE GENERATOR (Exercise 23c #2, #3, #4)
  // ===========================================================================
  static LinearGraphPropResult solveParallelGenerator({
    required int subMode, // 0: Write 3 Parallel Lines (Ex 23c #2 & #4), 1: Write 3 Non-Parallel Lines (Ex 23c #3)
    required String equationStr,
    required String scaleXStr,
    required String scaleYStr,
  }) {
    try {
      final _ParsedEq givenEq = parseLinearEquation(equationStr);
      if (givenEq.isVertical) {
        throw const FormatException(
            "Please enter a linear equation containing y.");
      }

      final double scaleX =
      (double.tryParse(scaleXStr.trim()) ?? 1.0).clamp(0.2, 50.0);
      final double scaleY =
      (double.tryParse(scaleYStr.trim()) ?? 5.0).clamp(0.2, 100.0);

      final double m = givenEq.m;
      final double c = givenEq.yIntercept;
      final String stdTex = formatSlopeInterceptLaTeX(givenEq);
      final String stdPlain = formatSlopeInterceptPlain(givenEq);
      final bool isGeneralFormInput = givenEq.rawInput.contains('= 0') ||
          (!givenEq.rawInput.trim().startsWith('y') &&
              givenEq.rawInput.indexOf('x') < givenEq.rawInput.indexOf('='));

      final List<String> workings = [];
      final List<LinearGraphPropStep> steps = [];
      final Map<String, String> answers = {};

      workings.add(
          "\\text{\\textbf{Step 1: Find the Coefficient of }} x \\text{\\textbf{ of the Given Line}}");
      workings.add(
          "\\text{Given Line: } ${givenEq.rawInput} \\implies \\text{In } y = mx + c \\text{ form: } $stdTex");
      workings.add(
          "\\text{Coefficient of } x \\; (m) = ${fmt(m)}, \\quad y\\text{-intercept } (c) = ${fmt(c)}");
      workings.add("");

      steps.add(LinearGraphPropStep(
        title: "Step 1: Rearrange the Given Line to Find its Coefficient of x (m)",
        description:
        "First, write '${givenEq.rawInput}' in the slope-intercept form y = mx + c:\n"
            "• $stdPlain → The coefficient of x is m = ${fmt(m)} and the constant term is c = ${fmt(c)}.",
        mathLaTeX:
        "${givenEq.rawInput} \\iff $stdTex \\quad (m = ${fmt(m)})",
      ));

      final List<PropLineSeries> canvasLines = [
        PropLineSeries(
          equationLabel: "${givenEq.rawInput} (Given)",
          a: givenEq.a,
          b: givenEq.b,
          c: givenEq.c,
          color: Colors.deepPurple,
        ),
      ];

      const List<Color> genColors = [
        Color(0xFF2E7D32),
        Color(0xFFE65100),
        Color(0xFF1565C0),
      ];

      if (subMode == 0) {
        // Generate 3 Lines PARALLEL to the Given Line (Ex 23c #2 & #4)
        final List<double> candidateC = [0.0, 4.0, -3.0, 7.0, -8.0]
            .where((val) => (val - c).abs() > 0.5)
            .take(3)
            .toList();

        workings.add(
            "\\text{\\textbf{Step 2: Keep the Exact Same Coefficient of }} x \\; (m = ${fmt(m)}) \\text{\\textbf{ and Change }} c");
        workings.add(
            "\\text{Rule: Lines in the form } y = mx + c \\text{ with the SAME coefficient of } x \\text{ are PARALLEL.}");

        final List<String> genPlainList = [];
        final List<String> genMathList = [];

        for (int i = 0; i < candidateC.length; i++) {
          final double newC = candidateC[i];
          final _ParsedEq pEq = _ParsedEq(
            rawInput: '',
            a: givenEq.a,
            b: givenEq.b,
            c: -newC * givenEq.b,
          );
          final String pTex = formatSlopeInterceptLaTeX(pEq);
          final String pPlain = formatSlopeInterceptPlain(pEq);

          String generalAlt = "";
          if (isGeneralFormInput) {
            final double gC = -newC * givenEq.b;
            final String gSign =
            gC.abs() < 1e-9 ? "" : (gC > 0 ? "+ ${fmt(gC)}" : "- ${fmt(gC.abs())}");
            generalAlt =
            " \\quad \\left(\\text{or } ${fmt(givenEq.a)}x + ${fmt(givenEq.b)}y $gSign = 0\\right)";
          }

          workings.add(
              "\\bullet \\text{ Parallel Line ${i + 1} } (c = ${fmt(newC)}): \\quad \\mathbf{$pTex}$generalAlt");
          genPlainList.add(pPlain);
          genMathList.add("$pTex$generalAlt");
          answers["Parallel Line ${i + 1}"] = pPlain;

          canvasLines.add(PropLineSeries(
            equationLabel: pPlain,
            a: pEq.a,
            b: pEq.b,
            c: pEq.c,
            color: genColors[i % genColors.length],
            isDashed: true,
          ));
        }

        steps.add(LinearGraphPropStep(
          title:
          "Step 2: Write Equations with the Same Coefficient of x (Ex 23c #2 & #4)",
          description:
          "• Textbook Rule (page 208): 'If two or more equations in the form y = mx + c have the same coefficients of x, then their graphs will be parallel lines.'\n"
              "• Therefore, keep the coefficient of x equal to ${fmt(m)} and choose any three different values for the constant c (such as c = ${candidateC.map(fmt).join(', ')}):\n"
              "  1. ${genPlainList[0]}\n"
              "  2. ${genPlainList[1]}\n"
              "  3. ${genPlainList[2]}"
              "${isGeneralFormInput ? '\n• Note for General Form (${givenEq.rawInput}): Keeping the x and y terms (${fmt(givenEq.a)}x + ${fmt(givenEq.b)}y) identical and changing only the constant term also guarantees parallel lines!' : ''}",
          mathLaTeX: genMathList.join('\n'),
        ));
      } else {
        // Generate 3 Lines NOT Parallel to the Given Line (Ex 23c #3)
        final List<double> candidateM = [
          -m,
          m + 2.0,
          1.0,
          -2.0,
        ].where((val) => (val - m).abs() > 0.2 && val.abs() > 1e-9).take(3).toList();

        workings.add(
            "\\text{\\textbf{Step 2: Change the Coefficient of }} x \\text{\\textbf{ so }} m_{\\text{new}} \\neq ${fmt(m)} \\text{\\textbf{ (Ex 23c \\#3)}}");
        workings.add(
            "\\text{Rule: Any line whose coefficient of } x \\text{ is DIFFERENT from } ${fmt(m)} \\text{ will NOT be parallel to } $stdTex.");

        final List<String> nonParPlain = [];
        final List<String> nonParMath = [];

        for (int i = 0; i < candidateM.length; i++) {
          final double newM = candidateM[i];
          final double newC = i == 0 ? c : (i == 1 ? 1.0 : 0.0);
          final _ParsedEq npEq = _ParsedEq(
            rawInput: '',
            a: newM,
            b: -1.0,
            c: newC,
          );
          final String npTex = formatSlopeInterceptLaTeX(npEq);
          final String npPlain = formatSlopeInterceptPlain(npEq);

          workings.add(
              "\\bullet \\text{ Non-Parallel Line ${i + 1} } (m = ${fmt(newM)} \\neq ${fmt(m)}): \\quad \\mathbf{$npTex}");
          nonParPlain.add("$npPlain  (m = ${fmt(newM)})");
          nonParMath.add("$npTex \\quad (m = ${fmt(newM)} \\neq ${fmt(m)})");
          answers["Non-Parallel Line ${i + 1}"] = npPlain;

          canvasLines.add(PropLineSeries(
            equationLabel: npPlain,
            a: npEq.a,
            b: npEq.b,
            c: npEq.c,
            color: genColors[i % genColors.length],
            isDashed: true,
          ));
        }

        steps.add(LinearGraphPropStep(
          title:
          "Step 2: Choose Any Different Coefficient of x (m ≠ ${fmt(m)}) (Ex 23c #3)",
          description:
          "• For a line to NOT be parallel to '$stdPlain', its coefficient of x in the form y = mx + c must be different from ${fmt(m)} (for example, m = ${candidateM.map(fmt).join(', ')}).\n"
              "• Even if the constant c stays the same (like y = ${fmt(-m)}x ${fmtSigned(c)}), changing the sign of the coefficient of x makes the line slope in the opposite direction so the lines cross!\n"
              "  1. ${nonParPlain[0]}\n"
              "  2. ${nonParPlain[1]}\n"
              "  3. ${nonParPlain[2]}",
          mathLaTeX: nonParMath.join('\n'),
        ));
      }

      return LinearGraphPropResult(
        mode: 1,
        subMode: subMode,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: PropCartesianCanvasData(
          lines: canvasLines,
          scaleXUnitsPer2Cm: scaleX,
          scaleYUnitsPer2Cm: scaleY,
          scaleBannerText: subMode == 0
              ? "All 4 lines have m = ${fmt(m)} → They are PARALLEL"
              : "Different coefficients of x (m ≠ ${fmt(m)}) → Lines INTERSECT",
          headerBadge: subMode == 0
              ? "Lines Parallel to  ${givenEq.rawInput}"
              : "Lines NOT Parallel to  ${givenEq.rawInput}",
        ),
      );
    } catch (e) {
      return LinearGraphPropResult.error(
        mode: 1,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid reference equation (e.g. y = 2x - 5 or 5x + 2y - 6 = 0).",
      );
    }
  }

  // ===========================================================================
  // MODE 2: MULTI-LINE PARALLEL DETECTOR & FAMILY RELATIONSHIP ANALYZER
  // Matches Figure 23.5, Example 3, and Exercise 23c #6 & #8
  // ===========================================================================
  static LinearGraphPropResult solveMultiLineInspector({
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
            "Please enter at least 2 linear equations to compare.");
      }

      final List<_ParsedEq> parsedList =
      nonEmpty.map(parseLinearEquation).toList();
      final List<double> xList = parseXValues(xValuesCsv);
      final double scaleX =
      (double.tryParse(scaleXStr.trim()) ?? 1.0).clamp(0.2, 50.0);
      final double scaleY =
      (double.tryParse(scaleYStr.trim()) ?? 5.0).clamp(0.2, 100.0);

      const List<Color> palette = [
        Colors.deepPurple,
        Color(0xFF2E7D32),
        Color(0xFFE65100),
        Color(0xFF1565C0),
      ];
      const List<String> letters = ['a', 'b', 'c', 'd'];

      final List<String> workings = [];
      final List<LinearGraphPropStep> steps = [];
      final Map<String, String> answers = {};
      final List<PropLineSeries> seriesList = [];
      final List<PropPlottedPoint> interceptDots = [];

      // Step 1: Write Each Equation in the Form y = mx + c (Example 3 Method)
      workings.add(
          "\\text{\\textbf{Step 1: Write Each Equation in the Form }} y = mx + c \\text{\\textbf{ (Example 3)}}");
      final List<String> step1Desc = [];
      final List<String> step1Math = [];

      for (int i = 0; i < parsedList.length; i++) {
        final _ParsedEq eq = parsedList[i];
        final String stdTex = formatSlopeInterceptLaTeX(eq);
        final String stdPlain = formatSlopeInterceptPlain(eq);
        final String xIntStr = eq.xIntercept != null
            ? formatExactFractionAndDecimal(-eq.yIntercept, eq.m)['display']!
            : "None";

        final String lineTex =
            "\\text{(${letters[i]}) } ${eq.rawInput} \\implies \\mathbf{$stdTex} \\quad \\left(m = ${fmt(eq.m)}, \\; y\\text{-int} = ${fmt(eq.yIntercept)}, \\; x\\text{-int} = ${fmt(eq.xIntercept ?? 0)}\\right)";
        workings.add(lineTex);
        step1Math.add(lineTex);
        step1Desc.add(
            "• (${letters[i]}) ${eq.rawInput}  →  $stdPlain:\n"
                "  Coefficient of x (m) = ${fmt(eq.m)} | y-intercept (c) = ${fmt(eq.yIntercept)} at ${fmtCoord(0, eq.yIntercept)} | x-intercept = $xIntStr.");

        final List<PropPlottedPoint> pts = xList
            .map((x) => PropPlottedPoint(
            x: x, y: eq.evaluateY(x), label: fmtCoord(x, eq.evaluateY(x))))
            .toList();

        seriesList.add(PropLineSeries(
          equationLabel: "(${letters[i]}) ${eq.rawInput}",
          a: eq.a,
          b: eq.b,
          c: eq.c,
          points: pts,
          color: palette[i % palette.length],
        ));

        interceptDots.add(PropPlottedPoint(
          x: 0,
          y: eq.yIntercept,
          label: fmtCoord(0, eq.yIntercept),
          isIntercept: true,
        ));
        if (eq.xIntercept != null) {
          interceptDots.add(PropPlottedPoint(
            x: eq.xIntercept!,
            y: 0,
            label: fmtCoord(eq.xIntercept!, 0),
            isIntercept: true,
          ));
        }
      }
      workings.add("");

      steps.add(LinearGraphPropStep(
        title:
        "Step 1: Rearrange Each Equation into y = mx + c & Find Intercepts",
        description:
        "Just like Example 3 and Exercise 23c #6, write each equation in the form y = mx + c to read its coefficient of x (m), y-intercept (c), and x-intercept (when y = 0):\n\n"
            "${step1Desc.join('\n\n')}",
        mathLaTeX: step1Math.join('\n'),
      ));

      // Step 2: Group Lines by Coefficient of x (m) to Identify Which Lines Are Parallel
      final Map<String, List<String>> slopeGroups = {};
      for (int i = 0; i < parsedList.length; i++) {
        final String mKey = fmt(parsedList[i].m);
        slopeGroups.putIfAbsent(mKey, () => []);
        slopeGroups[mKey]!
            .add("(${letters[i]}) ${formatSlopeInterceptPlain(parsedList[i])}");
      }

      workings.add(
          "\\text{\\textbf{Step 2: Compare Coefficients of }} x \\text{\\textbf{ to Identify Parallel Lines}}");
      final List<String> groupDescriptions = [];
      final List<String> groupMathLines = [];

      slopeGroups.forEach((mKey, eqLabels) {
        if (eqLabels.length > 1) {
          final String joined = eqLabels.join(', ');
          workings.add(
              "\\bullet \\text{ Coefficient } m = $mKey: \\quad \\text{Lines $joined are \\textbf{PARALLEL} (same coefficient of } x = $mKey\\text{).}");
          groupDescriptions.add(
              "• Parallel Group (m = $mKey): $joined all have the exact same coefficient of x ($mKey), so they are PARALLEL to each other!");
          groupMathLines.add(
              "m = $mKey \\implies \\text{Lines $joined are PARALLEL}");
          answers["Parallel (m = $mKey)"] = joined;
        } else {
          final String single = eqLabels.first;
          workings.add(
              "\\bullet \\text{ Coefficient } m = $mKey: \\quad \\text{Line $single has a different slope } (m = $mKey)\\text{, so it intersects the other lines!}");
          groupDescriptions.add(
              "• Intersecting Line (m = $mKey): $single has a coefficient of x equal to $mKey, so it is NOT parallel to the others—it cuts across them!");
          groupMathLines.add(
              "m = $mKey \\implies \\text{Line $single is NOT parallel (intersects)}");
          answers["Not Parallel (m = $mKey)"] = single;
        }
      });

      steps.add(LinearGraphPropStep(
        title:
        "Step 2: Describe the Relationship Between the Lines (Example 3 & Ex 23c #6, #8)",
        description: groupDescriptions.join('\n\n'),
        mathLaTeX: groupMathLines.join('\n'),
      ));

      // Also add individual intercepts to final answers for Ex 23c #6
      for (int i = 0; i < parsedList.length; i++) {
        final _ParsedEq eq = parsedList[i];
        final String xIntDisp = eq.xIntercept != null
            ? fmt(eq.xIntercept!)
            : "None";
        answers["Line (${letters[i]}) Intercepts"] =
        "x-int = $xIntDisp, y-int = ${fmt(eq.yIntercept)}";
      }

      return LinearGraphPropResult(
        mode: 2,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: PropCartesianCanvasData(
          lines: seriesList,
          highlightIntercepts: interceptDots,
          scaleXUnitsPer2Cm: scaleX,
          scaleYUnitsPer2Cm: scaleY,
          scaleBannerText:
          "Lines with the same coefficient of x (m) are parallel; different m intersect",
          headerBadge:
          "Multi-Line Parallel & Intercept Inspector (${parsedList.length} Lines)",
        ),
      );
    } catch (e) {
      return LinearGraphPropResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter at least 2 valid linear equations.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: REVERSE GRAPH READER — FIND EQUATION OF LINE FROM 2 POINTS / INTERCEPTS
  // Matches Exercise 23c #10 Challenge (Figure 23.6: Equations of Lines M and N)
  // ===========================================================================
  static Map<String, double> _parsePointPair(String raw, String label) {
    final String s = raw
        .trim()
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(RegExp(r'^[a-zA-Z]\s*'), '');
    final List<String> parts = s.split(RegExp(r'[;,]'));
    if (parts.length != 2) {
      throw FormatException(
          "Enter coordinates for $label as x;y or x,y (e.g. 0;3 or 2;2).");
    }
    return {
      'x': double.parse(parts[0].trim()),
      'y': double.parse(parts[1].trim()),
    };
  }

  static Map<String, dynamic> _solveSingleLineFromTwoPoints({
    required String lineName,
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    required Color color,
  }) {
    if ((x1 - x2).abs() < 1e-9 && (y1 - y2).abs() < 1e-9) {
      throw FormatException(
          "$lineName requires two distinct points, but both points are ${fmtCoord(x1, y1)}.");
    }

    final List<String> workings = [];
    String stepDesc = "";
    String stepMath = "";
    String eqPlain = "";
    String eqLatex = "";
    double a = 0, b = -1, c = 0;

    if ((x1 - x2).abs() < 1e-9) {
      // Vertical line x = k
      a = 1.0;
      b = 0.0;
      c = -x1;
      eqPlain = "x = ${fmt(x1)}";
      eqLatex = "x = ${fmt(x1)}";
      workings.add(
          "\\text{Both points on $lineName have } x = ${fmt(x1)} \\implies \\text{Vertical line } \\mathbf{x = ${fmt(x1)}}");
      stepDesc =
      "Both points ${fmtCoord(x1, y1)} and ${fmtCoord(x2, y2)} have the same x-coordinate (${fmt(x1)}), so $lineName is the vertical line x = ${fmt(x1)}.";
      stepMath = "x = ${fmt(x1)}";
    } else {
      final double m = (y2 - y1) / (x2 - x1);
      final double cVal = y1 - m * x1;
      a = m;
      b = -1.0;
      c = cVal;

      final _ParsedEq built = _ParsedEq(rawInput: '', a: a, b: b, c: c);
      eqLatex = formatSlopeInterceptLaTeX(built);
      eqPlain = formatSlopeInterceptPlain(built);
      final Map<String, String> mFrac =
      formatExactFractionAndDecimal(y2 - y1, x2 - x1);

      workings.add(
          "\\text{\\textbf{Finding the Equation of $lineName Through ${fmtCoord(x1, y1)} and ${fmtCoord(x2, y2)}:}}");
      workings.add(
          "\\text{Let the equation of $lineName be } y = mx + c.");

      if (x1.abs() < 1e-9 || x2.abs() < 1e-9) {
        // Textbook JSS 2 Method: One of the points is on the y-axis (x = 0), so c is known immediately!
        final bool firstIsYInt = x1.abs() < 1e-9;
        final double yInt = firstIsYInt ? y1 : y2;
        final double ox = firstIsYInt ? x2 : x1;
        final double oy = firstIsYInt ? y2 : y1;

        workings.add(
            "\\text{1. Since $lineName passes through } ${fmtCoord(0, yInt)} \\text{ on the } y\\text{-axis, the } y\\text{-intercept is } c = ${fmt(yInt)}.");
        workings.add(
            "\\quad \\text{So the equation becomes: } y = mx ${cVal.abs() < 1e-9 ? '' : fmtSigned(cVal)}");
        workings.add(
            "\\text{2. Substitute the second point } x = ${fmt(ox)}, \\; y = ${fmt(oy)} \\text{ into } y = mx ${cVal.abs() < 1e-9 ? '' : fmtSigned(cVal)}:");
        workings.add(
            "\\quad ${fmt(oy)} = m(${fmt(ox)}) ${cVal.abs() < 1e-9 ? '' : fmtSigned(cVal)} \\implies ${fmt(ox)}m = ${fmt(oy - yInt)} \\implies m = \\frac{${fmt(oy - yInt)}}{${fmt(ox)}} = ${mFrac['latex']}");
        workings.add(
            "\\text{3. Therefore, the equation of $lineName is: } \\mathbf{$eqLatex}");

        stepDesc =
        "1. Start with the general straight-line equation y = mx + c.\n"
            "2. Find c (the y-intercept): Since $lineName cuts the y-axis at ${fmtCoord(0, yInt)}, when x = 0, y = ${fmt(yInt)}. Thus c = ${fmt(yInt)}.\n"
            "3. Find m (the coefficient of x): Substitute the second point ${fmtCoord(ox, oy)} (where x = ${fmt(ox)} and y = ${fmt(oy)}) into y = mx ${cVal.abs() < 1e-9 ? '' : fmtSigned(cVal)}:\n"
            "   ${fmt(oy)} = ${fmt(ox)}m ${cVal.abs() < 1e-9 ? '' : fmtSigned(cVal)}  →  ${fmt(ox)}m = ${fmt(oy - yInt)}  →  m = ${fmt(oy - yInt)} ÷ ${fmt(ox)} = ${mFrac['display']}.\n"
            "4. Substitute m and c into y = mx + c to get the equation of $lineName: $eqPlain!";
        stepMath =
        "c = ${fmt(yInt)}, \\quad ${fmt(oy)} = ${fmt(ox)}m ${cVal.abs() < 1e-9 ? '' : fmtSigned(cVal)} \\implies m = ${mFrac['latex']} \\implies \\mathbf{$eqLatex}";
      } else {
        // General two-point case
        workings.add(
            "\\text{1. Find coefficient of } x \\; (m) = \\frac{y_2 - y_1}{x_2 - x_1} = \\frac{${fmt(y2)} - (${fmt(y1)})}{${fmt(x2)} - (${fmt(x1)})} = \\frac{${fmt(y2 - y1)}}{${fmt(x2 - x1)}} = ${mFrac['latex']}");
        workings.add(
            "\\text{2. Substitute } m = ${fmt(m)} \\text{ and point } ${fmtCoord(x1, y1)} \\text{ into } y = mx + c:");
        workings.add(
            "\\quad ${fmt(y1)} = ${fmt(m)}(${fmt(x1)}) + c \\implies c = ${fmt(y1)} - ${fmt(m * x1)} = ${fmt(cVal)}");
        workings.add(
            "\\text{3. Equation of $lineName: } \\mathbf{$eqLatex}");

        stepDesc =
        "1. Start with y = mx + c.\n"
            "2. Find m (change in y divided by change in x): m = (${fmt(y2)} − ${fmt(y1)}) ÷ (${fmt(x2)} − ${fmt(x1)}) = ${mFrac['display']}.\n"
            "3. Substitute m = ${fmt(m)} and point ${fmtCoord(x1, y1)} into y = mx + c to find c = ${fmt(cVal)}.\n"
            "4. Equation of $lineName: $eqPlain.";
        stepMath =
        "m = ${mFrac['latex']}, \\quad c = ${fmt(cVal)} \\implies \\mathbf{$eqLatex}";
      }
    }

    final PropLineSeries series = PropLineSeries(
      equationLabel: "$lineName: $eqPlain",
      a: a,
      b: b,
      c: c,
      points: [
        PropPlottedPoint(
          x: x1,
          y: y1,
          label: fmtCoord(x1, y1),
          isIntercept: x1.abs() < 1e-9 || y1.abs() < 1e-9,
        ),
        PropPlottedPoint(
          x: x2,
          y: y2,
          label: fmtCoord(x2, y2),
          isIntercept: x2.abs() < 1e-9 || y2.abs() < 1e-9,
        ),
      ],
      color: color,
    );

    return {
      'workings': workings,
      'stepDesc': stepDesc,
      'stepMath': stepMath,
      'eqPlain': eqPlain,
      'series': series,
    };
  }

  static LinearGraphPropResult solveEquationFromGraphPoints({
    required int subMode, // 0: Single Line, 1: Two Lines (Line M & Line N — Fig 23.6 Challenge)
    required String line1Name,
    required String line1Pt1Str,
    required String line1Pt2Str,
    required String line2Name,
    required String line2Pt1Str,
    required String line2Pt2Str,
    required String scaleXStr,
    required String scaleYStr,
  }) {
    try {
      final double scaleX =
      (double.tryParse(scaleXStr.trim()) ?? 1.0).clamp(0.2, 50.0);
      final double scaleY =
      (double.tryParse(scaleYStr.trim()) ?? 1.0).clamp(0.2, 100.0);

      final String name1 =
      line1Name.trim().isEmpty ? "Line M" : line1Name.trim();
      final Map<String, double> p1A =
      _parsePointPair(line1Pt1Str, "$name1 Point 1");
      final Map<String, double> p1B =
      _parsePointPair(line1Pt2Str, "$name1 Point 2");

      final Map<String, dynamic> res1 = _solveSingleLineFromTwoPoints(
        lineName: name1,
        x1: p1A['x']!,
        y1: p1A['y']!,
        x2: p1B['x']!,
        y2: p1B['y']!,
        color: Colors.deepPurple,
      );

      final List<String> workings = [
        ...(res1['workings'] as List<String>),
      ];
      final List<LinearGraphPropStep> steps = [
        LinearGraphPropStep(
          title:
          "Step 1: Find the Equation of $name1 Through ${fmtCoord(p1A['x']!, p1A['y']!)} and ${fmtCoord(p1B['x']!, p1B['y']!)}",
          description: res1['stepDesc'] as String,
          mathLaTeX: res1['stepMath'] as String,
        ),
      ];
      final Map<String, String> answers = {
        "Equation of $name1": res1['eqPlain'] as String,
      };
      final List<PropLineSeries> lines = [res1['series'] as PropLineSeries];

      if (subMode == 1) {
        final String name2 =
        line2Name.trim().isEmpty ? "Line N" : line2Name.trim();
        final Map<String, double> p2A =
        _parsePointPair(line2Pt1Str, "$name2 Point 1");
        final Map<String, double> p2B =
        _parsePointPair(line2Pt2Str, "$name2 Point 2");

        final Map<String, dynamic> res2 = _solveSingleLineFromTwoPoints(
          lineName: name2,
          x1: p2A['x']!,
          y1: p2A['y']!,
          x2: p2B['x']!,
          y2: p2B['y']!,
          color: Colors.green.shade800,
        );

        workings.add("");
        workings.addAll(res2['workings'] as List<String>);

        steps.add(LinearGraphPropStep(
          title:
          "Step 2: Find the Equation of $name2 Through ${fmtCoord(p2A['x']!, p2A['y']!)} and ${fmtCoord(p2B['x']!, p2B['y']!)}",
          description: res2['stepDesc'] as String,
          mathLaTeX: res2['stepMath'] as String,
        ));

        answers["Equation of $name2"] = res2['eqPlain'] as String;
        lines.add(res2['series'] as PropLineSeries);
      }

      return LinearGraphPropResult(
        mode: 3,
        subMode: subMode,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: PropCartesianCanvasData(
          lines: lines,
          scaleXUnitsPer2Cm: scaleX,
          scaleYUnitsPer2Cm: scaleY,
          scaleBannerText:
          "Substitute the known points (x;y) into y = mx + c to find c and m",
          headerBadge: subMode == 1
              ? "Figure 23.6 Challenge: Equations of $name1 and ${line2Name.trim().isEmpty ? 'Line N' : line2Name.trim()}"
              : "Equation of $name1 from Graph Points",
        ),
      );
    } catch (e) {
      return LinearGraphPropResult.error(
        mode: 3,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid point coordinates as x;y (e.g. 0;3 and 2;0).",
      );
    }
  }
}