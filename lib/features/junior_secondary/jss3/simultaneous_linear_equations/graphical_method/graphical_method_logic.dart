import 'graphical_method_models.dart';

/// Exact Rational Number Engine for Graphical Method Tables of Values & Intersection Coordinates
/// Ensures fractional table entries like 2\frac{1}{2}, 3\frac{1}{2} (Table 10.5, Page 92) are rendered via \frac{}{} in Math.tex!
class _GFrac {
  final int num;
  final int den;

  const _GFrac(this.num, [this.den = 1]);

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

  static int lcm(int a, int b) =>
      (a == 0 || b == 0) ? 1 : (a.abs() * b.abs()) ~/ gcd(a, b);

  factory _GFrac.from(int n, [int d = 1]) {
    if (d == 0) throw const FormatException("Denominator cannot be zero.");
    if (n == 0) return const _GFrac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _GFrac(sign * (an ~/ g), ad ~/ g);
  }

  factory _GFrac.parse(String raw) {
    String s = raw.trim().replaceAll(' ', '').replaceAll('−', '-');
    if (s.isEmpty || s == '+') return const _GFrac(1, 1);
    if (s == '-') return const _GFrac(-1, 1);

    int sign = 1;
    if (s.startsWith('-')) {
      sign = -1;
      s = s.substring(1);
    } else if (s.startsWith('+')) {
      s = s.substring(1);
    }
    if (s.isEmpty) return _GFrac(sign, 1);

    if (s.contains('/')) {
      final List<String> sp = s.split('/');
      return _GFrac.from(sign * int.parse(sp[0]), int.parse(sp[1]));
    }
    if (s.contains('.')) {
      final List<String> sp = s.split('.');
      int d = 1;
      for (int i = 0; i < sp[1].length; i++) {
        d *= 10;
      }
      final int n = int.parse(sp[0]) * d + int.parse(sp[1]);
      return _GFrac.from(sign * n, d);
    }
    return _GFrac.from(sign * int.parse(s), 1);
  }

  double get toDouble => num / den;
  bool get isImproper => num.abs() > den && den > 1;

  _GFrac operator +(_GFrac other) =>
      _GFrac.from(num * other.den + other.num * den, den * other.den);
  _GFrac operator -(_GFrac other) =>
      _GFrac.from(num * other.den - other.num * den, den * other.den);
  _GFrac operator *(_GFrac other) =>
      _GFrac.from(num * other.num, den * other.den);
  _GFrac operator /(_GFrac other) =>
      _GFrac.from(num * other.den, den * other.num);

  String toLaTeX({bool withSign = false}) {
    if (num == 0) return withSign ? '+ 0' : '0';
    final String signStr =
    num < 0 ? (withSign ? '- ' : '-') : (withSign ? '+ ' : '');
    final int an = num.abs();
    if (den == 1) return '$signStr$an';
    return '$signStr\\frac{$an}{$den}';
  }

  /// Renders improper fractions as mixed numbers like 2\frac{1}{2} (matching Table 10.5 on Page 92!)
  String toTableCellLaTeX() {
    if (num == 0) return '0';
    final String signStr = num < 0 ? '-' : '';
    final int an = num.abs();
    if (den == 1) return '$signStr$an';
    if (an > den) {
      final int whole = an ~/ den;
      final int rem = an % den;
      if (rem == 0) return '$signStr$whole';
      return '$signStr$whole\\frac{$rem}{$den}';
    }
    return '$signStr\\frac{$an}{$den}';
  }

  String toPlain() {
    if (num == 0) return '0';
    final String signStr = num < 0 ? '-' : '';
    final int an = num.abs();
    if (den == 1) return '$signStr$an';
    return '$signStr$an/$den';
  }
}

/// Represents a linear equation a*x + b*y = c and builds its exact y-subject formula (Pages 91–93)
class _GraphEq {
  final int a;
  final int b;
  final int c;
  final String rawOriginal;

