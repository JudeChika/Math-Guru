import 'dart:math' as math;
import 'binary_to_base10_models.dart';

class BinaryToBase10Logic {
  // ===========================================================================
  // 14 TEXTBOOK PRESETS (Pages 8–9: Examples 1–3, Exercise 1.1 & Exercise 1.2)
  // ===========================================================================
  static const List<BinaryToBase10Preset> textbookPresets = [
    BinaryToBase10Preset(
      chipLabel: "Ex 2a: Convert 1 011₂ to Base 10",
      mode: 0,
      input1: '1 011',
    ),
    BinaryToBase10Preset(
      chipLabel: "Ex 2b: Convert Bicimal 1 101.110₂ to Base 10",
      mode: 0,
      input1: '1 101.110',
    ),
    BinaryToBase10Preset(
      chipLabel: "Ex 1.2 #1i: Convert 101.11₂ to Base 10",
      mode: 0,
      input1: '101.11',
    ),
    BinaryToBase10Preset(
      chipLabel: "Ex 1.2 #1j: Convert 0.10101₂ to Base 10",
      mode: 0,
      input1: '0.10101',
    ),
    BinaryToBase10Preset(
      chipLabel: "Ex 1.2 #1l: Convert 0.00011₂ to Base 10",
      mode: 0,
      input1: '0.00011',
    ),
    BinaryToBase10Preset(
      chipLabel: "Ex 1a: Expand 110 001₂ in Powers of 2",
      mode: 1,
      input1: '110 001',
      baseInt: 2,
    ),
    BinaryToBase10Preset(
      chipLabel: "Ex 1b: Expand 432₅ in Powers of 5",
      mode: 1,
      input1: '432',
      baseInt: 5,
    ),
    BinaryToBase10Preset(
      chipLabel: "Ex 1.1 #5: Expand 321 011₄ in Powers of 4",
      mode: 1,
      input1: '321 011',
      baseInt: 4,
    ),
    BinaryToBase10Preset(
      chipLabel: "Ex 1.1 #16: Expand 124₁₆ in Powers of 16",
      mode: 1,
      input1: '124',
      baseInt: 16,
    ),
    BinaryToBase10Preset(
      chipLabel: "Ex 3a: Square Root √(100 100₂)",
      mode: 2,
      input1: '100 100',
    ),
    BinaryToBase10Preset(
      chipLabel: "Ex 3b: Square Root √(1 010 001₂)",
      mode: 2,
      input1: '1 010 001',
    ),
    BinaryToBase10Preset(
      chipLabel: "Ex 1.2 #4e: Fractional Root √(0.0001₂)",
      mode: 2,
      input1: '0.0001',
    ),
    BinaryToBase10Preset(
      chipLabel: "Ex 1.2 #2: Add 110 011₂, 101.11₂ & 1 111₂ in Base 10",
      mode: 3,
      subMode: 1,
      input1: '110 011',
      input2: '101.11',
      input3: '1 111',
    ),
    BinaryToBase10Preset(
      chipLabel: "Ex 1.2 #3d: Evaluate (1.1₂)³ in Base 10",
      mode: 3,
      subMode: 0,
      input1: '1.1',
      exponentK: 3,
    ),
  ];

  // ===========================================================================
  // BASE WORDS & FORMATTING HELPERS
  // ===========================================================================
  static const Map<int, String> baseWords = {
    2: 'two',
    3: 'three',
    4: 'four',
    5: 'five',
    6: 'six',
    7: 'seven',
    8: 'eight',
    9: 'nine',
    10: 'ten',
    12: 'twelve',
    16: 'sixteen',
  };

  static String getBaseWord(int b) => baseWords[b] ?? b.toString();

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

  static int intPow(int base, int exp) {
    int res = 1;
    for (int i = 0; i < exp; i++) {
      res *= base;
    }
    return res;
  }

  static String fmtDec(double v, {int maxDecimals = 6}) {
    if (v.abs() < 1e-12) return '0';
    if ((v - v.roundToDouble()).abs() < 1e-12) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static String toUnicodeSuperscript(int n) {
    const Map<String, String> supMap = {
      '-': '⁻',
      '0': '⁰',
      '1': '¹',
      '2': '²',
      '3': '³',
      '4': '⁴',
      '5': '⁵',
      '6': '⁶',
      '7': '⁷',
      '8': '⁸',
      '9': '⁹',
    };
    final String s = n.toString();
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      buf.write(supMap[s[i]] ?? s[i]);
    }
    return buf.toString();
  }

