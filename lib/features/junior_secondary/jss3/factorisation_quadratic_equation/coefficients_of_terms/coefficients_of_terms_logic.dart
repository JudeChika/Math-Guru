import 'coefficients_of_terms_models.dart';

/// Exact Rational Number (Fraction) Engine for Coefficients of Terms (Example 2d: 2/7x^2 - 11/18x - 7/40)
class _CFrac {
  final int num;
  final int den;

  const _CFrac(this.num, [this.den = 1]);

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

  factory _CFrac.from(int n, [int d = 1]) {
    if (d == 0) throw const FormatException("Denominator cannot be zero.");
    if (n == 0) return const _CFrac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = _gcd(an, ad);
    return _CFrac(sign * (an ~/ g), ad ~/ g);
  }

  factory _CFrac.parse(String raw) {
    String s = raw.trim().replaceAll(' ', '').replaceAll('−', '-');
    if (s.isEmpty || s == '+') return const _CFrac(1, 1);
    if (s == '-') return const _CFrac(-1, 1);

    int sign = 1;
    if (s.startsWith('-')) {
      sign = -1;
      s = s.substring(1);
    } else if (s.startsWith('+')) {
      s = s.substring(1);
    }
    if (s.isEmpty) return _CFrac(sign, 1);

    if (s.contains('/')) {
      final List<String> parts = s.split('/');
      if (parts.length != 2) {
        throw FormatException("Invalid fraction '$raw'.");
      }
      return _CFrac.from(sign * int.parse(parts[0]), int.parse(parts[1]));
    }

    if (s.contains('.')) {
      final List<String> parts = s.split('.');
      int d = 1;
      for (int i = 0; i < parts[1].length; i++) {
        d *= 10;
      }
      final int n = int.parse(parts[0]) * d + int.parse(parts[1]);
      return _CFrac.from(sign * n, d);
    }

    return _CFrac.from(sign * int.parse(s), 1);
  }

  bool get isZero => num == 0;
  bool get isNegative => num < 0;
  bool get isAbsOne => num.abs() == 1 && den == 1;

  _CFrac abs() => _CFrac(num.abs(), den);
  _CFrac operator +(_CFrac other) =>
      _CFrac.from(num * other.den + other.num * den, den * other.den);
  _CFrac operator *(_CFrac other) =>
      _CFrac.from(num * other.num, den * other.den);

  String toLaTeX({bool withSign = false, bool explicitPlus = false}) {
    if (num == 0) return (withSign || explicitPlus) ? '+0' : '0';
    final String signStr = num < 0
        ? (withSign ? '- ' : '-')
        : (withSign ? '+ ' : (explicitPlus ? '+' : ''));
    final int an = num.abs();
    if (den == 1) return '$signStr$an';
    return '$signStr\\frac{$an}{$den}';
  }

  String toPlain({bool withSign = false, bool explicitPlus = false}) {
    if (num == 0) return (withSign || explicitPlus) ? '+0' : '0';
    final String signStr = num < 0
        ? (withSign ? '- ' : '-')
        : (withSign ? '+ ' : (explicitPlus ? '+' : ''));
    final int an = num.abs();
    if (den == 1) return '$signStr$an';
    return '$signStr$an/$den';
  }
}

class _PolyTerm {
  final _CFrac coeff;
  final String variable;
  final int power;

  const _PolyTerm({
    required this.coeff,
    required this.variable,
    required this.power,
  });