  const _GraphEq({
    required this.a,
    required this.b,
    required this.c,
    required this.rawOriginal,
  });

  static _GraphEq parse(String raw) {
    final String clean = raw.trim().replaceAll(' ', '').replaceAll('−', '-');
    if (!clean.contains('=')) {
      throw FormatException(
        "Equation '$raw' must contain an '=' sign (e.g. x - y = 5 or y = 7 - 2x).",
      );
    }
    final List<String> sides = clean.split('=');
    if (sides.length != 2 || sides[0].isEmpty || sides[1].isEmpty) {
      throw FormatException("Invalid linear equation '$raw'.");
    }

    _GFrac aSum = const _GFrac(0, 1);
    _GFrac bSum = const _GFrac(0, 1);
    _GFrac cSum = const _GFrac(0, 1);

    void parseSide(String s, int sideMult) {
      final String norm = s
          .replaceAll('--', '+')
          .replaceAll('+-', '-')
          .replaceAll('-', '+-');
      final List<String> parts =
      norm.split('+').where((String p) => p.trim().isNotEmpty).toList();
      for (final String p in parts) {
        if (p.contains('x')) {
          final _GFrac coeff = _GFrac.parse(p.replaceAll('x', ''));
          aSum = aSum + (_GFrac(sideMult, 1) * coeff);
        } else if (p.contains('y')) {
          final _GFrac coeff = _GFrac.parse(p.replaceAll('y', ''));
          bSum = bSum + (_GFrac(sideMult, 1) * coeff);
        } else {
          final _GFrac coeff = _GFrac.parse(p);
          cSum = cSum + (_GFrac(-sideMult, 1) * coeff);
        }
      }
    }

    parseSide(sides[0], 1);
    parseSide(sides[1], -1);

    final int commonDen =
    _GFrac.lcm(aSum.den, _GFrac.lcm(bSum.den, cSum.den));
    final int intA = aSum.num * (commonDen ~/ aSum.den);
    final int intB = bSum.num * (commonDen ~/ bSum.den);
    final int intC = cSum.num * (commonDen ~/ cSum.den);

    if (intB == 0) {
      throw FormatException(
        "Equation '$raw' does not contain 'y'. Please enter equations in x and y.",
      );
    }

    return _GraphEq(a: intA, b: intB, c: intC, rawOriginal: raw.trim());
  }

  String toStandardLaTeX() {
    final List<String> lhs = [];
    if (a != 0) {
      final String s = a < 0 ? '-' : '';
      lhs.add('$s${a.abs() == 1 ? 'x' : '${a.abs()}x'}');
    }
    if (b != 0) {
      final String s =
      b < 0 ? (lhs.isEmpty ? '-' : '- ') : (lhs.isEmpty ? '' : '+ ');
      lhs.add('$s${b.abs() == 1 ? 'y' : '${b.abs()}y'}');
    }
    return '${lhs.join(' ')} = $c';
  }

  /// Formats the numerator of y = (numX * x + numConst) / denY in natural textbook order
  /// e.g. "x - 5", "7 - 2x", "x + 12", "2 - 3x"
  String _formatNumeratorForY(int numX, int numConst) {
    if (numX == 0) return '$numConst';
    final String xMag = numX.abs() == 1 ? 'x' : '${numX.abs()}x';
    if (numConst == 0) return numX < 0 ? '-$xMag' : xMag;

    // If numConst > 0 and numX < 0, write as "7 - 2x" or "2 - 3x" (matching Example 1a & 1b on Page 91!)
    if (numConst > 0 && numX < 0) {
      return '$numConst - $xMag';
    }
    // Otherwise write x term first: "x - 5" or "x + 12" or "2x - 3"
    final String xSigned = numX < 0 ? '-$xMag' : xMag;
    final String cSigned =
    numConst < 0 ? '- ${numConst.abs()}' : '+ $numConst';
    return '$xSigned $cSigned';
  }

