import 'expansion_models.dart';

/// Helper model for an algebraic monomial term (e.g., -14a, 21b, 6x^2, 30).
class _Monomial {
  final double coeff;
  final Map<String, int> varPowers; // Variable letters to integer powers

  const _Monomial({
    required this.coeff,
    required this.varPowers,
  });

  static _Monomial parse(String raw) {
    String s = raw
        .trim()
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3');
    if (s.isEmpty) return const _Monomial(coeff: 0, varPowers: {});

    double sign = 1.0;
    if (s.startsWith('-')) {
      sign = -1.0;
      s = s.substring(1);
    } else if (s.startsWith('+')) {
      s = s.substring(1);
    }

    final RegExp numPrefix = RegExp(r'^(\d+\.?\d*)');
    final Match? nm = numPrefix.firstMatch(s);
    double c = 1.0;
    String rem = s;
    if (nm != null) {
      c = double.parse(nm.group(1)!);
      rem = s.substring(nm.end);
    }

    final Map<String, int> vp = {};
    final RegExp varPowerReg = RegExp(r'([a-zA-Z])(?:\^(\d+))?');
    for (final Match m in varPowerReg.allMatches(rem)) {
      final String v = m.group(1)!;
      final int p = int.tryParse(m.group(2) ?? '1') ?? 1;
      vp[v] = (vp[v] ?? 0) + p;
    }

    return _Monomial(coeff: sign * c, varPowers: vp);
  }

  _Monomial multiply(_Monomial other) {
    final Map<String, int> newPowers = Map.from(varPowers);
    other.varPowers.forEach((k, v) {
      newPowers[k] = (newPowers[k] ?? 0) + v;
    });
    return _Monomial(
      coeff: coeff * other.coeff,
      varPowers: newPowers,
    );
  }

  String toPlainString({bool withSign = false}) {
    if (coeff.abs() < 1e-9) return withSign ? '+ 0' : '0';
    final String cStr = _formatNum(coeff.abs());
    final StringBuffer sb = StringBuffer();
    final bool hasVars = varPowers.isNotEmpty;

    if (coeff < 0) {
      sb.write(withSign ? '- ' : '-');
    } else if (withSign) {
      sb.write('+ ');
    }

    if (!hasVars || (coeff.abs() - 1.0).abs() > 1e-9) {
      sb.write(cStr);
    }

    final List<String> sortedVars = varPowers.keys.toList()..sort();
    for (final v in sortedVars) {
      final int p = varPowers[v]!;
      sb.write(v);
      if (p > 1) sb.write('^$p');
    }
    return sb.toString().trim();
  }

  String toLaTeXString({bool withSign = false}) {
    if (coeff.abs() < 1e-9) return withSign ? '+ 0' : '0';
    final String cStr = _formatNum(coeff.abs());
    final StringBuffer sb = StringBuffer();
    final bool hasVars = varPowers.isNotEmpty;

    if (coeff < 0) {
      sb.write(withSign ? '- ' : '-');
    } else if (withSign) {
      sb.write('+ ');
    }

    if (!hasVars || (coeff.abs() - 1.0).abs() > 1e-9) {
      sb.write(cStr);
    }

    final List<String> sortedVars = varPowers.keys.toList()..sort();
    for (final v in sortedVars) {
      final int p = varPowers[v]!;
      sb.write(v);
      if (p > 1) sb.write('^{$p}');
    }
    return sb.toString().trim();
  }

  String get signature {
    final List<String> sortedVars = varPowers.keys.toList()..sort();
    final StringBuffer sb = StringBuffer();
    for (final v in sortedVars) {
      sb.write('$v^${varPowers[v]};');
    }
    return sb.toString();
  }

