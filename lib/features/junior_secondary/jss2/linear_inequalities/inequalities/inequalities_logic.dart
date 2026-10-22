import 'dart:math' as math;
import 'inequalities_models.dart';

class InequalitiesLogic {
  // ===========================================================================
  // TEXTBOOK PRESETS (Covers Exercises 22a, QR, 22b, 22c & Examples 1–4)
  // ===========================================================================
  static const List<InequalityPreset> textbookPresets = [
    InequalityPreset(
      chipLabel: "Ex 22a #3h: Compare (-5)² and (2)²",
      mode: 0,
      subMode: 0,
      lhsExpr: "(-5)^2",
      rhsExpr: "(2)^2",
    ),
    InequalityPreset(
      chipLabel: "Ex 22a #2h: True/False 30 > -50 + 20",
      mode: 0,
      subMode: 1,
      lhsExpr: "30",
      rhsExpr: "-50 + 20",
      claimSymbol: ">",
    ),
    InequalityPreset(
      chipLabel: "QR Box (n=3): 5n - n vs 7 + 2n",
      mode: 1,
      subMode: 0,
      varName: "n",
      varValue: "3",
      lhsExpr: "5n - n",
      rhsExpr: "7 + 2n",
    ),
    InequalityPreset(
      chipLabel: "QR Box #i (n=3): 1 - n² vs 21 - 10n",
      mode: 1,
      subMode: 0,
      varName: "n",
      varValue: "3",
      lhsExpr: "1 - n^2",
      rhsExpr: "21 - 10n",
    ),
    InequalityPreset(
      chipLabel: "Ex 1: Village Distance Over 18 km",
      mode: 2,
      subMode: 0,
      contextDescription: "Distance between two villages",
      varName: "d",
      phraseKey: "over",
      boundaryVal: "18",
      unit: "km",
    ),
    InequalityPreset(
      chipLabel: "Ex 22c #1f: Speed Never More Than 120 km/h",
      mode: 2,
      subMode: 0,
      contextDescription: "The speed of the car",
      varName: "v",
      phraseKey: "not_greater",
      boundaryVal: "120",
      unit: "km/h",
    ),
    InequalityPreset(
      chipLabel: "Ex 2: Spend ₦200 Out of x Naira (< ₦50 left)",
      mode: 2,
      subMode: 1,
      varName: "x",
      secondVal: "200",
      boundaryVal: "50",
      phraseKey: "less",
      unit: "₦",
    ),
    InequalityPreset(
      chipLabel: "Ex 22b #4: Saved Over ₦500 + ₦200 Gift",
      mode: 2,
      subMode: 2,
      varName: "y",
      boundaryVal: "500",
      secondVal: "200",
      phraseKey: "over",
      unit: "₦",
    ),
    InequalityPreset(
      chipLabel: "Ex 22b #6: x Goats on 3 ha (< 20 per ha)",
      mode: 2,
      subMode: 4,
      varName: "x",
      secondVal: "3",
      boundaryVal: "20",
      phraseKey: "less",
      unit: "goats",
    ),
    InequalityPreset(
      chipLabel: "Ex 4: Deborah (d) & Taiwo (t) ₦120 Notebook",
      mode: 3,
      subMode: 0,
      person1Name: "Deborah",
      person1Var: "d",
      person2Name: "Taiwo",
      person2Var: "t",
      boundaryVal: "120",
      itemLabel: "Notebook cost (₦)",
    ),
    InequalityPreset(
      chipLabel: "Ex 22c #3: Pass Mark 27 (x Failed, y Passed)",
      mode: 3,
      subMode: 0,
      person1Name: "First Candidate (Failed)",
      person1Var: "x",
      person2Name: "Second Candidate (Passed)",
      person2Var: "y",
      boundaryVal: "27",
      itemLabel: "Test Pass Mark",
    ),
    InequalityPreset(
      chipLabel: "Ex 3: Square Area < 25 cm² (Side & Perimeter)",
      mode: 4,
      subMode: 0,
      varName: "a",
      geoSymbol: "<",
      boundaryVal: "25",
      unit: "cm",
    ),
    InequalityPreset(
      chipLabel: "Ex 22b #8: Square Perimeter < 28 cm (Side & Area)",
      mode: 4,
      subMode: 1,
      varName: "a",
      geoSymbol: "<",
      boundaryVal: "28",
      unit: "cm",
    ),
    InequalityPreset(
      chipLabel: "Ex 22c #5: Circle Radius ≤ 3 m (In terms of π)",
      mode: 4,
      subMode: 2,
      varName: "r",
      geoSymbol: "<=",
      boundaryVal: "3",
      unit: "m",
    ),
  ];