  /// Returns y made the subject of the equation in LaTeX (e.g. y = 7 - 2x or y = \frac{x + 12}{4})
  String ySubjectLaTeX() {
    // From a*x + b*y = c => b*y = -a*x + c
    int numX = -a;
    int numC = c;
    int den = b;
    if (den < 0) {
      numX = -numX;
      numC = -numC;
      den = -den;
    }
    final int g = _GFrac.gcd(numX.abs(), _GFrac.gcd(numC.abs(), den));
    numX ~/= g;
    numC ~/= g;
    den ~/= g;

    final String numStr = _formatNumeratorForY(numX, numC);
    if (den == 1) return 'y = $numStr';
    return 'y = \\frac{$numStr}{$den}';
  }

  /// Detailed, unskipped step-by-step lines showing how y is made the subject of the equation for JSS 3 students!
  List<String> makeYSubjectStepsLaTeX(int eqNumber) {
    final String std = toStandardLaTeX();
    // If the original input was already written as y = ..., show it directly
    if (a == 0 && b == 1) {
      return [
        "\\text{From Equation ($eqNumber): } \\mathbf{y = $c}",
      ];
    }

    final List<String> lines = [
      "\\text{\\textbf{From Equation ($eqNumber): }} \\mathbf{$std}",
    ];

    final String yTermStr = b == 1
        ? 'y'
        : (b == -1 ? '-y' : '${b}y');
    final String xTermAbsStr = a.abs() == 1 ? 'x' : '${a.abs()}x';

    // Step A: Move the x-term across the '=' sign by adding/subtracting on both sides
    final String rhsAfterMovingX = _formatNumeratorForY(-a, c);
    if (a != 0) {
      final String opSign = a > 0 ? '-' : '+';
      final String actionWord = a > 0 ? 'Subtract' : 'Add';
      lines.add(
        "\\bullet \\text{ $actionWord } $xTermAbsStr \\text{ ${a > 0 ? 'from' : 'to'} both sides to isolate the } y\\text{-term:}",
      );
      lines.add(
        "$std \\implies ${a > 0 ? '$xTermAbsStr - $xTermAbsStr' : '-$xTermAbsStr + $xTermAbsStr'} ${b < 0 ? '- ${b.abs() == 1 ? 'y' : '${b.abs()}y'}' : '+ ${b == 1 ? 'y' : '${b}y'}'} = $c $opSign $xTermAbsStr",
      );
      lines.add(
        "\\implies $yTermStr = $rhsAfterMovingX",
      );
    }

    // Step B: If b != 1, divide both sides by b (showing negative sign cancellation if b < 0!)
    if (b == 1) {
      lines.add("\\therefore \\; \\mathbf{${ySubjectLaTeX()}}");
    } else if (b == -1) {
      final String posRhs = _formatNumeratorForY(a, -c);
      lines.add(
        "\\bullet \\text{ Multiply or divide both sides by } -1 \\text{ to make } y \\text{ positive:}",
      );
      lines.add(
        "\\frac{-y}{-1} = \\frac{$rhsAfterMovingX}{-1} \\implies \\mathbf{y = $posRhs}",
      );
    } else {
      lines.add(
        "\\bullet \\text{ Divide both sides by the coefficient of } y \\text{ (which is } $b\\text{):}",
      );
      lines.add(
        "\\frac{${b}y}{$b} = \\frac{$rhsAfterMovingX}{$b}",
      );
      if (b < 0) {
        final String flippedNum = _formatNumeratorForY(a, -c);
        lines.add(
          "\\bullet \\text{ Factor out } -1 \\text{ and cancel the negative signs } \\left(\\text{since } \\frac{-}{-}=+\\right):",
        );
        lines.add(
          "y = \\frac{-($flippedNum)}{$b} = \\frac{$flippedNum}{${b.abs()}}",
        );
      }
      lines.add("\\therefore \\; \\mathbf{${ySubjectLaTeX()}}");
    }

    return lines;
  }

