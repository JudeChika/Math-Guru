import 'graphs_of_inequalities_models.dart';

class GraphsOfInequalitiesLogic {
  // ===========================================================================
  // 14 TEXTBOOK PRESETS (Covers Figures 22.1–22.6, Examples 5–7 & Exercise 22d)
  // ===========================================================================
  static const List<GraphInequalityPreset> textbookPresets = [
    GraphInequalityPreset(
      chipLabel: "Fig 22.1: Graph of x < 2 (Open Circle, Left)",
      mode: 0,
      graphStyle: 1,
      varName: 'x',
      symbol: '<',
      boundaryStr: '2',
    ),
    GraphInequalityPreset(
      chipLabel: "Fig 22.2: Graph of x ≥ -1 (Shaded Circle, Right)",
      mode: 0,
      graphStyle: 1,
      varName: 'x',
      symbol: '>=',
      boundaryStr: '-1',
    ),
    GraphInequalityPreset(
      chipLabel: "Fig 22.3: Compare All 3 Drawing Styles (x ≥ -1)",
      mode: 0,
      graphStyle: 2,
      varName: 'x',
      symbol: '>=',
      boundaryStr: '-1',
    ),
    GraphInequalityPreset(
      chipLabel: "Ex 5 (Fig 22.4): Read Graph at 4 (Shaded, Left)",
      mode: 1,
      graphStyle: 1,
      varName: 'x',
      boundaryStr: '4',
      isShadedCircle: true,
      pointsRight: false,
    ),
    GraphInequalityPreset(
      chipLabel: "Ex 22d #1a: Read Graph at 3 (Empty, Left)",
      mode: 1,
      graphStyle: 0,
      varName: 'x',
      boundaryStr: '3',
      isShadedCircle: false,
      pointsRight: false,
    ),
    GraphInequalityPreset(
      chipLabel: "Ex 22d #1c: Read Graph at -2 (Shaded, Right)",
      mode: 1,
      graphStyle: 0,
      varName: 'x',
      boundaryStr: '-2',
      isShadedCircle: true,
      pointsRight: true,
    ),
    GraphInequalityPreset(
      chipLabel: "Ex 22d #1e: Read Graph at -4 (Empty, Right)",
      mode: 1,
      graphStyle: 0,
      varName: 'x',
      boundaryStr: '-4',
      isShadedCircle: false,
      pointsRight: true,
    ),
    GraphInequalityPreset(
      chipLabel: "Ex 22d #1f: Read Graph at -4 (Shaded, Left)",
      mode: 1,
      graphStyle: 0,
      varName: 'x',
      boundaryStr: '-4',
      isShadedCircle: true,
      pointsRight: false,
    ),
    GraphInequalityPreset(
      chipLabel: "Ex 22d #1h: Read Graph at 2½ (Shaded, Right)",
      mode: 1,
      graphStyle: 0,
      varName: 'x',
      boundaryStr: '2 1/2',
      isShadedCircle: true,
      pointsRight: true,
    ),
    GraphInequalityPreset(
      chipLabel: "Ex 22d #2c: Sketch Graph of x ≥ -3",
      mode: 0,
      graphStyle: 0,
      varName: 'x',
      symbol: '>=',
      boundaryStr: '-3',
    ),
    GraphInequalityPreset(
      chipLabel: "Ex 22d #2d: Sketch Graph of x ≤ 0",
      mode: 0,
      graphStyle: 0,
      varName: 'x',
      symbol: '<=',
      boundaryStr: '0',
    ),
    GraphInequalityPreset(
      chipLabel: "Fig 22.6: Reversed 3½ ≤ x (Arrange LHS → x ≥ 3½)",
      mode: 0,
      graphStyle: 1,
      varName: 'x',
      symbol: '<=',
      boundaryStr: '3 1/2',
      isReversedInput: true,
    ),
    GraphInequalityPreset(
      chipLabel: "Ex 7 (Fig 22.6): Solve & Graph 6 ≤ 2x - 1",
      mode: 2,
      graphStyle: 1,
      fullInequalityExpr: '6 <= 2x - 1',
    ),
    GraphInequalityPreset(
      chipLabel: "Page 193: Inspect 3x > -12 vs 2x - y ≤ 7",
      mode: 3,
      fullInequalityExpr: '3x > -12',
    ),
  ];

