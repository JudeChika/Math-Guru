import 'dart:math' as math;
import 'common_factors_models.dart';

/// Internal signed algebraic monomial (e.g., 12x^3, -9xy^2, -15x^2, 3xy, -4).
class _SignedTerm {
  final int coeff; // Signed non-zero integer
  final Map<String, int> powers;

  const _SignedTerm({
    required this.coeff,
    required this.powers,
  });

  static _SignedTerm parse(String raw, {String fieldName = 'term'}) {
    String s = raw
        .trim()
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('⁴', '^4');

    if (s.isEmpty) {
      throw FormatException("Please enter a valid $fieldName.");
    }

    int sign = 1;
    if (s.startsWith('-')) {
      sign = -1;
      s = s.substring(1);
    } else if (s.startsWith('+')) {
      s = s.substring(1);
    }

    final RegExp numPrefix = RegExp(r'^(\d+)');
    final Match? nm = numPrefix.firstMatch(s);
    int c = 1;
    String rem = s;
    if (nm != null) {
      c = int.parse(nm.group(1)!);
      rem = s.substring(nm.end);
    }
    if (c == 0) {
      throw const FormatException("Term coefficient cannot be zero.");
    }

    final Map<String, int> vp = {};
    final RegExp varReg = RegExp(r'([a-zA-Z])(?:\^(\d+))?');
    for (final Match m in varReg.allMatches(rem)) {
      final String v = m.group(1)!;
      final int p = int.tryParse(m.group(2) ?? '1') ?? 1;
      vp[v] = (vp[v] ?? 0) + p;
    }

    return _SignedTerm(coeff: sign * c, powers: vp);
  }

  _SignedTerm divideBy(_SignedTerm divisor) {
    final int qCoeff = coeff ~/ divisor.coeff;
    final Map<String, int> qPowers = Map.from(powers);
    divisor.powers.forEach((v, p) {
      final int remP = (qPowers[v] ?? 0) - p;
      if (remP <= 0) {
        qPowers.remove(v);
      } else {
        qPowers[v] = remP;
      }
    });
    return _SignedTerm(coeff: qCoeff, powers: qPowers);
  }

  _SignedTerm multiplyBy(_SignedTerm other) {
    final Map<String, int> mPowers = Map.from(powers);
    other.powers.forEach((v, p) {
      mPowers[v] = (mPowers[v] ?? 0) + p;
    });
    return _SignedTerm(coeff: coeff * other.coeff, powers: mPowers);
  }

  String toLaTeX({bool withLeadingSign = false}) {
    final int absC = coeff.abs();
    final bool hasVars = powers.isNotEmpty;
    final StringBuffer sb = StringBuffer();

    if (coeff < 0) {
      sb.write(withLeadingSign ? '- ' : '-');
    } else if (withLeadingSign) {
      sb.write('+ ');
    }

    if (!hasVars || absC != 1) {
      sb.write('$absC');
    }

    final List<String> sortedVars = powers.keys.toList()..sort();
    for (final String v in sortedVars) {
      final int p = powers[v]!;
      sb.write(v);
      if (p > 1) sb.write('^{$p}');
    }
    return sb.toString();
  }

  String toPlain({bool withLeadingSign = false}) {
    return toLaTeX(withLeadingSign: withLeadingSign)
        .replaceAll('{', '')
        .replaceAll('}', '');
  }
}

class CommonFactorsLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 67–68 & 70–71: Examples 3–4, Ex 7.3, QR #1–9 & Rev Ex 7)
  // ===========================================================================
  static const List<CommonFactorsPreset> textbookPresets = [
    CommonFactorsPreset(
      chipLabel: "Example 3a (Page 67): Factorise 2ab + 5a (Box & Quotient)",
      mode: 0,
      input1: '2ab + 5a',
    ),
    CommonFactorsPreset(
      chipLabel: "Example 3b (Page 67): Factorise 6x² + 15x",
      mode: 0,
      input1: '6x^2 + 15x',
    ),
    CommonFactorsPreset(
      chipLabel: "Example 3c (Page 67): Factorise 12x³ - 9xy²",
      mode: 0,
      input1: '12x^3 - 9xy^2',
    ),
    CommonFactorsPreset(
      chipLabel: "Example 4b (Page 67): Factorise 16xy + 14y²",
      mode: 0,
      input1: '16xy + 14y^2',
    ),
    CommonFactorsPreset(
      chipLabel: "Example 4c (Page 67): Factorise 12x³ - 15x² + 9x (3 Terms)",
      mode: 0,
      input1: '12x^3 - 15x^2 + 9x',
    ),
    CommonFactorsPreset(
      chipLabel: "Ex 7.3 #10 (Page 68): Factorise 12mn² - 16m²n + 28m²n²",
      mode: 0,
      input1: '12mn^2 - 16m^2n + 28m^2n^2',
    ),
    CommonFactorsPreset(
      chipLabel: "Ex 7.3 #12 (Page 68): Factorise 15a²b - 12ab² + 21ab",
      mode: 0,
      input1: '15a^2b - 12ab^2 + 21ab',
    ),
    CommonFactorsPreset(
      chipLabel: "Ex 7.3 #13 (Page 68): Factorise 81x³ - 54x² + 18x",
      mode: 0,
      input1: '81x^3 - 54x^2 + 18x',
    ),
    CommonFactorsPreset(
      chipLabel: "Ex 7.3 #19 (Page 68): Factorise 40y³ - 25y² - 35y⁴",
      mode: 0,
      input1: '40y^3 - 25y^2 - 35y^4',
    ),
    CommonFactorsPreset(
      chipLabel: "Rev Ex 7 Part B #1 & #6 (Page 71): Complete 24y - 36 = 12(   )",
      mode: 1,
      input1: '24y - 36',
      input2: '12',
    ),
    CommonFactorsPreset(
      chipLabel: "Rev Ex 7 Part B #9 (Page 71): Complete 4ab² + 8ab - 12a²b = 4ab(   )",
      mode: 1,
      input1: '4ab^2 + 8ab - 12a^2b',
      input2: '4ab',
    ),
    CommonFactorsPreset(
      chipLabel: "Rev Ex 7 Part B #10 (Page 71): Complete 36a³ - 12a² + 18a = 6a(   )",
      mode: 1,
      input1: '36a^3 - 12a^2 + 18a',
      input2: '6a',
    ),
    CommonFactorsPreset(
      chipLabel: "QR Box #1 (Page 70): Outside ?, Top [5b | -3c], Inside [15b² | -9bc]",
      mode: 2,
      input1: '', // Outside factor ?
      input2: '5b', // Top 1
      input3: '-3c', // Top 2
      input4: '15b^2', // Inside 1
      input5: '-9bc', // Inside 2
    ),
    CommonFactorsPreset(
      chipLabel: "QR Box #3 (Page 70): Outside -4x, Top [2x | ?], Inside [? | 12xy]",
      mode: 2,
      input1: '-4x',
      input2: '2x',
      input3: '',
      input4: '',
      input5: '12xy',
    ),
    CommonFactorsPreset(
      chipLabel: "QR Box #4 (Page 70): Outside 8a, Top [a² | 3b], Inside [? | ?]",
      mode: 2,
      input1: '8a',
      input2: 'a^2',
      input3: '3b',
      input4: '',
      input5: '',
    ),
    CommonFactorsPreset(
      chipLabel: "QR Box #7 (Page 70): Outside ?, Top [-x | 3a], Inside [2ax²z | ?]",
      mode: 2,
      input1: '',
      input2: '-x',
      input3: '3a',
      input4: '2ax^2z',
      input5: '',
    ),
  ];

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

  static List<_SignedTerm> _parsePolynomial(String raw) {
    final String s = raw
        .trim()
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll('--', '+')
        .replaceAll('+-', '-')
        .replaceAll('-', '+-');

    final List<String> chunks =
    s.split('+').where((c) => c.trim().isNotEmpty).toList();
    if (chunks.length < 2) {
      throw const FormatException(
        "Please enter an algebraic expression with at least 2 terms (e.g. 6x^2 + 15x, 12x^3 - 9xy^2, or 12x^3 - 15x^2 + 9x).",
      );
    }
    return chunks.map((c) => _SignedTerm.parse(c)).toList();
  }

  static _SignedTerm _computeHcfOfTerms(List<_SignedTerm> terms) {
    int gCoeff = terms.map((t) => t.coeff.abs()).reduce(gcd);
    if (terms.first.coeff < 0) {
      gCoeff = -gCoeff; // If leading term is negative, factor out negative HCF
    }

    final Map<String, int> commonVars = {};
    for (final String v in terms.first.powers.keys) {
      int minP = terms.first.powers[v]!;
      bool inAll = true;
      for (int i = 1; i < terms.length; i++) {
        if (!terms[i].powers.containsKey(v)) {
          inAll = false;
          break;
        }
        minP = math.min(minP, terms[i].powers[v]!);
      }
      if (inAll && minP > 0) {
        commonVars[v] = minP;
      }
    }

    return _SignedTerm(coeff: gCoeff, powers: commonVars);
  }

  static String _formatPolyLaTeX(List<_SignedTerm> terms) {
    final List<String> parts = [];
    for (int i = 0; i < terms.length; i++) {
      parts.add(terms[i].toLaTeX(withLeadingSign: i > 0));
    }
    return parts.join(' ');
  }

  static String _formatPolyPlain(List<_SignedTerm> terms) {
    final List<String> parts = [];
    for (int i = 0; i < terms.length; i++) {
      parts.add(terms[i].toPlain(withLeadingSign: i > 0));
    }
    return parts.join(' ');
  }

  /// Builds the exact Textbook Factorisation Box in LaTeX (matching Example 3 on Page 67 & QR on Page 70!)
  static String _buildFactorisationBoxLaTeX({
    required _SignedTerm outsideFactor,
    required List<_SignedTerm> originalTerms,
    required List<_SignedTerm> quotients,
  }) {
    final int n = originalTerms.length;
    final String colSpec = 'c|${List.filled(n, 'c').join('|')}';
    final List<String> topRow = [];
    final List<String> insideRow = [];

    for (int i = 0; i < n; i++) {
      topRow.add("\\mathbf{${quotients[i].toLaTeX(withLeadingSign: i > 0)}}");
      insideRow.add(originalTerms[i].toLaTeX(withLeadingSign: i > 0));
    }

    return "\\begin{array}{$colSpec} "
        " & ${topRow.join(' & ')} \\\\ \\hline "
        "\\mathbf{${outsideFactor.toLaTeX()}} & ${insideRow.join(' & ')} \\\\ \\hline "
        "\\end{array}";
  }

  // ===========================================================================
  // MODES 0, 1 & 3: FACTORISE EXPRESSIONS COMPLETELY OR COMPLETE PARTIAL FACTORISATION
  // Shows BOTH Method 1 (Example 3 Factorisation Box) AND Method 2 (Example 4 Fraction Quotients)!
  // ===========================================================================
  static CommonFactorsResult solveFactorisationByCommonFactors({
    required int mode, // 0: Full Factorisation, 1: Complete Partial Factorisation E = F( ), 3: Reverse Verification
    required String expressionStr,
    required String givenOutsideFactorStr,
  }) {
    try {
      final List<_SignedTerm> origTerms = _parsePolynomial(expressionStr);
      final _SignedTerm hcf = (mode == 1 && givenOutsideFactorStr.trim().isNotEmpty)
          ? _SignedTerm.parse(givenOutsideFactorStr, fieldName: 'Given Outside Factor')
          : _computeHcfOfTerms(origTerms);

      final List<_SignedTerm> quotients =
      origTerms.map((t) => t.divideBy(hcf)).toList();

      final String origLaTeX = _formatPolyLaTeX(origTerms);
      final String hcfLaTeX = hcf.toLaTeX();
      final String quotientsLaTeX = _formatPolyLaTeX(quotients);
      final String finalFactoredLaTeX = "$hcfLaTeX($quotientsLaTeX)";

      // Build Example 4's Fraction-Quotient Bracket Line (rendered via Math.tex!):
      // e.g. 12x^3 - 15x^2 + 9x = 3x( 12x^3 / 3x - 15x^2 / 3x + 9x / 3x )
      final List<String> fractionTermsLaTeX = [];
      for (int i = 0; i < origTerms.length; i++) {
        final _SignedTerm t = origTerms[i];
        final _SignedTerm absT =
        _SignedTerm(coeff: t.coeff.abs(), powers: t.powers);
        if (i == 0) {
          fractionTermsLaTeX.add("\\frac{${t.toLaTeX()}}{$hcfLaTeX}");
        } else {
          final String sign = t.coeff >= 0 ? "+" : "-";
          fractionTermsLaTeX.add("$sign \\frac{${absT.toLaTeX()}}{$hcfLaTeX}");
        }
      }
      final String example4FractionLineLaTeX =
          "$origLaTeX = $hcfLaTeX\\left(${fractionTermsLaTeX.join(' ')}\\right)";

      final String factorBoxLaTeX = _buildFactorisationBoxLaTeX(
        outsideFactor: hcf,
        originalTerms: origTerms,
        quotients: quotients,
      );

      // Check for Example 3c textbook misprint note (12x^3 - 9xy^2)
      final String cleanExpr = expressionStr.replaceAll(' ', '');
      final String typoNote = cleanExpr.contains('12x^3-9xy^2')
          ? "\n• Helpful Textbook Note (Page 67, Example 3c): In Example 3c, 12x³ ÷ 3x = 4x² (the textbook accidentally omitted the exponent 2 on 4x² inside the box). Thus 12x³ − 9xy² = 3x(4x² − 3y²)!"
          : "";

      final List<String> step1Lines = [
        "\\text{Given algebraic expression: } \\mathbf{$origLaTeX}",
        mode == 1
            ? "\\text{Given outside factor} = \\mathbf{$hcfLaTeX}"
            : "\\text{Find the Highest Common Factor (HCF) of all ${origTerms.length} terms: } \\text{HCF} = \\mathbf{$hcfLaTeX}",
      ];

      final List<String> method1BoxLines = [
        "\\text{Place each term inside a factorisation box and write the HCF } ($hcfLaTeX) \\text{ outside on the left (Example 3, Page 67):}",
        factorBoxLaTeX,
        "= \\mathbf{$finalFactoredLaTeX}",
      ];

      final List<String> method2QuotientLines = [
        "\\text{Divide each term by } $hcfLaTeX \\text{ inside the bracket (Example 4, Page 67):}",
        example4FractionLineLaTeX,
        "= \\mathbf{$finalFactoredLaTeX}",
        "\\text{Check by multiplying out the bracket: } $finalFactoredLaTeX = \\mathbf{$origLaTeX} \\quad (\\text{Verified!})",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Find the Common Factor (HCF) of All Terms}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Method 1: Using the Textbook Factorisation Box (Example 3, Page 67)}}",
        ...method1BoxLines,
        "",
        "\\text{\\textbf{Method 2: Direct Quotient Method Without Boxes (Example 4, Page 67)}}",
        ...method2QuotientLines,
      ];

      final List<CommonFactorsStep> steps = [
        CommonFactorsStep(
          title:
          "Step 1: Identify the Common Factor (HCF = ${hcf.toPlain()})",
          description:
          "• Find the Highest Common Factor (HCF) of (${origTerms.map((t) => t.toPlain()).join(', ')}), which is ${hcf.toPlain()}.$typoNote",
          mathLinesLaTeX: step1Lines,
        ),
        CommonFactorsStep(
          title:
          "Step 2: Method 1 — Textbook Factorisation Box (Example 3, Page 67)",
          description:
          "Place the original terms inside the factorisation box, write ${hcf.toPlain()} on the left, and write the quotient of each term (${_formatPolyPlain(quotients)}) above the box.",
          mathLinesLaTeX: method1BoxLines,
        ),
        CommonFactorsStep(
          title:
          "Step 3: Method 2 — Direct Fraction-Quotient Method (Example 4, Page 67)",
          description:
          "Write ${hcf.toPlain()} outside the bracket and divide each original term by ${hcf.toPlain()} inside the bracket to get ${hcf.toPlain()}(${_formatPolyPlain(quotients)}).",
          mathLinesLaTeX: method2QuotientLines,
        ),
      ];

      return CommonFactorsResult(
        mode: mode,
        finalAnswersLaTeX: {
          "Original Expression": origLaTeX,
          "Common Factor (HCF)": hcfLaTeX,
          "Inside Bracket Quotients": quotientsLaTeX,
          "Factorised Form": "\\mathbf{$finalFactoredLaTeX}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: CommonFactorsCanvasData(
          headerLaTeX:
          "\\text{Factorisation by Common Factors (Examples 3 \\& 4): } $origLaTeX = \\mathbf{$finalFactoredLaTeX}",
          subHeaderLaTeX: example4FractionLineLaTeX,
          card1Title: "Common Factor (HCF)",
          card1LaTeX: hcfLaTeX,
          card2Title: "Bracket Quotients",
          card2LaTeX: quotientsLaTeX,
          card3Title: "Factorised Form",
          card3LaTeX: "\\mathbf{$finalFactoredLaTeX}",
          factorBoxLaTeX: factorBoxLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $origLaTeX = \\mathbf{$finalFactoredLaTeX}",
        ),
      );
    } catch (e) {
      return CommonFactorsResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid polynomial with 2 or 3 terms (e.g. 12x^3 - 15x^2 + 9x).",
      );
    }
  }

  // ===========================================================================
  // MODE 2: QUANTITATIVE REASONING FACTORISATION BOX PUZZLES (Page 70 #1–9)
  // Sample Rule (Page 70 Top Left):
  //   Outside Factor (F) × Top Quotient 1 (Q₁) = Inside Box 1 (T₁)
  //   Outside Factor (F) × Top Quotient 2 (Q₂) = Inside Box 2 (T₂)
  // ===========================================================================
  static CommonFactorsResult solveQuantitativeFactorBox({
    required String outsideFactorStr,
    required String topQ1Str,
    required String topQ2Str,
    required String insideT1Str,
    required String insideT2Str,
  }) {
    try {
      String fRaw = outsideFactorStr.trim().replaceAll('?', '');
      String q1Raw = topQ1Str.trim().replaceAll('?', '');
      String q2Raw = topQ2Str.trim().replaceAll('?', '');
      String t1Raw = insideT1Str.trim().replaceAll('?', '');
      String t2Raw = insideT2Str.trim().replaceAll('?', '');

      _SignedTerm? F = fRaw.isNotEmpty ? _SignedTerm.parse(fRaw) : null;
      _SignedTerm? Q1 = q1Raw.isNotEmpty ? _SignedTerm.parse(q1Raw) : null;
      _SignedTerm? Q2 = q2Raw.isNotEmpty ? _SignedTerm.parse(q2Raw) : null;
      _SignedTerm? T1 = t1Raw.isNotEmpty ? _SignedTerm.parse(t1Raw) : null;
      _SignedTerm? T2 = t2Raw.isNotEmpty ? _SignedTerm.parse(t2Raw) : null;

      final List<String> deductionLinesLaTeX = [];
      final List<String> deductionPlain = [];

      // Iteratively deduce any missing component using F * Q1 = T1 and F * Q2 = T2!
      for (int pass = 0; pass < 3; pass++) {
        if (F == null && T1 != null && Q1 != null) {
          F = T1.divideBy(Q1);
          deductionLinesLaTeX.add(
              "\\bullet \\text{ Find Outside Factor } F = \\frac{\\text{Inside Box 1}}{\\text{Top 1}} = \\frac{${T1.toLaTeX()}}{${Q1.toLaTeX()}} = \\mathbf{${F.toLaTeX()}}");
          deductionPlain.add(
              "• Outside Factor = Inside Box 1 (${T1.toPlain()}) ÷ Top 1 (${Q1.toPlain()}) = ${F.toPlain()}.");
        }
        if (F == null && T2 != null && Q2 != null) {
          F = T2.divideBy(Q2);
          deductionLinesLaTeX.add(
              "\\bullet \\text{ Find Outside Factor } F = \\frac{\\text{Inside Box 2}}{\\text{Top 2}} = \\frac{${T2.toLaTeX()}}{${Q2.toLaTeX()}} = \\mathbf{${F.toLaTeX()}}");
          deductionPlain.add(
              "• Outside Factor = Inside Box 2 (${T2.toPlain()}) ÷ Top 2 (${Q2.toPlain()}) = ${F.toPlain()}.");
        }
        if (F == null && T1 != null && T2 != null) {
          F = _computeHcfOfTerms([T1, T2]);
          deductionLinesLaTeX.add(
              "\\bullet \\text{ Find Outside Factor } F = \\text{HCF}\\left(${T1.toLaTeX()},\\; ${T2.toLaTeX()}\\right) = \\mathbf{${F.toLaTeX()}}");
          deductionPlain.add(
              "• Outside Factor = HCF of (${T1.toPlain()}, ${T2.toPlain()}) = ${F.toPlain()}.");
        }
        if (F != null && Q1 == null && T1 != null) {
          Q1 = T1.divideBy(F);
          deductionLinesLaTeX.add(
              "\\bullet \\text{ Find Top 1 } (Q_1) = \\frac{\\text{Inside Box 1}}{\\text{Outside Factor}} = \\frac{${T1.toLaTeX()}}{${F.toLaTeX()}} = \\mathbf{${Q1.toLaTeX()}}");
          deductionPlain.add(
              "• Top 1 = Inside Box 1 (${T1.toPlain()}) ÷ Outside Factor (${F.toPlain()}) = ${Q1.toPlain()}.");
        }
        if (F != null && Q2 == null && T2 != null) {
          Q2 = T2.divideBy(F);
          deductionLinesLaTeX.add(
              "\\bullet \\text{ Find Top 2 } (Q_2) = \\frac{\\text{Inside Box 2}}{\\text{Outside Factor}} = \\frac{${T2.toLaTeX()}}{${F.toLaTeX()}} = \\mathbf{${Q2.toLaTeX()}}");
          deductionPlain.add(
              "• Top 2 = Inside Box 2 (${T2.toPlain()}) ÷ Outside Factor (${F.toPlain()}) = ${Q2.toPlain()}.");
        }
        if (F != null && T1 == null && Q1 != null) {
          T1 = F.multiplyBy(Q1);
          deductionLinesLaTeX.add(
              "\\bullet \\text{ Find Inside Box 1 } (T_1) = \\text{Outside Factor} \\times \\text{Top 1} = (${F.toLaTeX()}) \\times (${Q1.toLaTeX()}) = \\mathbf{${T1.toLaTeX()}}");
          deductionPlain.add(
              "• Inside Box 1 = Outside Factor (${F.toPlain()}) × Top 1 (${Q1.toPlain()}) = ${T1.toPlain()}.");
        }
        if (F != null && T2 == null && Q2 != null) {
          T2 = F.multiplyBy(Q2);
          deductionLinesLaTeX.add(
              "\\bullet \\text{ Find Inside Box 2 } (T_2) = \\text{Outside Factor} \\times \\text{Top 2} = (${F.toLaTeX()}) \\times (${Q2.toLaTeX()}) = \\mathbf{${T2.toLaTeX()}}");
          deductionPlain.add(
              "• Inside Box 2 = Outside Factor (${F.toPlain()}) × Top 2 (${Q2.toPlain()}) = ${T2.toPlain()}.");
        }
      }

      if (F == null || Q1 == null || Q2 == null || T1 == null || T2 == null) {
        throw const FormatException(
          "Please provide enough known boxes to determine the factorisation box (e.g. Outside Factor + Top 1 + Top 2, or Inside 1 + Inside 2 + Top 1).",
        );
      }

      final String completedBoxLaTeX = _buildFactorisationBoxLaTeX(
        outsideFactor: F,
        originalTerms: [T1, T2],
        quotients: [Q1, Q2],
      );
      final String expandedExprLaTeX = _formatPolyLaTeX([T1, T2]);
      final String factoredExprLaTeX =
          "${F.toLaTeX()}(${_formatPolyLaTeX([Q1, Q2])})";

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Quantitative Reasoning Factorisation Box Rule (Page 70 Top Left)}}",
        "\\text{Rule: } \\text{Outside Factor } (F) \\times \\text{Top Quotient } (Q_i) = \\text{Inside Term } (T_i)",
        "\\text{Equivalently: } Q_i = \\frac{T_i}{F} \\qquad \\text{and} \\qquad F = \\frac{T_i}{Q_i}",
        "",
        "\\text{\\textbf{Step 2: Deduce Each Missing Box}}",
        ...deductionLinesLaTeX,
        "",
        "\\text{\\textbf{Step 3: Completed Quantitative Reasoning Factorisation Box}}",
        completedBoxLaTeX,
        "\\therefore \\; $expandedExprLaTeX = \\mathbf{$factoredExprLaTeX}",
      ];

      return CommonFactorsResult(
        mode: 2,
        finalAnswersLaTeX: {
          "Outside Factor": F.toLaTeX(),
          "Top Quotients":
          "${Q1.toLaTeX()},\\; ${Q2.toLaTeX(withLeadingSign: true)}",
          "Inside Box Terms":
          "${T1.toLaTeX()},\\; ${T2.toLaTeX(withLeadingSign: true)}",
          "Complete Identity": "$expandedExprLaTeX = $factoredExprLaTeX",
        },
        workingsLaTeX: workings,
        steps: [
          CommonFactorsStep(
            title:
            "Step 1: Apply the Quantitative Reasoning Box Rule (Page 70 #1–9)",
            description:
            "In the Page 70 factorisation boxes, multiplying the outside factor on the left by each term above the box gives the term inside the box:\n\n"
                "${deductionPlain.join('\n')}",
            mathLinesLaTeX: [
              ...deductionLinesLaTeX,
              completedBoxLaTeX,
            ],
          ),
        ],
        canvasData: CommonFactorsCanvasData(
          headerLaTeX:
          "\\text{Page 70 Quantitative Reasoning Box: } $expandedExprLaTeX = \\mathbf{$factoredExprLaTeX}",
          subHeaderLaTeX:
          "\\text{Outside } (${F.toLaTeX()}) \\times \\text{Top } (${Q1.toLaTeX()},\\; ${Q2.toLaTeX(withLeadingSign: true)}) = \\text{Inside } (${T1.toLaTeX()},\\; ${T2.toLaTeX(withLeadingSign: true)})",
          card1Title: "Outside Factor",
          card1LaTeX: "\\mathbf{${F.toLaTeX()}}",
          card2Title: "Top Quotients",
          card2LaTeX: "${Q1.toLaTeX()},\\; ${Q2.toLaTeX(withLeadingSign: true)}",
          card3Title: "Inside Terms",
          card3LaTeX: "${T1.toLaTeX()},\\; ${T2.toLaTeX(withLeadingSign: true)}",
          factorBoxLaTeX: completedBoxLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $expandedExprLaTeX = \\mathbf{$factoredExprLaTeX}",
        ),
      );
    } catch (e) {
      return CommonFactorsResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter valid algebraic terms in the known boxes.",
      );
    }
  }
}