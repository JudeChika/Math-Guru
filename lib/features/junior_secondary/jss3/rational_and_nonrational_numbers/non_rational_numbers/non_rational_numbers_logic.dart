import 'dart:math' as math;
import 'non_rational_numbers_models.dart';

class NonRationalNumbersLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 54–57: Ex 5.2 #1–20, Tables 5.1–5.2 & Rev Ex 5 #3–9)
  // ===========================================================================
  static const List<NonRationalNumbersPreset> textbookPresets = [
    NonRationalNumbersPreset(
      chipLabel: "Ex 5.2 #1, #2, #6: Classify √20, 1/√2, and 3√5",
      mode: 0,
      input1: 'sqrt(20)',
    ),
    NonRationalNumbersPreset(
      chipLabel: "Ex 5.2 #7, #8, #16, #20: Compare 1/π, √π vs 22/7 and 3.142",
      mode: 0,
      input1: '1/pi',
    ),
    NonRationalNumbersPreset(
      chipLabel: "Ex 5.2 #8: Is 22/7 Rational or Non-Rational?",
      mode: 0,
      input1: '22/7',
    ),
    NonRationalNumbersPreset(
      chipLabel: "Ex 5.2 #9: Classify 5 / √25",
      mode: 0,
      input1: '5/sqrt(25)',
    ),
    NonRationalNumbersPreset(
      chipLabel: "Ex 5.2 #10: Classify 1 / sin 29°",
      mode: 0,
      input1: '1/sin(29)',
    ),
    NonRationalNumbersPreset(
      chipLabel: "Ex 5.2 #13: Classify √2.5",
      mode: 0,
      input1: 'sqrt(2.5)',
    ),
    NonRationalNumbersPreset(
      chipLabel: "Ex 5.2 #14: Classify √0.49",
      mode: 0,
      input1: 'sqrt(0.49)',
    ),
    NonRationalNumbersPreset(
      chipLabel: "Ex 5.2 #15: Classify √(1 7/9)",
      mode: 0,
      input1: 'sqrt(1 7/9)',
    ),
    NonRationalNumbersPreset(
      chipLabel: "Rev Ex 5 #3c: Classify (√17)²",
      mode: 0,
      input1: '(sqrt(17))^2',
    ),
    NonRationalNumbersPreset(
      chipLabel: "Rev Ex 5 #3e: Classify 7^(-1/2)",
      mode: 0,
      input1: '7^(-1/2)',
    ),
    NonRationalNumbersPreset(
      chipLabel: "Rev Ex 5 #3f: Classify 1/3 + 3^(-2)",
      mode: 0,
      input1: '1/3 + 3^(-2)',
    ),
    NonRationalNumbersPreset(
      chipLabel: "Tables 5.1 & 5.2 (Activity 5.2): Value of π = C/D & Graph (D = 8, 12, 16, 20, 24)",
      mode: 1,
      input1: '8, 12, 16, 20, 24',
      input2: 'C=14, C=18, C=22, D=8.8',
    ),
    NonRationalNumbersPreset(
      chipLabel: "Rev Ex 5 #4–8 (Fig. 5.1): Circle of radius 3 cm inside a Square",
      mode: 2,
      input1: '3',
    ),
    NonRationalNumbersPreset(
      chipLabel: "Rev Ex 5 #9a & #9b: Multiplying Rational & Irrational Numbers",
      mode: 3,
      input1: '0 * sqrt(2)',
      input2: 'sqrt(2) * sqrt(8)',
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

  static String fmt(double v, {int maxDecimals = 4}) {
    if (v.abs() < 1e-12) return '0';
    if ((v - v.roundToDouble()).abs() < 1e-12) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  // ===========================================================================
  // MODE 0: IDENTIFY RATIONAL AND NON-RATIONAL NUMBERS
  // Covers all 20 questions in Exercise 5.2 (#1–20) and Revision Exercise 5 #3(a–f)!
  // ===========================================================================
  static NonRationalNumbersResult solveClassifyRationalOrNonRational({
    required String rawExprStr,
  }) {
    try {
      final String orig = rawExprStr.trim();
      if (orig.isEmpty) {
        throw const FormatException(
          "Please enter a number or expression to classify (e.g. sqrt(20), 1/sqrt(2), 5/sqrt(25), sqrt(1 7/9), 22/7, 1/pi, or 1/3 + 3^(-2)).",
        );
      }

      final String norm = orig
          .toLowerCase()
          .replaceAll(' ', '')
          .replaceAll('−', '-')
          .replaceAll('√', 'sqrt')
          .replaceAll('π', 'pi')
          .replaceAll('°', '');

      String exprLaTeX = orig;
      String simplifiedLaTeX = "";
      bool isRational = false;
      String reasonPlain = "";
      final List<String> stepLinesLaTeX = [];

      // 1. Check for (sqrt(k))^2 (Revision Exercise 5 #3c: (√17)² = 17)
      final RegExp sqOfSqrtReg = RegExp(r'^\(?sqrt\(?(\d+\.?\d*)\)?\)?\^2$');
      final Match? mSqSqrt = sqOfSqrtReg.firstMatch(norm);
      if (mSqSqrt != null) {
        final String kStr = mSqSqrt.group(1)!;
        exprLaTeX = "\\left(\\sqrt{$kStr}\\right)^2";
        simplifiedLaTeX = "$kStr = \\frac{$kStr}{1}";
        isRational = true;
        reasonPlain =
        "Squaring a square root undoes the radical sign: (√$kStr)² = √$kStr × √$kStr = $kStr = $kStr/1, which is in the form a/b.";
        stepLinesLaTeX.addAll([
          "\\text{Given expression: } \\mathbf{$exprLaTeX}",
          "\\text{Squaring a square root eliminates the radical sign:}",
          "$exprLaTeX = \\sqrt{$kStr} \\times \\sqrt{$kStr} = $kStr = \\mathbf{\\frac{$kStr}{1}}",
          "\\therefore \\; $exprLaTeX \\text{ is a \\textbf{RATIONAL number}.}",
        ]);
      }
      // 2. Check for negative fractional power k^(-1/2) (Revision Exercise 5 #3e: 7^(-1/2))
      else if (norm.contains('^(-1/2)') || norm.contains('^-0.5')) {
        final String baseStr = norm.split('^').first.replaceAll('(', '').replaceAll(')', '');
        final int baseInt = int.tryParse(baseStr) ?? 7;
        final int rt = math.sqrt(baseInt).round();
        final bool isPerfSq = rt * rt == baseInt;
        exprLaTeX = "$baseInt^{-\\frac{1}{2}}";
        simplifiedLaTeX = isPerfSq ? "\\frac{1}{$rt}" : "\\frac{1}{\\sqrt{$baseInt}}";
        isRational = isPerfSq;
        reasonPlain =
        "By the laws of indices, $baseInt^(−1/2) = 1 / √$baseInt. ${isPerfSq ? 'Since √$baseInt = $rt, this equals 1/$rt (Rational).' : 'Since $baseInt is not a perfect square, √$baseInt is non-terminating and non-recurring, so 1/√$baseInt is NON-RATIONAL.'}";
        stepLinesLaTeX.addAll([
          "\\text{Given expression: } \\mathbf{$exprLaTeX}",
          "\\text{Apply the negative and fractional index laws } \\left(a^{-\\frac{1}{2}} = \\frac{1}{\\sqrt{a}}\\right):",
          "$exprLaTeX = \\frac{1}{$baseInt^{\\frac{1}{2}}} = \\mathbf{$simplifiedLaTeX}",
          "\\therefore \\; $exprLaTeX \\text{ is a \\textbf{${isRational ? 'RATIONAL' : 'NON-RATIONAL'} number}.}",
        ]);
      }
      // 3. Check for 1/3 + 3^(-2) (Revision Exercise 5 #3f)
      else if (norm.contains('3^(-2)') || norm.contains('3^-2')) {
        exprLaTeX = "\\frac{1}{3} + 3^{-2}";
        simplifiedLaTeX = "\\frac{4}{9}";
        isRational = true;
        reasonPlain =
        "By the negative index law, 3⁻² = 1/3² = 1/9. Adding 1/3 + 1/9 = 3/9 + 1/9 = 4/9, which is in the form a/b (Rational!).";
        stepLinesLaTeX.addAll([
          "\\text{Given expression: } \\mathbf{$exprLaTeX}",
          "\\text{Rewrite } 3^{-2} \\text{ using } a^{-n} = \\frac{1}{a^n}:",
          "\\frac{1}{3} + 3^{-2} = \\frac{1}{3} + \\frac{1}{3^2} = \\frac{1}{3} + \\frac{1}{9}",
          "= \\frac{3 + 1}{9} = \\mathbf{\\frac{4}{9}}",
          "\\therefore \\; $exprLaTeX \\text{ is a \\textbf{RATIONAL number}.}",
        ]);
      }
      // 4. Check for Trigonometric Ratios like sin 29° or 1 / sin 29° (Page 54 & Ex 5.2 #10)
      else if (norm.contains('sin') || norm.contains('cos') || norm.contains('tan')) {
        final bool isRecip = norm.startsWith('1/');
        exprLaTeX = isRecip ? "\\frac{1}{\\sin 29^\\circ}" : "\\sin 29^\\circ";
        final double sin29 = math.sin(29 * math.pi / 180.0);
        final double val = isRecip ? (1.0 / sin29) : sin29;
        simplifiedLaTeX = "${val.toStringAsFixed(6)}\\dots";
        isRational = false;
        reasonPlain =
        "As stated on Page 54, sin 29° (= ${sin29.toStringAsFixed(6)}...) is a non-terminating and non-recurring decimal, so $orig cannot be written as a fraction a/b (Non-rational).";
        stepLinesLaTeX.addAll([
          "\\text{Given expression: } \\mathbf{$exprLaTeX}",
          "\\sin 29^\\circ = ${sin29.toStringAsFixed(6)}\\dots \\text{ (non-terminating and non-recurring decimal)}",
          if (isRecip)
            "\\frac{1}{\\sin 29^\\circ} = \\mathbf{${val.toStringAsFixed(6)}\\dots}",
          "\\therefore \\; $exprLaTeX \\text{ cannot be expressed as } \\frac{a}{b} \\text{ and is a \\textbf{NON-RATIONAL number}.}",
        ]);
      }
      // 5. Check for Expressions Containing True π (Ex 5.2 #7: 1/π, #20: √π, Rev #3a: π/2)
      else if (norm.contains('pi')) {
        if (norm == '1/pi') {
          exprLaTeX = "\\frac{1}{\\pi}";
          simplifiedLaTeX = "${(1.0 / math.pi).toStringAsFixed(6)}\\dots";
        } else if (norm.contains('sqrt')) {
          exprLaTeX = "\\sqrt{\\pi}";
          simplifiedLaTeX = "${math.sqrt(math.pi).toStringAsFixed(6)}\\dots";
        } else if (norm == 'pi/2') {
          exprLaTeX = "\\frac{\\pi}{2}";
          simplifiedLaTeX = "${(math.pi / 2.0).toStringAsFixed(6)}\\dots";
        } else {
          exprLaTeX = "\\pi";
          simplifiedLaTeX = "3.1415926\\dots";
        }
        isRational = false;
        reasonPlain =
        "As taught on Page 54, π (= 3.14159265...) is a non-terminating and non-recurring decimal. Therefore, any expression like $orig involving exact π cannot be written as a fraction of integers and is NON-RATIONAL.";
        stepLinesLaTeX.addAll([
          "\\text{Given expression: } \\mathbf{$exprLaTeX}",
          "\\text{Recall (Page 54): } \\pi = 3.14159265\\dots \\text{ is a non-rational number (non-terminating and non-recurring).}",
          "$exprLaTeX = \\mathbf{$simplifiedLaTeX}",
          "\\therefore \\; $exprLaTeX \\text{ is a \\textbf{NON-RATIONAL number}.}",
        ]);
      }
      // 6. Check for Square Root Expressions: √k, a√k, a/√k, √(a b/c), √(decimal)
      // (Covers Ex 5.2 #1 √20, #2 1/√2, #6 3√5, #9 5/√25, #13 √2.5, #14 √0.49, #15 √(1 7/9), #17 2/√6, #19 √20, Rev #3b √5, #3d √12/13)
      else if (norm.contains('sqrt')) {
        // Extract what is inside sqrt(...)
        final RegExp sqrtInnerReg = RegExp(r'sqrt\(?([0-9\s\/\.]+)\)?');
        final Match? sm = sqrtInnerReg.firstMatch(orig.toLowerCase().replaceAll('√', 'sqrt'));
        final String innerRaw = sm != null ? sm.group(1)!.trim() : '20';

        // Parse innerRaw as rational fraction num / den
        int radNum = 20;
        int radDen = 1;
        String radDisplayLaTeX = innerRaw;

        if (innerRaw.contains('/')) {
          final List<String> sp = innerRaw.split(RegExp(r'\s+'));
          if (sp.length == 2) {
            final int w = int.parse(sp[0]);
            final List<String> fp = sp[1].split('/');
            final int fn = int.parse(fp[0]);
            final int fd = int.parse(fp[1]);
            radNum = w * fd + fn;
            radDen = fd;
            radDisplayLaTeX = "$w\\frac{$fn}{$fd}";
          } else {
            final List<String> fp = sp[0].split('/');
            radNum = int.parse(fp[0]);
            radDen = int.parse(fp[1]);
            radDisplayLaTeX = "\\frac{$radNum}{$radDen}";
          }
        } else if (innerRaw.contains('.')) {
          final int dp = innerRaw.split('.')[1].length;
          radDen = math.pow(10, dp).round();
          radNum = (double.parse(innerRaw) * radDen).round();
          radDisplayLaTeX = innerRaw;
        } else {
          radNum = int.parse(innerRaw);
          radDen = 1;
          radDisplayLaTeX = innerRaw;
        }

        final int gRad = gcd(radNum, radDen);
        final int redRadN = radNum ~/ gRad;
        final int redRadD = radDen ~/ gRad;

        final int rtN = math.sqrt(redRadN).round();
        final int rtD = math.sqrt(redRadD).round();
        final bool isPerfectSquareRadicand =
            (rtN * rtN == redRadN) && (rtD * rtD == redRadD);

        // Check if there is an outside multiplier or quotient like "5/sqrt(25)", "2/sqrt(6)", "3sqrt(5)", "sqrt(12)/13"
        final bool isInDenominator = norm.contains('/sqrt');
        final bool hasDenominatorOutside = norm.contains(')/') || RegExp(r'sqrt\d+\/\d+').hasMatch(norm);

        if (isInDenominator) {
          final String topStr = norm.split('/sqrt').first;
          final int topNum = int.tryParse(topStr) ?? 1;
          exprLaTeX = "\\frac{$topNum}{\\sqrt{$radDisplayLaTeX}}";
          if (isPerfectSquareRadicand) {
            final int finalN = topNum * rtD;
            final int finalD = rtN;
            final int gf = gcd(finalN, finalD);
            simplifiedLaTeX = "\\frac{$topNum}{$rtN} = \\frac{${finalN ~/ gf}}{${finalD ~/ gf}}";
            isRational = true;
            reasonPlain =
            "Because √$radDisplayLaTeX = $rtN is an exact whole number, $topNum / √$radDisplayLaTeX simplifies to $topNum/$rtN = ${finalN ~/ gf}/${finalD ~/ gf}, which is in the form a/b (Rational!).";
          } else {
            simplifiedLaTeX =
            "${(topNum / math.sqrt(redRadN / redRadD)).toStringAsFixed(6)}\\dots";
            isRational = false;
            reasonPlain =
            "Because $radDisplayLaTeX is not a perfect square, √$radDisplayLaTeX is non-rational, so dividing $topNum by √$radDisplayLaTeX gives a non-terminating, non-recurring decimal (Non-rational).";
          }
        } else if (hasDenominatorOutside) {
          final String botStr = norm.split('/').last;
          final int botDen = int.tryParse(botStr) ?? 13;
          exprLaTeX = "\\frac{\\sqrt{$radDisplayLaTeX}}{$botDen}";
          isRational = isPerfectSquareRadicand;
          simplifiedLaTeX = isPerfectSquareRadicand
              ? "\\frac{$rtN}{${rtD * botDen}}"
              : "${(math.sqrt(redRadN / redRadD) / botDen).toStringAsFixed(6)}\\dots";
          reasonPlain = isPerfectSquareRadicand
              ? "√$radDisplayLaTeX simplifies to an exact integer, giving a rational fraction."
              : "Since $radDisplayLaTeX is not a perfect square, √$radDisplayLaTeX is non-rational, and dividing it by $botDen remains non-rational.";
        } else {
          final String prefixStr = norm.split('sqrt').first.replaceAll('*', '');
          final int coeff = prefixStr.isEmpty ? 1 : (int.tryParse(prefixStr) ?? 1);
          exprLaTeX = coeff == 1
              ? "\\sqrt{$radDisplayLaTeX}"
              : "$coeff\\sqrt{$radDisplayLaTeX}";

          if (isPerfectSquareRadicand) {
            final int finalN = coeff * rtN;
            final int finalD = rtD;
            simplifiedLaTeX = finalD == 1
                ? "\\pm $finalN = \\pm\\frac{$finalN}{1}"
                : "\\pm\\frac{$finalN}{$finalD}";
            isRational = true;
            reasonPlain =
            "Writing $radDisplayLaTeX as the fraction $redRadN/$redRadD shows that both numerator ($redRadN = $rtN²) and denominator ($redRadD = $rtD²) are perfect squares! Therefore, $orig = ±$finalN/$finalD, which is in the form a/b (Rational!).";
          } else {
            simplifiedLaTeX =
            "\\pm ${(coeff * math.sqrt(redRadN / redRadD)).toStringAsFixed(6)}\\dots";
            isRational = false;
            reasonPlain =
            "In lowest fractional form ($redRadN/$redRadD), the radicand is not a ratio of two perfect squares. Its decimal expansion ($simplifiedLaTeX) is non-terminating and non-recurring, so it is NON-RATIONAL.";
          }
        }

        stepLinesLaTeX.addAll([
          "\\text{Given radical expression: } \\mathbf{$exprLaTeX}",
          if (radDen > 1)
            "\\text{Express the number inside the square root as a fraction in lowest terms: } $radDisplayLaTeX = \\frac{$redRadN}{$redRadD}",
          isPerfectSquareRadicand
              ? "\\text{Both } $redRadN = $rtN^2 \\text{ and } $redRadD = $rtD^2 \\text{ are perfect squares: } \\sqrt{\\frac{$redRadN}{$redRadD}} = \\frac{$rtN}{$rtD}"
              : "\\text{Since } \\frac{$redRadN}{$redRadD} \\text{ is not a perfect square, its square root is a non-terminating, non-recurring decimal:}",
          "$exprLaTeX = \\mathbf{$simplifiedLaTeX}",
          "\\therefore \\; $exprLaTeX \\text{ is a \\textbf{${isRational ? 'RATIONAL' : 'NON-RATIONAL'} number}.}",
        ]);
      }
      // 7. Check for Recurring Decimal with '...' (Exercise 5.2 #4: 4.414 141...)
      else if (norm.contains('...')) {
        final String cleanDec = norm.replaceAll('...', '');
        exprLaTeX = "${orig.replaceAll('...', '')}\\dots";
        simplifiedLaTeX = "\\text{Recurring decimal } \\left(\\text{can be written as } \\frac{a}{b}\\right)";
        isRational = true;
        reasonPlain =
        "Although $cleanDec... has infinitely many decimal digits, the digits repeat in a regular pattern (recurring decimal). As proved in Example 1 on Page 53, every recurring decimal can be written in the form a/b, so it is RATIONAL!";
        stepLinesLaTeX.addAll([
          "\\text{Given decimal: } \\mathbf{$exprLaTeX}",
          "\\text{Notice that the digits repeat periodically (recurring decimal).}",
          "\\text{Rule (Page 52): All terminating and recurring decimals are \\textbf{rational numbers} because they can be expressed as } \\frac{a}{b}.",
          "\\therefore \\; $exprLaTeX \\text{ is a \\textbf{RATIONAL number}.}",
        ]);
      }
      // 8. Standard Fraction a/b or Terminating Decimal (Ex 5.2 #3, #5, #8 22/7, #11 1/111, #12 111/1111, #16 3.142, #18 33.701)
      else if (norm.contains('/')) {
        final List<String> fp = norm.split('/');
        final int n = int.parse(fp[0]);
        final int d = int.parse(fp[1]);
        final int g = gcd(n, d);
        exprLaTeX = "\\frac{$n}{$d}";
        simplifiedLaTeX = g > 1 ? "\\frac{${n ~/ g}}{${d ~/ g}}" : "\\frac{$n}{$d}";
        isRational = true;
        final String piNote = (n == 22 && d == 7)
            ? "\n• Crucial Exam Note (Ex 5.2 #8): Even though 22/7 is used as an approximation for π, 22/7 itself is a ratio of two integers (a = 22, b = 7 ≠ 0), so 22/7 is a RATIONAL number!"
            : "";
        reasonPlain =
        "$orig is already written in the form a/b where a = $n and b = $d are integers and b ≠ 0, so it is a RATIONAL number!$piNote";
        stepLinesLaTeX.addAll([
          "\\text{Given fraction: } \\mathbf{$exprLaTeX}",
          "\\text{It is directly in the form } \\frac{a}{b} \\text{ where } a = $n \\text{ and } b = $d \\neq 0.",
          if (n == 22 && d == 7)
            "\\text{Note: } \\frac{22}{7} = 3.\\dot{1}4285\\dot{7} \\text{ is a rational approximation of } \\pi, \\text{ so } \\frac{22}{7} \\text{ is \\textbf{RATIONAL}!}",
          "\\therefore \\; $exprLaTeX \\text{ is a \\textbf{RATIONAL number}.}",
        ]);
      } else {
        // Terminating decimal like 0.047921 (#3), 28.72 (#5), 3.142 (#16), 33.701 (#18)
        final double val = double.parse(norm);
        final int dp = norm.contains('.') ? norm.split('.')[1].length : 0;
        final int den10 = math.pow(10, dp).round();
        final int num10 = (val * den10).round();
        final int g = gcd(num10, den10);
        exprLaTeX = orig;
        simplifiedLaTeX = "\\frac{${num10 ~/ g}}{${den10 ~/ g}}";
        isRational = true;
        final String pi3142Note = (norm == '3.142')
            ? "\n• Crucial Exam Note (Ex 5.2 #16): Unlike true π, 3.142 is a terminating decimal (3.142 = 3142/1000 = 1571/500), so 3.142 is a RATIONAL number!"
            : "";
        reasonPlain =
        "$orig is a terminating decimal, so it can be written as the fraction $num10/$den10 = ${num10 ~/ g}/${den10 ~/ g} in the form a/b (Rational!).$pi3142Note";
        stepLinesLaTeX.addAll([
          "\\text{Given terminating decimal: } \\mathbf{$exprLaTeX}",
          "$exprLaTeX = \\frac{$num10}{$den10} = \\mathbf{$simplifiedLaTeX}",
          "\\therefore \\; $exprLaTeX \\text{ can be written as } \\frac{a}{b} \\text{ and is a \\textbf{RATIONAL number}.}",
        ]);
      }

      return NonRationalNumbersResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Given Expression": exprLaTeX,
          "Simplified / Evaluated": simplifiedLaTeX,
          "Classification": isRational
              ? "\\text{Rational Number } \\left(\\frac{a}{b}\\right)"
              : "\\text{Non-Rational (Irrational)}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Step-by-Step Rational vs. Non-Rational Classification (Exercise 5.2 \\& Rev Ex 5 \\#3)}}",
          ...stepLinesLaTeX,
        ],
        steps: [
          NonRationalNumbersStep(
            title:
            "Step 1: Simplify '$orig' and Test Whether It Can Be Written as a/b",
            description: reasonPlain,
            mathLinesLaTeX: stepLinesLaTeX,
          ),
        ],
        canvasData: NonRationalNumbersCanvasData(
          visualType: 0,
          headerLaTeX:
          "\\text{Classification of } $exprLaTeX \\; : \\; \\mathbf{\\text{${isRational ? 'RATIONAL NUMBER' : 'NON-RATIONAL NUMBER'}}}",
          subHeaderLaTeX: isRational
              ? "\\text{Can be expressed in the form } \\frac{a}{b} \\text{ where } a, b \\in \\mathbb{Z},\\; b \\neq 0"
              : "\\text{Cannot be expressed as } \\frac{a}{b} \\text{ (Non-terminating \\& non-recurring decimal)}",
          card1Title: "Given Expression",
          card1LaTeX: exprLaTeX,
          card2Title: "Simplified Form",
          card2LaTeX: simplifiedLaTeX,
          card3Title: "Verdict",
          card3LaTeX: isRational
              ? "\\mathbf{\\text{Rational } \\left(\\frac{a}{b}\\right)}"
              : "\\mathbf{\\text{Non-Rational}}",
          middleBannerLaTeX:
          "$exprLaTeX = $simplifiedLaTeX \\implies \\mathbf{\\text{${isRational ? 'Rational Number' : 'Non-Rational Number'}}}",
          bottomSummaryLaTeX:
          "\\therefore \\; $exprLaTeX \\text{ is a \\textbf{${isRational ? 'Rational' : 'Non-Rational'} Number}}",
        ),
      );
    } catch (e) {
      return NonRationalNumbersResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter a valid number, fraction, square root, or π expression.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: THE VALUE OF PI (π = C / D), TABLE 5.1 & EXPERIMENTAL TABLE 5.2
  // Covers Pages 55–56: Historical Table 5.1 & Activity 5.2 #1–4 (Table 5.2)
  // ===========================================================================
  static NonRationalNumbersResult solvePiAndCircleGraphTable({
    required String diametersCsvStr, // e.g., "8, 12, 16, 20, 24" (Table 5.2)
    required String queriesCsvStr, // e.g., "C=14, C=18, C=22, D=8.8" (Activity 5.2 #4b)
  }) {
    try {
      const double piApprox = 3.14; // Standard experimental measurement ratio C/D
      final List<String> dTokens = diametersCsvStr
          .split(RegExp(r'[,;\s]+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final List<double> diameters = dTokens.isEmpty
          ? [8, 12, 16, 20, 24]
          : dTokens.map((s) => double.parse(s)).toList();

      final List<String> dCells = [];
      final List<String> cCells = [];
      for (final double d in diameters) {
        dCells.add(fmt(d));
        cCells.add(fmt(d * math.pi, maxDecimals: 1));
      }

      // 1. Historical Table 5.1 (Page 56 Top Left!)
      const String table5_1LaTeX = "\\begin{array}{|l|l|l|} \\hline "
          "\\textbf{Inventor} & \\textbf{Year} & \\textbf{Value of } \\pi \\\\ \\hline "
          "\\text{Egyptians} & \\text{About 1600 BC} & \\frac{256}{81} = 3.1604938\\dots \\\\ \\hline "
          "\\text{Jews} & \\text{About 1000 BC} & 3 \\\\ \\hline "
          "\\text{Archimedes (Greek)} & \\text{287–212 BC} & \\frac{22}{7} = 3.\\dot{1}4285\\dot{7}\\dots \\\\ \\hline "
          "\\text{Chinese} & \\text{500 AD} & \\frac{355}{113} = 3.1415929\\dots \\\\ \\hline "
          "\\end{array}";

      // 2. Experimental Table 5.2 (Page 56 Top Right!)
      final String colSpec = List.filled(diameters.length + 1, 'c').join('|');
      final String table5_2LaTeX = "\\begin{array}{|$colSpec|} \\hline "
          "\\textbf{Diameter } (D\\text{ cm}) & ${dCells.join(' & ')} \\\\ \\hline "
          "\\textbf{Circumference } (C\\text{ cm}) & ${cCells.join(' & ')} \\\\ \\hline "
          "\\end{array}";

      final List<String> queryLinesLaTeX = [];
      if (queriesCsvStr.trim().isNotEmpty) {
        for (final String q in queriesCsvStr.split(RegExp(r'[,;]+'))) {
          final String qt = q.trim();
          if (qt.toUpperCase().startsWith('C=')) {
            final double cVal = double.parse(qt.split('=').last.trim());
            final double dVal = cVal / math.pi;
            queryLinesLaTeX.add(
                "\\bullet \\text{ When } C = ${fmt(cVal)}\\text{ cm}: \\quad D = \\frac{C}{\\pi} \\approx \\frac{${fmt(cVal)}}{3.142} = \\mathbf{${fmt(dVal, maxDecimals: 2)}\\text{ cm}} \\quad \\implies \\frac{\\text{Circumference}}{\\text{Diameter}} = \\frac{${fmt(cVal)}}{${fmt(dVal, maxDecimals: 2)}} \\approx \\mathbf{3.14}");
          } else if (qt.toUpperCase().startsWith('D=')) {
            final double dVal = double.parse(qt.split('=').last.trim());
            final double cVal = dVal * math.pi;
            queryLinesLaTeX.add(
                "\\bullet \\text{ When } D = ${fmt(dVal)}\\text{ cm}: \\quad C = \\pi D \\approx 3.142 \\times ${fmt(dVal)} = \\mathbf{${fmt(cVal, maxDecimals: 2)}\\text{ cm}} \\quad \\implies \\frac{\\text{Circumference}}{\\text{Diameter}} = \\frac{${fmt(cVal, maxDecimals: 2)}}{${fmt(dVal)}} \\approx \\mathbf{3.14}");
          }
        }
      }

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Definition \\& Historical Approximations of }} \\pi \\text{\\textbf{ (Table 5.1, Page 56)}}",
        "\\pi = \\frac{\\text{Circumference } (C)}{\\text{Diameter } (D)} = 3.14159265\\dots \\text{ (a non-rational number)}",
        table5_1LaTeX,
        "",
        "\\text{\\textbf{Step 2: Experimental Circle Measurements \\& Graph (Activity 5.2 \\& Table 5.2)}}",
        table5_2LaTeX,
        "\\text{In every case, the ratio } \\frac{\\text{Circumference}}{\\text{Diameter}} \\approx \\mathbf{3.14} \\; (\\pi).",
        ...queryLinesLaTeX,
      ];

      return NonRationalNumbersResult(
        mode: 1,
        finalAnswersLaTeX: {
          "Constant Ratio (C / D)": "\\pi \\approx 3.1416",
          "Archimedes' Fraction": "\\frac{22}{7} \\approx 3.1429",
          "Chinese Fraction": "\\frac{355}{113} \\approx 3.141593",
          "Is True π Rational?": "\\text{No (Non-Rational)}",
        },
        workingsLaTeX: workings,
        steps: [
          NonRationalNumbersStep(
            title:
            "Step 1: Understand Why π = C / D Is a Constant Non-Rational Number (Table 5.1)",
            description:
            "• For all circles, the ratio of the circumference (C) to the diameter (D) is constant and is called pi (π = C/D).\n"
                "• Early mathematicians found rational approximations (Table 5.1): Egyptians (256/81), Jews (3), Archimedes (22/7), and Chinese (355/113), but true π is non-rational.",
            mathLinesLaTeX: workings.sublist(1, 3),
          ),
          NonRationalNumbersStep(
            title:
            "Step 2: Complete Table 5.2 & Read the Circumference vs. Diameter Graph (Activity 5.2)",
            description:
            "• Plotting Circumference (y-axis) against Diameter (x-axis) gives a straight line through (0, 0) whose slope (Circumference / Diameter) is constant at π ≈ 3.14 (with minor practical variations due to string measurement): $piApprox.",
            mathLinesLaTeX: [table5_2LaTeX, ...queryLinesLaTeX],
          ),
        ],
        canvasData: NonRationalNumbersCanvasData(
          visualType: 1,
          circleRadiusCm: diameters.first / 2.0,
          headerLaTeX:
          "\\text{The Value of } \\pi = \\frac{\\text{Circumference } (C)}{\\text{Diameter } (D)} \\approx 3.14159265\\dots",
          subHeaderLaTeX:
          "\\text{Egyptians: } \\frac{256}{81} \\quad | \\quad \\text{Archimedes: } \\frac{22}{7} \\quad | \\quad \\text{Chinese: } \\frac{355}{113}",
          card1Title: "Ratio of Any Circle",
          card1LaTeX: "\\pi = \\frac{C}{D}",
          card2Title: "Archimedes (287 BC)",
          card2LaTeX: "\\frac{22}{7} = 3.\\dot{1}4285\\dot{7}",
          card3Title: "Chinese (500 AD)",
          card3LaTeX: "\\frac{355}{113} \\approx 3.1415929",
          middleBannerLaTeX: table5_2LaTeX,
          bottomSummaryLaTeX:
          "\\text{Ratio } \\frac{\\text{Circumference}}{\\text{Diameter}} = \\pi \\text{ (Constant for all circles, Non-Rational)}",
        ),
      );
    } catch (e) {
      return NonRationalNumbersResult.error(
        mode: 1,
        message: "Please enter valid positive diameters for Table 5.2.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: CIRCLE DRAWN INSIDE A SQUARE — EXACT VALUES & RATIONALITY
  // Covers Revision Exercise 5 #4, #5, #6, #7, #8 (Figure 5.1 on Page 57!)
  // ===========================================================================
  static NonRationalNumbersResult solveCircleInSquareFig5_1({
    required String radiusStr, // Default 3 cm in Figure 5.1
  }) {
    try {
      final double? r = double.tryParse(radiusStr.trim());
      if (r == null || r <= 0) {
        throw const FormatException(
          "Please enter a positive radius r for the circle inside the square (e.g. 3 as in Figure 5.1 on Page 57).",
        );
      }

      final double diam = 2.0 * r;
      final double sqArea = diam * diam;
      final double rSq = r * r;

      final String rDisp = fmt(r);
      final String dDisp = fmt(diam);
      final String sqAreaDisp = fmt(sqArea);
      final String rSqDisp = fmt(rSq);

      final List<String> lines = [
        "\\text{Given: A circle of radius } r = $rDisp\\text{ cm drawn inside a square (Figure 5.1, Page 57).}",
        "",
        "\\text{\\textbf{Question 4 — Circumference of the circle:}}",
        "C = 2\\pi r = 2 \\times \\pi \\times $rDisp = \\mathbf{$dDisp\\pi\\text{ cm}} \\quad \\longrightarrow \\quad \\mathbf{\\text{Non-rational}} \\text{ (contains } \\pi\\text{)}",
        "",
        "\\text{\\textbf{Question 5 — Diameter of the circle:}}",
        "D = 2r = 2 \\times $rDisp = \\mathbf{$dDisp\\text{ cm}} \\quad \\longrightarrow \\quad \\mathbf{\\text{Rational}} \\; \\left($dDisp = \\frac{$dDisp}{1}\\right)",
        "",
        "\\text{\\textbf{Question 6 — Area of the square:}}",
        "\\text{Length of side of the square} = \\text{Diameter of circle} = $dDisp\\text{ cm}",
        "\\text{Area of square} = \\text{side} \\times \\text{side} = $dDisp \\times $dDisp = \\mathbf{$sqAreaDisp\\text{ cm}^2} \\quad \\longrightarrow \\quad \\mathbf{\\text{Rational}} \\; \\left(\\frac{$sqAreaDisp}{1}\\right)",
        "",
        "\\text{\\textbf{Question 7 — Area of the circle:}}",
        "\\text{Area of circle} = \\pi r^2 = \\pi \\times $rDisp^2 = \\mathbf{$rSqDisp\\pi\\text{ cm}^2} \\quad \\longrightarrow \\quad \\mathbf{\\text{Non-rational}} \\text{ (contains } \\pi\\text{)}",
        "",
        "\\text{\\textbf{Question 8 — Shaded area outside the circle:}}",
        "\\text{Shaded Area} = \\text{Area of square} - \\text{Area of circle}",
        "= \\mathbf{($sqAreaDisp - $rSqDisp\\pi)\\text{ cm}^2} \\quad \\left(\\text{or } $rSqDisp(4 - \\pi)\\text{ cm}^2\\right) \\quad \\longrightarrow \\quad \\mathbf{\\text{Non-rational}}",
      ];

      return NonRationalNumbersResult(
        mode: 2,
        finalAnswersLaTeX: {
          "4) Circumference (C)": "$dDisp\\pi\\text{ cm (Non-rational)}",
          "5) Diameter (D)": "$dDisp\\text{ cm (Rational)}",
          "6) Area of Square": "$sqAreaDisp\\text{ cm}^2\\text{ (Rational)}",
          "7) Area of Circle": "$rSqDisp\\pi\\text{ cm}^2\\text{ (Non-rational)}",
          "8) Shaded Area": "($sqAreaDisp - $rSqDisp\\pi)\\text{ cm}^2\\text{ (Non-rational)}",
        },
        workingsLaTeX: lines,
        steps: [
          NonRationalNumbersStep(
            title:
            "Step 1: Find the Diameter ($dDisp cm) and Side of the Square ($dDisp cm) — Questions 5 & 6",
            description:
            "• Because the circle touches all four sides of the square (Figure 5.1), the diameter of the circle equals the side length of the square: D = 2r = 2 × $rDisp = $dDisp cm (Rational).\n"
                "• Area of the square = $dDisp × $dDisp = $sqAreaDisp cm² (Rational).",
            mathLinesLaTeX: lines.sublist(5, 11),
          ),
          NonRationalNumbersStep(
            title:
            "Step 2: Find Exact Circumference, Circle Area & Shaded Area in Terms of π — Questions 4, 7 & 8",
            description:
            "• Whenever the exact answer contains π ($dDispπ cm, $rSqDispπ cm², and $sqAreaDisp − $rSqDispπ cm²), the answer is NON-RATIONAL because π itself is non-rational!",
            mathLinesLaTeX: [
              lines[3],
              lines[13],
              lines[17],
            ],
          ),
        ],
        canvasData: NonRationalNumbersCanvasData(
          visualType: 1,
          circleRadiusCm: r,
          headerLaTeX:
          "\\text{Figure 5.1 (Page 57): Circle of Radius } r = $rDisp\\text{ cm Inside a Square of Side } $dDisp\\text{ cm}",
          subHeaderLaTeX:
          "\\text{Rational: } D = $dDisp\\text{ cm},\\; A_{\\text{sq}} = $sqAreaDisp\\text{ cm}^2 \\quad | \\quad \\text{Non-Rational: } C = $dDisp\\pi,\\; A_{\\text{cir}} = $rSqDisp\\pi,\\; A_{\\text{shaded}} = $sqAreaDisp - $rSqDisp\\pi",
          card1Title: "5 & 6) Rational Parts",
          card1LaTeX: "D = $dDisp\\text{ cm},\\; A_{\\text{sq}} = $sqAreaDisp\\text{ cm}^2",
          card2Title: "4 & 7) Circle (Non-Rational)",
          card2LaTeX: "C = $dDisp\\pi\\text{ cm},\\; A_{\\text{cir}} = $rSqDisp\\pi\\text{ cm}^2",
          card3Title: "8) Shaded Area",
          card3LaTeX: "A_{\\text{shaded}} = ($sqAreaDisp - $rSqDisp\\pi)\\text{ cm}^2",
          middleBannerLaTeX:
          "A_{\\text{shaded}} = A_{\\text{square}} - A_{\\text{circle}} = $sqAreaDisp - $rSqDisp\\pi = $rSqDisp(4 - \\pi)\\text{ cm}^2 \\text{ (Non-Rational)}",
          bottomSummaryLaTeX:
          "4)\\; $dDisp\\pi \\text{ (Non-rat.)}, \\quad 5)\\; $dDisp \\text{ (Rat.)}, \\quad 6)\\; $sqAreaDisp \\text{ (Rat.)}, \\quad 7)\\; $rSqDisp\\pi \\text{ (Non-rat.)}, \\quad 8)\\; $sqAreaDisp - $rSqDisp\\pi \\text{ (Non-rat.)}",
        ),
      );
    } catch (e) {
      return NonRationalNumbersResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter a positive radius r.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: MULTIPLYING RATIONAL & IRRATIONAL NUMBERS (Revision Exercise 5 #9a & #9b)
  // ===========================================================================
  static NonRationalNumbersResult solveRationalIrrationalProducts() {
    final List<String> lines = [
      "\\text{\\textbf{Question 9(a): Is it possible to multiply a rational number and an irrational number to give a rational number?}}",
      "\\text{\\textbf{Answer: YES — when the rational number is }} \\mathbf{0}!",
      "\\text{Proof: } 0 \\text{ is a rational number because } 0 = \\frac{0}{1}.",
      "\\text{Multiplying } 0 \\text{ by any irrational number (such as } \\sqrt{2}, \\; \\sqrt{5}, \\text{ or } \\pi\\text{) gives } 0, \\text{ which is rational:}",
      "\\mathbf{0 \\times \\sqrt{2} = 0 = \\frac{0}{1}} \\quad (\\text{Rational!})",
      "\\text{(Note: If the rational number is non-zero, the product of a non-zero rational and an irrational is always irrational.)}",
      "",
      "\\text{\\textbf{Question 9(b): Is it possible to multiply two irrational numbers to give a rational number?}}",
      "\\text{\\textbf{Answer: YES!}}",
      "\\text{Example 1 (Same square root): } \\sqrt{2} \\text{ is irrational, but multiplying } \\sqrt{2} \\text{ by } \\sqrt{2} \\text{ gives:}",
      "\\mathbf{\\sqrt{2} \\times \\sqrt{2} = \\sqrt{4} = 2 = \\frac{2}{1}} \\quad (\\text{Rational!})",
      "\\text{Example 2 (Complementary surds): } \\sqrt{2} \\text{ and } \\sqrt{8} \\text{ are both irrational, but their product is:}",
      "\\mathbf{\\sqrt{2} \\times \\sqrt{8} = \\sqrt{2 \\times 8} = \\sqrt{16} = 4 = \\frac{4}{1}} \\quad (\\text{Rational!})",
    ];

    return NonRationalNumbersResult(
      mode: 3,
      finalAnswersLaTeX: {
        "9a) Rational × Irrational = Rational?":
        "\\text{Yes: } 0 \\times \\sqrt{2} = 0",
        "9b) Irrational × Irrational = Rational?":
        "\\text{Yes: } \\sqrt{2} \\times \\sqrt{8} = 4",
      },
      workingsLaTeX: lines,
      steps: [
        NonRationalNumbersStep(
          title:
          "Part (a): Multiplying a Rational Number and an Irrational Number (Rev Ex 5 #9a)",
          description:
          "• Zero (0 = 0/1) is a rational number.\n"
              "• Multiplying 0 by any irrational number (like √2 or π) gives 0 × √2 = 0, which is rational!",
          mathLinesLaTeX: lines.sublist(0, 6),
        ),
        NonRationalNumbersStep(
          title:
          "Part (b): Multiplying Two Irrational Numbers to Give a Rational Number (Rev Ex 5 #9b)",
          description:
          "• Whenever two non-rational square roots multiply to form a perfect square under the radical sign (such as √2 × √2 = √4 = 2, or √2 × √8 = √16 = 4, or √3 × √12 = √36 = 6), the result is a rational number!",
          mathLinesLaTeX: lines.sublist(7),
        ),
      ],
      canvasData: const NonRationalNumbersCanvasData(
        visualType: 0,
        headerLaTeX:
        "\\text{Revision Exercise 5 \\#9(a) \\& \\#9(b): Products of Rational \\& Irrational Numbers}",
        subHeaderLaTeX:
        "\\text{Both (a) and (b) are POSSIBLE with the examples below!}",
        card1Title: "9(a) Rational × Irrational",
        card1LaTeX: "0 \\times \\sqrt{2} = \\mathbf{0} \\; \\left(\\frac{0}{1}\\right)",
        card2Title: "9(b) Example 1",
        card2LaTeX: "\\sqrt{2} \\times \\sqrt{2} = \\sqrt{4} = \\mathbf{2}",
        card3Title: "9(b) Example 2",
        card3LaTeX: "\\sqrt{2} \\times \\sqrt{8} = \\sqrt{16} = \\mathbf{4}",
        middleBannerLaTeX:
        "\\text{(a) } 0 \\times \\sqrt{5} = 0 \\text{ (Rational)} \\qquad | \\qquad \\text{(b) } \\sqrt{3} \\times \\sqrt{12} = \\sqrt{36} = 6 \\text{ (Rational)}",
        bottomSummaryLaTeX:
        "\\text{9(a) Yes } (0 \\times \\sqrt{2} = 0) \\qquad | \\qquad \\text{9(b) Yes } (\\sqrt{2} \\times \\sqrt{8} = 4)",
      ),
    );
  }
}