import 'dart:math' as math;
import 'perfect_squares_models.dart';

/// Exact Rational Number (Fraction) Engine for Perfect Squares (handles integer, mixed, and fractional terms!)
class _PFrac {
  final int num;
  final int den;

  const _PFrac(this.num, [this.den = 1]);

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

  factory _PFrac.from(int n, [int d = 1]) {
    if (d == 0) throw const FormatException("Denominator cannot be zero.");
    if (n == 0) return const _PFrac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _PFrac(sign * (an ~/ g), ad ~/ g);
  }

  factory _PFrac.parse(String raw) {
    String s = raw.trim().replaceAll(' ', '').replaceAll('−', '-');
    if (s.isEmpty || s == '+') return const _PFrac(1, 1);
    if (s == '-') return const _PFrac(-1, 1);

    int sign = 1;
    if (s.startsWith('-')) {
      sign = -1;
      s = s.substring(1);
    } else if (s.startsWith('+')) {
      s = s.substring(1);
    }
    if (s.isEmpty) return _PFrac(sign, 1);

    if (s.contains('/')) {
      final List<String> parts = s.split('/');
      if (parts.length != 2) {
        throw FormatException("Invalid fraction '$raw'.");
      }
      return _PFrac.from(sign * int.parse(parts[0]), int.parse(parts[1]));
    }

    if (s.contains('.')) {
      final List<String> parts = s.split('.');
      int d = 1;
      for (int i = 0; i < parts[1].length; i++) {
        d *= 10;
      }
      final int n = int.parse(parts[0]) * d + int.parse(parts[1]);
      return _PFrac.from(sign * n, d);
    }

    return _PFrac.from(sign * int.parse(s), 1);
  }

  bool get isZero => num == 0;
  bool get isNegative => num < 0;
  bool get isAbsOne => num.abs() == 1 && den == 1;

  _PFrac abs() => _PFrac(num.abs(), den);
  _PFrac operator +(_PFrac other) =>
      _PFrac.from(num * other.den + other.num * den, den * other.den);
  _PFrac operator *(_PFrac other) =>
      _PFrac.from(num * other.num, den * other.den);
  _PFrac operator /(_PFrac other) =>
      _PFrac.from(num * other.den, den * other.num);

  static int? _exactSqrtInt(int n) {
    if (n < 0) return null;
    if (n == 0) return 0;
    final int r = math.sqrt(n).round();
    return (r * r == n) ? r : null;
  }

  _PFrac? exactSqrt() {
    if (num < 0) return null;
    final int? rn = _exactSqrtInt(num);
    final int? rd = _exactSqrtInt(den);
    if (rn == null || rd == null) return null;
    return _PFrac.from(rn, rd);
  }

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

class PerfectSquaresLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 75–77: Example 4a–e & Exercise 8.4 #1–20)
  // ===========================================================================
  static const List<PerfectSquaresPreset> textbookPresets = [
    PerfectSquaresPreset(
      chipLabel: "Example 4a (Page 75): x² + 6x + 9",
      mode: 0,
      exprInput: 'x^2 + 6x + 9',
    ),
    PerfectSquaresPreset(
      chipLabel: "Example 4b (Page 75): 4x² + 8xy + 4y² (Both Forms!)",
      mode: 0,
      exprInput: '4x^2 + 8xy + 4y^2',
    ),
    PerfectSquaresPreset(
      chipLabel: "Example 4c (Page 75): x² + 2xy + y²",
      mode: 0,
      exprInput: 'x^2 + 2xy + y^2',
    ),
    PerfectSquaresPreset(
      chipLabel: "Example 4d (Page 75): 4x² - 4xy + y²",
      mode: 0,
      exprInput: '4x^2 - 4xy + y^2',
    ),
    PerfectSquaresPreset(
      chipLabel: "Example 4e (Page 75): x² - 8x + 16",
      mode: 0,
      exprInput: 'x^2 - 8x + 16',
    ),
    PerfectSquaresPreset(
      chipLabel: "Ex 8.4 #2 (Page 77): 4x² - 4x + 1",
      mode: 0,
      exprInput: '4x^2 - 4x + 1',
    ),
    PerfectSquaresPreset(
      chipLabel: "Ex 8.4 #7 (Page 77): 25y² - 30y + 9",
      mode: 0,
      exprInput: '25y^2 - 30y + 9',
    ),
    PerfectSquaresPreset(
      chipLabel: "Ex 8.4 #9 (Page 77): 36x² - 60x + 25",
      mode: 0,
      exprInput: '36x^2 - 60x + 25',
    ),
    PerfectSquaresPreset(
      chipLabel: "Ex 8.4 #10 (Page 77): 4a² + 28a + 49",
      mode: 0,
      exprInput: '4a^2 + 28a + 49',
    ),
    PerfectSquaresPreset(
      chipLabel: "Ex 8.4 #11 (Page 77): 4b² - 44b + 121",
      mode: 0,
      exprInput: '4b^2 - 44b + 121',
    ),
    PerfectSquaresPreset(
      chipLabel: "Ex 8.4 #13 (Page 77): d² - 30d + 225",
      mode: 0,
      exprInput: 'd^2 - 30d + 225',
    ),
    PerfectSquaresPreset(
      chipLabel: "Ex 8.4 #17 (Page 77): 49 - 28b + 4b²",
      mode: 0,
      exprInput: '49 - 28b + 4b^2',
    ),
    PerfectSquaresPreset(
      chipLabel: "Ex 8.4 #19 (Page 77): 81w² + 90w + 25",
      mode: 0,
      exprInput: '81w^2 + 90w + 25',
    ),
    PerfectSquaresPreset(
      chipLabel: "Ex 8.4 #20 (Page 77): 1 - 2p + p²",
      mode: 0,
      exprInput: '1 - 2p + p^2',
    ),
    PerfectSquaresPreset(
      chipLabel: "Fractional Perfect Square: x² + x + 1/4",
      mode: 0,
      exprInput: 'x^2 + x + 1/4',
    ),
    PerfectSquaresPreset(
      chipLabel: "Missing Middle Term Exam Question: 9x² + [ ? ] + 16",
      mode: 1,
      term1Input: '9x^2',
      term2Input: '16',
      missingPosition: 0,
    ),
  ];

