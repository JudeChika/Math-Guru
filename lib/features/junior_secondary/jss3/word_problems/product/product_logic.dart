import 'dart:math' as math;
import 'product_models.dart';

class ProductLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 22–23: Examples 4a–d, 5, 6 & Exercise 2.2 #1–15)
  // ===========================================================================
  static const List<ProductPreset> textbookPresets = [
    ProductPreset(
      chipLabel: "Ex 4a: Product of -24 and 5",
      mode: 0,
      input1: '-24',
      input2: '5',
    ),
    ProductPreset(
      chipLabel: "Ex 4b: Product of -13 and -7",
      mode: 0,
      input1: '-13',
      input2: '-7',
    ),
    ProductPreset(
      chipLabel: "Ex 4c: Product of -6 ¼ and -4/5",
      mode: 0,
      input1: '-6 1/4',
      input2: '-4/5',
    ),
    ProductPreset(
      chipLabel: "Ex 4d: Product of 3, 2 ½ and -3 ⅓",
      mode: 0,
      input1: '3',
      input2: '2 1/2',
      input3: '-3 1/3',
    ),
    ProductPreset(
      chipLabel: "Ex 2.2 #2: Product of 3/8, 1 3/5 and 5",
      mode: 0,
      input1: '3/8',
      input2: '1 3/5',
      input3: '5',
    ),
    ProductPreset(
      chipLabel: "Ex 2.2 #4: Product of 4, 67 and 25",
      mode: 0,
      input1: '4',
      input2: '67',
      input3: '25',
    ),
    ProductPreset(
      chipLabel: "Ex 2.2 #6: Product of 8.3, 4 and 2 ½",
      mode: 0,
      input1: '8.3',
      input2: '4',
      input3: '2 1/2',
    ),
    ProductPreset(
      chipLabel: "Ex 2.2 #7: Product of -4 and 2 ½",
      mode: 0,
      input1: '-4',
      input2: '2 1/2',
    ),
    ProductPreset(
      chipLabel: "Ex 2.2 #12: Product of 7.64 and 1.2",
      mode: 0,
      input1: '7.64',
      input2: '1.2',
    ),
    ProductPreset(
      chipLabel: "Example 5: Product of 2 numbers is 63; one is 7",
      mode: 1,
      input1: '7',
      input2: '63',
    ),
    ProductPreset(
      chipLabel: "Ex 2.2 #8: Product is 9 11/12; one number is -2 ⅓",
      mode: 1,
      input1: '-2 1/3',
      input2: '9 11/12',
    ),
    ProductPreset(
      chipLabel: "Ex 2.2 #11: Product is 7.92; first number is -9.9",
      mode: 1,
      input1: '-9.9',
      input2: '7.92',
    ),
    ProductPreset(
      chipLabel: "Ex 2.2 #13: Product is 1 2/5; one number is 2/5",
      mode: 1,
      input1: '2/5',
      input2: '1 2/5',
    ),
    ProductPreset(
      chipLabel: "Example 6: Product of 3 numbers is 4020; two are 15 & 4",
      mode: 2,
      input1: '15',
      input2: '4',
      input3: '4020',
    ),
    ProductPreset(
      chipLabel: "Ex 2.2 #9: Product of 3 numbers is -0.64; two are 0.4 & 8",
      mode: 2,
      input1: '0.4',
      input2: '8',
      input3: '-0.64',
    ),
    ProductPreset(
      chipLabel: "Ex 2.2 #15: Product of 3 is 134 2/5; two are -16 & 2 2/5",
      mode: 2,
      input1: '-16',
      input2: '2 2/5',
      input3: '134 2/5',
    ),
    ProductPreset(
      chipLabel: "Ex 2.2 #14: Number multiplied by itself gives 3 6/25",
      mode: 3,
      subMode: 0,
      input1: '3 6/25',
    ),
  ];

  // ===========================================================================
  // UNIVERSAL NUMBER & FRACTION PARSING / FORMATTING ENGINE
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

  static String fmt(double v, {int maxDecimals = 5}) {
    if (v.abs() < 1e-9) return '0';
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static String wrapNegLaTeX(ParsedFactor f) {
    return f.value < 0 ? "\\left(${f.displayLaTeX}\\right)" : f.displayLaTeX;
  }

  static String wrapNegPlain(ParsedFactor f) {
    return f.value < 0 ? "(${f.displayPlain})" : f.displayPlain;
  }

  /// Formats any rational fraction `num / den` into plain, mixed LaTeX, and improper LaTeX
  static Map<String, String> formatRational(int num, int den) {
    if (den == 0 || num == 0) {
      return {
        'plain': '0',
        'latex': '0',
        'improperLaTeX': '0',
        'improperPlain': '0',
      };
    }

    final bool isNeg = (num < 0) ^ (den < 0);
    int n = num.abs();
    int d = den.abs();
    final int g = gcd(n, d);
    n ~/= g;
    d ~/= g;
    final String sign = isNeg ? '-' : '';

    if (d == 1) {
      return {
        'plain': '$sign$n',
        'latex': '$sign$n',
        'improperLaTeX': '$sign\\frac{$n}{1}',
        'improperPlain': '$sign$n/1',
      };
    }

    final String impTex = '$sign\\frac{$n}{$d}';
    final String impPlain = '$sign$n/$d';
    if (n > d) {
      final int w = n ~/ d;
      final int rem = n % d;
      return {
        'plain': '$sign$w $rem/$d',
        'latex': '$sign$w\\frac{$rem}{$d}',
        'improperLaTeX': impTex,
        'improperPlain': impPlain,
      };
    } else {
      return {
        'plain': impPlain,
        'latex': impTex,
        'improperLaTeX': impTex,
        'improperPlain': impPlain,
      };
    }
  }

  /// Parses integers ("-24"), decimals ("8.24", "-0.64"), proper/improper fractions ("-4/5"),
  /// or mixed numbers ("-6 1/4", "9 11/12", "134 2/5", "3 6/25").
  static ParsedFactor parseFlexibleFactor(
      String raw, {
        String fieldName = 'number',
      }) {
    String s = raw
        .trim()
        .replaceAll('−', '-')
        .replaceAll('½', ' 1/2')
        .replaceAll('¼', ' 1/4')
        .replaceAll('¾', ' 3/4')
        .replaceAll('⅓', ' 1/3')
        .replaceAll('⅔', ' 2/3')
        .replaceAll('⅕', ' 1/5')
        .replaceAll('⅖', ' 2/5')
        .replaceAll('⅗', ' 3/5')
        .replaceAll('⅘', ' 4/5')
        .replaceAll(',', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (s.isEmpty) {
      throw FormatException(
        "Please enter a valid $fieldName (e.g. -24, 8.24, -4/5, or -6 1/4).",
      );
    }

    if (s.contains('/')) {
      final List<String> parts = s.split(' ');
      if (parts.length == 2) {
        final bool isNeg = parts[0].startsWith('-');
        final int wholeAbs =
        int.parse(parts[0].replaceAll('-', '').replaceAll('+', ''));
        final List<String> fParts = parts[1].split('/');
        final int fNum = int.parse(fParts[0]);
        final int fDen = int.parse(fParts[1]);
        if (fDen <= 0) {
          throw const FormatException(
              "Fraction denominator must be greater than zero.");
        }
        final int impAbs = wholeAbs * fDen + fNum;
        final int signedNum = isNeg ? -impAbs : impAbs;
        final String signStr = isNeg ? '-' : '';

        return ParsedFactor(
          rawInput: raw.trim(),
          value: signedNum / fDen,
          num: signedNum,
          den: fDen,
          wholeAbs: wholeAbs,
          remAbs: fNum,
          isFractionOrMixed: true,
          isMixedInput: true,
          displayPlain: '$signStr$wholeAbs $fNum/$fDen',
          displayLaTeX: '$signStr$wholeAbs\\frac{$fNum}{$fDen}',
          improperLaTeX: '$signStr\\frac{$impAbs}{$fDen}',
        );
      } else if (parts.length == 1) {
        final List<String> fParts = parts[0].split('/');
        final int fNum = int.parse(fParts[0]);
        final int fDen = int.parse(fParts[1]);
        if (fDen == 0) {
          throw const FormatException("Fraction denominator cannot be zero.");
        }
        final int signedN = fDen < 0 ? -fNum : fNum;
        final int posD = fDen.abs();
        final String signStr = signedN < 0 ? '-' : '';
        final int absN = signedN.abs();

        return ParsedFactor(
          rawInput: raw.trim(),
          value: signedN / posD,
          num: signedN,
          den: posD,
          isFractionOrMixed: true,
          isMixedInput: false,
          displayPlain: '$signStr$absN/$posD',
          displayLaTeX: '$signStr\\frac{$absN}{$posD}',
          improperLaTeX: '$signStr\\frac{$absN}{$posD}',
        );
      } else {
        throw FormatException(
            "Invalid fraction format '$raw'. Try '-6 1/4' or '-4/5'.");
      }
    }

    final String noSpace = s.replaceAll(' ', '');
    final double? val = double.tryParse(noSpace);
    if (val == null) {
      throw FormatException("Could not read '$raw' as a valid number.");
    }

    int decPlaces = 0;
    if (noSpace.contains('.')) {
      decPlaces = noSpace.split('.')[1].length.clamp(0, 6);
    }
    final int scaleDen = math.pow(10, decPlaces).round();
    final int scaledNum = (val * scaleDen).round();
    final int g = gcd(scaledNum, scaleDen);
    final int redNum = scaledNum ~/ g;
    final int redDen = scaleDen ~/ g;

    final String cleanStr = fmt(val);
    final String signStr = redNum < 0 ? '-' : '';
    return ParsedFactor(
      rawInput: raw.trim(),
      value: val,
      num: redNum,
      den: redDen,
      isFractionOrMixed: false,
      isMixedInput: false,
      displayPlain: cleanStr,
      displayLaTeX: cleanStr,
      improperLaTeX: redDen == 1
          ? '$signStr\\frac{${redNum.abs()}}{1}'
          : '$signStr\\frac{${redNum.abs()}}{$redDen}',
    );
  }

  /// Helper that builds the explicit line-by-line conversion of a mixed number to an improper fraction
  static String buildMixedConversionLineLaTeX(ParsedFactor f) {
    final String sign = f.num < 0 ? '-' : '';
    final int impAbs = f.num.abs();
    return "${f.displayLaTeX} = $sign\\frac{(${f.wholeAbs} \\times ${f.den}) + ${f.remAbs}}{${f.den}} = $sign\\frac{${f.wholeAbs * f.den} + ${f.remAbs}}{${f.den}} = $sign\\frac{$impAbs}{${f.den}}";
  }

  // ===========================================================================
  // MODE 0: DIRECT PRODUCT OF TWO OR THREE NUMBERS
  // Covers Example 4(a–d) and Exercise 2.2 #1, #2, #3, #4, #5, #6, #7, #10, #12
  // ===========================================================================
  static ProductResult solveDirectProduct({
    required String factor1Str,
    required String factor2Str,
    required String factor3Str,
  }) {
    try {
      final ParsedFactor f1 =
      parseFlexibleFactor(factor1Str, fieldName: 'First Number');
      final ParsedFactor f2 =
      parseFlexibleFactor(factor2Str, fieldName: 'Second Number');
      final bool hasThird = factor3Str.trim().isNotEmpty;
      final ParsedFactor? f3 = hasThird
          ? parseFlexibleFactor(factor3Str, fieldName: 'Third Number')
          : null;

      final List<ParsedFactor> factors = [f1, f2, if (f3 != null) f3];
      final bool anyFraction = factors.any((f) => f.isFractionOrMixed);
      final bool anyMixed = factors.any((f) => f.isMixedInput);

      // Count negative signs for the Directed-Number Sign Rule
      final int negCount = factors.where((f) => f.value < 0).length;
      final bool anyZero = factors.any((f) => f.value.abs() < 1e-12);
      final bool isPositiveProduct = anyZero || (negCount % 2 == 0);
      final String resSignLaTeX =
      anyZero ? '' : (isPositiveProduct ? '+' : '-');
      final String signWord =
      anyZero ? 'ZERO (0)' : (isPositiveProduct ? 'POSITIVE (+)' : 'NEGATIVE (−)');

      final String signsChainLaTeX =
      factors.map((f) => f.value < 0 ? '(-)' : '(+)').join(' \\times ');
      final String signsChainPlain =
      factors.map((f) => f.value < 0 ? '(−)' : '(+)').join(' × ');

      final List<String> workings = [];
      final List<ProductStep> steps = [];
      final Map<String, String> answers = {};

      // STEP 1: Definition of a Product & Directed-Number Sign Rule
      final String exprChainLaTeX =
      factors.map((f) => wrapNegLaTeX(f)).join(' \\times ');
      final String exprChainPlain =
      factors.map((f) => wrapNegPlain(f)).join(' × ');

      final List<String> step1Lines = [
        "\\text{Definition (Page 22): A quantity obtained when two or more numbers are multiplied is called a \\textbf{product}.}",
        "\\text{Product} = $exprChainLaTeX",
        "\\text{Directed-Number Sign Rule: } $signsChainLaTeX = (${isPositiveProduct ? '+' : '-'})",
        if (negCount == 0)
          "\\text{All factors are positive, so the product is \\textbf{positive} } (+)."
        else if (negCount == 1)
          "\\text{There is } 1 \\text{ negative factor (an odd number of negative signs), so the product is \\textbf{negative} } (-)."
        else if (negCount == 2)
            "\\text{There are } 2 \\text{ negative factors (like signs: } (-) \\times (-) = (+)\\text{), so the product is \\textbf{positive} } (+)."
          else
            "\\text{There are } 3 \\text{ negative factors (an odd number of negative signs), so the product is \\textbf{negative} } (-).",
      ];

      workings.add(
          "\\text{\\textbf{Step 1: Set Up the Multiplication and Determine the Sign of the Product}}");
      workings.addAll(step1Lines);
      workings.add("");

      steps.add(ProductStep(
        title: "Step 1: Write the Multiplication Expression & Apply the Sign Rule",
        description:
        "• Definition (Page 22): Multiplication (×) is the operation, while the 'product' is the result obtained after multiplying the numbers together.\n"
            "• Sign Rule: $signsChainPlain = $signWord (Number of negative factors = $negCount).",
        mathLinesLaTeX: step1Lines,
      ));

      String finalAnswerPlain = "";
      String finalAnswerLaTeX = "";

      if (anyFraction) {
        // STEP 2 (Fractions / Mixed Numbers Mode — Matches Ex 4c, 4d & Ex 2.2 #2, #6, #7)
        final List<String> step2Lines = [];
        if (anyMixed) {
          step2Lines.add(
              "\\text{Convert each mixed number into an improper fraction } \\left(W\\frac{N}{D} = \\frac{(W \\times D) + N}{D}\\right):");
          for (final ParsedFactor f in factors) {
            if (f.isMixedInput) {
              step2Lines.add(buildMixedConversionLineLaTeX(f));
            } else if (!f.isFractionOrMixed && f.den == 1) {
              step2Lines.add(
                  "\\text{Write whole number } ${f.displayLaTeX} \\text{ as a fraction over } 1: \\quad ${f.displayLaTeX} = ${f.improperLaTeX}");
            }
          }
        } else {
          for (final ParsedFactor f in factors) {
            if (!f.isFractionOrMixed && f.den == 1) {
              step2Lines.add(
                  "\\text{Write whole number } ${f.displayLaTeX} \\text{ over } 1: \\quad ${f.displayLaTeX} = ${f.improperLaTeX}");
            }
          }
        }

        final String improperChainLaTeX =
        factors.map((f) => f.improperLaTeX).join(' \\times ');
        step2Lines.add("\\text{Product} = $improperChainLaTeX");

        final String numFactorsLaTeX =
        factors.map((f) => '${f.num.abs()}').join(' \\times ');
        final String denFactorsLaTeX =
        factors.map((f) => '${f.den}').join(' \\times ');

        final int rawNumProd =
        factors.fold(1, (acc, f) => acc * f.num.abs());
        final int rawDenProd = factors.fold(1, (acc, f) => acc * f.den);
        final int signedNumProd =
        anyZero ? 0 : (isPositiveProduct ? rawNumProd : -rawNumProd);
        final int hcf = gcd(rawNumProd, rawDenProd);
        final Map<String, String> resMap =
        formatRational(signedNumProd, rawDenProd);
        final double exactDec = signedNumProd / rawDenProd;

        step2Lines.add(
            "\\text{Multiply the numerators together and the denominators together:}");
        step2Lines.add(
            "= $resSignLaTeX\\frac{$numFactorsLaTeX}{$denFactorsLaTeX}");
        step2Lines.add("= $resSignLaTeX\\frac{$rawNumProd}{$rawDenProd}");

        if (hcf > 1) {
          step2Lines.add(
              "\\text{Divide numerator and denominator by their HCF } ($hcf):");
          step2Lines.add(
              "= $resSignLaTeX\\frac{$rawNumProd \\div $hcf}{$rawDenProd \\div $hcf} = ${resMap['improperLaTeX']}");
        }

        if (resMap['latex'] != resMap['improperLaTeX']) {
          step2Lines.add(
              "\\text{Convert improper fraction to a mixed number:}");
        }
        step2Lines.add(
            "\\therefore \\; \\text{Product} = \\mathbf{${resMap['latex']}} \\quad \\left(\\text{or } \\mathbf{${fmt(exactDec)}}\\right)");

        workings.add(
            "\\text{\\textbf{Step 2: Convert to Improper Fractions and Multiply (Example 4c \\& 4d Method)}}");
        workings.addAll(step2Lines);

        steps.add(ProductStep(
          title:
          "Step 2: Convert Mixed Numbers to Improper Fractions & Multiply",
          description:
          "1. Convert any mixed fractions into improper fractions and write any whole numbers over 1 (just like Example 4c and 4d on Page 22).\n"
              "2. Multiply the numerators ($numFactorsLaTeX = $rawNumProd) and multiply the denominators ($denFactorsLaTeX = $rawDenProd).\n"
              "3. Simplify by dividing top and bottom by their Highest Common Factor (HCF = $hcf) to get ${resMap['plain']} (or ${fmt(exactDec)}).",
          mathLinesLaTeX: step2Lines,
        ));

        finalAnswerPlain = resMap['plain']!;
        finalAnswerLaTeX = resMap['latex']!;
        answers["Expression"] = exprChainPlain;
        answers["Product"] = finalAnswerPlain;
        if (finalAnswerPlain != fmt(exactDec)) {
          answers["Decimal Form"] = fmt(exactDec);
        }
      } else {
        // STEP 2 (Whole Numbers & Decimals Mode — Matches Ex 4a, 4b & Ex 2.2 #1, #3, #4, #5, #10, #12)
        final double prodVal =
        factors.fold(1.0, (acc, f) => acc * f.value);
        final double absProd = prodVal.abs();
        final List<String> step2Lines = [
          "\\text{Product} = $exprChainLaTeX",
        ];

        if (factors.length == 3) {
          // Show pairwise multiplication (and associative grouping tip if 4 * 67 * 25!)
          final double p12 = f1.value * f2.value;
          final double p13 = f1.value * f3!.value;
          if ((p13 - 100.0).abs() < 1e-9 || (p13 - 10.0).abs() < 1e-9) {
            step2Lines.add(
                "\\text{Group convenient factors first (Associative Property):}");
            step2Lines.add(
                "= \\left(${wrapNegLaTeX(f1)} \\times ${wrapNegLaTeX(f3)}\\right) \\times ${wrapNegLaTeX(f2)}");
            step2Lines.add(
                "= ${fmt(p13)} \\times ${wrapNegLaTeX(f2)}");
          } else {
            step2Lines.add(
                "\\text{Multiply the first two numbers } \\left(${wrapNegLaTeX(f1)} \\times ${wrapNegLaTeX(f2)} = ${fmt(p12)}\\right):");
            step2Lines.add(
                "= ${fmt(p12)} \\times ${wrapNegLaTeX(f3)}");
          }
        } else {
          step2Lines.add(
              "= $resSignLaTeX\\left(${fmt(f1.value.abs())} \\times ${fmt(f2.value.abs())}\\right)");
        }

        // If decimals are involved, also show the exact decimal-place counting rule!
        final bool hasDecimals =
        factors.any((f) => f.rawInput.contains('.'));
        if (hasDecimals) {
          final int totalDecPlaces = factors.fold(0, (sum, f) {
            final String s = f.rawInput.trim();
            return sum + (s.contains('.') ? s.split('.')[1].length : 0);
          });
          step2Lines.add(
              "\\text{Decimal multiplication check: Total decimal places in factors} = $totalDecPlaces");
        }

        step2Lines.add(
            "\\therefore \\; \\text{Product} = \\mathbf{${fmt(prodVal)}}");

        workings.add(
            "\\text{\\textbf{Step 2: Multiply the Magnitudes and Attach the Sign}}");
        workings.addAll(step2Lines);

        steps.add(ProductStep(
          title: "Step 2: Multiply the Numbers Step-by-Step",
          description:
          "1. Multiply the absolute values of the factors together: ${factors.map((f) => fmt(f.value.abs())).join(' × ')} = ${fmt(absProd)}.\n"
              "2. Apply the sign from Step 1 ($signWord) to get the final product: ${fmt(prodVal)}.",
          mathLinesLaTeX: step2Lines,
        ));

        finalAnswerPlain = fmt(prodVal);
        finalAnswerLaTeX = fmt(prodVal);
        answers["Expression"] = exprChainPlain;
        answers["Product"] = finalAnswerPlain;
      }

      return ProductResult(
        mode: 0,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: ProductCanvasData(
          visualType: 0,
          factorNodes: [
            for (int i = 0; i < factors.length; i++)
              FactorNodeVisual(
                titleLabel: "Factor ${i + 1}",
                mainValueText: factors[i].displayPlain,
                subImproperText: factors[i].isMixedInput
                    ? "(${factors[i].num}/${factors[i].den})"
                    : (factors[i].value < 0 ? "Negative (−)" : "Positive (+)"),
                isNegative: factors[i].value < 0,
              ),
          ],
          signRuleBadge:
          "Sign Rule:  $signsChainPlain = (${isPositiveProduct ? '+' : '−'})",
          productNodeTitle: "Final Product",
          productNodeValue: finalAnswerPlain,
          inverseFormulaBanner: "$exprChainPlain = $finalAnswerPlain",
          headerBadge:
          "Direct Product:  $exprChainPlain = $finalAnswerPlain",
          subBadge:
          "Sign Rule: $signsChainPlain = $signWord   |   Result = $finalAnswerLaTeX",
          bottomSummaryBanner: "Product = $finalAnswerPlain",
        ),
      );
    } catch (e) {
      return ProductResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter valid numbers, decimals, or fractions.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: FIND THE SECOND NUMBER GIVEN THE PRODUCT OF TWO NUMBERS (a * m = P)
  // Covers Example 5 (63 and 7) and Exercise 2.2 #8 (9 11/12 and -2 1/3),
  // #11 (7.92 and -9.9), and #13 (1 2/5 and 2/5)
  // ===========================================================================
  static ProductResult solveUnknownOfTwoNumbers({
    required String knownFactorStr,
    required String givenProductStr,
  }) {
    try {
      final ParsedFactor a =
      parseFlexibleFactor(knownFactorStr, fieldName: 'Known Number');
      final ParsedFactor p =
      parseFlexibleFactor(givenProductStr, fieldName: 'Given Product');

      if (a.value.abs() < 1e-12) {
        throw const FormatException(
            "The known factor cannot be 0 when dividing to find the second number.");
      }

      final bool useFractions = a.isFractionOrMixed || p.isFractionOrMixed;
      final List<String> workings = [];
      final List<ProductStep> steps = [];
      final Map<String, String> answers = {};

      // STEP 1: Choose Variable m and Form the Algebraic Product Equation (Example 5 Style)
      final List<String> step1Lines = [
        "\\text{Let } m \\text{ be the second (unknown) number.}",
        "\\text{Given that the product of } m \\text{ and } ${a.displayLaTeX} \\text{ is } ${p.displayLaTeX}:",
        "m \\times ${wrapNegLaTeX(a)} = ${p.displayLaTeX}",
        "${a.displayLaTeX}m = ${p.displayLaTeX}",
      ];

      workings.add(
          "\\text{\\textbf{Step 1: Form the Algebraic Equation (Example 5 Method)}}");
      workings.addAll(step1Lines);
      workings.add("");

      steps.add(ProductStep(
        title: "Step 1: Let m Be the Second Number and Form the Equation",
        description:
        "• Following Example 5 on Page 23, let m represent the unknown second number.\n"
            "• Since the product of the two numbers is ${p.displayPlain} and one of the numbers is ${a.displayPlain}, multiplying m by ${a.displayPlain} gives ${p.displayPlain}.",
        mathLinesLaTeX: step1Lines,
      ));

      // STEP 2: Isolate m by Dividing Both Sides by the Known Number
      final List<String> step2Lines = [];
      String finalAnsPlain = "";
      String finalAnsLaTeX = "";

      final int resNumRaw = p.num * a.den;
      final int resDenRaw = p.den * a.num;
      final Map<String, String> resFmt = formatRational(resNumRaw, resDenRaw);
      final double exactM = p.value / a.value;

      if (useFractions) {
        // Unabridged Fraction & Mixed-Number Division (Matches Ex 2.2 #8 & #13!)
        if (a.isMixedInput || p.isMixedInput) {
          step2Lines.add(
              "\\text{Convert mixed numbers into improper fractions:}");
          if (a.isMixedInput) {
            step2Lines.add(buildMixedConversionLineLaTeX(a));
          }
          if (p.isMixedInput) {
            step2Lines.add(buildMixedConversionLineLaTeX(p));
          }
          step2Lines.add("${a.improperLaTeX}m = ${p.improperLaTeX}");
        }

        step2Lines.add(
            "\\text{Divide both sides of the equation by } ${a.improperLaTeX}:");
        step2Lines.add(
            "m = ${p.improperLaTeX} \\div \\left(${a.improperLaTeX}\\right)");

        final String recipSign = a.num < 0 ? '-' : '';
        final String recipLaTeX = "$recipSign\\frac{${a.den}}{${a.num.abs()}}";
        step2Lines.add(
            "\\text{Multiply by the reciprocal (invert the divisor fraction):}");
        step2Lines.add(
            "m = ${p.improperLaTeX} \\times \\left($recipLaTeX\\right)");

        final bool isResPos = (resNumRaw >= 0 && resDenRaw > 0) ||
            (resNumRaw <= 0 && resDenRaw < 0);
        final String signSym = isResPos ? '+' : '-';
        final int absProdN = (p.num * a.den).abs();
        final int absProdD = (p.den * a.num).abs();
        final int hcf = gcd(absProdN, absProdD);

        step2Lines.add(
            "m = $signSym\\frac{${p.num.abs()} \\times ${a.den}}{${p.den} \\times ${a.num.abs()}}");
        step2Lines.add("m = $signSym\\frac{$absProdN}{$absProdD}");

        if (hcf > 1) {
          step2Lines.add(
              "\\text{Divide numerator and denominator by their HCF } ($hcf):");
          step2Lines.add(
              "m = $signSym\\frac{$absProdN \\div $hcf}{$absProdD \\div $hcf} = ${resFmt['improperLaTeX']}");
        }
        step2Lines.add(
            "\\therefore \\; \\mathbf{m = ${resFmt['latex']}} \\quad \\left(\\text{or } \\mathbf{${fmt(exactM)}}\\right)");

        finalAnsPlain = resFmt['plain']!;
        finalAnsLaTeX = resFmt['latex']!;
      } else {
        // Whole Numbers or Decimals (Matches Example 5 & Exercise 2.2 #11!)
        step2Lines.add(
            "\\text{Divide both sides by } ${a.displayLaTeX}:");
        step2Lines.add(
            "\\frac{${a.displayLaTeX}m}{${a.displayLaTeX}} = \\frac{${p.displayLaTeX}}{${a.displayLaTeX}}");

        // If decimals are present (like Ex 2.2 #11: 7.92 / -9.9), show clearing decimal places!
        if (a.rawInput.contains('.') || p.rawInput.contains('.')) {
          final int decA = a.rawInput.contains('.')
              ? a.rawInput.trim().split('.')[1].length
              : 0;
          final int decP = p.rawInput.contains('.')
              ? p.rawInput.trim().split('.')[1].length
              : 0;
          final int mult10 = math.pow(10, math.max(decA, decP)).round();
          step2Lines.add(
              "\\text{Multiply numerator and denominator by } $mult10 \\text{ to clear decimals:}");
          step2Lines.add(
              "m = \\frac{${p.displayLaTeX} \\times $mult10}{${a.displayLaTeX} \\times $mult10} = \\frac{${fmt(p.value * mult10)}}{${fmt(a.value * mult10)}}");
        }

        if ((exactM - exactM.roundToDouble()).abs() < 1e-9) {
          finalAnsPlain = fmt(exactM);
          finalAnsLaTeX = fmt(exactM);
          step2Lines.add("\\therefore \\; \\mathbf{m = $finalAnsLaTeX}");
        } else {
          finalAnsPlain = "${fmt(exactM)} (or ${resFmt['plain']})";
          finalAnsLaTeX = fmt(exactM);
          step2Lines.add(
              "\\therefore \\; \\mathbf{m = ${fmt(exactM)}} \\quad \\left(\\text{or } \\mathbf{${resFmt['latex']}}\\right)");
        }
      }

      workings.add(
          "\\text{\\textbf{Step 2: Divide Both Sides by the Known Number}}");
      workings.addAll(step2Lines);
      workings.add("");

      steps.add(ProductStep(
        title: "Step 2: Divide Both Sides by ${a.displayPlain} to Isolate m",
        description: useFractions
            ? "1. Convert mixed numbers to improper fractions.\n"
            "2. Divide both sides by ${a.displayPlain}, which is equivalent to multiplying by its reciprocal.\n"
            "3. Simplify common factors and convert back to a mixed/proper fraction: m = $finalAnsPlain."
            : "1. Divide both sides of ${a.displayPlain}m = ${p.displayPlain} by ${a.displayPlain}.\n"
            "2. Apply the directed-number sign rule for division: m = $finalAnsPlain.",
        mathLinesLaTeX: step2Lines,
      ));

      // STEP 3: Verification Check
      final List<String> step3Lines = [
        "\\text{Check: } m \\times ${wrapNegLaTeX(a)} = \\left($finalAnsLaTeX\\right) \\times ${wrapNegLaTeX(a)} = \\mathbf{${p.displayLaTeX}} \\quad (\\text{Verified!})",
      ];
      workings.add("\\text{\\textbf{Step 3: Verification Check}}");
      workings.addAll(step3Lines);

      steps.add(ProductStep(
        title: "Step 3: Check Your Answer by Multiplying",
        description:
        "Multiply the found number ($finalAnsPlain) by the known number (${a.displayPlain}) to confirm that their product equals ${p.displayPlain}.",
        mathLinesLaTeX: step3Lines,
      ));

      answers["Equation"] = "${a.displayPlain}m = ${p.displayPlain}";
      answers["Second Number (m)"] = finalAnsPlain;

      return ProductResult(
        mode: 1,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: ProductCanvasData(
          visualType: 0,
          factorNodes: [
            FactorNodeVisual(
              titleLabel: "Known Number",
              mainValueText: a.displayPlain,
              subImproperText:
              a.isMixedInput ? "(${a.num}/${a.den})" : "Given Factor",
              isNegative: a.value < 0,
            ),
            FactorNodeVisual(
              titleLabel: "2nd Number (m)",
              mainValueText: "m = $finalAnsPlain",
              subImproperText: "Found by P ÷ a",
              isNegative: exactM < 0,
              isHighlightedUnknown: true,
            ),
          ],
          signRuleBadge:
          "Inverse Operation:  m = Product (${p.displayPlain}) ÷ Known (${a.displayPlain})",
          productNodeTitle: "Given Product",
          productNodeValue: p.displayPlain,
          inverseFormulaBanner: "m = $finalAnsPlain",
          headerBadge:
          "Find 2nd Number:  ${a.displayPlain} × m = ${p.displayPlain}   ➔   m = $finalAnsPlain",
          subBadge:
          "Divide both sides by ${a.displayPlain}:   m = ${p.displayPlain} ÷ ${wrapNegPlain(a)} = $finalAnsPlain",
          bottomSummaryBanner: "The Second Number is m = $finalAnsPlain",
        ),
      );
    } catch (e) {
      return ProductResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid numbers or fractions.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: FIND THE THIRD NUMBER GIVEN THE PRODUCT OF THREE NUMBERS (a * b * c = P)
  // Covers Example 6 (4020; 15 and 4), Exercise 2.2 #9 (-0.64; 0.4 and 8),
  // and Exercise 2.2 #15 (134 2/5; -16 and 2 2/5)
  // ===========================================================================
  static ProductResult solveUnknownOfThreeNumbers({
    required String known1Str,
    required String known2Str,
    required String givenProductStr,
  }) {
    try {
      final ParsedFactor f1 =
      parseFlexibleFactor(known1Str, fieldName: 'First Known Number');
      final ParsedFactor f2 =
      parseFlexibleFactor(known2Str, fieldName: 'Second Known Number');
      final ParsedFactor p = parseFlexibleFactor(
        givenProductStr,
        fieldName: 'Given Product of 3 Numbers',
      );

      if (f1.value.abs() < 1e-12 || f2.value.abs() < 1e-12) {
        throw const FormatException(
            "The known numbers cannot be zero when solving for the third number.");
      }

      final bool useFractions =
          f1.isFractionOrMixed || f2.isFractionOrMixed || p.isFractionOrMixed;
      final List<String> workings = [];
      final List<ProductStep> steps = [];
      final Map<String, String> answers = {};

      // STEP 1: Set Up the Three-Number Product Equation (Example 6 Style)
      final List<String> step1Lines = [
        "\\text{Let } a \\text{ be the third (unknown) number.}",
        "\\text{Given that the product of } a, \\; ${f1.displayLaTeX}, \\text{ and } ${f2.displayLaTeX} \\text{ is } ${p.displayLaTeX}:",
        "a \\times ${wrapNegLaTeX(f1)} \\times ${wrapNegLaTeX(f2)} = ${p.displayLaTeX}",
      ];

      workings.add(
          "\\text{\\textbf{Step 1: Let }} a \\text{\\textbf{ Be the Third Number and Form the Equation (Example 6)}}");
      workings.addAll(step1Lines);
      workings.add("");

      steps.add(ProductStep(
        title: "Step 1: Let 'a' Be the Third Number and Form the Equation",
        description:
        "• Following Example 6 on Page 23, let a represent the third number.\n"
            "• Write the product of the three numbers equal to ${p.displayPlain}: a × ${wrapNegPlain(f1)} × ${wrapNegPlain(f2)} = ${p.displayPlain}.",
        mathLinesLaTeX: step1Lines,
      ));

      // STEP 2: Multiply the Two Known Numbers Together First
      final int knownNumProd = f1.num * f2.num;
      final int knownDenProd = f1.den * f2.den;
      final Map<String, String> knownProdFmt =
      formatRational(knownNumProd, knownDenProd);
      final double knownProdVal = f1.value * f2.value;

      final List<String> step2Lines = [];
      if (useFractions) {
        if (f1.isMixedInput || f2.isMixedInput || p.isMixedInput) {
          step2Lines.add(
              "\\text{Convert mixed numbers into improper fractions:}");
          if (f1.isMixedInput) {
            step2Lines.add(buildMixedConversionLineLaTeX(f1));
          }
          if (f2.isMixedInput) {
            step2Lines.add(buildMixedConversionLineLaTeX(f2));
          }
          if (p.isMixedInput) {
            step2Lines.add(buildMixedConversionLineLaTeX(p));
          }
        }
        step2Lines.add(
            "\\text{Multiply the two known numbers together first:}");
        step2Lines.add(
            "${f1.improperLaTeX} \\times ${f2.improperLaTeX} = ${knownProdFmt['improperLaTeX']}");
        step2Lines.add(
            "\\text{Substitute back into the equation:}");
        step2Lines.add(
            "${knownProdFmt['improperLaTeX']}a = ${p.improperLaTeX}");
      } else {
        step2Lines.add(
            "\\text{Multiply the two known numbers } \\left(${wrapNegLaTeX(f1)} \\times ${wrapNegLaTeX(f2)} = ${fmt(knownProdVal)}\\right):");
        step2Lines.add("${fmt(knownProdVal)}a = ${p.displayLaTeX}");
      }

      workings.add(
          "\\text{\\textbf{Step 2: Multiply the Two Known Numbers Together}}");
      workings.addAll(step2Lines);
      workings.add("");

      steps.add(ProductStep(
        title: "Step 2: Multiply the Two Known Numbers First",
        description:
        "Multiply ${f1.displayPlain} and ${f2.displayPlain} together so the left-hand side simplifies to a single coefficient multiplying a:\n"
            "• ${wrapNegPlain(f1)} × ${wrapNegPlain(f2)} = ${useFractions ? knownProdFmt['plain'] : fmt(knownProdVal)}.",
        mathLinesLaTeX: step2Lines,
      ));

      // STEP 3: Divide Both Sides by the Product of the Two Known Numbers
      final int finalNumRaw = p.num * knownDenProd;
      final int finalDenRaw = p.den * knownNumProd;
      final Map<String, String> finalFmt =
      formatRational(finalNumRaw, finalDenRaw);
      final double exactA = p.value / knownProdVal;

      final List<String> step3Lines = [];
      String finalAnsPlain = "";
      String finalAnsLaTeX = "";

      if (useFractions) {
        final int kRedNum = knownNumProd ~/ gcd(knownNumProd, knownDenProd);
        final int kRedDen = knownDenProd ~/ gcd(knownNumProd, knownDenProd);
        final String recipSign = kRedNum < 0 ? '-' : '';
        final String recipLaTeX = "$recipSign\\frac{$kRedDen}{${kRedNum.abs()}}";

        step3Lines.add(
            "\\text{Divide both sides by } ${knownProdFmt['improperLaTeX']}:");
        step3Lines.add(
            "a = ${p.improperLaTeX} \\div \\left(${knownProdFmt['improperLaTeX']}\\right)");
        step3Lines.add(
            "\\text{Multiply by the reciprocal } \\left($recipLaTeX\\right):");
        step3Lines.add(
            "a = ${p.improperLaTeX} \\times \\left($recipLaTeX\\right)");

        final bool isPos = (finalNumRaw >= 0 && finalDenRaw > 0) ||
            (finalNumRaw <= 0 && finalDenRaw < 0);
        final String signSym = isPos ? '+' : '-';
        final int absN = (p.num * kRedDen).abs();
        final int absD = (p.den * kRedNum.abs()).abs();
        final int hcf = gcd(absN, absD);

        step3Lines.add("a = $signSym\\frac{$absN}{$absD}");
        if (hcf > 1) {
          step3Lines.add(
              "\\text{Simplify by dividing numerator and denominator by HCF } ($hcf):");
          step3Lines.add(
              "a = $signSym\\frac{$absN \\div $hcf}{$absD \\div $hcf} = ${finalFmt['improperLaTeX']}");
        }
        step3Lines.add(
            "\\therefore \\; \\mathbf{a = ${finalFmt['latex']}} \\quad \\left(\\text{or } \\mathbf{${fmt(exactA)}}\\right)");

        finalAnsPlain = "${finalFmt['plain']} (or ${fmt(exactA)})";
        finalAnsLaTeX = finalFmt['latex']!;
      } else {
        step3Lines.add(
            "\\text{Divide both sides by } ${fmt(knownProdVal)}:");
        step3Lines.add(
            "\\frac{${fmt(knownProdVal)}a}{${fmt(knownProdVal)}} = \\frac{${p.displayLaTeX}}{${fmt(knownProdVal)}}");

        if (p.rawInput.contains('.') ||
            known1Str.contains('.') ||
            known2Str.contains('.')) {
          step3Lines.add(
              "a = \\frac{${p.displayLaTeX}}{${fmt(knownProdVal)}} = \\mathbf{${fmt(exactA)}}");
        } else {
          step3Lines.add("\\therefore \\; \\mathbf{a = ${fmt(exactA)}}");
        }

        finalAnsPlain = fmt(exactA);
        finalAnsLaTeX = fmt(exactA);
      }

      workings.add(
          "\\text{\\textbf{Step 3: Divide Both Sides to Find the Third Number (}}a\\text{\\textbf{)}}");
      workings.addAll(step3Lines);
      workings.add("");

      // STEP 4: Verification Check
      final List<String> step4Lines = [
        "\\text{Check: } \\left($finalAnsLaTeX\\right) \\times ${wrapNegLaTeX(f1)} \\times ${wrapNegLaTeX(f2)} = \\mathbf{${p.displayLaTeX}} \\quad (\\text{Verified!})",
      ];
      workings.add("\\text{\\textbf{Step 4: Verification Check}}");
      workings.addAll(step4Lines);

      steps.add(ProductStep(
        title: "Step 3: Divide Both Sides & Verify the Third Number",
        description:
        "• Divide ${p.displayPlain} by ${useFractions ? knownProdFmt['plain'] : fmt(knownProdVal)} to isolate a: a = $finalAnsPlain.\n"
            "• Check: Multiplying $finalAnsPlain × ${f1.displayPlain} × ${f2.displayPlain} gives ${p.displayPlain}!",
        mathLinesLaTeX: [...step3Lines, ...step4Lines],
      ));

      answers["Product of Known Two"] =
      useFractions ? knownProdFmt['plain']! : fmt(knownProdVal);
      answers["Third Number (a)"] = finalAnsPlain;

      return ProductResult(
        mode: 2,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: ProductCanvasData(
          visualType: 0,
          factorNodes: [
            FactorNodeVisual(
              titleLabel: "Known #1",
              mainValueText: f1.displayPlain,
              isNegative: f1.value < 0,
            ),
            FactorNodeVisual(
              titleLabel: "Known #2",
              mainValueText: f2.displayPlain,
              isNegative: f2.value < 0,
            ),
            FactorNodeVisual(
              titleLabel: "3rd Number (a)",
              mainValueText: "a = ${useFractions ? finalFmt['plain'] : fmt(exactA)}",
              isNegative: exactA < 0,
              isHighlightedUnknown: true,
            ),
          ],
          signRuleBadge:
          "Known Product = ${f1.displayPlain} × ${f2.displayPlain} = ${useFractions ? knownProdFmt['plain'] : fmt(knownProdVal)}",
          productNodeTitle: "Given Product",
          productNodeValue: p.displayPlain,
          inverseFormulaBanner: "Third Number a = $finalAnsPlain",
          headerBadge:
          "3-Factor Product:  a × ${f1.displayPlain} × ${f2.displayPlain} = ${p.displayPlain}",
          subBadge:
          "Step 1: ${f1.displayPlain} × ${f2.displayPlain} = ${useFractions ? knownProdFmt['plain'] : fmt(knownProdVal)}   |   Step 2: a = ${p.displayPlain} ÷ ${useFractions ? knownProdFmt['plain'] : fmt(knownProdVal)}",
          bottomSummaryBanner: "The Third Number is a = $finalAnsPlain",
        ),
      );
    } catch (e) {
      return ProductResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter valid numbers or mixed fractions.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: A NUMBER MULTIPLIED BY ITSELF (x * x = x² = P) & MULTIPLE (k*x * x = P)
  // Covers Exercise 2.2 #14 ("When a number is multiplied by itself, the result is 3 6/25")
  // ===========================================================================
  static ProductResult solveSelfProductOrMultiple({
    required int subMode, // 0: Number Multiplied by Itself (x² = P) [Ex 2.2 #14], 1: One Number is k Times Another (k*x² = P)
    required String targetProductStr,
    required String multipleKStr,
  }) {
    try {
      final ParsedFactor p = parseFlexibleFactor(
        targetProductStr,
        fieldName: 'Resulting Product (P)',
      );

      final ParsedFactor kFactor = subMode == 1
          ? parseFlexibleFactor(multipleKStr, fieldName: 'Multiple (k)')
          : const ParsedFactor(
        rawInput: '1',
        value: 1.0,
        num: 1,
        den: 1,
        displayPlain: '1',
        displayLaTeX: '1',
        improperLaTeX: '1',
      );

      if (kFactor.value <= 0) {
        throw const FormatException("The multiple k must be greater than zero.");
      }

      final int xSqNumRaw = p.num * kFactor.den;
      final int xSqDenRaw = p.den * kFactor.num;
      if ((xSqNumRaw < 0 && xSqDenRaw > 0) ||
          (xSqNumRaw > 0 && xSqDenRaw < 0)) {
        throw const FormatException(
          "A real number multiplied by itself (x²) is always positive (since (+)×(+) = (+) and (−)×(−) = (+)). Please enter a positive product!",
        );
      }

      final int g = gcd(xSqNumRaw.abs(), xSqDenRaw.abs());
      final int simpNum = xSqNumRaw.abs() ~/ g;
      final int simpDen = xSqDenRaw.abs() ~/ g;

      final int rootNum = math.sqrt(simpNum).round();
      final int rootDen = math.sqrt(simpDen).round();
      final bool isExactRationalSquare =
          (rootNum * rootNum == simpNum) && (rootDen * rootDen == simpDen);

      final List<String> workings = [];
      final List<ProductStep> steps = [];
      final Map<String, String> answers = {};

      // STEP 1: Translate "A Number Multiplied by Itself" into x² = P
      final List<String> step1Lines = subMode == 0
          ? [
        "\\text{Let the unknown number be } x.",
        "\\text{'A number multiplied by itself' means } x \\times x = x^2.",
        "x \\times x = ${p.displayLaTeX}",
        "x^2 = ${p.displayLaTeX}",
      ]
          : [
        "\\text{Let the first number be } x, \\text{ so the second number is } ${kFactor.displayLaTeX}x.",
        "\\text{Their product is } ${p.displayLaTeX}:",
        "${kFactor.displayLaTeX}x \\times x = ${p.displayLaTeX}",
        "${kFactor.displayLaTeX}x^2 = ${p.displayLaTeX}",
        "x^2 = \\frac{${p.displayLaTeX}}{${kFactor.displayLaTeX}} = \\frac{$simpNum}{$simpDen}",
      ];

      workings.add(
          "\\text{\\textbf{Step 1: Translate the Word Problem into a Quadratic Equation (Exercise 2.2 \\#14)}}");
      workings.addAll(step1Lines);
      workings.add("");

      steps.add(ProductStep(
        title: "Step 1: Represent 'A Number Multiplied by Itself' as x²",
        description: subMode == 0
            ? "• Let the unknown number be x.\n"
            "• When x is multiplied by itself, we write x × x = x².\n"
            "• Equating this product to ${p.displayPlain} gives the equation x² = ${p.displayPlain}."
            : "• Let the smaller number be x and the other number be ${kFactor.displayPlain}x.\n"
            "• Multiplying them gives ${kFactor.displayPlain}x² = ${p.displayPlain}.",
        mathLinesLaTeX: step1Lines,
      ));

      // STEP 2: Convert Mixed Number to Improper Fraction & Take the Square Root
      final List<String> step2Lines = [];
      if (p.isMixedInput) {
        step2Lines.add(
            "\\text{Convert the mixed number } ${p.displayLaTeX} \\text{ into an improper fraction:}");
        step2Lines.add(buildMixedConversionLineLaTeX(p));
        step2Lines.add("x^2 = \\frac{$simpNum}{$simpDen}");
      }

      step2Lines.add("\\text{Take the square root of both sides of the equation:}");
      String posAnsPlain = "";
      String posAnsLaTeX = "";

      if (isExactRationalSquare) {
        final Map<String, String> rootFmt = formatRational(rootNum, rootDen);
        final Map<String, String> negRootFmt =
        formatRational(-rootNum, rootDen);
        posAnsPlain = rootFmt['plain']!;
        posAnsLaTeX = rootFmt['latex']!;

        if (simpDen > 1) {
          step2Lines.add("x = \\sqrt{\\frac{$simpNum}{$simpDen}}");
          step2Lines.add(
              "x = \\frac{\\sqrt{$simpNum}}{\\sqrt{$simpDen}} = \\frac{\\sqrt{$rootNum \\times $rootNum}}{\\sqrt{$rootDen \\times $rootDen}}");
          step2Lines.add("x = \\frac{$rootNum}{$rootDen}");
          if (rootFmt['latex'] != rootFmt['improperLaTeX']) {
            step2Lines.add(
                "\\text{Convert improper fraction to a mixed number:}");
          }
          step2Lines.add(
              "\\therefore \\; \\mathbf{x = ${rootFmt['latex']}} \\quad \\left(\\text{or } \\mathbf{${negRootFmt['latex']}}, \\text{ since } (-)\\times(-)=(+)\\right)");
        } else {
          step2Lines.add(
              "x = \\sqrt{$simpNum} = \\sqrt{$rootNum \\times $rootNum}");
          step2Lines.add(
              "\\therefore \\; \\mathbf{x = $rootNum} \\quad (\\text{or } \\mathbf{-$rootNum})");
        }

        answers["Positive Answer (x)"] = posAnsPlain;
        answers["Negative Solution"] = negRootFmt['plain']!;
        if (subMode == 1) {
          final double secondVal = (rootNum / rootDen) * kFactor.value;
          answers["2nd Number (${kFactor.displayPlain}x)"] = fmt(secondVal);
        }
      } else {
        final double approxX = math.sqrt(simpNum / simpDen);
        posAnsPlain = fmt(approxX);
        posAnsLaTeX = fmt(approxX);
        step2Lines.add("x = \\sqrt{${fmt(simpNum / simpDen)}} \\approx \\mathbf{$posAnsLaTeX}");
        answers["Number (x)"] = "±$posAnsPlain";
      }

      workings.add(
          "\\text{\\textbf{Step 2: Convert to Improper Fraction and Take the Square Root}}");
      workings.addAll(step2Lines);
      workings.add("");

      steps.add(ProductStep(
        title: "Step 2: Take the Square Root of Numerator and Denominator",
        description: p.isMixedInput
            ? "1. Convert the mixed number ${p.displayPlain} into the improper fraction $simpNum/$simpDen.\n"
            "2. Take the square root of the numerator (√$simpNum = $rootNum) and the square root of the denominator (√$simpDen = $rootDen) to get $rootNum/$rootDen = $posAnsPlain.\n"
            "3. Note: Since (−$posAnsPlain) × (−$posAnsPlain) also equals +${p.displayPlain}, −$posAnsPlain is also a valid mathematical solution!"
            : "Take the square root of both sides to find x = $posAnsPlain (or −$posAnsPlain).",
        mathLinesLaTeX: step2Lines,
      ));

      // STEP 3: Verification Check
      final List<String> step3Lines = [
        "\\text{Check: } x \\times x = \\left($posAnsLaTeX\\right) \\times \\left($posAnsLaTeX\\right) = \\frac{$simpNum}{$simpDen} = \\mathbf{${p.displayLaTeX}} \\quad (\\text{Verified!})",
      ];
      workings.add("\\text{\\textbf{Step 3: Verification Check}}");
      workings.addAll(step3Lines);

      steps.add(ProductStep(
        title: "Step 3: Check by Multiplying the Number by Itself",
        description:
        "Multiply $posAnsPlain by $posAnsPlain to verify that the result is ${p.displayPlain}.",
        mathLinesLaTeX: step3Lines,
      ));

      return ProductResult(
        mode: 3,
        subMode: subMode,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: ProductCanvasData(
          visualType: 1,
          squareSideLabel: "Side x = $posAnsPlain",
          squareAreaLabel: "Area x² = ${p.displayPlain} ($simpNum/$simpDen)",
          gridRows: rootDen.clamp(2, 6),
          gridCols: rootDen.clamp(2, 6),
          headerBadge:
          "Self-Product (x × x = ${p.displayPlain})   ➔   x = $posAnsPlain (or −$posAnsPlain)",
          subBadge:
          "x² = $simpNum/$simpDen   ➔   x = √($simpNum/$simpDen) = $rootNum/$rootDen = $posAnsPlain",
          bottomSummaryBanner:
          "The Required Number is  x = $posAnsPlain   (or −$posAnsPlain)",
        ),
      );
    } catch (e) {
      return ProductResult.error(
        mode: 3,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid positive number or mixed fraction.",
      );
    }
  }
}