  // ===========================================================================
  // REUSABLE PARSING & FORMATTING HELPERS
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
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// Parses whole numbers, decimals, fractions ("7/2"), or mixed numbers ("2 1/2", "-1 1/2")
  static Map<String, dynamic> parseBoundaryValue(String raw) {
    final String s = raw
        .trim()
        .replaceAll('½', ' 1/2')
        .replaceAll('¼', ' 1/4')
        .replaceAll('¾', ' 3/4')
        .replaceAll('−', '-')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (s.isEmpty) {
      throw const FormatException("Boundary value cannot be empty.");
    }

    if (s.contains('/')) {
      if (s.contains(' ')) {
        final List<String> parts = s.split(' ');
        final int whole = int.parse(parts[0]);
        final List<String> fParts = parts[1].split('/');
        final int n = int.parse(fParts[0]);
        final int d = int.parse(fParts[1]);
        if (d == 0) throw const FormatException("Denominator cannot be zero.");
        final double val = whole < 0 ? whole - (n / d) : whole + (n / d);
        final String sign = whole < 0 ? "-" : "";
        final int absW = whole.abs();
        final String disp = n == 1 && d == 2
            ? "$sign${absW}½"
            : "$sign$absW $n/$d";
        return {
          'value': val,
          'latex': "$sign$absW\\frac{$n}{$d}",
          'display': disp,
        };
      } else {
        final List<String> fParts = s.split('/');
        final int n = int.parse(fParts[0]);
        final int d = int.parse(fParts[1]);
        if (d == 0) throw const FormatException("Denominator cannot be zero.");
        final double val = n / d;
        return formatAsMixedFraction(n, d, fallbackVal: val);
      }
    }

    final double? val = double.tryParse(s);
    if (val == null) {
      throw const FormatException(
          "Enter a valid number or mixed fraction (e.g. 2, -4, or 2 1/2).");
    }

    // Check if decimal ends in .5 so we can also display textbook mixed fraction (e.g. 2.5 -> 2½)
    if (((val * 2).roundToDouble() - val * 2).abs() < 1e-9 &&
        (val - val.roundToDouble()).abs() > 1e-9) {
      final int num = (val * 2).round();
      return formatAsMixedFraction(num, 2, fallbackVal: val);
    }

    return {
      'value': val,
      'latex': fmt(val),
      'display': fmt(val),
    };
  }

  static Map<String, dynamic> formatAsMixedFraction(
      int num,
      int den, {
        double? fallbackVal,
      }) {
    final double val = fallbackVal ?? (num / den);
    if (num == 0) {
      return {'value': 0.0, 'latex': '0', 'display': '0'};
    }
    final bool isNeg = (num < 0) ^ (den < 0);
    int n = num.abs();
    int d = den.abs();
    final int g = _gcd(n, d);
    n ~/= g;
    d ~/= g;
    final String sign = isNeg ? "-" : "";

    if (d == 1) {
      return {'value': val, 'latex': '$sign$n', 'display': '$sign$n'};
    }
    if (n > d) {
      final int w = n ~/ d;
      final int rem = n % d;
      final String disp = (rem == 1 && d == 2)
          ? "$sign${w}½"
          : "$sign$w $rem/$d";
      return {
        'value': val,
        'latex': '$sign$w\\frac{$rem}{$d}',
        'display': disp,
      };
    }
    final String disp = (n == 1 && d == 2) ? "${sign}½" : "$sign$n/$d";
    return {
      'value': val,
      'latex': '$sign\\frac{$n}{$d}',
      'display': disp,
    };
  }

  static String symbolToLaTeX(String sym) {
    switch (sym.trim()) {
      case '>=':
      case '≥':
        return '\\ge';
      case '<=':
      case '≤':
        return '\\le';
      case '!=':
      case '≠':
        return '\\neq';
      case '>':
        return '>';
      case '<':
      default:
        return '<';
    }
  }

  static String symbolToDisplay(String sym) {
    switch (sym.trim()) {
      case '>=':
      case '\\ge':
        return '≥';
      case '<=':
      case '\\le':
        return '≤';
      case '!=':
      case '\\neq':
        return '≠';
      default:
        return sym.trim();
    }
  }

  static String reverseSymbol(String sym) {
    switch (sym.trim()) {
      case '>':
        return '<';
      case '<':
        return '>';
      case '>=':
      case '≥':
        return '<=';
      case '<=':
      case '≤':
        return '>=';
      default:
        return sym.trim();
    }
  }

  static bool isInclusive(String sym) {
    final String s = sym.trim();
    return s == '>=' || s == '<=' || s == '≥' || s == '≤';
  }

  static bool isGreater(String sym) {
    final String s = sym.trim();
    return s == '>' || s == '>=' || s == '≥';
  }