  static String _formatNum(double v) {
    if ((v - v.roundToDouble()).abs() < 1e-9) return v.round().toString();
    return v
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}

class ExpansionLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 65 & 71: Example 1, Ex 7.1 Parts A & B, Rev Ex 7 Part A)
  // ===========================================================================
  static const List<ExpansionPreset> textbookPresets = [
    ExpansionPreset(
      chipLabel: "Example 1a (Page 65): 6(2a + 5)",
      mode: 0,
      input1: '6',
      input2: '2a + 5',
    ),
    ExpansionPreset(
      chipLabel: "Example 1b (Page 65): -5(m + 3) (Negative Outside)",
      mode: 0,
      input1: '-5',
      input2: 'm + 3',
    ),
    ExpansionPreset(
      chipLabel: "Example 1c (Page 65): -7(2a - 3b) (Negative × Negative)",
      mode: 0,
      input1: '-7',
      input2: '2a - 3b',
    ),
    ExpansionPreset(
      chipLabel: "Ex 7.1 Part A #5: 2x(x - 2y + z) (3-Term Bracket)",
      mode: 0,
      input1: '2x',
      input2: 'x - 2y + z',
    ),
    ExpansionPreset(
      chipLabel: "Rev Ex 7 Part A #3: 6(5x² - 2x - 6)",
      mode: 0,
      input1: '6',
      input2: '5x^2 - 2x - 6',
    ),
    ExpansionPreset(
      chipLabel: "Rev Ex 7 Part A #4: -2(4x - 3x²z)",
      mode: 0,
      input1: '-2',
      input2: '4x - 3x^2z',
    ),
    ExpansionPreset(
      chipLabel: "Rev Ex 7 Part A #9: ab(a²b - ab²)",
      mode: 0,
      input1: 'ab',
      input2: 'a^2b - ab^2',
    ),
    ExpansionPreset(
      chipLabel: "Ex 7.1 Part B #1: (2a + 4) + (a + 3)",
      mode: 1,
      input1: '2a + 4',
      input2: 'a + 3',
    ),
    ExpansionPreset(
      chipLabel: "Ex 7.1 Part B #2: 6(y + 3) + 2(y + 5)",
      mode: 1,
      input1: '6(y + 3)',
      input2: '2(y + 5)',
    ),
    ExpansionPreset(
      chipLabel: "Ex 7.1 Part B #4: 5(a - 2) - (3 - a)",
      mode: 1,
      input1: '5(a - 2)',
      input2: '-(3 - a)',
    ),
    ExpansionPreset(
      chipLabel: "Ex 7.1 Part B #5: 4(x + 2) - 3(x - 4)",
      mode: 1,
      input1: '4(x + 2)',
      input2: '-3(x - 4)',
    ),
    ExpansionPreset(
      chipLabel: "Ex 7.1 Part B #9: c(c - 2) + 3c(c - 3)",
      mode: 1,
      input1: 'c(c - 2)',
      input2: '3c(c - 3)',
    ),
    ExpansionPreset(
      chipLabel: "Ex 7.1 Part B #11: 7e(d + 2) - d(3e + 3)",
      mode: 1,
      input1: '7e(d + 2)',
      input2: '-d(3e + 3)',
    ),
    ExpansionPreset(
      chipLabel: "Ex 7.1 Part B #6: 9 - 2(3r - 1) (BODMAS Warning!)",
      mode: 2,
      input1: '9',
      input2: '-2',
      input3: '3r - 1',
    ),
    ExpansionPreset(
      chipLabel: "Ex 7.1 Part B #7: 5b(b - 1) - 7b²",
      mode: 2,
      input1: '-7b^2',
      input2: '5b',
      input3: 'b - 1',
    ),
    ExpansionPreset(
      chipLabel: "Ex 7.1 Part B #8: 5xy - 3x(y - 2)",
      mode: 2,
      input1: '5xy',
      input2: '-3x',
      input3: 'y - 2',
    ),
  ];

  // ===========================================================================
  // POLYNOMIAL SPLITTING, FORMATTING & LIKE-TERM COMBINATION HELPERS
  // ===========================================================================
  static List<_Monomial> _parsePolynomialTerms(String rawInside) {
    final String s = rawInside
        .trim()
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll('--', '+')
        .replaceAll('+-', '-')
        .replaceAll('-', '+-');

    final List<String> chunks =
    s.split('+').where((c) => c.trim().isNotEmpty).toList();
    if (chunks.isEmpty) {
      throw const FormatException(
        "Please enter at least one algebraic term (e.g. 2a + 5 or 2a - 3b).",
      );
    }
    return chunks.map(_Monomial.parse).toList();
  }

  static String _formatPolynomialLaTeX(List<_Monomial> terms) {
    final List<_Monomial> nonZero =
    terms.where((t) => t.coeff.abs() > 1e-9).toList();
    if (nonZero.isEmpty) return '0';
    final List<String> parts = [];
    for (int i = 0; i < nonZero.length; i++) {
      parts.add(nonZero[i].toLaTeXString(withSign: i > 0));
    }
    return parts.join(' ');
  }

  static String _formatPolynomialPlain(List<_Monomial> terms) {
    final List<_Monomial> nonZero =
    terms.where((t) => t.coeff.abs() > 1e-9).toList();
    if (nonZero.isEmpty) return '0';
    final List<String> parts = [];
    for (int i = 0; i < nonZero.length; i++) {
      parts.add(nonZero[i].toPlainString(withSign: i > 0));
    }
    return parts.join(' ');
  }

  /// Combines like terms (matching variable power signatures) while preserving order of appearance
  static List<_Monomial> _combineLikeTerms(List<_Monomial> terms) {
    final Map<String, double> sumCoeffs = {};
    final Map<String, Map<String, int>> sigToVars = {};
    final List<String> order = [];

    for (final _Monomial t in terms) {
      final String sig = t.signature;
      if (!sumCoeffs.containsKey(sig)) {
        sumCoeffs[sig] = 0.0;
        sigToVars[sig] = t.varPowers;
        order.add(sig);
      }
      sumCoeffs[sig] = sumCoeffs[sig]! + t.coeff;
    }

    final List<_Monomial> combined = [];
    for (final String sig in order) {
      final double c = sumCoeffs[sig]!;
      if (c.abs() > 1e-9) {
        combined.add(_Monomial(coeff: c, varPowers: sigToVars[sig]!));
      }
    }
    return combined.isEmpty
        ? [const _Monomial(coeff: 0, varPowers: {})]
        : combined;
  }

  /// Builds the Textbook Area-Box Expansion Table in LaTeX (preparing students for Example 3 on Page 67!)
  static String _buildAreaBoxLaTeX(
      _Monomial outside,
      List<_Monomial> insideTerms,
      List<_Monomial> products,
      ) {
    final String colSpec = List.filled(insideTerms.length + 1, 'c').join('|');
    final List<String> topHeaders = [];
    final List<String> boxCells = [];

    for (int i = 0; i < insideTerms.length; i++) {
      topHeaders.add(insideTerms[i].toLaTeXString(withSign: i > 0));
      boxCells.add("\\mathbf{${products[i].toLaTeXString(withSign: i > 0)}}");
    }

    return "\\begin{array}{$colSpec} "
        "\\times & ${topHeaders.join(' & ')} \\\\ \\hline "
        "\\mathbf{${outside.toLaTeXString()}} & ${boxCells.join(' & ')} \\\\ \\hline "
        "\\end{array}";
  }

  // ===========================================================================
  // MODE 0: MULTIPLY OUT A SINGLE BRACKET A(B ± C ± D)
  // Replicates Example 1(a–c) on Page 65 Word-for-Word!
  // Covers Exercise 7.1 Part A (#1–16) & Revision Exercise 7 Part A (#1–10)
  // ===========================================================================
  static ExpansionResult solveSingleBracketExpansion({
    required String outsideFactorStr,
    required String insideBracketStr,
  }) {
    try {
      String outRaw = outsideFactorStr.trim();
      String inRaw = insideBracketStr.trim();

      // Allow user to enter full expression like "-7(2a - 3b)" in the first field if the second is empty
      if (inRaw.isEmpty && outRaw.contains('(') && outRaw.contains(')')) {
        final int openIdx = outRaw.indexOf('(');
        final int closeIdx = outRaw.lastIndexOf(')');
        inRaw = outRaw.substring(openIdx + 1, closeIdx).trim();
        outRaw = outRaw.substring(0, openIdx).trim();
        if (outRaw.isEmpty || outRaw == '+') outRaw = '1';
        if (outRaw == '-') outRaw = '-1';
      }

      if (outRaw.isEmpty || inRaw.isEmpty) {
        throw const FormatException(
          "Please enter both the outside multiplier (e.g. 6, -5, -7, or 2x) and the expression inside the bracket (e.g. 2a + 5 or 2a - 3b).",
        );
      }

      final _Monomial outTerm = _Monomial.parse(outRaw);
      final List<_Monomial> inTerms = _parsePolynomialTerms(inRaw);
      final List<_Monomial> products =
      inTerms.map((t) => outTerm.multiply(t)).toList();

      final String outLaTeX = (outTerm.coeff == 1 && outTerm.varPowers.isEmpty)
          ? ""
          : ((outTerm.coeff == -1 && outTerm.varPowers.isEmpty)
          ? "-"
          : outTerm.toLaTeXString());
      final String insideLaTeX = _formatPolynomialLaTeX(inTerms);
      final String givenExprLaTeX = "$outLaTeX($insideLaTeX)";

      // Build Example 1's exact intermediate lines!
      // Line 1: 6(2a + 5) = 6 × 2a + 6 × 5  (or -7(2a - 3b) = -7 × 2a - (-7) × (3b))
      final List<String> multPairsLaTeX = [];
      final List<String> signedBracketPairsLaTeX = [];
      final List<String> termByTermPlain = [];

      final String outWrapLaTeX = outTerm.coeff < 0
          ? "(${outTerm.toLaTeXString()})"
          : outTerm.toLaTeXString();

      for (int i = 0; i < inTerms.length; i++) {
        final _Monomial t = inTerms[i];
        final _Monomial prod = products[i];

        if (i == 0) {
          multPairsLaTeX.add(
              "${outTerm.toLaTeXString()} \\times ${t.coeff < 0 ? '(${t.toLaTeXString()})' : t.toLaTeXString()}");
          signedBracketPairsLaTeX.add(prod.toLaTeXString());
        } else {
          if (t.coeff >= 0) {
            multPairsLaTeX
                .add("+ $outWrapLaTeX \\times (${t.toLaTeXString()})");
            signedBracketPairsLaTeX.add(prod.coeff < 0
                ? "+ (${prod.toLaTeXString()})"
                : "+ ${prod.toLaTeXString()}");
          } else {
            // Matching Example 1c: - (-7) × (3b) = - (-21b) = + 21b!
            final _Monomial absT =
            _Monomial(coeff: t.coeff.abs(), varPowers: t.varPowers);
            final _Monomial prodWithAbs = outTerm.multiply(absT);
            multPairsLaTeX
                .add("- $outWrapLaTeX \\times (${absT.toLaTeXString()})");
            signedBracketPairsLaTeX.add(prodWithAbs.coeff < 0
                ? "- (${prodWithAbs.toLaTeXString()})"
                : "- ${prodWithAbs.toLaTeXString()}");
          }
        }

        final String signRuleNote = (outTerm.coeff < 0 && t.coeff < 0)
            ? " [since (−) × (−) = (+)]"
            : ((outTerm.coeff < 0 || t.coeff < 0)
            ? " [since (+) × (−) = (−)]"
            : "");
        termByTermPlain.add(
            "• Term ${i + 1}: (${outTerm.toPlainString()}) × (${t.toPlainString()}) = ${prod.toPlainString(withSign: true)}$signRuleNote");
      }

      final List<_Monomial> finalCombined = _combineLikeTerms(products);
      final String finalLaTeX = _formatPolynomialLaTeX(finalCombined);
      final String areaBoxLaTeX =
      _buildAreaBoxLaTeX(outTerm, inTerms, products);

      final bool hasNegativeSignFlip =
          outTerm.coeff < 0 || inTerms.any((t) => t.coeff < 0);

      final List<String> step1Lines = [
        "\\text{Rule (Page 65): An expression of the form } $givenExprLaTeX \\text{ means } ${outTerm.toLaTeXString()} \\text{ times each term inside } ($insideLaTeX):",
        "$givenExprLaTeX = ${multPairsLaTeX.join(' ')}",
        if (hasNegativeSignFlip) "= ${signedBracketPairsLaTeX.join(' ')}",
        "= \\mathbf{$finalLaTeX}",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Multiply Every Term Inside the Bracket by }} \\mathbf{${outTerm.toLaTeXString()}} \\text{\\textbf{ (Example 1, Page 65)}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Step 2: Area-Box Expansion Check}}",
        areaBoxLaTeX,
      ];

      final List<ExpansionStep> steps = [
        ExpansionStep(
          title:
          "Step 1: Multiply '${outTerm.toPlainString()}' by Each Term Inside the Bracket (Example 1)",
          description:
          "• Multiply the outside factor (${outTerm.toPlainString()}) by every term inside the bracket one by one, paying careful attention to the directed-number sign rules and laws of indices:\n\n"
              "${termByTermPlain.join('\n')}",
          mathLinesLaTeX: step1Lines,
        ),
        ExpansionStep(
          title: "Step 2: Visual Area-Box Verification",
          description:
          "Placing '${outTerm.toPlainString()}' on the left of an expansion box and each bracket term along the top confirms that the expanded expression is ${_formatPolynomialPlain(finalCombined)}.",
          mathLinesLaTeX: [
            areaBoxLaTeX,
            "\\therefore \\; $givenExprLaTeX = \\mathbf{$finalLaTeX}",
          ],
        ),
      ];

      return ExpansionResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Given Expression": givenExprLaTeX,
          "Expanded Form": "\\mathbf{$finalLaTeX}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: ExpansionCanvasData(
          headerLaTeX:
          "\\text{Example 1 Multiplying Out Brackets: } $givenExprLaTeX = \\mathbf{$finalLaTeX}",
          subHeaderLaTeX:
          "\\text{Sign Rules: } (+) \\times (-) = (-) \\quad | \\quad (-) \\times (-) = (+)",
          card1Title: "Outside Multiplier",
          card1LaTeX: outTerm.toLaTeXString(),
          card2Title: "Inside Bracket",
          card2LaTeX: insideLaTeX,
          card3Title: "Expanded Result",
          card3LaTeX: "\\mathbf{$finalLaTeX}",
          areaBoxLaTeX: areaBoxLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $givenExprLaTeX = \\mathbf{$finalLaTeX}",
        ),
      );
    } catch (e) {
      return ExpansionResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter valid algebraic terms.",
      );
    }
  }

  // ===========================================================================
  // MODES 1, 2 & 3: EXPAND AND SIMPLIFY MULTI-BRACKET & STANDALONE EXPRESSIONS
  // Covers Exercise 7.1 Part B (#1–12 on Page 65):
  //   - Two brackets: 6(y + 3) + 2(y + 5), 5(a - 2) - (3 - a), 7e(d + 2) - d(3e + 3)
  //   - Standalone + Bracket: 9 - 2(3r - 1), 5b(b - 1) - 7b^2, 5xy - 3x(y - 2)
  // ===========================================================================
  static ExpansionResult solveMultiBracketOrStandalone({
    required int mode,
    required String rawFullExpression,
  }) {
    try {
      String expr = rawFullExpression
          .trim()
          .replaceAll('−', '-')
          .replaceAll('²', '^2')
          .replaceAll('³', '^3');

      if (expr.isEmpty) {
        throw const FormatException(
          "Please enter an algebraic expression with brackets to expand and simplify (e.g. 6(y + 3) + 2(y + 5), 5(a - 2) - (3 - a), or 9 - 2(3r - 1)).",
        );
      }

      // Split top-level chunks (outside parentheses)
      final List<String> topChunks = [];
      int depth = 0;
      String current = '';
      for (int i = 0; i < expr.length; i++) {
        final String ch = expr[i];
        if (ch == '(') depth++;
        if (ch == ')') depth--;
        if (depth == 0 && (ch == '+' || ch == '-') && current.trim().isNotEmpty) {
          topChunks.add(current.trim());
          current = ch;
        } else {
          current += ch;
        }
      }
      if (current.trim().isNotEmpty) {
        topChunks.add(current.trim());
      }

      final List<_Monomial> allExpandedTerms = [];
      final List<String> chunkExpansionLinesLaTeX = [];
      final List<String> chunkExpansionPlain = [];
      final List<String> givenChunksLaTeX = [];

      for (final String chunk in topChunks) {
        final String cClean = chunk.replaceAll(' ', '');
        if (cClean.contains('(') && cClean.contains(')')) {
          final int openIdx = cClean.indexOf('(');
          final int closeIdx = cClean.lastIndexOf(')');
          String outPart = cClean.substring(0, openIdx).trim();
          final String inPart = cClean.substring(openIdx + 1, closeIdx).trim();

          if (outPart.isEmpty || outPart == '+') outPart = '+1';
          if (outPart == '-') outPart = '-1';

          final _Monomial outMono = _Monomial.parse(outPart);
          final List<_Monomial> inMonos = _parsePolynomialTerms(inPart);
          final List<_Monomial> prods =
          inMonos.map((m) => outMono.multiply(m)).toList();
          allExpandedTerms.addAll(prods);

          final String outDisp = (outMono.coeff == 1 && outMono.varPowers.isEmpty)
              ? "+"
              : ((outMono.coeff == -1 && outMono.varPowers.isEmpty)
              ? "-"
              : outMono.toLaTeXString(withSign: true));
          final String inDisp = _formatPolynomialLaTeX(inMonos);
          final String chunkInputLaTeX = "$outDisp($inDisp)"
              .replaceFirst(RegExp(r'^\+\s*'), '');
          givenChunksLaTeX.add(
              givenChunksLaTeX.isEmpty ? chunkInputLaTeX : "$outDisp($inDisp)");

          final String prodsLaTeX = _formatPolynomialLaTeX(prods);
          chunkExpansionLinesLaTeX.add(
              "\\bullet \\text{ Expand } $chunkInputLaTeX = \\mathbf{$prodsLaTeX}");
          chunkExpansionPlain.add(
              "• Expand ${chunk.trim()}: multiply each inside term by ${outMono.toPlainString()} to get ${_formatPolynomialPlain(prods)}.");
        } else {
          final _Monomial singleMono = _Monomial.parse(cClean);
          allExpandedTerms.add(singleMono);
          givenChunksLaTeX.add(singleMono.toLaTeXString(
              withSign: givenChunksLaTeX.isNotEmpty));
        }
      }

      final String fullGivenLaTeX = givenChunksLaTeX.join(' ');
      final List<String> allUncombinedParts = [];
      for (int i = 0; i < allExpandedTerms.length; i++) {
        allUncombinedParts
            .add(allExpandedTerms[i].toLaTeXString(withSign: i > 0));
      }
      final String uncombinedLineLaTeX = allUncombinedParts.join(' ');

      // Group like terms together visually before adding them!
      final Map<String, List<_Monomial>> groupedBySig = {};
      final List<String> sigOrder = [];
      for (final _Monomial m in allExpandedTerms) {
        final String sig = m.signature;
        if (!groupedBySig.containsKey(sig)) {
          groupedBySig[sig] = [];
          sigOrder.add(sig);
        }
        groupedBySig[sig]!.add(m);
      }

      final List<_Monomial> reorderedLikeTerms = [];
      for (final String sig in sigOrder) {
        reorderedLikeTerms.addAll(groupedBySig[sig]!);
      }
      final List<String> reorderedParts = [];
      for (int i = 0; i < reorderedLikeTerms.length; i++) {
        reorderedParts
            .add(reorderedLikeTerms[i].toLaTeXString(withSign: i > 0));
      }
      final String groupedLineLaTeX = reorderedParts.join(' ');

      final List<_Monomial> simplifiedTerms =
      _combineLikeTerms(allExpandedTerms);
      final String finalSimplifiedLaTeX =
      _formatPolynomialLaTeX(simplifiedTerms);

      final List<String> step1Lines = [
        "\\text{Given expression: } \\mathbf{$fullGivenLaTeX}",
        ...chunkExpansionLinesLaTeX,
        "\\text{Write all expanded terms together:}",
        "= $uncombinedLineLaTeX",
      ];

      final List<String> step2Lines = [
        if (groupedLineLaTeX != uncombinedLineLaTeX) ...[
          "\\text{Collect like terms together:}",
          "= $groupedLineLaTeX",
        ],
        "\\text{Simplify like terms:}",
        "= \\mathbf{$finalSimplifiedLaTeX}",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Multiply Out the Bracket(s) First (BODMAS — Exercise 7.1 Part B)}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Step 2: Collect and Simplify Like Terms}}",
        ...step2Lines,
      ];

      final List<ExpansionStep> steps = [
        ExpansionStep(
          title:
          "Step 1: Multiply Out Each Bracket First (BODMAS Rule)",
          description:
          "• Remember BODMAS: always multiply out the brackets FIRST before adding or subtracting any standalone terms outside the brackets!\n\n"
              "${chunkExpansionPlain.join('\n')}",
          mathLinesLaTeX: step1Lines,
        ),
        ExpansionStep(
          title: "Step 2: Group Like Terms and Simplify",
          description:
          "Group terms with the exact same letter(s) and power(s) together and combine their coefficients to get ${_formatPolynomialPlain(simplifiedTerms)}.",
          mathLinesLaTeX: step2Lines,
        ),
      ];

      return ExpansionResult(
        mode: mode,
        finalAnswersLaTeX: {
          "Given Expression": fullGivenLaTeX,
          "Expanded Terms": uncombinedLineLaTeX,
          "Simplified Answer": "\\mathbf{$finalSimplifiedLaTeX}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: ExpansionCanvasData(
          headerLaTeX:
          "\\text{Expand \\& Simplify (Exercise 7.1 Part B): } $fullGivenLaTeX = \\mathbf{$finalSimplifiedLaTeX}",
          subHeaderLaTeX:
          "\\text{Step 1 (Expand Brackets): } $uncombinedLineLaTeX \\quad \\longrightarrow \\quad \\text{Step 2 (Combine Like Terms): } \\mathbf{$finalSimplifiedLaTeX}",
          card1Title: "1. Given Expression",
          card1LaTeX: fullGivenLaTeX,
          card2Title: "2. Expanded Terms",
          card2LaTeX: uncombinedLineLaTeX,
          card3Title: "3. Simplified Result",
          card3LaTeX: "\\mathbf{$finalSimplifiedLaTeX}",
          areaBoxLaTeX:
          "$fullGivenLaTeX = $uncombinedLineLaTeX = \\mathbf{$finalSimplifiedLaTeX}",
          bottomSummaryLaTeX:
          "\\therefore \\; $fullGivenLaTeX = \\mathbf{$finalSimplifiedLaTeX}",
        ),
      );
    } catch (e) {
      return ExpansionResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid bracketed algebraic expression.",
      );
    }
  }
}