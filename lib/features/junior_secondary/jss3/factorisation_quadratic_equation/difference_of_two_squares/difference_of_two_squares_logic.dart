import 'dart:math' as math;
import 'difference_of_two_squares_models.dart';

/// Exact Rational Number Engine supporting integers, proper/improper fractions, mixed numbers (e.g., 2 2/49, 6 1/4), and decimals!
class _DFrac {
  final int num;
  final int den;

  const _DFrac(this.num, [this.den = 1]);

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

  factory _DFrac.from(int n, [int d = 1]) {
    if (d == 0) throw const FormatException("Denominator cannot be zero.");
    if (n == 0) return const _DFrac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _DFrac(sign * (an ~/ g), ad ~/ g);
  }

  bool get isZero => num == 0;
  bool get isNegative => num < 0;
  bool get isFraction => den != 1;
  bool get isAbsOne => num.abs() == 1 && den == 1;

  _DFrac abs() => _DFrac(num.abs(), den);
  _DFrac operator /(_DFrac other) =>
      _DFrac.from(num * other.den, den * other.num);

  static int? _exactSqrtInt(int n) {
    if (n < 0) return null;
    if (n == 0) return 0;
    final int r = math.sqrt(n).round();
    return (r * r == n) ? r : null;
  }

  _DFrac? exactSqrt() {
    if (num < 0) return null;
    final int? rn = _exactSqrtInt(num);
    final int? rd = _exactSqrtInt(den);
    if (rn == null || rd == null) return null;
    return _DFrac.from(rn, rd);
  }

  String toLaTeX({bool withSign = false}) {
    if (num == 0) return withSign ? '+ 0' : '0';
    final String signStr =
    num < 0 ? (withSign ? '- ' : '-') : (withSign ? '+ ' : '');
    final int an = num.abs();
    if (den == 1) return '$signStr$an';
    return '$signStr\\frac{$an}{$den}';
  }

  String toMixedLaTeX({bool withSign = false}) {
    if (num == 0) return withSign ? '+ 0' : '0';
    final String signStr =
    num < 0 ? (withSign ? '- ' : '-') : (withSign ? '+ ' : '');
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

  String toPlain({bool withSign = false}) {
    if (num == 0) return withSign ? '+ 0' : '0';
    final String signStr =
    num < 0 ? (withSign ? '- ' : '-') : (withSign ? '+ ' : '');
    final int an = num.abs();
    if (den == 1) return '$signStr$an';
    return '$signStr$an/$den';
  }
}

/// Parsed representation of one term in a Difference of Two Squares expression
/// Supports mixed numbers like "2 2/49 k^2", "6 1/4", fractions like "9/16 g^2", "a^2/9", and powers like "m^3", "36z^2k^2".
class _SqTerm {
  final _DFrac coeff;
  final int? mixedWhole;
  final int? mixedNum;
  final int? mixedDen;
  final Map<String, int> vars;

  const _SqTerm({
    required this.coeff,
    this.mixedWhole,
    this.mixedNum,
    this.mixedDen,
    required this.vars,
  });

  bool get hadMixedNumber =>
      mixedWhole != null && mixedNum != null && mixedDen != null;