  /// Detailed, unskipped substitution of a specific x-value into the y-subject formula!
  String evaluateYDetailedLineLaTeX(_GFrac xVal, _GFrac yVal) {
    int numX = -a;
    int numC = c;
    int den = b;
    if (den < 0) {
      numX = -numX;
      numC = -numC;
      den = -den;
    }
    final int g = _GFrac.gcd(numX.abs(), _GFrac.gcd(numC.abs(), den));
    numX ~/= g;
    numC ~/= g;
    den ~/= g;

    final String xStr = xVal.toTableCellLaTeX();
    final String xBrack = xVal.num < 0 || xVal.den > 1 ? "\\left($xStr\\right)" : "($xStr)";
    final _GFrac prodX = _GFrac.from(numX, 1) * xVal;
    final _GFrac numTotal = prodX + _GFrac.from(numC, 1);

    // Format the substitution expression inside the numerator
    String subNumExpr = '';
    String evalNumStep = '';
    if (numC > 0 && numX < 0) {
      // Form: numC - |numX| * x
      final int absNX = numX.abs();
      subNumExpr = absNX == 1 ? "$numC - $xBrack" : "$numC - $absNX$xBrack";
      final _GFrac term2 = _GFrac.from(numX, 1) * xVal;
      evalNumStep = "$numC ${term2.toLaTeX(withSign: true)} = ${numTotal.toLaTeX()}";
    } else {
      // Form: numX * x + numC
      final String firstPart = numX == 1
          ? xBrack
          : (numX == -1 ? "-$xBrack" : "$numX$xBrack");
      final String secondPart = numC == 0
          ? ''
          : (numC < 0 ? " - ${numC.abs()}" : " + $numC");
      subNumExpr = "$firstPart$secondPart";
      evalNumStep = numC == 0
          ? prodX.toLaTeX()
          : "${prodX.toLaTeX()} ${numC < 0 ? '- ${numC.abs()}' : '+ $numC'} = ${numTotal.toLaTeX()}";
    }

    final String yFinalCell = yVal.toTableCellLaTeX();
    final String yImproperLaTeX = yVal.toLaTeX();
    final String mixedSuffix =
    (yVal.isImproper && yFinalCell != yImproperLaTeX)
        ? " = \\mathbf{$yFinalCell}"
        : "";

    if (den == 1) {
      return "\\bullet \\text{ When } x = $xStr: \\quad y = $subNumExpr = $evalNumStep = \\mathbf{$yImproperLaTeX}$mixedSuffix \\quad \\longrightarrow \\quad \\text{Point } \\left($xStr, \\; $yFinalCell\\right)";
    } else {
      final String unreducedFrac = "\\frac{${numTotal.toLaTeX()}}{$den}";
      final String reducedStep =
      (unreducedFrac != yImproperLaTeX) ? " = \\mathbf{$yImproperLaTeX}" : "";
      return "\\bullet \\text{ When } x = $xStr: \\quad y = \\frac{$subNumExpr}{$den} = \\frac{$evalNumStep}{$den} = $unreducedFrac$reducedStep$mixedSuffix \\quad \\longrightarrow \\quad \\text{Point } \\left($xStr, \\; $yFinalCell\\right)";
    }
  }

  _GFrac evaluateY(_GFrac xVal) {
    // y = (c - a*x) / b
    final _GFrac numPart =
        _GFrac.from(c, 1) - (_GFrac.from(a, 1) * xVal);
    return numPart / _GFrac.from(b, 1);
  }
}

