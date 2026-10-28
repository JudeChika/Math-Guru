import 'flow_chart_models.dart';

class FlowChartLogic {
  // ===========================================================================
  // 10 TEXTBOOK PRESETS (Pages 15–17: Example 8 [Figs 1.1–1.2], Example 9 [Fig 1.3] & Ex 1.5 #1–5)
  // ===========================================================================
  static const List<FlowChartPreset> textbookPresets = [
    FlowChartPreset(
      chipLabel: "Ex 8 (Fig 1.2 Algebraic): Twice a number + 8 = 12",
      mode: 0,
      chartStyle: 0,
      input1: '2x + 8 = 12',
    ),
    FlowChartPreset(
      chipLabel: "Ex 8 (Fig 1.1 Verbal): Twice a number + 8 = 12",
      mode: 0,
      chartStyle: 1,
      input1: 'Twice a certain number plus 8 equals 12',
    ),
    FlowChartPreset(
      chipLabel: "Ex 1.5 #1: Thrice a certain number + 6 = 18",
      mode: 0,
      chartStyle: 0,
      input1: '3x + 6 = 18',
    ),
    FlowChartPreset(
      chipLabel: "Ex 1.5 #4: Subtract 3 from x, multiply by 7 = 35",
      mode: 0,
      chartStyle: 0,
      input1: '7(x - 3) = 35',
    ),
    FlowChartPreset(
      chipLabel: "Ex 9 (Fig 1.3): 2x + 6 = 3x - 1 (Boxes A–F)",
      mode: 1,
      input1: '2x + 6',
      input2: '3x - 1',
    ),
    FlowChartPreset(
      chipLabel: "Ex 1.5 #2: Twice a number minus 4 = 3 times the number",
      mode: 1,
      input1: '2x - 4',
      input2: '3x',
    ),
    FlowChartPreset(
      chipLabel: "Ex 1.5 #3: Half of a number + twice it = 25",
      mode: 2,
      input1: '1/2x',
      input2: '2x',
      input3: '25',
    ),
    FlowChartPreset(
      chipLabel: "Ex 1.5 #5 (a–h): Arrange Circle Compass Instructions",
      mode: 3,
      input1:
      'a) Put the point of the compasses on the paper.\n'
          'b) Pick up your compasses.\n'
          'c) Hold the compasses by the knob at the top.\n'
          'd) Find your mathematical set.\n'
          'e) Turn the compasses carefully, leaning them slightly in the direction you turn them.\n'
          'f) Check that your pencil is sharpened.\n'
          'g) Put your compasses back in the mathematical set.\n'
          'h) Put your pencil in your compasses.',
    ),
    FlowChartPreset(
      chipLabel: "Bonus Fraction: 1/3x + 2x = 14",
      mode: 2,
      input1: '1/3x',
      input2: '2x',
      input3: '14',
    ),
    FlowChartPreset(
      chipLabel: "Bonus Two-Sided: 4x - 3 = 2x + 9",
      mode: 1,
      input1: '4x - 3',
      input2: '2x + 9',
    ),
  ];

  // ===========================================================================
  // FORMATTING & ALGEBRAIC PARSING HELPERS
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

  static String cleanTex(String s) {
    return s
        .replaceAll('\\', '')
        .replaceAll('{', '(')
        .replaceAll('}', ')')
        .replaceAll('\$', '')
        .replaceAll('&', ' and ')
        .replaceAll('_', ' ')
        .trim();
  }

  /// Formats linear expression `a*x + b` cleanly (e.g. "2x + 6", "3x - 1", "3x")
  static String formatLinearExpr(double a, double b) {
    String xPart = '';
    if ((a - 1.0).abs() < 1e-9) {
      xPart = 'x';
    } else if ((a + 1.0).abs() < 1e-9) {
      xPart = '-x';
    } else if (a.abs() > 1e-9) {
      xPart = '${fmt(a)}x';
    }

    if (b.abs() < 1e-9) {
      return xPart.isEmpty ? '0' : xPart;
    }
    if (xPart.isEmpty) return fmt(b);
    return b > 0 ? '$xPart + ${fmt(b)}' : '$xPart - ${fmt(b.abs())}';
  }

  /// Parses a linear expression `ax + b` (like `2x + 6`, `3x - 1`, `3x`, `x - 4`) into `{'a': a, 'b': b}`
  static Map<String, double> parseLinearExpression(String raw) {
    String s = raw
        .trim()
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll('--', '+')
        .replaceAll('+-', '-')
        .replaceAll('-', '+-');

    if (s.isEmpty) {
      throw const FormatException(
          "Please enter a valid algebraic expression in x (e.g. 2x + 6 or 3x - 1).");
    }

    final List<String> chunks =
    s.split('+').where((c) => c.trim().isNotEmpty).toList();
    double a = 0.0;
    double b = 0.0;

    for (final String tok in chunks) {
      if (tok.contains('x')) {
        final String coeffStr = tok.replaceAll('x', '').trim();
        if (coeffStr.isEmpty || coeffStr == '+') {
          a += 1.0;
        } else if (coeffStr == '-') {
          a -= 1.0;
        } else if (coeffStr.contains('/')) {
          final List<String> fp = coeffStr.split('/');
          a += double.parse(fp[0]) / double.parse(fp[1]);
        } else {
          a += double.parse(coeffStr);
        }
      } else {
        if (tok.contains('/')) {
          final List<String> fp = tok.split('/');
          b += double.parse(fp[0]) / double.parse(fp[1]);
        } else {
          b += double.parse(tok);
        }
      }
    }

    return {'a': a, 'b': b};
  }

  /// Translates English word sentences from Examples 8 & 9 and Exercise 1.5 #1–4 into algebraic equations!
  static String translateWordProblemIfSentence(String raw) {
    final String lower = raw.trim().toLowerCase();
    if (lower.contains('=') && !lower.contains('equals')) {
      return raw.trim();
    }

    // Check specific textbook word-problem patterns first
    if (lower.contains('subtracted from') && lower.contains('multiplied by')) {
      // Ex 1.5 #4: "When 3 is subtracted from a certain number and the result is multiplied by 7, the result is 35"
      final List<double> nums = RegExp(r'-?\d+\.?\d*')
          .allMatches(lower)
          .map((m) => double.parse(m.group(0)!))
          .toList();
      if (nums.length >= 3) {
        return '${fmt(nums[1])}(x - ${fmt(nums[0])}) = ${fmt(nums[2])}';
      }
    }

    // Replace number words with digits
    String norm = lower
        .replaceAll('twenty-five', '25')
        .replaceAll('thirty-five', '35')
        .replaceAll('eighteen', '18')
        .replaceAll('twelve', '12')
        .replaceAll('seven', '7')
        .replaceAll('eight', '8')
        .replaceAll('six', '6')
        .replaceAll('four', '4')
        .replaceAll('three times the number', '3x')
        .replaceAll('three times a number', '3x')
        .replaceAll('thrice a certain number', '3x')
        .replaceAll('thrice a number', '3x')
        .replaceAll('twice a certain number', '2x')
        .replaceAll('twice a number', '2x')
        .replaceAll('twice it', '2x')
        .replaceAll('half of it', '1/2x')
        .replaceAll('a certain number', 'x')
        .replaceAll('the number', 'x')
        .replaceAll('plus', '+')
        .replaceAll('added to', '+')
        .replaceAll('minus', '-')
        .replaceAll('one', '1')
        .replaceAll('two', '2')
        .replaceAll('three', '3')
        .replaceAll('equals', '=')
        .replaceAll('is equal to', '=')
        .replaceAll('the result is', '=');

    // Strip trailing question sentences like "find the number" or "use a flow chart..."
    norm = norm.split('.').first.trim();
    if (norm.contains('=')) {
      return norm;
    }
    return raw.trim();
  }

