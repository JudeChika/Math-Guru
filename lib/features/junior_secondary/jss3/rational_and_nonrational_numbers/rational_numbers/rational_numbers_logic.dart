import 'dart:math' as math;
import 'rational_numbers_models.dart';

class RationalNumbersLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 52–54 & 56–57: Example 1, Ex 5.1 #1–4 & Rev Ex 5 #1–2)
  // ===========================================================================
  static const List<RationalNumbersPreset> textbookPresets = [
    RationalNumbersPreset(
      chipLabel: "Example 1a (Page 53): Write 0.373 737... (0.3̇7̇) as a rational number",
      mode: 1,
      input1: '0',
      input2: '37',
    ),
    RationalNumbersPreset(
      chipLabel: "Example 1b (Page 53): Write 4.142 142... (4.1̇42̇) as a rational number",
      mode: 1,
      input1: '4',
      input2: '142',
    ),
    RationalNumbersPreset(
      chipLabel: "Ex 5.1 #1a & #1c: Terminating decimal 3.25 in the form a/b",
      mode: 0,
      input1: '3.25',
    ),
    RationalNumbersPreset(
      chipLabel: "Ex 5.1 #1d & #1e: Terminating decimal 0.125 in the form a/b",
      mode: 0,
      input1: '0.125',
    ),
    RationalNumbersPreset(
      chipLabel: "Rev Ex 5 #1b & #1e: Terminating decimal 13.705 in the form x/y",
      mode: 0,
      input1: '13.705',
    ),
    RationalNumbersPreset(
      chipLabel: "Ex 5.1 #3a: Recurring decimal 0.0̇1̇ as a rational number",
      mode: 1,
      input1: '0',
      input2: '01',
    ),
    RationalNumbersPreset(
      chipLabel: "Ex 5.1 #3b: Recurring decimal 5.2̇09̇ as a rational number",
      mode: 1,
      input1: '5',
      input2: '209',
    ),
    RationalNumbersPreset(
      chipLabel: "Ex 5.1 #3c: Recurring decimal 7.2̇4̇ as a rational number",
      mode: 1,
      input1: '7',
      input2: '24',
    ),
    RationalNumbersPreset(
      chipLabel: "Ex 5.1 #3d: Recurring decimal 4.1̇9̇ as a rational number",
      mode: 1,
      input1: '4',
      input2: '19',
    ),
    RationalNumbersPreset(
      chipLabel: "Ex 5.1 #3e: Recurring decimal 1.0̇01̇ as a rational number",
      mode: 1,
      input1: '1',
      input2: '001',
    ),
    RationalNumbersPreset(
      chipLabel: "Ex 5.1 #3f: Recurring decimal 11.1̇ as a rational number",
      mode: 1,
      input1: '11',
      input2: '1',
    ),
    RationalNumbersPreset(
      chipLabel: "Ex 5.1 #2b: Express 1 000 / 99 as a recurring decimal",
      mode: 2,
      input1: '1000/99',
    ),
    RationalNumbersPreset(
      chipLabel: "Ex 5.1 #2d: Express 2 9/25 as a terminating decimal",
      mode: 2,
      input1: '2 9/25',
    ),
    RationalNumbersPreset(
      chipLabel: "Ex 5.1 #2f & #2j: Express 3 4/11 as a recurring decimal",
      mode: 2,
      input1: '3 4/11',
    ),
    RationalNumbersPreset(
      chipLabel: "Ex 5.1 #4h & Rev #2d: Express 1 6/7 as a recurring decimal",
      mode: 2,
      input1: '1 6/7',
    ),
    RationalNumbersPreset(
      chipLabel: "Page 52 Intro: Solve 2x + 5 = 12 & Classify Number Sets",
      mode: 3,
      input1: '3.25',
      input2: '2x + 5 = 12',
    ),
  ];

  // ===========================================================================
  // ARITHMETIC & RECURRING DOT NOTATION HELPERS (Math.tex Safe!)
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

  static String _groupInt(int n) {
    final bool neg = n < 0;
    final String s = n.abs().toString();
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        buf.write('\\,');
      }
      buf.write(s[i]);
    }
    return neg ? '-${buf.toString()}' : buf.toString();
  }

  /// Formats a repeating block of digits using textbook LaTeX dot notation:
  /// - 1 digit ('6') -> `\dot{6}`
  /// - 2 digits ('37') -> `\dot{3}\dot{7}`
  /// - 3+ digits ('142') -> `\dot{1}4\dot{2}` (dots on first and last repeating digit, matching Page 52!)
  static String formatRecurringBlockLaTeX(String repDigits) {
    if (repDigits.isEmpty) return '';
    if (repDigits.length == 1) {
      return '\\dot{${repDigits[0]}}';
    }
    if (repDigits.length == 2) {
      return '\\dot{${repDigits[0]}}\\dot{${repDigits[1]}}';
    }
    final String first = repDigits[0];
    final String middle = repDigits.substring(1, repDigits.length - 1);
    final String last = repDigits[repDigits.length - 1];
    return '\\dot{$first}$middle\\dot{$last}';
  }

  static Map<String, String> formatRational(int num, int den) {
    if (den == 0 || num == 0) {
      return {
        'plain': '0',
        'latex': '0',
        'improperLaTeX': '\\frac{0}{1}',
      };
    }
    final bool isNeg = (num < 0) ^ (den < 0);
    int n = num.abs();
    int d = den.abs();
    final int g = gcd(n, d);
    n ~/= g;
    d ~/= g;
    final String sign = isNeg ? '-' : '';

    final String impTex = '$sign\\frac{${_groupInt(n)}}{${_groupInt(d)}}';
    if (d == 1) {
      return {
        'plain': '$sign$n',
        'latex': '$sign${_groupInt(n)}',
        'improperLaTeX': impTex,
      };
    }
    if (n > d) {
      final int w = n ~/ d;
      final int rem = n % d;
      return {
        'plain': '$sign$w $rem/$d (or $sign$n/$d)',
        'latex': '$impTex \\quad \\left(\\text{or } $sign${_groupInt(w)}\\frac{${_groupInt(rem)}}{${_groupInt(d)}}\\right)',
        'improperLaTeX': impTex,
      };
    }
    return {
      'plain': '$sign$n/$d',
      'latex': impTex,
      'improperLaTeX': impTex,
    };
  }

  // ===========================================================================
  // MODE 0: REWRITE TERMINATING DECIMALS AS RATIONAL NUMBERS IN THE FORM a/b
  // Covers Exercise 5.1 #1(a–e) (Page 53) & Revision Exercise 5 #1(a–j) (Page 56)
  // ===========================================================================
  static RationalNumbersResult solveTerminatingDecimalToRational({
    required String decimalInputStr,
  }) {
    try {
      final String clean = decimalInputStr
          .trim()
          .replaceAll('−', '-')
          .replaceAll(',', '')
          .replaceAll(' ', '');

      if (clean.isEmpty) {
        throw const FormatException(
          "Please enter a terminating decimal (e.g. 0.35, 0.78, 3.25, 9.42, 0.125, or 13.705).",
        );
      }

      final double? val = double.tryParse(clean);
      if (val == null) {
        throw FormatException("Could not read '$decimalInputStr' as a valid decimal number.");
      }

      final bool isNeg = clean.startsWith('-');
      final String absStr = clean.replaceFirst('-', '').replaceFirst('+', '');
      final List<String> parts = absStr.split('.');
      final String intPartStr = parts[0].isEmpty ? '0' : parts[0];
      final String decPartStr = parts.length > 1 ? parts[1] : '';

      final int decPlaces = decPartStr.length;
      if (decPlaces > 7) {
        throw const FormatException("Please enter up to 7 decimal places.");
      }

      final int rawDen10 = math.pow(10, decPlaces).round();
      final int rawNum10 = int.parse('$intPartStr$decPartStr') * (isNeg ? -1 : 1);
      final int hcf = gcd(rawNum10, rawDen10);
      final int redNum = rawNum10 ~/ hcf;
      final int redDen = rawDen10 ~/ hcf;
      final Map<String, String> fmtMap = formatRational(redNum, redDen);

      final String sign = isNeg ? '-' : '';
      final List<String> step1Lines = [
        "\\text{Definition (Page 52): A rational number is a number which can be expressed as } \\frac{a}{b}, \\text{ where } a \\text{ and } b \\text{ are integers and } b \\neq 0.",
        "\\text{Given terminating decimal: } \\mathbf{$clean}",
        if (decPlaces > 0) ...[
          "\\text{Since there ${decPlaces == 1 ? 'is 1 digit' : 'are $decPlaces digits'} after the decimal point, write the number over } 10^{$decPlaces} = ${_groupInt(rawDen10)}:",
          "$clean = $sign\\frac{${_groupInt(rawNum10.abs())}}{${_groupInt(rawDen10)}}",
        ] else
          "$clean = \\frac{${_groupInt(rawNum10)}}{1}",
      ];

      final List<String> step2Lines = [
        if (hcf > 1) ...[
          "\\text{Find the Highest Common Factor (HCF) of } ${_groupInt(rawNum10.abs())} \\text{ and } ${_groupInt(rawDen10)}, \\text{ which is } \\mathbf{${_groupInt(hcf)}}.",
          "\\text{Divide both numerator and denominator by } ${_groupInt(hcf)} \\text{ to reduce to lowest terms:}",
          "$sign\\frac{${_groupInt(rawNum10.abs())} \\div ${_groupInt(hcf)}}{${_groupInt(rawDen10)} \\div ${_groupInt(hcf)}} = \\mathbf{${fmtMap['latex']}}",
        ] else
          "\\text{Since HCF}(${_groupInt(rawNum10.abs())},\\; ${_groupInt(rawDen10)}) = 1, \\text{ the fraction is already in its lowest form: } \\mathbf{${fmtMap['latex']}}",
        "\\therefore \\; $clean = \\mathbf{${fmtMap['improperLaTeX']}} \\quad \\left(\\text{where } a = ${_groupInt(redNum)} \\text{ and } b = ${_groupInt(redDen)}\\right)",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Express the Terminating Decimal Over a Power of 10 (Exercise 5.1 \\#1)}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Step 2: Reduce to Lowest Form }} \\frac{a}{b} \\text{\\textbf{ by Dividing by the HCF}}",
        ...step2Lines,
      ];

      final List<RationalNumbersStep> steps = [
        RationalNumbersStep(
          title:
          "Step 1: Write $clean as an Unsimplified Fraction Over ${rawDen10.toString()}",
          description:
          "• Count the digits after the decimal point ($decPlaces decimal place${decPlaces == 1 ? '' : 's'}).\n"
              "• Place the digits over 10^$decPlaces = $rawDen10 to remove the decimal point: $clean = ${rawNum10}/$rawDen10.",
          mathLinesLaTeX: step1Lines,
        ),
        RationalNumbersStep(
          title:
          "Step 2: Divide Numerator and Denominator by Their HCF ($hcf) for Lowest Form",
          description:
          "• Divide the numerator (${rawNum10.abs()}) and the denominator ($rawDen10) by their Highest Common Factor ($hcf).\n"
              "• In lowest form a/b, $clean = $redNum/$redDen (where a = $redNum and b = $redDen ≠ 0).",
          mathLinesLaTeX: step2Lines,
        ),
      ];

      return RationalNumbersResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Decimal Input": clean,
          "Unsimplified Form": "$sign\\frac{${_groupInt(rawNum10.abs())}}{${_groupInt(rawDen10)}}",
          "HCF": _groupInt(hcf),
          "Lowest Form (a / b)": fmtMap['latex']!,
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: RationalNumbersCanvasData(
          headerLaTeX:
          "\\text{Terminating Decimal to Rational Number: } $clean = \\mathbf{${fmtMap['improperLaTeX']}}",
          subHeaderLaTeX:
          "a = ${_groupInt(redNum)}, \\quad b = ${_groupInt(redDen)} \\neq 0 \\quad \\left(\\text{HCF} = ${_groupInt(hcf)}\\right)",
          card1Title: "1. Over Power of 10",
          card1LaTeX:
          "$clean = $sign\\frac{${_groupInt(rawNum10.abs())}}{${_groupInt(rawDen10)}}",
          card2Title: "2. Divide by HCF ($hcf)",
          card2LaTeX:
          "\\frac{${_groupInt(rawNum10.abs())} \\div ${_groupInt(hcf)}}{${_groupInt(rawDen10)} \\div ${_groupInt(hcf)}}",
          card3Title: "3. Lowest Form (a/b)",
          card3LaTeX: "\\mathbf{${fmtMap['improperLaTeX']}}",
          middleBannerLaTeX:
          "$clean = $sign\\frac{${_groupInt(rawNum10.abs())}}{${_groupInt(rawDen10)}} = \\mathbf{${fmtMap['latex']}}",
          bottomSummaryLaTeX:
          "\\therefore \\; $clean = \\mathbf{${fmtMap['improperLaTeX']}} \\text{ is a rational number}",
        ),
      );
    } catch (e) {
      return RationalNumbersResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter a valid terminating decimal.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: RECURRING DECIMALS TO RATIONAL NUMBERS a/b (Simultaneous Equations (1) & (2))
  // Covers Example 1a (0.373 737...), Example 1b (4.142 142...) & Exercise 5.1 #3(a–f)
  // ===========================================================================
  static RationalNumbersResult solveRecurringDecimalToRational({
    required String nonRecurringPartStr, // e.g., "0", "4", "5", "7", "11", or "0.1"
    required String recurringBlockStr, // e.g., "37", "142", "01", "209", "24", "1"
  }) {
    try {
      String basePart = nonRecurringPartStr.trim().replaceAll(' ', '');
      String repBlock = recurringBlockStr
          .trim()
          .replaceAll('.', '')
          .replaceAll(' ', '');

      // Allow user to type a full dot/ellipsis string in the first box if they leave the second box blank!
      if (repBlock.isEmpty && basePart.contains('.')) {
        final List<String> dotSplit = basePart.replaceAll('...', '').split('.');
        basePart = dotSplit[0].isEmpty ? '0' : dotSplit[0];
        repBlock = dotSplit[1];
      }

      if (basePart.isEmpty) basePart = '0';
      if (repBlock.isEmpty || !RegExp(r'^\d+$').hasMatch(repBlock)) {
        throw const FormatException(
          "Please enter the repeating block of digits (e.g. '37' for 0.3̇7̇ or '142' for 4.1̇42̇).",
        );
      }
      if (repBlock.length > 5) {
        throw const FormatException(
            "Please enter a repeating block of up to 5 digits.");
      }

      final bool isNeg = basePart.startsWith('-');
      final String absBase = basePart.replaceFirst('-', '').replaceFirst('+', '');
      final List<String> baseSplit = absBase.split('.');
      final int wholePart =
      baseSplit[0].isEmpty ? 0 : int.parse(baseSplit[0]);
      final String nonRepDec = baseSplit.length > 1 ? baseSplit[1] : '';

      final int mNonRep = nonRepDec.length; // 0 for pure recurring decimals (all of Example 1 & Ex 5.1 #3!)
      final int kRep = repBlock.length; // Number of repeating digits (1 -> 10, 2 -> 100, 3 -> 1,000)

      final String sign = isNeg ? '-' : '';
      final String dotNotationLaTeX =
          "$sign$wholePart.$nonRepDec${formatRecurringBlockLaTeX(repBlock)}";
      final String expandedRepeat =
          "$sign$wholePart.$nonRepDec$repBlock\\,$repBlock\\,${repBlock.substring(0, math.min(2, repBlock.length))}\\dots";

      final int mult1 = math.pow(10, mNonRep).round(); // 1 when mNonRep == 0
      final int mult2 = math.pow(10, mNonRep + kRep).round(); // 10, 100, or 1,000
      final int lhsCoeffDiff = mult2 - mult1; // 9, 99, or 999

      final int intBeforeRep = int.parse('$wholePart$nonRepDec');
      final int intWithOneRep = int.parse('$wholePart$nonRepDec$repBlock');
      final int rhsIntDiff = intWithOneRep - intBeforeRep;
      final int signedNum = isNeg ? -rhsIntDiff : rhsIntDiff;

      final int hcf = gcd(signedNum, lhsCoeffDiff);
      final int redNum = signedNum ~/ hcf;
      final int redDen = lhsCoeffDiff ~/ hcf;
      final Map<String, String> finalFmt = formatRational(redNum, redDen);

      // Replicate Example 1a & 1b on Page 53 Word-for-Word!
      final String shiftedStr2 =
          "$sign${_groupInt(intWithOneRep)}.$repBlock\\,$repBlock\\dots";
      final String shiftedStr1 = mNonRep == 0
          ? expandedRepeat
          : "$sign${_groupInt(intBeforeRep)}.$repBlock\\,$repBlock\\dots";

      final List<String> step1Lines = [
        "\\text{Given recurring decimal: } $expandedRepeat \\quad \\left(\\text{i.e. } \\mathbf{$dotNotationLaTeX}\\right)",
        "\\text{Let } x = $expandedRepeat \\qquad \\text{--- (1)}",
        if (mNonRep > 0)
          "\\text{Multiply equation (1) by } $mult1: \\quad ${mult1}x = $shiftedStr1 \\qquad \\text{--- (1a)}",
        "\\text{Since there ${kRep == 1 ? 'is 1 recurring digit' : 'are $kRep recurring digits'}, multiply both sides of equation (1) by } ${_groupInt(mult2)}:",
        "${_groupInt(mult2)}x = $shiftedStr2 \\qquad \\text{--- (2)}",
      ];

      final List<String> step2Lines = [
        "\\text{Subtract equation ${mNonRep > 0 ? '(1a)' : '(1)'} from equation (2) so the recurring decimal tail cancels out:}",
        "\\left(${_groupInt(mult2)}x - ${mult1 == 1 ? 'x' : '${_groupInt(mult1)}x'}\\right) = $shiftedStr2 - \\left($shiftedStr1\\right)",
        "${_groupInt(lhsCoeffDiff)}x = $sign${_groupInt(rhsIntDiff)}",
        "\\text{Divide both sides by } ${_groupInt(lhsCoeffDiff)}:",
        "x = $sign\\frac{${_groupInt(rhsIntDiff)}}{${_groupInt(lhsCoeffDiff)}}",
        if (hcf > 1) ...[
          "\\text{Simplify by dividing numerator and denominator by their HCF } (${_groupInt(hcf)}):",
          "x = $sign\\frac{${_groupInt(rhsIntDiff)} \\div ${_groupInt(hcf)}}{${_groupInt(lhsCoeffDiff)} \\div ${_groupInt(hcf)}} = \\mathbf{${finalFmt['latex']}}",
        ],
        "\\text{So, } $dotNotationLaTeX = \\mathbf{${finalFmt['latex']}}, \\text{ which is a rational number.}",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Form Equations (1) and (2) (Example 1 Method, Page 53)}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Step 2: Subtract Equation (1) from Equation (2) and Solve for }} x",
        ...step2Lines,
      ];

      final List<RationalNumbersStep> steps = [
        RationalNumbersStep(
          title:
          "Step 1: Let x Equal the Recurring Decimal & Multiply by ${_groupInt(mult2).replaceAll('\\,', ',')} (Example 1)",
          description:
          "• Note from Page 52: A recurring decimal can be expressed with a dot over the first and last recurring digits.\n"
              "• Let x equal the recurring decimal — Equation (1).\n"
              "• Because $kRep digit${kRep == 1 ? '' : 's'} ('$repBlock') repeat continuously, multiply both sides of Equation (1) by 10^$kRep = ${mult2.toString()} to form Equation (2).",
          mathLinesLaTeX: step1Lines,
        ),
        RationalNumbersStep(
          title:
          "Step 2: Subtract Equation (1) from Equation (2) to Eliminate the Infinite Tail",
          description:
          "1. Subtracting Equation (1) from Equation (2) cancels the infinite repeating decimal part completely, leaving ${lhsCoeffDiff}x = $signedNum.\n"
              "2. Divide both sides by $lhsCoeffDiff: x = $signedNum/$lhsCoeffDiff${hcf > 1 ? ' = $redNum/$redDen (in lowest terms)' : ''}.\n"
              "3. Since it is written in the form a/b where b ≠ 0, it is a rational number!",
          mathLinesLaTeX: step2Lines,
        ),
      ];

      return RationalNumbersResult(
        mode: 1,
        finalAnswersLaTeX: {
          "Dot Notation": dotNotationLaTeX,
          "Equation (2) − (1)": "${_groupInt(lhsCoeffDiff)}x = $sign${_groupInt(rhsIntDiff)}",
          "Rational Form (a / b)": finalFmt['latex']!,
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: RationalNumbersCanvasData(
          headerLaTeX:
          "\\text{Example 1 Recurring Decimal to Fraction: } $dotNotationLaTeX = \\mathbf{${finalFmt['improperLaTeX']}}",
          subHeaderLaTeX:
          "\\text{Multiply by } 10^$kRep = ${_groupInt(mult2)} \\text{ and subtract to cancel the repeating tail}",
          card1Title: "Equation (1)",
          card1LaTeX: "x = $dotNotationLaTeX",
          card2Title: "Equation (2) (× $mult2)",
          card2LaTeX: "${_groupInt(mult2)}x = $sign${_groupInt(intWithOneRep)}.\\dot{${repBlock[0]}}\\dots",
          card3Title: "Subtract (2) − (1)",
          card3LaTeX:
          "${_groupInt(lhsCoeffDiff)}x = $sign${_groupInt(rhsIntDiff)} \\implies x = \\mathbf{${finalFmt['improperLaTeX']}}",
          middleBannerLaTeX:
          "${_groupInt(mult2)}x - ${mult1 == 1 ? 'x' : '${_groupInt(mult1)}x'} = ${_groupInt(lhsCoeffDiff)}x = $sign${_groupInt(rhsIntDiff)} \\implies x = $sign\\frac{${_groupInt(rhsIntDiff)}}{${_groupInt(lhsCoeffDiff)}} = \\mathbf{${finalFmt['latex']}}",
          bottomSummaryLaTeX:
          "\\therefore \\; $dotNotationLaTeX = \\mathbf{${finalFmt['improperLaTeX']}} \\text{ (Rational Number)}",
        ),
      );
    } catch (e) {
      return RationalNumbersResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid digits for the recurring decimal.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: EXPRESS FRACTIONS a/b AS TERMINATING OR RECURRING DECIMALS
  // Covers Exercise 5.1 #2(a–j), #4(a–j) (Pages 53–54) & Revision Exercise 5 #2(a–d) (Page 57)
  // ===========================================================================
  static RationalNumbersResult solveFractionToDecimalClassification({
    required String fractionInputStr,
  }) {
    try {
      String s = fractionInputStr
          .trim()
          .replaceAll('−', '-')
          .replaceAll(',', '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      if (!s.contains('/')) {
        throw const FormatException(
          "Please enter a fraction or mixed number containing '/' (e.g. 20/3, 1000/99, 2 9/25, 17/6, 3 4/11, or 1 6/7).",
        );
      }

      bool isNeg = false;
      int rawNum = 0;
      int rawDen = 1;
      String inputLaTeX = "";

      final List<String> parts = s.split(' ');
      if (parts.length == 2) {
        isNeg = parts[0].startsWith('-');
        final int wAbs =
        int.parse(parts[0].replaceAll('-', '').replaceAll('+', ''));
        final List<String> fp = parts[1].split('/');
        final int fN = int.parse(fp[0]);
        final int fD = int.parse(fp[1]);
        if (fD <= 0) {
          throw const FormatException("Denominator must be greater than zero.");
        }
        rawNum = wAbs * fD + fN;
        rawDen = fD;
        inputLaTeX = "${isNeg ? '-' : ''}$wAbs\\frac{$fN}{$fD}";
      } else {
        final List<String> fp = parts[0].split('/');
        final int fN = int.parse(fp[0]);
        final int fD = int.parse(fp[1]);
        if (fD == 0) {
          throw const FormatException("Denominator cannot be zero.");
        }
        isNeg = (fN < 0) ^ (fD < 0);
        rawNum = fN.abs();
        rawDen = fD.abs();
        inputLaTeX = "${isNeg ? '-' : ''}\\frac{${_groupInt(rawNum)}}{${_groupInt(rawDen)}}";
      }

      final int g = gcd(rawNum, rawDen);
      final int redN = rawNum ~/ g;
      final int redD = rawDen ~/ g;
      final String sign = isNeg ? '-' : '';

      // Check prime factors of reduced denominator redD to prove why it terminates vs. recurs!
      int tempD = redD;
      int count2 = 0;
      int count5 = 0;
      while (tempD > 0 && tempD % 2 == 0) {
        count2++;
        tempD ~/= 2;
      }
      while (tempD > 0 && tempD % 5 == 0) {
        count5++;
        tempD ~/= 5;
      }
      final bool isTerminating = (tempD == 1);

      // Perform exact remainder-tracking long division of redN ÷ redD!
      final int intQuot = redN ~/ redD;
      int rem = redN % redD;

      final List<int> decDigits = [];
      final Map<int, int> remToIndex = {};
      final List<String> divStepsLaTeX = [];
      final List<String> divStepsPlain = [];
      int repeatStartIdx = -1;

      divStepsLaTeX.add(
          "\\bullet \\text{ Whole-number part: } ${_groupInt(redN)} \\div ${_groupInt(redD)} = \\mathbf{$intQuot} \\text{ remainder } $rem");
      divStepsPlain.add(
          "• Whole-number division: $redN ÷ $redD = $intQuot remainder $rem.");

      int stepIdx = 0;
      while (rem != 0 && stepIdx < 24) {
        if (remToIndex.containsKey(rem)) {
          repeatStartIdx = remToIndex[rem]!;
          divStepsLaTeX.add(
              "\\bullet \\text{ Remainder } \\mathbf{$rem} \\text{ repeats the remainder from decimal place ${repeatStartIdx + 1}! Thus the digits repeat endlessly from here.}");
          divStepsPlain.add(
              "• Remainder $rem has appeared before (at decimal place ${repeatStartIdx + 1}), so the decimal digits now repeat in a cycle!");
          break;
        }
        remToIndex[rem] = stepIdx;
        final int dividend = rem * 10;
        final int d = dividend ~/ redD;
        final int nextRem = dividend % redD;
        decDigits.add(d);

        if (stepIdx < 8) {
          divStepsLaTeX.add(
              "\\bullet \\text{ Place ${stepIdx + 1}: } $dividend \\div $redD = \\mathbf{$d} \\text{ remainder } $nextRem");
          divStepsPlain.add(
              "• Decimal place ${stepIdx + 1}: $dividend ÷ $redD = $d remainder $nextRem.");
        }
        rem = nextRem;
        stepIdx++;
      }

      String finalDecimalLaTeX = "";
      String expandedDecimalLaTeX = "";
      String classificationText = "";

      if (rem == 0) {
        final String decStr =
        decDigits.isEmpty ? '0' : decDigits.join('');
        finalDecimalLaTeX =
        decDigits.isEmpty ? '$sign$intQuot' : '$sign$intQuot.$decStr';
        expandedDecimalLaTeX = finalDecimalLaTeX;
        classificationText = "Terminating Decimal (Rational)";
      } else if (repeatStartIdx != -1) {
        final String nonRepPart =
        decDigits.sublist(0, repeatStartIdx).join('');
        final String repPart =
        decDigits.sublist(repeatStartIdx).join('');
        final String dotPart = formatRecurringBlockLaTeX(repPart);
        finalDecimalLaTeX = '$sign$intQuot.$nonRepPart$dotPart';
        expandedDecimalLaTeX =
        '$sign$intQuot.$nonRepPart$repPart\\,$repPart\\dots';
        classificationText =
        "Recurring Decimal — Cycle '$repPart' of length ${repPart.length} (Rational)";
      } else {
        final String decStr = decDigits.join('');
        finalDecimalLaTeX = '$sign$intQuot.$decStr\\dots';
        expandedDecimalLaTeX = finalDecimalLaTeX;
        classificationText = "Recurring Decimal (Rational)";
      }

      final List<String> step1Lines = [
        "\\text{Given fraction: } \\mathbf{$inputLaTeX}"
            "${parts.length == 2 || g > 1 ? ' = \\mathbf{$sign\\frac{${_groupInt(redN)}}{${_groupInt(redD)}}}' : ''}",
        isTerminating
            ? "\\text{Denominator Check: In lowest terms, the denominator } $redD \\text{ has only prime factors of } 2 \\text{ and/or } 5 \\; (2^{$count2} \\times 5^{$count5}), \\text{ so the decimal \\textbf{terminates}!}"
            : "\\text{Denominator Check: In lowest terms, the denominator } $redD \\text{ has prime factor(s) other than } 2 \\text{ and } 5 \\text{ (factor } $tempD\\text{), so the decimal is \\textbf{non-terminating but recurring}!}",
      ];

      final List<String> step2Lines = [
        ...divStepsLaTeX,
        if (!isTerminating)
          "\\text{Expanded repeating decimal: } $inputLaTeX = $expandedDecimalLaTeX",
        "\\therefore \\; $inputLaTeX = \\mathbf{$finalDecimalLaTeX} \\quad \\left(\\text{\\textbf{${isTerminating ? 'Terminating Decimal' : 'Recurring Decimal'}}} \\implies \\text{Rational Number}\\right)",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Simplify the Fraction \\& Inspect the Denominator (Exercise 5.1 \\#2 \\& \\#4)}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Step 2: Divide Numerator by Denominator \\& Write with Dot Notation}}",
        ...step2Lines,
      ];

      final List<RationalNumbersStep> steps = [
        RationalNumbersStep(
          title:
          "Step 1: Convert to Improper Fraction ($redN/$redD) & Check Denominator Prime Factors",
          description: isTerminating
              ? "• In lowest terms, the denominator is $redD, whose prime factors consist only of 2s and/or 5s. Therefore, the division will reach a remainder of 0 and produce a TERMINATING decimal."
              : "• In lowest terms, the denominator is $redD, which contains the factor $tempD (not 2 or 5). Therefore, the remainders will eventually repeat in a cycle and produce a RECURRING decimal.",
          mathLinesLaTeX: step1Lines,
        ),
        RationalNumbersStep(
          title:
          "Step 2: Perform Long Division ($redN ÷ $redD) & Apply Dot Notation",
          description:
          "${divStepsPlain.join('\n')}\n\n"
              "• Classification: $classificationText.",
          mathLinesLaTeX: step2Lines,
        ),
      ];

      return RationalNumbersResult(
        mode: 2,
        finalAnswersLaTeX: {
          "Given Fraction": inputLaTeX,
          "Decimal Form": finalDecimalLaTeX,
          "Type of Decimal": isTerminating
              ? "\\text{Terminating Decimal}"
              : "\\text{Recurring Decimal}",
          "Rational or Non-Rational?": "\\text{Rational Number}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: RationalNumbersCanvasData(
          headerLaTeX:
          "\\text{Fraction to Decimal: } $inputLaTeX = \\mathbf{$finalDecimalLaTeX}",
          subHeaderLaTeX: isTerminating
              ? "\\text{Remainder reaches } 0 \\implies \\text{\\textbf{Terminating Decimal (Rational)}}"
              : "\\text{Remainder repeats in a cycle} \\implies \\text{\\textbf{Recurring Decimal (Rational)}}",
          card1Title: "Fraction (a / b)",
          card1LaTeX: "$sign\\frac{${_groupInt(redN)}}{${_groupInt(redD)}}",
          card2Title: "Decimal Expansion",
          card2LaTeX: expandedDecimalLaTeX,
          card3Title: "Dot Notation & Type",
          card3LaTeX: "\\mathbf{$finalDecimalLaTeX}",
          middleBannerLaTeX:
          "$inputLaTeX = $expandedDecimalLaTeX = \\mathbf{$finalDecimalLaTeX}",
          bottomSummaryLaTeX:
          "\\therefore \\; $inputLaTeX = \\mathbf{$finalDecimalLaTeX} \\text{ (${isTerminating ? 'Terminating' : 'Recurring'} Rational Number)}",
        ),
      );
    } catch (e) {
      return RationalNumbersResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter a valid fraction or mixed number (e.g. 20/3, 1000/99, or 2 9/25).",
      );
    }
  }

  // ===========================================================================
  // MODE 3: NUMBER SET HIERARCHY & LINEAR EQUATION MOTIVATOR (Page 52)
  // Classifies any number into Natural, Whole, Integer, and Rational sets!
  // ===========================================================================
  static RationalNumbersResult solveHierarchyAndEquation({
    required String numberToClassifyStr,
    required String linearEquationStr, // e.g., "2x + 5 = 12"
  }) {
    try {
      final RationalNumbersResult decRes =
      solveTerminatingDecimalToRational(decimalInputStr: numberToClassifyStr);
      if (!decRes.valid) return decRes;

      final double val = double.parse(
          numberToClassifyStr.trim().replaceAll('−', '-').replaceAll(',', ''));
      final bool isInt = (val - val.roundToDouble()).abs() < 1e-9;
      final int intVal = val.round();

      final bool isNatural = isInt && intVal >= 1;
      final bool isWhole = isInt && intVal >= 0;
      final bool isInteger = isInt;
      const bool isRational = true;

      final String lowestFracLaTeX =
          decRes.finalAnswersLaTeX["Lowest Form (a / b)"] ?? "$val";

      final List<String> lines = [
        "\\text{\\textbf{1. Hierarchy of Number Sets (Page 52):}}",
        "\\bullet \\text{ \\textbf{Natural Numbers} (Counting numbers } 1, 2, 3, 4, \\dots\\text{): } \\mathbf{\\text{${isNatural ? 'YES' : 'NO'}}}",
        "\\bullet \\text{ \\textbf{Whole Numbers} (Natural numbers and } 0: \\; 0, 1, 2, 3, \\dots\\text{): } \\mathbf{\\text{${isWhole ? 'YES' : 'NO'}}}",
        "\\bullet \\text{ \\textbf{Integers} (Positive and negative whole numbers } \\dots, -2, -1, 0, 1, 2, \\dots\\text{): } \\mathbf{\\text{${isInteger ? 'YES' : 'NO'}}}"
            "${isInteger ? ' \\quad \\left($intVal = \\frac{$intVal}{1}\\right)' : ''}",
        "\\bullet \\text{ \\textbf{Rational Numbers} (Numbers of the form } \\frac{a}{b}, \\; b \\neq 0\\text{): } \\mathbf{\\text{YES}} \\quad \\left(${numberToClassifyStr.trim()} = $lowestFracLaTeX\\right)",
        "",
        "\\text{\\textbf{2. Why Rational Numbers Were Invented (Page 52 Bottom):}}",
        "\\text{The need to provide solutions to linear equations of the form } 2x + 5 = 12 \\text{ led to the invention of rational numbers:}",
        "2x + 5 = 12 \\implies 2x = 12 - 5 = 7 \\implies x = \\mathbf{\\frac{7}{2}} = \\mathbf{3\\frac{1}{2}} \\; (3.5)",
      ];

      return RationalNumbersResult(
        mode: 3,
        finalAnswersLaTeX: {
          "Natural Number?": isNatural ? "\\text{Yes}" : "\\text{No}",
          "Whole Number?": isWhole ? "\\text{Yes}" : "\\text{No}",
          "Integer?": isInteger ? "\\text{Yes } \\left(\\frac{$intVal}{1}\\right)" : "\\text{No}",
          "Rational Number (a/b)?": "\\text{Yes } ($lowestFracLaTeX)",
        },
        workingsLaTeX: lines,
        steps: [
          RationalNumbersStep(
            title:
            "Step 1: Classify ${numberToClassifyStr.trim()} Across the 4 Number Sets (Page 52)",
            description:
            "• Natural numbers: 1, 2, 3, 4, …\n"
                "• Whole numbers: 0, 1, 2, 3, 4, …\n"
                "• Integers: …, −3, −2, −1, 0, 1, 2, 3, … (Every integer k is a rational number k/1).\n"
                "• Rational numbers: All numbers that can be written as a/b where a and b are integers and b ≠ 0.",
            mathLinesLaTeX: lines,
          ),
        ],
        canvasData: RationalNumbersCanvasData(
          headerLaTeX:
          "\\text{Page 52 Number Set Hierarchy: } \\mathbb{N} \\subset \\mathbb{W} \\subset \\mathbb{Z} \\subset \\mathbb{Q}",
          subHeaderLaTeX:
          "${numberToClassifyStr.trim()} = $lowestFracLaTeX \\in \\text{Rational Numbers } \\left(\\frac{a}{b},\\; b \\neq 0\\right)",
          card1Title: "Natural / Whole",
          card1LaTeX:
          "\\text{Natural: ${isNatural ? 'Yes' : 'No'}} \\; | \\; \\text{Whole: ${isWhole ? 'Yes' : 'No'}}",
          card2Title: "Integer (b = 1)",
          card2LaTeX: isInteger
              ? "\\text{Yes: } $intVal = \\frac{$intVal}{1}"
              : "\\text{No (Fractional)}",
          card3Title: "Rational (a / b)",
          card3LaTeX: "\\text{Yes: } $lowestFracLaTeX",
          middleBannerLaTeX:
          "2x + 5 = 12 \\implies 2x = 7 \\implies x = \\frac{7}{2} = 3\\frac{1}{2} \\text{ (Rational Number)}",
          bottomSummaryLaTeX:
          "\\text{All integers, terminating decimals, and recurring decimals are Rational Numbers}",
        ),
      );
    } catch (e) {
      return RationalNumbersResult.error(
        mode: 3,
        message: "Please enter a valid number to classify.",
      );
    }
  }
}