  // ===========================================================================
  // REUSABLE FORMATTING & SYMBOL HELPERS
  // ===========================================================================
  static String fmt(double v, {int maxDecimals = 2}) {
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static String cleanTex(String s) {
    return s
        .replaceAll('\\', '')
        .replaceAll('{', '(')
        .replaceAll('}', ')')
        .replaceAll('\$', '')
        .replaceAll('&', ' and ')
        .replaceAll('%', '\\%')
        .replaceAll('_', ' ')
        .replaceAll('₦', 'N')
        .trim();
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
        return '<';
      default:
        return '=';
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

  static bool isInclusiveSymbol(String sym) {
    final String s = sym.trim();
    return s == '>=' || s == '<=' || s == '≥' || s == '≤' || s == '\\ge' || s == '\\le';
  }

  static bool isGreaterSymbol(String sym) {
    final String s = sym.trim();
    return s == '>' || s == '>=' || s == '≥' || s == '\\ge';
  }

  // ===========================================================================
  // UNIVERSAL ARITHMETIC & ALGEBRAIC SIDE EVALUATOR (Modes 0 & 1)
  // ===========================================================================
  static EvaluatedSide evaluateExpression(
      String rawInput, {
        String? varName,
        double? varValue,
      }) {
    final String orig = rawInput.trim();
    if (orig.isEmpty) {
      throw const FormatException("Expression cannot be empty.");
    }

    // Check if it is a pure single letter variable (e.g. "x", "a", "b" in Ex 22a #1e-j)
    if (varValue == null && RegExp(r'^[a-zA-Z]$').hasMatch(orig)) {
      return EvaluatedSide(
        rawExpression: orig,
        substitutedLatex: orig,
        intermediateLatex: orig,
        numericValue: 0,
        isPureVariable: true,
        variableSymbol: orig,
      );
    }

    String working = orig
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('²', '^2')
        .replaceAll('−', '-');

    String subLatex = orig
        .replaceAll('*', ' \\times ')
        .replaceAll('×', ' \\times ')
        .replaceAll('/', ' \\div ')
        .replaceAll('÷', ' \\div ')
        .replaceAll('²', '^2');

    // Perform variable substitution if varName and varValue are provided (Mode 1 QR Box)
    if (varName != null && varName.isNotEmpty && varValue != null) {
      final String v = RegExp.escape(varName.trim());
      final String valStr = fmt(varValue);
      final String wrapVal = varValue < 0 ? "($valStr)" : valStr;

      // Replace coefficient*var^2: e.g. 4n^2 -> 4*(3)^2
      working = working.replaceAllMapped(
        RegExp('(\\d+\\.?\\d*)\\s*$v\\^2'),
            (m) => '${m.group(1)}*($valStr)^2',
      );
      subLatex = subLatex.replaceAllMapped(
        RegExp('(\\d+\\.?\\d*)\\s*$v\\^2'),
            (m) => '${m.group(1)}($valStr)^2',
      );

      // Replace standalone var^2: e.g. n^2 -> (3)^2
      working = working.replaceAllMapped(
        RegExp('$v\\^2'),
            (_) => '($valStr)^2',
      );
      subLatex = subLatex.replaceAllMapped(
        RegExp('$v\\^2'),
            (_) => '($valStr)^2',
      );

      // Replace coefficient*var: e.g. 5n -> 5*3
      working = working.replaceAllMapped(
        RegExp('(\\d+\\.?\\d*)\\s*$v'),
            (m) => '${m.group(1)}*$wrapVal',
      );
      subLatex = subLatex.replaceAllMapped(
        RegExp('(\\d+\\.?\\d*)\\s*$v'),
            (m) => '${m.group(1)}($valStr)',
      );

      // Replace standalone var: e.g. n -> 3
      working = working.replaceAll(RegExp('\\b$v\\b'), wrapVal);
      subLatex = subLatex.replaceAll(RegExp('\\b$v\\b'), wrapVal);
    }

    // Step A: Evaluate any squares like (-5)^2, (2)^2, or 3^2
    String stepAfterPowers = working;
    stepAfterPowers = stepAfterPowers.replaceAllMapped(
      RegExp(r'\((-?\d+\.?\d*)\)\^2'),
          (m) {
        final double base = double.parse(m.group(1)!);
        return fmt(base * base, maxDecimals: 4);
      },
    );
    stepAfterPowers = stepAfterPowers.replaceAllMapped(
      RegExp(r'(\d+\.?\d*)\^2'),
          (m) {
        final double base = double.parse(m.group(1)!);
        return fmt(base * base, maxDecimals: 4);
      },
    );

    // Step B: Evaluate multiplications and divisions inside each additive term
    final String normalized = stepAfterPowers
        .replaceAll(' ', '')
        .replaceAll('+-', '-')
        .replaceAll('--', '+');

    final List<String> additiveChunks = [];
    String current = '';
    int depth = 0;
    for (int i = 0; i < normalized.length; i++) {
      final String ch = normalized[i];
      if (ch == '(') depth++;
      if (ch == ')') depth--;
      if ((ch == '+' || ch == '-') &&
          depth == 0 &&
          i > 0 &&
          normalized[i - 1] != '*' &&
          normalized[i - 1] != '/') {
        additiveChunks.add(current);
        current = ch;
      } else {
        current += ch;
      }
    }
    if (current.isNotEmpty) additiveChunks.add(current);

    final List<double> termValues = [];
    for (String chunk in additiveChunks) {
      String c = chunk.replaceAll('(', '').replaceAll(')', '');
      if (c.startsWith('+')) c = c.substring(1);

      if (c.contains('*')) {
        final List<String> factors = c.split('*');
        double prod = 1.0;
        for (final f in factors) {
          prod *= double.parse(f);
        }
        termValues.add(prod);
      } else if (c.contains('/')) {
        final List<String> parts = c.split('/');
        double quot = double.parse(parts[0]);
        for (int k = 1; k < parts.length; k++) {
          final double div = double.parse(parts[k]);
          if (div.abs() < 1e-12) {
            throw const FormatException("Division by zero is undefined.");
          }
          quot /= div;
        }
        termValues.add(quot);
      } else {
        termValues.add(double.parse(c));
      }
    }

    final double total = termValues.fold(0.0, (a, b) => a + b);
    final List<String> formattedTerms = [];
    for (int i = 0; i < termValues.length; i++) {
      final double tv = termValues[i];
      if (i == 0) {
        formattedTerms.add(fmt(tv));
      } else {
        formattedTerms.add(tv >= 0 ? "+ ${fmt(tv)}" : "- ${fmt(tv.abs())}");
      }
    }
    final String intermediate = formattedTerms.join(' ');

    return EvaluatedSide(
      rawExpression: orig,
      substitutedLatex: subLatex,
      intermediateLatex: intermediate,
      numericValue: total,
    );
  }

  // ===========================================================================
  // MODE 0: COMPARE QUANTITIES (`>` or `<`) & TRUE/FALSE STATEMENT CHECKER
  // Matches Exercise 22a #1, #2, #3
  // ===========================================================================
  static InequalityResult solveComparisonAndTruth({
    required int subMode, // 0: Fill in Box (> or <), 1: True (T) or False (F) Checker
    required String lhsStr,
    required String rhsStr,
    required String claimSymbol,
  }) {
    try {
      final EvaluatedSide lhs = evaluateExpression(lhsStr);
      final EvaluatedSide rhs = evaluateExpression(rhsStr);

      final List<String> workings = [];
      final List<InequalityStep> steps = [];
      final Map<String, String> answers = {};

      // Special Case: Comparing a Variable and a Number (Ex 22a #1e-j: e.g. "4 is greater than a")
      if (lhs.isPureVariable || rhs.isPureVariable) {
        final String sym = claimSymbol.trim().isEmpty ? '>' : claimSymbol.trim();
        final String revSym = reverseSymbol(sym);
        final String lRaw = lhs.rawExpression;
        final String rRaw = rhs.rawExpression;

        workings.add("\\text{\\textbf{Step 1: Translate Words into Inequality Symbol}}");
        workings.add(
            "\\text{Statement: } $lRaw \\; ${symbolToLaTeX(sym)} \\; $rRaw");
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 2: Equivalent Reversed Inequality (Ex 22a \\#1g–j)}}");
        workings.add(
            "$lRaw \\; ${symbolToLaTeX(sym)} \\; $rRaw \\quad \\Longleftrightarrow \\quad $rRaw \\; ${symbolToLaTeX(revSym)} \\; $lRaw");

        steps.add(InequalityStep(
          title: "Step 1: Write the Inequality Symbol",
          description:
          "Replace the words with the inequality symbol '${symbolToDisplay(sym)}':\n"
              "• $lRaw ${symbolToDisplay(sym)} $rRaw.",
          mathLaTeX: "$lRaw \\; ${symbolToLaTeX(sym)} \\; $rRaw",
        ));

        steps.add(InequalityStep(
          title: "Step 2: Write the Equivalent Reversed Form (Ex 22a #1g–j)",
          description:
          "Whenever you swap the left-hand side and the right-hand side of an inequality, you must also flip the inequality sign so it still points to the smaller quantity:\n"
              "• $lRaw ${symbolToDisplay(sym)} $rRaw is exactly the same as $rRaw ${symbolToDisplay(revSym)} $lRaw!",
          mathLaTeX:
          "$lRaw \\; ${symbolToLaTeX(sym)} \\; $rRaw \\iff $rRaw \\; ${symbolToLaTeX(revSym)} \\; $lRaw",
        ));

        answers["Inequality Statement"] =
        "$lRaw ${symbolToDisplay(sym)} $rRaw";
        answers["Equivalent Form"] =
        "$rRaw ${symbolToDisplay(revSym)} $lRaw";

        final double boundVal =
        lhs.isPureVariable ? rhs.numericValue : lhs.numericValue;
        final String effSym = lhs.isPureVariable ? sym : revSym;

        return InequalityResult(
          mode: 0,
          subMode: subMode,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          visualData: InequalityVisualData(
            visualType: 1,
            val1: boundVal,
            label1: lhs.isPureVariable ? lRaw : rRaw,
            symbol: symbolToDisplay(effSym),
            isInclusive: isInclusiveSymbol(effSym),
            pointsRight: isGreaterSymbol(effSym),
            headerBadge: "$lRaw ${symbolToDisplay(sym)} $rRaw",
            subBadge1: "Equivalent: $rRaw ${symbolToDisplay(revSym)} $lRaw",
          ),
        );
      }

      // Standard Numeric / Arithmetic Comparison
      final double lVal = lhs.numericValue;
      final double rVal = rhs.numericValue;
      final String actualSym = (lVal - rVal).abs() < 1e-9
          ? '='
          : (lVal > rVal ? '>' : '<');
      final String revActualSym = reverseSymbol(actualSym);

      workings.add(
          "\\text{\\textbf{Step 1: Evaluate the Left-Hand Side (LHS) and Right-Hand Side (RHS)}}");
      if (lhs.rawExpression != fmt(lVal)) {
        workings.add(
            "\\text{LHS} = ${lhs.substitutedLatex} = ${lhs.intermediateLatex} = ${fmt(lVal)}");
      } else {
        workings.add("\\text{LHS} = ${fmt(lVal)}");
      }
      if (rhs.rawExpression != fmt(rVal)) {
        workings.add(
            "\\text{RHS} = ${rhs.substitutedLatex} = ${rhs.intermediateLatex} = ${fmt(rVal)}");
      } else {
        workings.add("\\text{RHS} = ${fmt(rVal)}");
      }
      workings.add("");

      steps.add(InequalityStep(
        title: "Step 1: Evaluate Both Sides of the Statement",
        description:
        "First, simplify any arithmetic operations (+, −, ×, ÷, or exponents like (−5)² = +25) on both sides:\n"
            "• Left-Hand Side (LHS): ${lhs.rawExpression} = ${fmt(lVal)}.\n"
            "• Right-Hand Side (RHS): ${rhs.rawExpression} = ${fmt(rVal)}.",
        mathLaTeX:
        "\\text{LHS} = ${lhs.substitutedLatex} = ${fmt(lVal)}, \\quad \\text{RHS} = ${rhs.substitutedLatex} = ${fmt(rVal)}",
      ));

      final String dirExplain = lVal == rVal
          ? "${fmt(lVal)} and ${fmt(rVal)} are at the exact same point on the number line."
          : (lVal > rVal
          ? "On a horizontal number line, ${fmt(lVal)} lies to the RIGHT of ${fmt(rVal)}, so ${fmt(lVal)} is greater than ${fmt(rVal)} (${fmt(lVal)} > ${fmt(rVal)})."
          : "On a horizontal number line, ${fmt(lVal)} lies to the LEFT of ${fmt(rVal)}, so ${fmt(lVal)} is less than ${fmt(rVal)} (${fmt(lVal)} < ${fmt(rVal)}).");

      workings.add(
          "\\text{\\textbf{Step 2: Compare Positions on the Number Line}}");
      workings.add(
          "${fmt(lVal)} \\; ${symbolToLaTeX(actualSym)} \\; ${fmt(rVal)} \\quad \\left(\\text{or } ${fmt(rVal)} \\; ${symbolToLaTeX(revActualSym)} \\; ${fmt(lVal)}\\right)");

      steps.add(InequalityStep(
        title: "Step 2: Compare on the Horizontal Number Line",
        description:
        "Remember the Directed Numbers Rule: on a horizontal number line, any number to the RIGHT is greater than any number to its LEFT (for example, −1 > −5 and 0 > −2.4).\n"
            "• $dirExplain",
        mathLaTeX:
        "${fmt(lVal)} \\; ${symbolToLaTeX(actualSym)} \\; ${fmt(rVal)} \\implies ${lhs.substitutedLatex} \\; \\boxed{${symbolToLaTeX(actualSym)}} \\; ${rhs.substitutedLatex}",
      ));

      if (subMode == 0) {
        answers["Symbol in Box"] = actualSym;
        answers["Completed Statement"] =
        "${lhs.rawExpression} $actualSym ${rhs.rawExpression}";
        answers["Evaluated Values"] = "${fmt(lVal)} $actualSym ${fmt(rVal)}";
        if (actualSym != '=') {
          answers["Reversed Form"] =
          "${fmt(rVal)} $revActualSym ${fmt(lVal)}";
        }
      } else {
        // Sub-Mode 0B: Verify whether the given claim (e.g. 3 + 9 < 10 or 0 < 7 - 7) is True (T) or False (F)
        bool isTrue = false;
        switch (claimSymbol.trim()) {
          case '>':
            isTrue = lVal > rVal + 1e-9;
            break;
          case '<':
            isTrue = lVal < rVal - 1e-9;
            break;
          case '>=':
          case '≥':
            isTrue = lVal >= rVal - 1e-9;
            break;
          case '<=':
          case '≤':
            isTrue = lVal <= rVal + 1e-9;
            break;
          case '!=':
          case '≠':
            isTrue = (lVal - rVal).abs() > 1e-9;
            break;
        }

        final String verdict = isTrue ? "True (T)" : "False (F)";
        workings.add("");
        workings.add("\\text{\\textbf{Step 3: True (T) or False (F) Verdict}}");
        workings.add(
            "\\text{Claimed: } ${lhs.substitutedLatex} \\; ${symbolToLaTeX(claimSymbol)} \\; ${rhs.substitutedLatex} \\implies ${fmt(lVal)} \\; ${symbolToLaTeX(claimSymbol)} \\; ${fmt(rVal)} \\text{ is \\textbf{$verdict}}");

        steps.add(InequalityStep(
          title: "Step 3: Check If the Claimed Inequality is True or False",
          description:
          "The question claims that ${lhs.rawExpression} ${symbolToDisplay(claimSymbol)} ${rhs.rawExpression}, which simplifies to ${fmt(lVal)} ${symbolToDisplay(claimSymbol)} ${fmt(rVal)}.\n"
              "• Since the true relationship is ${fmt(lVal)} $actualSym ${fmt(rVal)}, the statement is $verdict!",
          mathLaTeX:
          "${fmt(lVal)} \\; ${symbolToLaTeX(claimSymbol)} \\; ${fmt(rVal)} \\rightarrow \\text{\\textbf{$verdict}} \\quad (\\text{Actual: } ${fmt(lVal)} \\; ${symbolToLaTeX(actualSym)} \\; ${fmt(rVal)})",
        ));

        answers["Verdict"] = verdict;
        answers["Simplified Claim"] =
        "${fmt(lVal)} ${symbolToDisplay(claimSymbol)} ${fmt(rVal)}";
        answers["True Relationship"] = "${fmt(lVal)} $actualSym ${fmt(rVal)}";
      }

      return InequalityResult(
        mode: 0,
        subMode: subMode,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        visualData: InequalityVisualData(
          visualType: 0,
          val1: lVal,
          val2: rVal,
          label1: "LHS = ${fmt(lVal)}",
          label2: "RHS = ${fmt(rVal)}",
          symbol: actualSym,
          headerBadge:
          "${lhs.rawExpression}  [ $actualSym ]  ${rhs.rawExpression}",
          subBadge1: "LHS = ${fmt(lVal)}   |   RHS = ${fmt(rVal)}",
        ),
      );
    } catch (e) {
      return InequalityResult.error(
        mode: 0,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid numbers or arithmetic expressions (e.g. (-5)^2, -50 + 20, or 29 / 7).",
      );
    }
  }

  // ===========================================================================
  // MODE 1: ALGEBRAIC SUBSTITUTION COMPARATOR (QR Box — Pages 190–191)
  // Put > or < in the box when n = 3
  // ===========================================================================
  static InequalityResult solveSubstitutionComparison({
    required String varName,
    required String varValueStr,
    required String lhsExprStr,
    required String rhsExprStr,
  }) {
    try {
      final String v = varName.trim().isEmpty ? 'n' : varName.trim();
      final double? val = double.tryParse(varValueStr.trim());
      if (val == null) {
        throw FormatException("Please enter a valid number for $v (e.g. 3).");
      }

      final EvaluatedSide lhs = evaluateExpression(
        lhsExprStr,
        varName: v,
        varValue: val,
      );
      final EvaluatedSide rhs = evaluateExpression(
        rhsExprStr,
        varName: v,
        varValue: val,
      );

      final double lVal = lhs.numericValue;
      final double rVal = rhs.numericValue;
      final String sym = (lVal - rVal).abs() < 1e-9
          ? '='
          : (lVal > rVal ? '>' : '<');

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Substitute }} $v = ${fmt(val)} \\text{\\textbf{ into the Left-Hand Side (LHS)}}",
        "\\text{LHS} = ${lhs.rawExpression.replaceAll('²', '^2')} = ${lhs.substitutedLatex} = ${lhs.intermediateLatex} = ${fmt(lVal)}",
        "",
        "\\text{\\textbf{Step 2: Substitute }} $v = ${fmt(val)} \\text{\\textbf{ into the Right-Hand Side (RHS)}}",
        "\\text{RHS} = ${rhs.rawExpression.replaceAll('²', '^2')} = ${rhs.substitutedLatex} = ${rhs.intermediateLatex} = ${fmt(rVal)}",
        "",
        "\\text{\\textbf{Step 3: Compare LHS and RHS Values}}",
        "\\text{Since } ${fmt(lVal)} \\; $sym \\; ${fmt(rVal)}, \\text{ put } \\boxed{$sym} \\text{ in the box:}",
        "${lhs.rawExpression.replaceAll('²', '^2')} \\; \\boxed{$sym} \\; ${rhs.rawExpression.replaceAll('²', '^2')} \\quad (\\text{when } $v = ${fmt(val)})",
      ];

      final List<InequalityStep> steps = [
        InequalityStep(
          title: "Step 1: Substitute $v = ${fmt(val)} into the Left Expression",
          description:
          "Replace every '$v' in '${lhs.rawExpression}' with ${fmt(val)}, evaluate powers and multiplications first, then add or subtract:\n"
              "• LHS = ${lhs.rawExpression} = ${lhs.intermediateLatex} = ${fmt(lVal)}.",
          mathLaTeX:
          "\\text{LHS} = ${lhs.substitutedLatex} = ${lhs.intermediateLatex} = ${fmt(lVal)}",
        ),
        InequalityStep(
          title: "Step 2: Substitute $v = ${fmt(val)} into the Right Expression",
          description:
          "Replace every '$v' in '${rhs.rawExpression}' with ${fmt(val)} and simplify step-by-step:\n"
              "• RHS = ${rhs.rawExpression} = ${rhs.intermediateLatex} = ${fmt(rVal)}.",
          mathLaTeX:
          "\\text{RHS} = ${rhs.substitutedLatex} = ${rhs.intermediateLatex} = ${fmt(rVal)}",
        ),
        InequalityStep(
          title: "Step 3: Compare ${fmt(lVal)} and ${fmt(rVal)} to Fill in the Box",
          description:
          "Compare the evaluated LHS (${fmt(lVal)}) with the evaluated RHS (${fmt(rVal)}) on the number line:\n"
              "• ${fmt(lVal)} $sym ${fmt(rVal)}.\n"
              "• Therefore, when $v = ${fmt(val)}, ${lhs.rawExpression} $sym ${rhs.rawExpression}.",
          mathLaTeX:
          "${fmt(lVal)} \\; $sym \\; ${fmt(rVal)} \\implies ${lhs.rawExpression.replaceAll('²', '^2')} \\; \\boxed{$sym} \\; ${rhs.rawExpression.replaceAll('²', '^2')}",
        ),
      ];

      return InequalityResult(
        mode: 1,
        subMode: 0,
        finalAnswers: {
          "When $v = ${fmt(val)}, LHS": fmt(lVal),
          "When $v = ${fmt(val)}, RHS": fmt(rVal),
          "Symbol in Box": sym,
          "Completed Statement": "${lhs.rawExpression} $sym ${rhs.rawExpression}",
        },
        workingsLaTeX: workings,
        steps: steps,
        visualData: InequalityVisualData(
          visualType: 0,
          val1: lVal,
          val2: rVal,
          label1: "LHS = ${fmt(lVal)}",
          label2: "RHS = ${fmt(rVal)}",
          symbol: sym,
          headerBadge:
          "When $v = ${fmt(val)}:  ${lhs.rawExpression}  [ $sym ]  ${rhs.rawExpression}",
          subBadge1: "LHS = ${fmt(lVal)}   |   RHS = ${fmt(rVal)}",
        ),
      );
    } catch (e) {
      return InequalityResult.error(
        mode: 1,
        subMode: 0,
        message: e is FormatException
            ? e.message
            : "Please check your algebraic expressions (e.g. 5n - n, 1 - n^2, 21 - 10n).",
      );
    }
  }