  static _SqTerm parse(String raw) {
    String s = raw
        .trim()
        .replaceAll('−', '-')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('⁴', '^4');

    int sign = 1;
    if (s.startsWith('-')) {
      sign = -1;
      s = s.substring(1).trim();
    } else if (s.startsWith('+')) {
      s = s.substring(1).trim();
    }

    int? mWhole;
    int? mNum;
    int? mDen;
    _DFrac coeff = _DFrac.from(sign, 1);

    // Check for mixed number prefix like "2 2/49 k^2" or "6 1/4" or "2_2/49"
    final RegExp mixedReg = RegExp(r'^(\d+)(?:\s+|_)(\d+)/(\d+)(.*)$');
    final Match? mm = mixedReg.firstMatch(s);
    String rem = '';

    if (mm != null) {
      mWhole = int.parse(mm.group(1)!);
      mNum = int.parse(mm.group(2)!);
      mDen = int.parse(mm.group(3)!);
      rem = mm.group(4)!.replaceAll(' ', '');
      final int improperNum = mWhole * mDen + mNum;
      coeff = _DFrac.from(sign * improperNum, mDen);
    } else {
      s = s.replaceAll(' ', '');
      final RegExp numReg = RegExp(r'^(\d+(?:/\d+|\.\d+)?)');
      final Match? nm = numReg.firstMatch(s);
      rem = s;
      if (nm != null) {
        final String numStr = nm.group(1)!;
        if (numStr.contains('/')) {
          final List<String> sp = numStr.split('/');
          coeff = _DFrac.from(sign * int.parse(sp[0]), int.parse(sp[1]));
        } else {
          coeff = _DFrac.from(sign * int.parse(numStr), 1);
        }
        rem = s.substring(nm.end);
      }
    }

    // Check for trailing denominator like "a^2/9" or "b^2/4" (Exercise 8.5 #16)
    if (rem.contains('/')) {
      final List<String> slashParts = rem.split('/');
      rem = slashParts[0];
      if (slashParts.length > 1 && slashParts[1].isNotEmpty) {
        final int tailDen = int.parse(slashParts[1]);
        coeff = _DFrac.from(coeff.num, coeff.den * tailDen);
      }
    }

    final Map<String, int> vp = {};
    for (final Match m in RegExp(r'([a-zA-Z])(?:\^(\d+))?').allMatches(rem)) {
      final String v = m.group(1)!;
      final int p = int.tryParse(m.group(2) ?? '1') ?? 1;
      vp[v] = (vp[v] ?? 0) + p;
    }

    return _SqTerm(
      coeff: coeff,
      mixedWhole: mWhole,
      mixedNum: mNum,
      mixedDen: mDen,
      vars: vp,
    );
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

  String get varsPlain =>
      varsLaTeX.replaceAll('{', '').replaceAll('}', '');

  String toOriginalLaTeX({bool withSign = false}) {
    final String signStr =
    coeff.isNegative ? (withSign ? '- ' : '-') : (withSign ? '+ ' : '');
    if (hadMixedNumber) {
      return '$signStr$mixedWhole\\frac{$mixedNum}{$mixedDen}$varsLaTeX';
    }
    final _DFrac ac = coeff.abs();
    if (vars.isEmpty) return '$signStr${ac.toLaTeX()}';
    if (ac.isAbsOne) return '$signStr$varsLaTeX';
    return '$signStr${ac.toLaTeX()}$varsLaTeX';
  }

  String toImproperLaTeX({bool withSign = false}) {
    final String signStr =
    coeff.isNegative ? (withSign ? '- ' : '-') : (withSign ? '+ ' : '');
    final _DFrac ac = coeff.abs();
    if (vars.isEmpty) return '$signStr${ac.toLaTeX()}';
    if (ac.isAbsOne) return '$signStr$varsLaTeX';
    return '$signStr${ac.toLaTeX()}$varsLaTeX';
  }
}

class DifferenceOfTwoSquaresLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 77–80: Examples 5 & 6, Exercises 8.5 & 8.6, Rev Ex 8)
  // ===========================================================================
  static const List<DifferenceOfTwoSquaresPreset> textbookPresets = [
    DifferenceOfTwoSquaresPreset(
      chipLabel: "Example 5a (Page 77): 9x² - 1",
      mode: 0,
      input1: '9x^2 - 1',
    ),
    DifferenceOfTwoSquaresPreset(
      chipLabel: "Example 5c (Page 77): 4k² - r²",
      mode: 0,
      input1: '4k^2 - r^2',
    ),
    DifferenceOfTwoSquaresPreset(
      chipLabel: "Example 5d (Page 78): 3m² - 27n² (With Common Factor 3)",
      mode: 0,
      input1: '3m^2 - 27n^2',
    ),
    DifferenceOfTwoSquaresPreset(
      chipLabel: "Example 5e (Page 78): 8c² - 2cd² (With Common Factor 2c)",
      mode: 0,
      input1: '8c^2 - 2cd^2',
    ),
    DifferenceOfTwoSquaresPreset(
      chipLabel: "Ex 8.5 #7 (Page 78): 1 - 9/16g² (Fractional Coefficient)",
      mode: 0,
      input1: '1 - 9/16g^2',
    ),
    DifferenceOfTwoSquaresPreset(
      chipLabel: "Ex 8.5 #8 (Page 78): 2 2/49k² - 169 (Mixed Number!)",
      mode: 0,
      input1: '2 2/49 k^2 - 169',
    ),
    DifferenceOfTwoSquaresPreset(
      chipLabel: "Ex 8.5 #15 (Page 78): m³ - m",
      mode: 0,
      input1: 'm^3 - m',
    ),
    DifferenceOfTwoSquaresPreset(
      chipLabel: "Ex 8.5 #16 (Page 78): a²/9 - b²/4",
      mode: 0,
      input1: 'a^2/9 - b^2/4',
    ),
    DifferenceOfTwoSquaresPreset(
      chipLabel: "Ex 8.5 #17 (Page 78): 16x² - 4/25y²",
      mode: 0,
      input1: '16x^2 - 4/25y^2',
    ),
    DifferenceOfTwoSquaresPreset(
      chipLabel: "Ex 8.5 #20 (Page 78): 4a²b - bc²",
      mode: 0,
      input1: '4a^2b - bc^2',
    ),
    DifferenceOfTwoSquaresPreset(
      chipLabel: "Ex 8.5 #22 (Page 78): 25y² - 6 1/4 (Mixed Number!)",
      mode: 0,
      input1: '25y^2 - 6 1/4',
    ),
    DifferenceOfTwoSquaresPreset(
      chipLabel: "Example 6b (Page 78): Evaluate 56² - 16",
      mode: 1,
      input1: '56^2',
      input2: '16',
    ),
    DifferenceOfTwoSquaresPreset(
      chipLabel: "Example 6c (Page 78): Evaluate 198² - 4",
      mode: 1,
      input1: '198^2',
      input2: '4',
    ),
    DifferenceOfTwoSquaresPreset(
      chipLabel: "Example 6e (Page 78): Evaluate 53² - 3²",
      mode: 1,
      input1: '53^2',
      input2: '3^2',
    ),
    DifferenceOfTwoSquaresPreset(
      chipLabel: "Ex 8.6 #15 (Page 78): Evaluate 52.4² - 47.6² (Decimals!)",
      mode: 1,
      input1: '52.4^2',
      input2: '47.6^2',
    ),
    DifferenceOfTwoSquaresPreset(
      chipLabel: "Rev Ex 8 Part D #4 (Page 80): 1000001² - 999999²",
      mode: 1,
      input1: '1000001^2',
      input2: '999999^2',
    ),
  ];