  static String toUnicodeSubscript(int n) {
    const Map<String, String> subMap = {
      '-': '₋',
      '0': '₀',
      '1': '₁',
      '2': '₂',
      '3': '₃',
      '4': '₄',
      '5': '₅',
      '6': '₆',
      '7': '₇',
      '8': '₈',
      '9': '₉',
    };
    final String s = n.toString();
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      buf.write(subMap[s[i]] ?? s[i]);
    }
    return buf.toString();
  }

  /// Strips spaces, commas, and subscript suffixes like "_2", "_two", "two", "(base 2)"
  static String sanitizeNumberInput(String raw) {
    String s = raw.trim();
    // Convert any trailing Unicode subscripts (₂, ₁₀, etc.) or remove them
    s = s.replaceAll(RegExp(r'[₀₁₂₃₄₅₆₇₈₉]+\s*$'), '');
    // Remove trailing base words or subscripts
    s = s.replaceAll(
        RegExp(
            r'(_|\s)*(base\s*)?(two|three|four|five|six|seven|eight|nine|ten|twelve|sixteen|\(\d+\)|_2|_10)\s*$',
            caseSensitive: false),
        '');
    s = s.replaceAll(' ', '').replaceAll(',', '');
    return s.toUpperCase();
  }

  /// Formats a cleaned number with textbook 3-digit grouping on the integer part (e.g. "1\,101.110")
  static String formatGroupedLaTeX(String cleaned) {
    final List<String> parts = cleaned.split('.');
    final String intPart = parts[0];
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buf.write('\\,');
      }
      buf.write(intPart[i]);
    }
    if (parts.length > 1 && parts[1].isNotEmpty) {
      buf.write('.');
      buf.write(parts[1]);
    }
    return buf.toString();
  }

  /// Formats an improper rational fraction (num / den) as both plain and LaTeX mixed fraction
  static Map<String, String> formatRationalAsMixed(int num, int den) {
    if (den == 0) return {'plain': '0', 'latex': '0'};
    if (num == 0) return {'plain': '0', 'latex': '0'};

    final bool isNeg = (num < 0) ^ (den < 0);
    int n = num.abs();
    int d = den.abs();
    final int g = gcd(n, d);
    n ~/= g;
    d ~/= g;
    final String sign = isNeg ? '-' : '';

    if (d == 1) {
      return {'plain': '$sign$n', 'latex': '$sign$n'};
    }
    if (n > d) {
      final int whole = n ~/ d;
      final int rem = n % d;
      return {
        'plain': '$sign$whole $rem/$d',
        'latex': '$sign$whole\\frac{$rem}{$d}',
      };
    } else {
      return {
        'plain': '$sign$n/$d',
        'latex': '$sign\\frac{$n}{$d}',
      };
    }
  }

  // ===========================================================================
  // CORE ENGINE: EXPAND ANY NUMBER IN BASE b INTO BASE 10 (ZERO SKIPPED STEPS!)
  // ===========================================================================
  static BinaryExpansionDetail expandNumberInBase({
    required String rawInput,
    required int baseInt,
    bool strictBinaryCheck = false,
  }) {
    final String cleaned = sanitizeNumberInput(rawInput);
    if (cleaned.isEmpty) {
      throw FormatException(
        strictBinaryCheck
            ? "Please enter a binary number using digits 0 and 1 (e.g. 1011, 110 011, or 1101.110)."
            : "Please enter a number to expand (e.g. 110 001, 432, or 3 256).",
      );
    }

    if (cleaned.split('.').length > 2) {
      throw const FormatException(
          "A number can contain at most one fractional point (.).");
    }

    final List<String> parts = cleaned.split('.');
    final String intStr = parts[0].isEmpty ? '0' : parts[0];
    final String fracStr = parts.length > 1 ? parts[1] : '';

    if (intStr.length > 14 || fracStr.length > 8) {
      throw const FormatException(
          "Please enter up to 14 integer digits and up to 8 fractional digits.");
    }

    final String bWord = getBaseWord(baseInt);
    final List<int> invalidDigits = [];

    int parseDigitChar(String ch) {
      final int? d = int.tryParse(ch, radix: 16);
      if (d == null) {
        throw FormatException("Invalid character '$ch' in number '$rawInput'.");
      }
      if (strictBinaryCheck && d > 1) {
        throw FormatException(
            "Invalid digit '$ch' found! A binary (base 2) number can only contain the digits 0 and 1.");
      }
      if (d >= baseInt && !invalidDigits.contains(d)) {
        invalidDigits.add(d);
      }
      return d;
    }

    final List<DigitPowerCell> cells = [];
    final int nInt = intStr.length;

    // 1. Build Integer Part Cells (powers nInt-1 down to 0)
    int wholeSum = 0;
    final List<String> tableDigitCols = [];
    final List<String> tablePowerCols = [];
    final List<String> bracketedTerms = [];
    final List<String> unitFractionTerms = [];
    final List<String> evaluatedPowerTerms = [];
    final List<String> nonZeroWholeEvaluated = [];

    for (int i = 0; i < nInt; i++) {
      final String ch = intStr[i];
      final int d = parseDigitChar(ch);
      final int p = nInt - 1 - i;
      final int pVal = intPow(baseInt, p);
      final int termVal = d * pVal;
      wholeSum += termVal;

      cells.add(DigitPowerCell(
        digitChar: ch,
        digitVal: d,
        powerIndex: p,
        isPoint: false,
        isFractional: false,
        powerHeaderText: '$baseInt${toUnicodeSuperscript(p)}',
        placeValueText: '$pVal',
        productTermText: '$d×$pVal = $termVal',
      ));

      tableDigitCols.add('\\mathbf{$ch}');
      tablePowerCols.add('$baseInt^{$p}');
      bracketedTerms.add('($d \\times $baseInt^{$p})');
      unitFractionTerms.add('($d \\times $baseInt^{$p})');
      evaluatedPowerTerms.add('($d \\times $pVal)');
      if (d > 0) {
        nonZeroWholeEvaluated.add('$termVal');
      }
    }

    // 2. Build Fractional Part Cells (powers -1 down to -m)
    final int mFrac = fracStr.length;
    final int rawFracDen = mFrac > 0 ? intPow(baseInt, mFrac) : 1;
    int rawFracNum = 0;

    final List<String> nonZeroFracUnitTerms = [];
    final List<String> lcdScaledTerms = [];
    final List<String> lcdNumeratorParts = [];
    final List<String> decimalFracParts = [];

    if (mFrac > 0) {
      cells.add(const DigitPowerCell(
        digitChar: '.',
        isPoint: true,
        powerHeaderText: '.',
        placeValueText: '.',
        productTermText: '+',
      ));
      tableDigitCols.add('\\mathbf{.}');
      tablePowerCols.add('\\cdot');

      for (int j = 0; j < mFrac; j++) {
        final String ch = fracStr[j];
        final int d = parseDigitChar(ch);
        final int k = j + 1; // positive index 1, 2, ...
        final int p = -k; // negative power -1, -2, ...
        final int denK = intPow(baseInt, k);
        final int multiplierToLCD = rawFracDen ~/ denK;
        final int scaledNum = d * multiplierToLCD;
        rawFracNum += scaledNum;

        cells.add(DigitPowerCell(
          digitChar: ch,
          digitVal: d,
          powerIndex: p,
          isPoint: false,
          isFractional: true,
          powerHeaderText: '$baseInt${toUnicodeSuperscript(p)}',
          placeValueText: '1/$denK',
          productTermText: d == 0 ? '0' : '$d/$denK',
        ));

        tableDigitCols.add('\\mathbf{$ch}');
        tablePowerCols.add('$baseInt^{$p}');
        bracketedTerms.add('($d \\times $baseInt^{$p})');
        unitFractionTerms.add('\\left($d \\times \\frac{1}{$baseInt^{$k}}\\right)');
        evaluatedPowerTerms.add('\\left($d \\times \\frac{1}{$denK}\\right)');

        if (d > 0) {
          nonZeroFracUnitTerms.add('\\frac{$d}{$denK}');
          if (multiplierToLCD > 1) {
            lcdScaledTerms.add(
                '\\frac{$d \\times $multiplierToLCD}{$denK \\times $multiplierToLCD}');
          } else {
            lcdScaledTerms.add('\\frac{$d}{$denK}');
          }
          lcdNumeratorParts.add('$scaledNum');
          decimalFracParts.add(fmtDec(d / denK));
        }
      }
    }

    // 3. Simplify Fractional Part & Total Value
    final int g = gcd(rawFracNum, rawFracDen);
    final int simpFracNum = rawFracNum ~/ g;
    final int simpFracDen = rawFracDen ~/ g;
    final int improperNum = wholeSum * simpFracDen + simpFracNum;
    final double exactDecimal = wholeSum + (rawFracNum / rawFracDen);

    final Map<String, String> mixedFmt =
    formatRationalAsMixed(improperNum, simpFracDen);
    final String mixedPlain = mixedFmt['plain']!;
    final String mixedLaTeX = "${mixedFmt['latex']}_{\\text{ten}}";
    final String decPlain = fmtDec(exactDecimal);
    final String decLaTeX = "${decPlain}_{\\text{ten}}";

    final String groupedDisp = formatGroupedLaTeX(
        mFrac > 0 ? '$intStr.$fracStr' : intStr);

    // 4. Construct LaTeX Positional Power Alignment Table
    final String colSpec = List.filled(tableDigitCols.length + 1, 'c').join('|');
    final String placeValueTableLaTeX =
        "\\begin{array}{|$colSpec|} \\hline "
        "\\text{Digit} & ${tableDigitCols.join(' & ')} \\\\ \\hline "
        "\\text{Power of $baseInt} & ${tablePowerCols.join(' & ')} \\\\ \\hline "
        "\\end{array}";

    final String bracketedExpansionLaTeX =
        "${groupedDisp}_{\\text{$bWord}} = ${bracketedTerms.join(' + ')}";

    // 5. Build Unabridged Line-by-Line Mathematical Workings
    final List<String> workings = [];
    workings.add(placeValueTableLaTeX);
    workings.add(bracketedExpansionLaTeX);

    if (mFrac > 0) {
      workings.add(
          "\\text{Rewrite negative powers using } $baseInt^{-k} = \\frac{1}{$baseInt^k}:");
      workings.add("= ${unitFractionTerms.join(' + ')}");
    }

    workings.add(
        "\\text{Evaluate each power of $baseInt (note that } $baseInt^0 = 1 \\text{ and } 0 \\times $baseInt^k = 0\\text{):}");
    workings.add("= ${evaluatedPowerTerms.join(' + ')}");

    final List<String> allNonZeroTerms = [
      if (nonZeroWholeEvaluated.isEmpty && nonZeroFracUnitTerms.isEmpty) '0',
      ...nonZeroWholeEvaluated,
      ...nonZeroFracUnitTerms,
    ];
    workings.add("= ${allNonZeroTerms.join(' + ')}");

    if (mFrac > 0 && rawFracNum > 0) {
      if (nonZeroWholeEvaluated.length > 1) {
        workings.add(
            "\\text{Add whole-number parts: } ${nonZeroWholeEvaluated.join(' + ')} = $wholeSum");
      }
      if (nonZeroFracUnitTerms.length > 1) {
        workings.add(
            "\\text{Add fractions using Lowest Common Denominator (LCD} = $rawFracDen\\text{):}");
        workings.add(
            "\\text{Fractional sum} = ${nonZeroFracUnitTerms.join(' + ')} = ${lcdScaledTerms.join(' + ')} = \\frac{${lcdNumeratorParts.join(' + ')}}{$rawFracDen} = \\frac{$rawFracNum}{$rawFracDen}"
                "${g > 1 ? ' = \\frac{$simpFracNum}{$simpFracDen}' : ''}");
      } else if (g > 1) {
        workings.add(
            "\\text{Simplify fraction: } \\frac{$rawFracNum}{$rawFracDen} = \\frac{$rawFracNum \\div $g}{$rawFracDen \\div $g} = \\frac{$simpFracNum}{$simpFracDen}");
      }

      workings.add(
          "\\text{Decimal equivalent of fraction: } \\frac{$simpFracNum}{$simpFracDen} = ${ decimalFracParts.length > 1 ? '${decimalFracParts.join(' + ')} = ' : '' }${fmtDec(rawFracNum / rawFracDen)}");
      workings.add(
          "\\therefore \\; ${groupedDisp}_{\\text{$bWord}} = \\mathbf{$mixedLaTeX} \\; \\text{ or } \\; \\mathbf{$decLaTeX}");
    } else {
      workings.add(
          "\\therefore \\; ${groupedDisp}_{\\text{$bWord}} = \\mathbf{${wholeSum}_{\\text{ten}}}");
    }

    return BinaryExpansionDetail(
      rawInput: rawInput,
      cleanedNumber: mFrac > 0 ? '$intStr.$fracStr' : intStr,
      groupedDisplay: groupedDisp,
      baseInt: baseInt,
      baseWord: bWord,
      hasInvalidDigitForBase: invalidDigits.isNotEmpty,
      invalidDigits: invalidDigits,
      cells: cells,
      wholeSum: wholeSum,
      rawFracNum: rawFracNum,
      rawFracDen: rawFracDen,
      simpFracNum: simpFracNum,
      simpFracDen: simpFracDen,
      improperNum: improperNum,
      exactDecimal: exactDecimal,
      mixedFractionPlain: mixedPlain,
      mixedFractionLaTeX: mixedLaTeX,
      exactDecimalPlain: decPlain,
      exactDecimalLaTeX: decLaTeX,
      placeValueTableLaTeX: placeValueTableLaTeX,
      bracketedExpansionLaTeX: bracketedExpansionLaTeX,
      fullWorkingsLaTeX: workings,
    );
  }

  // ===========================================================================
  // MODE 0: BINARY TO BASE 10 CONVERTER (WHOLE & FRACTIONAL BICIMALS)
  // Matches Example 2a, 2b & Exercise 1.2 #1a–l
  // ===========================================================================
  static BinaryToBase10Result solveBinaryToBase10({
    required String binaryInputStr,
  }) {
    try {
      final BinaryExpansionDetail exp = expandNumberInBase(
        rawInput: binaryInputStr,
        baseInt: 2,
        strictBinaryCheck: true,
      );

      final bool hasFraction = exp.rawFracDen > 1;
      final List<String> workings = [
        "\\text{\\textbf{Converting Binary Number }} ${exp.groupedDisplay}_{\\text{two}} \\text{\\textbf{ to Base 10}}",
        ...exp.fullWorkingsLaTeX,
      ];

      final List<BinaryToBase10Step> steps = [
        BinaryToBase10Step(
          title:
          "Step 1: Assign Positional Powers of 2 to Each Binary Digit",
          description:
          "• In the binary number system (base 2), there are only two digits: 0 and 1.\n"
              "• Starting from the units digit (just to the left of the point), assign powers of 2 going from right to left: 2⁰, 2¹, 2², 2³, …\n"
              "${hasFraction ? '• For digits to the RIGHT of the binary point, assign negative powers of 2 going from left to right: 2⁻¹, 2⁻², 2⁻³, …' : '• Every position represents a power of 2.'}",
          mathLaTeX: exp.placeValueTableLaTeX,
        ),
        BinaryToBase10Step(
          title:
          "Step 2: Express ${exp.cleanedNumber}₂ as a Sum of Multiples of Powers of 2",
          description:
          "Multiply each binary digit (1 or 0) by its corresponding power of 2 and write them as a sum from left to right:",
          mathLaTeX: exp.bracketedExpansionLaTeX,
        ),
        BinaryToBase10Step(
          title:
          "Step 3: Evaluate Each Power of 2${hasFraction ? ' and Unit Fraction (1 / 2ᵏ)' : ''}",
          description:
          "• Remember the laws of indices: 2⁰ = 1, 2¹ = 2, 2² = 4, 2³ = 8, 2⁴ = 16, 2⁵ = 32, 2⁶ = 64.\n"
              "${hasFraction ? '• For negative powers of 2: 2⁻¹ = 1/2¹ = 1/2 (0.5), 2⁻² = 1/2² = 1/4 (0.25), 2⁻³ = 1/8 (0.125), 2⁻⁴ = 1/16 (0.0625), 2⁻⁵ = 1/32 (0.03125).\n' : ''}"
              "• Any power of 2 multiplied by 0 equals 0 and drops out of the sum.",
          mathLaTeX: exp.fullWorkingsLaTeX
              .sublist(2, math.min(6, exp.fullWorkingsLaTeX.length))
              .join('\n'),
        ),
        BinaryToBase10Step(
          title: hasFraction
              ? "Step 4: Add the Whole Numbers and Fractions (Both Fraction & Decimal Form)"
              : "Step 4: Add the Evaluated Values to Get the Base 10 Number",
          description: hasFraction
              ? "• Whole-number part sum = ${exp.wholeSum}.\n"
              "• Fractional part sum: Using the Lowest Common Denominator (LCD = ${exp.rawFracDen}), the fractions add up to ${exp.rawFracNum}/${exp.rawFracDen}${exp.simpFracDen != exp.rawFracDen ? ' = ${exp.simpFracNum}/${exp.simpFracDen}' : ''} = ${fmtDec(exp.rawFracNum / exp.rawFracDen)}.\n"
              "• Combining both parts gives ${exp.mixedFractionPlain}₁₀ (base ten) or ${exp.exactDecimalPlain}₁₀ (base ten)!"
              : "Add all the non-zero place values together to obtain the final value in base 10: ${exp.wholeSum}₁₀ (base ten).",
          mathLaTeX: exp.fullWorkingsLaTeX.last,
        ),
      ];

      final Map<String, String> answers = {
        "Binary Input": "${exp.cleanedNumber}₂",
        if (hasFraction && exp.rawFracNum > 0) ...{
          "Base 10 (Fraction)": "${exp.mixedFractionPlain}₁₀",
          "Base 10 (Decimal)": "${exp.exactDecimalPlain}₁₀",
        } else
          "Value in Base 10": "${exp.wholeSum}₁₀",
      };

      return BinaryToBase10Result(
        mode: 0,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BinaryToBase10CanvasData(
          mode: 0,
          baseInt: 2,
          baseWord: 'two',
          primaryCells: exp.cells,
          headerBadge:
          "${exp.cleanedNumber}₂  =  ${hasFraction && exp.rawFracNum > 0 ? '${exp.mixedFractionPlain}₁₀  (or ${exp.exactDecimalPlain}₁₀)' : '${exp.wholeSum}₁₀'}",
          subBadge:
          "Green Cards = Active '1' Bits (Switched ON)   |   Grey Cards = '0' Bits (Switched OFF)",
          bottomSummaryBanner:
          "Base 10 Sum = ${hasFraction && exp.rawFracNum > 0 ? '${exp.mixedFractionPlain}₁₀ = ${exp.exactDecimalPlain}₁₀' : '${exp.wholeSum}₁₀'}",
        ),
      );
    } catch (e) {
      return BinaryToBase10Result.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter a valid binary number (e.g. 1011 or 1101.110).",
      );
    }
  }

  // ===========================================================================
  // MODE 1: EXPAND ANY NUMBER IN POWERS OF ITS BASE & EVALUATE IN BASE 10
  // Matches Page 8 Top Diagram, Example 1a–c, Exercise 1.1 #1–20 & Page 9 Top Note
  // ===========================================================================
  static BinaryToBase10Result solveExpandInPowersOfBase({
    required String numberInputStr,
    required int baseInt,
  }) {
    try {
      final BinaryExpansionDetail exp = expandNumberInBase(
        rawInput: numberInputStr,
        baseInt: baseInt,
        strictBinaryCheck: false,
      );

      final String bWord = exp.baseWord;
      final String bSub = toUnicodeSubscript(baseInt);
      final List<String> workings = [
        "\\text{\\textbf{Step 1: Identify Given Number and Base Subscript (Page 8)}}",
        "\\text{In } ${exp.groupedDisplay}_{\\text{$bWord}}: \\quad \\text{Given number} = ${exp.groupedDisplay}, \\quad \\text{Base number} = $baseInt \\text{ ($bWord)}",
        if (exp.hasInvalidDigitForBase)
          "\\text{Note: Digit(s) } ${exp.invalidDigits.join(', ')} \\ge $baseInt \\text{ (normally base-$baseInt digits are } 0 \\text{ to } ${baseInt - 1}\\text{), but expanding in powers of $baseInt gives:}",
        "",
        "\\text{\\textbf{Step 2: Expand in the Powers of Base $baseInt (Exercise 1.1)}}",
        exp.placeValueTableLaTeX,
        "\\mathbf{${exp.bracketedExpansionLaTeX}}",
        "",
        "\\text{\\textbf{Step 3: Value in Base 10 (Page 9 Fundamental Rule)}}",
        "\\text{Rule: Any number expressed in any number base, when expanded in the powers of the given base, gives its value in base 10:}",
        ...exp.fullWorkingsLaTeX.sublist(2),
      ];

      final List<BinaryToBase10Step> steps = [
        BinaryToBase10Step(
          title:
          "Step 1: Identify the Given Number and the Base Subscript (Page 8 Diagram)",
          description:
          "• We always indicate which number base we are working with by writing the base number as a subscript after the given number.\n"
              "• In '${exp.cleanedNumber}$bSub' (${exp.cleanedNumber} base $bWord), the given number is ${exp.cleanedNumber} and the base is $baseInt ($bWord)."
              "${exp.hasInvalidDigitForBase ? '\n• Pedagogical Note: In a strict base-$baseInt system, digits must be less than $baseInt (0 to ${baseInt - 1}). However, we can still write out its algebraic expansion in powers of $baseInt!' : ''}",
          mathLaTeX:
          "\\text{Given Number} = ${exp.groupedDisplay}, \\quad \\text{Base} = $baseInt \\text{ ($bWord)}",
        ),
        BinaryToBase10Step(
          title:
          "Step 2: Assign Powers of $baseInt & Write the Expanded Form (Example 1 & Exercise 1.1)",
          description:
          "Assign powers of $baseInt from right to left starting with $baseInt⁰ at the units digit ($baseInt⁰, $baseInt¹, $baseInt², …), and multiply each digit by its power of $baseInt:",
          mathLaTeX:
          "${exp.placeValueTableLaTeX}\n\\boxed{${exp.bracketedExpansionLaTeX}}",
        ),
        BinaryToBase10Step(
          title:
          "Step 3: Evaluate the Expansion to Find the Value in Base 10 (Page 9 Rule)",
          description:
          "• Textbook Rule (Page 9 top): 'Note that any number expressed in any number base when expanded in the powers of the given base, gives the value of the number in base 10.'\n"
              "• Evaluating each power of $baseInt and adding the products gives ${exp.exactDecimalPlain}₁₀ (base ten).",
          mathLaTeX: exp.fullWorkingsLaTeX.sublist(2).join('\n'),
        ),
      ];

      final String cleanExpandedPlain = exp.cells
          .where((c) => !c.isPoint)
          .map((c) => '(${c.digitVal} × ${c.powerHeaderText})')
          .join(' + ');

      return BinaryToBase10Result(
        mode: 1,
        finalAnswers: {
          "Given Number & Base": "${exp.cleanedNumber}$bSub (Base $bWord)",
          "Expanded Form": cleanExpandedPlain,
          "Value in Base 10": "${exp.exactDecimalPlain}₁₀",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BinaryToBase10CanvasData(
          mode: 1,
          baseInt: baseInt,
          baseWord: bWord,
          primaryCells: exp.cells,
          headerBadge:
          "Expanded in Powers of $baseInt ($bWord):  ${exp.cleanedNumber}$bSub = ${exp.exactDecimalPlain}₁₀",
          subBadge:
          "Each digit is multiplied by its positional power of $baseInt ($baseInt⁰ = 1, $baseInt¹ = $baseInt, $baseInt² = ${baseInt * baseInt}, …)",
          bottomSummaryBanner:
          "Value in Base 10 = ${exp.exactDecimalPlain}₁₀ (base ten)",
        ),
      );
    } catch (e) {
      return BinaryToBase10Result.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter a valid number for base $baseInt.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: SQUARE ROOT OF A BINARY NUMBER (√N_two)
  // Matches Example 3a, 3b & Exercise 1.2 #4a–f (including √0.0001_two)
  // ===========================================================================
  static List<DivisionRemainderRow> buildDivisionBy2Table(int n) {
    if (n <= 0) {
      return [
        const DivisionRemainderRow(
            dividend: 0, divisor: 2, quotient: 0, remainder: 0)
      ];
    }
    final List<DivisionRemainderRow> rows = [];
    int curr = n;
    while (curr > 0) {
      final int q = curr ~/ 2;
      final int r = curr % 2;
      rows.add(DivisionRemainderRow(
        dividend: curr,
        divisor: 2,
        quotient: q,
        remainder: r,
      ));
      curr = q;
    }
    return rows;
  }

  static String formatDivisionTableLaTeX(
      int startNum, List<DivisionRemainderRow> rows) {
    final StringBuffer buf = StringBuffer();
    buf.write("\\begin{array}{r|l} ");
    for (int i = 0; i < rows.length; i++) {
      final DivisionRemainderRow r = rows[i];
      if (i == 0) {
        buf.write("2 & ${r.dividend} \\\\ \\hline ");
      }
      final String arrow = i == 0 ? "\\; \\uparrow" : "\\; \\big|";
      if (i < rows.length - 1) {
        buf.write("2 & ${r.quotient} \\text{ r } \\mathbf{${r.remainder}} $arrow \\\\ \\hline ");
      } else {
        buf.write("  & ${r.quotient} \\text{ r } \\mathbf{${r.remainder}} $arrow ");
      }
    }
    buf.write("\\end{array}");
    return buf.toString();
  }

  static BinaryToBase10Result solveBinarySquareRoot({
    required String binaryRadicandStr,
  }) {
    try {
      final BinaryExpansionDetail exp = expandNumberInBase(
        rawInput: binaryRadicandStr,
        baseInt: 2,
        strictBinaryCheck: true,
      );

      final bool hasFraction = exp.rawFracDen > 1;
      final List<String> workings = [
        "\\text{\\textbf{Step 1: Convert }} ${exp.groupedDisplay}_{\\text{two}} \\text{\\textbf{ to Base 10}}",
        ...exp.fullWorkingsLaTeX,
        "",
        "\\text{\\textbf{Step 2: Find the Square Root in Base 10}}",
      ];

      final List<BinaryToBase10Step> steps = [
        BinaryToBase10Step(
          title:
          "Step 1: Convert the Binary Number (${exp.cleanedNumber}₂) to Base 10",
          description:
          "First, expand the binary number under the square root sign in powers of 2 to find its value in base 10:\n"
              "• ${exp.cleanedNumber}₂ = ${hasFraction && exp.rawFracNum > 0 ? '${exp.mixedFractionPlain}₁₀ (${exp.exactDecimalPlain}₁₀)' : '${exp.wholeSum}₁₀'}.",
          mathLaTeX: exp.fullWorkingsLaTeX.join('\n'),
        ),
      ];

      final Map<String, String> answers = {
        "Radicand in Base 10": hasFraction && exp.rawFracNum > 0
            ? "${exp.mixedFractionPlain}₁₀ (${exp.exactDecimalPlain}₁₀)"
            : "${exp.wholeSum}₁₀",
      };

      List<DivisionRemainderRow> divRows = [];
      String rootBase2Display = "";
      String rootBase10Display = "";

      final int numRoot = math.sqrt(exp.improperNum).round();
      final int denRoot = math.sqrt(exp.simpFracDen).round();
      final bool isExactRationalSquare =
          (numRoot * numRoot == exp.improperNum) &&
              (denRoot * denRoot == exp.simpFracDen);

      if (!hasFraction && isExactRationalSquare) {
        // Exact Whole-Number Square Root (Matches Example 3a: √36 = 6, Example 3b: √81 = 9, Ex 1.2 #4a–d, f)
        final int root10 = numRoot;
        rootBase10Display = "${root10}₁₀";
        divRows = buildDivisionBy2Table(root10);
        final String binDigits =
        divRows.reversed.map((r) => r.remainder.toString()).join('');
        final String groupedBinRoot = formatGroupedLaTeX(binDigits);
        rootBase2Display = "${binDigits}₂";

        workings.add(
            "\\sqrt{${exp.wholeSum}_{\\text{ten}}} = \\sqrt{$root10 \\times $root10} = \\mathbf{${root10}_{\\text{ten}}}");
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 3: Convert }} ${root10}_{\\text{ten}} \\text{\\textbf{ Back to Base 2 (Repeated Division by 2)}}");

        for (final r in divRows) {
          workings.add(
              "${r.dividend} \\div 2 = ${r.quotient} \\text{ remainder } \\mathbf{${r.remainder}}");
        }
        workings.add(formatDivisionTableLaTeX(root10, divRows));
        workings.add(
            "\\text{Reading the remainders upwards } (\\uparrow): \\quad ${root10}_{\\text{ten}} = \\mathbf{${groupedBinRoot}_{\\text{two}}}");
        workings.add(
            "\\therefore \\; \\sqrt{${exp.groupedDisplay}_{\\text{two}}} = \\mathbf{${root10}_{\\text{ten}}} \\; \\text{ or } \\; \\mathbf{${groupedBinRoot}_{\\text{two}}}");

        steps.add(BinaryToBase10Step(
          title:
          "Step 2: Find the Square Root of ${exp.wholeSum}₁₀ in Base 10",
          description:
          "Since $root10 × $root10 = ${exp.wholeSum}, the square root of ${exp.wholeSum}₁₀ is ${root10}₁₀.",
          mathLaTeX:
          "\\sqrt{${exp.wholeSum}_{\\text{ten}}} = \\sqrt{$root10 \\times $root10} = \\mathbf{${root10}_{\\text{ten}}}",
        ));

        final String divExplainLines = divRows
            .map((r) =>
        "• ${r.dividend} ÷ 2 = ${r.quotient} remainder ${r.remainder}")
            .join('\n');

        steps.add(BinaryToBase10Step(
          title:
          "Step 3: Convert ${root10}₁₀ Back to Base 2 Using Repeated Division by 2",
          description:
          "Divide $root10 repeatedly by 2, recording the remainder (0 or 1) at each stage until the quotient becomes 0:\n"
              "$divExplainLines\n"
              "• Read the remainders from bottom to top (upwards ↑): ${binDigits}₂!",
          mathLaTeX:
          "${formatDivisionTableLaTeX(root10, divRows)} \\implies \\boxed{\\sqrt{${exp.groupedDisplay}_{\\text{two}}} = ${groupedBinRoot}_{\\text{two}} \\; (${root10}_{\\text{ten}})}",
        ));

        answers["Square Root (Base 10)"] = "${root10}₁₀";
        answers["Square Root (Base 2)"] = "${binDigits}₂";
      } else if (hasFraction && isExactRationalSquare) {
        // Exact Fractional Binary Square Root (Matches Exercise 1.2 #4e: √0.0001_two = √(1/16) = 1/4 = 0.25_ten = 0.01_two)
        final Map<String, String> rootMix =
        formatRationalAsMixed(numRoot, denRoot);
        final double rootDec = numRoot / denRoot;
        rootBase10Display = "${rootMix['plain']}₁₀ (${fmtDec(rootDec)}₁₀)";

        // Convert numRoot / denRoot (where denRoot is a power of 2) to binary!
        final int wholeRootPart = numRoot ~/ denRoot;
        int remNum = numRoot % denRoot;
        final String wholeBin = wholeRootPart == 0
            ? '0'
            : buildDivisionBy2Table(wholeRootPart)
            .reversed
            .map((r) => r.remainder.toString())
            .join('');

        final StringBuffer fracBinBuf = StringBuffer();
        final List<String> multBy2Lines = [];
        int currRem = remNum;
        int safety = 0;
        while (currRem > 0 && safety < 12) {
          final double decBefore = currRem / denRoot;
          currRem *= 2;
          final int bit = currRem >= denRoot ? 1 : 0;
          final double decAfter = currRem / denRoot;
          multBy2Lines.add(
              "${fmtDec(decBefore)} \\times 2 = ${fmtDec(decAfter)} \\implies \\text{integer bit} = \\mathbf{$bit}");
          fracBinBuf.write(bit);
          if (currRem >= denRoot) currRem -= denRoot;
          safety++;
        }

        final String finalBinStr = fracBinBuf.isEmpty
            ? wholeBin
            : '$wholeBin.${fracBinBuf.toString()}';
        rootBase2Display = "${finalBinStr}₂";

        workings.add(
            "\\sqrt{\\frac{${exp.simpFracNum}}{${exp.simpFracDen}}_{\\text{ten}}} = \\frac{\\sqrt{${exp.simpFracNum}}}{\\sqrt{${exp.simpFracDen}}} = \\mathbf{\\frac{$numRoot}{$denRoot}_{\\text{ten}}} = \\mathbf{${fmtDec(rootDec)}_{\\text{ten}}}");
        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 3: Convert }} \\frac{$numRoot}{$denRoot}_{\\text{ten}} \\text{\\textbf{ Back to Base 2}}");
        workings.add(
            "\\text{Method A (Negative Powers of 2): } \\frac{$numRoot}{$denRoot} = ${fmtDec(rootDec)}_{\\text{ten}} = \\mathbf{${finalBinStr}_{\\text{two}}}");
        for (final mLine in multBy2Lines) {
          workings.add("\\text{Method B (Multiply by 2): } $mLine");
        }
        workings.add(
            "\\therefore \\; \\sqrt{${exp.groupedDisplay}_{\\text{two}}} = \\mathbf{\\frac{$numRoot}{$denRoot}_{\\text{ten}}} \\; (${fmtDec(rootDec)}_{\\text{ten}}) = \\mathbf{${finalBinStr}_{\\text{two}}}");

        steps.add(BinaryToBase10Step(
          title:
          "Step 2: Take the Square Root of the Base 10 Fraction (${exp.simpFracNum}/${exp.simpFracDen})",
          description:
          "Take the square root of the numerator (√${exp.simpFracNum} = $numRoot) and the square root of the denominator (√${exp.simpFracDen} = $denRoot):\n"
              "• √(${exp.simpFracNum}/${exp.simpFracDen}) = $numRoot/$denRoot = ${fmtDec(rootDec)}₁₀.",
          mathLaTeX:
          "\\sqrt{\\frac{${exp.simpFracNum}}{${exp.simpFracDen}}} = \\frac{\\sqrt{${exp.simpFracNum}}}{\\sqrt{${exp.simpFracDen}}} = \\frac{$numRoot}{$denRoot}_{\\text{ten}} = ${fmtDec(rootDec)}_{\\text{ten}}",
        ));

        steps.add(BinaryToBase10Step(
          title:
          "Step 3: Convert $numRoot/$denRoot (${fmtDec(rootDec)}₁₀) Back to Base 2",
          description:
          "• Using negative powers of 2 (or repeated multiplication of the fractional part by 2), $numRoot/$denRoot = ${finalBinStr}₂.",
          mathLaTeX:
          "\\frac{$numRoot}{$denRoot}_{\\text{ten}} = \\boxed{${finalBinStr}_{\\text{two}}}",
        ));

        answers["Square Root (Base 10)"] =
        "${rootMix['plain']}₁₀ (${fmtDec(rootDec)}₁₀)";
        answers["Square Root (Base 2)"] = "${finalBinStr}₂";
      } else {
        // Non-perfect square fallback
        final double approxRoot = math.sqrt(exp.exactDecimal);
        rootBase10Display = "≈ ${fmtDec(approxRoot, maxDecimals: 4)}₁₀";
        rootBase2Display = "Non-perfect square";

        workings.add(
            "\\sqrt{${exp.exactDecimalPlain}_{\\text{ten}}} \\approx \\mathbf{${fmtDec(approxRoot, maxDecimals: 4)}_{\\text{ten}}}");

        steps.add(BinaryToBase10Step(
          title: "Step 2: Evaluate the Square Root in Base 10",
          description:
          "${exp.exactDecimalPlain} is not a perfect square, so its square root in base 10 is approximately ${fmtDec(approxRoot, maxDecimals: 4)}₁₀.",
          mathLaTeX:
          "\\sqrt{${exp.exactDecimalPlain}_{\\text{ten}}} \\approx ${fmtDec(approxRoot, maxDecimals: 4)}_{\\text{ten}}",
        ));

        answers["Square Root (Base 10)"] =
        "≈ ${fmtDec(approxRoot, maxDecimals: 4)}₁₀";
      }

      return BinaryToBase10Result(
        mode: 2,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BinaryToBase10CanvasData(
          mode: 2,
          baseInt: 2,
          baseWord: 'two',
          primaryCells: exp.cells,
          divisionRows: divRows,
          headerBadge:
          "√(${exp.cleanedNumber}₂)  =  √(${exp.exactDecimalPlain}₁₀)  =  $rootBase2Display  ($rootBase10Display)",
          subBadge:
          "Step 1: Expand to Base 10   |   Step 2: Take Square Root   |   Step 3: Convert Root Back to Base 2",
          bottomSummaryBanner:
          "Square Root = $rootBase2Display  ($rootBase10Display)",
        ),
      );
    } catch (e) {
      return BinaryToBase10Result.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter a valid binary number inside the square root.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: POWERS (N_two)^k & MULTI-TERM ADDITIONS EXPRESSED IN BASE 10
  // Matches Exercise 1.2 #2 & #3a–f
  // ===========================================================================
  static BinaryToBase10Result solvePowersAndAdditionsInBase10({
    required int subMode, // 0: Power (N_two)^k (Ex 1.2 #3a–e), 1: Multi-Term Addition (Ex 1.2 #2 & #3f)
    required String bin1Str,
    required String bin2Str,
    required String bin3Str,
    required int exponentK,
  }) {
    try {
      if (subMode == 0) {
        // Sub-Mode 3A: Power / Cube of a Binary Number (N_two)^k in Base 10 (Ex 1.2 #3a–e)
        final BinaryExpansionDetail exp = expandNumberInBase(
          rawInput: bin1Str,
          baseInt: 2,
          strictBinaryCheck: true,
        );

        final int k = exponentK.clamp(1, 6);
        final String kSup = toUnicodeSuperscript(k);
        final bool hasFrac = exp.simpFracDen > 1;

        final int powNum = intPow(exp.improperNum, k);
        final int powDen = intPow(exp.simpFracDen, k);
        final Map<String, String> powMixed =
        formatRationalAsMixed(powNum, powDen);
        final double powDec = math.pow(exp.exactDecimal, k).toDouble();

        final String repeatedNumFactors =
        List.filled(k, '${exp.improperNum}').join(' \\times ');
        final String repeatedDenFactors =
        List.filled(k, '${exp.simpFracDen}').join(' \\times ');

        final List<String> workings = [
          "\\text{\\textbf{Step 1: Convert }} ${exp.groupedDisplay}_{\\text{two}} \\text{\\textbf{ Inside the Brackets to Base 10}}",
          ...exp.fullWorkingsLaTeX,
          "",
          "\\text{\\textbf{Step 2: Raise the Base 10 Value to the Power of $k (Exercise 1.2 \\#3)}}",
          if (hasFrac) ...[
            "\\left(${exp.groupedDisplay}_{\\text{two}}\\right)^$k = \\left(${exp.mixedFractionLaTeX}\\right)^$k = \\left(\\frac{${exp.improperNum}}{${exp.simpFracDen}}\\right)^$k",
            "= \\frac{$repeatedNumFactors}{$repeatedDenFactors} = \\frac{$powNum}{$powDen}",
            "= \\mathbf{${powMixed['latex']}_{\\text{ten}}} \\; \\text{ or } \\; \\mathbf{${fmtDec(powDec)}_{\\text{ten}}}",
          ] else ...[
            "\\left(${exp.groupedDisplay}_{\\text{two}}\\right)^$k = \\left(${exp.wholeSum}_{\\text{ten}}\\right)^$k = $repeatedNumFactors = \\mathbf{${powNum}_{\\text{ten}}}",
          ],
        ];

        final List<BinaryToBase10Step> steps = [
          BinaryToBase10Step(
            title:
            "Step 1: Convert (${exp.cleanedNumber}₂) to Base 10 First",
            description:
            "Expand ${exp.cleanedNumber}₂ in powers of 2 to find its value in base 10:\n"
                "• ${exp.cleanedNumber}₂ = ${hasFrac ? '${exp.mixedFractionPlain}₁₀ (= ${exp.improperNum}/${exp.simpFracDen} or ${exp.exactDecimalPlain}₁₀)' : '${exp.wholeSum}₁₀'}.",
            mathLaTeX: exp.fullWorkingsLaTeX.join('\n'),
          ),
          BinaryToBase10Step(
            title:
            "Step 2: Raise the Base 10 Value to the Power of $k",
            description: hasFrac
                ? "• Write ${exp.mixedFractionPlain} as the improper fraction ${exp.improperNum}/${exp.simpFracDen} (or decimal ${exp.exactDecimalPlain}).\n"
                "• Raise both numerator and denominator to the power of $k: (${exp.improperNum}/${exp.simpFracDen})$kSup = $powNum/$powDen = ${powMixed['plain']}₁₀ (or ${fmtDec(powDec)}₁₀)!"
                : "• Multiply ${exp.wholeSum}₁₀ by itself $k times: (${exp.wholeSum})$kSup = ${powNum}₁₀.",
            mathLaTeX: workings.sublist(workings.length - (hasFrac ? 3 : 1)).join('\n'),
          ),
        ];

        return BinaryToBase10Result(
          mode: 3,
          subMode: 0,
          finalAnswers: {
            "Inside Brackets (Base 10)": hasFrac
                ? "${exp.mixedFractionPlain}₁₀ (${exp.exactDecimalPlain}₁₀)"
                : "${exp.wholeSum}₁₀",
            if (hasFrac) ...{
              "Result (Fraction in Base 10)": "${powMixed['plain']}₁₀",
              "Result (Decimal in Base 10)": "${fmtDec(powDec)}₁₀",
            } else
              "Result in Base 10": "${powNum}₁₀",
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: BinaryToBase10CanvasData(
            mode: 3,
            baseInt: 2,
            baseWord: 'two',
            primaryCells: exp.cells,
            headerBadge:
            "(${exp.cleanedNumber}₂)$kSup  =  (${exp.exactDecimalPlain}₁₀)$kSup  =  ${hasFrac ? '${powMixed['plain']}₁₀ (${fmtDec(powDec)}₁₀)' : '${powNum}₁₀'}",
            subBadge:
            "Step 1: Expand ${exp.cleanedNumber}₂ to Base 10   |   Step 2: Raise Base 10 Value to Power $k",
            bottomSummaryBanner:
            "Final Value in Base 10 = ${hasFrac ? '${powMixed['plain']}₁₀ = ${fmtDec(powDec)}₁₀' : '${powNum}₁₀'}",
          ),
        );
      } else {
        // Sub-Mode 3B: Multi-Term Addition of 2 or 3 Binary Numbers Expressed in Base 10 (Ex 1.2 #2 & #3f)
        final List<String> nonEmptyInputs = [bin1Str, bin2Str, bin3Str]
            .where((s) => sanitizeNumberInput(s).isNotEmpty)
            .toList();

        if (nonEmptyInputs.length < 2) {
          throw const FormatException(
              "Please enter at least 2 binary numbers to add together (e.g. 110 011 and 101.11).");
        }

        final List<BinaryExpansionDetail> expansions = nonEmptyInputs
            .map((s) => expandNumberInBase(
          rawInput: s,
          baseInt: 2,
          strictBinaryCheck: true,
        ))
            .toList();

        final List<String> workings = [];
        final List<BinaryToBase10Step> steps = [];
        final Map<String, String> answers = {};

        // Common denominator across all terms (since each simpFracDen is a power of 2, LCD is max(simpFracDen))
        int commonDen = 1;
        for (final e in expansions) {
          if (e.simpFracDen > commonDen) commonDen = e.simpFracDen;
        }

        int totalImproperNum = 0;
        double totalDecimal = 0.0;

        for (int i = 0; i < expansions.length; i++) {
          final BinaryExpansionDetail e = expansions[i];
          final int scaleFactor = commonDen ~/ e.simpFracDen;
          totalImproperNum += e.improperNum * scaleFactor;
          totalDecimal += e.exactDecimal;

          workings.add(
              "\\text{\\textbf{Term ${i + 1}: Convert }} ${e.groupedDisplay}_{\\text{two}} \\text{\\textbf{ to Base 10}}");
          workings.add(e.bracketedExpansionLaTeX);
          workings.addAll(e.fullWorkingsLaTeX.sublist(3));
          workings.add("");

          steps.add(BinaryToBase10Step(
            title:
            "Step ${i + 1}: Convert Term ${i + 1} (${e.cleanedNumber}₂) to Base 10",
            description:
            "Expand ${e.cleanedNumber}₂ in powers of 2:\n"
                "• ${e.cleanedNumber}₂ = ${e.simpFracDen > 1 ? '${e.mixedFractionPlain}₁₀ (${e.exactDecimalPlain}₁₀)' : '${e.wholeSum}₁₀'}.",
            mathLaTeX:
            "${e.bracketedExpansionLaTeX}\n${e.fullWorkingsLaTeX.last}",
          ));

          answers["Term ${i + 1} (${e.cleanedNumber}₂)"] = e.simpFracDen > 1
              ? "${e.mixedFractionPlain}₁₀ (${e.exactDecimalPlain}₁₀)"
              : "${e.wholeSum}₁₀";
        }

        final Map<String, String> sumMixed =
        formatRationalAsMixed(totalImproperNum, commonDen);
        final String sumDecStr = fmtDec(totalDecimal);
        final bool sumHasFraction = commonDen > 1 && (totalImproperNum % commonDen != 0);

        final String termsLatexSum = expansions
            .map((e) => "${e.groupedDisplay}_{\\text{two}}")
            .join(' + ');
        final String base10DecTerms =
        expansions.map((e) => e.exactDecimalPlain).join(' + ');

        workings.add(
            "\\text{\\textbf{Final Step: Add the Base 10 Values Together}}");
        workings.add("$termsLatexSum = $base10DecTerms");
        if (sumHasFraction) {
          workings.add(
              "= \\mathbf{${sumMixed['latex']}_{\\text{ten}}} \\; \\text{ or } \\; \\mathbf{${sumDecStr}_{\\text{ten}}}");
        } else {
          workings.add("= \\mathbf{${sumDecStr}_{\\text{ten}}}");
        }

        steps.add(BinaryToBase10Step(
          title:
          "Step ${expansions.length + 1}: Add All Base 10 Values Together",
          description:
          "Add the base 10 equivalents of all ${expansions.length} binary numbers:\n"
              "• Decimal addition: $base10DecTerms = ${sumDecStr}₁₀."
              "${sumHasFraction ? '\n• Mixed fraction form: ${sumMixed['plain']}₁₀.' : ''}",
          mathLaTeX:
          "$termsLatexSum = $base10DecTerms = \\boxed{${sumHasFraction ? '${sumMixed['latex']}_{\\text{ten}} \\text{ or } ${sumDecStr}_{\\text{ten}}' : '${sumDecStr}_{\\text{ten}}'}}",
        ));

        if (sumHasFraction) {
          answers["Total Sum (Fraction)"] = "${sumMixed['plain']}₁₀";
          answers["Total Sum (Decimal)"] = "${sumDecStr}₁₀";
        } else {
          answers["Total Sum in Base 10"] = "${sumDecStr}₁₀";
        }

        return BinaryToBase10Result(
          mode: 3,
          subMode: 1,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          canvasData: BinaryToBase10CanvasData(
            mode: 3,
            baseInt: 2,
            baseWord: 'two',
            primaryCells: expansions.first.cells,
            headerBadge:
            "${expansions.map((e) => '${e.cleanedNumber}₂').join(' + ')}  =  ${sumHasFraction ? '${sumMixed['plain']}₁₀ (${sumDecStr}₁₀)' : '${sumDecStr}₁₀'}",
            subBadge:
            "Place-Value Breakdown of 1st Term (${expansions.first.cleanedNumber}₂ = ${expansions.first.exactDecimalPlain}₁₀)",
            bottomSummaryBanner:
            "Combined Base 10 Sum: $base10DecTerms = ${sumDecStr}₁₀",
          ),
        );
      }
    } catch (e) {
      return BinaryToBase10Result.error(
        mode: 3,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid binary numbers.",
      );
    }
  }
}