  static String _formatTermLaTeX(
      _PFrac c,
      String varPart, {
        bool isFirst = false,
      }) {
    if (c.isZero) return isFirst ? '0' : '+ 0';
    final String sign =
    c.isNegative ? (isFirst ? '-' : '- ') : (isFirst ? '' : '+ ');
    final _PFrac ac = c.abs();
    if (varPart.isEmpty) return '$sign${ac.toLaTeX()}';
    if (ac.isAbsOne) return '$sign$varPart';
    return '$sign${ac.toLaTeX()}$varPart';
  }

  static String _formatTermPlain(
      _PFrac c,
      String varPart, {
        bool isFirst = false,
      }) {
    if (c.isZero) return isFirst ? '0' : '+ 0';
    final String sign =
    c.isNegative ? (isFirst ? '-' : '- ') : (isFirst ? '' : '+ ');
    final _PFrac ac = c.abs();
    if (varPart.isEmpty) return '$sign${ac.toPlain()}';
    if (ac.isAbsOne) return '$sign$varPart';
    return '$sign${ac.toPlain()}$varPart';
  }

  /// Parses a 3-term perfect square trinomial (preserving order for expressions like 49 - 28b + 4b^2 or 1 - 2p + p^2!)
  static Map<String, dynamic> _parsePerfectSquareTrinomial(String raw) {
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
    if (chunks.length != 3) {
      throw const FormatException(
        "Please enter a 3-term quadratic expression (e.g. x^2 + 6x + 9, 4x^2 - 4xy + y^2, or 1 - 2p + p^2).",
      );
    }

    // Parse each of the 3 terms in the exact order given by the user/textbook
    final List<Map<String, dynamic>> parsedTerms = [];
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
      _PFrac coeff = _PFrac.from(sign, 1);
      String rem = ch;
      if (nm != null) {
        final _PFrac p = _PFrac.parse(nm.group(1)!);
        coeff = _PFrac.from(sign * p.num, p.den);
        rem = ch.substring(nm.end);
      }

      if (rem.contains('/')) {
        final List<String> sp = rem.split('/');
        rem = sp[0];
        if (sp.length > 1 && sp[1].isNotEmpty) {
          coeff = _PFrac.from(coeff.num, coeff.den * int.parse(sp[1]));
        }
      }

      final Map<String, int> vp = {};
      for (final Match m in RegExp(r'([a-zA-Z])(?:\^(\d+))?').allMatches(rem)) {
        final String v = m.group(1)!;
        final int pow = int.tryParse(m.group(2) ?? '1') ?? 1;
        vp[v] = (vp[v] ?? 0) + pow;
      }

      parsedTerms.add({
        'coeff': coeff,
        'vars': vp,
      });
    }