  static String _varsToLaTeX(Map<String, int> vp) {
    final List<String> keys = vp.keys.toList()..sort();
    final StringBuffer sb = StringBuffer();
    for (final String k in keys) {
      final int p = vp[k]!;
      sb.write(k);
      if (p > 1) sb.write('^{$p}');
    }
    return sb.toString();
  }

  static String _varsToPlain(Map<String, int> vp) =>
      _varsToLaTeX(vp).replaceAll('{', '').replaceAll('}', '');

  static String _formatTermLaTeX(
      _DFrac c,
      Map<String, int> vp, {
        bool isFirst = false,
        bool useMixed = false,
      }) {
    final String vStr = _varsToLaTeX(vp);
    final String sign =
    c.isNegative ? (isFirst ? '-' : '- ') : (isFirst ? '' : '+ ');
    final _DFrac ac = c.abs();
    final String cStr = useMixed ? ac.toMixedLaTeX() : ac.toLaTeX();
    if (vStr.isEmpty) return '$sign$cStr';
    if (ac.isAbsOne) return '$sign$vStr';
    return '$sign$cStr$vStr';
  }

  // ===========================================================================
  // MODE 0: ALGEBRAIC FACTORISATION OF DIFFERENCE OF TWO SQUARES
  // Covers Example 5(a–e), Exercise 8.5 (#1–22), and Revision Exercise 8
  // ===========================================================================
  static DifferenceOfTwoSquaresResult solveAlgebraicDifferenceOfSquares(
      String rawExpr,
      ) {
    try {
      String expr = rawExpr
          .trim()
          .replaceAll('−', '-')
          .replaceAll('²', '^2')
          .replaceAll('³', '^3')
          .replaceAll('⁴', '^4');

      if (expr.isEmpty) {
        throw const FormatException(
          "Please enter a binomial expression to factorise (e.g. 9x^2 - 1, 3m^2 - 27n^2, 2 2/49 k^2 - 169, or 25y^2 - 6 1/4).",
        );
      }

      // Split on the minus sign separating the two terms
      final int minusIdx = expr.indexOf('-', 1);
      if (minusIdx == -1) {
        throw const FormatException(
          "A difference of two squares must have two terms separated by a minus sign '−' (e.g. a^2 - b^2).",
        );
      }

      final String leftRaw = expr.substring(0, minusIdx).trim();
      final String rightRaw = expr.substring(minusIdx + 1).trim();

      final _SqTerm term1 = _SqTerm.parse(leftRaw);
      final _SqTerm term2 = _SqTerm.parse(rightRaw);

      if (term1.coeff.isNegative || term2.coeff.isNegative) {
        throw const FormatException(
          "Please enter the expression in the form A - B where A and B are positive terms.",
        );
      }

      final String givenLaTeX =
          "${term1.toOriginalLaTeX()} - ${term2.toOriginalLaTeX()}";

      // Step 1: Mixed Number to Improper Fraction Conversion (if applicable, e.g. Ex 8.5 #8 & #22!)
      final bool hasMixed = term1.hadMixedNumber || term2.hadMixedNumber;
      final List<String> mixedConversionLinesLaTeX = [];
      final List<String> mixedConversionPlain = [];

      if (term1.hadMixedNumber) {
        final int impN =
            term1.mixedWhole! * term1.mixedDen! + term1.mixedNum!;
        mixedConversionLinesLaTeX.add(
          "\\bullet \\; ${term1.mixedWhole}\\frac{${term1.mixedNum}}{${term1.mixedDen}}${term1.varsLaTeX} = \\frac{(${term1.mixedWhole} \\times ${term1.mixedDen}) + ${term1.mixedNum}}{${term1.mixedDen}}${term1.varsLaTeX} = \\mathbf{\\frac{$impN}{${term1.mixedDen}}${term1.varsLaTeX}}",
        );
        mixedConversionPlain.add(
          "• Convert ${term1.mixedWhole} ${term1.mixedNum}/${term1.mixedDen}${term1.varsPlain} to improper fraction: $impN/${term1.mixedDen}${term1.varsPlain}.",
        );
      }
      if (term2.hadMixedNumber) {
        final int impN =
            term2.mixedWhole! * term2.mixedDen! + term2.mixedNum!;
        mixedConversionLinesLaTeX.add(
          "\\bullet \\; ${term2.mixedWhole}\\frac{${term2.mixedNum}}{${term2.mixedDen}}${term2.varsLaTeX} = \\frac{(${term2.mixedWhole} \\times ${term2.mixedDen}) + ${term2.mixedNum}}{${term2.mixedDen}}${term2.varsLaTeX} = \\mathbf{\\frac{$impN}{${term2.mixedDen}}${term2.varsLaTeX}}",
        );
        mixedConversionPlain.add(
          "• Convert ${term2.mixedWhole} ${term2.mixedNum}/${term2.mixedDen}${term2.varsPlain} to improper fraction: $impN/${term2.mixedDen}${term2.varsPlain}.",
        );
      }

      final String improperExprLaTeX =
          "${term1.toImproperLaTeX()} - ${term2.toImproperLaTeX()}";

      // Step 2: Check for Common Numerical and/or Algebraic Factor (HCF) first!
      // e.g. 3m^2 - 27n^2 = 3(m^2 - 9n^2), 8c^2 - 2cd^2 = 2c(4c - d^2), 45p^2 - 125 = 5(9p^2 - 25), m^3 - m = m(m^2 - 1)
      final Map<String, int> commonVars = {};
      for (final String v in term1.vars.keys) {
        if (term2.vars.containsKey(v)) {
          final int p1 = term1.vars[v]!;
          final int p2 = term2.vars[v]!;
          // Extract common variable power if either power is odd or if both terms share a variable
          // In textbook Ex 8.5 #21: 36z^2 - 16z^2k^2 = 4z^2(9 - 4k^2)
          commonVars[v] = math.min(p1, p2);
        }
      }

      final Map<String, int> remVars1 = Map.from(term1.vars);
      final Map<String, int> remVars2 = Map.from(term2.vars);
      commonVars.forEach((String k, int p) {
        if (remVars1[k] == p) {
          remVars1.remove(k);
        } else {
          remVars1[k] = remVars1[k]! - p;
        }
        if (remVars2[k] == p) {
          remVars2.remove(k);
        } else {
          remVars2[k] = remVars2[k]! - p;
        }
      });

      // Determine numerical HCF if needed so remaining coefficients are exact squares
      int hcfNum = 1;
      int hcfDen = 1;
      _DFrac innerC1 = term1.coeff;
      _DFrac innerC2 = term2.coeff;

      if (innerC1.exactSqrt() == null ||
          innerC2.exactSqrt() == null ||
          commonVars.isNotEmpty) {
        final int gN = _DFrac.gcd(term1.coeff.num, term2.coeff.num);
        final int gD = _DFrac.gcd(term1.coeff.den, term2.coeff.den);
        final _DFrac testC1 =
        _DFrac.from(term1.coeff.num ~/ gN, term1.coeff.den ~/ gD);
        final _DFrac testC2 =
        _DFrac.from(term2.coeff.num ~/ gN, term2.coeff.den ~/ gD);

        if (testC1.exactSqrt() != null && testC2.exactSqrt() != null) {
          // If original coefficients were already squares (e.g., 36z^2 - 16z^2k^2 or 900 - 324y^2),
          // only factor out the numerical HCF when variables are also factored or when required to make squares!
          if (innerC1.exactSqrt() == null ||
              innerC2.exactSqrt() == null ||
              commonVars.isNotEmpty) {
            hcfNum = gN;
            hcfDen = gD;
            innerC1 = testC1;
            innerC2 = testC2;
          }
        }
      }

      final _DFrac hcfCoeff = _DFrac.from(hcfNum, hcfDen);
      final bool hasHcf =
          !hcfCoeff.isAbsOne || commonVars.isNotEmpty;
      final String hcfPrefixLaTeX = hasHcf
          ? _formatTermLaTeX(hcfCoeff, commonVars, isFirst: true)
          : '';
      final String hcfPrefixPlain =
      hcfPrefixLaTeX.replaceAll('{', '').replaceAll('}', '');

      // Verify remaining inner terms are perfect squares
      final _DFrac? sqrtC1 = innerC1.exactSqrt();
      final _DFrac? sqrtC2 = innerC2.exactSqrt();

      if (sqrtC1 == null || sqrtC2 == null) {
        throw FormatException(
          "After extracting common factors, the terms (${_formatTermLaTeX(innerC1, remVars1, isFirst: true)} and ${_formatTermLaTeX(innerC2, remVars2, isFirst: true)}) are not perfect squares.",
        );
      }

      final Map<String, int> rootVars1 = {};
      for (final entry in remVars1.entries) {
        if (entry.value % 2 != 0) {
          throw FormatException(
            "After factoring out common letters, the power of '${entry.key}' (${entry.value}) is odd, so it is not a square.",
          );
        }
        rootVars1[entry.key] = entry.value ~/ 2;
      }

      final Map<String, int> rootVars2 = {};
      for (final entry in remVars2.entries) {
        if (entry.value % 2 != 0) {
          throw FormatException(
            "After factoring out common letters, the power of '${entry.key}' (${entry.value}) is odd, so it is not a square.",
          );
        }
        rootVars2[entry.key] = entry.value ~/ 2;
      }

      final String innerTerm1LaTeX =
      _formatTermLaTeX(innerC1, remVars1, isFirst: true);
      final String innerTerm2LaTeX =
      _formatTermLaTeX(innerC2, remVars2, isFirst: true);
      final String innerDiffLaTeX = "$innerTerm1LaTeX - $innerTerm2LaTeX";

      final String root1LaTeX =
      _formatTermLaTeX(sqrtC1, rootVars1, isFirst: true);
      final String root2LaTeX =
      _formatTermLaTeX(sqrtC2, rootVars2, isFirst: true);

      final String root1Wrap =
      (sqrtC1.isFraction || (!sqrtC1.isAbsOne && rootVars1.isNotEmpty))
          ? "\\left($root1LaTeX\\right)"
          : (rootVars1.length > 1 ? "($root1LaTeX)" : root1LaTeX);
      final String root2Wrap =
      (sqrtC2.isFraction || (!sqrtC2.isAbsOne && rootVars2.isNotEmpty))
          ? "\\left($root2LaTeX\\right)"
          : (rootVars2.length > 1 ? "($root2LaTeX)" : root2LaTeX);

      final String diffOfSquaresFormLaTeX = hasHcf
          ? "$hcfPrefixLaTeX\\left[$root1Wrap^2 - $root2Wrap^2\\right]"
          : "$root1Wrap^2 - $root2Wrap^2";

      final bool hasFractionalRoots = sqrtC1.isFraction || sqrtC2.isFraction;
      final String finalFactoredLaTeX = hasFractionalRoots
          ? "$hcfPrefixLaTeX\\left($root1LaTeX + $root2LaTeX\\right)\\left($root1LaTeX - $root2LaTeX\\right)"
          : "$hcfPrefixLaTeX($root1LaTeX + $root2LaTeX)($root1LaTeX - $root2LaTeX)";

      // If input had a mixed number whose square root is an improper fraction (like 10/7 k = 1 3/7 k in Ex 8.5 #8), also show mixed-number bracket form!
      String? mixedFactoredLaTeX;
      if (hasMixed &&
          ((sqrtC1.num > sqrtC1.den && sqrtC1.den > 1) ||
              (sqrtC2.num > sqrtC2.den && sqrtC2.den > 1))) {
        final String r1Mixed = _formatTermLaTeX(sqrtC1, rootVars1,
            isFirst: true, useMixed: true);
        final String r2Mixed = _formatTermLaTeX(sqrtC2, rootVars2,
            isFirst: true, useMixed: true);
        mixedFactoredLaTeX =
        "$hcfPrefixLaTeX\\left($r1Mixed + $r2Mixed\\right)\\left($r1Mixed - $r2Mixed\\right)";
      }

      // Build Visualisation Identity Box in LaTeX (including Page 77 Geometric Area Proof reference!)
      final String identityBoxLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Fundamental Identity (Page 77)} & \\textbf{Step-by-Step Factorisation} \\\\ \\hline "
          "a^2 - b^2 = (a + b)(a - b) & $givenLaTeX \\\\ "
          "\\text{First Root } a = \\mathbf{$root1LaTeX} & ${hasHcf ? '= $hcfPrefixLaTeX($innerDiffLaTeX)' : '= $improperExprLaTeX'} \\\\ "
          "\\text{Second Root } b = \\mathbf{$root2LaTeX} & = $diffOfSquaresFormLaTeX \\\\ "
          "\\text{Sum } (a + b) = ($root1LaTeX + $root2LaTeX) & = \\mathbf{$finalFactoredLaTeX} \\\\ \\hline "
          "\\end{array}";

      int stepNum = 1;
      final List<String> workings = [
        "\\text{\\textbf{Fundamental Identity (Page 77):}} \\quad a^2 - b^2 = (a + b)(a - b)",
        "\\text{Given Expression: } \\mathbf{$givenLaTeX}",
        if (hasMixed) ...[
          "",
          "\\text{\\textbf{Step ${stepNum++}: Convert Mixed Numbers to Improper Fractions (Exercise 8.5 #8 \\& #22)}}",
          ...mixedConversionLinesLaTeX,
          "\\text{Expression becomes: } \\mathbf{$improperExprLaTeX}",
        ],
        if (hasHcf) ...[
          "",
          "\\text{\\textbf{Step ${stepNum++}: Factor Out the Highest Common Factor }} \\mathbf{$hcfPrefixLaTeX} \\text{\\textbf{ (Example 5d \\& 5e, Page 78)}}",
          "$improperExprLaTeX = $hcfPrefixLaTeX($innerDiffLaTeX)",
        ],
        "",
        "\\text{\\textbf{Step ${stepNum++}: Express Each Term as a Perfect Square }} \\mathbf{a^2 - b^2}",
        "\\bullet \\; \\sqrt{$innerTerm1LaTeX} = $root1LaTeX \\implies $innerTerm1LaTeX = $root1Wrap^2",
        "\\bullet \\; \\sqrt{$innerTerm2LaTeX} = $root2LaTeX \\implies $innerTerm2LaTeX = $root2Wrap^2",
        "= $diffOfSquaresFormLaTeX",
        "",
        "\\text{\\textbf{Step $stepNum: Apply the Difference of Two Squares Identity }} \\mathbf{a^2 - b^2 = (a + b)(a - b)}",
        "= \\mathbf{$finalFactoredLaTeX}",
        if (mixedFactoredLaTeX != null) ...[
          "\\text{Or in mixed-number form:}",
          "= \\mathbf{$mixedFactoredLaTeX}",
        ],
      ];

      final List<DifferenceOfTwoSquaresStep> steps = [
        if (hasMixed)
          DifferenceOfTwoSquaresStep(
            title: "Convert Mixed Numbers to Improper Fractions",
            description:
            "${mixedConversionPlain.join('\n')}\n"
                "• This makes it easy to take the exact square root of the numerator and denominator.",
            mathLinesLaTeX: [
              ...mixedConversionLinesLaTeX,
              "= $improperExprLaTeX",
            ],
          ),
        if (hasHcf)
          DifferenceOfTwoSquaresStep(
            title: "Factor Out the Common Factor ($hcfPrefixPlain) First (Example 5d & 5e)",
            description:
            "• Both terms share a common factor of $hcfPrefixPlain. Factoring it out leaves ($innerDiffLaTeX) inside the bracket, which is a difference of two squares.",
            mathLinesLaTeX: [
              "$improperExprLaTeX = $hcfPrefixLaTeX($innerDiffLaTeX)",
            ],
          ),
        DifferenceOfTwoSquaresStep(
          title: "Write Each Term in Square Form (a² − b²)",
          description:
          "• Take the square root of the first term ($innerTerm1LaTeX) to get a = $root1LaTeX.\n"
              "• Take the square root of the second term ($innerTerm2LaTeX) to get b = $root2LaTeX.",
          mathLinesLaTeX: [
            "a = \\sqrt{$innerTerm1LaTeX} = $root1LaTeX, \\qquad b = \\sqrt{$innerTerm2LaTeX} = $root2LaTeX",
            "${hasHcf ? '$hcfPrefixLaTeX($innerDiffLaTeX)' : improperExprLaTeX} = $diffOfSquaresFormLaTeX",
          ],
        ),
        DifferenceOfTwoSquaresStep(
          title: "Apply the Fundamental Identity a² − b² = (a + b)(a − b)",
          description:
          "• Replace a² − b² with the product of the sum (a + b) and the difference (a − b).",
          mathLinesLaTeX: [
            "= \\mathbf{$finalFactoredLaTeX}",
            if (mixedFactoredLaTeX != null) "= \\mathbf{$mixedFactoredLaTeX}",
          ],
        ),
      ];

      return DifferenceOfTwoSquaresResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Given Expression": givenLaTeX,
          if (hasHcf) "Common Factor (HCF)": "\\mathbf{$hcfPrefixLaTeX}",
          "Square Roots (a, b)": "a = $root1LaTeX,\\; b = $root2LaTeX",
          "Factorised Form": "\\mathbf{$finalFactoredLaTeX}",
          if (mixedFactoredLaTeX != null)
            "Mixed-Number Form": "\\mathbf{$mixedFactoredLaTeX}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: DifferenceOfTwoSquaresCanvasData(
          headerLaTeX:
          "\\text{Difference of Two Squares (Pages 77–78): } $givenLaTeX = \\mathbf{$finalFactoredLaTeX}",
          subHeaderLaTeX:
          "\\text{Square Form: } $diffOfSquaresFormLaTeX \\quad \\longrightarrow \\quad \\mathbf{$finalFactoredLaTeX}",
          card1Title: "1st Square Root (a)",
          card1LaTeX: "\\mathbf{$root1LaTeX}",
          card2Title: "2nd Square Root (b)",
          card2LaTeX: "\\mathbf{$root2LaTeX}",
          card3Title: "Factorised Result",
          card3LaTeX: "\\mathbf{$finalFactoredLaTeX}",
          identityBoxLaTeX: identityBoxLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $givenLaTeX = \\mathbf{$finalFactoredLaTeX}",
        ),
      );
    } catch (e) {
      return DifferenceOfTwoSquaresResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter a valid difference of two squares expression.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: NUMERICAL EVALUATION USING DIFFERENCE OF TWO SQUARES
  // Covers Example 6(a–e), Exercise 8.6 (#1–15), and Revision Exercise 8 Part D
  // Handles both x^2 - y^2 (e.g. 53^2 - 3^2, 52.4^2 - 47.6^2) AND x^2 - K (e.g. 56^2 - 16, 111^2 - 121)!
  // ===========================================================================
  static DifferenceOfTwoSquaresResult solveNumericalEvaluation({
    required String rawFirstTerm,
    required String rawSecondTerm,
  }) {
    try {
      String in1 = rawFirstTerm.trim().replaceAll(' ', '').replaceAll('²', '^2');
      String in2 = rawSecondTerm.trim().replaceAll(' ', '').replaceAll('²', '^2');

      // Allow user to enter full expression like "56^2 - 16" or "52.4^2 - 47.6^2" in the first field
      if (in2.isEmpty && in1.contains('-')) {
        final int idx = in1.indexOf('-', 1);
        if (idx != -1) {
          in2 = in1.substring(idx + 1).trim();
          in1 = in1.substring(0, idx).trim();
        }
      }

      if (in1.isEmpty || in2.isEmpty) {
        throw const FormatException(
          "Please enter both numerical terms (e.g. First term: 56^2, Second term: 16 or 4^2).",
        );
      }

      final bool firstHasSquare = in1.endsWith('^2');
      final bool secondHasSquare = in2.endsWith('^2');

      final String base1Str =
      firstHasSquare ? in1.substring(0, in1.length - 2) : in1;
      final String base2RawStr =
      secondHasSquare ? in2.substring(0, in2.length - 2) : in2;

      final double? val1 = double.tryParse(base1Str);
      final double? val2Raw = double.tryParse(base2RawStr);

      if (val1 == null || val2Raw == null) {
        throw const FormatException(
          "Please enter valid numbers (e.g. 99^2 and 1, 56^2 and 16, or 52.4^2 and 47.6^2).",
        );
      }

      final double aVal = firstHasSquare ? val1 : math.sqrt(val1);
      final double bVal = secondHasSquare ? val2Raw : math.sqrt(val2Raw);

      if (!secondHasSquare) {
        final double sqCheck = bVal.roundToDouble();
        if ((sqCheck * sqCheck - val2Raw).abs() > 1e-9) {
          throw FormatException(
            "Since '$in2' is not written with a square exponent, it must be a perfect square number (like 1, 4, 9, 16, 121).",
          );
        }
      }

      String fmtNum(double v) {
        if ((v - v.roundToDouble()).abs() < 1e-9) {
          return v.round().toString();
        }
        return v
            .toStringAsFixed(6)
            .replaceAll(RegExp(r'0*$'), '')
            .replaceAll(RegExp(r'\.$'), '');
      }

      final String aStr = fmtNum(aVal);
      final String bStr = fmtNum(bVal);
      final String givenSecondLaTeX =
      secondHasSquare ? "$bStr^2" : fmtNum(val2Raw);
      final String givenExprLaTeX = "$aStr^2 - $givenSecondLaTeX";
      final String rewrittenSquaresLaTeX = "$aStr^2 - $bStr^2";

      final double sumVal = aVal + bVal;
      final double diffVal = aVal - bVal;
      final double finalProductVal = sumVal * diffVal;

      final String sumStr = fmtNum(sumVal);
      final String diffStr = fmtNum(diffVal);
      final String finalProductStr = fmtNum(finalProductVal);

      final bool neededSecondSquareConversion = !secondHasSquare;

      final String identityBoxLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Numerical Identity (Example 6, Page 78)} & \\textbf{Step-by-Step Evaluation} \\\\ \\hline "
          "x^2 - y^2 = (x + y)(x - y) & $givenExprLaTeX \\\\ "
          "x = \\mathbf{$aStr}, \\quad y = \\mathbf{$bStr} & ${neededSecondSquareConversion ? '= $rewrittenSquaresLaTeX' : '= ($aStr + $bStr)($aStr - $bStr)'} \\\\ "
          "x + y = $aStr + $bStr = \\mathbf{$sumStr} & = ($aStr + $bStr)($aStr - $bStr) \\\\ "
          "x - y = $aStr - $bStr = \\mathbf{$diffStr} & = $sumStr \\times $diffStr = \\mathbf{$finalProductStr} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Rule (Example 6, Page 78):}} \\text{ The difference of two squares } x^2 - y^2 = (x + y)(x - y) \\text{ can be used to evaluate numerical expressions.}",
        "\\text{Given Numerical Expression: } \\mathbf{$givenExprLaTeX}",
        if (neededSecondSquareConversion) ...[
          "",
          "\\text{\\textbf{Step 1: Express }} \\mathbf{$givenSecondLaTeX} \\text{\\textbf{ in Index Square Form (Example 6a–d, Page 78)}}",
          "\\text{Since } \\sqrt{$givenSecondLaTeX} = $bStr, \\text{ we write } $givenSecondLaTeX = $bStr^2:",
          "$givenExprLaTeX = \\mathbf{$rewrittenSquaresLaTeX}",
        ],
        "",
        "\\text{\\textbf{Step ${neededSecondSquareConversion ? 2 : 1}: Apply the Difference of Two Squares Identity }} \\mathbf{x^2 - y^2 = (x + y)(x - y)}",
        "$rewrittenSquaresLaTeX = ($aStr + $bStr)($aStr - $bStr)",
        "",
        "\\text{\\textbf{Step ${neededSecondSquareConversion ? 3 : 2}: Evaluate Each Bracket and Multiply}}",
        "\\bullet \\text{ First bracket (Sum): } $aStr + $bStr = \\mathbf{$sumStr}",
        "\\bullet \\text{ Second bracket (Difference): } $aStr - $bStr = \\mathbf{$diffStr}",
        "= $sumStr \\times $diffStr",
        "= \\mathbf{$finalProductStr}",
      ];

      final List<DifferenceOfTwoSquaresStep> steps = [
        if (neededSecondSquareConversion)
          DifferenceOfTwoSquaresStep(
            title:
            "Step 1: Write $givenSecondLaTeX as a Square ($bStr²) (Example 6a–d, Page 78)",
            description:
            "• Notice that $givenSecondLaTeX is a perfect square number ($bStr × $bStr = $givenSecondLaTeX). Rewrite the expression as $aStr² − $bStr².",
            mathLinesLaTeX: [
              "$givenSecondLaTeX = $bStr^2",
              "$givenExprLaTeX = $rewrittenSquaresLaTeX",
            ],
          ),
        DifferenceOfTwoSquaresStep(
          title:
          "Step ${neededSecondSquareConversion ? 2 : 1}: Apply x² − y² = (x + y)(x − y)",
          description:
          "• Substitute x = $aStr and y = $bStr into the difference of two squares formula instead of squaring the large numbers directly.",
          mathLinesLaTeX: [
            "$rewrittenSquaresLaTeX = ($aStr + $bStr)($aStr - $bStr)",
          ],
        ),
        DifferenceOfTwoSquaresStep(
          title:
          "Step ${neededSecondSquareConversion ? 3 : 2}: Simplify Each Bracket and Multiply",
          description:
          "• Add inside the first bracket: $aStr + $bStr = $sumStr.\n"
              "• Subtract inside the second bracket: $aStr − $bStr = $diffStr.\n"
              "• Multiply the two results: $sumStr × $diffStr = $finalProductStr.",
          mathLinesLaTeX: [
            "= $sumStr \\times $diffStr",
            "= \\mathbf{$finalProductStr}",
          ],
        ),
      ];

      return DifferenceOfTwoSquaresResult(
        mode: 1,
        finalAnswersLaTeX: {
          "Given Expression": givenExprLaTeX,
          "Difference of Squares": rewrittenSquaresLaTeX,
          "Product of Brackets": "$sumStr \\times $diffStr",
          "Exact Evaluated Value": "\\mathbf{$finalProductStr}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: DifferenceOfTwoSquaresCanvasData(
          headerLaTeX:
          "\\text{Numerical Evaluation (Example 6, Page 78): } $givenExprLaTeX = \\mathbf{$finalProductStr}",
          subHeaderLaTeX:
          "$rewrittenSquaresLaTeX = ($aStr + $bStr)($aStr - $bStr) = $sumStr \\times $diffStr = \\mathbf{$finalProductStr}",
          card1Title: "Sum (x + y)",
          card1LaTeX: "$aStr + $bStr = \\mathbf{$sumStr}",
          card2Title: "Difference (x - y)",
          card2LaTeX: "$aStr - $bStr = \\mathbf{$diffStr}",
          card3Title: "Final Value",
          card3LaTeX: "\\mathbf{$finalProductStr}",
          identityBoxLaTeX: identityBoxLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $givenExprLaTeX = $sumStr \\times $diffStr = \\mathbf{$finalProductStr}",
        ),
      );
    } catch (e) {
      return DifferenceOfTwoSquaresResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid numerical values (e.g. 56^2 and 16, or 53^2 and 3^2).",
      );
    }
  }
}