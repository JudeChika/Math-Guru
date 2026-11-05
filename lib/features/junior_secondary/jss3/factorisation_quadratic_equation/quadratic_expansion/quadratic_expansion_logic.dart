import 'quadratic_expansion_models.dart';

/// Exact Rational Number (Fraction) Engine so every fraction is rendered via \frac{num}{den} in Math.tex!
class _Frac {
  final int num;
  final int den;

  const _Frac(this.num, [this.den = 1]);

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

  factory _Frac.from(int n, [int d = 1]) {
    if (d == 0) throw const FormatException("Denominator cannot be zero.");
    if (n == 0) return const _Frac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = _gcd(an, ad);
    return _Frac(sign * (an ~/ g), ad ~/ g);
  }

  factory _Frac.parse(String raw) {
    String s = raw.trim().replaceAll(' ', '').replaceAll('−', '-');
    if (s.isEmpty || s == '+') return const _Frac(1, 1);
    if (s == '-') return const _Frac(-1, 1);

    int sign = 1;
    if (s.startsWith('-')) {
      sign = -1;
      s = s.substring(1);
    } else if (s.startsWith('+')) {
      s = s.substring(1);
    }
    if (s.isEmpty) return _Frac(sign, 1);

    if (s.contains('/')) {
      final List<String> parts = s.split('/');
      if (parts.length != 2) {
        throw FormatException("Invalid fraction coefficient '$raw'.");
      }
      final int n = int.parse(parts[0]);
      final int d = int.parse(parts[1]);
      return _Frac.from(sign * n, d);
    }

    if (s.contains('.')) {
      final List<String> parts = s.split('.');
      final String decPart = parts[1];
      int d = 1;
      for (int i = 0; i < decPart.length; i++) {
        d *= 10;
      }
      final int n = int.parse(parts[0]) * d + int.parse(decPart);
      return _Frac.from(sign * n, d);
    }

    return _Frac.from(sign * int.parse(s), 1);
  }

  bool get isZero => num == 0;
  bool get isNegative => num < 0;
  bool get isFraction => den != 1;
  bool get isAbsOne => num.abs() == 1 && den == 1;

  _Frac abs() => _Frac(num.abs(), den);
  _Frac operator +(_Frac other) =>
      _Frac.from(num * other.den + other.num * den, den * other.den);
  _Frac operator -(_Frac other) =>
      _Frac.from(num * other.den - other.num * den, den * other.den);
  _Frac operator *(_Frac other) => _Frac.from(num * other.num, den * other.den);

  String toLaTeX({bool withSign = false}) {
    if (num == 0) return withSign ? '+ 0' : '0';
    final String signStr = num < 0 ? (withSign ? '- ' : '-') : (withSign ? '+ ' : '');
    final int an = num.abs();
    if (den == 1) return '$signStr$an';
    return '$signStr\\frac{$an}{$den}';
  }

  String toPlain({bool withSign = false}) {
    if (num == 0) return withSign ? '+ 0' : '0';
    final String signStr = num < 0 ? (withSign ? '- ' : '-') : (withSign ? '+ ' : '');
    final int an = num.abs();
    if (den == 1) return '$signStr$an';
    return '$signStr$an/$den';
  }
}

/// Exact Rational Algebraic Monomial (e.g., 2a, -3y, \frac{2}{3}x^2, -15y^2)
class _QTerm {
  final _Frac coeff;
  final Map<String, int> vars;

  const _QTerm({
    required this.coeff,
    required this.vars,
  });