    return {'terms': parsedTerms};
  }

  static String _varsMapToLaTeX(Map<String, int> vp) {
    final List<String> keys = vp.keys.toList()..sort();
    final StringBuffer sb = StringBuffer();
    for (final String k in keys) {
      final int p = vp[k]!;
      sb.write(k);
      if (p > 1) sb.write('^{$p}');
    }
    return sb.toString();
  }

  static String _varsMapToPlain(Map<String, int> vp) {
    return _varsMapToLaTeX(vp).replaceAll('{', '').replaceAll('}', '');
  }

  // ===========================================================================
  // MODE 0: FACTORISE PERFECT SQUARE QUADRATIC (BOTH METHOD 1 & METHOD 2, Page 76)
  // ===========================================================================
  static PerfectSquaresResult solvePerfectSquareFactorisation(String rawExpr) {
    try {
      if (rawExpr.trim().isEmpty) {
        throw const FormatException(
          "Please enter a quadratic expression to factorise (e.g. x^2 + 6x + 9 or 4x^2 - 4xy + y^2).",
        );
      }

      final Map<String, dynamic> parsed = _parsePerfectSquareTrinomial(rawExpr);
      final List<Map<String, dynamic>> terms =
      parsed['terms'] as List<Map<String, dynamic>>;

      final _PFrac c1 = terms[0]['coeff'] as _PFrac;
      final Map<String, int> v1Map = terms[0]['vars'] as Map<String, int>;

      final _PFrac c2 = terms[1]['coeff'] as _PFrac;
      final Map<String, int> v2Map = terms[1]['vars'] as Map<String, int>;

      final _PFrac c3 = terms[2]['coeff'] as _PFrac;
      final Map<String, int> v3Map = terms[2]['vars'] as Map<String, int>;

      // Verify first and third terms are positive perfect squares
      final _PFrac? r1 = c1.exactSqrt();
      final _PFrac? r3 = c3.exactSqrt();

      if (r1 == null || r3 == null || c1.isZero || c3.isZero) {
        throw const FormatException(
          "The first and third terms must be positive perfect squares (e.g. x^2, 4x^2, 9, 16, 25y^2).",
        );
      }

      // Check variable powers of 1st and 3rd terms are even
      final Map<String, int> halfV1 = {};
      for (final entry in v1Map.entries) {
        if (entry.value % 2 != 0) {
          throw FormatException(
              "The power of '${entry.key}' in the first term must be even for a perfect square.");
        }
        halfV1[entry.key] = entry.value ~/ 2;
      }

      final Map<String, int> halfV3 = {};
      for (final entry in v3Map.entries) {
        if (entry.value % 2 != 0) {
          throw FormatException(
              "The power of '${entry.key}' in the third term must be even for a perfect square.");
        }
        halfV3[entry.key] = entry.value ~/ 2;
      }

      // Expected middle term = ± 2 * (r1 * halfV1) * (r3 * halfV3)
      final _PFrac expectedMidAbs = const _PFrac(2, 1) * r1 * r3;
      final Map<String, int> expectedMidVars = Map.from(halfV1);
      halfV3.forEach((String k, int v) {
        expectedMidVars[k] = (expectedMidVars[k] ?? 0) + v;
      });

      final String actualMidSig = _varsMapToLaTeX(v2Map);
      final String expectedMidSig = _varsMapToLaTeX(expectedMidVars);

      if (c2.abs().num != expectedMidAbs.num ||
          c2.abs().den != expectedMidAbs.den ||
          actualMidSig != expectedMidSig) {
        final String expectedMidLaTeX =
        _formatTermLaTeX(expectedMidAbs, expectedMidSig, isFirst: true);
        throw FormatException(
          "Not a perfect square trinomial: for first term ${_formatTermPlain(c1, _varsMapToPlain(v1Map), isFirst: true)} and last term ${_formatTermPlain(c3, _varsMapToPlain(v3Map), isFirst: true)}, the middle term must be ±$expectedMidLaTeX.",
        );
      }

      final bool isMinus = c2.isNegative;
      final String signOp = isMinus ? '-' : '+';

      final String v1FullLaTeX = _varsMapToLaTeX(v1Map);
      final String v2FullLaTeX = _varsMapToLaTeX(v2Map);
      final String v3FullLaTeX = _varsMapToLaTeX(v3Map);

      final String aRootVarsLaTeX = _varsMapToLaTeX(halfV1);
      final String bRootVarsLaTeX = _varsMapToLaTeX(halfV3);

      final String aRootLaTeX =
      _formatTermLaTeX(r1, aRootVarsLaTeX, isFirst: true);
      final String bRootLaTeX =
      _formatTermLaTeX(r3, bRootVarsLaTeX, isFirst: true);
      final String aRootPlain =
      _formatTermPlain(r1, _varsMapToPlain(halfV1), isFirst: true);
      final String bRootPlain =
      _formatTermPlain(r3, _varsMapToPlain(halfV3), isFirst: true);

      final String t1LaTeX = _formatTermLaTeX(c1, v1FullLaTeX, isFirst: true);
      final String t2LaTeX = _formatTermLaTeX(c2, v2FullLaTeX, isFirst: false);
      final String t3LaTeX = _formatTermLaTeX(c3, v3FullLaTeX, isFirst: false);
      final String givenQuadLaTeX = "$t1LaTeX $t2LaTeX $t3LaTeX";

      // Decomposed form: (A)^2 ± 2(A)(B) + (B)^2 (Page 76 Method 1)
      final String decomposedLineLaTeX =
          "($aRootLaTeX)^2 $signOp 2($aRootLaTeX)($bRootLaTeX) + ($bRootLaTeX)^2";
      final String primaryFactoredLaTeX = "($aRootLaTeX $signOp $bRootLaTeX)^2";

      // Check if there is a common numerical square factor like in Example 4b: 4x^2 + 8xy + 4y^2 = (2x + 2y)^2 = 4(x + y)^2
      String? equivalentFactoredHcfLaTeX;
      final List<String> hcfEquivalenceLinesLaTeX = [];
      if (r1.den == 1 && r3.den == 1) {
        final int gRoot = _PFrac.gcd(r1.num, r3.num);
        if (gRoot > 1) {
          final int sqFactor = gRoot * gRoot;
          final _PFrac innerR1 = _PFrac.from(r1.num ~/ gRoot, 1);
          final _PFrac innerR3 = _PFrac.from(r3.num ~/ gRoot, 1);
          final String innerALaTeX =
          _formatTermLaTeX(innerR1, aRootVarsLaTeX, isFirst: true);
          final String innerBLaTeX =
          _formatTermLaTeX(innerR3, bRootVarsLaTeX, isFirst: true);
          equivalentFactoredHcfLaTeX =
          "$sqFactor($innerALaTeX $signOp $innerBLaTeX)^2";

          final String innerQuadLaTeX =
              "${_formatTermLaTeX(_PFrac.from(c1.num ~/ sqFactor), v1FullLaTeX, isFirst: true)} ${_formatTermLaTeX(_PFrac.from(c2.num ~/ sqFactor), v2FullLaTeX)} ${_formatTermLaTeX(_PFrac.from(c3.num ~/ sqFactor), v3FullLaTeX)}";

          hcfEquivalenceLinesLaTeX.addAll([
            "\\text{Similarly, the expression above may be factorised by extracting the common factor } $sqFactor \\text{ first (Example 4b, Page 76):}",
            "$givenQuadLaTeX = $sqFactor($innerQuadLaTeX)",
            "= $sqFactor\\left[($innerALaTeX)^2 $signOp 2($innerALaTeX)($innerBLaTeX) + ($innerBLaTeX)^2\\right]",
            "= \\mathbf{$equivalentFactoredHcfLaTeX}",
            "\\text{Note: } $primaryFactoredLaTeX \\text{ and } $equivalentFactoredHcfLaTeX \\text{ are completely equivalent!}",
          ]);
        }
      }

      // Method 2: Splitting the middle term into two equal halves (Page 76 Method 2!)
      final _PFrac halfMidCoeff = c2 / const _PFrac(2, 1);
      final String halfMidLaTeX =
      _formatTermLaTeX(halfMidCoeff, v2FullLaTeX, isFirst: false);
      final String halfMidInsidePosLaTeX =
      _formatTermLaTeX(halfMidCoeff.abs(), v2FullLaTeX, isFirst: true);
      final String t3InsideSignedLaTeX = isMinus
          ? _formatTermLaTeX(_PFrac(-c3.num, c3.den), v3FullLaTeX,
          isFirst: false)
          : _formatTermLaTeX(c3, v3FullLaTeX, isFirst: false);

      final String method2SplitLaTeX =
          "$t1LaTeX $halfMidLaTeX $halfMidLaTeX $t3LaTeX";
      final String method2GroupedLaTeX =
          "($t1LaTeX $halfMidLaTeX) $signOp ($halfMidInsidePosLaTeX $t3InsideSignedLaTeX)";
      final String method2FactoredPairsLaTeX =
          "$aRootLaTeX($aRootLaTeX $signOp $bRootLaTeX) $signOp $bRootLaTeX($aRootLaTeX $signOp $bRootLaTeX)";
      final String method2DoubleBracketLaTeX =
          "($aRootLaTeX $signOp $bRootLaTeX)($aRootLaTeX $signOp $bRootLaTeX)";

      // Build Visualisation Comparison Box in LaTeX
      final String decompositionBoxLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Method 1: Identity Decomposition (Page 76)} & \\textbf{Method 2: Splitting Middle Term (Page 76)} \\\\ \\hline "
          "$givenQuadLaTeX & $givenQuadLaTeX \\\\ "
          "= $decomposedLineLaTeX & = $method2SplitLaTeX \\\\ "
          "\\swarrow \\qquad \\qquad \\searrow & = $method2FactoredPairsLaTeX \\\\ "
          "= \\mathbf{$primaryFactoredLaTeX} & = $method2DoubleBracketLaTeX = \\mathbf{$primaryFactoredLaTeX} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Given Perfect Square Quadratic Expression (Pages 75–76):}}",
        "\\mathbf{$givenQuadLaTeX}",
        "",
        "\\text{\\textbf{Method 1: Identity Decomposition Method (Page 76)}}",
        "\\text{To factorise any perfect square quadratic, we decompose the expansion into either:}",
        "(a + b)^2 = a^2 + 2ab + b^2 \\quad \\text{or} \\quad (a - b)^2 = a^2 - 2ab + b^2",
        "\\bullet \\text{ Square root of 1st term: } \\sqrt{$t1LaTeX} = \\mathbf{$aRootLaTeX}",
        "\\bullet \\text{ Square root of 3rd term: } \\sqrt{${_formatTermLaTeX(c3, v3FullLaTeX, isFirst: true)}} = \\mathbf{$bRootLaTeX}",
        "\\bullet \\text{ Middle term check: } $signOp 2($aRootLaTeX)($bRootLaTeX) = \\mathbf{$t2LaTeX} \\quad \\checkmark",
        "\\text{Hence:}",
        "$givenQuadLaTeX = $decomposedLineLaTeX",
        "= \\mathbf{$primaryFactoredLaTeX}",
        if (hcfEquivalenceLinesLaTeX.isNotEmpty) ...[
          "",
          ...hcfEquivalenceLinesLaTeX,
        ],
        "",
        "\\text{\\textbf{Method 2: Factorisation by Grouping / Splitting Method (Page 76)}}",
        "$givenQuadLaTeX = $method2SplitLaTeX",
        "= $method2GroupedLaTeX",
        "= $method2FactoredPairsLaTeX",
        "\\text{Since } ($aRootLaTeX $signOp $bRootLaTeX) \\text{ is a common factor:}",
        "= $method2DoubleBracketLaTeX",
        "= \\mathbf{$primaryFactoredLaTeX}",
      ];

      final List<PerfectSquaresStep> steps = [
        PerfectSquaresStep(
          title: "Step 1: Verify the Perfect Square Conditions (Page 75)",
          description:
          "• First term ($t1LaTeX) is a perfect square: ($aRootPlain)².\n"
              "• Third term (${_formatTermPlain(c3, _varsMapToPlain(v3Map), isFirst: true)}) is a perfect square: ($bRootPlain)².\n"
              "• Middle term ($t2LaTeX) is exactly ${isMinus ? '−' : '+'}2 × ($aRootPlain) × ($bRootPlain).",
          mathLinesLaTeX: [
            "a = $aRootLaTeX, \\qquad b = $bRootLaTeX",
            "2ab = 2($aRootLaTeX)($bRootLaTeX) = ${_formatTermLaTeX(c2.abs(), v2FullLaTeX, isFirst: true)}",
          ],
        ),
        PerfectSquaresStep(
          title: "Step 2: Method 1 — Decompose into (a $signOp b)² Identity (Page 76)",
          description:
          "• Using the perfect square identity a² $signOp 2ab + b² = (a $signOp b)², rewrite the expression and compress it into a squared binomial.",
          mathLinesLaTeX: [
            "$givenQuadLaTeX = $decomposedLineLaTeX",
            "= \\mathbf{$primaryFactoredLaTeX}",
            if (hcfEquivalenceLinesLaTeX.isNotEmpty)
              ...hcfEquivalenceLinesLaTeX,
          ],
        ),
        PerfectSquaresStep(
          title: "Step 3: Method 2 — Split the Middle Term into Two Equal Halves (Page 76)",
          description:
          "• Alternatively, split the middle term ($t2LaTeX) into two identical terms ($halfMidLaTeX $halfMidLaTeX) and factorise by grouping in pairs.",
          mathLinesLaTeX: [
            "$givenQuadLaTeX = $method2SplitLaTeX",
            "= $method2GroupedLaTeX",
            "= $method2FactoredPairsLaTeX",
            "= $method2DoubleBracketLaTeX = \\mathbf{$primaryFactoredLaTeX}",
          ],
        ),
      ];

      return PerfectSquaresResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Given Expression": givenQuadLaTeX,
          "Square Roots (a, b)": "a = $aRootLaTeX,\\; b = $bRootLaTeX",
          "Factorised Form": "\\mathbf{$primaryFactoredLaTeX}",
          if (equivalentFactoredHcfLaTeX != null)
            "Equivalent HCF Form": "\\mathbf{$equivalentFactoredHcfLaTeX}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: PerfectSquaresCanvasData(
          headerLaTeX:
          "\\text{Perfect Squares (Pages 75–76): } $givenQuadLaTeX = \\mathbf{$primaryFactoredLaTeX}",
          subHeaderLaTeX:
          "\\text{Identity: } a^2 $signOp 2ab + b^2 = (a $signOp b)^2 \\quad \\text{where } a = $aRootLaTeX, \\; b = $bRootLaTeX",
          card1Title: "1st Root (a)",
          card1LaTeX: "\\mathbf{$aRootLaTeX}",
          card2Title: "Middle Term (±2ab)",
          card2LaTeX: "\\mathbf{$t2LaTeX}",
          card3Title: "Perfect Square",
          card3LaTeX: "\\mathbf{$primaryFactoredLaTeX}",
          decompositionBoxLaTeX: decompositionBoxLaTeX,
          bottomSummaryLaTeX: equivalentFactoredHcfLaTeX != null
              ? "\\therefore \\; $givenQuadLaTeX = \\mathbf{$primaryFactoredLaTeX} \\; \\text{or} \\; \\mathbf{$equivalentFactoredHcfLaTeX}"
              : "\\therefore \\; $givenQuadLaTeX = \\mathbf{$primaryFactoredLaTeX}",
        ),
      );
    } catch (e) {
      return PerfectSquaresResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter a valid perfect square quadratic expression.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: FIND MISSING TERM TO MAKE A PERFECT SQUARE (Exam Extension)
  // ===========================================================================
  static PerfectSquaresResult solveMissingTermForPerfectSquare({
    required String term1Raw,
    required String term2Raw,
    required int missingPosition, // 0: Middle missing, 1: Last missing, 2: First missing
  }) {
    try {
      if (term1Raw.trim().isEmpty || term2Raw.trim().isEmpty) {
        throw const FormatException(
          "Please enter both known terms to find the missing term (e.g. 9x^2 and 16).",
        );
      }

      // Parse known terms using single-term helper
      final Map<String, dynamic> p1 =
      (_parsePerfectSquareTrinomial("${term1Raw.trim()} + x + 1")['terms']
      as List<Map<String, dynamic>>)[0];
      final Map<String, dynamic> p2 =
      (_parsePerfectSquareTrinomial("${term2Raw.trim()} + x + 1")['terms']
      as List<Map<String, dynamic>>)[0];

      final _PFrac c1 = p1['coeff'] as _PFrac;
      final Map<String, int> v1 = p1['vars'] as Map<String, int>;
      final _PFrac c2 = p2['coeff'] as _PFrac;
      final Map<String, int> v2 = p2['vars'] as Map<String, int>;

      if (missingPosition == 0) {
        // Given A^2 (first term) and B^2 (last term), find middle term ±2AB
        final _PFrac? r1 = c1.exactSqrt();
        final _PFrac? r3 = c2.exactSqrt();
        if (r1 == null || r3 == null) {
          throw const FormatException(
            "Both the first and last terms must be positive perfect squares (e.g. 9x^2 and 16).",
          );
        }
        final Map<String, int> halfV1 =
        v1.map((String k, int val) => MapEntry(k, val ~/ 2));
        final Map<String, int> halfV3 =
        v2.map((String k, int val) => MapEntry(k, val ~/ 2));

        final _PFrac midCoeff = const _PFrac(2, 1) * r1 * r3;
        final Map<String, int> midVars = Map.from(halfV1);
        halfV3.forEach((String k, int val) {
          midVars[k] = (midVars[k] ?? 0) + val;
        });

        final String aLaTeX =
        _formatTermLaTeX(r1, _varsMapToLaTeX(halfV1), isFirst: true);
        final String bLaTeX =
        _formatTermLaTeX(r3, _varsMapToLaTeX(halfV3), isFirst: true);
        final String midTermLaTeX =
        _formatTermLaTeX(midCoeff, _varsMapToLaTeX(midVars), isFirst: true);
        final String t1LaTeX =
        _formatTermLaTeX(c1, _varsMapToLaTeX(v1), isFirst: true);
        final String t3LaTeX =
        _formatTermLaTeX(c2, _varsMapToLaTeX(v2), isFirst: true);

        final List<String> workings = [
          "\\text{\\textbf{Problem: Find the Missing Middle Term to Make a Perfect Square}}",
          "\\text{Given First Term } (a^2) = $t1LaTeX, \\qquad \\text{Given Third Term } (b^2) = $t3LaTeX",
          "\\bullet \\; a = \\sqrt{$t1LaTeX} = \\mathbf{$aLaTeX}",
          "\\bullet \\; b = \\sqrt{$t3LaTeX} = \\mathbf{$bLaTeX}",
          "\\bullet \\; \\text{Middle Term} = \\pm 2ab = \\pm 2($aLaTeX)($bLaTeX) = \\mathbf{\\pm $midTermLaTeX}",
          "\\therefore \\; \\text{Complete Perfect Square} = $t1LaTeX \\pm $midTermLaTeX + $t3LaTeX = \\mathbf{($aLaTeX \\pm $bLaTeX)^2}",
        ];

        return PerfectSquaresResult(
          mode: 1,
          finalAnswersLaTeX: {
            "1st Term (a²)": t1LaTeX,
            "3rd Term (b²)": t3LaTeX,
            "Missing Middle Term": "\\mathbf{\\pm $midTermLaTeX}",
            "Factored Square": "\\mathbf{($aLaTeX \\pm $bLaTeX)^2}",
          },
          workingsLaTeX: workings,
          steps: [
            PerfectSquaresStep(
              title: "Step 1: Find the Square Roots of the First and Last Terms",
              description:
              "Take the square root of the first term ($t1LaTeX) to get a = $aLaTeX, and the square root of the third term ($t3LaTeX) to get b = $bLaTeX.",
              mathLinesLaTeX: [
                "a = \\sqrt{$t1LaTeX} = $aLaTeX, \\qquad b = \\sqrt{$t3LaTeX} = $bLaTeX",
              ],
            ),
            PerfectSquaresStep(
              title: "Step 2: Compute Middle Term = ±2ab",
              description:
              "In any perfect square a² ± 2ab + b², the middle term is twice the product of a and b.",
              mathLinesLaTeX: [
                "\\text{Middle Term} = \\pm 2($aLaTeX)($bLaTeX) = \\mathbf{\\pm $midTermLaTeX}",
                "$t1LaTeX \\pm $midTermLaTeX + $t3LaTeX = \\mathbf{($aLaTeX \\pm $bLaTeX)^2}",
              ],
            ),
          ],
          canvasData: PerfectSquaresCanvasData(
            headerLaTeX:
            "\\text{Missing Middle Term: } $t1LaTeX + [\\; \\mathbf{\\pm $midTermLaTeX} \\;] + $t3LaTeX = \\mathbf{($aLaTeX \\pm $bLaTeX)^2}",
            subHeaderLaTeX:
            "\\text{Rule: Middle Term } = \\pm 2ab = \\pm 2($aLaTeX)($bLaTeX) = \\mathbf{\\pm $midTermLaTeX}",
            card1Title: "1st Root (a)",
            card1LaTeX: "\\mathbf{$aLaTeX}",
            card2Title: "3rd Root (b)",
            card2LaTeX: "\\mathbf{$bLaTeX}",
            card3Title: "Missing Middle (±2ab)",
            card3LaTeX: "\\mathbf{\\pm $midTermLaTeX}",
            decompositionBoxLaTeX:
            "$t1LaTeX \\pm $midTermLaTeX + $t3LaTeX = ($aLaTeX)^2 \\pm 2($aLaTeX)($bLaTeX) + ($bLaTeX)^2 = \\mathbf{($aLaTeX \\pm $bLaTeX)^2}",
            bottomSummaryLaTeX:
            "\\therefore \\; \\text{Missing Middle Term} = \\mathbf{\\pm $midTermLaTeX}",
          ),
        );
      } else {
        // Missing Last Term (given 1st term a^2 and middle term ±2ab)
        final _PFrac? r1 = c1.exactSqrt();
        if (r1 == null || c1.isZero) {
          throw const FormatException(
            "The known squared term must be a positive perfect square (e.g. x^2, 4x^2, 9y^2).",
          );
        }
        final Map<String, int> halfV1 =
        v1.map((String k, int val) => MapEntry(k, val ~/ 2));
        final _PFrac bRoot = c2.abs() / (const _PFrac(2, 1) * r1);
        final _PFrac bSquared = bRoot * bRoot;

        final Map<String, int> bVars = Map.from(v2);
        halfV1.forEach((String k, int val) {
          final int rem = (bVars[k] ?? 0) - val;
          if (rem <= 0) {
            bVars.remove(k);
          } else {
            bVars[k] = rem;
          }
        });
        final Map<String, int> bSqVars =
        bVars.map((String k, int val) => MapEntry(k, val * 2));

        final String aLaTeX =
        _formatTermLaTeX(r1, _varsMapToLaTeX(halfV1), isFirst: true);
        final String bLaTeX =
        _formatTermLaTeX(bRoot, _varsMapToLaTeX(bVars), isFirst: true);
        final String bSqLaTeX =
        _formatTermLaTeX(bSquared, _varsMapToLaTeX(bSqVars), isFirst: true);
        final String t1LaTeX =
        _formatTermLaTeX(c1, _varsMapToLaTeX(v1), isFirst: true);
        final String midLaTeX =
        _formatTermLaTeX(c2, _varsMapToLaTeX(v2), isFirst: false);
        final String signOp = c2.isNegative ? '-' : '+';

        final List<String> workings = [
          "\\text{\\textbf{Problem: Find the Missing Constant / Third Term to Complete the Square}}",
          "\\text{Given 1st Term } (a^2) = $t1LaTeX, \\qquad \\text{Given Middle Term } (\\pm 2ab) = $midLaTeX",
          "\\bullet \\; a = \\sqrt{$t1LaTeX} = \\mathbf{$aLaTeX}",
          "\\bullet \\; 2ab = ${_formatTermLaTeX(c2.abs(), _varsMapToLaTeX(v2), isFirst: true)} \\implies b = \\frac{${_formatTermLaTeX(c2.abs(), _varsMapToLaTeX(v2), isFirst: true)}}{2($aLaTeX)} = \\mathbf{$bLaTeX}",
          "\\bullet \\; \\text{Missing Term } (b^2) = ($bLaTeX)^2 = \\mathbf{$bSqLaTeX}",
          "\\therefore \\; $t1LaTeX $midLaTeX + $bSqLaTeX = \\mathbf{($aLaTeX $signOp $bLaTeX)^2}",
        ];

        return PerfectSquaresResult(
          mode: 1,
          finalAnswersLaTeX: {
            "1st Root (a)": aLaTeX,
            "2nd Root (b)": bLaTeX,
            "Missing Square Term (b²)": "\\mathbf{+$bSqLaTeX}",
            "Completed Square": "\\mathbf{($aLaTeX $signOp $bLaTeX)^2}",
          },
          workingsLaTeX: workings,
          steps: [
            PerfectSquaresStep(
              title: "Step 1: Divide the Middle Term by 2a to Find b",
              description:
              "Since the first term is a² = $t1LaTeX, we have a = $aLaTeX. Dividing the middle term by 2a gives b = $bLaTeX.",
              mathLinesLaTeX: [
                "a = $aLaTeX, \\qquad b = \\frac{${_formatTermLaTeX(c2.abs(), _varsMapToLaTeX(v2), isFirst: true)}}{2($aLaTeX)} = \\mathbf{$bLaTeX}",
              ],
            ),
            PerfectSquaresStep(
              title: "Step 2: Square b to Obtain the Missing Term b²",
              description:
              "Square b = $bLaTeX to get the missing term b² = $bSqLaTeX.",
              mathLinesLaTeX: [
                "b^2 = ($bLaTeX)^2 = \\mathbf{$bSqLaTeX}",
                "$t1LaTeX $midLaTeX + $bSqLaTeX = \\mathbf{($aLaTeX $signOp $bLaTeX)^2}",
              ],
            ),
          ],
          canvasData: PerfectSquaresCanvasData(
            headerLaTeX:
            "\\text{Complete the Square: } $t1LaTeX $midLaTeX + \\mathbf{$bSqLaTeX} = \\mathbf{($aLaTeX $signOp $bLaTeX)^2}",
            subHeaderLaTeX:
            "b = \\frac{\\text{Middle Term}}{2a} = $bLaTeX \\quad \\Longrightarrow \\quad b^2 = \\mathbf{$bSqLaTeX}",
            card1Title: "1st Root (a)",
            card1LaTeX: "\\mathbf{$aLaTeX}",
            card2Title: "2nd Root (b)",
            card2LaTeX: "\\mathbf{$bLaTeX}",
            card3Title: "Missing Term (b²)",
            card3LaTeX: "\\mathbf{+$bSqLaTeX}",
            decompositionBoxLaTeX:
            "$t1LaTeX $midLaTeX + $bSqLaTeX = ($aLaTeX)^2 $signOp 2($aLaTeX)($bLaTeX) + ($bLaTeX)^2 = \\mathbf{($aLaTeX $signOp $bLaTeX)^2}",
            bottomSummaryLaTeX:
            "\\therefore \\; \\text{Missing Term} = \\mathbf{+$bSqLaTeX}",
          ),
        );
      }
    } catch (e) {
      return PerfectSquaresResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid algebraic terms.",
      );
    }
  }
}