  // ===========================================================================
  // MODE 0: SKETCH THE GRAPH OF AN INEQUALITY ON A NUMBER LINE
  // Matches Figures 22.1, 22.2, 22.3, 22.6 & Exercise 22d #2(a–j)
  // ===========================================================================
  static GraphInequalityResult solveSketchGraph({
    required String varName,
    required String rawSymbol,
    required String boundaryStr,
    required bool isReversedInput,
    required int graphStyle,
  }) {
    try {
      final String v = varName.trim().isEmpty ? 'x' : varName.trim();
      final Map<String, dynamic> bData = parseBoundaryValue(boundaryStr);
      final double bVal = bData['value'] as double;
      final String bLatex = bData['latex'] as String;
      final String bDisp = bData['display'] as String;

      final String inputSym = rawSymbol.trim();
      final String effectiveSym =
      isReversedInput ? reverseSymbol(inputSym) : inputSym;
      final String effSymTex = symbolToLaTeX(effectiveSym);
      final String effSymDisp = symbolToDisplay(effectiveSym);
      final String revSymTex = symbolToLaTeX(reverseSymbol(effectiveSym));
      final String revSymDisp = symbolToDisplay(reverseSymbol(effectiveSym));

      final bool shaded = isInclusive(effectiveSym);
      final bool rightArrow = isGreater(effectiveSym);
      final bool isNotEq = effectiveSym == '!=' || effectiveSym == '≠';

      final List<String> workings = [];
      final List<GraphInequalityStep> steps = [];
      final Map<String, String> answers = {};

      // Step 1: Arrange Unknown on the Left-Hand Side (Page 195 Rule)
      if (isReversedInput) {
        final String origTex = symbolToLaTeX(inputSym);
        final String origDisp = symbolToDisplay(inputSym);
        workings.add(
            "\\text{\\textbf{Step 1: Arrange Unknown ($v) on the Left-Hand Side (Page 195 Rule)}}");
        workings.add(
            "\\text{Given: } $bLatex \\; $origTex \\; $v \\quad \\Longrightarrow \\quad $v \\; $effSymTex \\; $bLatex");
        workings.add("");

        steps.add(GraphInequalityStep(
          title: "Step 1: Arrange the Unknown ($v) on the Left-Hand Side",
          description:
          "Textbook Rule (page 195): 'Always try to arrange for the unknown to be on the left-hand side of the inequality. This makes it easier to sketch the graph.'\n"
              "• Given statement: $bDisp $origDisp $v.\n"
              "• Swap both sides and reverse the inequality sign so it still points to the same term:\n"
              "  $v $effSymDisp $bDisp.",
          mathLaTeX: "$bLatex \\; $origTex \\; $v \\iff $v \\; $effSymTex \\; $bLatex",
        ));
      } else {
        workings.add("\\text{\\textbf{Step 1: Inequality to Graph}}");
        workings.add(
            "$v \\; $effSymTex \\; $bLatex \\quad \\left(\\text{Equivalent reversed form: } $bLatex \\; $revSymTex \\; $v\\right)");
        workings.add("");

        steps.add(GraphInequalityStep(
          title: "Step 1: Check That the Unknown ($v) is on the Left-Hand Side",
          description:
          "The unknown '$v' is already on the left-hand side of '$v $effSymDisp $bDisp', so we can read the circle type and arrow direction directly.",
          mathLaTeX: "$v \\; $effSymTex \\; $bLatex",
        ));
      }

      // Step 2: Locate Boundary & Choose Empty (○) vs. Shaded (●) Circle
      final String circleType = shaded
          ? "Shaded (Solid) Circle (●)"
          : "Empty (Open) Circle (○)";
      final String inclusionWord = shaded
          ? "IS included ($v = $bDisp is part of the solution)"
          : "is NOT included ($v cannot equal $bDisp)";

      String tickLocationNote =
          "Locate $bDisp on the horizontal number line.";
      if ((bVal - bVal.roundToDouble()).abs() > 1e-9) {
        final int lowerInt = bVal.floor();
        final int upperInt = bVal.ceil();
        tickLocationNote =
        "Because $bDisp is a fraction/mixed number, mark its position between the integers $lowerInt and $upperInt on the number line (as shown in Figure 22.5h & Figure 22.6).";
      }

      workings.add(
          "\\text{\\textbf{Step 2: Circle Type at Boundary }} $v = $bLatex");
      workings.add(
          "\\text{Sign is } $effSymTex \\implies \\text{Draw a \\textbf{$circleType} at } $bLatex");
      workings.add(
          "\\text{(Reason: The value } $bLatex \\text{ $inclusionWord.)}");
      workings.add("");

      steps.add(GraphInequalityStep(
        title: "Step 2: Draw an ${shaded ? 'Shaded (●)' : 'Empty (○)'} Circle at $bDisp",
        description:
        "1. $tickLocationNote\n"
            "2. Check whether the boundary value $bDisp is included:\n"
            "   • Empty circle (○) is used for '<' or '>' (boundary NOT included).\n"
            "   • Shaded circle (●) is used for '≤' or '≥' (boundary IS included).\n"
            "3. Since our symbol is '$effSymDisp', the value $bDisp $inclusionWord. Draw a $circleType at $bDisp.",
        mathLaTeX:
        "\\text{At } $bLatex: \\quad \\text{\\textbf{$circleType}}",
      ));

      // Step 3: Determine Heavy Arrowed Ray Direction (Left vs. Right)
      final String arrowDir = isNotEq
          ? "Both Left (←) and Right (→)"
          : (rightArrow ? "To the RIGHT (→)" : "To the LEFT (←)");

      workings.add("\\text{\\textbf{Step 3: Direction of Heavy Arrowed Line}}");
      if (isNotEq) {
        workings.add(
            "\\text{Since } $v \\neq $bLatex, \\; $v \\text{ can be any number less than } $bLatex \\text{ OR greater than } $bLatex.");
        workings.add(
            "\\text{Draw heavy arrowed lines pointing both LEFT and RIGHT from the open circle at } $bLatex.");
      } else {
        workings.add(
            "\\text{Since } $v \\; $effSymTex \\; $bLatex, \\text{ draw a heavy arrowed line pointing \\textbf{$arrowDir} from } $bLatex.");
      }
      workings.add("");

      steps.add(GraphInequalityStep(
        title: "Step 3: Draw the Heavy Arrowed Line $arrowDir",
        description: isNotEq
            ? "Because $v ≠ $bDisp (page 190), $v can be any positive or negative number except $bDisp. Draw heavy arrowed lines pointing both to the LEFT and to the RIGHT of the empty circle at $bDisp."
            : (rightArrow
            ? "The inequality '$v $effSymDisp $bDisp' means $v can have any value greater than${shaded ? ' or equal to' : ''} $bDisp.\n"
            "• On a horizontal number line, greater numbers lie to the RIGHT.\n"
            "• Draw a heavy bold line with an arrowhead pointing to the RIGHT (→) starting from the circle at $bDisp."
            : "The inequality '$v $effSymDisp $bDisp' means $v can have any value less than${shaded ? ' or equal to' : ''} $bDisp.\n"
            "• On a horizontal number line, smaller numbers lie to the LEFT.\n"
            "• Draw a heavy bold line with an arrowhead pointing to the LEFT (←) starting from the circle at $bDisp."),
        mathLaTeX:
        "\\text{Arrow Direction from } $bLatex: \\quad \\text{\\textbf{$arrowDir}}",
      ));

      // Step 4: Sample Integer Solutions Check
      final List<int> sampleInts = [];
      if (isNotEq) {
        final int c = bVal.round();
        sampleInts.addAll([c - 2, c - 1, c + 1, c + 2]);
      } else if (rightArrow) {
        int startInt = bVal.ceil();
        if (!shaded && (startInt - bVal).abs() < 1e-9) startInt += 1;
        for (int i = 0; i < 4; i++) {
          sampleInts.add(startInt + i);
        }
      } else {
        int startInt = bVal.floor();
        if (!shaded && (startInt - bVal).abs() < 1e-9) startInt -= 1;
        for (int i = 0; i < 4; i++) {
          sampleInts.add(startInt - i);
        }
      }

      final String sampleListStr = rightArrow
          ? "${sampleInts.join(', ')}, ..."
          : "..., ${sampleInts.reversed.join(', ')}";

      workings.add(
          "\\text{\\textbf{Step 4: Sample Integer Values in the Solution Range}}");
      workings.add(
          "\\text{Examples of integers satisfying } $v \\; $effSymTex \\; $bLatex: \\quad $v \\in \\{$sampleListStr\\}");

      steps.add(GraphInequalityStep(
        title: "Step 4: Check with Sample Integer Solutions on the Number Line",
        description:
        "An inequality has infinitely many solutions along the heavy arrowed line (page 194). You can verify your arrow direction by testing integer values on that side of $bDisp:\n"
            "• Sample integers in the solution range: $sampleListStr.\n"
            "• For example, substituting $v = ${sampleInts.first} into '$v $effSymDisp $bDisp' gives '${sampleInts.first} $effSymDisp $bDisp', which is True!",
        mathLaTeX:
        "\\text{Test } $v = ${sampleInts.first}: \\quad ${sampleInts.first} \\; $effSymTex \\; $bLatex \\; (\\text{True!})",
      ));

      answers["Inequality (Standard)"] = "$v $effSymDisp $bDisp";
      answers["Circle at $bDisp"] = shaded ? "Shaded (●)" : "Empty (○)";
      answers["Arrow Direction"] = rightArrow ? "Right (→)" : "Left (←)";
      answers["Sample Integers"] = sampleListStr;

      return GraphInequalityResult(
        mode: 0,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        visualData: NumberLineVisualData(
          boundaryVal: bVal,
          boundaryDisplay: bDisp,
          varName: v,
          symbolDisplay: effSymDisp,
          isShaded: shaded,
          pointsRight: rightArrow,
          isNotEqual: isNotEq,
          graphStyle: graphStyle,
          headerBadge: "Graph of  $v $effSymDisp $bDisp",
          subBadge:
          "${shaded ? 'Shaded Circle (● Included)' : 'Empty Circle (○ Not Included)'}  |  Arrow Points ${rightArrow ? 'Right (→)' : 'Left (←)'}",
        ),
      );
    } catch (e) {
      return GraphInequalityResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter a valid boundary number or mixed fraction (e.g. 2, -3, or 2 1/2).",
      );
    }
  }

  // ===========================================================================
  // MODE 1: READ & WRITE THE INEQUALITY SHOWN BY A NUMBER LINE GRAPH
  // Matches Example 5 (Fig 22.4) & Exercise 22d #1(a–j) (Fig 22.5)
  // ===========================================================================
  static GraphInequalityResult solveReadGraph({
    required String varName,
    required String boundaryStr,
    required bool isShadedCircle,
    required bool pointsRight,
    required int graphStyle,
  }) {
    try {
      final String v = varName.trim().isEmpty ? 'x' : varName.trim();
      final Map<String, dynamic> bData = parseBoundaryValue(boundaryStr);
      final double bVal = bData['value'] as double;
      final String bLatex = bData['latex'] as String;
      final String bDisp = bData['display'] as String;

      final String strictSym = pointsRight ? '>' : '<';
      final String finalSym = pointsRight
          ? (isShadedCircle ? '>=' : '>')
          : (isShadedCircle ? '<=' : '<');
      final String finalSymTex = symbolToLaTeX(finalSym);
      final String finalSymDisp = symbolToDisplay(finalSym);
      final String revSymTex = symbolToLaTeX(reverseSymbol(finalSym));
      final String revSymDisp = symbolToDisplay(reverseSymbol(finalSym));

      final String dirWord = pointsRight ? "right" : "left";
      final String circleWord = isShadedCircle ? "shaded" : "empty (open)";

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Read the Circle at }} $bLatex \\text{\\textbf{ (Example 5 Method)}}",
        isShadedCircle
            ? "\\text{The shaded circle at } $bLatex \\text{ shows that the value } $v = $bLatex \\text{ IS included.}"
            : "\\text{The empty circle at } $bLatex \\text{ shows that the value } $v = $bLatex \\text{ is NOT included.}",
        "",
        "\\text{\\textbf{Step 2: Read the Heavy Arrowed Line}}",
        "\\text{The heavy line to the $dirWord of } $bLatex \\text{ shows that } $v \\text{ can have values in the range } $v \\; $strictSym \\; $bLatex.",
        "",
        "\\text{\\textbf{Step 3: Combine Both Clues into the Inequality}}",
        isShadedCircle
            ? "\\text{Combining } $v \\; $strictSym \\; $bLatex \\text{ and } $v = $bLatex \\text{ gives:}"
            : "\\text{Since } $v = $bLatex \\text{ is not included, the inequality is strictly:}",
        "$v \\; $finalSymTex \\; $bLatex \\quad \\left(\\text{or } $bLatex \\; $revSymTex \\; $v\\right)",
      ];

      final List<GraphInequalityStep> steps = [
        GraphInequalityStep(
          title: "Step 1: Inspect the Circle at $bDisp (Included or Not Included?)",
          description: isShadedCircle
              ? "Look at the circle positioned at $bDisp on the number line:\n"
              "• Because it is a SHADED (solid) circle (●), the boundary value $v = $bDisp IS included in the solution."
              : "Look at the circle positioned at $bDisp on the number line:\n"
              "• Because it is an EMPTY (open) circle (○), the boundary value $v = $bDisp is NOT included in the solution.",
          mathLaTeX: isShadedCircle
              ? "\\text{Shaded circle at } $bLatex \\implies $v = $bLatex \\text{ is included}"
              : "\\text{Empty circle at } $bLatex \\implies $v = $bLatex \\text{ is NOT included}",
        ),
        GraphInequalityStep(
          title: "Step 2: Inspect the Direction of the Heavy Arrowed Line",
          description:
          "Look at which way the heavy arrowed line points from the $circleWord circle at $bDisp:\n"
              "• The heavy line points to the ${dirWord.toUpperCase()} of $bDisp.\n"
              "• Numbers to the $dirWord of $bDisp are ${pointsRight ? 'greater' : 'less'} than $bDisp, which represents the range $v $strictSym $bDisp.",
          mathLaTeX:
          "\\text{Heavy line to the $dirWord of } $bLatex \\implies $v \\; $strictSym \\; $bLatex",
        ),
        GraphInequalityStep(
          title: "Step 3: Write Down the Complete Inequality (Example 5)",
          description: isShadedCircle
              ? "Combine Step 1 ($v = $bDisp is included) and Step 2 ($v $strictSym $bDisp):\n"
              "• Putting '$strictSym' and '=' together gives '$finalSymDisp'.\n"
              "• Thus, the graph shows the inequality $v $finalSymDisp $bDisp (also written $bDisp $revSymDisp $v)."
              : "Combine Step 1 ($v = $bDisp is not included) and Step 2 ($v $strictSym $bDisp):\n"
              "• Thus, the graph shows the strict inequality $v $finalSymDisp $bDisp (also written $bDisp $revSymDisp $v).",
          mathLaTeX:
          "\\text{Inequality: } \\boxed{$v \\; $finalSymTex \\; $bLatex} \\quad \\left(\\text{or } $bLatex \\; $revSymTex \\; $v\\right)",
        ),
      ];

      return GraphInequalityResult(
        mode: 1,
        finalAnswers: {
          "Inequality Shown": "$v $finalSymDisp $bDisp",
          "Reversed Form": "$bDisp $revSymDisp $v",
          "Boundary ($bDisp)": isShadedCircle ? "Included (●)" : "Not Included (○)",
          "Arrow Range": "$v $strictSym $bDisp (${dirWord.toUpperCase()})",
        },
        workingsLaTeX: workings,
        steps: steps,
        visualData: NumberLineVisualData(
          boundaryVal: bVal,
          boundaryDisplay: bDisp,
          varName: v,
          symbolDisplay: finalSymDisp,
          isShaded: isShadedCircle,
          pointsRight: pointsRight,
          graphStyle: graphStyle,
          headerBadge: "Graph Shows:  $v $finalSymDisp $bDisp",
          subBadge:
          "${isShadedCircle ? 'Shaded Circle at $bDisp ($v = $bDisp included)' : 'Empty Circle at $bDisp ($v = $bDisp excluded)'}  +  Line to $dirWord ($v $strictSym $bDisp)",
        ),
      );
    } catch (e) {
      return GraphInequalityResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter a valid number where the circle sits on the number line.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: SOLVE 1-STEP / 2-STEP INEQUALITY & SKETCH GRAPH
  // Matches Examples 6 & 7 (Figures 22.1 & 22.6)
  // ===========================================================================
  static Map<String, double> _parseLinearSide(String side, String varName) {
    final String s = side
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll('--', '+')
        .replaceAll('+-', '-')
        .replaceAll('-', '+-');
    final List<String> chunks =
    s.split('+').where((c) => c.trim().isNotEmpty).toList();

    double coeff = 0.0;
    double constant = 0.0;
    for (final String c in chunks) {
      if (c.contains(varName)) {
        final String numPart = c.replaceAll(varName, '').trim();
        if (numPart.isEmpty || numPart == '+') {
          coeff += 1.0;
        } else if (numPart == '-') {
          coeff -= 1.0;
        } else {
          coeff += double.parse(numPart);
        }
      } else {
        constant += double.parse(c);
      }
    }
    return {'coeff': coeff, 'const': constant};
  }

  static GraphInequalityResult solveAndSketchLinear({
    required String rawInequality,
    required int graphStyle,
  }) {
    try {
      final String clean = rawInequality
          .trim()
          .replaceAll('≤', '<=')
          .replaceAll('≥', '>=')
          .replaceAll('−', '-');

      final RegExp symReg = RegExp(r'(<=|>=|<|>)');
      final Match? m = symReg.firstMatch(clean);
      if (m == null) {
        throw const FormatException(
            "Inequality must contain <, >, <=, or >= (e.g. x + 4 < 6 or 6 <= 2x - 1).");
      }

      final String sym = m.group(0)!;
      final List<String> sides = clean.split(symReg);
      if (sides.length != 2) {
        throw const FormatException("Invalid inequality format.");
      }

      // Detect variable letter
      final Match? varMatch = RegExp(r'[a-zA-Z]').firstMatch(clean);
      final String v = varMatch != null ? varMatch.group(0)! : 'x';

      final Map<String, double> lhs = _parseLinearSide(sides[0], v);
      final Map<String, double> rhs = _parseLinearSide(sides[1], v);

      double lCoeff = lhs['coeff']!;
      double lConst = lhs['const']!;
      double rCoeff = rhs['coeff']!;
      double rConst = rhs['const']!;

      if ((lCoeff - rCoeff).abs() < 1e-9) {
        throw const FormatException("The variable terms cancel out.");
      }

      final List<String> workings = [];
      final List<GraphInequalityStep> steps = [];
      String currentSym = sym;

      workings.add("\\text{\\textbf{Step 1: Original Linear Inequality}}");
      workings.add("${sides[0].trim()} \\; ${symbolToLaTeX(currentSym)} \\; ${sides[1].trim()}");
      workings.add("");

      // Determine if variable is primarily on RHS (like Example 7: 6 <= 2x - 1)
      final bool varOnlyOnRhs = lCoeff == 0 && rCoeff != 0;

      if (varOnlyOnRhs) {
        // Solve in place like Example 7, then flip at the end so unknown is on LHS!
        if (rConst != 0) {
          final String opWord = rConst < 0 ? "Add" : "Subtract";
          final double absC = rConst.abs();
          lConst = lConst - rConst;
          rConst = 0;

          workings.add(
              "\\text{\\textbf{Step 2: $opWord ${fmt(absC)} ${rConst < 0 ? 'to' : 'from'} Both Sides (Balance Method)}}");
          workings.add(
              "${fmt(lConst)} \\; ${symbolToLaTeX(currentSym)} \\; ${fmt(rCoeff) == '1' ? v : '${fmt(rCoeff)}$v'}");
          workings.add("");

          steps.add(GraphInequalityStep(
            title: "Step 1: $opWord ${fmt(absC)} on Both Sides (Example 7)",
            description:
            "Use the balance method just like solving an equation: ${opWord.toLowerCase()} ${fmt(absC)} on both sides to isolate the '$v' term.",
            mathLaTeX:
            "${fmt(lConst)} \\; ${symbolToLaTeX(currentSym)} \\; ${fmt(rCoeff) == '1' ? v : '${fmt(rCoeff)}$v'}",
          ));
        }

        if ((rCoeff - 1.0).abs() > 1e-9) {
          final bool divByNeg = rCoeff < 0;
          if (divByNeg) currentSym = reverseSymbol(currentSym);
          final Map<String, dynamic> frac = formatAsMixedFraction(
            (lConst * 100).round(),
            (rCoeff * 100).round(),
          );
          final String bTex = frac['latex'] as String;

          workings.add(
              "\\text{\\textbf{Step 3: Divide Both Sides by ${fmt(rCoeff)}}}");
          workings.add(
              "\\frac{${fmt(lConst)}}{${fmt(rCoeff)}} \\; ${symbolToLaTeX(currentSym)} \\; \\frac{${fmt(rCoeff)}$v}{${fmt(rCoeff)}} \\implies $bTex \\; ${symbolToLaTeX(currentSym)} \\; $v");
          workings.add("");

          steps.add(GraphInequalityStep(
            title: "Step 2: Divide Both Sides by ${fmt(rCoeff)}",
            description:
            "Divide both sides by the coefficient ${fmt(rCoeff)}${divByNeg ? ' (and reverse the inequality sign because we divided by a negative number)' : ''}:\n"
                "• $bTex ${symbolToDisplay(currentSym)} $v.",
            mathLaTeX: "$bTex \\; ${symbolToLaTeX(currentSym)} \\; $v",
          ));
        }

        final Map<String, dynamic> finalFrac = formatAsMixedFraction(
          (lConst * 100).round(),
          (rCoeff * 100).round(),
        );
        final String finalSym = reverseSymbol(currentSym);
        final String bDisp = finalFrac['display'] as String;
        final String bTex = finalFrac['latex'] as String;
        final double bVal = finalFrac['value'] as double;

        workings.add(
            "\\text{\\textbf{Step 4: Arrange Unknown ($v) on the Left-Hand Side Before Sketching}}");
        workings.add(
            "\\text{If } $bTex \\; ${symbolToLaTeX(currentSym)} \\; $v, \\text{ then } $v \\; ${symbolToLaTeX(finalSym)} \\; $bTex");

        steps.add(GraphInequalityStep(
          title:
          "Step 3: Arrange $v on the Left-Hand Side & Sketch on Number Line (Figure 22.6)",
          description:
          "If $bDisp ${symbolToDisplay(currentSym)} $v, then $v ${symbolToDisplay(finalSym)} $bDisp.\n"
              "• Putting $v on the left-hand side makes it easy to sketch the graph: draw a ${isInclusive(finalSym) ? 'shaded (●)' : 'empty (○)'} circle at $bDisp and a heavy arrowed line pointing to the ${isGreater(finalSym) ? 'RIGHT (→)' : 'LEFT (←)'}.",
          mathLaTeX:
          "$bTex \\; ${symbolToLaTeX(currentSym)} \\; $v \\iff \\boxed{$v \\; ${symbolToLaTeX(finalSym)} \\; $bTex}",
        ));

        return GraphInequalityResult(
          mode: 2,
          finalAnswers: {
            "Solution": "$v ${symbolToDisplay(finalSym)} $bDisp",
            "Reversed Step": "$bDisp ${symbolToDisplay(currentSym)} $v",
            "Circle at $bDisp":
            isInclusive(finalSym) ? "Shaded (●)" : "Empty (○)",
            "Arrow Direction":
            isGreater(finalSym) ? "Right (→)" : "Left (←)",
          },
          workingsLaTeX: workings,
          steps: steps,
          visualData: NumberLineVisualData(
            boundaryVal: bVal,
            boundaryDisplay: bDisp,
            varName: v,
            symbolDisplay: symbolToDisplay(finalSym),
            isShaded: isInclusive(finalSym),
            pointsRight: isGreater(finalSym),
            graphStyle: graphStyle,
            headerBadge:
            "Solution of $rawInequality:   $v ${symbolToDisplay(finalSym)} $bDisp",
            subBadge:
            "${isInclusive(finalSym) ? 'Shaded Circle (●)' : 'Empty Circle (○)'} at $bDisp   |   Heavy Line Points ${isGreater(finalSym) ? 'Right (→)' : 'Left (←)'}",
          ),
        );
      } else {
        // Standard LHS isolation (like Example 6: x + 4 < 6)
        if (rCoeff != 0) {
          lCoeff -= rCoeff;
          rCoeff = 0;
        }
        if (lConst != 0) {
          final String opWord = lConst > 0 ? "Subtract" : "Add";
          final double absC = lConst.abs();
          final double oldRConst = rConst;
          rConst -= lConst;
          lConst = 0;

          workings.add(
              "\\text{\\textbf{Step 2: $opWord ${fmt(absC)} ${opWord == 'Add' ? 'to' : 'from'} Both Sides (Example 6)}}");
          workings.add(
              "${fmt(lCoeff) == '1' ? v : '${fmt(lCoeff)}$v'} \\; ${symbolToLaTeX(currentSym)} \\; ${fmt(oldRConst)} ${opWord == 'Add' ? '+' : '-'} ${fmt(absC)} \\implies ${fmt(lCoeff) == '1' ? v : '${fmt(lCoeff)}$v'} \\; ${symbolToLaTeX(currentSym)} \\; ${fmt(rConst)}");
          workings.add("");

          steps.add(GraphInequalityStep(
            title: "Step 1: $opWord ${fmt(absC)} on Both Sides (Balance Method)",
            description:
            "$opWord ${fmt(absC)} on both sides of the inequality to isolate the '$v' term on the left-hand side.",
            mathLaTeX:
            "${fmt(lCoeff) == '1' ? v : '${fmt(lCoeff)}$v'} \\; ${symbolToLaTeX(currentSym)} \\; ${fmt(rConst)}",
          ));
        }

        if ((lCoeff - 1.0).abs() > 1e-9) {
          final bool divByNeg = lCoeff < 0;
          if (divByNeg) currentSym = reverseSymbol(currentSym);
        }

        final Map<String, dynamic> finalFrac = formatAsMixedFraction(
          (rConst * 100).round(),
          (lCoeff * 100).round(),
        );
        final String bDisp = finalFrac['display'] as String;
        final String bTex = finalFrac['latex'] as String;
        final double bVal = finalFrac['value'] as double;
        final String symDisp = symbolToDisplay(currentSym);
        final String symTex = symbolToLaTeX(currentSym);

        workings.add("\\text{\\textbf{Step 3: Solution & Number Line Graph}}");
        workings.add("$v \\; $symTex \\; $bTex");

        steps.add(GraphInequalityStep(
          title: "Step 2: Sketch the Solution $v $symDisp $bDisp on the Number Line",
          description:
          "When solving inequalities, do not try to list all the values of the unknown (page 194). Instead, show the solution range on a number line:\n"
              "• Draw an ${isInclusive(currentSym) ? 'shaded (●)' : 'empty (○)'} circle at $bDisp.\n"
              "• Draw a heavy arrowed line pointing to the ${isGreater(currentSym) ? 'RIGHT (→)' : 'LEFT (←)'}.",
          mathLaTeX: "\\text{Solution: } \\boxed{$v \\; $symTex \\; $bTex}",
        ));

        return GraphInequalityResult(
          mode: 2,
          finalAnswers: {
            "Solution": "$v $symDisp $bDisp",
            "Circle at $bDisp":
            isInclusive(currentSym) ? "Shaded (●)" : "Empty (○)",
            "Arrow Direction":
            isGreater(currentSym) ? "Right (→)" : "Left (←)",
          },
          workingsLaTeX: workings,
          steps: steps,
          visualData: NumberLineVisualData(
            boundaryVal: bVal,
            boundaryDisplay: bDisp,
            varName: v,
            symbolDisplay: symDisp,
            isShaded: isInclusive(currentSym),
            pointsRight: isGreater(currentSym),
            graphStyle: graphStyle,
            headerBadge:
            "Solution of $rawInequality:   $v $symDisp $bDisp",
            subBadge:
            "${isInclusive(currentSym) ? 'Shaded Circle (●)' : 'Empty Circle (○)'} at $bDisp   |   Heavy Line Points ${isGreater(currentSym) ? 'Right (→)' : 'Left (←)'}",
          ),
        );
      }
    } catch (e) {
      return GraphInequalityResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter a valid linear inequality (e.g. x + 4 < 6 or 6 <= 2x - 1).",
      );
    }
  }

  // ===========================================================================
  // MODE 3: LINEAR INEQUALITY INSPECTOR (Page 193 — Index = 1 & Variable Count)
  // ===========================================================================
  static GraphInequalityResult solveLinearInspector({
    required String rawInequality,
  }) {
    try {
      final String s = rawInequality.trim();
      if (s.isEmpty) {
        throw const FormatException("Please enter an inequality to inspect.");
      }

      // Extract distinct variable letters
      final Set<String> vars = RegExp(r'[a-zA-Z]')
          .allMatches(s)
          .map((m) => m.group(0)!)
          .toSet();

      if (vars.isEmpty) {
        throw const FormatException(
            "No algebraic variable (letter) found in the statement.");
      }

      // Check highest power/index (e.g. x^2, x², x^3)
      int maxIndex = 1;
      if (s.contains('²') || s.contains('^2')) maxIndex = 2;
      if (s.contains('³') || s.contains('^3')) maxIndex = 3;
      final Iterable<Match> powMatches = RegExp(r'\^(\d+)').allMatches(s);
      for (final pm in powMatches) {
        final int p = int.tryParse(pm.group(1)!) ?? 1;
        if (p > maxIndex) maxIndex = p;
      }

      final bool isLinear = maxIndex == 1;
      final int varCount = vars.length;
      final String varListStr = vars.join(', ');

      final String classification = isLinear
          ? "Linear inequality in $varCount variable${varCount > 1 ? 's' : ''} ($varListStr)"
          : "Non-linear inequality (highest index = $maxIndex)";

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Identify Unknowns (Variables) in Statement}}",
        "\\text{Variables found: } $varListStr \\quad (\\text{Count} = $varCount)",
        "",
        "\\text{\\textbf{Step 2: Check the Index (Power) of Each Variable (Page 193)}}",
        isLinear
            ? "\\text{Each variable has an unwritten index of } 1 \\; (${vars.first} = ${vars.first}^1)."
            : "\\text{The highest power (index) of a variable is } $maxIndex \\neq 1.",
        "\\text{Classification: \\textbf{$classification}}",
      ];

      final List<GraphInequalityStep> steps = [
        GraphInequalityStep(
          title: "Step 1: Count the Unknown Variables ($varListStr)",
          description:
          "Count how many different letters (variables) appear in '$s':\n"
              "• Variable(s): $varListStr ($varCount variable${varCount > 1 ? 's' : ''}).",
          mathLaTeX: "\\text{Variables: } $varListStr \\; ($varCount)",
        ),
        GraphInequalityStep(
          title: "Step 2: Check the Index (Power) Rule (Page 193 Definition)",
          description:
          "Textbook Rule: 'Inequalities with variables of index 1 (that is, x = x¹ and y = y¹) are called linear inequalities.'\n"
              "• Highest index in '$s' = $maxIndex.\n"
              "• Verdict: $classification"
              "${isLinear && varCount == 1 ? ' — can be graphed directly on a 1D number line!' : ''}",
          mathLaTeX: "\\text{Result: \\textbf{$classification}}",
        ),
      ];

      return GraphInequalityResult(
        mode: 3,
        finalAnswers: {
          "Classification": isLinear ? "Linear Inequality" : "Non-Linear (Index $maxIndex)",
          "Variable Count": "$varCount ($varListStr)",
          "Highest Index": "$maxIndex (${vars.first} = ${vars.first}^$maxIndex)",
          "Number Line Graphable?":
          (isLinear && varCount == 1) ? "Yes (1 Variable)" : "No",
        },
        workingsLaTeX: workings,
        steps: steps,
        visualData: NumberLineVisualData(
          isInspectorMode: true,
          headerBadge: "Statement:  $s",
          subBadge: classification,
          inspectorDetails:
          "Variables: $varListStr ($varCount)   |   Highest Power (Index) = $maxIndex",
        ),
      );
    } catch (e) {
      return GraphInequalityResult.error(
        mode: 3,
        message: e is FormatException
            ? e.message
            : "Please enter an algebraic inequality (e.g. 3x > -12 or 2x - y <= 7).",
      );
    }
  }
}