  /// Generates 4 trial values of x leading up to the winning solution xSol for the Computer Execution Trace Table.
  static List<double> buildTrialSequence(double xSol) {
    final bool isIntSol = (xSol - xSol.roundToDouble()).abs() < 1e-9;
    if (!isIntSol) {
      final double base = xSol.floorToDouble();
      return [base - 1, base, xSol];
    }
    final int target = xSol.round();
    if (target >= 1 && target <= 5) {
      return [for (int k = 1; k <= target; k++) k.toDouble()];
    } else if (target > 5) {
      return [1.0, (target - 2).toDouble(), (target - 1).toDouble(), target.toDouble()];
    } else {
      // Negative or zero solution (like Ex 1.5 #2: 2x - 4 = 3x => x = -4)
      return [
        (target + 3).toDouble(),
        (target + 2).toDouble(),
        (target + 1).toDouble(),
        target.toDouble(),
      ];
    }
  }

  // ===========================================================================
  // MODE 0: ONE-SIDED & BRACKETED EQUATION FLOW CHART BUILDER
  // Covers Example 8 (Figures 1.1 & 1.2: 2x + 8 = 12), Ex 1.5 #1 (3x + 6 = 18) & Ex 1.5 #4 (7(x - 3) = 35)
  // ===========================================================================
  static FlowChartResult solveOneSidedOrBracketFlowChart({
    required String rawInput,
    required int chartStyle, // 0: Fig 1.2 Algebraic Style, 1: Fig 1.1 Verbal Style
  }) {
    try {
      final String translated = translateWordProblemIfSentence(rawInput);
      if (!translated.contains('=')) {
        throw const FormatException(
          "Please enter an equation with '=' or a word problem (e.g. 2x + 8 = 12, 3x + 6 = 18, or 7(x - 3) = 35).",
        );
      }

      final List<String> sides = translated.split('=');
      final String lhsRaw = sides[0].trim();
      final double? cVal = double.tryParse(
        sides[1].trim().replaceAll(RegExp(r'[^0-9.\-]'), ''),
      );
      if (cVal == null) {
        throw const FormatException(
          "The right-hand side of a Mode 0 equation should be a number (e.g. = 12, = 18, or = 35). For x on both sides, use Mode 1!",
        );
      }

      final bool isBracketForm = lhsRaw.contains('(') && lhsRaw.contains(')');

      if (isBracketForm) {
        // Bracketed Equation k(ax + b) = c  (Matches Exercise 1.5 #4: 7(x - 3) = 35)
        final RegExp brkReg =
        RegExp(r'([+-]?\d*\.?\d*)\s*\(\s*([^()]+)\s*\)');
        final Match? m = brkReg.firstMatch(lhsRaw);
        if (m == null) {
          throw const FormatException(
              "Invalid bracket format. Example: 7(x - 3) = 35.");
        }
        final String kStr = m.group(1)!.trim();
        final double k = (kStr.isEmpty || kStr == '+')
            ? 1.0
            : (kStr == '-' ? -1.0 : double.parse(kStr));
        final Map<String, double> inner = parseLinearExpression(m.group(2)!);
        final double a = inner['a']!;
        final double b = inner['b']!;
        if (a.abs() < 1e-9 || k.abs() < 1e-9) {
          throw const FormatException("Coefficient of x cannot be zero.");
        }

        final String innerExpr = formatLinearExpr(a, b);
        final String fullLhsExpr = '${fmt(k)}($innerExpr)';
        final double afterDivK = cVal / k;
        final double axVal = afterDivK - b;
        final double xSol = axVal / a;

        // Build Flow Chart Nodes (subtract/add inside bracket FIRST, then multiply by k!)
        final String bVerb = b < 0
            ? "Subtract ${fmt(b.abs())} from ${chartStyle == 1 ? 'the number' : 'x'}"
            : "Add ${fmt(b)} to ${chartStyle == 1 ? 'the number' : 'x'}";

        final List<FlowChartNode> nodes = [
          const FlowChartNode(text: 'Start', type: FlowNodeType.startStopPill),
          FlowChartNode(
            boxLetter: 'A',
            text: chartStyle == 1 ? 'Choose a number' : 'Choose x',
            subExprLaTeX: 'x',
          ),
          if ((a - 1.0).abs() > 1e-9)
            FlowChartNode(
              boxLetter: 'B',
              text: chartStyle == 1
                  ? 'Multiply by ${fmt(a)}'
                  : 'Find ${fmt(a)}x',
              subExprLaTeX: '${fmt(a)}x',
            ),
          FlowChartNode(
            boxLetter: (a - 1.0).abs() > 1e-9 ? 'C' : 'B',
            text: chartStyle == 1
                ? bVerb
                : '$bVerb (Find $innerExpr)',
            subExprLaTeX: innerExpr,
          ),
          FlowChartNode(
            boxLetter: (a - 1.0).abs() > 1e-9 ? 'D' : 'C',
            text: chartStyle == 1
                ? 'Multiply the result by ${fmt(k)}'
                : 'Multiply by ${fmt(k)} [Gives $fullLhsExpr]',
            subExprLaTeX: fullLhsExpr,
          ),
          FlowChartNode(
            boxLetter: (a - 1.0).abs() > 1e-9 ? 'E' : 'D',
            text: chartStyle == 1
                ? 'Is your result equal to ${fmt(cVal)}?'
                : 'Is $fullLhsExpr = ${fmt(cVal)}?',
            type: FlowNodeType.decisionHexagon,
          ),
          const FlowChartNode(text: 'Stop', type: FlowNodeType.startStopPill),
        ];

        // Build Computer Trial-and-Error Trace Table
        final List<double> trials = buildTrialSequence(xSol);
        final StringBuffer traceTable = StringBuffer();
        traceTable.write(
            "\\begin{array}{|c|c|c|c|c|} \\hline "
                "\\textbf{Trial } x & \\textbf{Step 1: } $innerExpr & \\textbf{Step 2: } $fullLhsExpr & \\textbf{Is } $fullLhsExpr = ${fmt(cVal)}\\textbf{?} & \\textbf{Computer Action} \\\\ \\hline ");
        for (final double tx in trials) {
          final double v1 = a * tx + b;
          final double v2 = k * v1;
          final bool isWin = (v2 - cVal).abs() < 1e-9;
          traceTable.write(
              "${fmt(tx)} & ${fmt(v1)} & ${fmt(v2)} & \\mathbf{\\text{${isWin ? 'Yes' : 'No'}}} & "
                  "\\text{${isWin ? 'Stop (x = ${fmt(tx)})' : 'Try again ↺'}} \\\\ \\hline ");
        }
        traceTable.write("\\end{array}");

        final List<String> workings = [
          "\\text{\\textbf{Stage 1: Translate Problem into Equation \\& Sequential Flow Chart Steps}}",
          "\\text{Let the unknown number be } x. \\quad \\text{Equation: } \\mathbf{$fullLhsExpr = ${fmt(cVal)}}",
          "\\bullet \\text{ Box 1 (Start): } \\text{Begin the computer program.}",
          "\\bullet \\text{ Box 2 (Input): } \\text{${nodes[1].text}.}",
          "\\bullet \\text{ Box 3 (First Operation inside Brackets): } \\text{$bVerb} \\longrightarrow $innerExpr",
          "\\bullet \\text{ Box 4 (Second Operation): } \\text{Multiply the result by ${fmt(k)}} \\longrightarrow $fullLhsExpr",
          "\\bullet \\text{ Box 5 (Decision Hexagon): } \\text{Is } $fullLhsExpr = ${fmt(cVal)}\\text{? If \\textbf{No} } \\rightarrow \\text{Try again; if \\textbf{Yes} } \\rightarrow \\text{Stop!}",
          "",
          "\\text{\\textbf{Stage 2: Computer Trial-and-Error Loop Trace Table}}",
          traceTable.toString(),
          "",
          "\\text{\\textbf{Stage 3: Unabridged Algebraic Solution of }} $fullLhsExpr = ${fmt(cVal)}",
          "$fullLhsExpr = ${fmt(cVal)}",
          "\\text{Divide both sides by } ${fmt(k)}: \\quad \\frac{$fullLhsExpr}{${fmt(k)}} = \\frac{${fmt(cVal)}}{${fmt(k)}} \\implies $innerExpr = ${fmt(afterDivK)}",
          "\\text{${b < 0 ? 'Add ${fmt(b.abs())} to' : 'Subtract ${fmt(b)} from'} both sides: } \\quad ${a == 1 ? 'x' : '${fmt(a)}x'} = ${fmt(afterDivK)} ${b < 0 ? '+ ${fmt(b.abs())}' : '- ${fmt(b)}'} = ${fmt(axVal)}",
          if ((a - 1.0).abs() > 1e-9)
            "\\text{Divide both sides by } ${fmt(a)}: \\quad x = \\frac{${fmt(axVal)}}{${fmt(a)}} = \\mathbf{${fmt(xSol)}}",
          "\\therefore \\; \\text{The required number is } \\mathbf{x = ${fmt(xSol)}}.",
          "",
          "\\text{\\textbf{Stage 4: Verification Check in the Decision Hexagon}}",
          "\\text{Substitute } x = ${fmt(xSol)}: \\quad \\text{LHS} = ${fmt(k)}(${fmt(a * xSol)} ${fmtSigned(b)}) = ${fmt(k)}(${fmt(a * xSol + b)}) = \\mathbf{${fmt(cVal)}} = \\text{RHS (Yes } \\rightarrow \\text{ Stop!)}",
        ];

        final List<FlowChartStep> steps = [
          FlowChartStep(
            title:
            "Step 1: Break '$fullLhsExpr = ${fmt(cVal)}' into Sequential Flow Chart Instructions",
            description:
            "• A flow chart is a diagram used to organize instructions meant for a computer in sequential order (one operation per box).\n"
                "• Because $innerExpr is inside brackets in $fullLhsExpr = ${fmt(cVal)}, the computer must perform '$bVerb' FIRST, and then multiply that result by ${fmt(k)}!\n"
                "• Sequence: Start → ${nodes[1].text} → $bVerb → Multiply the result by ${fmt(k)} → Decision: Is $fullLhsExpr = ${fmt(cVal)}? (Yes → Stop / No → Try again).",
            mathLaTeX:
            "x \\xrightarrow{\\text{$bVerb}} $innerExpr \\xrightarrow{\\times ${fmt(k)}} $fullLhsExpr \\xrightarrow{= ${fmt(cVal)}\\text{?}} \\text{Stop}",
          ),
          FlowChartStep(
            title:
            "Step 2: Trace the Computer's 'No → Try again' Loop Until 'Yes → Stop'",
            description:
            "When the computer runs this flow chart, if a chosen value of x does not give ${fmt(cVal)}, the 'No' arrow sends it through 'Try again' back to 'Choose x'. When x = ${fmt(xSol)}, the Decision Box outputs 'Yes' and proceeds to 'Stop':",
            mathLaTeX: traceTable.toString(),
          ),
          FlowChartStep(
            title:
            "Step 3: Solve '$fullLhsExpr = ${fmt(cVal)}' Algebraically Step-by-Step",
            description:
            "1. Divide both sides by ${fmt(k)}: $innerExpr = ${fmt(cVal)} ÷ ${fmt(k)} = ${fmt(afterDivK)}.\n"
                "2. ${b < 0 ? 'Add ${fmt(b.abs())} to' : 'Subtract ${fmt(b)} from'} both sides: x = ${fmt(afterDivK)} ${b < 0 ? '+ ${fmt(b.abs())}' : '− ${fmt(b)}'} = ${fmt(xSol)}.\n"
                "3. Check: ${fmt(k)}(${fmt(xSol)} ${fmtSigned(b)}) = ${fmt(k)} × ${fmt(xSol + b)} = ${fmt(cVal)} (Verified!).",
            mathLaTeX:
            "$fullLhsExpr = ${fmt(cVal)} \\implies $innerExpr = ${fmt(afterDivK)} \\implies \\boxed{x = ${fmt(xSol)}}",
          ),
        ];

        return FlowChartResult(
          mode: 0,
          finalAnswers: {
            "Equation": "$fullLhsExpr = ${fmt(cVal)}",
            "Unknown Number (x)": "x = ${fmt(xSol)}",
            "Check at x = ${fmt(xSol)}":
            "${fmt(k)}(${fmt(xSol + b)}) = ${fmt(cVal)} (Yes → Stop)",
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: FlowChartCanvasData(
            mode: 0,
            mainNodes: nodes,
            hasTryAgainLoop: true,
            loopReturnIndex: 1,
            headerBadge:
            "Flow Chart for '$fullLhsExpr = ${fmt(cVal)}'   ➔   Solution: x = ${fmt(xSol)}",
            subBadge:
            "Yes (↓) leads to Stop when x = ${fmt(xSol)}   |   No (→ ↑) loops through 'Try again' back to 'Choose x'",
            bottomSummaryBanner:
            "Winning Value: x = ${fmt(xSol)}   |   Check: $fullLhsExpr = ${fmt(cVal)} (Yes → Stop!)",
          ),
        );
      }

      // Standard Two-Step Linear Equation ax + b = c (Matches Example 8: 2x + 8 = 12 & Ex 1.5 #1: 3x + 6 = 18)
      final Map<String, double> parsedLhs = parseLinearExpression(lhsRaw);
      final double a = parsedLhs['a']!;
      final double b = parsedLhs['b']!;
      if (a.abs() < 1e-9) {
        throw const FormatException(
            "The equation must contain an unknown variable x (e.g. 2x + 8 = 12).");
      }

      final String lhsClean = formatLinearExpr(a, b);
      final double axVal = cVal - b;
      final double xSol = axVal / a;

      final String step2Text = chartStyle == 1
          ? 'Multiply by ${fmt(a)}'
          : 'Find ${fmt(a)}x';
      final String step3Text = b >= 0
          ? 'Add ${fmt(b)}'
          : 'Subtract ${fmt(b.abs())}';
      final String decisionText = chartStyle == 1
          ? 'Is your result equal to ${fmt(cVal)}?'
          : 'Is $lhsClean = ${fmt(cVal)}?';

      final List<FlowChartNode> nodes = [
        const FlowChartNode(text: 'Start', type: FlowNodeType.startStopPill),
        FlowChartNode(
          text: chartStyle == 1 ? 'Choose a number' : 'Choose x',
          subExprLaTeX: 'x',
        ),
        if ((a - 1.0).abs() > 1e-9)
          FlowChartNode(
            text: step2Text,
            subExprLaTeX: '${fmt(a)}x',
          ),
        if (b.abs() > 1e-9)
          FlowChartNode(
            text: step3Text,
            subExprLaTeX: lhsClean,
          ),
        FlowChartNode(
          text: decisionText,
          type: FlowNodeType.decisionHexagon,
        ),
        const FlowChartNode(text: 'Stop', type: FlowNodeType.startStopPill),
      ];

      // Build Computer Trial-and-Error Loop Trace Table
      final List<double> trials = buildTrialSequence(xSol);
      final StringBuffer traceTable = StringBuffer();
      traceTable.write(
          "\\begin{array}{|c|c|c|c|c|} \\hline "
              "\\textbf{Choose } x & \\textbf{Find } ${fmt(a)}x & \\textbf{${b >= 0 ? 'Add ${fmt(b)}' : 'Subtract ${fmt(b.abs())}'}} \\; ($lhsClean) & \\textbf{Is } $lhsClean = ${fmt(cVal)}\\textbf{?} & \\textbf{Branch Taken} \\\\ \\hline ");
      for (final double tx in trials) {
        final double multVal = a * tx;
        final double resVal = multVal + b;
        final bool isWin = (resVal - cVal).abs() < 1e-9;
        traceTable.write(
            "${fmt(tx)} & ${fmt(multVal)} & ${fmt(resVal)} & \\mathbf{\\text{${isWin ? 'Yes' : 'No'}}} & "
                "\\text{${isWin ? 'Yes ↓ Stop (x = ${fmt(tx)})' : 'No → Try again ↺'}} \\\\ \\hline ");
      }
      traceTable.write("\\end{array}");

      final List<String> workings = [
        "\\text{\\textbf{Stage 1: Set Up the Flow Chart Instructions (Figures 1.1 \\& 1.2 Method)}}",
        "\\text{Let the unknown number be } x. \\quad \\text{Algebraic Equation: } \\mathbf{$lhsClean = ${fmt(cVal)}}",
        "\\bullet \\text{ Figure 1.1 Verbal Flow Chart: } \\text{Start} \\rightarrow \\text{Choose a number} \\rightarrow \\text{$step2Text} \\rightarrow \\text{$step3Text} \\rightarrow \\text{Is result} = ${fmt(cVal)}\\text{?}",
        "\\bullet \\text{ Figure 1.2 Algebraic Flow Chart: } \\text{Start} \\rightarrow \\text{Choose } x \\rightarrow \\text{Find } ${fmt(a)}x \\rightarrow \\text{$step3Text} \\rightarrow \\text{Is } $lhsClean = ${fmt(cVal)}\\text{?}",
        "",
        "\\text{\\textbf{Stage 2: Computer Trial-and-Error Loop Simulation ('Try again' vs. 'Stop')}}",
        traceTable.toString(),
        "",
        "\\text{\\textbf{Stage 3: Unabridged Algebraic Solution of }} $lhsClean = ${fmt(cVal)}",
        "$lhsClean = ${fmt(cVal)}",
        if (b.abs() > 1e-9)
          "\\text{${b > 0 ? 'Subtract ${fmt(b)} from' : 'Add ${fmt(b.abs())} to'} both sides: } \\quad ${fmt(a)}x = ${fmt(cVal)} ${b > 0 ? '- ${fmt(b)}' : '+ ${fmt(b.abs())}'} = ${fmt(axVal)}",
        if ((a - 1.0).abs() > 1e-9)
          "\\text{Divide both sides by } ${fmt(a)}: \\quad x = \\frac{${fmt(axVal)}}{${fmt(a)}} = \\mathbf{${fmt(xSol)}}",
        "\\therefore \\; \\text{The certain number is } \\mathbf{x = ${fmt(xSol)}}.",
        "",
        "\\text{\\textbf{Stage 4: Verification Check in the Decision Box}}",
        "\\text{When } x = ${fmt(xSol)}: \\quad ${fmt(a)}(${fmt(xSol)}) ${fmtSigned(b)} = ${fmt(a * xSol)} ${fmtSigned(b)} = \\mathbf{${fmt(cVal)}} \\quad (\\text{Matches } ${fmt(cVal)} \\implies \\text{Yes } \\rightarrow \\text{ Stop!})",
      ];

      final List<FlowChartStep> steps = [
        FlowChartStep(
          title:
          "Step 1: Translate into an Algebraic Equation & Flow Chart Boxes (Example 8)",
          description:
          "• Note from Page 16: 'The number chosen in the flow chart is a variable. We may call it x. Then we can work out the numbers in the other boxes from x.'\n"
              "• Equation: $lhsClean = ${fmt(cVal)}.\n"
              "• Box-by-Box Computer Instructions:\n"
              "  1. Start (Rounded pill box)\n"
              "  2. ${nodes[1].text} (Variable x)\n"
              "  3. $step2Text (Gives ${fmt(a)}x)\n"
              "  4. $step3Text (Gives $lhsClean)\n"
              "  5. Decision Box: $decisionText\n"
              "     – If No: Follow the right loop through 'Try again' back to 'Choose x'.\n"
              "     – If Yes: Follow the downward arrow to 'Stop'!",
          mathLaTeX:
          "\\text{Start} \\rightarrow \\text{Choose } x \\rightarrow \\text{Find } ${fmt(a)}x \\rightarrow \\text{$step3Text} \\rightarrow \\text{Is } $lhsClean = ${fmt(cVal)}\\text{?}",
        ),
        FlowChartStep(
          title:
          "Step 2: Computer Trial-and-Error Execution Trace Table",
          description:
          "Here is how the computer tests values of x around the 'Try again' loop until the decision box condition ($lhsClean = ${fmt(cVal)}) is satisfied at x = ${fmt(xSol)}:",
          mathLaTeX: traceTable.toString(),
        ),
        FlowChartStep(
          title:
          "Step 3: Solve '$lhsClean = ${fmt(cVal)}' Algebraically Step-by-Step",
          description:
          "1. Start with the equation: $lhsClean = ${fmt(cVal)}.\n"
              "2. ${b >= 0 ? 'Subtract ${fmt(b)} from' : 'Add ${fmt(b.abs())} to'} both sides: ${fmt(a)}x = ${fmt(cVal)} ${b >= 0 ? '− ${fmt(b)}' : '+ ${fmt(b.abs())}'} = ${fmt(axVal)}.\n"
              "3. Divide both sides by ${fmt(a)}: x = ${fmt(axVal)} ÷ ${fmt(a)} = ${fmt(xSol)}.\n"
              "4. Verification: ${fmt(a)}(${fmt(xSol)}) ${fmtSigned(b)} = ${fmt(a * xSol)} ${fmtSigned(b)} = ${fmt(cVal)} (Yes → Stop!).",
          mathLaTeX:
          "$lhsClean = ${fmt(cVal)} \\implies ${fmt(a)}x = ${fmt(axVal)} \\implies \\boxed{x = ${fmt(xSol)}}",
        ),
      ];

      return FlowChartResult(
        mode: 0,
        finalAnswers: {
          "Algebraic Equation": "$lhsClean = ${fmt(cVal)}",
          "Certain Number (x)": "x = ${fmt(xSol)}",
          "Flow Chart Style":
          chartStyle == 1 ? "Fig 1.1 (Verbal)" : "Fig 1.2 (Algebraic x)",
          "Check at x = ${fmt(xSol)}":
          "${fmt(a * xSol)} ${fmtSigned(b)} = ${fmt(cVal)} (Yes → Stop)",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: FlowChartCanvasData(
          mode: 0,
          mainNodes: nodes,
          hasTryAgainLoop: true,
          loopReturnIndex: 1,
          headerBadge:
          "Example 8 / Ex 1.5 Flow Chart:  $lhsClean = ${fmt(cVal)}   (Solution: x = ${fmt(xSol)})",
          subBadge:
          "Style: ${chartStyle == 1 ? 'Figure 1.1 Verbal Instructions' : 'Figure 1.2 Algebraic Variable (x)'}   |   'No' loops via 'Try again'",
          bottomSummaryBanner:
          "Winning Number: x = ${fmt(xSol)}   |   Decision Box: ${fmt(cVal)} = ${fmt(cVal)} (Yes → Stop!)",
        ),
      );
    } catch (e) {
      return FlowChartResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter a valid equation or word problem (e.g. 2x + 8 = 12 or 3x + 6 = 18).",
      );
    }
  }

  // ===========================================================================
  // MODE 1: TWO-SIDED COMPARISON FLOW CHART (A–F LABELED BOXES — FIGURE 1.3)
  // Covers Example 9 (Figure 1.3: 2x + 6 = 3x - 1) & Exercise 1.5 #2 (2x - 4 = 3x)
  // ===========================================================================
  static FlowChartResult solveTwoSidedComparisonFlowChart({
    required String lhsExprStr,
    required String rhsExprStr,
  }) {
    try {
      final Map<String, double> lhs = parseLinearExpression(lhsExprStr);
      final Map<String, double> rhs = parseLinearExpression(rhsExprStr);

      final double a = lhs['a']!;
      final double b = lhs['b']!;
      final double c = rhs['a']!;
      final double d = rhs['b']!;

      if ((a - c).abs() < 1e-9) {
        throw const FormatException(
          "The coefficients of x on both sides are equal, so there is no unique solution for x. Try expressions like '2x + 6' and '3x - 1'.",
        );
      }

      final String lhsClean = formatLinearExpr(a, b);
      final String rhsClean = formatLinearExpr(c, d);
      final double xSol = (d - b) / (a - c);

      // Construct Labeled Boxes A, B, C, D, E, F matching Figure 1.3 on Page 17!
      final List<FlowChartNode> nodes = [
        const FlowChartNode(text: 'Start', type: FlowNodeType.startStopPill),
        const FlowChartNode(
          boxLetter: 'A',
          text: 'Choose x',
          subExprLaTeX: 'x',
        ),
      ];

      // LHS Boxes (B and optionally C)
      int letterCode = 66; // 'B'
      nodes.add(FlowChartNode(
        boxLetter: String.fromCharCode(letterCode),
        text: 'Find ${fmt(a)}x',
        subExprLaTeX: '${fmt(a)}x',
      ));
      String lhsFinalBoxLetter = String.fromCharCode(letterCode);
      letterCode++;

      if (b.abs() > 1e-9) {
        final String prevLetter = lhsFinalBoxLetter;
        lhsFinalBoxLetter = String.fromCharCode(letterCode);
        nodes.add(FlowChartNode(
          boxLetter: lhsFinalBoxLetter,
          text: b > 0
              ? 'Add ${fmt(b)} to $prevLetter'
              : 'Subtract ${fmt(b.abs())} from $prevLetter',
          subExprLaTeX: lhsClean,
        ));
        letterCode++;
      }

      // RHS Boxes (D and optionally E)
      final String rhsMultBoxLetter = String.fromCharCode(letterCode);
      nodes.add(FlowChartNode(
        boxLetter: rhsMultBoxLetter,
        text: 'Find ${fmt(c)}x',
        subExprLaTeX: '${fmt(c)}x',
      ));
      String rhsFinalBoxLetter = rhsMultBoxLetter;
      letterCode++;

      if (d.abs() > 1e-9) {
        final String prevLetter = rhsFinalBoxLetter;
        rhsFinalBoxLetter = String.fromCharCode(letterCode);
        nodes.add(FlowChartNode(
          boxLetter: rhsFinalBoxLetter,
          text: d > 0
              ? 'Add ${fmt(d)} to $prevLetter'
              : 'Subtract ${fmt(d.abs())} from $prevLetter',
          subExprLaTeX: rhsClean,
        ));
        letterCode++;
      }

      // Decision Box (F in Figure 1.3, or E in Ex 1.5 #2)
      final String decisionLetter = String.fromCharCode(letterCode);
      nodes.add(FlowChartNode(
        boxLetter: decisionLetter,
        text:
        'Are the results in $lhsFinalBoxLetter and $rhsFinalBoxLetter equal?',
        type: FlowNodeType.decisionHexagon,
      ));
      nodes.add(
          const FlowChartNode(text: 'Stop', type: FlowNodeType.startStopPill));

      // Build Computer Execution Trace Table across Boxes A..F
      final List<double> trials = buildTrialSequence(xSol);
      final StringBuffer traceBuf = StringBuffer();
      traceBuf.write(
          "\\begin{array}{|c|c|c|c|c|c|} \\hline "
              "\\textbf{A: } x & \\textbf{B: } ${fmt(a)}x & \\textbf{$lhsFinalBoxLetter: } $lhsClean & \\textbf{$rhsMultBoxLetter: } ${fmt(c)}x & "
              "\\textbf{$rhsFinalBoxLetter: } $rhsClean & \\textbf{$decisionLetter: $lhsFinalBoxLetter = $rhsFinalBoxLetter?} \\\\ \\hline ");

      for (final double tx in trials) {
        final double valB = a * tx;
        final double valLhs = valB + b;
        final double valD = c * tx;
        final double valRhs = valD + d;
        final bool isEq = (valLhs - valRhs).abs() < 1e-9;
        traceBuf.write(
            "${fmt(tx)} & ${fmt(valB)} & \\mathbf{${fmt(valLhs)}} & ${fmt(valD)} & \\mathbf{${fmt(valRhs)}} & "
                "\\mathbf{\\text{${isEq ? 'Yes → Stop!' : 'No → Try again'}}} \\\\ \\hline ");
      }
      traceBuf.write("\\end{array}");

      // Algebraic Steps for ax + b = cx + d
      final double netXCoeff = a - c;
      final double netConst = d - b;
      final double winLhsVal = a * xSol + b;

      final List<String> workings = [
        "\\text{\\textbf{Stage 1: Labeled Flow Chart Boxes (A to $decisionLetter — Figure 1.3 Method)}}",
        "\\text{Equation to solve: } \\mathbf{$lhsClean = $rhsClean}",
        for (int i = 1; i < nodes.length - 1; i++)
          "\\bullet \\text{ Box ${nodes[i].boxLetter}: ${nodes[i].text}}"
              "${nodes[i].subExprLaTeX.isNotEmpty ? ' \\quad \\longrightarrow \\quad ${nodes[i].subExprLaTeX}' : ''}",
        "",
        "\\text{\\textbf{Stage 2: Computer Execution Trace Table for Boxes A to $decisionLetter}}",
        traceBuf.toString(),
        "",
        "\\text{\\textbf{Stage 3: Unabridged Algebraic Solution of }} $lhsClean = $rhsClean",
        "$lhsClean = $rhsClean",
        "\\text{Collect like terms (${c >= 0 ? 'subtract ${fmt(c)}x from' : 'add ${fmt(c.abs())}x to'} both sides):}",
        "${fmt(a)}x ${c >= 0 ? '- ${fmt(c)}x' : '+ ${fmt(c.abs())}x'} ${b.abs() < 1e-9 ? '' : fmtSigned(b)} = ${fmt(d)}",
        if (b.abs() > 1e-9)
          "\\text{${b > 0 ? 'Subtract ${fmt(b)} from' : 'Add ${fmt(b.abs())} to'} both sides: } \\quad ${fmt(netXCoeff)}x = ${fmt(d)} ${b > 0 ? '- ${fmt(b)}' : '+ ${fmt(b.abs())}'} = ${fmt(netConst)}"
        else
          "${fmt(netXCoeff)}x = ${fmt(netConst)}",
        "\\text{Divide both sides by } ${fmt(netXCoeff)}: \\quad x = \\frac{${fmt(netConst)}}{${fmt(netXCoeff)}} = \\mathbf{${fmt(xSol)}}",
        "",
        "\\text{\\textbf{Stage 4: Check in Decision Box $decisionLetter (Are $lhsFinalBoxLetter and $rhsFinalBoxLetter Equal?)}}",
        "\\bullet \\text{ Box $lhsFinalBoxLetter ($lhsClean): } ${fmt(a)}(${fmt(xSol)}) ${b.abs() < 1e-9 ? '' : fmtSigned(b)} = \\mathbf{${fmt(winLhsVal)}}",
        "\\bullet \\text{ Box $rhsFinalBoxLetter ($rhsClean): } ${fmt(c)}(${fmt(xSol)}) ${d.abs() < 1e-9 ? '' : fmtSigned(d)} = \\mathbf{${fmt(winLhsVal)}} \\quad (\\text{Equal! Yes } \\rightarrow \\text{ Stop})",
      ];

      final List<FlowChartStep> steps = [
        FlowChartStep(
          title:
          "Step 1: Set Up Labeled Flow Chart Boxes A to $decisionLetter (Figure 1.3)",
          description:
          "• As shown in Example 9 (Figure 1.3 on Page 17), when the unknown number x appears on BOTH sides of the equation ($lhsClean = $rhsClean), we label each instruction box with a capital letter (A, B, C, ...) so the computer can refer back to earlier results:\n"
              "${nodes.sublist(1, nodes.length - 1).map((n) => '  – Box ${n.boxLetter}: ${n.text}').join('\n')}\n"
              "• Decision Box $decisionLetter compares Box $lhsFinalBoxLetter and Box $rhsFinalBoxLetter: if they are equal ('Yes'), the program stops; if not ('No'), it loops through 'Try again' back above Box A!",
          mathLaTeX:
          "\\text{Box $lhsFinalBoxLetter} = $lhsClean, \\quad \\text{Box $rhsFinalBoxLetter} = $rhsClean \\implies \\text{Box $decisionLetter: Is } \\text{$lhsFinalBoxLetter} = \\text{$rhsFinalBoxLetter?}",
        ),
        FlowChartStep(
          title:
          "Step 2: Computer Trial-and-Error Trace Across Boxes A to $decisionLetter",
          description:
          "Evaluating each box A through $decisionLetter for trial values of x shows that Box $lhsFinalBoxLetter and Box $rhsFinalBoxLetter become equal (= ${fmt(winLhsVal)}) when x = ${fmt(xSol)}:",
          mathLaTeX: traceBuf.toString(),
        ),
        FlowChartStep(
          title:
          "Step 3: Solve '$lhsClean = $rhsClean' Algebraically",
          description:
          "1. Collect x-terms on the left-hand side and constants on the right-hand side:\n"
              "   ${fmt(a)}x − ${fmt(c)}x = ${fmt(d)} ${b >= 0 ? '− ${fmt(b)}' : '+ ${fmt(b.abs())}'}\n"
              "   ${fmt(netXCoeff)}x = ${fmt(netConst)}.\n"
              "2. Divide both sides by ${fmt(netXCoeff)}:\n"
              "   x = ${fmt(netConst)} ÷ ${fmt(netXCoeff)} = ${fmt(xSol)}.\n"
              "3. Check: When x = ${fmt(xSol)}, Box $lhsFinalBoxLetter = ${fmt(winLhsVal)} and Box $rhsFinalBoxLetter = ${fmt(winLhsVal)} (Yes → Stop!).",
          mathLaTeX:
          "$lhsClean = $rhsClean \\implies ${fmt(netXCoeff)}x = ${fmt(netConst)} \\implies \\boxed{x = ${fmt(xSol)}}",
        ),
      ];

      return FlowChartResult(
        mode: 1,
        finalAnswers: {
          "Equation": "$lhsClean = $rhsClean",
          "Unknown Number (x)": "x = ${fmt(xSol)}",
          "Box $lhsFinalBoxLetter Value": fmt(winLhsVal),
          "Box $rhsFinalBoxLetter Value": fmt(winLhsVal),
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: FlowChartCanvasData(
          mode: 1,
          mainNodes: nodes,
          hasTryAgainLoop: true,
          loopReturnIndex: 1,
          headerBadge:
          "Figure 1.3 Labeled Flow Chart (Boxes A–$decisionLetter):  $lhsClean = $rhsClean",
          subBadge:
          "Box $lhsFinalBoxLetter computes $lhsClean   |   Box $rhsFinalBoxLetter computes $rhsClean   |   Box $decisionLetter checks if $lhsFinalBoxLetter = $rhsFinalBoxLetter",
          bottomSummaryBanner:
          "Solution: x = ${fmt(xSol)}   (Both Box $lhsFinalBoxLetter and Box $rhsFinalBoxLetter equal ${fmt(winLhsVal)} → Yes → Stop!)",
        ),
      );
    } catch (e) {
      return FlowChartResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid expressions in x for both sides (e.g. '2x + 6' and '3x - 1').",
      );
    }
  }

  // ===========================================================================
  // MODE 2: COMBINED FRACTIONS & MULTI-TERM FLOW CHART (Exercise 1.5 #3)
  // Specifically covers Ex 1.5 #3: "Find the whole number, such that half of it plus twice it equals 25"
  // ===========================================================================
  static Map<String, int> _parseFractionCoefficient(String raw) {
    final String s = raw
        .trim()
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('x', '')
        .replaceAll('½', '1/2')
        .replaceAll('⅓', '1/3')
        .replaceAll('¼', '1/4')
        .replaceAll('¾', '3/4');

    if (s.isEmpty || s == '+') return {'num': 1, 'den': 1};
    if (s == '-') return {'num': -1, 'den': 1};
    if (s.contains('/')) {
      final List<String> p = s.split('/');
      final int n = p[0].isEmpty ? 1 : int.parse(p[0]);
      final int d = int.parse(p[1]);
      if (d == 0) throw const FormatException("Denominator cannot be zero.");
      return {'num': n, 'den': d};
    }
    final int n = int.parse(s);
    return {'num': n, 'den': 1};
  }

  static FlowChartResult solveFractionalMultiPartFlowChart({
    required String part1Str, // e.g., "1/2x"
    required String part2Str, // e.g., "2x"
    required String totalStr, // e.g., "25"
  }) {
    try {
      final Map<String, int> f1 = _parseFractionCoefficient(part1Str);
      final Map<String, int> f2 = _parseFractionCoefficient(part2Str);
      final double? targetTotal = double.tryParse(totalStr.trim());
      if (targetTotal == null) {
        throw const FormatException(
            "Please enter a valid number for the required total (e.g. 25).");
      }

      final int n1 = f1['num']!, d1 = f1['den']!;
      final int n2 = f2['num']!, d2 = f2['den']!;

      // Common denominator (LCM of d1 and d2)
      final int lcmDen = (d1 * d2) ~/ gcd(d1, d2);
      final int scaledN1 = n1 * (lcmDen ~/ d1);
      final int scaledN2 = n2 * (lcmDen ~/ d2);
      final int sumNum = scaledN1 + scaledN2;
      if (sumNum == 0) {
        throw const FormatException("The two parts cancel out to 0.");
      }

      final double xSol = (targetTotal * lcmDen) / sumNum;

      final String p1Plain = d1 == 1 ? '${n1}x' : '$n1/${d1}x';
      final String p1LaTeX = d1 == 1 ? '${n1}x' : '\\frac{$n1}{$d1}x';
      final String p2Plain = d2 == 1 ? '${n2}x' : '$n2/${d2}x';
      final String p2LaTeX = d2 == 1 ? '${n2}x' : '\\frac{$n2}{$d2}x';

      final String boxBText = d1 > 1 && n1 == 1
          ? 'Find 1/${d1}x (Divide x by $d1)'
          : 'Find $p1Plain';
      final String boxCText = d2 == 1
          ? 'Find ${n2}x (Multiply x by $n2)'
          : 'Find $p2Plain';

      final List<FlowChartNode> nodes = [
        const FlowChartNode(text: 'Start', type: FlowNodeType.startStopPill),
        const FlowChartNode(
          boxLetter: 'A',
          text: 'Choose x',
          subExprLaTeX: 'x',
        ),
        FlowChartNode(
          boxLetter: 'B',
          text: boxBText,
          subExprLaTeX: p1LaTeX,
        ),
        FlowChartNode(
          boxLetter: 'C',
          text: boxCText,
          subExprLaTeX: p2LaTeX,
        ),
        FlowChartNode(
          boxLetter: 'D',
          text: 'Add B and C ($p1Plain + $p2Plain)',
          subExprLaTeX: '$p1LaTeX + $p2LaTeX',
        ),
        FlowChartNode(
          boxLetter: 'E',
          text: 'Is the result in D equal to ${fmt(targetTotal)}?',
          type: FlowNodeType.decisionHexagon,
        ),
        const FlowChartNode(text: 'Stop', type: FlowNodeType.startStopPill),
      ];

      // Build Computer Trial-and-Error Trace Table (choosing multiples of lcmDen leading to xSol)
      final List<double> trials = [
        (xSol - 2 * lcmDen) > 0 ? (xSol - 2 * lcmDen) : lcmDen.toDouble(),
        if ((xSol - lcmDen) > 0) xSol - lcmDen,
        xSol,
      ];

      final StringBuffer traceBuf = StringBuffer();
      traceBuf.write(
          "\\begin{array}{|c|c|c|c|c|} \\hline "
              "\\textbf{A: Choose } x & \\textbf{B: } $p1LaTeX & \\textbf{C: } $p2LaTeX & \\textbf{D: B + C} & \\textbf{E: Is D = ${fmt(targetTotal)}?} \\\\ \\hline ");
      for (final double tx in trials) {
        final double vB = (n1 / d1) * tx;
        final double vC = (n2 / d2) * tx;
        final double vD = vB + vC;
        final bool isWin = (vD - targetTotal).abs() < 1e-9;
        traceBuf.write(
            "${fmt(tx)} & ${fmt(vB)} & ${fmt(vC)} & \\mathbf{${fmt(vD)}} & "
                "\\mathbf{\\text{${isWin ? 'Yes → Stop!' : 'No → Try again'}}} \\\\ \\hline ");
      }
      traceBuf.write("\\end{array}");

      final double winB = (n1 / d1) * xSol;
      final double winC = (n2 / d2) * xSol;

      final List<String> workings = [
        "\\text{\\textbf{Stage 1: Translate Word Problem into Labeled Flow Chart Boxes (Exercise 1.5 \\#3)}}",
        "\\text{Let the whole number be } x. \\quad \\text{Equation: } \\mathbf{$p1LaTeX + $p2LaTeX = ${fmt(targetTotal)}}",
        "\\bullet \\text{ Box A: Choose } x",
        "\\bullet \\text{ Box B: $boxBText} \\quad \\longrightarrow \\quad $p1LaTeX",
        "\\bullet \\text{ Box C: $boxCText} \\quad \\longrightarrow \\quad $p2LaTeX",
        "\\bullet \\text{ Box D: Add B and C} \\quad \\longrightarrow \\quad $p1LaTeX + $p2LaTeX",
        "\\bullet \\text{ Box E (Decision): Is the result in D equal to ${fmt(targetTotal)}?}",
        "",
        "\\text{\\textbf{Stage 2: Computer Trial-and-Error Execution Trace Table}}",
        traceBuf.toString(),
        "",
        "\\text{\\textbf{Stage 3: Unabridged Algebraic Solution of }} $p1LaTeX + $p2LaTeX = ${fmt(targetTotal)}",
        "$p1LaTeX + $p2LaTeX = ${fmt(targetTotal)}",
        "\\text{Multiply every term by the LCM of the denominators } ($lcmDen) \\text{ to clear fractions:}",
        "$lcmDen \\times $p1LaTeX + $lcmDen \\times $p2LaTeX = $lcmDen \\times ${fmt(targetTotal)}",
        "${scaledN1}x + ${scaledN2}x = ${fmt(lcmDen * targetTotal)}",
        "${sumNum}x = ${fmt(lcmDen * targetTotal)}",
        "\\text{Divide both sides by } $sumNum: \\quad x = \\frac{${fmt(lcmDen * targetTotal)}}{$sumNum} = \\mathbf{${fmt(xSol)}}",
        "",
        "\\text{\\textbf{Stage 4: Check in Box D and Decision Box E}}",
        "\\text{When } x = ${fmt(xSol)}: \\quad \\text{Box B} = ${fmt(winB)}, \\quad \\text{Box C} = ${fmt(winC)}, \\quad \\text{Box D} = ${fmt(winB)} + ${fmt(winC)} = \\mathbf{${fmt(targetTotal)}} \\; (\\text{Yes } \\rightarrow \\text{ Stop!})",
      ];

      final List<FlowChartStep> steps = [
        FlowChartStep(
          title:
          "Step 1: Set Up Boxes A, B, C, D, E for '$p1Plain + $p2Plain = ${fmt(targetTotal)}' (Exercise 1.5 #3)",
          description:
          "Because the problem combines two different parts of the same number ('$p1Plain' and '$p2Plain'), we use labeled boxes so the computer can calculate each part separately and then add them together:\n"
              "• Box A: Choose x\n"
              "• Box B: $boxBText\n"
              "• Box C: $boxCText\n"
              "• Box D: Add B and C ($p1Plain + $p2Plain)\n"
              "• Box E (Decision): Is the result in D equal to ${fmt(targetTotal)}?",
          mathLaTeX:
          "\\text{Box B} = $p1LaTeX, \\quad \\text{Box C} = $p2LaTeX, \\quad \\text{Box D} = \\text{B} + \\text{C} = $p1LaTeX + $p2LaTeX",
        ),
        FlowChartStep(
          title:
          "Step 2: Computer Trial-and-Error Loop Trace Table",
          description:
          "Tracing the values in Boxes A, B, C, D, and E shows that when x = ${fmt(xSol)}, Box B = ${fmt(winB)} and Box C = ${fmt(winC)}, so Box D = ${fmt(winB)} + ${fmt(winC)} = ${fmt(targetTotal)} (Yes → Stop!):",
          mathLaTeX: traceBuf.toString(),
        ),
        FlowChartStep(
          title:
          "Step 3: Solve '$p1Plain + $p2Plain = ${fmt(targetTotal)}' Algebraically",
          description:
          "1. Clear the fraction by multiplying every term by $lcmDen:\n"
              "   ${scaledN1}x + ${scaledN2}x = ${fmt(lcmDen * targetTotal)}.\n"
              "2. Add like terms: ${sumNum}x = ${fmt(lcmDen * targetTotal)}.\n"
              "3. Divide both sides by $sumNum: x = ${fmt(lcmDen * targetTotal)} ÷ $sumNum = ${fmt(xSol)}.",
          mathLaTeX:
          "${scaledN1}x + ${scaledN2}x = ${fmt(lcmDen * targetTotal)} \\implies ${sumNum}x = ${fmt(lcmDen * targetTotal)} \\implies \\boxed{x = ${fmt(xSol)}}",
        ),
      ];

      return FlowChartResult(
        mode: 2,
        finalAnswers: {
          "Equation": "$p1Plain + $p2Plain = ${fmt(targetTotal)}",
          "Whole Number (x)": "x = ${fmt(xSol)}",
          "Box B ($p1Plain)": fmt(winB),
          "Box C ($p2Plain)": fmt(winC),
          "Box D (B + C)": "${fmt(winB)} + ${fmt(winC)} = ${fmt(targetTotal)}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: FlowChartCanvasData(
          mode: 2,
          mainNodes: nodes,
          hasTryAgainLoop: true,
          loopReturnIndex: 1,
          headerBadge:
          "Exercise 1.5 #3 Flow Chart:  $p1Plain + $p2Plain = ${fmt(targetTotal)}   (x = ${fmt(xSol)})",
          subBadge:
          "Box B = $p1Plain (${fmt(winB)})   |   Box C = $p2Plain (${fmt(winC)})   |   Box D = B + C = ${fmt(targetTotal)}",
          bottomSummaryBanner:
          "Whole Number: x = ${fmt(xSol)}   |   Check: ${fmt(winB)} + ${fmt(winC)} = ${fmt(targetTotal)} (Yes → Stop!)",
        ),
      );
    } catch (e) {
      return FlowChartResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter valid fractional/linear terms (e.g. '1/2x', '2x', and '25').",
      );
    }
  }

