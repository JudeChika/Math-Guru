import 'quadratic_factorisation_models.dart';

/// Exact Rational Number Engine for Quadratic Factorisation (handles integer and fractional coefficients!)
class _FFrac {
  final int num;
  final int den;

  const _FFrac(this.num, [this.den = 1]);

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

  static int lcm(int a, int b) => (a == 0 || b == 0) ? 1 : (a.abs() * b.abs()) ~/ gcd(a, b);

  factory _FFrac.from(int n, [int d = 1]) {
    if (d == 0) throw const FormatException("Denominator cannot be zero.");
    if (n == 0) return const _FFrac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _FFrac(sign * (an ~/ g), ad ~/ g);
  }

  factory _FFrac.parse(String raw) {
    String s = raw.trim().replaceAll(' ', '').replaceAll('−', '-');
    if (s.isEmpty || s == '+') return const _FFrac(1, 1);
    if (s == '-') return const _FFrac(-1, 1);

    int sign = 1;
    if (s.startsWith('-')) {
      sign = -1;
      s = s.substring(1);
    } else if (s.startsWith('+')) {
      s = s.substring(1);
    }
    if (s.isEmpty) return _FFrac(sign, 1);

    if (s.contains('/')) {
      final List<String> parts = s.split('/');
      if (parts.length != 2) {
        throw FormatException("Invalid fraction '$raw'.");
      }
      return _FFrac.from(sign * int.parse(parts[0]), int.parse(parts[1]));
    }

    if (s.contains('.')) {
      final List<String> parts = s.split('.');
      int d = 1;
      for (int i = 0; i < parts[1].length; i++) {
        d *= 10;
      }
      final int n = int.parse(parts[0]) * d + int.parse(parts[1]);
      return _FFrac.from(sign * n, d);
    }

    return _FFrac.from(sign * int.parse(s), 1);
  }

  bool get isZero => num == 0;
  bool get isNegative => num < 0;

  _FFrac abs() => _FFrac(num.abs(), den);
  _FFrac operator +(_FFrac other) =>
      _FFrac.from(num * other.den + other.num * den, den * other.den);

  String toLaTeX({bool withSign = false}) {
    if (num == 0) return withSign ? '+ 0' : '0';
    final String signStr =
    num < 0 ? (withSign ? '- ' : '-') : (withSign ? '+ ' : '');
    final int an = num.abs();
    if (den == 1) return '$signStr$an';
    return '$signStr\\frac{$an}{$den}';
  }

  String toPlain({bool withSign = false}) {
    if (num == 0) return withSign ? '+ 0' : '0';
    final String signStr =
    num < 0 ? (withSign ? '- ' : '-') : (withSign ? '+ ' : '');
    final int an = num.abs();
    if (den == 1) return '$signStr$an';
    return '$signStr$an/$den';
  }
}

class QuadraticFactorisationLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 74–75 Example 3 & Ex 8.3, Page 79 Quantitative, Page 80 Rev Ex 8)
  // ===========================================================================
  static const List<QuadraticFactorisationPreset> textbookPresets = [
    QuadraticFactorisationPreset(
      chipLabel: "Example 3a (Page 74): x² + 8x + 12",
      mode: 0,
      exprInput: 'x^2 + 8x + 12',
    ),
    QuadraticFactorisationPreset(
      chipLabel: "Example 3b (Page 74): x² - 4x - 12",
      mode: 0,
      exprInput: 'x^2 - 4x - 12',
    ),
    QuadraticFactorisationPreset(
      chipLabel: "Example 3c (Page 74): x² + 2x - 3",
      mode: 0,
      exprInput: 'x^2 + 2x - 3',
    ),
    QuadraticFactorisationPreset(
      chipLabel: "Example 3d (Page 75): 3x² - 10x + 3",
      mode: 0,
      exprInput: '3x^2 - 10x + 3',
    ),
    QuadraticFactorisationPreset(
      chipLabel: "Example 3e (Page 75): 5x² - 11x + 2",
      mode: 0,
      exprInput: '5x^2 - 11x + 2',
    ),
    QuadraticFactorisationPreset(
      chipLabel: "Ex 8.3 #10 (Page 75): z² + 3z - 10",
      mode: 0,
      exprInput: 'z^2 + 3z - 10',
    ),
    QuadraticFactorisationPreset(
      chipLabel: "Ex 8.3 #17 (Page 75): 4t² + t - 3",
      mode: 0,
      exprInput: '4t^2 + t - 3',
    ),
    QuadraticFactorisationPreset(
      chipLabel: "Ex 8.3 #18 (Page 75): 4u² - 11u - 3",
      mode: 0,
      exprInput: '4u^2 - 11u - 3',
    ),
    QuadraticFactorisationPreset(
      chipLabel: "Ex 8.3 #21 (Page 75): 3b² + 10b + 8",
      mode: 0,
      exprInput: '3b^2 + 10b + 8',
    ),
    QuadraticFactorisationPreset(
      chipLabel: "Ex 8.3 #23 (Page 75): 4x - 1 - 3x² (Scrambled Order)",
      mode: 0,
      exprInput: '4x - 1 - 3x^2',
    ),
    QuadraticFactorisationPreset(
      chipLabel: "Ex 8.3 #27 (Page 75): 6a² + 16a - 6 (With Common Factor)",
      mode: 0,
      exprInput: '6a^2 + 16a - 6',
    ),
    QuadraticFactorisationPreset(
      chipLabel: "Ex 8.3 #28 (Page 75): 14y² - 21y - 14",
      mode: 0,
      exprInput: '14y^2 - 21y - 14',
    ),
    QuadraticFactorisationPreset(
      chipLabel: "Ex 8.3 #30 (Page 75): 2p² - 11p + 15",
      mode: 0,
      exprInput: '2p^2 - 11p + 15',
    ),
    QuadraticFactorisationPreset(
      chipLabel: "Quantitative Sample 1 (Page 79): x² - 3x - 28",
      mode: 0,
      exprInput: 'x^2 - 3x - 28',
    ),
    QuadraticFactorisationPreset(
      chipLabel: "Quantitative Sample 2 (Page 79): 2x² + 7x + 3",
      mode: 0,
      exprInput: '2x^2 + 7x + 3',
    ),
    QuadraticFactorisationPreset(
      chipLabel: "Rev Ex 8 Part C #3 (Page 80): 7m² + 22m + 3",
      mode: 0,
      exprInput: '7m^2 + 22m + 3',
    ),
  ];

  static String _formatTermLaTeX(int coeff, String varPart, {bool isFirst = false}) {
    if (coeff == 0) return isFirst ? '0' : '+ 0';
    final String sign = coeff < 0 ? (isFirst ? '-' : '- ') : (isFirst ? '' : '+ ');
    final int ac = coeff.abs();
    if (varPart.isEmpty) return '$sign$ac';
    if (ac == 1) return '$sign$varPart';
    return '$sign$ac$varPart';
  }

  static String _formatTermPlain(int coeff, String varPart, {bool isFirst = false}) {
    return _formatTermLaTeX(coeff, varPart, isFirst: isFirst)
        .replaceAll('{', '')
        .replaceAll('}', '');
  }

  static String _formatQuadLaTeX(
      int a,
      int b,
      int c,
      String v1,
      String v2,
      ) {
    final String p1 = _formatTermLaTeX(a, '$v1^2', isFirst: true);
    final String midVar = v2.isEmpty ? v1 : '$v1$v2';
    final String p2 = b == 0 ? '' : ' ${_formatTermLaTeX(b, midVar)}';
    final String endVar = v2.isEmpty ? '' : '$v2^2';
    final String p3 = c == 0 ? '' : ' ${_formatTermLaTeX(c, endVar)}';
    return '$p1$p2$p3'.trim();
  }

  /// Parses any quadratic expression (including scrambled order, homogeneous 2-variable like x^2 + 2xy + y^2, or fractional coefficients)
  static Map<String, dynamic> _parseQuadraticExpression(String raw) {
    final String clean = raw
        .trim()
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll('²', '^2')
        .replaceAll('--', '+')
        .replaceAll('+-', '-')
        .replaceAll('-', '+-');

    final List<String> chunks =
    clean.split('+').where((String p) => p.trim().isNotEmpty).toList();
    if (chunks.length < 2) {
      throw const FormatException(
        "Please enter a quadratic trinomial (e.g. x^2 + 8x + 12, 3x^2 - 10x + 3, or 5x^2 - 11x + 2).",
      );
    }

    // Detect variables present
    final Set<String> varsFound = {};
    for (final String ch in chunks) {
      for (final Match m in RegExp(r'([a-zA-Z])').allMatches(ch)) {
        varsFound.add(m.group(1)!);
      }
    }
    if (varsFound.isEmpty) {
      throw const FormatException("Please include a variable (e.g. x, a, y, m).");
    }
    final List<String> sortedVars = varsFound.toList()..sort();
    final String v1 = sortedVars.first;
    final String v2 = sortedVars.length > 1 ? sortedVars[1] : '';

    _FFrac aFrac = const _FFrac(0, 1);
    _FFrac bFrac = const _FFrac(0, 1);
    _FFrac cFrac = const _FFrac(0, 1);

    for (String ch in chunks) {
      int sign = 1;
      if (ch.startsWith('-')) {
        sign = -1;
        ch = ch.substring(1);
      } else if (ch.startsWith('+')) {
        ch = ch.substring(1);
      }

      final RegExp numReg = RegExp(r'^(\d+(?:/\d+|\.\d+)?)');
      final Match? nm = numReg.firstMatch(ch);
      _FFrac coeff = _FFrac.from(sign, 1);
      String rem = ch;
      if (nm != null) {
        final _FFrac parsed = _FFrac.parse(nm.group(1)!);
        coeff = _FFrac.from(sign * parsed.num, parsed.den);
        rem = ch.substring(nm.end);
      }

      if (rem.contains('$v1^2')) {
        aFrac = aFrac + coeff;
      } else if (v2.isNotEmpty && rem.contains('$v2^2')) {
        cFrac = cFrac + coeff;
      } else if (rem.contains(v1)) {
        bFrac = bFrac + coeff;
      } else {
        cFrac = cFrac + coeff;
      }
    }

    if (aFrac.isZero) {
      throw const FormatException(
        "The coefficient of the squared term cannot be zero in a quadratic expression.",
      );
    }

    return {
      'aFrac': aFrac,
      'bFrac': bFrac,
      'cFrac': cFrac,
      'v1': v1,
      'v2': v2,
    };
  }

  // ===========================================================================
  // MASTER SOLVER: FACTORISATION OF QUADRATIC EXPRESSIONS (Pages 74–75 & 79)
  // ===========================================================================
  static QuadraticFactorisationResult solveQuadraticFactorisation({
    required int mode,
    required String exprInput,
    required String aInput,
    required String bInput,
    required String cInput,
    required String varInput,
  }) {
    try {
      _FFrac aFrac;
      _FFrac bFrac;
      _FFrac cFrac;
      String v1 = 'x';
      String v2 = '';

      if (mode == 0) {
        if (exprInput.trim().isEmpty) {
          throw const FormatException(
            "Please enter a quadratic expression to factorise (e.g. x^2 + 8x + 12 or 3x^2 - 10x + 3).",
          );
        }
        final Map<String, dynamic> parsed = _parseQuadraticExpression(exprInput);
        aFrac = parsed['aFrac'] as _FFrac;
        bFrac = parsed['bFrac'] as _FFrac;
        cFrac = parsed['cFrac'] as _FFrac;
        v1 = parsed['v1'] as String;
        v2 = parsed['v2'] as String;
      } else {
        if (aInput.trim().isEmpty ||
            bInput.trim().isEmpty ||
            cInput.trim().isEmpty) {
          throw const FormatException(
            "Please enter all three coefficients a, b, and c (e.g. a = 3, b = -10, c = 3).",
          );
        }
        aFrac = _FFrac.parse(aInput);
        bFrac = _FFrac.parse(bInput);
        cFrac = _FFrac.parse(cInput);
        if (aFrac.isZero) {
          throw const FormatException("Coefficient 'a' cannot be 0.");
        }
        final String vClean =
        varInput.trim().replaceAll(RegExp(r'[^a-zA-Z]'), '');
        v1 = vClean.isEmpty ? 'x' : vClean[0];
      }

      final String midVar = v2.isEmpty ? v1 : '$v1$v2';
      final String endVar = v2.isEmpty ? '' : '$v2^2';

      // Check if fractional denominators or overall integer HCF exist
      final int commonDen =
      _FFrac.lcm(aFrac.den, _FFrac.lcm(bFrac.den, cFrac.den));
      final int scaledA = aFrac.num * (commonDen ~/ aFrac.den);
      final int scaledB = bFrac.num * (commonDen ~/ bFrac.den);
      final int scaledC = cFrac.num * (commonDen ~/ cFrac.den);

      int hcfAll =
      _FFrac.gcd(scaledA.abs(), _FFrac.gcd(scaledB.abs(), scaledC.abs()));
      if (scaledA < 0) {
        hcfAll = -hcfAll; // Normalise leading coefficient inside bracket to positive
      }

      final int A = scaledA ~/ hcfAll;
      final int B = scaledB ~/ hcfAll;
      final int C = scaledC ~/ hcfAll;

      final _FFrac outerFactor = _FFrac.from(hcfAll, commonDen);
      final bool hasOuterFactor =
      !(outerFactor.num == 1 && outerFactor.den == 1);
      final String outerPrefixLaTeX = hasOuterFactor
          ? (outerFactor.num == -1 && outerFactor.den == 1
          ? "-"
          : outerFactor.toLaTeX())
          : "";

      final String innerQuadLaTeX = _formatQuadLaTeX(A, B, C, v1, v2);
      final String givenExprLaTeX = hasOuterFactor
          ? "${aFrac.num.abs() == 1 && aFrac.den == 1 ? (aFrac.isNegative ? '-' : '') : aFrac.toLaTeX()}$v1^2 ${bFrac.toLaTeX(withSign: true)}$midVar ${cFrac.toLaTeX(withSign: true)}$endVar"
          : innerQuadLaTeX;

      // Step 1: Product ac and Sum b
      final int acProduct = A * C;
      final int targetSum = B;

      // Exhaustive Factor Pair Search (replicating Page 75 Example 3d & 3e!)
      final int absAC = acProduct.abs();
      final List<String> factorPairTableLinesLaTeX = [];
      final List<String> factorPairPlainLines = [];
      int? chosenP;
      int? chosenQ;

      for (int d = 1; d * d <= absAC; d++) {
        if (absAC % d == 0) {
          final int other = absAC ~/ d;
          final List<List<int>> candidatePairs = acProduct > 0
              ? [
            [d, other],
            [-d, -other]
          ]
              : [
            [d, -other],
            [-d, other]
          ];

          for (final List<int> pair in candidatePairs) {
            final int p = pair[0];
            final int q = pair[1];
            final int sum = p + q;
            final String pTerm = _formatTermLaTeX(p, midVar, isFirst: false);
            final String qTerm = _formatTermLaTeX(q, midVar, isFirst: false);
            final String sumTerm =
            _formatTermLaTeX(sum, midVar, isFirst: false);
            final String acTerm = _formatTermLaTeX(
                acProduct, v2.isEmpty ? '$v1^2' : '$v1^2$v2^2',
                isFirst: false);

            final bool isMatch = (sum == targetSum);
            if (isMatch && chosenP == null) {
              chosenP = p;
              chosenQ = q;
            }

            factorPairTableLinesLaTeX.add(
              "$acTerm = ($pTerm) \\times ($qTerm) \\quad \\longrightarrow \\quad \\text{sum} = $sumTerm ${isMatch ? '\\quad \\checkmark \\text{ (Matches middle term!)}' : ''}",
            );
            factorPairPlainLines.add(
              "• (${_formatTermPlain(p, midVar)}) × (${_formatTermPlain(q, midVar)})  ➔  sum = ${_formatTermPlain(sum, midVar)}${isMatch ? '  ✓ (Chosen pair!)' : ''}",
            );
          }
        }
      }

      if (chosenP == null || chosenQ == null) {
        throw FormatException(
          "The quadratic expression '$innerQuadLaTeX' cannot be factorised into rational linear factors (no integer factor pair of $acProduct sums to $targetSum).",
        );
      }

      // Order (p, q) so grouping looks natural
      final int P = chosenP;
      final int Q = chosenQ;

      // Step 2: Split middle term Bx into Px + Qx
      // Group 1: (Ax^2 + Px), Group 2: (Qx + C)
      final int g1Hcf = _FFrac.gcd(A.abs(), P.abs());
      final int u1 = A ~/ g1Hcf; // coeff of v1 inside common binomial
      final int u2 = P ~/ g1Hcf; // coeff of v2/constant inside common binomial

      // Then Q = g2Hcf * u1 and C = g2Hcf * u2
      final int g2Hcf = Q ~/ u1;

      final String firstTermLaTeX = _formatTermLaTeX(A, '$v1^2', isFirst: true);
      final String pTermLaTeX = _formatTermLaTeX(P, midVar);
      final String qTermLaTeX = _formatTermLaTeX(Q, midVar);
      final String lastTermLaTeX = _formatTermLaTeX(C, endVar);

      final String splitQuadLaTeX =
          "$firstTermLaTeX $pTermLaTeX $qTermLaTeX $lastTermLaTeX";

      // Grouped brackets line (explicitly showing sign flip if g2Hcf < 0, matching Example 3b & 3d!)
      final String group1InsideLaTeX =
          "${_formatTermLaTeX(A, '$v1^2', isFirst: true)} ${_formatTermLaTeX(P, midVar)}";
      final String group2InsideSignedLaTeX = g2Hcf < 0
          ? "${_formatTermLaTeX(-Q, midVar, isFirst: true)} ${_formatTermLaTeX(-C, endVar)}"
          : "${_formatTermLaTeX(Q, midVar, isFirst: true)} ${_formatTermLaTeX(C, endVar)}";
      final String betweenGroupsSign = g2Hcf < 0 ? "-" : "+";
      final String groupedLineLaTeX =
          "($group1InsideLaTeX) $betweenGroupsSign ($group2InsideSignedLaTeX)";

      // Common binomial factor (u1*v1 + u2*v2)
      final String commonBinomialLaTeX =
          "${_formatTermLaTeX(u1, v1, isFirst: true)} ${_formatTermLaTeX(u2, v2)}";
      final String secondBinomialLaTeX =
          "${_formatTermLaTeX(g1Hcf, v1, isFirst: true)} ${_formatTermLaTeX(g2Hcf, v2)}";

      final String g1OuterLaTeX =
      _formatTermLaTeX(g1Hcf, v1, isFirst: true);
      final String g2OuterLaTeX =
      _formatTermLaTeX(g2Hcf, v2, isFirst: false);

      final String factoredGroupsLineLaTeX =
          "$g1OuterLaTeX($commonBinomialLaTeX) $g2OuterLaTeX($commonBinomialLaTeX)";
      final String finalFactoredLaTeX =
          "$outerPrefixLaTeX($commonBinomialLaTeX)($secondBinomialLaTeX)";

      // Build Textbook Factor-Branch + Quantitative Reasoning 3-Tier Box in LaTeX (Pages 74 & 79!)
      // Using standard 2-column array without \multicolumn so flutter_math_fork renders it without parser errors!
      final String acProductTermLaTeX = _formatTermLaTeX(
          acProduct, v2.isEmpty ? '$v1^2' : '$v1^2$v2^2',
          isFirst: false);
      final String quantitativeBoxLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Quadratic Expression} & \\mathbf{$innerQuadLaTeX} \\quad \\left(\\text{Product} = $acProductTermLaTeX: \\; ${_formatTermLaTeX(P, midVar)} \\; \\& \\; ${_formatTermLaTeX(Q, midVar)}\\right) \\\\ \\hline "
          "\\mathbf{$g1OuterLaTeX($commonBinomialLaTeX)} & \\mathbf{$g2OuterLaTeX($commonBinomialLaTeX)} \\\\ \\hline "
          "\\textbf{Factorised Form} & \\mathbf{$finalFactoredLaTeX} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Given Quadratic Expression (Pages 74–75):}}",
        "\\mathbf{$givenExprLaTeX}",
        if (hasOuterFactor) ...[
          "",
          "\\text{\\textbf{Preliminary Step: Factor Out the Common Factor }} \\mathbf{$outerPrefixLaTeX}",
          "$givenExprLaTeX = $outerPrefixLaTeX($innerQuadLaTeX)",
        ],
        "",
        "\\text{\\textbf{Step 1: Multiply the First Term and the Constant/Last Term (Example 3, Page 74)}}",
        "\\text{First term} = $firstTermLaTeX, \\qquad \\text{Last term} = ${_formatTermLaTeX(C, endVar, isFirst: false)}, \\qquad \\text{Middle term} = ${_formatTermLaTeX(B, midVar, isFirst: false)}",
        "\\text{Product} = ($firstTermLaTeX) \\times (${_formatTermLaTeX(C, endVar, isFirst: false)}) = \\mathbf{$acProductTermLaTeX}",
        "",
        "\\text{\\textbf{Step 2: Find Two Factors of }} \\mathbf{$acProductTermLaTeX} \\text{\\textbf{ Whose Sum is }} \\mathbf{${_formatTermLaTeX(B, midVar, isFirst: false)}}",
        ...factorPairTableLinesLaTeX,
        "\\text{So, } ${_formatTermLaTeX(P, midVar, isFirst: false)} \\text{ and } ${_formatTermLaTeX(Q, midVar, isFirst: false)} \\text{ give } ${_formatTermLaTeX(B, midVar, isFirst: false)}.",
        "",
        "\\text{\\textbf{Step 3: Split the Middle Term and Group in Pairs}}",
        "$innerQuadLaTeX = $splitQuadLaTeX",
        "= $groupedLineLaTeX",
        if (g2Hcf < 0)
          "\\text{(Note: Since a minus sign is placed outside the second bracket, the sign inside changes!)}",
        "",
        "\\text{\\textbf{Step 4: Factor Each Pair and Extract the Common Binomial Factor}}",
        "= $factoredGroupsLineLaTeX",
        "\\text{Since } ($commonBinomialLaTeX) \\text{ is a common binomial factor:}",
        "= \\mathbf{$finalFactoredLaTeX}",
        "",
        "\\text{\\textbf{Quantitative Reasoning Box Summary (Page 79):}}",
        quantitativeBoxLaTeX,
      ];

      final List<QuadraticFactorisationStep> steps = [
        if (hasOuterFactor)
          QuadraticFactorisationStep(
            title: "Preliminary Step: Factor Out Common Factor (\$${outerFactor.toLaTeX()}\$)",
            description:
            "• Before looking for factor pairs, we notice that all three terms share a common factor of \$${outerFactor.toLaTeX()}\$.\n"
                "• Factoring out \$${outerFactor.toLaTeX()}\$ leaves a simpler quadratic trinomial (\$$innerQuadLaTeX\$) inside the bracket.",
            mathLinesLaTeX: [
              "$givenExprLaTeX = $outerPrefixLaTeX($innerQuadLaTeX)",
            ],
          ),
        QuadraticFactorisationStep(
          title:
          "Step 1: Multiply the Term in \$$v1^2\$ and the Constant/Last Term (Page 74 Method)",
          description:
          "• Why do we multiply the first and last terms? Because in any factorisable quadratic \$ax^2 + bx + c\$, the two middle parts we need to split \$bx\$ into must multiply to give the exact same product as the first term times the last term!\n"
              "• Multiplying the first term (\$$firstTermLaTeX\$) by the last term (\$$lastTermLaTeX\$) gives our Target Product = \$$acProductTermLaTeX\$.\n"
              "• Our Target Sum is the middle term = \$${_formatTermLaTeX(B, midVar)}\$.",
          mathLinesLaTeX: [
            "($firstTermLaTeX) \\times (${_formatTermLaTeX(C, endVar)}) = \\mathbf{$acProductTermLaTeX}",
            "\\text{Target Product} = $acProductTermLaTeX, \\qquad \\text{Target Sum} = ${_formatTermLaTeX(B, midVar)}",
          ],
        ),
        QuadraticFactorisationStep(
          title:
          "Step 2: Test Factor Pairs of \$$acProductTermLaTeX\$ (Page 75 Table)",
          description:
          "• Now we list all pairs of factors that multiply to give \$$acProductTermLaTeX\$ and add each pair together to see which one gives our middle term (\$${_formatTermLaTeX(B, midVar)}\$):\n\n"
              "${factorPairPlainLines.join('\n')}",
          mathLinesLaTeX: [
            ...factorPairTableLinesLaTeX,
            "\\therefore \\text{ Chosen factors: } \\mathbf{${_formatTermLaTeX(P, midVar)}} \\text{ and } \\mathbf{${_formatTermLaTeX(Q, midVar)}}",
          ],
        ),
        QuadraticFactorisationStep(
          title:
          "Step 3: Split the Middle Term, Group in Pairs & Factorise Completely",
          description:
          "• We rewrite the middle term (\$${_formatTermLaTeX(B, midVar)}\$) as the sum of our two chosen factors (\$$pTermLaTeX $qTermLaTeX\$) so the 3-term quadratic becomes a 4-term expression.\n"
              "• Next, we group the first two terms together and the last two terms together: \$$groupedLineLaTeX\$${g2Hcf < 0 ? ' (notice that because we put a minus sign outside the second bracket, the sign inside the second bracket changes!)' : ''}.\n"
              "• Factoring out \$$g1OuterLaTeX\$ from the first bracket and \$$g2OuterLaTeX\$ from the second bracket reveals the common binomial bracket \$($commonBinomialLaTeX)\$. Factoring out \$($commonBinomialLaTeX)\$ gives the final answer!",
          mathLinesLaTeX: [
            "$innerQuadLaTeX = $splitQuadLaTeX",
            "= $groupedLineLaTeX",
            "= $factoredGroupsLineLaTeX",
            "= \\mathbf{$finalFactoredLaTeX}",
          ],
        ),
      ];

      return QuadraticFactorisationResult(
        mode: mode,
        finalAnswersLaTeX: {
          "Given Quadratic": givenExprLaTeX,
          "Product & Sum":
          "\\text{Prod} = $acProductTermLaTeX,\\; \\text{Sum} = ${_formatTermLaTeX(B, midVar)}",
          "Chosen Factors":
          "${_formatTermLaTeX(P, midVar)} \\text{ and } ${_formatTermLaTeX(Q, midVar)}",
          "Factorised Form": "\\mathbf{$finalFactoredLaTeX}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: QuadraticFactorisationCanvasData(
          headerLaTeX:
          "\\text{Quadratic Factorisation (Pages 74–75): } $givenExprLaTeX = \\mathbf{$finalFactoredLaTeX}",
          subHeaderLaTeX:
          "\\text{Split Middle Term: } $innerQuadLaTeX = $splitQuadLaTeX = $factoredGroupsLineLaTeX",
          card1Title: "Product (ac)",
          card1LaTeX: "\\mathbf{$acProductTermLaTeX}",
          card2Title: "Chosen Factors (p, q)",
          card2LaTeX:
          "\\mathbf{${_formatTermLaTeX(P, midVar)},\\; ${_formatTermLaTeX(Q, midVar)}}",
          card3Title: "Factorised Result",
          card3LaTeX: "\\mathbf{$finalFactoredLaTeX}",
          quantitativeBoxLaTeX: quantitativeBoxLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $givenExprLaTeX = \\mathbf{$finalFactoredLaTeX}",
        ),
      );
    } catch (e) {
      return QuadraticFactorisationResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid factorisable quadratic expression.",
      );
    }
  }
}