  static _QTerm parse(String raw) {
    String s = raw
        .trim()
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3');
    if (s.isEmpty) return const _QTerm(coeff: _Frac(0, 1), vars: {});

    int sign = 1;
    if (s.startsWith('-')) {
      sign = -1;
      s = s.substring(1);
    } else if (s.startsWith('+')) {
      s = s.substring(1);
    }

    // Extract leading numeric/fractional prefix (e.g. 2/3, 12, 3.5)
    final RegExp prefixReg = RegExp(r'^(\d+(?:/\d+|\.\d+)?)');
    final Match? pm = prefixReg.firstMatch(s);
    _Frac c = _Frac.from(sign, 1);
    String rem = s;
    if (pm != null) {
      final _Frac parsedAbs = _Frac.parse(pm.group(1)!);
      c = _Frac.from(sign * parsedAbs.num, parsedAbs.den);
      rem = s.substring(pm.end);
    }

    // Check if there is a denominator at the end like x/3 or 2a/5
    int trailingDen = 1;
    if (rem.contains('/')) {
      final List<String> slashParts = rem.split('/');
      rem = slashParts[0];
      if (slashParts.length > 1 && slashParts[1].isNotEmpty) {
        trailingDen = int.tryParse(slashParts[1]) ?? 1;
      }
    }
    c = _Frac.from(c.num, c.den * trailingDen);

    final Map<String, int> vp = {};
    final RegExp varReg = RegExp(r'([a-zA-Z])(?:\^(\d+))?');
    for (final Match m in varReg.allMatches(rem)) {
      final String v = m.group(1)!;
      final int p = int.tryParse(m.group(2) ?? '1') ?? 1;
      vp[v] = (vp[v] ?? 0) + p;
    }

    return _QTerm(coeff: c, vars: vp);
  }

  _QTerm multiply(_QTerm other) {
    final Map<String, int> nextVars = Map.from(vars);
    other.vars.forEach((String k, int v) {
      nextVars[k] = (nextVars[k] ?? 0) + v;
    });
    return _QTerm(
      coeff: coeff * other.coeff,
      vars: nextVars,
    );
  }

  String get signature {
    final List<String> keys = vars.keys.toList()..sort();
    final StringBuffer sb = StringBuffer();
    for (final String k in keys) {
      sb.write('$k^${vars[k]};');
    }
    return sb.toString();
  }

  String get varsLaTeX {
    final List<String> keys = vars.keys.toList()..sort();
    final StringBuffer sb = StringBuffer();
    for (final String k in keys) {
      final int p = vars[k]!;
      sb.write(k);
      if (p > 1) sb.write('^{$p}');
    }
    return sb.toString();
  }

  String get varsPlain {
    final List<String> keys = vars.keys.toList()..sort();
    final StringBuffer sb = StringBuffer();
    for (final String k in keys) {
      final int p = vars[k]!;
      sb.write(k);
      if (p > 1) sb.write('^$p');
    }
    return sb.toString();
  }

  String toLaTeX({bool withSign = false}) {
    if (coeff.isZero) return withSign ? '+ 0' : '0';
    final bool hasVars = vars.isNotEmpty;
    final String signStr =
    coeff.isNegative ? (withSign ? '- ' : '-') : (withSign ? '+ ' : '');
    final _Frac absC = coeff.abs();

    final StringBuffer sb = StringBuffer(signStr);
    if (!hasVars || !absC.isAbsOne) {
      sb.write(absC.toLaTeX());
    }
    sb.write(varsLaTeX);
    return sb.toString().trim();
  }

  String toPlain({bool withSign = false}) {
    if (coeff.isZero) return withSign ? '+ 0' : '0';
    final bool hasVars = vars.isNotEmpty;
    final String signStr =
    coeff.isNegative ? (withSign ? '- ' : '-') : (withSign ? '+ ' : '');
    final _Frac absC = coeff.abs();

    final StringBuffer sb = StringBuffer(signStr);
    if (!hasVars || !absC.isAbsOne) {
      sb.write(absC.toPlain());
    }
    sb.write(varsPlain);
    return sb.toString().trim();
  }
}

class QuadraticExpansionLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Page 73 Example 1a–g, Exercise 8.1 #1–44 & Rev Ex 8A)
  // ===========================================================================
  static const List<QuadraticExpansionPreset> textbookPresets = [
    QuadraticExpansionPreset(
      chipLabel: "Example 1a (Page 73): (2a + b)(3c - d)",
      mode: 0,
      input1: '2a + b',
      input2: '3c - d',
    ),
    QuadraticExpansionPreset(
      chipLabel: "Example 1b (Page 73): (3x + 5y)(4x - 3y)",
      mode: 0,
      input1: '3x + 5y',
      input2: '4x - 3y',
    ),
    QuadraticExpansionPreset(
      chipLabel: "Example 1c (Page 73): (x + 2)(x - 5)",
      mode: 0,
      input1: 'x + 2',
      input2: 'x - 5',
    ),
    QuadraticExpansionPreset(
      chipLabel: "Example 1d (Page 73): (2a - 3)(3a + 5)",
      mode: 0,
      input1: '2a - 3',
      input2: '3a + 5',
    ),
    QuadraticExpansionPreset(
      chipLabel: "Example 1e (Page 73): (3y + 2)²",
      mode: 1,
      input1: '3y + 2',
    ),
    QuadraticExpansionPreset(
      chipLabel: "Example 1f (Page 73): (4c - 5)²",
      mode: 1,
      input1: '4c - 5',
    ),
    QuadraticExpansionPreset(
      chipLabel: "Example 1g (Page 73): (5d + 2)(7d - 1)",
      mode: 0,
      input1: '5d + 2',
      input2: '7d - 1',
    ),
    QuadraticExpansionPreset(
      chipLabel: "Ex 8.1 #2: (4a - 3)(2a - 3)",
      mode: 0,
      input1: '4a - 3',
      input2: '2a - 3',
    ),
    QuadraticExpansionPreset(
      chipLabel: "Ex 8.1 #10: (e - 2)(5 - e)",
      mode: 0,
      input1: 'e - 2',
      input2: '5 - e',
    ),
    QuadraticExpansionPreset(
      chipLabel: "Ex 8.1 #12: (3b + c)(2b + 5c)",
      mode: 0,
      input1: '3b + c',
      input2: '2b + 5c',
    ),
    QuadraticExpansionPreset(
      chipLabel: "Ex 8.1 #15: (g - h)(5g - 3h)",
      mode: 0,
      input1: 'g - h',
      input2: '5g - 3h',
    ),
    QuadraticExpansionPreset(
      chipLabel: "Ex 8.1 #40: (3x + z)²",
      mode: 1,
      input1: '3x + z',
    ),
    QuadraticExpansionPreset(
      chipLabel: "Ex 8.1 #41: (4y - 3)²",
      mode: 1,
      input1: '4y - 3',
    ),
    QuadraticExpansionPreset(
      chipLabel: "Ex 8.1 #42: (6z + 11)²",
      mode: 1,
      input1: '6z + 11',
    ),
    QuadraticExpansionPreset(
      chipLabel: "Fractional Binomials: (1/2x + 3)(2x - 4/3)",
      mode: 0,
      input1: '1/2x + 3',
      input2: '2x - 4/3',
    ),
    QuadraticExpansionPreset(
      chipLabel: "Rev Ex 8 Part A #4: (4k - 3)(3k + 1)",
      mode: 0,
      input1: '4k - 3',
      input2: '3k + 1',
    ),
  ];

  static List<_QTerm> _parseTerms(String rawBracket) {
    final String clean = rawBracket
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
        "Please enter valid algebraic terms inside the bracket (e.g. 3x + 5y or 2a - 3).",
      );
    }
    return parts.map(_QTerm.parse).toList();
  }

  static String _formatPolyLaTeX(List<_QTerm> terms) {
    final List<_QTerm> nonZero =
    terms.where((_QTerm t) => !t.coeff.isZero).toList();
    if (nonZero.isEmpty) return '0';
    final List<String> chunks = [];
    for (int i = 0; i < nonZero.length; i++) {
      chunks.add(nonZero[i].toLaTeX(withSign: i > 0));
    }
    return chunks.join(' ');
  }

  static String _formatPolyPlain(List<_QTerm> terms) {
    final List<_QTerm> nonZero =
    terms.where((_QTerm t) => !t.coeff.isZero).toList();
    if (nonZero.isEmpty) return '0';
    final List<String> chunks = [];
    for (int i = 0; i < nonZero.length; i++) {
      chunks.add(nonZero[i].toPlain(withSign: i > 0));
    }
    return chunks.join(' ');
  }

  static List<_QTerm> _combineLikeTerms(List<_QTerm> terms) {
    final Map<String, _Frac> sumBySig = {};
    final Map<String, Map<String, int>> varsBySig = {};
    final List<String> sigOrder = [];

    for (final _QTerm t in terms) {
      final String sig = t.signature;
      if (!sumBySig.containsKey(sig)) {
        sumBySig[sig] = const _Frac(0, 1);
        varsBySig[sig] = t.vars;
        sigOrder.add(sig);
      }
      sumBySig[sig] = sumBySig[sig]! + t.coeff;
    }

    final List<_QTerm> result = [];
    for (final String sig in sigOrder) {
      final _Frac c = sumBySig[sig]!;
      if (!c.isZero) {
        result.add(_QTerm(coeff: c, vars: varsBySig[sig]!));
      }
    }
    return result.isEmpty
        ? [const _QTerm(coeff: _Frac(0, 1), vars: {})]
        : result;
  }

  /// Builds the 2x2 (or M x N) Quadratic Box Table in LaTeX (Teaching & Learning Resources, Page 73)
  static String _buildQuadraticBoxLaTeX(
      List<_QTerm> b1,
      List<_QTerm> b2,
      ) {
    final String colSpec = List.filled(b2.length + 1, 'c').join('|');
    final List<String> topRow =
    b2.asMap().entries.map((e) => e.value.toLaTeX(withSign: e.key > 0)).toList();

    final StringBuffer sb = StringBuffer();
    sb.write("\\begin{array}{$colSpec} ");
    sb.write("\\times & ${topRow.join(' & ')} \\\\ \\hline ");

    for (int i = 0; i < b1.length; i++) {
      final _QTerm t1 = b1[i];
      final List<String> rowProducts = [];
      for (int j = 0; j < b2.length; j++) {
        final _QTerm prod = t1.multiply(b2[j]);
        rowProducts.add("\\mathbf{${prod.toLaTeX(withSign: true)}}");
      }
      sb.write(
          "\\mathbf{${t1.toLaTeX(withSign: i > 0)}} & ${rowProducts.join(' & ')} \\\\ \\hline ");
    }
    sb.write("\\end{array}");
    return sb.toString();
  }

  // ===========================================================================
  // MASTER SOLVER: EXPANSION OF ALGEBRAIC EXPRESSIONS (Page 73, Example 1a–g)
  // ===========================================================================
  static QuadraticExpansionResult solveExpansion({
    required int mode,
    required String rawInput1,
    required String rawInput2,
  }) {
    try {
      String in1 = rawInput1.trim();
      String in2 = rawInput2.trim();
      bool isSquaredBinomial = (mode == 1);

      // Smart detection if user enters full expression like "(3x + 5y)(4x - 3y)" or "(3y + 2)^2" in one box
      if (mode == 3 || (in2.isEmpty && in1.contains('('))) {
        final String norm = in1
            .replaceAll(' ', '')
            .replaceAll('−', '-')
            .replaceAll('²', '^2');
        final RegExp sqReg = RegExp(r'^\(([^()]+)\)\^2$');
        final RegExp twoBrackReg = RegExp(r'^\(([^()]+)\)\(([^()]+)\)$');
        final RegExp monoBrackReg = RegExp(r'^([^(]+)\(([^()]+)\)$');

        if (sqReg.hasMatch(norm)) {
          final Match m = sqReg.firstMatch(norm)!;
          in1 = m.group(1)!;
          in2 = m.group(1)!;
          isSquaredBinomial = true;
        } else if (twoBrackReg.hasMatch(norm)) {
          final Match m = twoBrackReg.firstMatch(norm)!;
          in1 = m.group(1)!;
          in2 = m.group(2)!;
          isSquaredBinomial = false;
        } else if (monoBrackReg.hasMatch(norm)) {
          final Match m = monoBrackReg.firstMatch(norm)!;
          in1 = m.group(1)!;
          in2 = m.group(2)!;
          isSquaredBinomial = false;
        }
      }

      if (mode == 1) {
        if (in1.isEmpty) {
          throw const FormatException(
            "Please enter the binomial to be squared (e.g. 3y + 2 or 4c - 5).",
          );
        }
        in2 = in1;
        isSquaredBinomial = true;
      }

      if (in1.isEmpty || in2.isEmpty) {
        throw const FormatException(
          "Please enter both expressions to expand (e.g. 1st bracket: 3x + 5y, 2nd bracket: 4x - 3y).",
        );
      }

      final List<_QTerm> terms1 = _parseTerms(in1);
      final List<_QTerm> terms2 = _parseTerms(in2);

      final String b1LaTeX = _formatPolyLaTeX(terms1);
      final String b2LaTeX = _formatPolyLaTeX(terms2);
      final String b1Plain = _formatPolyPlain(terms1);
      final String b2Plain = _formatPolyPlain(terms2);

      final bool isMonomialFirst = (terms1.length == 1);
      final String givenExprLaTeX = isSquaredBinomial
          ? "($b1LaTeX)^2"
          : (isMonomialFirst ? "$b1LaTeX($b2LaTeX)" : "($b1LaTeX)($b2LaTeX)");

      // Step 1: Rewrite (A ± B)^2 as (A ± B)(A ± B) if squared (Example 1e & 1f, Page 73)
      final List<String> step1RewriteLines = [];
      if (isSquaredBinomial) {
        step1RewriteLines.addAll([
          "\\text{Rule (Example 1e \\& 1f, Page 73): A squared binomial means multiplying the bracket by itself:}",
          "($b1LaTeX)^2 = ($b1LaTeX)($b2LaTeX)",
        ]);
      }

      // Step 2: Distributive Splitting — each term in the 1st bracket multiplies the entire 2nd bracket
      // (a + b)(c + d) = a(c + d) + b(c + d)
      final List<String> splitChunksLaTeX = [];
      final List<String> splitChunksPlain = [];
      for (int i = 0; i < terms1.length; i++) {
        final String t1Str = terms1[i].toLaTeX(withSign: i > 0);
        splitChunksLaTeX.add("$t1Str($b2LaTeX)");
        splitChunksPlain.add("${terms1[i].toPlain(withSign: i > 0)}($b2Plain)");
      }
      final String distributiveLineLaTeX = splitChunksLaTeX.join(' ');

      // Step 3: Detailed Term-by-Term Multiplication without skipping a single step!
      final List<_QTerm> rawProducts = [];
      final List<String> explicitProductPairsLaTeX = [];
      final List<String> detailedMultBulletsPlain = [];
      final List<String> detailedMultLinesLaTeX = [];

      for (int i = 0; i < terms1.length; i++) {
        final _QTerm t1 = terms1[i];
        for (int j = 0; j < terms2.length; j++) {
          final _QTerm t2 = terms2[j];
          final _QTerm prod = t1.multiply(t2);
          rawProducts.add(prod);

          final String t1Brack =
          t1.coeff.isNegative || i > 0 ? "(${t1.toLaTeX()})" : t1.toLaTeX();
          final String t2Brack =
          t2.coeff.isNegative ? "(${t2.toLaTeX()})" : "(${t2.toLaTeX()})";
          final String prefixPlus =
          (i == 0 && j == 0) ? "" : "+ ";
          explicitProductPairsLaTeX.add("$prefixPlus$t1Brack \\times $t2Brack");

          final String signExplanation = (t1.coeff.isNegative &&
              t2.coeff.isNegative)
              ? "[(−) × (−) = +]"
              : ((t1.coeff.isNegative || t2.coeff.isNegative)
              ? "[(+) × (−) = −]"
              : "[(+) × (+) = +]");

          // Show explicit coefficient multiplication and variable multiplication!
          final String coeffMultStep = (t1.coeff.isFraction || t2.coeff.isFraction)
              ? "\\left(${t1.coeff.toLaTeX()} \\times ${t2.coeff.toLaTeX()} = \\frac{${t1.coeff.num} \\times ${t2.coeff.num}}{${t1.coeff.den} \\times ${t2.coeff.den}} = ${prod.coeff.toLaTeX()}\\right)"
              : "\\left(${t1.coeff.toLaTeX()} \\times ${t2.coeff.toLaTeX()} = ${prod.coeff.toLaTeX()}\\right)";

          final String varMultStep = (t1.vars.isNotEmpty && t2.vars.isNotEmpty)
              ? ", \\; ${t1.varsLaTeX} \\times ${t2.varsLaTeX} = ${prod.varsLaTeX}"
              : "";

          detailedMultLinesLaTeX.add(
            "\\bullet \\; (${t1.toLaTeX()}) \\times (${t2.toLaTeX()}): \\quad $coeffMultStep$varMultStep \\implies \\mathbf{${prod.toLaTeX(withSign: true)}} \\quad \\text{$signExplanation}",
          );
          detailedMultBulletsPlain.add(
            "• Multiply (${t1.toPlain()}) by (${t2.toPlain()}): multiply numbers (${t1.coeff.toPlain()} × ${t2.coeff.toPlain()} = ${prod.coeff.toPlain()})${t1.vars.isNotEmpty || t2.vars.isNotEmpty ? ' and letters (${prod.varsPlain})' : ''} to get ${prod.toPlain(withSign: true)}  $signExplanation",
          );
        }
      }

      final String rawProductsLaTeX = _formatPolyLaTeX(rawProducts);

      // Step 4: Collect and combine like terms (if any share the same variable signature)
      final Map<String, List<_QTerm>> groups = {};
      final List<String> sigOrder = [];
      for (final _QTerm p in rawProducts) {
        final String sig = p.signature;
        if (!groups.containsKey(sig)) {
          groups[sig] = [];
          sigOrder.add(sig);
        }
        groups[sig]!.add(p);
      }

      final List<String> likeTermExplanationsLaTeX = [];
      final List<String> likeTermExplanationsPlain = [];
      bool hasLikeTerms = false;

      for (final String sig in sigOrder) {
        final List<_QTerm> g = groups[sig]!;
        if (g.length > 1) {
          hasLikeTerms = true;
          final String groupSumLaTeX = g
              .asMap()
              .entries
              .map((e) => e.value.toLaTeX(withSign: e.key > 0))
              .join(' ');
          final String coeffSumLaTeX = g
              .asMap()
              .entries
              .map((e) => e.value.coeff.toLaTeX(withSign: e.key > 0))
              .join(' ');
          final _Frac totalC = g
              .map((e) => e.coeff)
              .reduce((_Frac a, _Frac b) => a + b);
          final _QTerm combinedTerm = _QTerm(coeff: totalC, vars: g.first.vars);

          likeTermExplanationsLaTeX.add(
            "\\bullet \\text{ Combine like terms in } ${g.first.varsLaTeX.isEmpty ? '\\text{constants}' : g.first.varsLaTeX}: \\quad $groupSumLaTeX = \\left($coeffSumLaTeX\\right)${g.first.varsLaTeX} = \\mathbf{${combinedTerm.toLaTeX(withSign: true)}}",
          );
          likeTermExplanationsPlain.add(
            "• Combine like terms (${g.map((e) => e.toPlain(withSign: true)).join(' ')}): (${g.map((e) => e.coeff.toPlain(withSign: true)).join(' ')})${g.first.varsPlain} = ${combinedTerm.toPlain(withSign: true)}",
          );
        }
      }

      final List<_QTerm> simplifiedTerms = _combineLikeTerms(rawProducts);
      final String finalExpandedLaTeX = _formatPolyLaTeX(simplifiedTerms);
      final String quadraticBoxLaTeX = _buildQuadraticBoxLaTeX(terms1, terms2);

      // Assemble complete unskipped workings matching Example 1(a–g) on Page 73
      final List<String> workings = [
        "\\text{\\textbf{Given Expression to Expand (Page 73):}}",
        "\\mathbf{$givenExprLaTeX}",
        if (isSquaredBinomial) ...[
          "",
          "\\text{\\textbf{Step 1: Write the Squared Bracket as a Product of Two Identical Binomials}}",
          ...step1RewriteLines,
        ],
        "",
        "\\text{\\textbf{Step ${isSquaredBinomial ? 2 : 1}: Multiply Each Term in the First Bracket by the Second Bracket}}",
        "\\text{Rule: } (a + b)(c + d) = a(c + d) + b(c + d)",
        "${isSquaredBinomial ? '($b1LaTeX)($b2LaTeX)' : givenExprLaTeX} = $distributiveLineLaTeX",
        "",
        "\\text{\\textbf{Step ${isSquaredBinomial ? 3 : 2}: Multiply Out Every Term Inside each Bracket}}",
        "= ${explicitProductPairsLaTeX.join(' ')}",
        ...detailedMultLinesLaTeX,
        "= $rawProductsLaTeX",
        "",
        "\\text{\\textbf{Step ${isSquaredBinomial ? 4 : 3}: Collect and Simplify Like Terms}}",
        if (hasLikeTerms) ...[
          ...likeTermExplanationsLaTeX,
          "= \\mathbf{$finalExpandedLaTeX}",
        ] else ...[
          "\\text{There are no like terms to combine, so the expression is already in its simplest form:}",
          "= \\mathbf{$finalExpandedLaTeX}",
        ],
        "",
        "\\text{\\textbf{Quadratic Box Verification Table:}}",
        quadraticBoxLaTeX,
      ];

      final List<QuadraticExpansionStep> steps = [
        if (isSquaredBinomial)
          QuadraticExpansionStep(
            title: "Step 1: Expand the Square into Two Identical Brackets (Example 1e & 1f)",
            description:
            "• Whenever a binomial is squared like ($b1Plain)², write it out twice as the product of two identical brackets before expanding.",
            mathLinesLaTeX: step1RewriteLines,
          ),
        QuadraticExpansionStep(
          title:
          "Step ${isSquaredBinomial ? 2 : 1}: Split the First Bracket Over the Second Bracket (Page 73 Rule)",
          description:
          "• Multiply each term in the first bracket ($b1Plain) by the entire second bracket ($b2Plain):\n"
              "  (${b1Plain})(${b2Plain}) = ${splitChunksPlain.join(' ')}",
          mathLinesLaTeX: [
            "\\text{Identity: } (a + b)(c + d) = a(c + d) + b(c + d)",
            "${isSquaredBinomial ? '($b1LaTeX)($b2LaTeX)' : givenExprLaTeX} = $distributiveLineLaTeX",
          ],
        ),
        QuadraticExpansionStep(
          title:
          "Step ${isSquaredBinomial ? 3 : 2}: Multiply Out Term-by-Term (Sign, Coefficient & Powers)",
          description:
          "• Multiply every outside term by each term inside its bracket:\n\n"
              "${detailedMultBulletsPlain.join('\n')}",
          mathLinesLaTeX: [
            "= ${explicitProductPairsLaTeX.join(' ')}",
            ...detailedMultLinesLaTeX,
            "= $rawProductsLaTeX",
          ],
        ),
        QuadraticExpansionStep(
          title:
          "Step ${isSquaredBinomial ? 4 : 3}: Collect Like Terms & Verify with the Quadratic Box",
          description: hasLikeTerms
              ? "• Add or subtract the coefficients of the like middle terms:\n"
              "${likeTermExplanationsPlain.join('\n')}"
              : "• All four resulting terms have different variable parts (as in Example 1a), so no further combination is needed.",
          mathLinesLaTeX: [
            if (hasLikeTerms) ...likeTermExplanationsLaTeX,
            "\\therefore \\; $givenExprLaTeX = \\mathbf{$finalExpandedLaTeX}",
            quadraticBoxLaTeX,
          ],
        ),
      ];

      return QuadraticExpansionResult(
        mode: mode,
        finalAnswersLaTeX: {
          "Given Expression": givenExprLaTeX,
          "4 Partial Products": rawProductsLaTeX,
          "Expanded Answer": "\\mathbf{$finalExpandedLaTeX}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: QuadraticExpansionCanvasData(
          headerLaTeX:
          "\\text{Chapter 8 Expansion (Page 73): } $givenExprLaTeX = \\mathbf{$finalExpandedLaTeX}",
          subHeaderLaTeX:
          "\\text{Distributive Step: } $distributiveLineLaTeX = $rawProductsLaTeX",
          card1Title: "1st Factor / Bracket",
          card1LaTeX: b1LaTeX,
          card2Title: "2nd Factor / Bracket",
          card2LaTeX: b2LaTeX,
          card3Title: "Expanded Expression",
          card3LaTeX: "\\mathbf{$finalExpandedLaTeX}",
          quadraticBoxLaTeX: quadraticBoxLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $givenExprLaTeX = \\mathbf{$finalExpandedLaTeX}",
        ),
      );
    } catch (e) {
      return QuadraticExpansionResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter valid algebraic binomials (e.g. 3x + 5y and 4x - 3y).",
      );
    }
  }
}