  // ===========================================================================
  // MODE 3: SEQUENTIAL INSTRUCTION & ALGORITHM ORGANIZER (Exercise 1.5 #5a–h)
  // Covers Exercise 1.5 #5: Arranging scrambled instructions for drawing a circle with a pair of compasses
  // ===========================================================================
  static int _compassLogicalRank(String stepText) {
    final String lower = stepText.toLowerCase();
    if (lower.contains('find') && lower.contains('mathematical set')) return 1;
    if (lower.contains('check') && lower.contains('sharpened')) return 2;
    if (lower.contains('pick up') && lower.contains('compass')) return 3;
    if (lower.contains('put') &&
        lower.contains('pencil') &&
        lower.contains('compass')) {
      return 4;
    }
    if (lower.contains('hold') && lower.contains('knob')) return 5;
    if (lower.contains('point') && lower.contains('paper')) return 6;
    if (lower.contains('turn') && lower.contains('carefully')) return 7;
    if (lower.contains('back') && lower.contains('mathematical set')) return 8;
    return 99;
  }

  static String _compassStepReason(int rank) {
    switch (rank) {
      case 1:
        return "Preparation: You must first locate your mathematical set before you can take any instrument out of it.";
      case 2:
        return "Preparation: Ensure your pencil is well sharpened before mounting it so the circle line is neat and accurate.";
      case 3:
        return "Tool Selection: Pick up the pair of compasses from the mathematical set.";
      case 4:
        return "Assembly: Insert and tighten the sharpened pencil inside the compasses.";
      case 5:
        return "Grip / Positioning: Hold the compasses properly by the knob at the top using your thumb and forefinger.";
      case 6:
        return "Anchoring Center: Place the sharp metal point of the compasses firmly on the paper to mark the centre of the circle.";
      case 7:
        return "Execution: Turn the compasses smoothly through 360°, leaning them slightly in the direction of rotation to draw the circle.";
      case 8:
        return "Cleanup / Completion: Once the circle is drawn, return the compasses safely back into the mathematical set.";
      default:
        return "Sequential instruction step in the computer program / algorithm.";
    }
  }