class GraphicalMethodLogic {
  // ===========================================================================
  // 15 TEXTBOOK PRESETS (Pages 91–94: Examples 1a–c, 2a–b & Exercise 10.1 #1–10)
  // ===========================================================================
  static const List<GraphicalMethodPreset> textbookPresets = [
    GraphicalMethodPreset(
      chipLabel: "Example 1a (Page 91, Fig 10.1): x - y = 5 and 2x + y = 7",
      eq1Input: 'x - y = 5',
      eq2Input: '2x + y = 7',
      xValuesInput: '-2, -1, 0, 1, 2, 3, 4',
    ),
    GraphicalMethodPreset(
      chipLabel: "Example 1b (Page 91, Fig 10.2): 3x + y = 2 and 2x - y = 3",
      eq1Input: '3x + y = 2',
      eq2Input: '2x - y = 3',
      xValuesInput: '-2, -1, 0, 1, 2, 3, 4',
    ),
    GraphicalMethodPreset(
      chipLabel: "Example 1c (Page 92, Fig 10.3): x - 4y = -12 and x + y = 8 (Fractions!)",
      eq1Input: 'x - 4y = -12',
      eq2Input: 'x + y = 8',
      xValuesInput: '-4, -2, 0, 2, 4, 6',
    ),
    GraphicalMethodPreset(
      chipLabel: "Example 2a (Page 93, Fig 10.4): y = 7 - x and y = 2x + 1",
      eq1Input: 'y = 7 - x',
      eq2Input: 'y = 2x + 1',
      xValuesInput: '-2, -1, 0, 1, 2, 3',
    ),
    GraphicalMethodPreset(
      chipLabel: "Example 2b (Page 93, Fig 10.5): x + y = 5 and 2x + y = 6",
      eq1Input: 'x + y = 5',
      eq2Input: '2x + y = 6',
      xValuesInput: '-2, -1, 0, 1, 2',
    ),
    GraphicalMethodPreset(
      chipLabel: "Ex 10.1 #1 (Page 94): 2x + 3y = 5 and x + y = 1",
      eq1Input: '2x + 3y = 5',
      eq2Input: 'x + y = 1',
      xValuesInput: '-2, -1, 0, 1, 2, 3',
    ),
    GraphicalMethodPreset(
      chipLabel: "Ex 10.1 #2 (Page 94): 3x + y = 9 and x + 2y = 6",
      eq1Input: '3x + y = 9',
      eq2Input: 'x + 2y = 6',
      xValuesInput: '-1, 0, 1, 2, 3, 4',
    ),
    GraphicalMethodPreset(
      chipLabel: "Ex 10.1 #3 (Page 94): 2x + 5y = 8 and x + 4y = 8",
      eq1Input: '2x + 5y = 8',
      eq2Input: 'x + 4y = 8',
      xValuesInput: '-4, -2, 0, 2, 4',
    ),
    GraphicalMethodPreset(
      chipLabel: "Ex 10.1 #4 (Page 94): 3x - 3y = -3 and 3x + 2y = 12",
      eq1Input: '3x - 3y = -3',
      eq2Input: '3x + 2y = 12',
      xValuesInput: '-1, 0, 1, 2, 3, 4',
    ),
    GraphicalMethodPreset(
      chipLabel: "Ex 10.1 #5 (Page 94): x + 3y = -4 and 5x + 7y = 4",
      eq1Input: 'x + 3y = -4',
      eq2Input: '5x + 7y = 4',
      xValuesInput: '-1, 0, 1, 2, 3, 4, 5',
    ),
    GraphicalMethodPreset(
      chipLabel: "Ex 10.1 #6 (Page 94): 5x - y = 13 and 12x + 5y = 9",
      eq1Input: '5x - y = 13',
      eq2Input: '12x + 5y = 9',
      xValuesInput: '-1, 0, 1, 2, 3, 4',
    ),
    GraphicalMethodPreset(
      chipLabel: "Ex 10.1 #7 (Page 94): y - 3x = -5 and 2x + y = 6",
      eq1Input: 'y - 3x = -5',
      eq2Input: '2x + y = 6',
      xValuesInput: '-1, 0, 1, 2, 3, 4',
    ),
    GraphicalMethodPreset(
      chipLabel: "Ex 10.1 #8 (Page 94): 4x - y = 5 and 3x + 2y = 12",
      eq1Input: '4x - y = 5',
      eq2Input: '3x + 2y = 12',
      xValuesInput: '-1, 0, 1, 2, 3, 4',
    ),
    GraphicalMethodPreset(
      chipLabel: "Ex 10.1 #9 (Page 94): 3x - y = 4 and x + 2y = 6",
      eq1Input: '3x - y = 4',
      eq2Input: 'x + 2y = 6',
      xValuesInput: '-1, 0, 1, 2, 3, 4',
    ),
    GraphicalMethodPreset(
      chipLabel: "Ex 10.1 #10 (Page 94): x + y = 4 and x + 3y = 6",
      eq1Input: 'x + y = 4',
      eq2Input: 'x + 3y = 6',
      xValuesInput: '-1, 0, 1, 2, 3, 4',
    ),
  ];

