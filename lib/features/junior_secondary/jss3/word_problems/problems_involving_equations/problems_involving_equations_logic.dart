import 'problems_involving_equations_models.dart';

/// Represents a single operation in an "I thought of a number..." chain (e.g., `* 5`, `+ 3`, `/ 12`).
class _ChainOp {
  final String op; // '+', '-', '*', '/'
  final double val;
  final String valStr;

  const _ChainOp({
    required this.op,
    required this.val,
    required this.valStr,
  });
}

class ProblemsInvolvingEquationsLogic {
  // ===========================================================================
  // 14 TEXTBOOK PRESETS (Pages 27–28: Examples 14, 15, 16, Puzzle & Exercise 2.6)
  // ===========================================================================
  static const List<ProblemsInvolvingEquationsPreset> textbookPresets = [
    ProblemsInvolvingEquationsPreset(
      chipLabel: "Example 14 (Page 27): Product of x and 5 added to 3 gives 2",
      mode: 0,
      varLetter: 'x',
      operationsChain: '*5, +3',
      targetResult: '2',
    ),
    ProblemsInvolvingEquationsPreset(
      chipLabel: "Example 15 (Page 27): (3m − 1) / 5 = 1 + m",
      mode: 1,
      varLetter: 'm',
      input1: '3', // a in (a*m + b)/d = c*m + e
      input2: '-1', // b
      input3: '5', // d (denominator)
      input4: '1', // c (coeff of m on RHS)
      input5: '1', // e (constant on RHS)
    ),
    ProblemsInvolvingEquationsPreset(
      chipLabel: "Example 16 (Page 28): Add 3, multiply by 4, add 7 gives 63",
      mode: 0,
      varLetter: 'n',
      operationsChain: '+3, *4, +7',
      targetResult: '63',
    ),
    ProblemsInvolvingEquationsPreset(
      chipLabel: "Ex 2.6 #1: 1 subtracted from 8 times a number is 15",
      mode: 0,
      varLetter: 'x',
      operationsChain: '*8, -1',
      targetResult: '15',
    ),
    ProblemsInvolvingEquationsPreset(
      chipLabel: "Ex 2.6 #2: Number added to 7, then divided by 12 is 4",
      mode: 0,
      varLetter: 'x',
      operationsChain: '+7, /12',
      targetResult: '4',
    ),
    ProblemsInvolvingEquationsPreset(
      chipLabel: "Ex 2.6 #3: Multiply by 3, add 6, divide by 5 gives 2",
      mode: 0,
      varLetter: 'x',
      operationsChain: '*3, +6, /5',
      targetResult: '2',
    ),
    ProblemsInvolvingEquationsPreset(
      chipLabel: "Ex 2.6 #4: Add 3, then multiply by 2 gives 8.4",
      mode: 0,
      varLetter: 'x',
      operationsChain: '+3, *2',
      targetResult: '8.4',
    ),
    ProblemsInvolvingEquationsPreset(
      chipLabel: "Ex 2.6 #5 (5-Step!): +7, ×3, −3, ÷2, ×12 gives 72",
      mode: 0,
      varLetter: 'n',
      operationsChain: '+7, *3, -3, /2, *12',
      targetResult: '72',
    ),
    ProblemsInvolvingEquationsPreset(
      chipLabel: "Ex 2.6 #6 (Timi's Class): 3× as many wear glasses; 28 total",
      mode: 2,
      subMode: 0, // Group Multiple Partition: x + k*x = Total
      varLetter: 'x',
      input1: '3',
      input2: '0',
      input3: '28',
      input4: 'Students who do NOT wear glasses',
      input5: 'Students who wear glasses',
    ),
    ProblemsInvolvingEquationsPreset(
      chipLabel: "Puzzle (Page 28): Smallest number × 12 = Palindrome",
      mode: 3,
      subMode: 1, // Palindrome Multiplier Puzzle
      input2: '12',
    ),
    ProblemsInvolvingEquationsPreset(
      chipLabel: "Universal Solver: 4(n + 3) + 7 = 63 (Example 16)",
      mode: 3,
      subMode: 0,
      input1: '4(n + 3) + 7 = 63',
    ),
    ProblemsInvolvingEquationsPreset(
      chipLabel: "Universal Solver: (3m - 1) / 5 = 1 + m (Example 15)",
      mode: 3,
      subMode: 0,
      input1: '(3m - 1) / 5 = 1 + m',
    ),
    ProblemsInvolvingEquationsPreset(
      chipLabel: "Partition: String 45 cm cut so 2nd part is 2× first + 3 cm",
      mode: 2,
      subMode: 0,
      varLetter: 'x',
      input1: '2',
      input2: '3',
      input3: '45',
      input4: 'First piece of string (cm)',
      input5: 'Second piece of string (cm)',
    ),
    ProblemsInvolvingEquationsPreset(
      chipLabel: "Rectangle Perimeter: Length is 5 cm more than 2× breadth, P = 46",
      mode: 2,
      subMode: 1, // Rectangle Perimeter: 2(x + mx + b) = P
      varLetter: 'x',
      input1: '2',
      input2: '5',
      input3: '46',
      input4: 'Breadth of rectangle (cm)',
      input5: 'Length of rectangle (cm)',
    ),
  ];

  // ===========================================================================
  // FORMATTING & RATIONAL ARITHMETIC HELPERS (Math.tex Safe!)
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

  /// Formats any rational fraction `num / den` into plain and LaTeX (kept strictly outside `\text{...}`!)
  static Map<String, String> formatRational(double numVal, double denVal) {
    if (denVal.abs() < 1e-12) {
      return {'plain': 'Undefined', 'latex': '\\text{Undefined}'};
    }
    final double exact = numVal / denVal;
    if (exact.abs() < 1e-9) {
      return {'plain': '0', 'latex': '0'};
    }

    // Scale decimals to integers (e.g., 2.4 / 2 -> 24 / 20)
    final int scaledN = (numVal * 1000).round();
    final int scaledD = (denVal * 1000).round();
    final bool isNeg = (scaledN < 0) ^ (scaledD < 0);
    int n = scaledN.abs();
    int d = scaledD.abs();
    final int g = gcd(n, d);
    n ~/= g;
    d ~/= g;
    final String sign = isNeg ? '-' : '';

    if (d == 1) {
      return {'plain': '$sign$n', 'latex': '$sign$n'};
    }

    // If input had decimals (like 8.4 in Ex 2.6 #4 giving x = 1.2) and decimal is clean, show both!
    if (d == 2 || d == 4 || d == 5 || d == 8 || d == 10) {
      final String decStr = fmt(exact);
      if (n > d) {
        final int w = n ~/ d;
        final int rem = n % d;
        return {
          'plain': '$decStr (or $sign$w $rem/$d)',
          'latex': '$decStr \\quad \\left(\\text{or } $sign$w\\frac{$rem}{$d}\\right)',
        };
      }
      return {
        'plain': '$sign$n/$d (or $decStr)',
        'latex': '\\frac{$sign$n}{$d} \\quad (\\text{or } $decStr)',
      };
    }

    if (n > d) {
      final int w = n ~/ d;
      final int rem = n % d;
      return {
        'plain': '$sign$w $rem/$d (or ${fmt(exact)})',
        'latex': '\\frac{$sign$n}{$d} = $sign$w\\frac{$rem}{$d}',
      };
    }
    return {
      'plain': '$sign$n/$d',
      'latex': '\\frac{$sign$n}{$d}',
    };
  }