  static FlowChartResult solveSequentialInstructionOrganizer({
    required String rawInstructionsInput,
  }) {
    try {
      final List<String> lines = rawInstructionsInput
          .split(RegExp(r'[\n;]+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (lines.length < 2) {
        throw const FormatException(
          "Please enter at least 2 instructions (one per line or separated by ';'), or tap the 'Ex 1.5 #5' Preset Chip above!",
        );
      }

      // Check if this is the textbook compass circle problem (Exercise 1.5 #5a–h)
      final bool isCompassProblem =
      lines.any((l) => _compassLogicalRank(l) < 99);

      final List<Map<String, dynamic>> indexedSteps = [];
      for (int i = 0; i < lines.length; i++) {
        final String rawLine = lines[i];
        final RegExp prefixReg = RegExp(r'^([a-zA-Z0-9]+)[\)\.\:]\s*(.*)$');
        final Match? pm = prefixReg.firstMatch(rawLine);
        final String origTag =
        pm != null ? pm.group(1)!.toLowerCase() : '${i + 1}';
        final String cleanBody = pm != null ? pm.group(2)!.trim() : rawLine;
        final int rank =
        isCompassProblem ? _compassLogicalRank(cleanBody) : (i + 1);

        indexedSteps.add({
          'origTag': origTag,
          'body': cleanBody,
          'rank': rank,
          'origIdx': i,
        });
      }

      if (isCompassProblem) {
        indexedSteps.sort((a, b) {
          final int cmp = (a['rank'] as int).compareTo(b['rank'] as int);
          return cmp != 0
              ? cmp
              : (a['origIdx'] as int).compareTo(b['origIdx'] as int);
        });
      }

      final List<FlowChartNode> nodes = [
        const FlowChartNode(text: 'Start', type: FlowNodeType.startStopPill),
      ];
      final List<String> workings = [
        "\\text{\\textbf{Step 1: Why Instructions Must Be in Sequential Order (Pages 15 \\& 17)}}",
        "\\text{A \\textbf{program} is a finished list of meaningful instructions in sequential order.}",
        "\\text{A \\textbf{flow chart} organizes these instructions from \\textbf{Start} to \\textbf{Stop}:}",
        "",
        "\\text{\\textbf{Step 2: Correct Chronological Order of Instructions}}",
      ];

      final List<String> orderTags = [];
      final List<String> stepDescriptions = [];
      final List<String> latexOrderLines = [];

      for (int i = 0; i < indexedSteps.length; i++) {
        final Map<String, dynamic> item = indexedSteps[i];
        final String tag = item['origTag'] as String;
        final String body = item['body'] as String;
        final int rank = item['rank'] as int;
        orderTags.add('$tag)');

        nodes.add(FlowChartNode(
          boxLetter: '${i + 1}',
          text: '$tag) $body',
          type: FlowNodeType.processRect,
        ));

        final String lineTex =
            "\\text{Step ${i + 1} } \\mathbf{($tag)}: \\; \\text{${cleanTex(body)}}";
        workings.add(lineTex);
        latexOrderLines.add(lineTex);

        final String reason = _compassStepReason(rank);
        stepDescriptions.add(
          "${i + 1}. [$tag)] $body\n   • Why here: $reason",
        );
      }

      nodes.add(
          const FlowChartNode(text: 'Stop', type: FlowNodeType.startStopPill));

      final String arrowChainPlain = orderTags.join('  ➔  ');
      final String arrowChainLaTeX =
      orderTags.map((t) => "\\mathbf{\\text{$t}}").join(' \\rightarrow ');

      workings.add("");
      workings.add(
          "\\therefore \\; \\text{Correct Sequence} = $arrowChainLaTeX");

      final List<FlowChartStep> steps = [
        FlowChartStep(
          title:
          "Step 1: Understand Why Computers & Algorithms Need Strict Order (Page 15)",
          description:
          "• Textbook Rule (Page 15): 'The computer has no way of knowing whether the set of instructions given to it makes sense or not... Therefore, to carry out a task, computers need to be provided with a sequence of meaningful instructions in a certain sequential order.'\n"
              "• For example, you cannot put a pencil into your compasses before picking up the compasses, and you cannot put the compasses away before drawing the circle!",
          mathLaTeX:
          "\\text{Start} \\longrightarrow $arrowChainLaTeX \\longrightarrow \\text{Stop}",
        ),
        FlowChartStep(
          title:
          "Step 2: Arrange the Instructions in Logical Chronological Order (Exercise 1.5 #5)",
          description:
          "Grouping the instructions from Preparation → Assembly → Execution → Cleanup gives the exact sequence:\n\n"
              "${stepDescriptions.join('\n\n')}",
          mathLaTeX: latexOrderLines.join('\n'),
        ),
      ];

      return FlowChartResult(
        mode: 3,
        finalAnswers: {
          "Correct Letter Order": arrowChainPlain,
          "1st Instruction":
          "${indexedSteps.first['origTag']}) ${indexedSteps.first['body']}",
          "Last Instruction":
          "${indexedSteps.last['origTag']}) ${indexedSteps.last['body']}",
          "Total Steps": "${indexedSteps.length} sequential steps",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: FlowChartCanvasData(
          mode: 3,
          mainNodes: nodes,
          hasTryAgainLoop: false,
          headerBadge:
          "Exercise 1.5 #5 Sequential Flow Chart:  $arrowChainPlain",
          subBadge:
          "Each box contains one instruction arranged in strict chronological order from Start to Stop",
          bottomSummaryBanner: "Correct Order:  Start  ➔  $arrowChainPlain  ➔  Stop",
        ),
      );
    } catch (e) {
      return FlowChartResult.error(
        mode: 3,
        message: e is FormatException
            ? e.message
            : "Please enter a list of instructions to arrange into a flow chart.",
      );
    }
  }
}