  static String _buildTableOfValuesLaTeX(
      String ySubjectFormulaLaTeX,
      List<_GFrac> xVals,
      List<_GFrac> yVals,
      ) {
    final String colSpec = List.filled(xVals.length + 1, 'c').join('|');
    final List<String> xCells =
    xVals.map((_GFrac x) => x.toTableCellLaTeX()).toList();
    final List<String> yCells =
    yVals.map((_GFrac y) => "\\mathbf{${y.toTableCellLaTeX()}}").toList();

    return "\\begin{array}{|$colSpec|} \\hline "
        "x & ${xCells.join(' & ')} \\\\ \\hline "
        "y & ${yCells.join(' & ')} \\\\ \\hline "
        "\\end{array}";
  }

  // ===========================================================================
  // MASTER SOLVER: GRAPHICAL METHOD (Pages 91–94, Examples 1 & 2, Exercise 10.1)
  // ===========================================================================
  static GraphicalMethodResult solveGraphically({
    required String eq1Raw,
    required String eq2Raw,
    required String xValuesRaw,
  }) {
    try {
      if (eq1Raw.trim().isEmpty || eq2Raw.trim().isEmpty) {
        throw const FormatException(
          "Please enter both linear equations (e.g. x - y = 5 and 2x + y = 7).",
        );
      }

      final _GraphEq eq1 = _GraphEq.parse(eq1Raw);
      final _GraphEq eq2 = _GraphEq.parse(eq2Raw);

      final int det = eq1.a * eq2.b - eq2.a * eq1.b;
      if (det == 0) {
        throw const FormatException(
          "The two lines are parallel or coincident (they do not intersect at a single point).",
        );
      }

      // Exact intersection coordinates by Cramer's Rule
      final _GFrac intersectX =
      _GFrac.from(eq1.c * eq2.b - eq2.c * eq1.b, det);
      final _GFrac intersectY =
      _GFrac.from(eq1.a * eq2.c - eq2.a * eq1.c, det);

      // Parse user x-values or auto-center around intersection x
      final List<_GFrac> xList = [];
      if (xValuesRaw.trim().isNotEmpty) {
        final List<String> parts = xValuesRaw
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        for (final String p in parts) {
          xList.add(_GFrac.parse(p));
        }
      }
      if (xList.isEmpty) {
        final int center = intersectX.toDouble.round();
        for (int k = center - 3; k <= center + 3; k++) {
          xList.add(_GFrac.from(k, 1));
        }
      }

      final List<_GFrac> y1List = xList.map(eq1.evaluateY).toList();
      final List<_GFrac> y2List = xList.map(eq2.evaluateY).toList();

      final List<GraphPoint> pts1 = [
        for (int i = 0; i < xList.length; i++)
          GraphPoint(xList[i].toDouble, y1List[i].toDouble),
      ];
      final List<GraphPoint> pts2 = [
        for (int i = 0; i < xList.length; i++)
          GraphPoint(xList[i].toDouble, y2List[i].toDouble),
      ];

      final String y1SubjectLaTeX = eq1.ySubjectLaTeX();
      final String y2SubjectLaTeX = eq2.ySubjectLaTeX();

      final String table1LaTeX =
      _buildTableOfValuesLaTeX(y1SubjectLaTeX, xList, y1List);
      final String table2LaTeX =
      _buildTableOfValuesLaTeX(y2SubjectLaTeX, xList, y2List);

      // Detailed point-by-point evaluation lines for both tables so no step is skipped!
      final List<String> eq1EvalLinesLaTeX = [];
      final List<String> eq2EvalLinesLaTeX = [];
      for (int i = 0; i < xList.length; i++) {
        eq1EvalLinesLaTeX.add(
          eq1.evaluateYDetailedLineLaTeX(xList[i], y1List[i]),
        );
        eq2EvalLinesLaTeX.add(
          eq2.evaluateYDetailedLineLaTeX(xList[i], y2List[i]),
        );
      }

      final String ixLaTeX = intersectX.toTableCellLaTeX();
      final String iyLaTeX = intersectY.toTableCellLaTeX();

      final List<String> workings = [
        "\\text{\\textbf{Graphical Method Guidelines (Page 91):}}",
        "\\text{1) Make } y \\text{ the subject of each equation and construct a table of values;}",
        "\\text{2) Plot the points for both equations on the same Cartesian graph;}",
        "\\text{3) Locate the point of intersection } (x, y) \\text{ where the two straight lines cross.}",
        "",
        "\\text{\\textbf{Step 1: Make }} \\mathbf{y} \\text{\\textbf{ the Subject of Both Equations (Examples 1 \\& 2, Pages 91–93)}}",
        ...eq1.makeYSubjectStepsLaTeX(1),
        "",
        ...eq2.makeYSubjectStepsLaTeX(2),
        "",
        "\\text{\\textbf{Step 2: Construct Table of Values for 1st Line: }} \\mathbf{$y1SubjectLaTeX}",
        ...eq1EvalLinesLaTeX,
        table1LaTeX,
        "",
        "\\text{\\textbf{Step 3: Construct Table of Values for 2nd Line: }} \\mathbf{$y2SubjectLaTeX}",
        ...eq2EvalLinesLaTeX,
        table2LaTeX,
        "",
        "\\text{\\textbf{Step 4: Locate the Point of Intersection on the Graph}}",
        "\\text{The lines } $y1SubjectLaTeX \\text{ and } $y2SubjectLaTeX \\text{ intersect at the point } \\mathbf{($ixLaTeX, \\; $iyLaTeX)}.",
        "\\therefore \\; \\mathbf{x = $ixLaTeX, \\quad y = $iyLaTeX}",
      ];

      final List<GraphicalMethodStep> steps = [
        GraphicalMethodStep(
          title: "Step 1: Make \$y\$ the Subject of Each Equation (Page 91)",
          description:
          "• Why do we make \$y\$ the subject first? Because to draw a straight line on a graph, we need a rule that tells us how to calculate the vertical coordinate (\$y\$) whenever we pick any horizontal coordinate (\$x\$).\n"
              "• How we do it: For each equation, we first move the \$x\$-term across the '=' sign (remembering that when a term crosses the '=' sign, its sign changes from + to −, or from − to +). Then, if \$y\$ has a number multiplying it, we divide every term on both sides by that number.",
          mathLinesLaTeX: [
            ...eq1.makeYSubjectStepsLaTeX(1),
            ...eq2.makeYSubjectStepsLaTeX(2),
          ],
        ),
        GraphicalMethodStep(
          title: "Step 2: Build the Table of Values for the 1st Line (\$$y1SubjectLaTeX\$)",
          description:
          "• Now we choose a set of convenient \$x\$-values (${xList.map((e) => e.toPlain()).join(', ')}) and substitute each one carefully into our first formula \$$y1SubjectLaTeX\$.\n"
              "• Watch how each \$x\$-value is plugged in, simplified in the numerator, divided by the denominator, and converted to a mixed fraction if improper. Each pair of (\$x, y\$) values gives us a point to plot on the graph!",
          mathLinesLaTeX: [
            ...eq1EvalLinesLaTeX,
            table1LaTeX,
          ],
        ),
        GraphicalMethodStep(
          title: "Step 3: Build the Table of Values for the 2nd Line (\$$y2SubjectLaTeX\$)",
          description:
          "• Next, we take the exact same \$x\$-values (${xList.map((e) => e.toPlain()).join(', ')}) and substitute each one into our second formula \$$y2SubjectLaTeX\$.\n"
              "• Evaluating each step carefully gives us the second table of values for our second straight line.",
          mathLinesLaTeX: [
            ...eq2EvalLinesLaTeX,
            table2LaTeX,
          ],
        ),
        GraphicalMethodStep(
          title: "Step 4: Plot Both Straight Lines & Read the Point of Intersection",
          description:
          "• On the Cartesian graph grid, we plot all the points (\$x, y\$) from Table 1 and join them with a ruler to form the first straight line (\$$y1SubjectLaTeX\$).\n"
              "• On the same axes, we plot all the points from Table 2 and join them to form the second straight line (\$$y2SubjectLaTeX\$).\n"
              "• Finally, we look for the exact point where the two lines cross (intersect). Tracing from that crossing point down to the horizontal \$x\$-axis gives \$x = $ixLaTeX\$, and tracing across to the vertical \$y\$-axis gives \$y = $iyLaTeX\$!",
          mathLinesLaTeX: [
            "\\text{Point of Intersection of } $y1SubjectLaTeX \\text{ and } $y2SubjectLaTeX = \\mathbf{($ixLaTeX, \\; $iyLaTeX)}",
            "\\therefore \\; \\mathbf{x = $ixLaTeX, \\quad y = $iyLaTeX}",
          ],
        ),
      ];

      return GraphicalMethodResult(
        finalAnswersLaTeX: {
          "1st Line Formula": y1SubjectLaTeX,
          "2nd Line Formula": y2SubjectLaTeX,
          "Intersection Point": "\\mathbf{($ixLaTeX, \\; $iyLaTeX)}",
          "Solution (x, y)": "\\mathbf{x = $ixLaTeX, \\; y = $iyLaTeX}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: GraphicalMethodCanvasData(
          headerLaTeX:
          "\\text{Graphical Solution (Pages 91–94): Intersect at } \\mathbf{x = $ixLaTeX, \\; y = $iyLaTeX}",
          subHeaderLaTeX:
          "\\text{Line 1: } $y1SubjectLaTeX \\qquad | \\qquad \\text{Line 2: } $y2SubjectLaTeX",
          eq1SubjectLaTeX: y1SubjectLaTeX,
          eq2SubjectLaTeX: y2SubjectLaTeX,
          table1LaTeX: table1LaTeX,
          table2LaTeX: table2LaTeX,
          line1Points: pts1,
          line2Points: pts2,
          intersection:
          GraphPoint(intersectX.toDouble, intersectY.toDouble),
          intersectionLabelLaTeX: "\\mathbf{($ixLaTeX, \\; $iyLaTeX)}",
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{The lines intersect at } \\mathbf{($ixLaTeX, \\; $iyLaTeX)} \\implies \\mathbf{x = $ixLaTeX, \\; y = $iyLaTeX}",
        ),
      );
    } catch (e) {
      return GraphicalMethodResult.error(
        message: e is FormatException
            ? e.message
            : "Please enter two valid linear equations in x and y.",
      );
    }
  }
}