  static _PolyTerm parse(String raw) {
    String s = raw
        .trim()
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3');
    if (s.isEmpty) {
      return const _PolyTerm(coeff: _CFrac(0, 1), variable: '', power: 0);
    }

    int sign = 1;
    if (s.startsWith('-')) {
      sign = -1;
      s = s.substring(1);
    } else if (s.startsWith('+')) {
      s = s.substring(1);
    }

    // Match optional fraction/number before variable, variable + power, and optional /denominator after variable
    final RegExp reg =
    RegExp(r'^(\d+(?:/\d+|\.\d+)?)?([a-zA-Z])?(?:\^(\d+))?(?:/(\d+))?$');
    final Match? m = reg.firstMatch(s);
    if (m == null) {
      throw FormatException("Cannot parse algebraic term '$raw'.");
    }

    final String? numPart = m.group(1);
    final String? varPart = m.group(2);
    final String? powPart = m.group(3);
    final String? tailDenPart = m.group(4);

    _CFrac baseCoeff = (numPart != null && numPart.isNotEmpty)
        ? _CFrac.parse(numPart)
        : const _CFrac(1, 1);
    final int tailDen =
    (tailDenPart != null && tailDenPart.isNotEmpty) ? int.parse(tailDenPart) : 1;
    final _CFrac finalCoeff =
    _CFrac.from(sign * baseCoeff.num, baseCoeff.den * tailDen);

    final String v = varPart ?? '';
    final int p = v.isEmpty ? 0 : (int.tryParse(powPart ?? '1') ?? 1);

    return _PolyTerm(coeff: finalCoeff, variable: v, power: p);
  }

  _PolyTerm multiply(_PolyTerm other) {
    final String nextVar =
    variable.isNotEmpty ? variable : other.variable;
    return _PolyTerm(
      coeff: coeff * other.coeff,
      variable: nextVar,
      power: power + other.power,
    );
  }

  String toLaTeX({bool withSign = false}) {
    if (coeff.isZero) return withSign ? '+ 0' : '0';
    final String signStr =
    coeff.isNegative ? (withSign ? '- ' : '-') : (withSign ? '+ ' : '');
    final _CFrac absC = coeff.abs();
    final String varStr =
    power == 0 ? '' : (power == 1 ? variable : '$variable^{$power}');

    if (power == 0 || !absC.isAbsOne) {
      return '$signStr${absC.toLaTeX()}$varStr';
    }
    return '$signStr$varStr';
  }

  String toPlain({bool withSign = false}) {
    if (coeff.isZero) return withSign ? '+ 0' : '0';
    final String signStr =
    coeff.isNegative ? (withSign ? '- ' : '-') : (withSign ? '+ ' : '');
    final _CFrac absC = coeff.abs();
    final String varStr =
    power == 0 ? '' : (power == 1 ? variable : '$variable^$power');

    if (power == 0 || !absC.isAbsOne) {
      return '$signStr${absC.toPlain()}$varStr';
    }
    return '$signStr$varStr';
  }
}

class CoefficientsOfTermsLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 73–74: Text Examples, Example 2a–e & Exercise 8.2 #1–10)
  // ===========================================================================
  static const List<CoefficientsPreset> textbookPresets = [
    CoefficientsPreset(
      chipLabel: "Text Intro (Page 73): 2x² - x + 5",
      mode: 0,
      input1: '2x^2 - x + 5',
    ),
    CoefficientsPreset(
      chipLabel: "Text Intro (Page 73): 1/3a² + 11a - 60",
      mode: 0,
      input1: '1/3a^2 + 11a - 60',
    ),
    CoefficientsPreset(
      chipLabel: "Example 2a (Page 73): 4x² - 5x - 7",
      mode: 0,
      input1: '4x^2 - 5x - 7',
    ),
    CoefficientsPreset(
      chipLabel: "Example 2b (Page 73): 1 - 4x - x² (Scrambled Order)",
      mode: 0,
      input1: '1 - 4x - x^2',
    ),
    CoefficientsPreset(
      chipLabel: "Example 2c (Page 73): 3 - x - x²",
      mode: 0,
      input1: '3 - x - x^2',
    ),
    CoefficientsPreset(
      chipLabel: "Example 2d (Page 73): 2/7x² - 11/18x - 7/40 (Fractions!)",
      mode: 0,
      input1: '2/7x^2 - 11/18x - 7/40',
    ),
    CoefficientsPreset(
      chipLabel: "Example 2e (Page 73): 65x - 144 - 19x²",
      mode: 0,
      input1: '65x - 144 - 19x^2',
    ),
    CoefficientsPreset(
      chipLabel: "Ex 8.2 #1 (Page 74): (x + 1)(x + 2)",
      mode: 1,
      input1: 'x + 1',
      input2: 'x + 2',
    ),
    CoefficientsPreset(
      chipLabel: "Ex 8.2 #2 (Page 74): (2x - 3)(3x + 4)",
      mode: 1,
      input1: '2x - 3',
      input2: '3x + 4',
    ),
    CoefficientsPreset(
      chipLabel: "Ex 8.2 #3 (Page 74): (5x + 1)(x - 6)",
      mode: 1,
      input1: '5x + 1',
      input2: 'x - 6',
    ),
    CoefficientsPreset(
      chipLabel: "Ex 8.2 #4 (Page 74): (3x + 2)(2x - 3)",
      mode: 1,
      input1: '3x + 2',
      input2: '2x - 3',
    ),
    CoefficientsPreset(
      chipLabel: "Ex 8.2 #5 (Page 74): (4x - 1)(4x + 1) (Zero x-Term!)",
      mode: 1,
      input1: '4x - 1',
      input2: '4x + 1',
    ),
    CoefficientsPreset(
      chipLabel: "Ex 8.2 #6 (Page 74): (2x - 7)(2x + 7)",
      mode: 1,
      input1: '2x - 7',
      input2: '2x + 7',
    ),
    CoefficientsPreset(
      chipLabel: "Ex 8.2 #7 (Page 74): (3x - 5)²",
      mode: 2,
      input1: '3x - 5',
    ),
    CoefficientsPreset(
      chipLabel: "Ex 8.2 #8 (Page 74): (2x - 1)²",
      mode: 2,
      input1: '2x - 1',
    ),
    CoefficientsPreset(
      chipLabel: "Ex 8.2 #10 (Page 74): (11x + 5)(11x - 5)",
      mode: 1,
      input1: '11x + 5',
      input2: '11x - 5',
    ),
  ];

  static List<_PolyTerm> _parsePolyList(String raw) {
    final String clean = raw
        .trim()
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll('--', '+')
        .replaceAll('+-', '-')
        .replaceAll('-', '+-');

    final List<String> parts =
    clean.split('+').where((String p) => p.trim().isNotEmpty).toList();
    if (parts.isEmpty) {
      throw const FormatException(
        "Please enter a valid algebraic expression (e.g. 4x^2 - 5x - 7 or 2/7x^2 - 11/18x - 7/40).",
      );
    }
    return parts.map(_PolyTerm.parse).toList();
  }

  static String _formatPolyLaTeX(List<_PolyTerm> terms) {
    final List<_PolyTerm> nonZero =
    terms.where((_PolyTerm t) => !t.coeff.isZero).toList();
    if (nonZero.isEmpty) return '0';
    final List<String> out = [];
    for (int i = 0; i < nonZero.length; i++) {
      out.add(nonZero[i].toLaTeX(withSign: i > 0));
    }
    return out.join(' ');
  }

  static String _formatPolyPlain(List<_PolyTerm> terms) {
    final List<_PolyTerm> nonZero =
    terms.where((_PolyTerm t) => !t.coeff.isZero).toList();
    if (nonZero.isEmpty) return '0';
    final List<String> out = [];
    for (int i = 0; i < nonZero.length; i++) {
      out.add(nonZero[i].toPlain(withSign: i > 0));
    }
    return out.join(' ');
  }

  // ===========================================================================
  // MASTER SOLVER: COEFFICIENTS OF TERMS (Example 2 & Exercise 8.2, Pages 73–74)
  // ===========================================================================
  static CoefficientsResult solveCoefficients({
    required int mode,
    required String rawInput1,
    required String rawInput2,
  }) {
    try {
      String in1 = rawInput1.trim();
      String in2 = rawInput2.trim();
      int activeMode = mode;

      // Auto-detect if user typed a bracketed product in Mode 0
      if (activeMode == 0 && in1.contains('(')) {
        final String norm =
        in1.replaceAll(' ', '').replaceAll('−', '-').replaceAll('²', '^2');
        final RegExp sqReg = RegExp(r'^\(([^()]+)\)\^2$');
        final RegExp prodReg = RegExp(r'^\(([^()]+)\)\(([^()]+)\)$');
        if (sqReg.hasMatch(norm)) {
          in1 = sqReg.firstMatch(norm)!.group(1)!;
          activeMode = 2;
        } else if (prodReg.hasMatch(norm)) {
          final Match m = prodReg.firstMatch(norm)!;
          in1 = m.group(1)!;
          in2 = m.group(2)!;
          activeMode = 1;
        }
      }

      List<_PolyTerm> workingTerms = [];
      final List<String> preExpansionLinesLaTeX = [];
      final List<String> preExpansionLinesPlain = [];
      String givenDisplayLaTeX = '';

      if (activeMode == 1 || activeMode == 2) {
        if (activeMode == 2) {
          if (in1.isEmpty) {
            throw const FormatException(
              "Please enter the binomial inside the square (e.g. 3x - 5 or 2x - 1).",
            );
          }
          in2 = in1;
        }
        if (in1.isEmpty || in2.isEmpty) {
          throw const FormatException(
            "Please enter both brackets to expand (e.g. 2x - 3 and 3x + 4).",
          );
        }

        final List<_PolyTerm> b1 = _parsePolyList(in1);
        final List<_PolyTerm> b2 = _parsePolyList(in2);
        final String b1LaTeX = _formatPolyLaTeX(b1);
        final String b2LaTeX = _formatPolyLaTeX(b2);

        givenDisplayLaTeX =
        activeMode == 2 ? "($b1LaTeX)^2" : "($b1LaTeX)($b2LaTeX)";

        final List<String> splitLaTeX = [];
        final List<_PolyTerm> rawProds = [];
        for (int i = 0; i < b1.length; i++) {
          splitLaTeX.add("${b1[i].toLaTeX(withSign: i > 0)}($b2LaTeX)");
          for (int j = 0; j < b2.length; j++) {
            rawProds.add(b1[i].multiply(b2[j]));
          }
        }
        workingTerms = rawProds;

        preExpansionLinesLaTeX.addAll([
          if (activeMode == 2)
            "($b1LaTeX)^2 = ($b1LaTeX)($b2LaTeX)",
          "($b1LaTeX)($b2LaTeX) = ${splitLaTeX.join(' ')}",
          "= ${_formatPolyLaTeX(rawProds)}",
        ]);
        preExpansionLinesPlain.add(
          "• First expand the brackets: ${_formatPolyPlain(b1)} multiplied by ${_formatPolyPlain(b2)} gives ${_formatPolyPlain(rawProds)}.",
        );
      } else {
        if (in1.isEmpty) {
          throw const FormatException(
            "Please enter a quadratic expression (e.g. 4x^2 - 5x - 7 or 2/7x^2 - 11/18x - 7/40).",
          );
        }
        workingTerms = _parsePolyList(in1);
        givenDisplayLaTeX = _formatPolyLaTeX(workingTerms);
      }

      // Detect primary variable letter (default to 'x')
      String varLetter = 'x';
      for (final _PolyTerm t in workingTerms) {
        if (t.variable.isNotEmpty) {
          varLetter = t.variable;
          break;
        }
      }

      // Sum coefficients for power 2, power 1, and power 0 (constant)
      _CFrac coeffX2 = const _CFrac(0, 1);
      _CFrac coeffX1 = const _CFrac(0, 1);
      _CFrac coeffConst = const _CFrac(0, 1);

      for (final _PolyTerm t in workingTerms) {
        if (t.power == 2) {
          coeffX2 = coeffX2 + t.coeff;
        } else if (t.power == 1) {
          coeffX1 = coeffX1 + t.coeff;
        } else if (t.power == 0) {
          coeffConst = coeffConst + t.coeff;
        }
      }

      final List<_PolyTerm> standardTerms = [
        if (!coeffX2.isZero)
          _PolyTerm(coeff: coeffX2, variable: varLetter, power: 2),
        if (!coeffX1.isZero)
          _PolyTerm(coeff: coeffX1, variable: varLetter, power: 1),
        if (!coeffConst.isZero)
          _PolyTerm(coeff: coeffConst, variable: '', power: 0),
      ];
      final String standardFormLaTeX = _formatPolyLaTeX(standardTerms);
      final String standardFormPlain = _formatPolyPlain(standardTerms);

      final String c2LaTeX = coeffX2.toLaTeX(explicitPlus: true);
      final String c1LaTeX = coeffX1.toLaTeX(explicitPlus: true);
      final String c0LaTeX = coeffConst.toLaTeX(explicitPlus: true);

      final String c2Plain = coeffX2.toPlain(explicitPlus: true);
      final String c1Plain = coeffX1.toPlain(explicitPlus: true);
      final String c0Plain = coeffConst.toPlain(explicitPlus: true);

      // Build explicit signed decomposition: (+4)x^2 + (-5)x + (-7)
      final String explicitSignedSumLaTeX =
          "\\left($c2LaTeX\\right)$varLetter^2 + \\left($c1LaTeX\\right)$varLetter + \\left($c0LaTeX\\right)";

      // Build Term Anatomy Breakdown Table in LaTeX for Visualisation Area
      final String termX2Cell = _PolyTerm(
          coeff: coeffX2, variable: varLetter, power: 2)
          .toLaTeX(withSign: true);
      final String termX1Cell = _PolyTerm(
          coeff: coeffX1, variable: varLetter, power: 1)
          .toLaTeX(withSign: true);
      final String termConstCell =
      _PolyTerm(coeff: coeffConst, variable: '', power: 0)
          .toLaTeX(withSign: true);

      final String anatomyTableLaTeX = "\\begin{array}{c|c|c} "
          "\\textbf{Target Term} & \\textbf{Term in Expression} & \\textbf{Exact Coefficient} \\\\ \\hline "
          "\\text{i) Term in } $varLetter^2 & $termX2Cell & \\mathbf{$c2LaTeX} \\\\ \\hline "
          "\\text{ii) Term in } $varLetter & $termX1Cell & \\mathbf{$c1LaTeX} \\\\ \\hline "
          "\\text{iii) Constant Term} & $termConstCell & \\mathbf{$c0LaTeX} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Definition (Page 73):}} \\text{ The number (with its sign) before a letter in an algebraic expression is called its coefficient.}",
        "\\text{Given Expression: } \\mathbf{$givenDisplayLaTeX}",
        if (preExpansionLinesLaTeX.isNotEmpty) ...[
          "",
          "\\text{\\textbf{Step 1: Expand the Brackets First (Exercise 8.2, Page 74)}}",
          ...preExpansionLinesLaTeX,
          "= \\mathbf{$standardFormLaTeX}",
        ],
        "",
        "\\text{\\textbf{Step ${preExpansionLinesLaTeX.isNotEmpty ? 2 : 1}: Arrange in Standard Descending Powers of }} \\mathbf{$varLetter}",
        "\\text{Standard Form } (a$varLetter^2 + b$varLetter + c): \\quad \\mathbf{$standardFormLaTeX}",
        "\\text{Decompose into signed coefficients multiplying each power of } $varLetter:",
        "= $explicitSignedSumLaTeX",
        "",
        "\\text{\\textbf{Step ${preExpansionLinesLaTeX.isNotEmpty ? 3 : 2}: Extract Each Coefficient With Its Sign (Example 2, Page 73)}}",
        "\\text{i) Coefficient of } $varLetter^2 \\text{ (from } $termX2Cell\\text{)} = \\mathbf{$c2LaTeX}",
        "\\text{ii) Coefficient of } $varLetter \\text{ (from } $termX1Cell\\text{)} = \\mathbf{$c1LaTeX}",
        "\\text{iii) Constant term (independent of } $varLetter\\text{)} = \\mathbf{$c0LaTeX}",
      ];

      final List<CoefficientsStep> steps = [
        if (preExpansionLinesLaTeX.isNotEmpty)
          CoefficientsStep(
            title: "Step 1: Expand the Brackets First (Exercise 8.2 Method)",
            description:
            "${preExpansionLinesPlain.join('\n')}\n"
                "• Combining like terms gives the quadratic expression: $standardFormPlain.",
            mathLinesLaTeX: [
              ...preExpansionLinesLaTeX,
              "= \\mathbf{$standardFormLaTeX}",
            ],
          ),
        CoefficientsStep(
          title:
          "Step ${preExpansionLinesLaTeX.isNotEmpty ? 2 : 1}: Write in Standard Form & Separate Each Signed Term",
          description:
          "• Arrange the expression in descending powers of $varLetter ($varLetter² term first, $varLetter term second, and constant term last), ensuring every term carries its '+' or '−' sign in front of it.",
          mathLinesLaTeX: [
            "\\text{Standard Form: } \\mathbf{$standardFormLaTeX}",
            "= $explicitSignedSumLaTeX",
          ],
        ),
        CoefficientsStep(
          title:
          "Step ${preExpansionLinesLaTeX.isNotEmpty ? 3 : 2}: Read Off the Coefficients of $varLetter², $varLetter, and the Constant Term",
          description:
          "• i) The number multiplying $varLetter² is $c2Plain.\n"
              "• ii) The number multiplying $varLetter is $c1Plain${coeffX1.isZero ? ' (since the middle term vanished!)' : ''}.\n"
              "• iii) The constant term (without $varLetter) is $c0Plain.",
          mathLinesLaTeX: [
            "\\text{i) Coefficient of } $varLetter^2 = \\mathbf{$c2LaTeX}",
            "\\text{ii) Coefficient of } $varLetter = \\mathbf{$c1LaTeX}",
            "\\text{iii) Constant term} = \\mathbf{$c0LaTeX}",
            anatomyTableLaTeX,
          ],
        ),
      ];

      return CoefficientsResult(
        mode: activeMode,
        finalAnswersLaTeX: {
          "Standard Form": standardFormLaTeX,
          "i) Coefficient of $varLetter^2": "\\mathbf{$c2LaTeX}",
          "ii) Coefficient of $varLetter": "\\mathbf{$c1LaTeX}",
          "iii) Constant Term": "\\mathbf{$c0LaTeX}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: CoefficientsCanvasData(
          headerLaTeX:
          "\\text{Coefficients of Terms (Pages 73–74): } $givenDisplayLaTeX \\longrightarrow \\mathbf{$standardFormLaTeX}",
          subHeaderLaTeX: "\\text{Signed Decomposition: } $explicitSignedSumLaTeX",
          card1Title: "i) Coeff of $varLetter²",
          card1LaTeX: "\\mathbf{$c2LaTeX}",
          card2Title: "ii) Coeff of $varLetter",
          card2LaTeX: "\\mathbf{$c1LaTeX}",
          card3Title: "iii) Constant Term",
          card3LaTeX: "\\mathbf{$c0LaTeX}",
          anatomyTableLaTeX: anatomyTableLaTeX,
          bottomSummaryLaTeX:
          "\\text{i) Coeff of } $varLetter^2 = \\mathbf{$c2LaTeX} \\quad | \\quad \\text{ii) Coeff of } $varLetter = \\mathbf{$c1LaTeX} \\quad | \\quad \\text{Constant} = \\mathbf{$c0LaTeX}",
        ),
      );
    } catch (e) {
      return CoefficientsResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid algebraic expression (e.g. 2/7x^2 - 11/18x - 7/40).",
      );
    }
  }
}