  // ===========================================================================
  // MODE 2: FROM WORDS TO ALGEBRAIC INEQUALITIES (Examples 1–2, Ex 22b, Ex 22c)
  // ===========================================================================
  static Map<String, String> getPhraseMetadata(String phraseKey) {
    switch (phraseKey) {
      case 'less':
        return {
          'phrase': 'is less than / under / below',
          'sym': '<',
          'latex': '<',
          'rule':
          "Strictly less than: the boundary value itself is NOT included.",
        };
      case 'over':
        return {
          'phrase': 'is greater than / over / more than / above',
          'sym': '>',
          'latex': '>',
          'rule':
          "Strictly greater than: the boundary value itself is NOT included.",
        };
      case 'not_greater':
        return {
          'phrase':
          'is not greater than / at most / or less / within limit / up to / never more than',
          'sym': '≤',
          'latex': '\\le',
          'rule':
          "'Not greater than k' means the value is either LESS than k (< k) OR EQUAL to k (= k). Combining both gives ≤ k.",
        };
      case 'not_less':
      default:
        return {
          'phrase':
          'is not less than / at least / or more / minimum / able to vote',
          'sym': '≥',
          'latex': '\\ge',
          'rule':
          "'Not less than k' means the value is either GREATER than k (> k) OR EQUAL to k (= k). Combining both gives ≥ k.",
        };
    }
  }