  static String formatLinearExprLaTeX(
      double a,
      double b,
      String v, {
        bool constFirst = false,
      }) {
    String vPart = '';
    if ((a - 1.0).abs() < 1e-9) {
      vPart = v;
    } else if ((a + 1.0).abs() < 1e-9) {
      vPart = '-$v';
    } else if (a.abs() > 1e-9) {
      vPart = '${fmt(a)}$v';
    }

    if (b.abs() < 1e-9) {
      return vPart.isEmpty ? '0' : vPart;
    }
    if (vPart.isEmpty) return fmt(b);

    if (constFirst) {
      final String signV = a >= 0 ? '+ $vPart' : '- ${vPart.replaceFirst('-', '')}';
      return '${fmt(b)} $signV';
    }
    final String signB = b >= 0 ? '+ ${fmt(b)}' : '- ${fmt(b.abs())}';
    return '$vPart $signB';
  }

  static String formatLinearExprPlain(
      double a,
      double b,
      String v, {
        bool constFirst = false,
      }) {
    return formatLinearExprLaTeX(a, b, v, constFirst: constFirst)
        .replaceAll('-', '−');
  }

  /// Generates the textbook's exact balance-method lines for solving `A*v + B = C`
  /// without skipping a single intermediate line (matching Examples 14, 15, and 16 on Pages 27–28!).
  static List<String> buildBalanceSolveLinesLaTeX({
    required double coeffA,
    required double constB,
    required double rhsC,
    required String varName,
  }) {
    final List<String> lines = [];
    final String lhsInitial = formatLinearExprLaTeX(coeffA, constB, varName);
    final String axStr = (coeffA - 1.0).abs() < 1e-9
        ? varName
        : ((coeffA + 1.0).abs() < 1e-9 ? '-$varName' : '${fmt(coeffA)}$varName');

    double rhsAfterB = rhsC;

    if (constB.abs() > 1e-9) {
      final double absB = constB.abs();
      if (constB > 0) {
        // Subtract absB from both sides (Textbook Example 14 & 16 style!)
        lines.add("\\text{Subtract } ${fmt(absB)} \\text{ from both sides:}");
        lines.add(
            "$lhsInitial - ${fmt(absB)} = ${fmt(rhsC)} - ${fmt(absB)}");
        rhsAfterB = rhsC - absB;
        lines.add("$axStr = ${fmt(rhsAfterB)}");
      } else {
        // Add absB to both sides
        lines.add("\\text{Add } ${fmt(absB)} \\text{ to both sides:}");
        lines.add(
            "$lhsInitial + ${fmt(absB)} = ${fmt(rhsC)} + ${fmt(absB)}");
        rhsAfterB = rhsC + absB;
        lines.add("$axStr = ${fmt(rhsAfterB)}");
      }
    }

    if ((coeffA - 1.0).abs() > 1e-9) {
      lines.add("\\text{Divide both sides by } ${fmt(coeffA)}:");
      lines.add(
          "\\frac{$axStr}{${fmt(coeffA)}} = \\frac{${fmt(rhsAfterB)}}{${fmt(coeffA)}}");
    }

    final Map<String, String> ansFmt = formatRational(rhsAfterB, coeffA);
    lines.add("\\therefore \\; \\mathbf{$varName = ${ansFmt['latex']}}");
    return lines;
  }

