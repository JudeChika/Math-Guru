import 'dart:math' as math;
import 'hcf_algebraic_models.dart';

/// Internal parsed representation of a positive/negative algebraic monomial (e.g., 8m^3n^2, 24mn^2, 21x^2y).
class _AlgMonomial {
  final int coeff; // Positive integer coefficient
  final bool isNegative;
  final Map<String, int> powers;

  const _AlgMonomial({
    required this.coeff,
    this.isNegative = false,
    required this.powers,
  });

  static _AlgMonomial parse(String raw, {String fieldName = 'algebraic term'}) {
    String s = raw
        .trim()
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('⁴', '^4');

    if (s.isEmpty) {
      throw FormatException(
        "Please enter a valid $fieldName (e.g. 9ab, 15xy^2, 8m^3n^2, or 21x^2y).",
      );
    }

    bool neg = false;
    if (s.startsWith('-')) {
      neg = true;
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
    if (c <= 0) {
      throw FormatException("Coefficient in '$raw' must be non-zero.");
    }

    final Map<String, int> vp = {};
    final RegExp varReg = RegExp(r'([a-zA-Z])(?:\^(\d+))?');
    for (final Match m in varReg.allMatches(rem)) {
      final String v = m.group(1)!;
      final int p = int.tryParse(m.group(2) ?? '1') ?? 1;
      vp[v] = (vp[v] ?? 0) + p;
    }

    return _AlgMonomial(coeff: c, isNegative: neg, powers: vp);
  }

  _AlgMonomial divideByPrime(int p) =>
      _AlgMonomial(coeff: coeff ~/ p, isNegative: isNegative, powers: powers);

  _AlgMonomial divideByVariable(String v) {
    final Map<String, int> nextP = Map.from(powers);
    final int cur = nextP[v] ?? 0;
    if (cur <= 1) {
      nextP.remove(v);
    } else {
      nextP[v] = cur - 1;
    }
    return _AlgMonomial(coeff: coeff, isNegative: isNegative, powers: nextP);
  }

  String toLaTeX() {
    final StringBuffer sb = StringBuffer();
    if (isNegative) sb.write('-');
    if (powers.isEmpty || coeff != 1) {
      sb.write('$coeff');
    }
    final List<String> vars = powers.keys.toList()..sort();
    for (final String v in vars) {
      final int p = powers[v]!;
      sb.write(v);
      if (p > 1) sb.write('^{$p}');
    }
    return sb.toString();
  }

  String toPlain() {
    return toLaTeX().replaceAll('{', '').replaceAll('}', '');
  }

  /// Expanded prime-factor and single-letter product string (e.g. "3 × 5 × x × y × y")
  String toExpandedFactorsLaTeX() {
    final List<String> factors = [];
    int tempC = coeff;
    if (tempC == 1 && powers.isEmpty) return '1';

    int d = 2;
    while (d * d <= tempC) {
      while (tempC % d == 0) {
        factors.add('$d');
        tempC ~/= d;
      }
      d++;
    }
    if (tempC > 1) factors.add('$tempC');

    final List<String> vars = powers.keys.toList()..sort();
    for (final String v in vars) {
      final int p = powers[v]!;
      for (int k = 0; k < p; k++) {
        factors.add(v);
      }
    }
    return factors.join(' \\times ');
  }
}

class HcfAlgebraicLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 66–67: Example 2a–e & Exercise 7.2 #1–20)
  // ===========================================================================
  static const List<HcfAlgebraicPreset> textbookPresets = [
    HcfAlgebraicPreset(
      chipLabel: "Example 2a (Page 66): HCF of 9ab and 27abc",
      mode: 0,
      input1: '9ab',
      input2: '27abc',
    ),
    HcfAlgebraicPreset(
      chipLabel: "Example 2b (Page 66): HCF of 15xy² and 25x²y",
      mode: 0,
      input1: '15xy^2',
      input2: '25x^2y',
    ),
    HcfAlgebraicPreset(
      chipLabel: "Example 2c (Page 66): HCF of 8m³n² and 24mn²",
      mode: 0,
      input1: '8m^3n^2',
      input2: '24mn^2',
    ),
    HcfAlgebraicPreset(
      chipLabel: "Example 2d (Page 66): HCF of 30xy and 18xz",
      mode: 0,
      input1: '30xy',
      input2: '18xz',
    ),
    HcfAlgebraicPreset(
      chipLabel: "Example 2e (Page 66): HCF of 7y², 21x²y and 35yz",
      mode: 1,
      input1: '7y^2',
      input2: '21x^2y',
      input3: '35yz',
    ),
    HcfAlgebraicPreset(
      chipLabel: "Ex 7.2 #5: HCF of 27xy and 18yz",
      mode: 0,
      input1: '27xy',
      input2: '18yz',
    ),
    HcfAlgebraicPreset(
      chipLabel: "Ex 7.2 #6: HCF of 12abc and 18bcd",
      mode: 0,
      input1: '12abc',
      input2: '18bcd',
    ),
    HcfAlgebraicPreset(
      chipLabel: "Ex 7.2 #7: HCF of 3x²y and 12xy²",
      mode: 0,
      input1: '3x^2y',
      input2: '12xy^2',
    ),
    HcfAlgebraicPreset(
      chipLabel: "Ex 7.2 #10: HCF of 3ab, 9b and 15bc",
      mode: 1,
      input1: '3ab',
      input2: '9b',
      input3: '15bc',
    ),
    HcfAlgebraicPreset(
      chipLabel: "Ex 7.2 #12: HCF of 12x², 18xy and 42xz",
      mode: 1,
      input1: '12x^2',
      input2: '18xy',
      input3: '42xz',
    ),
    HcfAlgebraicPreset(
      chipLabel: "Ex 7.2 #15: HCF of 14pq, 6p²q and 8pqr",
      mode: 1,
      input1: '14pq',
      input2: '6p^2q',
      input3: '8pqr',
    ),
    HcfAlgebraicPreset(
      chipLabel: "Ex 7.2 #16: HCF of 22g²h, 33gh² and 55ghk",
      mode: 1,
      input1: '22g^2h',
      input2: '33gh^2',
      input3: '55ghk',
    ),
    HcfAlgebraicPreset(
      chipLabel: "Ex 7.2 #17: HCF of 14a²b, 28ab² and 35a²b²c",
      mode: 1,
      input1: '14a^2b',
      input2: '28ab^2',
      input3: '35a^2b^2c',
    ),
    HcfAlgebraicPreset(
      chipLabel: "Ex 7.2 #18: HCF of 6abc², 12abc and 20a²b²c³",
      mode: 1,
      input1: '6abc^2',
      input2: '12abc',
      input3: '20a^2b^2c^3',
    ),
    HcfAlgebraicPreset(
      chipLabel: "Ex 7.2 #19: HCF of 12mn², 15m²n³ and 21m²n",
      mode: 1,
      input1: '12mn^2',
      input2: '15m^2n^3',
      input3: '21m^2n',
    ),
    HcfAlgebraicPreset(
      chipLabel: "Ex 7.2 #20: HCF of 13xyz, 39x²yz² and 52x²z",
      mode: 1,
      input1: '13xyz',
      input2: '39x^2yz^2',
      input3: '52x^2z',
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

  // ===========================================================================
  // MASTER SOLVER: HCF OF 2 OR 3 ALGEBRAIC EXPRESSIONS
  // Replicates Example 2(a–e) Vertical Division Table AND Expanded Factor Comparison!
  // ===========================================================================
  static HcfAlgebraicResult solveHcfOfAlgebraicExpressions({
    required int mode,
    required String term1Str,
    required String term2Str,
    required String term3OptionalStr,
  }) {
    try {
      final _AlgMonomial t1 =
      _AlgMonomial.parse(term1Str, fieldName: 'First Expression');
      final _AlgMonomial t2 =
      _AlgMonomial.parse(term2Str, fieldName: 'Second Expression');
      final List<_AlgMonomial> initialTerms = [t1, t2];

      if (mode == 1 || term3OptionalStr.trim().isNotEmpty) {
        if (term3OptionalStr.trim().isEmpty && mode == 1) {
          throw const FormatException(
            "Please enter the 3rd algebraic expression for 3-term HCF (or switch to 2-Expression mode).",
          );
        }
        if (term3OptionalStr.trim().isNotEmpty) {
          initialTerms.add(_AlgMonomial.parse(
            term3OptionalStr,
            fieldName: 'Third Expression',
          ));
        }
      }

      // 1. Simulate the Textbook Vertical Common-Factor Division Table (Example 2a–e, Page 66!)
      List<_AlgMonomial> currRow = List.from(initialTerms);
      final List<Map<String, dynamic>> tableRows = [];
      final List<String> divisorSequenceLaTeX = [];
      final List<String> stepByStepDivLinesPlain = [];

      // Step A: Divide by common prime numbers (2, 3, 5, 7, 11, 13, ...)
      int numGcd = currRow.map((m) => m.coeff).reduce(gcd);
      int p = 2;
      while (p <= numGcd) {
        while (numGcd % p == 0) {
          final List<String> rowCells = currRow.map((m) => m.toLaTeX()).toList();
          tableRows.add({
            'divisor': '$p',
            'cells': rowCells,
          });
          divisorSequenceLaTeX.add('$p');
          currRow = currRow.map((m) => m.divideByPrime(p)).toList();
          stepByStepDivLinesPlain.add(
              "• Divide all coefficients by common prime factor $p  ➔  leaves ${currRow.map((m) => m.toPlain()).join(', ')}.");
          numGcd ~/= p;
        }
        p++;
      }

      // Step B: Divide by common algebraic variables in alphabetical order one power at a time!
      final Set<String> allVars = {};
      for (final m in currRow) {
        allVars.addAll(m.powers.keys);
      }
      final List<String> sortedVars = allVars.toList()..sort();

      final Map<String, int> hcfVarPowers = {};
      for (final String v in sortedVars) {
        int minPower = currRow.first.powers[v] ?? 0;
        for (int i = 1; i < currRow.length; i++) {
          minPower = math.min(minPower, currRow[i].powers[v] ?? 0);
        }
        if (minPower > 0) {
          hcfVarPowers[v] = minPower;
          for (int k = 0; k < minPower; k++) {
            final List<String> rowCells =
            currRow.map((m) => m.toLaTeX()).toList();
            tableRows.add({
              'divisor': v,
              'cells': rowCells,
            });
            divisorSequenceLaTeX.add(v);
            currRow = currRow.map((m) => m.divideByVariable(v)).toList();
            stepByStepDivLinesPlain.add(
                "• Divide all terms by common variable '$v'  ➔  leaves ${currRow.map((m) => m.toPlain()).join(', ')}.");
          }
        }
      }

      // Final HCF Monomial
      final int finalHcfCoeff = initialTerms.map((m) => m.coeff).reduce(gcd);
      final _AlgMonomial hcfMonomial = _AlgMonomial(
        coeff: finalHcfCoeff,
        powers: hcfVarPowers,
      );
      final String hcfLaTeX = hcfMonomial.toLaTeX();
      final String hcfPlain = hcfMonomial.toPlain();

      // Build the Textbook Vertical Division Table in LaTeX (matching Example 2a–e on Page 66!)
      final int nCols = initialTerms.length;
      final String colSpec = 'c|${List.filled(nCols, 'c').join('|')}';
      final StringBuffer tableBuf = StringBuffer();
      tableBuf.write("\\begin{array}{$colSpec} ");

      if (tableRows.isEmpty) {
        // Co-prime case (HCF = 1)
        tableBuf.write(
            "1 & ${initialTerms.map((m) => m.toLaTeX()).join(' & ')} \\\\ \\hline ");
      } else {
        for (final Map<String, dynamic> r in tableRows) {
          final String divStr = r['divisor'] as String;
          final List<String> cells = r['cells'] as List<String>;
          tableBuf.write("\\mathbf{$divStr} & ${cells.join(' & ')} \\\\ \\hline ");
        }
      }
      // Bottom remainder row (no common factors left!)
      tableBuf.write(
          " & ${currRow.map((m) => m.toLaTeX()).join(' & ')} ");
      tableBuf.write("\\end{array}");
      final String divisionTableLaTeX = tableBuf.toString();

      final String productChainLaTeX = divisorSequenceLaTeX.isEmpty
          ? "1"
          : "${divisorSequenceLaTeX.join(' \\times ')} = \\mathbf{$hcfLaTeX}";

      final List<String> step1Lines = [
        "\\text{Given algebraic expressions: } ${initialTerms.map((m) => '\\mathbf{${m.toLaTeX()}}').join(', \\; ')}",
        "\\text{Set out the expressions in a division table and divide by common prime factors and common letters (Example 2, Page 66):}",
        divisionTableLaTeX,
        "\\text{The bottom row } \\left(${currRow.map((m) => m.toLaTeX()).join(', \\; ')}\\right) \\text{ has no common factor other than } 1.",
        "\\therefore \\; \\text{HCF} = $productChainLaTeX",
      ];

      // Method 2: Expanded Prime-Factor & Index Inspection
      final List<String> step2Lines = [
        for (final _AlgMonomial m in initialTerms)
          "\\bullet \\; ${m.toLaTeX()} = ${m.toExpandedFactorsLaTeX()}",
        "\\text{Common numerical HCF} = $finalHcfCoeff, \\qquad \\text{Common letters (lowest power of each shared variable)} = ${hcfVarPowers.isEmpty ? '\\text{None}' : _AlgMonomial(coeff: 1, powers: hcfVarPowers).toLaTeX()}",
        "\\therefore \\; \\text{HCF} = \\mathbf{$hcfLaTeX}",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Method 1: Textbook Common-Factor Division Table (Example 2, Page 66)}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Method 2: Expanded Prime-Factor \\& Lowest-Power Inspection}}",
        ...step2Lines,
      ];

      final List<HcfAlgebraicStep> steps = [
        HcfAlgebraicStep(
          title:
          "Step 1: Divide by Common Prime Numbers & Common Variables (Example 2 Table)",
          description:
          "• Following Example 2 on Page 66, divide all expressions simultaneously by their common prime factors and common letters until the bottom row shares no common factor:\n\n"
              "${stepByStepDivLinesPlain.isEmpty ? '• The expressions share no common factor other than 1.' : stepByStepDivLinesPlain.join('\n')}\n\n"
              "• Multiply all the common divisors in the left column together: HCF = $hcfPlain.",
          mathLinesLaTeX: step1Lines,
        ),
        HcfAlgebraicStep(
          title:
          "Step 2: Verify by Expanded Factors & Lowest Powers",
          description:
          "• Numerical HCF of (${initialTerms.map((m) => m.coeff).join(', ')}) = $finalHcfCoeff.\n"
              "• For each letter that appears in EVERY expression, take its lowest power.\n"
              "• Remaining quotients in the bottom row: ${currRow.map((m) => m.toPlain()).join(', ')}.",
          mathLinesLaTeX: step2Lines,
        ),
      ];

      final String givenListLaTeX =
      initialTerms.map((m) => m.toLaTeX()).join(',\\; ');

      return HcfAlgebraicResult(
        mode: mode,
        finalAnswersLaTeX: {
          "Given Expressions": givenListLaTeX,
          "Numerical HCF": "$finalHcfCoeff",
          "Remaining Quotients":
          currRow.map((m) => m.toLaTeX()).join(',\\; '),
          "Highest Common Factor (HCF)": "\\mathbf{$hcfLaTeX}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: HcfAlgebraicCanvasData(
          headerLaTeX:
          "\\text{Example 2 HCF of Algebraic Expressions: HCF of } ($givenListLaTeX) = \\mathbf{$hcfLaTeX}",
          subHeaderLaTeX:
          "\\text{Multiply left-column divisors: } $productChainLaTeX",
          card1Title: "Given Expressions",
          card1LaTeX: givenListLaTeX,
          card2Title: "Bottom Quotients",
          card2LaTeX: currRow.map((m) => m.toLaTeX()).join(',\\; '),
          card3Title: "HCF",
          card3LaTeX: "\\mathbf{$hcfLaTeX}",
          divisionTableLaTeX: divisionTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{HCF of } $givenListLaTeX \\text{ is } \\mathbf{$hcfLaTeX}",
        ),
      );
    } catch (e) {
      return HcfAlgebraicResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter valid algebraic expressions (e.g. 15xy^2 and 25x^2y).",
      );
    }
  }
}