  static InequalityResult solveWordTranslation({
    required int subMode,
    // 0: Direct Statement (Ex 1, Ex 22b #1–2, Ex 22c #1–2)
    // 1: Spending / Remaining Money (Example 2: Have x, spend A, left < B)
    // 2: Savings + Additional Gift (Ex 22b #4: Saved > A, given B, total is y)
    // 3: Future / Past Age (Ex 22b #5: Now x years old, in A years will be > B)
    // 4: Multi-Item Load or Density per Hectare (Ex 22b #3, #6 & Ex 22c #2f)
    required String contextDesc,
    required String varName,
    required String phraseKey,
    required String boundaryValStr,
    required String secondValStr,
    required String unitStr,
    bool convertHoursToMinutes = false,
  }) {
    try {
      final String v = varName.trim().isEmpty ? 'x' : varName.trim();
      final double? rawBound = double.tryParse(boundaryValStr.trim());
      if (rawBound == null) {
        throw const FormatException("Please enter a valid boundary number.");
      }

      final Map<String, String> meta = getPhraseMetadata(phraseKey);
      final String symDisp = meta['sym']!;
      final String symTex = meta['latex']!;
      final String ruleExplain = meta['rule']!;
      final String u = unitStr.trim();
      final String cleanDesc = contextDesc.trim().isEmpty
          ? "the unknown quantity"
          : cleanTex(contextDesc);

      final List<String> workings = [];
      final List<InequalityStep> steps = [];
      final Map<String, String> answers = {};

      double finalThreshold = rawBound;

      if (subMode == 0) {
        // Direct Phrase Translation (with optional hours -> minutes conversion for Ex 22b #1h)
        if (convertHoursToMinutes) {
          finalThreshold = rawBound * 60.0;
          workings.add(
              "\\text{\\textbf{Step 1: Convert Units to Match the Unknown ($v min)}}");
          workings.add(
              "${fmt(rawBound)}\\text{ hours} = ${fmt(rawBound)} \\times 60\\text{ min} = ${fmt(finalThreshold)}\\text{ min}");
          workings.add("");

          steps.add(InequalityStep(
            title: "Step 1: Convert Hours to Minutes (Ex 22b #1h)",
            description:
            "Since the time $v is given in minutes (min), convert ${fmt(rawBound)} hours into minutes first (1 hour = 60 minutes):\n"
                "• ${fmt(rawBound)} × 60 = ${fmt(finalThreshold)} min.",
            mathLaTeX:
            "${fmt(rawBound)}\\text{ hours} = ${fmt(rawBound)} \\times 60 = ${fmt(finalThreshold)}\\text{ min}",
          ));
        }

        workings.add(
            "\\text{\\textbf{Step ${convertHoursToMinutes ? 2 : 1}: Choose a Letter for the Unknown}}");
        workings.add(
            "\\text{Let $cleanDesc be } $v${u.isNotEmpty ? '\\text{ ${cleanTex(u)}}' : ''}.");
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step ${convertHoursToMinutes ? 3 : 2}: Translate Key Phrase into Inequality Sign}}");
        workings.add("\\text{Key phrase meaning: } $symTex");
        workings.add(
            "\\text{Algebraic Inequality: } $v \\; $symTex \\; ${fmt(finalThreshold)}");

        steps.add(InequalityStep(
          title:
          "Step ${convertHoursToMinutes ? 2 : 1}: Define the Unknown Variable ($v)",
          description:
          "Let $cleanDesc be represented by the letter $v${u.isNotEmpty ? ' ($u)' : ''}.",
          mathLaTeX: "\\text{Unknown} = $v",
        ));

        steps.add(InequalityStep(
          title:
          "Step ${convertHoursToMinutes ? 3 : 2}: Translate the Words into an Algebraic Inequality",
          description:
          "• $ruleExplain\n"
              "• Combining the variable '$v', the symbol '$symDisp', and the boundary value ${fmt(finalThreshold)} gives: $v $symDisp ${fmt(finalThreshold)}.",
          mathLaTeX:
          "$v \\; $symTex \\; ${fmt(finalThreshold)} \\quad \\left(\\text{or } ${fmt(finalThreshold)} \\; ${symbolToLaTeX(reverseSymbol(symDisp))} \\; $v\\right)",
        ));

        answers["Algebraic Inequality"] = "$v $symDisp ${fmt(finalThreshold)}";
        answers["Reversed Form"] =
        "${fmt(finalThreshold)} ${symbolToDisplay(reverseSymbol(symDisp))} $v";
      } else if (subMode == 1) {
        // Example 2: I have x naira, I spend A naira, amount left is < B naira
        final double spent = double.tryParse(secondValStr.trim()) ?? 200.0;
        finalThreshold = spent + rawBound;

        workings.add(
            "\\text{\\textbf{Step 1: Express the Amount Left Algebraically (Example 2)}}");
        workings.add("\\text{Starting amount} = $v\\text{ naira}");
        workings.add(
            "\\text{After spending N}${fmt(spent)}, \\text{ amount left} = ($v - ${fmt(spent)})\\text{ naira}");
        workings.add("");
        workings.add("\\text{\\textbf{Step 2: Form the Inequality}}");
        workings.add("$v - ${fmt(spent)} \\; $symTex \\; ${fmt(rawBound)}");
        workings.add(
            "\\text{(Adding } ${fmt(spent)} \\text{ to both sides also shows } $v \\; $symTex \\; ${fmt(finalThreshold)}\\text{)}");

        steps.add(InequalityStep(
          title: "Step 1: Write the Expression for the Remaining Amount",
          description:
          "You start with $v naira and spend ₦${fmt(spent)}. Spending reduces the amount you have by ${fmt(spent)}, so the amount left is:\n"
              "• Amount left = $v − ${fmt(spent)}.",
          mathLaTeX: "\\text{Amount left} = $v - ${fmt(spent)}",
        ));

        steps.add(InequalityStep(
          title: "Step 2: Connect with the Inequality Sign ($symDisp)",
          description:
          "The problem states that the amount left ($v − ${fmt(spent)}) is '$symDisp ${fmt(rawBound)}':\n"
              "• Inequality: $v − ${fmt(spent)} $symDisp ${fmt(rawBound)}.",
          mathLaTeX: "$v - ${fmt(spent)} \\; $symTex \\; ${fmt(rawBound)}",
        ));

        answers["Textbook Inequality"] =
        "$v - ${fmt(spent)} $symDisp ${fmt(rawBound)}";
        answers["Simplified Bound"] = "$v $symDisp ${fmt(finalThreshold)}";
      } else if (subMode == 2) {
        // Ex 22b #4: A boy saved over ₦500. His father gave him ₦200. He now had ₦y altogether.
        final double gift = double.tryParse(secondValStr.trim()) ?? 200.0;
        finalThreshold = rawBound + gift;

        workings.add(
            "\\text{\\textbf{Step 1: Relate Total Money ($v) to Original Savings (Ex 22b \\#4)}}");
        workings.add(
            "\\text{Total money now} = $v \\quad ; \\quad \\text{Father's gift} = ${fmt(gift)}");
        workings.add(
            "\\text{Original savings before gift} = $v - ${fmt(gift)}");
        workings.add("");
        workings.add("\\text{\\textbf{Step 2: Write the Inequality in $v}}");
        workings.add(
            "$v - ${fmt(gift)} \\; $symTex \\; ${fmt(rawBound)} \\quad \\text{or} \\quad $v \\; $symTex \\; ${fmt(rawBound)} + ${fmt(gift)} \\implies $v \\; $symTex \\; ${fmt(finalThreshold)}");

        steps.add(InequalityStep(
          title: "Step 1: Add the Father's Gift to the Savings Threshold",
          description:
          "The boy originally saved $symDisp ₦${fmt(rawBound)}, and his father gave him another ₦${fmt(gift)} to make a total of ₦$v altogether:\n"
              "• Method A: Since his original savings ($v − ${fmt(gift)}) was $symDisp ${fmt(rawBound)}, we can write $v − ${fmt(gift)} $symDisp ${fmt(rawBound)}.\n"
              "• Method B: Adding the ₦${fmt(gift)} gift to ₦${fmt(rawBound)} gives ${fmt(rawBound)} + ${fmt(gift)} = ${fmt(finalThreshold)}, so $v $symDisp ${fmt(finalThreshold)}!",
          mathLaTeX:
          "$v \\; $symTex \\; ${fmt(rawBound)} + ${fmt(gift)} \\implies $v \\; $symTex \\; ${fmt(finalThreshold)}",
        ));

        answers["Inequality in $v"] = "$v $symDisp ${fmt(finalThreshold)}";
        answers["Subtraction Form"] =
        "$v - ${fmt(gift)} $symDisp ${fmt(rawBound)}";
      } else if (subMode == 3) {
        // Ex 22b #5: In 3 years' time, a girl will be over 18 years old. Now x years old.
        final double yearsAdded = double.tryParse(secondValStr.trim()) ?? 3.0;
        finalThreshold = rawBound - yearsAdded;

        workings.add(
            "\\text{\\textbf{Step 1: Express Age in ${fmt(yearsAdded)} Years' Time (Ex 22b \\#5)}}");
        workings.add("\\text{Present age} = $v\\text{ years}");
        workings.add(
            "\\text{Age in ${fmt(yearsAdded)} years' time} = ($v + ${fmt(yearsAdded)})\\text{ years}");
        workings.add("");
        workings.add("\\text{\\textbf{Step 2: Form the Inequality}}");
        workings.add(
            "$v + ${fmt(yearsAdded)} \\; $symTex \\; ${fmt(rawBound)} \\quad \\left(\\text{so } $v \\; $symTex \\; ${fmt(finalThreshold)}\\right)");

        steps.add(InequalityStep(
          title:
          "Step 1: Write Her Future Age in Terms of $v",
          description:
          "If the girl is $v years old now, then in ${fmt(yearsAdded)} years' time we add ${fmt(yearsAdded)} to her present age:\n"
              "• Future age = $v + ${fmt(yearsAdded)}.",
          mathLaTeX: "\\text{Age in ${fmt(yearsAdded)} years} = $v + ${fmt(yearsAdded)}",
        ));

        steps.add(InequalityStep(
          title: "Step 2: Form the Inequality",
          description:
          "In ${fmt(yearsAdded)} years' time she will be '$symDisp ${fmt(rawBound)}' years old:\n"
              "• $v + ${fmt(yearsAdded)} $symDisp ${fmt(rawBound)} (which also means her present age is $v $symDisp ${fmt(finalThreshold)}).",
          mathLaTeX: "$v + ${fmt(yearsAdded)} \\; $symTex \\; ${fmt(rawBound)}",
        ));

        answers["Future Age Inequality"] =
        "$v + ${fmt(yearsAdded)} $symDisp ${fmt(rawBound)}";
        answers["Present Age Bound"] = "$v $symDisp ${fmt(finalThreshold)}";
      } else {
        // Sub-Mode 4: Multi-Item Load / Density per Hectare (Ex 22b #3, #6 & Ex 22c #2f)
        final double countOrArea = double.tryParse(secondValStr.trim()) ?? 3.0;
        finalThreshold = countOrArea * rawBound;

        workings.add(
            "\\text{\\textbf{Step 1: Relate Total ($v) to the Per-Unit Bound (Ex 22b \\#3 \\& \\#6)}}");
        workings.add(
            "\\text{Number of units (lorries / hectares / cows)} = ${fmt(countOrArea)}");
        workings.add(
            "\\text{Bound for 1 unit} \\; $symTex \\; ${fmt(rawBound)}");
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 2: Form the Inequality for all ${fmt(countOrArea)} Units}}");
        workings.add(
            "\\frac{$v}{${fmt(countOrArea)}} \\; $symTex \\; ${fmt(rawBound)} \\quad \\Longleftrightarrow \\quad $v \\; $symTex \\; ${fmt(countOrArea)} \\times ${fmt(rawBound)} \\implies $v \\; $symTex \\; ${fmt(finalThreshold)}");

        steps.add(InequalityStep(
          title: "Step 1: Set Up the Per-Unit or Total Relationship",
          description:
          "There are ${fmt(countOrArea)} equal units (e.g. ${fmt(countOrArea)} lorries or ${fmt(countOrArea)} hectares), and each single unit is '$symDisp ${fmt(rawBound)}':\n"
              "• Division form (amount per 1 unit): $v / ${fmt(countOrArea)} $symDisp ${fmt(rawBound)}.\n"
              "• Multiplication form (total across all ${fmt(countOrArea)} units): $v $symDisp ${fmt(countOrArea)} × ${fmt(rawBound)} = ${fmt(finalThreshold)}.",
          mathLaTeX:
          "\\frac{$v}{${fmt(countOrArea)}} \\; $symTex \\; ${fmt(rawBound)} \\iff $v \\; $symTex \\; ${fmt(finalThreshold)}",
        ));

        answers["Total Inequality"] = "$v $symDisp ${fmt(finalThreshold)}";
        answers["Per-Unit Form"] =
        "$v/${fmt(countOrArea)} $symDisp ${fmt(rawBound)}";
      }

      return InequalityResult(
        mode: 2,
        subMode: subMode,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        visualData: InequalityVisualData(
          visualType: 1,
          val1: finalThreshold,
          label1: v,
          symbol: symDisp,
          isInclusive: isInclusiveSymbol(symDisp),
          pointsRight: isGreaterSymbol(symDisp),
          headerBadge: answers.values.first,
          subBadge1: ruleExplain,
        ),
      );
    } catch (e) {
      return InequalityResult.error(
        mode: 2,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please check your boundary numbers.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: TWO-PERSON THRESHOLD COMPARISON (Example 4 & Ex 22c #3–4)
  // ===========================================================================
  static InequalityResult solveTwoPersonThreshold({
    required String person1Name,
    required String person1Var,
    required String person2Name,
    required String person2Var,
    required String thresholdStr,
    required String itemLabel,
  }) {
    try {
      final double? k = double.tryParse(thresholdStr.trim());
      if (k == null || k <= 0) {
        throw const FormatException(
            "Enter a positive number for the cost or pass mark.");
      }

      final String p1 =
      person1Name.trim().isEmpty ? "Person 1" : person1Name.trim();
      final String v1 = person1Var.trim().isEmpty ? "d" : person1Var.trim();
      final String p2 =
      person2Name.trim().isEmpty ? "Person 2" : person2Name.trim();
      final String v2 = person2Var.trim().isEmpty ? "t" : person2Var.trim();
      final String kStr = fmt(k);

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Inequality for ${cleanTex(p1)} ($v1) — Below Threshold}}",
        "\\text{${cleanTex(p1)} does NOT have enough (or failed), so } $v1 \\text{ is strictly less than } $kStr:",
        "$v1 < $kStr",
        "",
        "\\text{\\textbf{Step 2: Inequality for ${cleanTex(p2)} ($v2) — Meets or Exceeds Threshold}}",
        "\\text{If ${cleanTex(p2)} has the exact amount (no change / exact pass mark), then } $v2 = $kStr.",
        "\\text{If ${cleanTex(p2)} has more than the threshold (gets change / above pass mark), then } $v2 > $kStr.",
        "\\text{Combining both possibilities gives:}",
        "$v2 \\ge $kStr",
        "",
        "\\text{\\textbf{Step 3: Compare $v1 and $v2 Directly (Example 4 Conclusion)}}",
        "\\text{Since } $v2 \\ge $kStr \\text{ and } $v1 < $kStr, \\text{ ${cleanTex(p2)} clearly has more than ${cleanTex(p1)}!}",
        "$v2 > $v1 \\quad \\text{or} \\quad $v1 < $v2",
      ];

      final List<InequalityStep> steps = [
        InequalityStep(
          title: "Step 1: Write the Inequality for $p1 ($v1)",
          description:
          "The question tells us that $p1 ($v1) does NOT have enough money to buy the item (or failed to reach the pass mark of $kStr). Therefore, $v1 is strictly less than $kStr:\n"
              "• $v1 < $kStr.",
          mathLaTeX: "$v1 < $kStr",
        ),
        InequalityStep(
          title: "Step 2: Write the Inequality for $p2 ($v2)",
          description:
          "$p2 ($v2) IS able to buy the item (or passed the test):\n"
              "• If $p2 gets no change (or scores the exact pass mark), then $v2 = $kStr.\n"
              "• If $p2 gets some change (or scores above the pass mark), then $v2 > $kStr.\n"
              "• Since we do not know which case happened, we combine '=' and '>' into 'greater than or equal to' (≥):\n"
              "  $v2 ≥ $kStr.",
          mathLaTeX: "$v2 = $kStr \\text{ or } $v2 > $kStr \\implies $v2 \\ge $kStr",
        ),
        InequalityStep(
          title: "Step 3: Compare $v1 and $v2 Directly (3 Inequalities in All)",
          description:
          "Finally, since $v2 is at least $kStr ($v2 ≥ $kStr) and $v1 is less than $kStr ($v1 < $kStr), $p2 clearly has more than $p1!\n"
              "• We can write this in two equivalent ways: $v2 > $v1 or $v1 < $v2.\n"
              "• Summary of the 3 different inequalities: (1) $v1 < $kStr, (2) $v2 ≥ $kStr, and (3) $v2 > $v1 (or $v1 < $v2).",
          mathLaTeX:
          "$v1 < $kStr, \\quad $v2 \\ge $kStr, \\quad $v2 > $v1 \\; (\\text{or } $v1 < $v2)",
        ),
      ];

      return InequalityResult(
        mode: 3,
        subMode: 0,
        finalAnswers: {
          "1. $p1 ($v1)": "$v1 < $kStr",
          "2. $p2 ($v2)": "$v2 ≥ $kStr",
          "3. Comparing Both": "$v2 > $v1 (or $v1 < $v2)",
        },
        workingsLaTeX: workings,
        steps: steps,
        visualData: InequalityVisualData(
          visualType: 2,
          val1: k,
          label1: "$v1 < $kStr ($p1)",
          label2: "$v2 ≥ $kStr ($p2)",
          symbol: "≥",
          headerBadge: "Threshold = $kStr  ➔  $v1 < $kStr  and  $v2 ≥ $kStr",
          subBadge1: "Therefore:  $v2 > $v1  (or  $v1 < $v2)",
        ),
      );
    } catch (e) {
      return InequalityResult.error(
        mode: 3,
        subMode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter a valid positive threshold value.",
      );
    }
  }

  // ===========================================================================
  // MODE 4: GEOMETRIC INEQUALITIES — SQUARES & CIRCLES
  // Matches Example 3, Ex 22b #7–8, and Ex 22c #5
  // ===========================================================================
  static InequalityResult solveGeometryBounds({
    required int subMode,
    // 0: Square Area -> Side (a) & Perimeter (4a) (Example 3 & Ex 22b #7)
    // 1: Square Perimeter -> Side (a) & Area (a²) (Ex 22b #8)
    // 2: Circle Radius -> Circumference (2πr) & Area (πr²) in terms of π (Ex 22c #5)
    required String varName,
    required String symStr,
    required String boundValStr,
    required String unitStr,
  }) {
    try {
      final double? bound = double.tryParse(boundValStr.trim());
      if (bound == null || bound <= 0) {
        throw const FormatException(
            "Enter a positive number for the geometric measurement.");
      }

      final String u = unitStr.trim().isEmpty ? "cm" : unitStr.trim();
      final String symDisp = symbolToDisplay(symStr);
      final String symTex = symbolToLaTeX(symStr);

      final List<String> workings = [];
      final List<InequalityStep> steps = [];
      final Map<String, String> answers = {};

      if (subMode == 0) {
        // Square Area -> Side (a) & Perimeter (4a) (Example 3 & Ex 22b #7)
        final String v = varName.trim().isEmpty ? 'a' : varName.trim();
        final double side = math.sqrt(bound);
        final double perim = 4.0 * side;

        workings.add(
            "\\text{\\textbf{Part (a): Length of One Side of the Square ($v $u)}}");
        workings.add(
            "\\text{Let the length of a side of the square be } $v\\text{ $u}.");
        workings.add("\\text{Area of square} = $v^2\\text{ $u}^2");
        workings.add("$v^2 \\; $symTex \\; ${fmt(bound)}");
        workings.add(
            "\\sqrt{$v^2} \\; $symTex \\; \\sqrt{${fmt(bound)}} \\implies $v \\; $symTex \\; ${fmt(side)}");
        workings.add(
            "\\text{The length of one side is $symDisp ${fmt(side)} $u.}");
        workings.add("");
        workings.add("\\text{\\textbf{Part (b): Perimeter of the Square (4$v)}}");
        workings.add("\\text{Perimeter} = 4$v");
        workings.add("\\text{Since } $v \\; $symTex \\; ${fmt(side)}:");
        workings.add(
            "4$v \\; $symTex \\; 4 \\times ${fmt(side)} \\implies \\text{Perimeter} \\; $symTex \\; ${fmt(perim)}\\text{ $u}");

        steps.add(InequalityStep(
          title: "Step 1: Take the Square Root of the Area to Find Side ($v)",
          description:
          "1. Let the length of one side of the square be $v $u.\n"
              "2. Since the area of a square is $v² and the area is $symDisp ${fmt(bound)} $u², we write: $v² $symDisp ${fmt(bound)}.\n"
              "3. Take the positive square root of both sides: √($v²) $symDisp √${fmt(bound)} → $v $symDisp ${fmt(side)} $u.",
          mathLaTeX:
          "$v^2 \\; $symTex \\; ${fmt(bound)} \\implies \\sqrt{$v^2} \\; $symTex \\; \\sqrt{${fmt(bound)}} \\implies $v \\; $symTex \\; ${fmt(side)}\\text{ $u}",
        ));

        steps.add(InequalityStep(
          title: "Step 2: Multiply by 4 to Find the Perimeter Bound (4$v)",
          description:
          "A square has 4 equal sides, so its perimeter is 4$v:\n"
              "• Since $v $symDisp ${fmt(side)}, multiply both sides by 4:\n"
              "  4$v $symDisp 4 × ${fmt(side)} → Perimeter $symDisp ${fmt(perim)} $u.",
          mathLaTeX:
          "\\text{Perimeter} = 4$v \\; $symTex \\; 4 \\times ${fmt(side)} = ${fmt(perim)}\\text{ $u}",
        ));

        answers["Given Area"] = "Area $symDisp ${fmt(bound)} $u²";
        answers["a) Side Length ($v)"] = "$v $symDisp ${fmt(side)} $u";
        answers["b) Perimeter (4$v)"] =
        "Perimeter $symDisp ${fmt(perim)} $u";

        return InequalityResult(
          mode: 4,
          subMode: 0,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          visualData: InequalityVisualData(
            visualType: 3,
            val1: side,
            val2: perim,
            symbol: symDisp,
            headerBadge: "Square: Area $symDisp ${fmt(bound)} $u²",
            subBadge1: "Side $v $symDisp ${fmt(side)} $u",
            subBadge2: "Perimeter 4$v $symDisp ${fmt(perim)} $u",
          ),
        );
      } else if (subMode == 1) {
        // Ex 22b #8: Square Perimeter -> Side (a) & Area (a²)
        final String v = varName.trim().isEmpty ? 'a' : varName.trim();
        final double side = bound / 4.0;
        final double area = side * side;

        workings.add(
            "\\text{\\textbf{Part (a): Length of One Side of the Square ($v $u)}}");
        workings.add(
            "\\text{Let the length of one side of the square be } $v\\text{ $u}.");
        workings.add("\\text{Perimeter} = 4$v \\; $symTex \\; ${fmt(bound)}");
        workings.add(
            "$v \\; $symTex \\; \\frac{${fmt(bound)}}{4} \\implies $v \\; $symTex \\; ${fmt(side)}\\text{ $u}");
        workings.add("");
        workings.add("\\text{\\textbf{Part (b): Area of the Square ($v^2)}}");
        workings.add("\\text{Area} = $v^2");
        workings.add(
            "\\text{Since } $v \\; $symTex \\; ${fmt(side)}, \\quad $v^2 \\; $symTex \\; ${fmt(side)}^2 \\implies \\text{Area} \\; $symTex \\; ${fmt(area)}\\text{ $u}^2");

        steps.add(InequalityStep(
          title: "Step 1: Divide the Perimeter by 4 to Find Side ($v)",
          description:
          "1. Let the side of the square be $v $u, so Perimeter = 4$v.\n"
              "2. Since 4$v $symDisp ${fmt(bound)}, divide both sides by 4:\n"
              "   $v $symDisp ${fmt(bound)} ÷ 4 → $v $symDisp ${fmt(side)} $u.",
          mathLaTeX:
          "4$v \\; $symTex \\; ${fmt(bound)} \\implies $v \\; $symTex \\; \\frac{${fmt(bound)}}{4} = ${fmt(side)}\\text{ $u}",
        ));

        steps.add(InequalityStep(
          title: "Step 2: Square the Side Length to Find the Area Bound ($v²)",
          description:
          "The area of a square is side × side ($v²):\n"
              "• Since $v $symDisp ${fmt(side)}, square both sides:\n"
              "  $v² $symDisp ${fmt(side)}² → Area $symDisp ${fmt(area)} $u².",
          mathLaTeX:
          "\\text{Area} = $v^2 \\; $symTex \\; ${fmt(side)}^2 = ${fmt(area)}\\text{ $u}^2",
        ));

        answers["Given Perimeter"] = "Perimeter $symDisp ${fmt(bound)} $u";
        answers["a) Side Length ($v)"] = "$v $symDisp ${fmt(side)} $u";
        answers["b) Area ($v²)"] = "Area $symDisp ${fmt(area)} $u²";

        return InequalityResult(
          mode: 4,
          subMode: 1,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          visualData: InequalityVisualData(
            visualType: 3,
            val1: side,
            val2: area,
            symbol: symDisp,
            headerBadge: "Square: Perimeter $symDisp ${fmt(bound)} $u",
            subBadge1: "Side $v $symDisp ${fmt(side)} $u",
            subBadge2: "Area $v² $symDisp ${fmt(area)} $u²",
          ),
        );
      } else {
        // Ex 22c #5: Circle Radius -> Circumference (2πr) & Area (πr²) in terms of π
        final String v = varName.trim().isEmpty ? 'r' : varName.trim();
        final double twoR = 2.0 * bound;
        final double rSq = bound * bound;

        workings.add(
            "\\text{\\textbf{Step 1: Radius Inequality ($v $u)}}");
        workings.add("$v \\; $symTex \\; ${fmt(bound)}\\text{ $u}");
        workings.add("");
        workings.add(
            "\\text{\\textbf{Part (a): Circumference of the Circle in Terms of }}\\pi");
        workings.add("\\text{Circumference } (C) = 2\\pi $v");
        workings.add(
            "\\text{Since } $v \\; $symTex \\; ${fmt(bound)}, \\quad C \\; $symTex \\; 2 \\times \\pi \\times ${fmt(bound)} \\implies C \\; $symTex \\; ${fmt(twoR)}\\pi\\text{ $u}");
        workings.add("");
        workings.add(
            "\\text{\\textbf{Part (b): Area of the Circle in Terms of }}\\pi");
        workings.add("\\text{Area } (A) = \\pi $v^2");
        workings.add(
            "\\text{Since } $v \\; $symTex \\; ${fmt(bound)}, \\quad A \\; $symTex \\; \\pi \\times ${fmt(bound)}^2 \\implies A \\; $symTex \\; ${fmt(rSq)}\\pi\\text{ $u}^2");

        steps.add(InequalityStep(
          title: "Step 1: Write the Radius Inequality ($v $symDisp ${fmt(bound)} $u)",
          description:
          "Let the radius of the circle be $v $u. For example, in Exercise 22c #5, 'not greater than ${fmt(bound)} $u' means $v ≤ ${fmt(bound)} $u.",
          mathLaTeX: "$v \\; $symTex \\; ${fmt(bound)}\\text{ $u}",
        ));

        steps.add(InequalityStep(
          title: "Step 2: Find the Circumference Bound in Terms of π (C = 2π$v)",
          description:
          "The circumference of a circle is C = 2π$v:\n"
              "• Since $v $symDisp ${fmt(bound)}, substitute ${fmt(bound)} for $v:\n"
              "  C $symDisp 2 × π × ${fmt(bound)} = ${fmt(twoR)}π $u.",
          mathLaTeX:
          "C = 2\\pi $v \\; $symTex \\; 2 \\times \\pi \\times ${fmt(bound)} = ${fmt(twoR)}\\pi\\text{ $u}",
        ));

        steps.add(InequalityStep(
          title: "Step 3: Find the Area Bound in Terms of π (A = π$v²)",
          description:
          "The area of a circle is A = π$v²:\n"
              "• Since $v $symDisp ${fmt(bound)}, square the radius (${fmt(bound)}² = ${fmt(rSq)}) and multiply by π:\n"
              "  A $symDisp π × ${fmt(bound)}² = ${fmt(rSq)}π $u².",
          mathLaTeX:
          "A = \\pi $v^2 \\; $symTex \\; \\pi \\times ${fmt(bound)}^2 = ${fmt(rSq)}\\pi\\text{ $u}^2",
        ));

        answers["Radius ($v)"] = "$v $symDisp ${fmt(bound)} $u";
        answers["a) Circumference (C)"] = "C $symDisp ${fmt(twoR)}π $u";
        answers["b) Area (A)"] = "A $symDisp ${fmt(rSq)}π $u²";

        return InequalityResult(
          mode: 4,
          subMode: 2,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          visualData: InequalityVisualData(
            visualType: 3,
            val1: bound,
            val2: rSq,
            label1: "circle",
            symbol: symDisp,
            headerBadge: "Circle: Radius $v $symDisp ${fmt(bound)} $u",
            subBadge1: "Circumference C $symDisp ${fmt(twoR)}π $u",
            subBadge2: "Area A $symDisp ${fmt(rSq)}π $u²",
          ),
        );
      }
    } catch (e) {
      return InequalityResult.error(
        mode: 4,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid positive number.",
      );
    }
  }
}