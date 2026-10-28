import 'dart:math' as math;
import 'sum_diff_product_models.dart';

class SumDiffProductLogic {
  // ===========================================================================
  // 16 TEXTBOOK & BECE PRESETS (Pages 23–25: Example 7 & Exercise 2.3)
  // ===========================================================================
  static const List<SumDiffProductPreset> textbookPresets = [
    SumDiffProductPreset(
      chipLabel: "Example 7 (Page 23): Product of 7 and the sum of 8 and 10",
      mode: 0,
      subMode: 0, // a * (b + c)
      input1: '7',
      input2: '8',
      input3: '10',
    ),
    SumDiffProductPreset(
      chipLabel: "Ex 2.3 #1: Product of -4 and positive diff between 15 and -5",
      mode: 0,
      subMode: 1, // a * |b - c|
      input1: '-4',
      input2: '15',
      input3: '-5',
    ),
    SumDiffProductPreset(
      chipLabel: "Ex 2.3 #2: Product of 2 ½ and the sum of 1 ⅓ and 2 ⅔",
      mode: 0,
      subMode: 0,
      input1: '2 1/2',
      input2: '1 1/3',
      input3: '2 2/3',
    ),
    SumDiffProductPreset(
      chipLabel: "Ex 2.3 #3: Product of sum of 12 & 8 and diff between 19 & 14",
      mode: 0,
      subMode: 2, // (a + b) * |c - d|
      input1: '12',
      input2: '8',
      input3: '19',
      input4: '14',
    ),
    SumDiffProductPreset(
      chipLabel: "Ex 2.3 #4: Add 15 to the product of -6 and 8",
      mode: 0,
      subMode: 3, // a + (b * c)
      input1: '15',
      input2: '-6',
      input3: '8',
    ),
    SumDiffProductPreset(
      chipLabel: "Ex 2.3 #5: Subtract the product of 4 and 9 from 50",
      mode: 0,
      subMode: 4, // a - (b * c)
      input1: '50',
      input2: '4',
      input3: '9',
    ),
    SumDiffProductPreset(
      chipLabel: "Ex 2.3 #6: When 8 is added to 5 times x, result is 43",
      mode: 1,
      subMode: 0, // ax + b = c
      input1: '5',
      input2: '8',
      input3: '43',
    ),
    SumDiffProductPreset(
      chipLabel: "Ex 2.3 #7: 9 subtracted from 4 times a number gives 27",
      mode: 1,
      subMode: 1, // ax - b = c
      input1: '4',
      input2: '9',
      input3: '27',
    ),
    SumDiffProductPreset(
      chipLabel: "Ex 2.3 #8: 3 times a number subtracted from 40 gives 16",
      mode: 1,
      subMode: 2, // b - ax = c
      input1: '3',
      input2: '40',
      input3: '16',
    ),
    SumDiffProductPreset(
      chipLabel: "Ex 2.3 #9: Sum of ¾ of a number and 2 ½ is 8 ½",
      mode: 1,
      subMode: 0,
      input1: '3/4',
      input2: '2 1/2',
      input3: '8 1/2',
    ),
    SumDiffProductPreset(
      chipLabel: "Ex 2.3 #10: Product of 6 and sum of a number and 4 is 54",
      mode: 2,
      subMode: 0, // k(x + b) = c
      input1: '6',
      input2: '4',
      input3: '54',
    ),
    SumDiffProductPreset(
      chipLabel: "Ex 2.3 #11: Subtract 5 from x, multiply result by 8 gives 56",
      mode: 2,
      subMode: 1, // k(x - b) = c
      input1: '8',
      input2: '5',
      input3: '56',
    ),
    SumDiffProductPreset(
      chipLabel: "Ex 2.3 #12: Subtract x from 20, multiply result by 3 gives 42",
      mode: 2,
      subMode: 2, // k(b - x) = c
      input1: '3',
      input2: '20',
      input3: '42',
    ),
    SumDiffProductPreset(
      chipLabel: "Ex 2.3 #13: Twice a number + 11 equals 5 times the number − 7",
      mode: 3,
      subMode: 0, // ax + b = cx + d
      input1: '2',
      input2: '11',
      input3: '5',
      input4: '-7',
    ),
    SumDiffProductPreset(
      chipLabel: "Ex 2.3 #14: 5 times (x + 2) equals 7 times (x − 4)",
      mode: 3,
      subMode: 1, // k1(x + a) = k2(x + b)
      input1: '5',
      input2: '2',
      input3: '7',
      input4: '-4',
    ),
    SumDiffProductPreset(
      chipLabel: "Ex 2.3 #15: Sum of 2× first and 3× second consecutive no. is 43",
      mode: 3,
      subMode: 2, // a*x + b*(x + 1) = S
      input1: '2',
      input2: '3',
      input3: '43',
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

  static int lcm(int a, int b) {
    if (a == 0 || b == 0) return 1;
    return (a.abs() * b.abs()) ~/ gcd(a, b);
  }

  static String fmt(double v, {int maxDecimals = 4}) {
    if (v.abs() < 1e-9) return '0';
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static String wrapNegLaTeX(ParsedTerm t) {
    return t.value < 0 ? "\\left(${t.displayLaTeX}\\right)" : t.displayLaTeX;
  }

  static String wrapNegPlain(ParsedTerm t) {
    return t.value < 0 ? "(${t.displayPlain})" : t.displayPlain;
  }

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
        'improperLaTeX': '$sign$n',
        'improperPlain': '$sign$n',
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

  static ParsedTerm parseFlexibleTerm(
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
        .replaceAll(',', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (s.isEmpty) {
      throw FormatException(
        "Please enter a valid $fieldName (e.g. 7, -4, 2 1/2, or 3/4).",
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

        return ParsedTerm(
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

        return ParsedTerm(
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
            "Invalid fraction format '$raw'. Try '2 1/2' or '3/4'.");
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
    return ParsedTerm(
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

  // ===========================================================================
  // MODE 0: DIRECT NUMERICAL EXPRESSIONS COMBINING PRODUCT WITH SUM / DIFFERENCE
  // Sub-Modes:
  // 0: Product of a and the Sum of b and c -> a * (b + c) [Example 7]
  // 1: Product of a and the Positive Difference between b and c -> a * |b - c|
  // 2: Product of the Sum of (a & b) and the Positive Difference between (c & d) -> (a + b) * |c - d|
  // 3: Add a to the Product of b and c -> a + (b * c)
  // 4: Subtract the Product of b and c from a -> a - (b * c)
  // ===========================================================================
  static SumDiffProductResult solveDirectCombinedExpression({
    required int subMode,
    required String input1Str,
    required String input2Str,
    required String input3Str,
    required String input4Str,
  }) {
    try {
      final ParsedTerm a =
      parseFlexibleTerm(input1Str, fieldName: 'First Number (a)');
      final ParsedTerm b =
      parseFlexibleTerm(input2Str, fieldName: 'Second Number (b)');
      final ParsedTerm c =
      parseFlexibleTerm(input3Str, fieldName: 'Third Number (c)');

      final List<String> workings = [];
      final List<SumDiffProductStep> steps = [];
      final Map<String, String> answers = {};

      if (subMode == 0 || subMode == 1) {
        // Sub-Mode 0: Product of a and the Sum of b and c -> a * (b + c) [Example 7]
        // Sub-Mode 1: Product of a and the Positive Difference between b and c -> a * (Larger - Smaller)
        final bool isSum = subMode == 0;
        final ParsedTerm leftInBracket =
        isSum ? b : (b.value >= c.value ? b : c);
        final ParsedTerm rightInBracket =
        isSum ? c : (b.value >= c.value ? c : b);

        final int lcmBC = lcm(leftInBracket.den, rightInBracket.den);
        final int scaledL =
            leftInBracket.num * (lcmBC ~/ leftInBracket.den);
        final int scaledR =
            rightInBracket.num * (lcmBC ~/ rightInBracket.den);
        final int bracketNum = isSum ? (scaledL + scaledR) : (scaledL - scaledR);
        final Map<String, String> bracketFmt =
        formatRational(bracketNum, lcmBC);
        final double bracketVal = isSum
            ? (leftInBracket.value + rightInBracket.value)
            : (leftInBracket.value - rightInBracket.value);

        final int finalNum = a.num * bracketNum;
        final int finalDen = a.den * lcmBC;
        final Map<String, String> finalFmt = formatRational(finalNum, finalDen);
        final double finalVal = a.value * bracketVal;

        final bool useFractions = a.isFractionOrMixed ||
            leftInBracket.isFractionOrMixed ||
            rightInBracket.isFractionOrMixed;

        final String opSym = isSum ? "+" : "-";
        final String opWord = isSum ? "sum" : "positive difference";
        final String bracketExprLaTeX =
            "\\left(${leftInBracket.displayLaTeX} $opSym ${wrapNegLaTeX(rightInBracket)}\\right)";
        final String bracketExprPlain =
            "(${leftInBracket.displayPlain} $opSym ${wrapNegPlain(rightInBracket)})";

        // STEP 1: Translate the Word Statement Using Brackets (Example 7 Method)
        final List<String> step1Lines = [
          "\\text{Rule (Example 7, Page 23): Enclose the $opWord of } ${leftInBracket.displayLaTeX} \\text{ and } ${rightInBracket.displayLaTeX} \\text{ inside brackets first:}",
          if (!isSum)
            "\\text{Compare } ${b.displayLaTeX} \\text{ and } ${c.displayLaTeX}: \\quad ${leftInBracket.displayLaTeX} > ${rightInBracket.displayLaTeX} \\quad (\\text{Larger} - \\text{Smaller})",
          "\\text{${isSum ? 'Sum' : 'Positive Difference'}} = $bracketExprLaTeX",
          "\\text{Multiply by } ${a.displayLaTeX}:",
          "\\text{Required Product} = ${wrapNegLaTeX(a)} \\times $bracketExprLaTeX",
        ];

        workings.add(
            "\\text{\\textbf{Step 1: Translate the Word Problem into a Bracketed Expression (Example 7)}}");
        workings.addAll(step1Lines);
        workings.add("");

        steps.add(SumDiffProductStep(
          title:
          "Step 1: Group the ${isSum ? 'Sum' : 'Difference'} in Brackets First (BODMAS Rule)",
          description:
          "• Following Example 7 on Page 23 ('Find the product of ${a.displayPlain} and the $opWord of ${b.displayPlain} and ${c.displayPlain}'), we must evaluate the $opWord FIRST before multiplying by ${a.displayPlain}.\n"
              "• Therefore, enclose $bracketExprPlain in brackets and multiply by ${a.displayPlain}: ${wrapNegPlain(a)} × $bracketExprPlain.",
          mathLinesLaTeX: step1Lines,
        ));

        // STEP 2: Evaluate Inside the Brackets First (B in BODMAS)
        final List<String> step2Lines = [
          "\\text{Evaluate the bracket } $bracketExprLaTeX \\text{ first:}",
        ];
        if (!isSum && rightInBracket.value < 0) {
          step2Lines.add(
              "\\text{Directed-number rule: } -(${rightInBracket.displayLaTeX}) = +${fmt(rightInBracket.value.abs())}");
          step2Lines.add(
              "$bracketExprLaTeX = ${leftInBracket.displayLaTeX} + ${fmt(rightInBracket.value.abs())}");
        }
        if (useFractions &&
            (leftInBracket.isFractionOrMixed ||
                rightInBracket.isFractionOrMixed)) {
          step2Lines.add(
              "= ${leftInBracket.improperLaTeX} $opSym ${rightInBracket.value < 0 ? '\\left(${rightInBracket.improperLaTeX}\\right)' : rightInBracket.improperLaTeX}");
          step2Lines.add(
              "= \\frac{$scaledL $opSym ${scaledR < 0 ? '($scaledR)' : '$scaledR'}}{$lcmBC} = \\frac{$bracketNum}{$lcmBC}");
          step2Lines.add("= \\mathbf{${bracketFmt['latex']}}");
        } else {
          step2Lines.add("= \\mathbf{${fmt(bracketVal)}}");
        }

        workings.add(
            "\\text{\\textbf{Step 2: Evaluate the Expression Inside the Brackets First}}");
        workings.addAll(step2Lines);
        workings.add("");

        final String bracketAnsPlain =
        useFractions ? bracketFmt['plain']! : fmt(bracketVal);
        final String bracketAnsLaTeX =
        useFractions ? bracketFmt['latex']! : fmt(bracketVal);

        steps.add(SumDiffProductStep(
          title:
          "Step 2: Calculate the ${isSum ? 'Sum' : 'Positive Difference'} Inside the Brackets",
          description:
          "By the BODMAS rule, work out the bracket $bracketExprPlain first to get $bracketAnsPlain.",
          mathLinesLaTeX: step2Lines,
        ));

        // STEP 3: Multiply by the First Number & Show Distributive Law Check
        final String finalAnsPlain =
        useFractions ? finalFmt['plain']! : fmt(finalVal);
        final String finalAnsLaTeX =
        useFractions ? finalFmt['latex']! : fmt(finalVal);

        final List<String> step3Lines = [
          "\\text{Product} = ${wrapNegLaTeX(a)} \\times $bracketExprLaTeX",
          "= ${wrapNegLaTeX(a)} \\times ${bracketVal < 0 ? '\\left($bracketAnsLaTeX\\right)' : bracketAnsLaTeX}",
          if (useFractions) ...[
            "= ${a.improperLaTeX} \\times ${bracketFmt['improperLaTeX']}",
            "= \\frac{${a.num} \\times ${bracketNum ~/ gcd(bracketNum, lcmBC)}}{${a.den} \\times ${lcmBC ~/ gcd(bracketNum, lcmBC)}} = ${finalFmt['improperLaTeX']}",
          ],
          "\\therefore \\; \\text{Product} = \\mathbf{$finalAnsLaTeX}"
              "${useFractions && finalAnsPlain != fmt(finalVal) ? ' \\quad \\left(\\text{or } \\mathbf{${fmt(finalVal)}}\\right)' : ''}",
          "\\text{Distributive Law Check: } \\left(${wrapNegLaTeX(a)} \\times ${wrapNegLaTeX(leftInBracket)}\\right) $opSym \\left(${wrapNegLaTeX(a)} \\times ${wrapNegLaTeX(rightInBracket)}\\right) = ${fmt(a.value * leftInBracket.value)} $opSym ${a.value * rightInBracket.value < 0 ? '(${fmt(a.value * rightInBracket.value)})' : fmt(a.value * rightInBracket.value)} = \\mathbf{${fmt(finalVal)}}",
        ];

        workings.add(
            "\\text{\\textbf{Step 3: Multiply by }} ${a.displayLaTeX} \\text{\\textbf{ to Find the Final Product}}");
        workings.addAll(step3Lines);

        steps.add(SumDiffProductStep(
          title:
          "Step 3: Multiply ${a.displayPlain} by $bracketAnsPlain (Plus Distributive Law Check)",
          description:
          "1. Multiply ${a.displayPlain} by the bracket result ($bracketAnsPlain): ${wrapNegPlain(a)} × $bracketAnsPlain = $finalAnsPlain.\n"
              "2. Distributive Law Check: You can also multiply ${a.displayPlain} by each term inside the bracket separately and ${isSum ? 'add' : 'subtract'} the products: (${wrapNegPlain(a)} × ${wrapNegPlain(leftInBracket)}) $opSym (${wrapNegPlain(a)} × ${wrapNegPlain(rightInBracket)}) = ${fmt(a.value * leftInBracket.value)} $opSym ${fmt(a.value * rightInBracket.value)} = ${fmt(finalVal)}!",
          mathLinesLaTeX: step3Lines,
        ));

        answers["Bracket (${isSum ? 'Sum' : 'Diff'})"] = bracketAnsPlain;
        answers["Final Product"] = finalAnsPlain;

        return SumDiffProductResult(
          mode: 0,
          subMode: subMode,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          canvasData: SumDiffProductCanvasData(
            visualType: 0,
            stage1BoxATitle: "Multiplier (a)",
            stage1BoxAValue: a.displayPlain,
            stage1BoxBTitle:
            "Bracket (${isSum ? 'Sum' : 'Positive Diff'})",
            stage1BoxBValue: "$bracketExprPlain = $bracketAnsPlain",
            bridgeOperatorSymbol: "×",
            finalResultTitle: "Final Product",
            finalResultValue:
            "${wrapNegPlain(a)} × $bracketAnsPlain = $finalAnsPlain",
            headerBadge:
            "Example 7 BODMAS:  ${wrapNegPlain(a)} × $bracketExprPlain = $finalAnsPlain",
            subBadge:
            "Step 1 (Brackets): $bracketExprPlain = $bracketAnsPlain   ➔   Step 2 (Multiply): ${wrapNegPlain(a)} × $bracketAnsPlain = $finalAnsPlain",
            bottomSummaryBanner: "Final Product = $finalAnsPlain",
          ),
        );
      } else if (subMode == 2) {
        // Sub-Mode 2: Product of the Sum of (a and b) and the Positive Difference between (c and d)
        final ParsedTerm d =
        parseFlexibleTerm(input4Str, fieldName: 'Fourth Number (d)');
        final ParsedTerm largerCD = c.value >= d.value ? c : d;
        final ParsedTerm smallerCD = c.value >= d.value ? d : c;

        final double sumAB = a.value + b.value;
        final double diffCD = largerCD.value - smallerCD.value;
        final double prodVal = sumAB * diffCD;

        final List<String> step1Lines = [
          "\\text{1st Bracket (Sum of } ${a.displayLaTeX} \\text{ and } ${b.displayLaTeX}\\text{)} = \\left(${a.displayLaTeX} + ${wrapNegLaTeX(b)}\\right)",
          "\\text{2nd Bracket (Positive difference between } ${c.displayLaTeX} \\text{ and } ${d.displayLaTeX}\\text{)} = \\left(${largerCD.displayLaTeX} - ${wrapNegLaTeX(smallerCD)}\\right)",
          "\\text{Required Product} = \\left(${a.displayLaTeX} + ${wrapNegLaTeX(b)}\\right) \\times \\left(${largerCD.displayLaTeX} - ${wrapNegLaTeX(smallerCD)}\\right)",
        ];

        final List<String> step2Lines = [
          "\\bullet \\text{ Evaluate 1st Bracket (Sum): } ${a.displayLaTeX} + ${wrapNegLaTeX(b)} = \\mathbf{${fmt(sumAB)}}",
          "\\bullet \\text{ Evaluate 2nd Bracket (Difference): } ${largerCD.displayLaTeX} - ${wrapNegLaTeX(smallerCD)} = \\mathbf{${fmt(diffCD)}}",
        ];

        final List<String> step3Lines = [
          "\\text{Product} = \\left(${a.displayLaTeX} + ${wrapNegLaTeX(b)}\\right) \\times \\left(${largerCD.displayLaTeX} - ${wrapNegLaTeX(smallerCD)}\\right)",
          "= ${fmt(sumAB)} \\times ${fmt(diffCD)}",
          "\\therefore \\; \\text{Product} = \\mathbf{${fmt(prodVal)}}",
        ];

        workings.add(
            "\\text{\\textbf{Step 1: Write the Product of Both Bracketed Expressions}}");
        workings.addAll(step1Lines);
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 2: Evaluate the Sum and the Difference Separately}}");
        workings.addAll(step2Lines);
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 3: Multiply the Sum by the Difference}}");
        workings.addAll(step3Lines);

        steps.add(SumDiffProductStep(
          title: "Step 1: Enclose the Sum and the Difference in Separate Brackets",
          description:
          "• First bracket (Sum): (${a.displayPlain} + ${wrapNegPlain(b)}).\n"
              "• Second bracket (Positive difference): (${largerCD.displayPlain} − ${wrapNegPlain(smallerCD)}).\n"
              "• Combined expression: (${a.displayPlain} + ${wrapNegPlain(b)}) × (${largerCD.displayPlain} − ${wrapNegPlain(smallerCD)}).",
          mathLinesLaTeX: step1Lines,
        ));

        steps.add(SumDiffProductStep(
          title: "Step 2: Evaluate Both Brackets, Then Multiply",
          description:
          "1. Sum = ${a.displayPlain} + ${wrapNegPlain(b)} = ${fmt(sumAB)}.\n"
              "2. Positive Difference = ${largerCD.displayPlain} − ${wrapNegPlain(smallerCD)} = ${fmt(diffCD)}.\n"
              "3. Product = ${fmt(sumAB)} × ${fmt(diffCD)} = ${fmt(prodVal)}.",
          mathLinesLaTeX: [...step2Lines, ...step3Lines],
        ));

        return SumDiffProductResult(
          mode: 0,
          subMode: 2,
          finalAnswers: {
            "Sum (a + b)": fmt(sumAB),
            "Difference |c − d|": fmt(diffCD),
            "Final Product": fmt(prodVal),
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: SumDiffProductCanvasData(
            visualType: 0,
            stage1BoxATitle: "1st Bracket (Sum)",
            stage1BoxAValue:
            "(${a.displayPlain} + ${wrapNegPlain(b)}) = ${fmt(sumAB)}",
            stage1BoxBTitle: "2nd Bracket (Diff)",
            stage1BoxBValue:
            "(${largerCD.displayPlain} − ${wrapNegPlain(smallerCD)}) = ${fmt(diffCD)}",
            bridgeOperatorSymbol: "×",
            finalResultTitle: "Final Product",
            finalResultValue:
            "${fmt(sumAB)} × ${fmt(diffCD)} = ${fmt(prodVal)}",
            headerBadge:
            "(${a.displayPlain} + ${wrapNegPlain(b)}) × (${largerCD.displayPlain} − ${wrapNegPlain(smallerCD)}) = ${fmt(prodVal)}",
            subBadge:
            "Sum = ${fmt(sumAB)}   |   Positive Difference = ${fmt(diffCD)}   |   Product = ${fmt(prodVal)}",
            bottomSummaryBanner: "Final Product = ${fmt(prodVal)}",
          ),
        );
      } else {
        // Sub-Mode 3: Add a to the Product of b and c -> a + (b * c)
        // Sub-Mode 4: Subtract the Product of b and c from a -> a - (b * c)
        final bool isAdd = subMode == 3;
        final double prodBC = b.value * c.value;
        final double finalVal = isAdd ? (a.value + prodBC) : (a.value - prodBC);
        final String opSym = isAdd ? "+" : "-";

        final List<String> step1Lines = [
          "\\text{Rule: Enclose the product of } ${b.displayLaTeX} \\text{ and } ${c.displayLaTeX} \\text{ in brackets: } \\left(${wrapNegLaTeX(b)} \\times ${wrapNegLaTeX(c)}\\right)",
          if (isAdd)
            "\\text{Add } ${a.displayLaTeX} \\text{ to the product:}"
          else
            "\\text{Subtract the product from } ${a.displayLaTeX} \\text{ (so } ${a.displayLaTeX} \\text{ comes FIRST!):}",
          "\\text{Expression} = ${a.displayLaTeX} $opSym \\left(${wrapNegLaTeX(b)} \\times ${wrapNegLaTeX(c)}\\right)",
        ];

        final List<String> step2Lines = [
          "\\text{Evaluate the product } \\left(${wrapNegLaTeX(b)} \\times ${wrapNegLaTeX(c)}\\right) \\text{ first (Multiplication before Addition/Subtraction):}",
          "${wrapNegLaTeX(b)} \\times ${wrapNegLaTeX(c)} = \\mathbf{${fmt(prodBC)}}",
          "\\text{Now ${isAdd ? 'add to' : 'subtract from'} } ${a.displayLaTeX}:",
          "= ${a.displayLaTeX} $opSym ${prodBC < 0 ? '\\left(${fmt(prodBC)}\\right)' : fmt(prodBC)}",
          if (!isAdd && prodBC < 0)
            "= ${a.displayLaTeX} + ${fmt(prodBC.abs())}",
          if (isAdd && prodBC < 0)
            "= ${a.displayLaTeX} - ${fmt(prodBC.abs())}",
          "\\therefore \\; \\text{Result} = \\mathbf{${fmt(finalVal)}}",
        ];

        workings.add(
            "\\text{\\textbf{Step 1: Set Up the Combined Expression Using BODMAS}}");
        workings.addAll(step1Lines);
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 2: Multiply First, Then ${isAdd ? 'Add' : 'Subtract'}}}");
        workings.addAll(step2Lines);

        steps.add(SumDiffProductStep(
          title:
          "Step 1: Write the Expression (${isAdd ? 'Add a to b × c' : 'Subtract b × c from a'})",
          description: isAdd
              ? "• 'Add ${a.displayPlain} to the product of ${b.displayPlain} and ${c.displayPlain}' is written as ${a.displayPlain} + (${wrapNegPlain(b)} × ${wrapNegPlain(c)})."
              : "• Crucial Rule: 'Subtract the product of ${b.displayPlain} and ${c.displayPlain} FROM ${a.displayPlain}' means ${a.displayPlain} is written FIRST: ${a.displayPlain} − (${wrapNegPlain(b)} × ${wrapNegPlain(c)}).",
          mathLinesLaTeX: step1Lines,
        ));

        steps.add(SumDiffProductStep(
          title:
          "Step 2: Evaluate the Product First (BODMAS), Then ${isAdd ? 'Add' : 'Subtract'}",
          description:
          "1. Multiply ${b.displayPlain} by ${c.displayPlain} first: ${wrapNegPlain(b)} × ${wrapNegPlain(c)} = ${fmt(prodBC)}.\n"
              "2. Combine with ${a.displayPlain}: ${a.displayPlain} $opSym ${prodBC < 0 ? '(${fmt(prodBC)})' : fmt(prodBC)} = ${fmt(finalVal)}.",
          mathLinesLaTeX: step2Lines,
        ));

        return SumDiffProductResult(
          mode: 0,
          subMode: subMode,
          finalAnswers: {
            "Product (b × c)": fmt(prodBC),
            "Final Result": fmt(finalVal),
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: SumDiffProductCanvasData(
            visualType: 0,
            stage1BoxATitle: "Number (a)",
            stage1BoxAValue: a.displayPlain,
            stage1BoxBTitle: "Product (b × c)",
            stage1BoxBValue:
            "(${wrapNegPlain(b)} × ${wrapNegPlain(c)}) = ${fmt(prodBC)}",
            bridgeOperatorSymbol: opSym,
            finalResultTitle: "Final Result",
            finalResultValue:
            "${a.displayPlain} $opSym ${prodBC < 0 ? '(${fmt(prodBC)})' : fmt(prodBC)} = ${fmt(finalVal)}",
            headerBadge:
            "${a.displayPlain} $opSym (${wrapNegPlain(b)} × ${wrapNegPlain(c)}) = ${fmt(finalVal)}",
            subBadge:
            "Step 1 (Product): ${wrapNegPlain(b)} × ${wrapNegPlain(c)} = ${fmt(prodBC)}   ➔   Step 2: ${a.displayPlain} $opSym ${prodBC < 0 ? '(${fmt(prodBC)})' : fmt(prodBC)} = ${fmt(finalVal)}",
            bottomSummaryBanner: "Final Result = ${fmt(finalVal)}",
          ),
        );
      }
    } catch (e) {
      return SumDiffProductResult.error(
        mode: 0,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid numbers or mixed fractions.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: ONE-SIDED ALGEBRAIC WORD PROBLEMS (ax + b = c, ax - b = c, b - ax = c)
  // Covers "Multiply a number by a, then add/subtract b to get c"
  // ===========================================================================
  static SumDiffProductResult solveOneSidedLinearWordProblem({
    required int subMode,
    // 0: b is added to a times a number -> ax + b = c
    // 1: b is subtracted from a times a number -> ax - b = c
    // 2: a times a number is subtracted from b -> b - ax = c
    required String coeffAStr,
    required String constBStr,
    required String resultCStr,
  }) {
    try {
      final ParsedTerm a =
      parseFlexibleTerm(coeffAStr, fieldName: 'Multiplier (a)');
      final ParsedTerm b =
      parseFlexibleTerm(constBStr, fieldName: 'Added/Subtracted Number (b)');
      final ParsedTerm c =
      parseFlexibleTerm(resultCStr, fieldName: 'Given Result (c)');

      if (a.value.abs() < 1e-12) {
        throw const FormatException(
            "The multiplier 'a' of the unknown number x cannot be zero.");
      }

      final bool useFractions =
          a.isFractionOrMixed || b.isFractionOrMixed || c.isFractionOrMixed;
      final List<String> workings = [];
      final List<SumDiffProductStep> steps = [];

      String eqLaTeX = "";
      String eqPlain = "";
      String wordTranslationDesc = "";

      final String axLaTeX =
      (a.value - 1.0).abs() < 1e-9 ? "x" : "${a.displayLaTeX}x";
      final String axPlain =
      (a.value - 1.0).abs() < 1e-9 ? "x" : "${a.displayPlain}x";

      if (subMode == 0) {
        eqLaTeX = "$axLaTeX + ${wrapNegLaTeX(b)} = ${c.displayLaTeX}";
        eqPlain = "$axPlain + ${wrapNegPlain(b)} = ${c.displayPlain}";
        wordTranslationDesc =
        "• Let the unknown number be x.\n"
            "• '${a.displayPlain} times the number' gives the product $axPlain.\n"
            "• Adding ${b.displayPlain} to $axPlain gives $axPlain + ${wrapNegPlain(b)}, which equals ${c.displayPlain}.";
      } else if (subMode == 1) {
        eqLaTeX = "$axLaTeX - ${wrapNegLaTeX(b)} = ${c.displayLaTeX}";
        eqPlain = "$axPlain − ${wrapNegPlain(b)} = ${c.displayPlain}";
        wordTranslationDesc =
        "• Let the unknown number be x.\n"
            "• '${a.displayPlain} times the number' gives the product $axPlain.\n"
            "• Subtracting ${b.displayPlain} from $axPlain gives $axPlain − ${wrapNegPlain(b)} = ${c.displayPlain}.";
      } else {
        eqLaTeX = "${b.displayLaTeX} - $axLaTeX = ${c.displayLaTeX}"
            .replaceAll(r'$axLaTeTeX', axLaTeX);
        eqLaTeX = "${b.displayLaTeX} - $axLaTeX = ${c.displayLaTeX}";
        eqPlain = "${b.displayPlain} − $axPlain = ${c.displayPlain}";
        wordTranslationDesc =
        "• Let the unknown number be x.\n"
            "• '${a.displayPlain} times the number' is $axPlain.\n"
            "• Subtracting $axPlain FROM ${b.displayPlain} means ${b.displayPlain} is written first: ${b.displayPlain} − $axPlain = ${c.displayPlain}.";
      }

      // STEP 1: Form the Equation
      final List<String> step1Lines = [
        "\\text{Let the unknown number be } x.",
        "\\text{Product part} = $axLaTeX",
        "\\text{Form the equation:}",
        "\\mathbf{$eqLaTeX}",
      ];

      workings.add(
          "\\text{\\textbf{Step 1: Translate the Word Problem into an Equation}}");
      workings.addAll(step1Lines);
      workings.add("");

      steps.add(SumDiffProductStep(
        title: "Step 1: Choose Variable x and Form the Equation",
        description: wordTranslationDesc,
        mathLinesLaTeX: step1Lines,
      ));

      // STEP 2: Isolate the Product Term (ax) and Solve for x
      // Exact rational arithmetic:
      // SubMode 0: a*x = c - b
      // SubMode 1: a*x = c + b
      // SubMode 2: -a*x = c - b  =>  a*x = b - c
      final int lcmBC = lcm(b.den, c.den);
      final int scaledB = b.num * (lcmBC ~/ b.den);
      final int scaledC = c.num * (lcmBC ~/ c.den);

      int rhsNumAfterB = 0;
      if (subMode == 0) {
        rhsNumAfterB = scaledC - scaledB;
      } else if (subMode == 1) {
        rhsNumAfterB = scaledC + scaledB;
      } else {
        rhsNumAfterB = scaledB - scaledC;
      }

      final Map<String, String> rhsAfterBFmt =
      formatRational(rhsNumAfterB, lcmBC);
      final double rhsAfterBVal = rhsNumAfterB / lcmBC;

      final int xNumRaw = rhsNumAfterB * a.den;
      final int xDenRaw = lcmBC * a.num;
      final Map<String, String> xFmt = formatRational(xNumRaw, xDenRaw);
      final double exactX = rhsAfterBVal / a.value;

      final List<String> step2Lines = [eqLaTeX];
      if (useFractions && (b.isMixedInput || c.isMixedInput || a.isMixedInput)) {
        step2Lines.add("\\text{Convert mixed numbers to improper fractions:}");
        if (subMode == 0) {
          step2Lines.add(
              "${a.improperLaTeX}x + ${b.improperLaTeX} = ${c.improperLaTeX}");
        } else if (subMode == 1) {
          step2Lines.add(
              "${a.improperLaTeX}x - ${b.improperLaTeX} = ${c.improperLaTeX}");
        } else {
          step2Lines.add(
              "${b.improperLaTeX} - ${a.improperLaTeX}x = ${c.improperLaTeX}");
        }
      }

      if (subMode == 0) {
        step2Lines.add(
            "\\text{Subtract } ${b.displayLaTeX} \\text{ from both sides:}");
        step2Lines.add(
            "$axLaTeX = ${c.displayLaTeX} - ${wrapNegLaTeX(b)}");
        step2Lines.add(
            "$axLaTeX = ${useFractions ? rhsAfterBFmt['improperLaTeX'] : fmt(rhsAfterBVal)}");
      } else if (subMode == 1) {
        step2Lines.add(
            "\\text{Add } ${b.displayLaTeX} \\text{ to both sides:}");
        step2Lines.add(
            "$axLaTeX = ${c.displayLaTeX} + ${wrapNegLaTeX(b)}");
        step2Lines.add(
            "$axLaTeX = ${useFractions ? rhsAfterBFmt['improperLaTeX'] : fmt(rhsAfterBVal)}");
      } else {
        step2Lines.add(
            "\\text{Subtract } ${b.displayLaTeX} \\text{ from both sides:}");
        step2Lines.add(
            "-$axLaTeX = ${c.displayLaTeX} - ${b.displayLaTeX}");
        step2Lines.add(
            "-$axLaTeX = ${fmt(c.value - b.value)}");
        step2Lines.add(
            "\\text{Multiply both sides by } -1:");
        step2Lines.add(
            "$axLaTeX = ${useFractions ? rhsAfterBFmt['improperLaTeX'] : fmt(rhsAfterBVal)}");
      }

      step2Lines.add(
          "\\text{Divide both sides by the coefficient of } x \\; (${a.displayLaTeX}):");
      if (useFractions) {
        step2Lines.add(
            "x = ${rhsAfterBFmt['improperLaTeX']} \\div \\left(${a.improperLaTeX}\\right)");
        final String recipSign = a.num < 0 ? '-' : '';
        step2Lines.add(
            "x = ${rhsAfterBFmt['improperLaTeX']} \\times \\left($recipSign\\frac{${a.den}}{${a.num.abs()}}\\right)");
        step2Lines.add(
            "\\therefore \\; \\mathbf{x = ${xFmt['latex']}} \\quad \\left(\\text{or } \\mathbf{${fmt(exactX)}}\\right)");
      } else {
        step2Lines.add(
            "x = \\frac{${fmt(rhsAfterBVal)}}{${a.displayLaTeX}}");
        step2Lines.add(
            "\\therefore \\; \\mathbf{x = ${xFmt['latex']}}"
                "${xFmt['plain'] != fmt(exactX) ? ' \\quad \\left(\\text{or } \\mathbf{${fmt(exactX)}}\\right)' : ''}");
      }

      workings.add(
          "\\text{\\textbf{Step 2: Isolate the Product Term and Solve for }} x");
      workings.addAll(step2Lines);
      workings.add("");

      // STEP 3: Verification Check
      final String finalAnsPlain = xFmt['plain']!;
      final String finalAnsLaTeX = xFmt['latex']!;
      final List<String> step3Lines = [
        "\\text{Check in } $eqLaTeX:",
        "\\text{Substitute } x = $finalAnsLaTeX: \\quad \\text{LHS} = \\mathbf{${c.displayLaTeX}} = \\text{RHS (Verified!)}",
      ];
      workings.add("\\text{\\textbf{Step 3: Verification Check}}");
      workings.addAll(step3Lines);

      steps.add(SumDiffProductStep(
        title: "Step 2: Isolate $axPlain First, Then Divide by ${a.displayPlain}",
        description:
        "1. Undo the addition/subtraction first so the product term ($axPlain) is alone on the left-hand side: $axPlain = ${useFractions ? rhsAfterBFmt['plain'] : fmt(rhsAfterBVal)}.\n"
            "2. Divide both sides by ${a.displayPlain} to find x = $finalAnsPlain.\n"
            "3. Check: Substituting x = $finalAnsPlain back into $eqPlain gives ${c.displayPlain}!",
        mathLinesLaTeX: [...step2Lines, ...step3Lines],
      ));

      final String lhsExprPlain = eqPlain.split('=').first.trim();

      return SumDiffProductResult(
        mode: 1,
        subMode: subMode,
        finalAnswers: {
          "Algebraic Equation": eqPlain,
          "Product Term ($axPlain)":
          useFractions ? rhsAfterBFmt['plain']! : fmt(rhsAfterBVal),
          "Required Number (x)": finalAnsPlain,
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SumDiffProductCanvasData(
          visualType: 1,
          lhsPanTitle: "Left-Hand Side (LHS)",
          lhsPanExpr: lhsExprPlain,
          rhsPanTitle: "Right-Hand Side (RHS)",
          rhsPanExpr: c.displayPlain,
          forwardChainText:
          "Forward:  x  ➔ (×${a.displayPlain}) ➔ (${subMode == 0 ? '+${b.displayPlain}' : '−${b.displayPlain}'}) ➔ ${c.displayPlain}",
          reverseChainText:
          "Inverse:  ${c.displayPlain}  ➔  $axPlain = ${useFractions ? rhsAfterBFmt['plain'] : fmt(rhsAfterBVal)}  ➔ (÷${a.displayPlain}) ➔ x = $finalAnsPlain",
          headerBadge:
          "One-Sided Equation:  $eqPlain   ➔   x = $finalAnsPlain",
          subBadge:
          "Step 1: Isolate $axPlain = ${useFractions ? rhsAfterBFmt['plain'] : fmt(rhsAfterBVal)}   |   Step 2: Divide by ${a.displayPlain} ➔ x = $finalAnsPlain",
          bottomSummaryBanner: "Required Number:  x = $finalAnsPlain",
        ),
      );
    } catch (e) {
      return SumDiffProductResult.error(
        mode: 1,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid numbers or fractions.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: BRACKETED ALGEBRAIC WORD PROBLEMS k(x + b) = c, k(x - b) = c, k(b - x) = c
  // Shows BOTH Textbook Methods:
  //   Method 1: Expanding Brackets First (Distributive Law)
  //   Method 2: Dividing Both Sides by Multiplier k First
  // ===========================================================================
  static SumDiffProductResult solveBracketedAlgebraicWordProblem({
    required int subMode,
    // 0: Product of k and the sum of x and b is c -> k(x + b) = c
    // 1: b subtracted from x, result multiplied by k gives c -> k(x - b) = c
    // 2: x subtracted from b, result multiplied by k gives c -> k(b - x) = c
    required String multiplierKStr,
    required String insideBStr,
    required String resultCStr,
  }) {
    try {
      final ParsedTerm k =
      parseFlexibleTerm(multiplierKStr, fieldName: 'Outside Multiplier (k)');
      final ParsedTerm b =
      parseFlexibleTerm(insideBStr, fieldName: 'Inside Number (b)');
      final ParsedTerm c =
      parseFlexibleTerm(resultCStr, fieldName: 'Given Result (c)');

      if (k.value.abs() < 1e-12) {
        throw const FormatException("The multiplier k cannot be zero.");
      }

      String innerLaTeX = "";
      String innerPlain = "";
      if (subMode == 0) {
        innerLaTeX = "x + ${b.displayLaTeX}";
        innerPlain = "x + ${b.displayPlain}";
      } else if (subMode == 1) {
        innerLaTeX = "x - ${b.displayLaTeX}";
        innerPlain = "x − ${b.displayPlain}";
      } else {
        innerLaTeX = "${b.displayLaTeX} - x";
        innerPlain = "${b.displayPlain} − x";
      }

      final String eqLaTeX = "${k.displayLaTeX}($innerLaTeX) = ${c.displayLaTeX}";
      final String eqPlain = "${k.displayPlain}($innerPlain) = ${c.displayPlain}";

      // Exact calculations
      final double kbVal = k.value * b.value;
      final double cOverK = c.value / k.value;
      double exactX = 0.0;
      if (subMode == 0) {
        exactX = cOverK - b.value;
      } else if (subMode == 1) {
        exactX = cOverK + b.value;
      } else {
        exactX = b.value - cOverK;
      }

      final int cOverKNum = c.num * k.den;
      final int cOverKDen = c.den * k.num;
      final int lcmDen = lcm(cOverKDen, b.den);
      final int scaledCOverK = cOverKNum * (lcmDen ~/ cOverKDen);
      final int scaledB = b.num * (lcmDen ~/ b.den);
      int xNum = 0;
      if (subMode == 0) {
        xNum = scaledCOverK - scaledB;
      } else if (subMode == 1) {
        xNum = scaledCOverK + scaledB;
      } else {
        xNum = scaledB - scaledCOverK;
      }
      final Map<String, String> xFmt = formatRational(xNum, lcmDen);
      final String finalAnsPlain = xFmt['plain']!;
      final String finalAnsLaTeX = xFmt['latex']!;

      // STEP 1: Form the Bracketed Equation
      final List<String> step1Lines = [
        "\\text{Let the unknown number be } x.",
        "\\text{First, write the ${subMode == 0 ? 'sum' : 'difference'} inside brackets: } ($innerLaTeX)",
        "\\text{Multiply the entire bracket by } ${k.displayLaTeX} \\text{ and equate to } ${c.displayLaTeX}:",
        "\\mathbf{$eqLaTeX}",
      ];

      // STEP 2: Method 1 — Expanding Brackets First (Distributive Law)
      final List<String> step2Lines = [
        "\\text{Multiply each term inside the brackets by } ${k.displayLaTeX}:",
        eqLaTeX,
        if (subMode == 0) ...[
          "${k.displayLaTeX}x + (${k.displayLaTeX} \\times ${b.displayLaTeX}) = ${c.displayLaTeX}",
          "${k.displayLaTeX}x + ${fmt(kbVal)} = ${c.displayLaTeX}",
          "\\text{Subtract } ${fmt(kbVal)} \\text{ from both sides:}",
          "${k.displayLaTeX}x = ${c.displayLaTeX} - ${fmt(kbVal)}",
          "${k.displayLaTeX}x = ${fmt(c.value - kbVal)}",
          "\\text{Divide both sides by } ${k.displayLaTeX}:",
          "x = \\frac{${fmt(c.value - kbVal)}}{${k.displayLaTeX}} = \\mathbf{$finalAnsLaTeX}",
        ] else if (subMode == 1) ...[
          "${k.displayLaTeX}x - (${k.displayLaTeX} \\times ${b.displayLaTeX}) = ${c.displayLaTeX}",
          "${k.displayLaTeX}x - ${fmt(kbVal)} = ${c.displayLaTeX}",
          "\\text{Add } ${fmt(kbVal)} \\text{ to both sides:}",
          "${k.displayLaTeX}x = ${c.displayLaTeX} + ${fmt(kbVal)}",
          "${k.displayLaTeX}x = ${fmt(c.value + kbVal)}",
          "\\text{Divide both sides by } ${k.displayLaTeX}:",
          "x = \\frac{${fmt(c.value + kbVal)}}{${k.displayLaTeX}} = \\mathbf{$finalAnsLaTeX}",
        ] else ...[
          "(${k.displayLaTeX} \\times ${b.displayLaTeX}) - ${k.displayLaTeX}x = ${c.displayLaTeX}",
          "${fmt(kbVal)} - ${k.displayLaTeX}x = ${c.displayLaTeX}",
          "\\text{Subtract } ${fmt(kbVal)} \\text{ from both sides:}",
          "-${k.displayLaTeX}x = ${c.displayLaTeX} - ${fmt(kbVal)}",
          "-${k.displayLaTeX}x = ${fmt(c.value - kbVal)}",
          "\\text{Divide both sides by } -${k.displayLaTeX}:",
          "x = \\frac{${fmt(c.value - kbVal)}}{-${k.displayLaTeX}} = \\mathbf{$finalAnsLaTeX}",
        ],
      ];

      // STEP 3: Method 2 — Dividing Both Sides by k First (Plus Verification)
      final Map<String, String> cOverKFmt =
      formatRational(cOverKNum, cOverKDen);
      final List<String> step3Lines = [
        "\\text{Alternatively, divide both sides of } $eqLaTeX \\text{ by } ${k.displayLaTeX} \\text{ first:}",
        "\\frac{${k.displayLaTeX}($innerLaTeX)}{${k.displayLaTeX}} = \\frac{${c.displayLaTeX}}{${k.displayLaTeX}}",
        "$innerLaTeX = ${cOverKFmt['latex']}",
        if (subMode == 0)
          "x = ${cOverKFmt['latex']} - ${b.displayLaTeX} = \\mathbf{$finalAnsLaTeX}"
        else if (subMode == 1)
          "x = ${cOverKFmt['latex']} + ${b.displayLaTeX} = \\mathbf{$finalAnsLaTeX}"
        else
          "x = ${b.displayLaTeX} - ${cOverKFmt['latex']} = \\mathbf{$finalAnsLaTeX}",
        "\\text{Check: } ${k.displayLaTeX}(${subMode == 2 ? '${b.displayLaTeX} - $finalAnsLaTeX' : '$finalAnsLaTeX ${subMode == 0 ? '+' : '-'} ${b.displayLaTeX}'}) = ${k.displayLaTeX}(${cOverKFmt['latex']}) = \\mathbf{${c.displayLaTeX}} \\quad (\\text{Verified!})",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Form the Bracketed Equation}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Step 2: Method 1 — Expand Brackets First (Distributive Law)}}",
        ...step2Lines,
        "",
        "\\text{\\textbf{Step 3: Method 2 — Divide Both Sides by ${k.displayLaTeX} First \\& Verify}}",
        ...step3Lines,
      ];

      final List<SumDiffProductStep> steps = [
        SumDiffProductStep(
          title: "Step 1: Enclose the ${subMode == 0 ? 'Sum' : 'Difference'} in Brackets First",
          description:
          "• Because the addition/subtraction happens to x BEFORE the result is multiplied by ${k.displayPlain}, we must enclose ($innerPlain) inside brackets.\n"
              "• Multiplying the bracket by ${k.displayPlain} gives the equation: $eqPlain.",
          mathLinesLaTeX: step1Lines,
        ),
        SumDiffProductStep(
          title: "Step 2: Method 1 — Clear Brackets by Multiplying Each Term by ${k.displayPlain}",
          description:
          "1. Multiply every term inside ($innerPlain) by ${k.displayPlain}.\n"
              "2. Collect constant terms on the right-hand side.\n"
              "3. Divide both sides by the coefficient of x to get x = $finalAnsPlain.",
          mathLinesLaTeX: step2Lines,
        ),
        SumDiffProductStep(
          title: "Step 3: Method 2 — Divide Both Sides by ${k.displayPlain} First & Check",
          description:
          "1. Divide both sides of $eqPlain by ${k.displayPlain} first to remove the outside multiplier: $innerPlain = ${cOverKFmt['plain']}.\n"
              "2. Solve for x to get the exact same answer: x = $finalAnsPlain!",
          mathLinesLaTeX: step3Lines,
        ),
      ];

      return SumDiffProductResult(
        mode: 2,
        subMode: subMode,
        finalAnswers: {
          "Bracketed Equation": eqPlain,
          "Bracket Value ($innerPlain)": cOverKFmt['plain']!,
          "Required Number (x)": finalAnsPlain,
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SumDiffProductCanvasData(
          visualType: 1,
          lhsPanTitle: "Left-Hand Side (LHS)",
          lhsPanExpr: "${k.displayPlain}($innerPlain)",
          rhsPanTitle: "Right-Hand Side (RHS)",
          rhsPanExpr: c.displayPlain,
          forwardChainText:
          "Forward:  x  ➔ ($innerPlain) ➔ (×${k.displayPlain}) ➔ ${c.displayPlain}",
          reverseChainText:
          "Inverse:  ${c.displayPlain} ➔ (÷${k.displayPlain} = ${cOverKFmt['plain']}) ➔ x = $finalAnsPlain",
          headerBadge:
          "Bracketed Equation:  $eqPlain   ➔   x = $finalAnsPlain",
          subBadge:
          "Method 1: Expand ${k.displayPlain}($innerPlain)   |   Method 2: Divide by ${k.displayPlain} first ➔ $innerPlain = ${cOverKFmt['plain']}",
          bottomSummaryBanner: "Required Number:  x = $finalAnsPlain",
        ),
      );
    } catch (e) {
      return SumDiffProductResult.error(
        mode: 2,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid numbers or fractions.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: TWO-SIDED EQUATIONS & COMBINED MULTIPLES OF CONSECUTIVE NUMBERS
  // Sub-Modes:
  // 0: Two-Sided Linear Equation: a*x + b = c*x + d
  // 1: Two-Sided Bracketed Equation: k1(x + a) = k2(x + b)
  // 2: Combined Multiples of Consecutive Numbers: a*x + b*(x + 1) = S
  // ===========================================================================
  static SumDiffProductResult solveTwoSidedOrConsecutiveMultiples({
    required int subMode,
    required String input1Str,
    required String input2Str,
    required String input3Str,
    required String input4Str,
  }) {
    try {
      if (subMode == 0 || subMode == 1) {
        final ParsedTerm p1 =
        parseFlexibleTerm(input1Str, fieldName: 'First Parameter');
        final ParsedTerm p2 =
        parseFlexibleTerm(input2Str, fieldName: 'Second Parameter');
        final ParsedTerm p3 =
        parseFlexibleTerm(input3Str, fieldName: 'Third Parameter');
        final ParsedTerm p4 =
        parseFlexibleTerm(input4Str, fieldName: 'Fourth Parameter');

        // Convert both subMode 0 (ax + b = cx + d) and subMode 1 (k1(x + a) = k2(x + b)) into A*x + B = C*x + D
        final double A = p1.value;
        final double B =
        subMode == 0 ? p2.value : (p1.value * p2.value);
        final double C = p3.value;
        final double D =
        subMode == 0 ? p4.value : (p3.value * p4.value);

        if ((A - C).abs() < 1e-12) {
          throw const FormatException(
              "The coefficients of x on both sides are equal, so there is no unique solution for x.");
        }

        final double netXCoeff = A - C;
        final double netConst = D - B;
        final double exactX = netConst / netXCoeff;
        final double evaluatedSide = A * exactX + B;

        String formatLinearLaTeX(double m, double kConst) {
          final String xPart =
          (m - 1.0).abs() < 1e-9 ? 'x' : ((m + 1.0).abs() < 1e-9 ? '-x' : '${fmt(m)}x');
          if (kConst.abs() < 1e-9) return xPart;
          return kConst > 0
              ? '$xPart + ${fmt(kConst)}'
              : '$xPart - ${fmt(kConst.abs())}';
        }

        String formatLinearPlain(double m, double kConst) {
          return formatLinearLaTeX(m, kConst).replaceAll('-', '−');
        }

        final String expandedLhsLaTeX = formatLinearLaTeX(A, B);
        final String expandedRhsLaTeX = formatLinearLaTeX(C, D);
        final String expandedLhsPlain = formatLinearPlain(A, B);
        final String expandedRhsPlain = formatLinearPlain(C, D);

        final String setupEqLaTeX = subMode == 0
            ? "$expandedLhsLaTeX = $expandedRhsLaTeX"
            : "${p1.displayLaTeX}\\left(x ${p2.value >= 0 ? '+ ${p2.displayLaTeX}' : '- ${fmt(p2.value.abs())}'}\\right) = ${p3.displayLaTeX}\\left(x ${p4.value >= 0 ? '+ ${p4.displayLaTeX}' : '- ${fmt(p4.value.abs())}'}\\right)";

        final List<String> step1Lines = [
          "\\text{Let the unknown number be } x.",
          "\\text{Equate the two expressions:}",
          "\\mathbf{$setupEqLaTeX}",
          if (subMode == 1) ...[
            "\\text{Expand the brackets on both sides:}",
            "$expandedLhsLaTeX = $expandedRhsLaTeX",
          ],
        ];

        final List<String> step2Lines = [
          "$expandedLhsLaTeX = $expandedRhsLaTeX",
          "\\text{Collect like terms (${C >= 0 ? 'subtract ${fmt(C)}x from' : 'add ${fmt(C.abs())}x to'} both sides, and move constants to the RHS):}",
          "${fmt(A)}x ${C >= 0 ? '- ${fmt(C)}x' : '+ ${fmt(C.abs())}x'} = ${fmt(D)} ${B >= 0 ? '- ${fmt(B)}' : '+ ${fmt(B.abs())}'}",
          "${fmt(netXCoeff)}x = ${fmt(netConst)}",
          "\\text{Divide both sides by } ${fmt(netXCoeff)}:",
          "x = \\frac{${fmt(netConst)}}{${fmt(netXCoeff)}}",
          "\\therefore \\; \\mathbf{x = ${fmt(exactX)}}",
        ];

        final List<String> step3Lines = [
          "\\bullet \\text{ Check LHS: } ${fmt(A)}(${fmt(exactX)}) ${B >= 0 ? '+ ${fmt(B)}' : '- ${fmt(B.abs())}'} = ${fmt(A * exactX)} ${B >= 0 ? '+ ${fmt(B)}' : '- ${fmt(B.abs())}'} = \\mathbf{${fmt(evaluatedSide)}}",
          "\\bullet \\text{ Check RHS: } ${fmt(C)}(${fmt(exactX)}) ${D >= 0 ? '+ ${fmt(D)}' : '- ${fmt(D.abs())}'} = ${fmt(C * exactX)} ${D >= 0 ? '+ ${fmt(D)}' : '- ${fmt(D.abs())}'} = \\mathbf{${fmt(evaluatedSide)}} \\quad (\\text{LHS} = \\text{RHS Verified!})",
        ];

        final List<String> workings = [
          "\\text{\\textbf{Step 1: Form the Two-Sided Equation}}",
          ...step1Lines,
          "",
          "\\text{\\textbf{Step 2: Collect Like Terms and Solve for }} x",
          ...step2Lines,
          "",
          "\\text{\\textbf{Step 3: Verification Check on Both Sides}}",
          ...step3Lines,
        ];

        final List<SumDiffProductStep> steps = [
          SumDiffProductStep(
            title: "Step 1: Translate Both Expressions and Equate Them",
            description:
            "• Write the first combined expression on the Left-Hand Side (LHS) and the second combined expression on the Right-Hand Side (RHS).\n"
                "${subMode == 1 ? '• Expand the brackets on both sides using the distributive law: $expandedLhsPlain = $expandedRhsPlain.' : '• Equation: $expandedLhsPlain = $expandedRhsPlain.'}",
            mathLinesLaTeX: step1Lines,
          ),
          SumDiffProductStep(
            title: "Step 2: Collect Like Terms on Opposite Sides & Solve for x",
            description:
            "1. Group all x-terms on the Left-Hand Side and all constant numbers on the Right-Hand Side: ${fmt(netXCoeff)}x = ${fmt(netConst)}.\n"
                "2. Divide both sides by ${fmt(netXCoeff)}: x = ${fmt(netConst)} ÷ ${fmt(netXCoeff)} = ${fmt(exactX)}.\n"
                "3. Check: When x = ${fmt(exactX)}, both the LHS and RHS evaluate to ${fmt(evaluatedSide)}!",
            mathLinesLaTeX: [...step2Lines, ...step3Lines],
          ),
        ];

        return SumDiffProductResult(
          mode: 3,
          subMode: subMode,
          finalAnswers: {
            "Two-Sided Equation": "$expandedLhsPlain = $expandedRhsPlain",
            "Required Number (x)": fmt(exactX),
            "Both Sides Equal": fmt(evaluatedSide),
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: SumDiffProductCanvasData(
            visualType: 1,
            lhsPanTitle: "Left-Hand Side (LHS)",
            lhsPanExpr: expandedLhsPlain,
            rhsPanTitle: "Right-Hand Side (RHS)",
            rhsPanExpr: expandedRhsPlain,
            forwardChainText:
            "Collect x-terms:  (${fmt(A)}x − ${fmt(C)}x) = ${fmt(netXCoeff)}x   |   Constants: ${fmt(D)} − (${fmt(B)}) = ${fmt(netConst)}",
            reverseChainText:
            "Solve:  ${fmt(netXCoeff)}x = ${fmt(netConst)}  ➔  x = ${fmt(exactX)}   (Both sides = ${fmt(evaluatedSide)})",
            headerBadge:
            "Two-Sided Balance:  $expandedLhsPlain = $expandedRhsPlain   ➔   x = ${fmt(exactX)}",
            subBadge:
            "${fmt(netXCoeff)}x = ${fmt(netConst)}   ➔   x = ${fmt(exactX)}   |   Check: LHS = RHS = ${fmt(evaluatedSide)}",
            bottomSummaryBanner: "Required Number:  x = ${fmt(exactX)}",
          ),
        );
      } else {
        // Sub-Mode 2: Combined Multiples of Two Consecutive Numbers: a*x + b*(x + 1) = S
        final ParsedTerm a =
        parseFlexibleTerm(input1Str, fieldName: '1st Multiplier (a)');
        final ParsedTerm b =
        parseFlexibleTerm(input2Str, fieldName: '2nd Multiplier (b)');
        final ParsedTerm s =
        parseFlexibleTerm(input3Str, fieldName: 'Total Sum (S)');

        final double sumCoeffs = a.value + b.value;
        if (sumCoeffs.abs() < 1e-12) {
          throw const FormatException(
              "The sum of the two multipliers cannot be zero.");
        }

        final double rhsAfterSub = s.value - b.value;
        final double firstNum = rhsAfterSub / sumCoeffs;
        final double secondNum = firstNum + 1.0;

        final List<String> step1Lines = [
          "\\text{Let the two consecutive numbers be } x \\text{ and } (x + 1).",
          "\\bullet \\text{ ${a.displayLaTeX} times the first number} = ${a.displayLaTeX}x",
          "\\bullet \\text{ ${b.displayLaTeX} times the second number} = ${b.displayLaTeX}(x + 1)",
          "\\text{Their sum is } ${s.displayLaTeX}:",
          "\\mathbf{${a.displayLaTeX}x + ${b.displayLaTeX}(x + 1) = ${s.displayLaTeX}}",
        ];

        final List<String> step2Lines = [
          "${a.displayLaTeX}x + ${b.displayLaTeX}(x + 1) = ${s.displayLaTeX}",
          "\\text{Expand the bracket } ${b.displayLaTeX}(x + 1):",
          "${a.displayLaTeX}x + ${b.displayLaTeX}x + ${b.displayLaTeX} = ${s.displayLaTeX}",
          "\\text{Collect like terms in } x:",
          "${fmt(sumCoeffs)}x + ${b.displayLaTeX} = ${s.displayLaTeX}",
          "\\text{Subtract } ${b.displayLaTeX} \\text{ from both sides:}",
          "${fmt(sumCoeffs)}x = ${s.displayLaTeX} - ${b.displayLaTeX}",
          "${fmt(sumCoeffs)}x = ${fmt(rhsAfterSub)}",
          "\\text{Divide both sides by } ${fmt(sumCoeffs)}:",
          "x = \\frac{${fmt(rhsAfterSub)}}{${fmt(sumCoeffs)}} = \\mathbf{${fmt(firstNum)}}",
        ];

        final List<String> step3Lines = [
          "\\bullet \\text{ 1st Number } (x) = \\mathbf{${fmt(firstNum)}}",
          "\\bullet \\text{ 2nd Consecutive Number } (x + 1) = ${fmt(firstNum)} + 1 = \\mathbf{${fmt(secondNum)}}",
          "\\text{Check: } (${a.displayLaTeX} \\times ${fmt(firstNum)}) + (${b.displayLaTeX} \\times ${fmt(secondNum)}) = ${fmt(a.value * firstNum)} + ${fmt(b.value * secondNum)} = \\mathbf{${s.displayLaTeX}} \\quad (\\text{Verified!})",
        ];

        final List<String> workings = [
          "\\text{\\textbf{Step 1: Represent the Consecutive Numbers and Form the Equation}}",
          ...step1Lines,
          "",
          "\\text{\\textbf{Step 2: Expand Brackets and Solve for }} x",
          ...step2Lines,
          "",
          "\\text{\\textbf{Step 3: Find Both Consecutive Numbers and Verify}}",
          ...step3Lines,
        ];

        final List<SumDiffProductStep> steps = [
          SumDiffProductStep(
            title: "Step 1: Represent the Two Consecutive Numbers as x and (x + 1)",
            description:
            "• Let the first number be x, so the next consecutive number is (x + 1).\n"
                "• Multiplying the first by ${a.displayPlain} gives ${a.displayPlain}x, and multiplying the second by ${b.displayPlain} gives ${b.displayPlain}(x + 1).\n"
                "• Adding them gives: ${a.displayPlain}x + ${b.displayPlain}(x + 1) = ${s.displayPlain}.",
            mathLinesLaTeX: step1Lines,
          ),
          SumDiffProductStep(
            title: "Step 2: Expand the Bracket, Collect Like Terms & Find Both Numbers",
            description:
            "1. Expand ${b.displayPlain}(x + 1) = ${b.displayPlain}x + ${b.displayPlain}.\n"
                "2. Add like terms: ${a.displayPlain}x + ${b.displayPlain}x = ${fmt(sumCoeffs)}x.\n"
                "3. Subtract ${b.displayPlain} from both sides: ${fmt(sumCoeffs)}x = ${fmt(rhsAfterSub)} → x = ${fmt(firstNum)}.\n"
                "4. The two consecutive numbers are ${fmt(firstNum)} and ${fmt(secondNum)}!",
            mathLinesLaTeX: [...step2Lines, ...step3Lines],
          ),
        ];

        return SumDiffProductResult(
          mode: 3,
          subMode: 2,
          finalAnswers: {
            "Equation": "${a.displayPlain}x + ${b.displayPlain}(x + 1) = ${s.displayPlain}",
            "1st Number (x)": fmt(firstNum),
            "2nd Number (x + 1)": fmt(secondNum),
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: SumDiffProductCanvasData(
            visualType: 1,
            lhsPanTitle: "Left-Hand Side (LHS)",
            lhsPanExpr: "${a.displayPlain}x + ${b.displayPlain}(x + 1)",
            rhsPanTitle: "Right-Hand Side (RHS)",
            rhsPanExpr: s.displayPlain,
            forwardChainText:
            "Expand & Group:  ${a.displayPlain}x + ${b.displayPlain}x + ${b.displayPlain} = ${fmt(sumCoeffs)}x + ${b.displayPlain} = ${s.displayPlain}",
            reverseChainText:
            "Solve:  ${fmt(sumCoeffs)}x = ${fmt(rhsAfterSub)}  ➔  x = ${fmt(firstNum)},  x + 1 = ${fmt(secondNum)}",
            headerBadge:
            "${a.displayPlain}x + ${b.displayPlain}(x + 1) = ${s.displayPlain}   ➔   Numbers are ${fmt(firstNum)} and ${fmt(secondNum)}",
            subBadge:
            "${fmt(sumCoeffs)}x + ${b.displayPlain} = ${s.displayPlain}   ➔   ${fmt(sumCoeffs)}x = ${fmt(rhsAfterSub)}   ➔   x = ${fmt(firstNum)}",
            bottomSummaryBanner:
            "The Consecutive Numbers Are ${fmt(firstNum)} and ${fmt(secondNum)}",
          ),
        );
      }
    } catch (e) {
      return SumDiffProductResult.error(
        mode: 3,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid numbers in all fields.",
      );
    }
  }
}