  // ===========================================================================
  // MODE 0: "I THOUGHT OF A NUMBER..." SEQUENTIAL OPERATION CHAINS
  // Covers Examples 14 & 16 (Pages 27–28) and Exercise 2.6 #1, #2, #3, #4, #5
  // ===========================================================================
  static List<_ChainOp> _parseOperationsChain(String rawChain) {
    final String clean = rawChain
        .trim()
        .replaceAll('−', '-')
        .replaceAll('×', '*')
        .replaceAll('÷', '/');

    if (clean.isEmpty) {
      throw const FormatException(
        "Please enter at least one operation in the chain (e.g. '*5, +3' or '+3, *4, +7' or '+7, *3, -3, /2, *12').",
      );
    }

    final List<String> tokens = clean
        .split(RegExp(r'[,;\n]+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final List<_ChainOp> ops = [];
    for (final String tok in tokens) {
      String s = tok.toLowerCase().replaceAll(' ', '');
      s = s
          .replaceAll('add', '+')
          .replaceAll('plus', '+')
          .replaceAll('subtract', '-')
          .replaceAll('minus', '-')
          .replaceAll('multiplyby', '*')
          .replaceAll('times', '*')
          .replaceAll('divideby', '/');

      if (s.isEmpty) continue;
      final String opCh = s[0];
      if (!['+', '-', '*', '/'].contains(opCh)) {
        throw FormatException(
          "Each operation in '$tok' must start with +, -, *, or / (e.g. +3, *4, -1, /5).",
        );
      }
      final double? val = double.tryParse(s.substring(1));
      if (val == null || (opCh == '/' && val.abs() < 1e-12)) {
        throw FormatException("Invalid number in operation '$tok'.");
      }
      ops.add(_ChainOp(op: opCh, val: val, valStr: fmt(val)));
    }

    if (ops.isEmpty) {
      throw const FormatException("Please enter valid operations (e.g. +3, *4, +7).");
    }
    return ops;
  }

  static ProblemsInvolvingEquationsResult solveSequentialChainProblem({
    required String varLetter,
    required String operationsChainStr,
    required String targetResultStr,
  }) {
    try {
      final String v = varLetter.trim().isEmpty
          ? 'x'
          : varLetter.trim()[0].toLowerCase();
      final List<_ChainOp> ops = _parseOperationsChain(operationsChainStr);
      final double? targetResult =
      double.tryParse(targetResultStr.trim().replaceAll('−', '-'));
      if (targetResult == null) {
        throw const FormatException(
          "Please enter a valid number for the final result (e.g. 2, 63, 15, 4, 8.4, or 72).",
        );
      }

      // 1. Build the Textbook's Progressive "i.e." Algebraic Construction Lines!
      String exprLaTeX = v;
      String exprPlain = v;
      String lastOpType = 'atom'; // 'atom', 'addsub', 'mul', 'div'

      // Track exact linear form (numCoeff * v + numConst) / denFactor at each stage
      double numCoeff = 1.0;
      double numConst = 0.0;
      double denFactor = 1.0;

      final List<String> progressiveLinesLaTeX = [
        "\\text{Let } $v \\text{ be the number.}",
      ];
      final List<String> progressiveLinesPlain = [
        "• Let $v be the number.",
      ];

      final List<Map<String, String>> forwardDisplayStages = [
        {'op': 'Start', 'expr': v},
      ];

      for (int i = 0; i < ops.length; i++) {
        final _ChainOp step = ops[i];
        if (step.op == '+') {
          exprLaTeX = "$exprLaTeX + ${step.valStr}";
          exprPlain = "$exprPlain + ${step.valStr}";
          lastOpType = 'addsub';
          numConst += step.val * denFactor;

          progressiveLinesLaTeX.add(
              "\\text{Add } ${step.valStr} \\text{ to it, i.e. } \\mathbf{$exprLaTeX}");
          progressiveLinesPlain
              .add("• Add ${step.valStr} to it, i.e. $exprPlain.");
          forwardDisplayStages
              .add({'op': '+ ${step.valStr}', 'expr': exprPlain});
        } else if (step.op == '-') {
          exprLaTeX = "$exprLaTeX - ${step.valStr}";
          exprPlain = "$exprPlain − ${step.valStr}";
          lastOpType = 'addsub';
          numConst -= step.val * denFactor;

          progressiveLinesLaTeX.add(
              "\\text{Subtract } ${step.valStr} \\text{ from it, i.e. } \\mathbf{$exprLaTeX}");
          progressiveLinesPlain
              .add("• Subtract ${step.valStr} from it, i.e. $exprPlain.");
          forwardDisplayStages
              .add({'op': '− ${step.valStr}', 'expr': exprPlain});
        } else if (step.op == '*') {
          if (lastOpType == 'atom') {
            exprLaTeX = "${step.valStr}$v";
            exprPlain = "${step.valStr}$v";
            progressiveLinesLaTeX.add(
                "\\text{Product of } $v \\text{ and } ${step.valStr} \\text{ is } ${step.valStr} \\times $v = \\mathbf{$exprLaTeX}");
            progressiveLinesPlain.add(
                "• Multiply $v by ${step.valStr}, i.e. ${step.valStr} × $v = $exprPlain.");
          } else if (lastOpType == 'addsub') {
            exprLaTeX = "${step.valStr}($exprLaTeX)";
            exprPlain = "${step.valStr}($exprPlain)";
            progressiveLinesLaTeX.add(
                "\\text{Multiply by } ${step.valStr}, \\text{ i.e. } \\mathbf{$exprLaTeX}");
            progressiveLinesPlain
                .add("• Multiply by ${step.valStr}, i.e. $exprPlain.");
          } else if (lastOpType == 'div') {
            exprLaTeX = "${step.valStr} \\times \\left($exprLaTeX\\right)";
            exprPlain = "${step.valStr} × ($exprPlain)";
            progressiveLinesLaTeX.add(
                "\\text{Then multiply by } ${step.valStr}, \\text{ i.e. } \\mathbf{$exprLaTeX}");
            progressiveLinesPlain
                .add("• Then multiply by ${step.valStr}, i.e. $exprPlain.");
          } else {
            exprLaTeX = "${step.valStr} \\times $exprLaTeX";
            exprPlain = "${step.valStr} × $exprPlain";
            progressiveLinesLaTeX.add(
                "\\text{Multiply by } ${step.valStr}, \\text{ i.e. } \\mathbf{$exprLaTeX}");
            progressiveLinesPlain
                .add("• Multiply by ${step.valStr}, i.e. $exprPlain.");
          }
          lastOpType = 'mul';

          // Check if step.val cancels with denFactor (like /2 followed by *12 in Ex 2.6 #5!)
          final int gCancel =
          gcd(step.val.round(), denFactor.round());
          if (denFactor > 1 && gCancel > 1) {
            final double multRem = step.val / gCancel;
            denFactor /= gCancel;
            numCoeff *= multRem;
            numConst *= multRem;
          } else {
            numCoeff *= step.val;
            numConst *= step.val;
          }
          forwardDisplayStages
              .add({'op': '× ${step.valStr}', 'expr': exprPlain});
        } else {
          // Division '/'
          exprLaTeX = "\\frac{$exprLaTeX}{${step.valStr}}";
          exprPlain = "($exprPlain) / ${step.valStr}";
          lastOpType = 'div';
          denFactor *= step.val;

          progressiveLinesLaTeX.add(
              "\\text{Divide by } ${step.valStr}, \\text{ i.e. } \\mathbf{$exprLaTeX}");
          progressiveLinesPlain
              .add("• Divide by ${step.valStr}, i.e. $exprPlain.");
          forwardDisplayStages
              .add({'op': '÷ ${step.valStr}', 'expr': exprPlain});
        }
      }

      final String fullEquationLaTeX =
          "$exprLaTeX = ${fmt(targetResult)}";
      final String fullEquationPlain =
          "$exprPlain = ${fmt(targetResult)}";

      progressiveLinesLaTeX.add(
          "\\text{The result is } ${fmt(targetResult)}, \\text{ i.e. } \\mathbf{$fullEquationLaTeX}");
      progressiveLinesPlain.add(
          "• The result is ${fmt(targetResult)}, so the equation is: $fullEquationPlain.");

      // 2. Build Unabridged Balance-Method Solution Lines (Examples 14 & 16 Style)
      final List<String> solveLinesLaTeX = [
        "\\text{The equation is:}",
        "\\mathbf{$fullEquationLaTeX}",
      ];

      double effectiveRhs = targetResult;
      if (denFactor > 1.0) {
        solveLinesLaTeX.add(
            "\\text{Multiply both sides by } ${fmt(denFactor)} \\text{ to clear the fraction:}");
        solveLinesLaTeX.add(
            "$exprLaTeX \\times ${fmt(denFactor)} = ${fmt(targetResult)} \\times ${fmt(denFactor)}");
        effectiveRhs = targetResult * denFactor;
      }

      final String simplifiedLhsLaTeX =
      formatLinearExprLaTeX(numCoeff, numConst, v);
      if (fullEquationLaTeX != "$simplifiedLhsLaTeX = ${fmt(effectiveRhs)}") {
        if (ops.any((o) => o.op == '*') && ops.first.op != '*') {
          solveLinesLaTeX.add(
              "\\text{Open the bracket and simplify:}");
        }
        solveLinesLaTeX.add(
            "$simplifiedLhsLaTeX = ${fmt(effectiveRhs)}");
      }

      solveLinesLaTeX.addAll(buildBalanceSolveLinesLaTeX(
        coeffA: numCoeff,
        constB: numConst,
        rhsC: effectiveRhs,
        varName: v,
      ));

      final Map<String, String> ansFmt =
      formatRational(effectiveRhs - numConst, numCoeff);
      final double exactVal = (effectiveRhs - numConst) / numCoeff;

      // 3. Build Inverse / Backtracking Verification Chain (Working Backwards from Result!)
      final List<String> backtrackLinesLaTeX = [
        "\\text{Start with the final result } ${fmt(targetResult)} \\text{ and undo each operation in reverse order:}",
      ];
      final List<String> backtrackPlain = [];

      double currRev = targetResult;
      final List<String> revValsAtEachNode = List.filled(ops.length + 1, '');
      revValsAtEachNode[ops.length] = fmt(currRev);

      for (int i = ops.length - 1; i >= 0; i--) {
        final _ChainOp step = ops[i];
        final double beforeRev = currRev;
        String invDescLaTeX = "";
        String invBadge = "";

        if (step.op == '+') {
          currRev -= step.val;
          invBadge = "− ${step.valStr}";
          invDescLaTeX =
          "\\text{Undo '+ ${step.valStr}' by subtracting } ${step.valStr}: \\quad ${fmt(beforeRev)} - ${step.valStr} = \\mathbf{${fmt(currRev)}}";
        } else if (step.op == '-') {
          currRev += step.val;
          invBadge = "+ ${step.valStr}";
          invDescLaTeX =
          "\\text{Undo '}- ${step.valStr}\\text{' by adding } ${step.valStr}: \\quad ${fmt(beforeRev)} + ${step.valStr} = \\mathbf{${fmt(currRev)}}";
        } else if (step.op == '*') {
          currRev /= step.val;
          invBadge = "÷ ${step.valStr}";
          invDescLaTeX =
          "\\text{Undo '}\\times ${step.valStr}\\text{' by dividing by } ${step.valStr}: \\quad \\frac{${fmt(beforeRev)}}{${step.valStr}} = \\mathbf{${formatRational(beforeRev, step.val)['latex']}}";
        } else {
          currRev *= step.val;
          invBadge = "× ${step.valStr}";
          invDescLaTeX =
          "\\text{Undo '}\\div ${step.valStr}\\text{' by multiplying by } ${step.valStr}: \\quad ${fmt(beforeRev)} \\times ${step.valStr} = \\mathbf{${fmt(currRev)}}";
        }

        backtrackLinesLaTeX.add(invDescLaTeX);
        backtrackPlain.add(
            "• Undo '${step.op} ${step.valStr}' ($invBadge): ${fmt(beforeRev)} $invBadge = ${fmt(currRev)}");
        revValsAtEachNode[i] = i == 0
            ? "$v = ${ansFmt['plain']}"
            : fmt(currRev);
      }

      // Build Pipeline Nodes for the CustomPaint Visualizer (up to 4 compact nodes)
      final List<PipelineStepNode> visualNodes = [
        PipelineStepNode(
          opBadge: 'Choose $v',
          exprText: v,
          inverseOpBadge: 'Start',
          inverseValText: revValsAtEachNode[0],
        ),
        for (int i = 0; i < ops.length; i++)
          PipelineStepNode(
            opBadge: forwardDisplayStages[i + 1]['op']!,
            exprText: i == ops.length - 1
                ? "${forwardDisplayStages[i + 1]['expr']} = ${fmt(targetResult)}"
                : forwardDisplayStages[i + 1]['expr']!,
            inverseOpBadge: ops[i].op == '+'
                ? '− ${ops[i].valStr}'
                : (ops[i].op == '-'
                ? '+ ${ops[i].valStr}'
                : (ops[i].op == '*'
                ? '÷ ${ops[i].valStr}'
                : '× ${ops[i].valStr}')),
            inverseValText: revValsAtEachNode[i + 1],
          ),
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Translate the Word Problem into an Equation (Textbook 'i.e.' Method)}}",
        ...progressiveLinesLaTeX,
        "",
        "\\text{\\textbf{Step 2: Solve the Equation Using the Balance Method}}",
        ...solveLinesLaTeX,
        "",
        "\\text{\\textbf{Step 3: Inverse Backtracking Check (Working Backwards)}}",
        ...backtrackLinesLaTeX,
      ];

      final List<ProblemsInvolvingEquationsStep> steps = [
        ProblemsInvolvingEquationsStep(
          title:
          "Step 1: Build the Equation Line-by-Line Using '$v' (Examples 14 & 16 Style)",
          description:
          "Follow the exact order of operations in the word problem one phrase at a time:\n"
              "${progressiveLinesPlain.join('\n')}",
          mathLinesLaTeX: progressiveLinesLaTeX,
        ),
        ProblemsInvolvingEquationsStep(
          title:
          "Step 2: Simplify and Solve for '$v' Using the Balance Method",
          description:
          "1. Clear any fractions or brackets so the left-hand side is in the form $simplifiedLhsLaTeX = ${fmt(effectiveRhs)}.\n"
              "2. Perform the same inverse operation on both sides of the equation to isolate $v = ${ansFmt['plain']}.",
          mathLinesLaTeX: solveLinesLaTeX,
        ),
        ProblemsInvolvingEquationsStep(
          title:
          "Step 3: Verify by Backtracking (Undoing Operations in Reverse Order)",
          description:
          "You can double-check your answer by starting from ${fmt(targetResult)} and applying the opposite operation at each step in reverse order:\n"
              "${backtrackPlain.join('\n')}\n"
              "• Both methods confirm $v = ${ansFmt['plain']} (${fmt(exactVal)})!",
          mathLinesLaTeX: backtrackLinesLaTeX,
        ),
      ];

      return ProblemsInvolvingEquationsResult(
        mode: 0,
        finalAnswers: {
          "Formed Equation": fullEquationPlain,
          "Simplified Form":
          "${formatLinearExprPlain(numCoeff, numConst, v)} = ${fmt(effectiveRhs)}",
          "Number Thought Of ($v)": ansFmt['plain']!,
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: ProblemsInvolvingEquationsCanvasData(
          visualType: 0,
          pipelineNodes: visualNodes,
          headerBadge:
          "Equation:  $fullEquationPlain   ➔   Solution:  $v = ${ansFmt['plain']}",
          subBadge:
          "Top Row: Forward Expression Building ('i.e.' steps)   |   Bottom Row: Inverse Unwinding back to $v",
          bottomSummaryBanner:
          "The Number Thought Of Is:   $v = ${ansFmt['plain']}",
        ),
      );
    } catch (e) {
      return ProblemsInvolvingEquationsResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter valid operations (e.g. +3, *4, +7) and a target result.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: FRACTIONAL & TWO-SIDED EQUATIONS WHERE BOTH SIDES DEPEND ON x
  // Covers Example 15 (Pages 27–28): (3m - 1) / 5 = 1 + m
  // General Form: (a*m + b) / d = c*m + e
  // ===========================================================================
  static ProblemsInvolvingEquationsResult solveTwoSidedFractionalProblem({
    required String varLetter,
    required String coeffAStr, // e.g., 3
    required String constBStr, // e.g., -1
    required String denomDStr, // e.g., 5
    required String rhsCoeffCStr, // e.g., 1
    required String rhsConstEStr, // e.g., 1
  }) {
    try {
      final String m = varLetter.trim().isEmpty
          ? 'm'
          : varLetter.trim()[0].toLowerCase();
      final double? a = double.tryParse(coeffAStr.trim().replaceAll('−', '-'));
      final double? b = double.tryParse(constBStr.trim().replaceAll('−', '-'));
      final double? d = double.tryParse(denomDStr.trim().replaceAll('−', '-'));
      final double? c =
      double.tryParse(rhsCoeffCStr.trim().replaceAll('−', '-'));
      final double? e =
      double.tryParse(rhsConstEStr.trim().replaceAll('−', '-'));

      if (a == null || b == null || d == null || c == null || e == null) {
        throw const FormatException(
          "Please fill in all fields (e.g. a = 3, b = -1, d = 5, c = 1, e = 1 for Example 15).",
        );
      }
      if (d.abs() < 1e-12) {
        throw const FormatException("Denominator d cannot be zero.");
      }

      final double rhsScaledCoeff = d * c;
      final double rhsScaledConst = d * e;
      if ((a - rhsScaledCoeff).abs() < 1e-12) {
        throw const FormatException(
          "After clearing the fraction, the coefficients of the unknown on both sides are equal, so there is no unique solution.",
        );
      }

      final String numExprLaTeX = formatLinearExprLaTeX(a, b, m);
      final String numExprPlain = formatLinearExprPlain(a, b, m);
      final String rhsExprLaTeX =
      formatLinearExprLaTeX(c, e, m, constFirst: e > 0 && c > 0);
      final String rhsExprPlain =
      formatLinearExprPlain(c, e, m, constFirst: e > 0 && c > 0);

      final String eqLaTeX =
      (d - 1.0).abs() < 1e-9
          ? "$numExprLaTeX = $rhsExprLaTeX"
          : "\\frac{$numExprLaTeX}{${fmt(d)}} = $rhsExprLaTeX";
      final String eqPlain =
      (d - 1.0).abs() < 1e-9
          ? "$numExprPlain = $rhsExprPlain"
          : "($numExprPlain) / ${fmt(d)} = $rhsExprPlain";

      // 1. Progressive "i.e." Construction (Exact Example 15 Style on Page 27!)
      final List<String> step1Lines = [
        "\\text{Let } $m \\text{ be the number.}",
        "${fmt(a)} \\text{ times } $m = ${fmt(a)} \\times $m = \\mathbf{${fmt(a)}$m}",
        if (b < 0)
          "${fmt(b.abs())} \\text{ is subtracted from } ${fmt(a)}$m, \\text{ i.e. } \\mathbf{$numExprLaTeX}"
        else if (b > 0)
          "${fmt(b)} \\text{ is added to } ${fmt(a)}$m, \\text{ i.e. } \\mathbf{$numExprLaTeX}",
        if ((d - 1.0).abs() > 1e-9)
          "\\text{It is divided by } ${fmt(d)}, \\text{ i.e. } \\mathbf{\\frac{$numExprLaTeX}{${fmt(d)}}}",
        "\\text{The result is the same as } $rhsExprLaTeX, \\text{ i.e.}",
        "\\mathbf{$eqLaTeX}",
      ];

      // 2. Unabridged Textbook Balance-Method Solution (Pages 27–28!)
      final List<String> step2Lines = [eqLaTeX];
      if ((d - 1.0).abs() > 1e-9) {
        step2Lines.add(
            "\\text{Multiply both sides by } ${fmt(d)} \\text{ to clear the fraction:}");
        step2Lines.add(
            "\\frac{$numExprLaTeX}{${fmt(d)}} \\times ${fmt(d)} = ${fmt(d)}($rhsExprLaTeX)");
      }

      final String clearedRhsLaTeX = formatLinearExprLaTeX(
        rhsScaledCoeff,
        rhsScaledConst,
        m,
        constFirst: e > 0 && c > 0,
      );
      step2Lines.add("$numExprLaTeX = $clearedRhsLaTeX");

      // Follow Example 15's exact variable collection steps!
      if (rhsScaledCoeff > a) {
        // Subtract a*m from both sides (just like Example 15: Subtract 3m from both sides!)
        final double diffM = rhsScaledCoeff - a;
        final String amStr =
        (a - 1.0).abs() < 1e-9 ? m : "${fmt(a)}$m";
        final String diffMStr =
        (diffM - 1.0).abs() < 1e-9 ? m : "${fmt(diffM)}$m";

        step2Lines.add(
            "\\text{Subtract } $amStr \\text{ from both sides:}");
        step2Lines.add(
            "$numExprLaTeX - $amStr = $clearedRhsLaTeX - $amStr");
        step2Lines.add(
            "${fmt(b)} = ${fmt(rhsScaledConst)} + $diffMStr");

        if (rhsScaledConst.abs() > 1e-9) {
          final double absRConst = rhsScaledConst.abs();
          final String opWord = rhsScaledConst > 0 ? "Subtract" : "Add";
          final String opSym = rhsScaledConst > 0 ? "-" : "+";
          final double netConstLeft = b - rhsScaledConst;

          step2Lines.add(
              "\\text{$opWord } ${fmt(absRConst)} \\text{ ${rhsScaledConst > 0 ? 'from' : 'to'} both sides:}");
          step2Lines.add(
              "${fmt(b)} $opSym ${fmt(absRConst)} = ${fmt(rhsScaledConst)} + $diffMStr $opSym ${fmt(absRConst)}");
          step2Lines.add("${fmt(netConstLeft)} = $diffMStr");

          if ((diffM - 1.0).abs() > 1e-9) {
            step2Lines.add("\\text{Divide both sides by } ${fmt(diffM)}:");
            step2Lines.add(
                "\\frac{${fmt(netConstLeft)}}{${fmt(diffM)}} = \\frac{$diffMStr}{${fmt(diffM)}}");
          }
          final Map<String, String> ansFmt =
          formatRational(netConstLeft, diffM);
          step2Lines
              .add("\\therefore \\; \\mathbf{$m = ${ansFmt['latex']}}");
        }
      } else {
        // Collect variable on the LHS
        final double netM = a - rhsScaledCoeff;
        final String cmStr = (rhsScaledCoeff.abs() - 1.0).abs() < 1e-9
            ? m
            : "${fmt(rhsScaledCoeff.abs())}$m";
        final String opMWord = rhsScaledCoeff >= 0 ? "Subtract" : "Add";
        final String opMSym = rhsScaledCoeff >= 0 ? "-" : "+";

        step2Lines.add(
            "\\text{$opMWord } $cmStr \\text{ ${rhsScaledCoeff >= 0 ? 'from' : 'to'} both sides:}");
        step2Lines.add(
            "$numExprLaTeX $opMSym $cmStr = $clearedRhsLaTeX $opMSym $cmStr");
        step2Lines.add(
            "${formatLinearExprLaTeX(netM, b, m)} = ${fmt(rhsScaledConst)}");
        step2Lines.addAll(buildBalanceSolveLinesLaTeX(
          coeffA: netM,
          constB: b,
          rhsC: rhsScaledConst,
          varName: m,
        ));
      }

      final double exactM = (rhsScaledConst - b) / (a - rhsScaledCoeff);
      final Map<String, String> finalAnsFmt =
      formatRational(rhsScaledConst - b, a - rhsScaledCoeff);
      final double checkSideVal = c * exactM + e;

      final List<String> step3Lines = [
        "\\text{Substitute } $m = ${fmt(exactM)} \\text{ into both sides of } $eqLaTeX:",
        "\\bullet \\; \\text{LHS} = \\frac{${fmt(a)}(${fmt(exactM)}) ${b >= 0 ? '+ ${fmt(b)}' : '- ${fmt(b.abs())}'}}{${fmt(d)}} = \\frac{${fmt(a * exactM + b)}}{${fmt(d)}} = \\mathbf{${fmt(checkSideVal)}}",
        "\\bullet \\; \\text{RHS} = $rhsExprLaTeX = \\mathbf{${fmt(checkSideVal)}} \\quad (\\text{LHS} = \\text{RHS Verified!})",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Translate the Word Problem into an Equation (Example 15 Method)}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Step 2: Clear the Fraction and Solve by the Balance Method}}",
        ...step2Lines,
        "",
        "\\text{\\textbf{Step 3: Verification Check on Both Sides}}",
        ...step3Lines,
      ];

      final List<ProblemsInvolvingEquationsStep> steps = [
        ProblemsInvolvingEquationsStep(
          title:
          "Step 1: Build Both Sides of the Equation Step-by-Step (Example 15)",
          description:
          "• Let $m be the unknown number.\n"
              "• Build the Left-Hand Side expression: ($numExprPlain) / ${fmt(d)}.\n"
              "• Build the Right-Hand Side expression: $rhsExprPlain.\n"
              "• Equate both expressions: $eqPlain.",
          mathLinesLaTeX: step1Lines,
        ),
        ProblemsInvolvingEquationsStep(
          title:
          "Step 2: Multiply Both Sides by ${fmt(d)} & Solve by the Balance Method",
          description:
          "1. Multiply both sides by ${fmt(d)} to clear the fraction: $numExprPlain = ${formatLinearExprPlain(rhsScaledCoeff, rhsScaledConst, m)}.\n"
              "2. Collect like terms in $m on one side and constant numbers on the other side, showing every subtraction/division on both sides.\n"
              "3. Solution: $m = ${finalAnsFmt['plain']} (Both sides equal ${fmt(checkSideVal)}).",
          mathLinesLaTeX: [...step2Lines, ...step3Lines],
        ),
      ];

      return ProblemsInvolvingEquationsResult(
        mode: 1,
        finalAnswers: {
          "Formed Equation": eqPlain,
          "Cleared Equation":
          "$numExprPlain = ${formatLinearExprPlain(rhsScaledCoeff, rhsScaledConst, m)}",
          "Required Number ($m)": finalAnsFmt['plain']!,
          "Both Sides Equal": fmt(checkSideVal),
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: ProblemsInvolvingEquationsCanvasData(
          visualType: 1,
          lhsPanTitle: "Left-Hand Side (LHS)",
          lhsPanExpr: "($numExprPlain) / ${fmt(d)}",
          rhsPanTitle: "Right-Hand Side (RHS)",
          rhsPanExpr: rhsExprPlain,
          middleBridgeBadge:
          "Multiply Both Sides by ${fmt(d)} to Clear the Fraction",
          clearedBalanceBanner:
          "Cleared:  $numExprPlain = ${formatLinearExprPlain(rhsScaledCoeff, rhsScaledConst, m)}   ➔   $m = ${finalAnsFmt['plain']}",
          headerBadge:
          "Example 15 Two-Sided Fractional Equation:  $eqPlain",
          subBadge:
          "Clear fraction (×${fmt(d)})  ➔  Collect $m terms & constants  ➔  $m = ${finalAnsFmt['plain']}",
          bottomSummaryBanner:
          "Required Number:  $m = ${finalAnsFmt['plain']}   (LHS = RHS = ${fmt(checkSideVal)})",
        ),
      );
    } catch (e) {
      return ProblemsInvolvingEquationsResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid numbers in all fields.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: REAL-LIFE CLASS / GROUP RATIO, PARTITION & PERIMETER WORD PROBLEMS
  // Sub-Modes:
  // 0: Group Multiple / Additive Partition: x + (k*x + b) = Total (Ex 2.6 #6 Timi's Class!)
  // 1: Rectangle Perimeter Word Problem: 2(x + (k*x + b)) = Perimeter
  // ===========================================================================
  static ProblemsInvolvingEquationsResult solveRealLifePartitionProblem({
    required int subMode,
    required String varLetter,
    required String multiplierKStr, // e.g., 3 (three times as many)
    required String offsetBStr, // e.g., 0 (or +b more)
    required String totalGivenStr, // e.g., 28 students
    required String group1LabelStr,
    required String group2LabelStr,
  }) {
    try {
      final String x = varLetter.trim().isEmpty
          ? 'x'
          : varLetter.trim()[0].toLowerCase();
      final double? k =
      double.tryParse(multiplierKStr.trim().replaceAll('−', '-'));
      final double b =
          double.tryParse(offsetBStr.trim().replaceAll('−', '-')) ?? 0.0;
      final double? totalGiven =
      double.tryParse(totalGivenStr.trim().replaceAll('−', '-'));

      if (k == null || totalGiven == null || totalGiven <= 0) {
        throw const FormatException(
          "Please enter valid positive numbers for the multiple (k) and the total (e.g. k = 3 and Total = 28 for Ex 2.6 #6).",
        );
      }

      final String g1Name = group1LabelStr.trim().isEmpty
          ? "First Group (Do not wear glasses)"
          : group1LabelStr.trim();
      final String g2Name = group2LabelStr.trim().isEmpty
          ? "Second Group (Wear glasses)"
          : group2LabelStr.trim();

      final String g2ExprLaTeX = formatLinearExprLaTeX(k, b, x);
      final String g2ExprPlain = formatLinearExprPlain(k, b, x);

      // In Sub-Mode 0 (Group Sum): x + (k*x + b) = Total => (1 + k)x + b = Total
      // In Sub-Mode 1 (Rectangle Perimeter): 2(x + k*x + b) = Total => 2(1 + k)x + 2b = Total
      final double scaleMult = subMode == 1 ? 2.0 : 1.0;
      final double netCoeffX = scaleMult * (1.0 + k);
      final double netConstB = scaleMult * b;

      if (netCoeffX.abs() < 1e-12) {
        throw const FormatException("Total x-coefficient cannot be zero.");
      }

      final double rhsAfterB = totalGiven - netConstB;
      final double valGroup1 = rhsAfterB / netCoeffX;
      final double valGroup2 = k * valGroup1 + b;
      final Map<String, String> g1Fmt = formatRational(rhsAfterB, netCoeffX);

      final String eqSetupLaTeX = subMode == 0
          ? "$x + ${b.abs() < 1e-9 ? g2ExprLaTeX : '($g2ExprLaTeX)'} = ${fmt(totalGiven)}"
          : "2($x + $g2ExprLaTeX) = ${fmt(totalGiven)}";
      final String eqSetupPlain = subMode == 0
          ? "$x + ${b.abs() < 1e-9 ? g2ExprPlain : '($g2ExprPlain)'} = ${fmt(totalGiven)}"
          : "2($x + $g2ExprPlain) = ${fmt(totalGiven)}";

      final List<String> step1Lines = [
        "\\text{Let } $x \\text{ represent: ${g1Name.replaceAll('\\', '')}.}",
        "\\text{Then ${g2Name.replaceAll('\\', '')}} = \\mathbf{$g2ExprLaTeX}",
        subMode == 0
            ? "\\text{Total of both groups is } ${fmt(totalGiven)}, \\text{ i.e.}"
            : "\\text{Perimeter } P = 2(\\text{Breadth} + \\text{Length}) = ${fmt(totalGiven)}, \\text{ i.e.}",
        "\\mathbf{$eqSetupLaTeX}",
      ];

      final List<String> step2Lines = [
        eqSetupLaTeX,
        "\\text{Combine like terms in } $x:",
        "${formatLinearExprLaTeX(netCoeffX, netConstB, x)} = ${fmt(totalGiven)}",
        ...buildBalanceSolveLinesLaTeX(
          coeffA: netCoeffX,
          constB: netConstB,
          rhsC: totalGiven,
          varName: x,
        ),
      ];

      final List<String> step3Lines = [
        "\\bullet \\; \\text{${g1Name.replaceAll('\\', '')} } ($x) = \\mathbf{${g1Fmt['latex']}}",
        "\\bullet \\; \\text{${g2Name.replaceAll('\\', '')} } ($g2ExprLaTeX) = ${fmt(k)}(${fmt(valGroup1)})${b == 0 ? '' : (b > 0 ? ' + ${fmt(b)}' : ' - ${fmt(b.abs())}')} = \\mathbf{${fmt(valGroup2)}}",
        subMode == 0
            ? "\\text{Check Total: } ${fmt(valGroup1)} + ${fmt(valGroup2)} = \\mathbf{${fmt(totalGiven)}} \\quad (\\text{Verified!})"
            : "\\text{Check Perimeter: } 2(${fmt(valGroup1)} + ${fmt(valGroup2)}) = 2(${fmt(valGroup1 + valGroup2)}) = \\mathbf{${fmt(totalGiven)}} \\quad (\\text{Verified!})",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Represent Each Quantity in Terms of }} $x \\text{\\textbf{ (Exercise 2.6 \\#6)}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Step 2: Simplify and Solve the Equation Using the Balance Method}}",
        ...step2Lines,
        "",
        "\\text{\\textbf{Step 3: State Both Quantities and Verify the Total}}",
        ...step3Lines,
      ];

      final List<ProblemsInvolvingEquationsStep> steps = [
        ProblemsInvolvingEquationsStep(
          title:
          "Step 1: Represent Both Groups in Terms of '$x' and Form the Equation",
          description:
          "• Always let the smaller/base group ($g1Name) be $x.\n"
              "• Since the second group ($g2Name) is ${fmt(k)} times the first${b == 0 ? '' : (b > 0 ? ' plus ${fmt(b)}' : ' minus ${fmt(b.abs())}')}, it is written as $g2ExprPlain.\n"
              "• Combining them gives the equation: $eqSetupPlain.",
          mathLinesLaTeX: step1Lines,
        ),
        ProblemsInvolvingEquationsStep(
          title: "Step 2: Collect Like Terms and Solve by the Balance Method",
          description:
          "1. Add the $x-terms together: $eqSetupPlain simplifies to ${formatLinearExprPlain(netCoeffX, netConstB, x)} = ${fmt(totalGiven)}.\n"
              "2. Solve for $x to get $x = ${g1Fmt['plain']} ($g1Name) and $g2ExprPlain = ${fmt(valGroup2)} ($g2Name).",
          mathLinesLaTeX: [...step2Lines, ...step3Lines],
        ),
      ];

      final double sumParts =
      (valGroup1.abs() + valGroup2.abs()).clamp(1.0, 1e9);

      return ProblemsInvolvingEquationsResult(
        mode: 2,
        subMode: subMode,
        finalAnswers: {
          "Equation": eqSetupPlain,
          "$g1Name ($x)": g1Fmt['plain']!,
          "$g2Name ($g2ExprPlain)": fmt(valGroup2),
          "Total Check": fmt(totalGiven),
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: ProblemsInvolvingEquationsCanvasData(
          visualType: 2,
          group1Title: "$g1Name ($x)",
          group1Value: "$x = ${fmt(valGroup1)}",
          group1Proportion: (valGroup1.abs() / sumParts).clamp(0.18, 0.82),
          group2Title: "$g2Name ($g2ExprPlain)",
          group2Value: "$g2ExprPlain = ${fmt(valGroup2)}",
          group2Proportion: (valGroup2.abs() / sumParts).clamp(0.18, 0.82),
          totalGroupBanner:
          "Equation:  $eqSetupPlain   ➔   ${fmt(netCoeffX)}$x ${netConstB == 0 ? '' : (netConstB > 0 ? '+ ${fmt(netConstB)} ' : '− ${fmt(netConstB.abs())} ')}= ${fmt(totalGiven)}",
          headerBadge:
          "Partition Equation:  $eqSetupPlain   ➔   $x = ${g1Fmt['plain']}",
          subBadge:
          "$g1Name = ${fmt(valGroup1)}   |   $g2Name = ${fmt(valGroup2)}   |   Total = ${fmt(totalGiven)}",
          bottomSummaryBanner:
          "$g1Name = ${fmt(valGroup1)}   &   $g2Name = ${fmt(valGroup2)}",
        ),
      );
    } catch (e) {
      return ProblemsInvolvingEquationsResult.error(
        mode: 2,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid numbers in all fields.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: UNIVERSAL LINEAR EQUATION SOLVER & TEXTBOOK PALINDROME PUZZLE
  // Sub-Mode 0: Universal Free-Form Linear Equation Solver (with Balance Steps!)
  // Sub-Mode 1: Textbook Palindrome Puzzle (Page 28 Top Box: Smallest n * 12 = Palindrome)
  // ===========================================================================
  static Map<String, double> _parseLinearSideWithBrackets(
      String rawSide,
      String v,
      ) {
    String s = rawSide
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll('×', '*');

    // Expand any brackets k(a*v + b)
    final RegExp brkReg =
    RegExp(r'([+-]?\d*\.?\d*)\*?(\([^()]+\))');
    while (brkReg.hasMatch(s)) {
      s = s.replaceFirstMapped(brkReg, (Match m) {
        final String kStr = m.group(1) ?? '';
        final double k = (kStr.isEmpty || kStr == '+')
            ? 1.0
            : (kStr == '-' ? -1.0 : double.parse(kStr));
        final String inside =
        m.group(2)!.substring(1, m.group(2)!.length - 1);
        final Map<String, double> innerMap =
        _parseLinearSideWithBrackets(inside, v);
        final double na = k * innerMap['a']!;
        final double nb = k * innerMap['b']!;
        final List<String> terms = [];
        if (na.abs() > 1e-9) {
          terms.add('${na >= 0 ? '+' : ''}${fmt(na)}$v');
        }
        if (nb.abs() > 1e-9) {
          terms.add('${nb >= 0 ? '+' : ''}${fmt(nb)}');
        }
        return terms.isEmpty ? '+0' : terms.join('');
      });
    }

    s = s
        .replaceAll('--', '+')
        .replaceAll('+-', '-')
        .replaceAll('-', '+-');
    final List<String> chunks =
    s.split('+').where((c) => c.trim().isNotEmpty).toList();

    double a = 0.0;
    double b = 0.0;
    for (final String tok in chunks) {
      if (tok.contains(v)) {
        final String cStr = tok.replaceAll(v, '').replaceAll('*', '').trim();
        if (cStr.isEmpty || cStr == '+') {
          a += 1.0;
        } else if (cStr == '-') {
          a -= 1.0;
        } else {
          a += double.parse(cStr);
        }
      } else {
        b += double.parse(tok);
      }
    }
    return {'a': a, 'b': b};
  }

  static bool _isPalindromeNumber(int n) {
    final String s = n.abs().toString();
    if (s.length < 2) return true;
    final String rev = s.split('').reversed.join('');
    return s == rev;
  }

  static ProblemsInvolvingEquationsResult solveUniversalOrPalindromePuzzle({
    required int subMode, // 0: Universal Equation Solver, 1: Palindrome Puzzle (Page 28)
    required String rawEquationInput,
    required String palindromeMultiplierStr,
  }) {
    try {
      if (subMode == 1) {
        // Sub-Mode 1: Textbook Palindrome Puzzle (Page 28 Top Box!)
        // "A palindrome is a number that reads the same forwards and backwards. 22, 656, 2442 are palindromes.
        //  What is the smallest number (excluding zero) that you can multiply by 12 (or K) to get a palindrome?"
        final int? kMult = int.tryParse(palindromeMultiplierStr.trim());
        if (kMult == null || kMult <= 0 || kMult > 9999) {
          throw const FormatException(
            "Please enter a positive whole number multiplier (e.g. 12 as in the Page 28 Palindrome Puzzle).",
          );
        }

        int winningN = -1;
        int winningPalindrome = -1;
        final List<String> trialLinesLaTeX = [];
        final List<String> trialLinesPlain = [];

        for (int n = 1; n <= 5000; n++) {
          final int prod = n * kMult;
          final bool isPal = _isPalindromeNumber(prod);
          if (n <= 10 || isPal || (kMult == 12 && (n == 11 || n == 20 || n == 21))) {
            final String revStr = prod.toString().split('').reversed.join('');
            trialLinesLaTeX.add(
                "n = $n: \\quad $n \\times $kMult = \\mathbf{$prod} \\quad (\\text{Backwards} = $revStr \\implies \\text{${isPal ? '\\textbf{PALINDROME!}' : 'Not a palindrome'}})");
            trialLinesPlain.add(
                "• Try n = $n:  $n × $kMult = $prod  (Reads '$revStr' backwards ➔ ${isPal ? 'PALINDROME!' : 'No'})");
          }
          if (isPal) {
            winningN = n;
            winningPalindrome = prod;
            break;
          }
        }

        if (winningN == -1) {
          throw FormatException(
            "No palindrome multiple found for $kMult within the first 5,000 multiples (note: multiples of 10 always end in 0 and cannot start with 0!).",
          );
        }

        final List<String> workings = [
          "\\text{\\textbf{Step 1: Definition of a Palindrome (Page 28 Puzzle Box)}}",
          "\\text{A \\textbf{palindrome} is a number that reads the exact same forwards and backwards (e.g. } 22, \\; 252, \\; 656, \\; 2\\,442\\text{).}",
          "\\text{We want the smallest positive whole number } n \\text{ such that } n \\times $kMult \\text{ is a palindrome.}",
          "",
          "\\text{\\textbf{Step 2: Test Multiples of }} $kMult \\text{\\textbf{ Systematic Digit Analysis}}",
          if (kMult == 12) ...[
            "\\bullet \\text{ 2-digit palindromes are } 11, 22, 33, 44, 55, 66, 77, 88, 99. \\text{ None of these is divisible by } 12 \\text{ (since } 12 \\times 8 = 96\\text{).}",
            "\\bullet \\text{ Next, test 3-digit palindromes starting with } 1 \\text{ (like } 101, 111, \\dots\\text{): All are odd, so none is divisible by } 12!",
            "\\bullet \\text{ Next, test 3-digit palindromes starting with } 2 \\text{ (which are even: } 202, 212, 222, 232, 242, 252\\text{):}",
            "\\quad 252 \\div 12 = \\mathbf{21} \\text{ (exact whole number!)}",
          ],
          ...trialLinesLaTeX,
          "",
          "\\text{\\textbf{Step 3: Conclusion}}",
          "\\therefore \\; \\text{Smallest number } (n) = \\mathbf{$winningN} \\quad (\\text{since } $winningN \\times $kMult = \\mathbf{$winningPalindrome})",
        ];

        final List<ProblemsInvolvingEquationsStep> steps = [
          ProblemsInvolvingEquationsStep(
            title:
            "Step 1: Understand What a Palindrome Is (Page 28 Puzzle)",
            description:
            "• A palindrome is a number that reads the same forwards and backwards (such as 22, 252, 656, or 2 442).\n"
                "• We need the smallest positive number n (excluding 0) such that n × $kMult produces a palindrome.",
            mathLinesLaTeX: workings.sublist(1, 3),
          ),
          ProblemsInvolvingEquationsStep(
            title:
            "Step 2: Test Multiples of $kMult to Find the Smallest Palindrome",
            description:
            "${kMult == 12 ? '• No 2-digit palindrome (11, 22, ..., 99) is a multiple of 12.\n• Every 3-digit palindrome starting with 1 (1_1) ends in 1 (odd), so it cannot be a multiple of 12.\n• The smallest 3-digit palindrome divisible by 12 is 252, and 252 ÷ 12 = 21!\n\n' : ''}"
                "${trialLinesPlain.join('\n')}",
            mathLinesLaTeX: [
              ...trialLinesLaTeX,
              "\\therefore \\; \\mathbf{n = $winningN} \\quad ($winningN \\times $kMult = \\mathbf{$winningPalindrome})",
            ],
          ),
        ];

        return ProblemsInvolvingEquationsResult(
          mode: 3,
          subMode: 1,
          finalAnswers: {
            "Given Multiplier": "$kMult",
            "Smallest Number (n)": "$winningN",
            "Palindrome Product": "$winningN × $kMult = $winningPalindrome",
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: ProblemsInvolvingEquationsCanvasData(
            visualType: 1,
            lhsPanTitle: "Smallest Multiplier (n)",
            lhsPanExpr: "n = $winningN",
            rhsPanTitle: "Palindrome Result",
            rhsPanExpr: "$winningN × $kMult = $winningPalindrome",
            middleBridgeBadge:
            "Reads '$winningPalindrome' Forwards AND '$winningPalindrome' Backwards!",
            clearedBalanceBanner:
            "Equation:  $kMult × n = $winningPalindrome   ➔   n = $winningPalindrome ÷ $kMult = $winningN",
            headerBadge:
            "Page 28 Palindrome Puzzle:  $winningN × $kMult = $winningPalindrome",
            subBadge:
            "Smallest positive number is n = $winningN because $winningPalindrome is the smallest palindrome divisible by $kMult",
            bottomSummaryBanner:
            "Smallest Number = $winningN   (Gives Palindrome $winningPalindrome)",
          ),
        );
      }

      // Sub-Mode 0: Universal Free-Form Linear Equation Solver
      final String rawEq = rawEquationInput.trim();
      if (!rawEq.contains('=')) {
        throw const FormatException(
          "Please enter a linear equation containing '=' (e.g. 5x + 3 = 2, 4(n + 3) + 7 = 63, or (3m - 1) / 5 = 1 + m).",
        );
      }

      // Detect variable letter ('x', 'm', 'n', 'a', 'y', etc.)
      final Match? varM = RegExp(r'[a-zA-Z]').firstMatch(rawEq);
      final String v = varM != null ? varM.group(0)!.toLowerCase() : 'x';

      final List<String> sides = rawEq.split('=');
      if (sides.length != 2) {
        throw const FormatException("An equation can only have one '=' sign.");
      }

      String lhsRaw = sides[0].trim();
      String rhsRaw = sides[1].trim();
      double denFactor = 1.0;

      // Check if LHS has a top-level fraction `/ d` like `(3m - 1) / 5`
      final RegExp fracLhsReg = RegExp(r'^\(?([^/]+)\)?\s*\/\s*(\d+\.?\d*)$');
      final Match? fm = fracLhsReg.firstMatch(lhsRaw);
      if (fm != null) {
        lhsRaw = fm.group(1)!.trim();
        denFactor = double.parse(fm.group(2)!);
      }

      final Map<String, double> lhsMap =
      _parseLinearSideWithBrackets(lhsRaw, v);
      final Map<String, double> rhsMap =
      _parseLinearSideWithBrackets(rhsRaw, v);

      final double A = lhsMap['a']!;
      final double B = lhsMap['b']!;
      final double C = rhsMap['a']! * denFactor;
      final double D = rhsMap['b']! * denFactor;

      if ((A - C).abs() < 1e-12) {
        throw const FormatException(
          "The variable terms on both sides have equal coefficients, so there is no unique solution.",
        );
      }

      final List<String> solveLines = [
        "\\text{Given Equation:}",
        "\\mathbf{${rawEq.replaceAll('*', ' \\times ')}}",
      ];

      if (denFactor > 1.0) {
        solveLines.add(
            "\\text{Multiply both sides by } ${fmt(denFactor)} \\text{ to clear the fraction:}");
        solveLines.add(
            "${formatLinearExprLaTeX(A, B, v)} = ${formatLinearExprLaTeX(C, D, v)}");
      } else if (rawEq.contains('(')) {
        solveLines.add("\\text{Open the bracket and simplify:}");
        solveLines.add(
            "${formatLinearExprLaTeX(A, B, v)} = ${formatLinearExprLaTeX(C, D, v)}");
      }

      final double netA = A - C;
      if (C.abs() > 1e-9) {
        final String cTerm =
        (C.abs() - 1.0).abs() < 1e-9 ? v : "${fmt(C.abs())}$v";
        solveLines.add(
            "\\text{${C > 0 ? 'Subtract' : 'Add'} } $cTerm \\text{ ${C > 0 ? 'from' : 'to'} both sides:}");
        solveLines.add(
            "${formatLinearExprLaTeX(netA, B, v)} = ${fmt(D)}");
      }

      solveLines.addAll(buildBalanceSolveLinesLaTeX(
        coeffA: netA,
        constB: B,
        rhsC: D,
        varName: v,
      ));

      final Map<String, String> ansFmt = formatRational(D - B, netA);

      final List<String> workings = [
        "\\text{\\textbf{Unabridged Balance-Method Solution of }} ${rawEq.replaceAll('*', ' \\times ')}",
        ...solveLines,
      ];

      final List<ProblemsInvolvingEquationsStep> steps = [
        ProblemsInvolvingEquationsStep(
          title:
          "Step 1: Solve '$rawEq' Line-by-Line Using the Balance Method",
          description:
          "1. Clear any fractions or brackets first.\n"
              "2. Collect variable terms in '$v' and constant terms on opposite sides, writing every addition/subtraction/division applied to both sides.\n"
              "3. Solution: $v = ${ansFmt['plain']}.",
          mathLinesLaTeX: solveLines,
        ),
      ];

      return ProblemsInvolvingEquationsResult(
        mode: 3,
        subMode: 0,
        finalAnswers: {
          "Equation": rawEq,
          "Solution ($v)": ansFmt['plain']!,
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: ProblemsInvolvingEquationsCanvasData(
          visualType: 1,
          lhsPanTitle: "Left-Hand Side (LHS)",
          lhsPanExpr: sides[0].trim(),
          rhsPanTitle: "Right-Hand Side (RHS)",
          rhsPanExpr: sides[1].trim(),
          middleBridgeBadge:
          "Balance Rule: Do the Exact Same Operation to Both Sides",
          clearedBalanceBanner:
          "Simplified:  ${formatLinearExprPlain(netA, B, v)} = ${fmt(D)}   ➔   $v = ${ansFmt['plain']}",
          headerBadge:
          "Balance-Method Solver:  $rawEq   ➔   $v = ${ansFmt['plain']}",
          subBadge:
          "${formatLinearExprPlain(netA, B, v)} = ${fmt(D)}   ➔   ${fmt(netA)}$v = ${fmt(D - B)}   ➔   $v = ${ansFmt['plain']}",
          bottomSummaryBanner: "Solution:   $v = ${ansFmt['plain']}",
        ),
      );
    } catch (e) {
      return ProblemsInvolvingEquationsResult.error(
        mode: 3,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid linear equation (e.g. 4(n + 3) + 7 = 63).",
      );
    }
  }
}