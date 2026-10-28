import 'other_bases_to_binary_models.dart';

class OtherBasesToBinaryLogic {
  // ===========================================================================
  // 14 TEXTBOOK PRESETS (Pages 10–11: Example 4a–c & Exercise 1.3 #1–3)
  // ===========================================================================
  static const List<OtherBasesToBinaryPreset> textbookPresets = [
    OtherBasesToBinaryPreset(
      chipLabel: "Ex 4a: Convert 324₁₀ to Binary",
      mode: 0,
      inputStr: '324',
      baseInt: 10,
    ),
    OtherBasesToBinaryPreset(
      chipLabel: "Ex 1.3 #1c: Convert 25.0625₁₀ to Binary",
      mode: 0,
      inputStr: '25.0625',
      baseInt: 10,
    ),
    OtherBasesToBinaryPreset(
      chipLabel: "Ex 1.3 #1d: Convert 112.125₁₀ to Binary",
      mode: 0,
      inputStr: '112.125',
      baseInt: 10,
    ),
    OtherBasesToBinaryPreset(
      chipLabel: "Ex 1.3 #1e: Convert 20 ¾ to Binary",
      mode: 0,
      inputStr: '20 3/4',
      baseInt: 10,
    ),
    OtherBasesToBinaryPreset(
      chipLabel: "Ex 1.3 #1h: Convert 15/16 to Binary",
      mode: 0,
      inputStr: '15/16',
      baseInt: 10,
    ),
    OtherBasesToBinaryPreset(
      chipLabel: "Ex 4b: Convert 124₅ to Binary",
      mode: 1,
      inputStr: '124',
      baseInt: 5,
    ),
    OtherBasesToBinaryPreset(
      chipLabel: "Ex 1.3 #3a: Convert 234₆ to Binary",
      mode: 1,
      inputStr: '234',
      baseInt: 6,
    ),
    OtherBasesToBinaryPreset(
      chipLabel: "Ex 1.3 #3c: Convert 245₈ to Binary",
      mode: 1,
      inputStr: '245',
      baseInt: 8,
    ),
    OtherBasesToBinaryPreset(
      chipLabel: "Ex 1.3 #3e: Convert 857₉ to Binary",
      mode: 1,
      inputStr: '857',
      baseInt: 9,
    ),
    OtherBasesToBinaryPreset(
      chipLabel: "Ex 1.3 #3f: Convert 121₃ to Binary",
      mode: 1,
      inputStr: '121',
      baseInt: 3,
    ),
    OtherBasesToBinaryPreset(
      chipLabel: "Ex 4c: Convert 306.43₈ to Binary (Method 1 & 2)",
      mode: 2,
      inputStr: '306.43',
      baseInt: 8,
    ),
    OtherBasesToBinaryPreset(
      chipLabel: "Ex 1.3 #3i: Convert 73.5₉ to Binary",
      mode: 2,
      inputStr: '73.5',
      baseInt: 9,
    ),
    OtherBasesToBinaryPreset(
      chipLabel: "Ex 1.3 #3j: Express (9₁₀)² in Binary",
      mode: 3,
      subMode: 0,
      inputStr: '9',
      baseInt: 10,
      exponentK: 2,
    ),
    OtherBasesToBinaryPreset(
      chipLabel: "Ex 1.3 #2f: Convert 1 101.100 1₂ to Base 10",
      mode: 3,
      subMode: 1,
      inputStr: '1 101.100 1',
      baseInt: 2,
    ),
  ];

  // ===========================================================================
  // BASE WORDS, UNICODE SUBSCRIPTS/SUPERSCRIPTS & ARITHMETIC HELPERS
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

  static bool isPowerOfTwo(int n) => n > 0 && (n & (n - 1)) == 0;

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

  /// Groups binary or integer strings in threes from the right (and threes from the left after '.')
  /// matching textbook formatting like `101 000 100` or `11 000 110.100 011`
  static String groupDigitsPlain(String rawDigits) {
    final List<String> parts = rawDigits.split('.');
    final String intPart = parts[0];
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buf.write(' ');
      }
      buf.write(intPart[i]);
    }
    if (parts.length > 1 && parts[1].isNotEmpty) {
      buf.write('.');
      final String fracPart = parts[1];
      for (int j = 0; j < fracPart.length; j++) {
        if (j > 0 && j % 3 == 0 && fracPart[j] != '.') {
          buf.write(' ');
        }
        buf.write(fracPart[j]);
      }
    }
    return buf.toString();
  }

  static String groupDigitsLaTeX(String rawDigits) {
    return groupDigitsPlain(rawDigits).replaceAll(' ', '\\,');
  }

  /// Strips spaces, commas, and subscript suffixes like "_five", "_8", "ten"
  static String sanitizeBaseInput(String raw) {
    String s = raw.trim();
    s = s.replaceAll(RegExp(r'[₀₁₂₃₄₅₆₇₈₉]+\s*$'), '');
    s = s.replaceAll(
        RegExp(
            r'(_|\s)*(base\s*)?(two|three|four|five|six|seven|eight|nine|ten|twelve|sixteen|\(\d+\)|_\d+)\s*$',
            caseSensitive: false),
        '');
    s = s.replaceAll(' ', '').replaceAll(',', '');
    return s.toUpperCase();
  }

  // ===========================================================================
  // REPEATED DIVISION BY 2 ENGINE (STAGE 2A — WHOLE NUMBERS)
  // ===========================================================================
  static List<BinaryDivisionRow> buildDivisionBy2Rows(int n) {
    if (n <= 0) {
      return [
        const BinaryDivisionRow(
          dividend: 0,
          divisor: 2,
          quotient: 0,
          remainder: 0,
        ),
      ];
    }
    final List<BinaryDivisionRow> rows = [];
    int curr = n;
    while (curr > 0) {
      final int q = curr ~/ 2;
      final int r = curr % 2;
      rows.add(BinaryDivisionRow(
        dividend: curr,
        divisor: 2,
        quotient: q,
        remainder: r,
      ));
      curr = q;
    }
    return rows;
  }

  static String rowsToBinaryString(List<BinaryDivisionRow> rows) {
    if (rows.isEmpty) return '0';
    return rows.reversed.map((r) => r.remainder.toString()).join('');
  }

  /// Generates the textbook vertical division-by-2 table in LaTeX (matching Pages 10 & 11)
  static String formatDivisionTableLaTeX(List<BinaryDivisionRow> rows) {
    final StringBuffer buf = StringBuffer();
    buf.write("\\begin{array}{r|l} ");
    for (int i = 0; i < rows.length; i++) {
      final BinaryDivisionRow r = rows[i];
      if (i == 0) {
        buf.write("2 & ${r.dividend} \\\\ \\hline ");
      }
      final String arrow = i == 0 ? "\\; \\uparrow" : "\\; \\big|";
      if (i < rows.length - 1) {
        buf.write(
            "2 & ${r.quotient} \\text{ r } \\mathbf{${r.remainder}} $arrow \\\\ \\hline ");
      } else {
        buf.write(
            "  & ${r.quotient} \\text{ r } \\mathbf{${r.remainder}} $arrow ");
      }
    }
    buf.write("\\end{array}");
    return buf.toString();
  }

  // ===========================================================================
  // FRACTIONAL CONVERSION TO BINARY (BOTH TEXTBOOK METHOD 1 & METHOD 2!)
  // Matches Page 10 Bottom (Method 1) & Page 11 Top (Method 2)
  // ===========================================================================
  static Map<String, dynamic> convertBase10FractionToBinary({
    required int rawNum,
    required int rawDen,
  }) {
    final int g = gcd(rawNum, rawDen);
    final int simpNum = rawNum ~/ g;
    final int simpDen = rawDen ~/ g;
    final double decVal = simpNum / simpDen;

    final List<String> workings = [];
    final List<OtherBasesToBinaryStep> steps = [];
    final List<DivisionLadderTable> extraLadders = [];

    if (isPowerOfTwo(simpDen)) {
      // Exact dyadic fraction (e.g. 35/64 in Example 4c, 1/16 in Ex 1.3 #1c, 1/8 in #1d, 3/4 in #1e, 15/16 in #1h)
      final List<BinaryDivisionRow> numRows = buildDivisionBy2Rows(simpNum);
      final List<BinaryDivisionRow> denRows = buildDivisionBy2Rows(simpDen);
      final String numBin = rowsToBinaryString(numRows);
      final String denBin = rowsToBinaryString(denRows);

      // Number of zeros in denBin is log2(simpDen)
      final int kZeros = denBin.length - 1;
      final String paddedFracBits = numBin.padLeft(kZeros, '0');
      final String groupedNumBin = groupDigitsLaTeX(numBin);
      final String groupedDenBin = groupDigitsLaTeX(denBin);
      final String groupedFracOutLaTeX = groupDigitsLaTeX('0.$paddedFracBits');
      final String groupedFracOutPlain = groupDigitsPlain('0.$paddedFracBits');

      extraLadders.add(DivisionLadderTable(
        title: "Numerator: $simpNum₁₀ → ${groupDigitsPlain(numBin)}₂",
        startNumber: simpNum,
        rows: numRows,
        binaryResultGrouped: "${groupDigitsPlain(numBin)}₂",
      ));
      extraLadders.add(DivisionLadderTable(
        title: "Denominator: $simpDen₁₀ → ${groupDigitsPlain(denBin)}₂",
        startNumber: simpDen,
        rows: denRows,
        binaryResultGrouped: "${groupDigitsPlain(denBin)}₂",
      ));

      // --- TEXTBOOK METHOD 2 (Page 11 Top: Separate Binary Division of Numerator & Denominator) ---
      workings.add(
          "\\text{\\textbf{Convert Fractional Part }} \\left(\\frac{$simpNum}{$simpDen}\\right)_{\\text{ten}} \\text{\\textbf{ to Binary — Method 2 (Page 11 Top):}}");
      workings.add(
          "\\text{1. Convert numerator } ${simpNum}_{\\text{ten}} \\text{ to binary by repeated division by 2:}");
      for (final r in numRows) {
        workings.add(
            "\\quad ${r.dividend} \\div 2 = ${r.quotient} \\text{ r } \\mathbf{${r.remainder}}");
      }
      workings.add(formatDivisionTableLaTeX(numRows));
      workings.add(
          "\\quad \\therefore \\; ${simpNum}_{\\text{ten}} = \\mathbf{${groupedNumBin}_{\\text{two}}}");
      workings.add("");
      workings.add(
          "\\text{2. Convert denominator } ${simpDen}_{\\text{ten}} \\text{ to binary by repeated division by 2:}");
      for (final r in denRows) {
        workings.add(
            "\\quad ${r.dividend} \\div 2 = ${r.quotient} \\text{ r } \\mathbf{${r.remainder}}");
      }
      workings.add(formatDivisionTableLaTeX(denRows));
      workings.add(
          "\\quad \\therefore \\; ${simpDen}_{\\text{ten}} = \\mathbf{${groupedDenBin}_{\\text{two}}}");
      workings.add("");
      workings.add(
          "\\text{3. Divide numerator by denominator in base 2 (shift binary point $kZeros places left):}");
      workings.add(
          "\\left(\\frac{$simpNum}{$simpDen}\\right)_{\\text{ten}} = \\left(\\frac{$groupedNumBin}{$groupedDenBin}\\right)_{\\text{two}} = \\mathbf{${groupedFracOutLaTeX}_{\\text{two}}}");
      workings.add("");

      // --- TEXTBOOK METHOD 1 (Page 10 Bottom: Decimal Place-Value / Multiplication by 2) ---
      final String decStr = fmtDec(decVal, maxDecimals: 8);
      workings.add(
          "\\text{\\textbf{Alternative Method 1 (Page 10 Bottom — Decimal }} ${decStr}_{\\text{ten}} \\text{\\textbf{ to Base 2):}}");
      workings.add(
          "\\left(\\frac{$simpNum}{$simpDen}\\right)_{\\text{ten}} = ${decStr}_{\\text{ten}}");

      final List<String> multLinesLatex = [];
      final List<String> multLinesPlain = [];
      int currNum = simpNum;
      for (int step = 1; step <= kZeros; step++) {
        final double beforeDec = currNum / simpDen;
        currNum *= 2;
        final int bit = currNum >= simpDen ? 1 : 0;
        final double afterDec = currNum / simpDen;
        multLinesLatex.add(
            "${fmtDec(beforeDec, maxDecimals: 8)} \\times 2 = ${fmtDec(afterDec, maxDecimals: 8)} \\implies \\text{integer bit} = \\mathbf{$bit}");
        multLinesPlain.add(
            "• ${fmtDec(beforeDec, maxDecimals: 8)} × 2 = ${fmtDec(afterDec, maxDecimals: 8)}  ➔  record bit $bit");
        if (currNum >= simpDen) currNum -= simpDen;
      }
      workings.addAll(multLinesLatex);
      workings.add(
          "\\text{Reading the integer bits from top to bottom gives: } ${decStr}_{\\text{ten}} = \\mathbf{${groupedFracOutLaTeX}_{\\text{two}}}");

      steps.add(OtherBasesToBinaryStep(
        title:
        "Fractional Part — Textbook Method 2 (Convert Numerator $simpNum₁₀ & Denominator ${simpDen}₁₀ to Binary)",
        description:
        "As shown at the top of page 11 in the textbook:\n"
            "1. Convert the numerator $simpNum₁₀ to binary by dividing repeatedly by 2:\n"
            "   $simpNum₁₀ = ${groupDigitsPlain(numBin)}₂.\n"
            "2. Convert the denominator $simpDen₁₀ to binary by dividing repeatedly by 2:\n"
            "   $simpDen₁₀ = ${groupDigitsPlain(denBin)}₂ (which is 1 followed by $kZeros zeros).\n"
            "3. Write the fraction in binary as (${groupDigitsPlain(numBin)} / ${groupDigitsPlain(denBin)})₂ and shift the binary point $kZeros places to the left:\n"
            "   ($simpNum/$simpDen)₁₀ = $groupedFracOutPlain₂!",
        mathLaTeX:
        "${simpNum}_{\\text{ten}} = ${groupedNumBin}_{\\text{two}}, \\quad ${simpDen}_{\\text{ten}} = ${groupedDenBin}_{\\text{two}}\n"
            "\\left(\\frac{$simpNum}{$simpDen}\\right)_{\\text{ten}} = \\left(\\frac{$groupedNumBin}{$groupedDenBin}\\right)_{\\text{two}} = \\boxed{${groupedFracOutLaTeX}_{\\text{two}}}",
      ));

      steps.add(OtherBasesToBinaryStep(
        title:
        "Fractional Part — Textbook Method 1 (Decimal $decStr₁₀ to Base 2)",
        description:
        "Alternatively, express $simpNum/$simpDen as a base 10 decimal ($decStr₁₀) and multiply the fractional part repeatedly by 2, recording the whole-number bit (0 or 1) at each stage from top to bottom:\n"
            "${multLinesPlain.join('\n')}\n"
            "• Result: $decStr₁₀ = $groupedFracOutPlain₂.",
        mathLaTeX:
        "${multLinesLatex.join('\n')}\n\\therefore \\; ${decStr}_{\\text{ten}} = \\mathbf{${groupedFracOutLaTeX}_{\\text{two}}}",
      ));

      return {
        'fracBitsPlain': paddedFracBits,
        'fracBitsGroupedPlain': groupDigitsPlain(paddedFracBits),
        'fracBitsGroupedLaTeX': groupDigitsLaTeX(paddedFracBits),
        'isRecurring': false,
        'workings': workings,
        'steps': steps,
        'extraLadders': extraLadders,
      };
    } else {
      // Non-power-of-2 denominator (e.g. Exercise 1.3 #3i: 73.5_nine = 66 5/9_ten)
      // Produces a recurring bicimal expansion! We compute 6 binary fractional places with full steps.
      final String decStr = "${fmtDec(decVal, maxDecimals: 4)}\\dots";
      workings.add(
          "\\text{\\textbf{Convert Fractional Part }} \\left(\\frac{$simpNum}{$simpDen}\\right)_{\\text{ten}} \\text{\\textbf{ to Binary (Repeated Multiplication by 2):}}");
      workings.add(
          "\\text{Note: Since the denominator } $simpDen \\text{ is not a power of 2, } \\frac{$simpNum}{$simpDen} = ${decStr}_{\\text{ten}} \\text{ forms a recurring binary fraction:}");

      final StringBuffer bitsBuf = StringBuffer();
      final List<String> multLatex = [];
      final List<String> multPlain = [];
      int currNum = simpNum;
      for (int step = 1; step <= 6; step++) {
        final int doubled = currNum * 2;
        final int bit = doubled >= simpDen ? 1 : 0;
        final int nextRem = doubled >= simpDen ? (doubled - simpDen) : doubled;
        bitsBuf.write(bit);
        multLatex.add(
            "\\text{Place $step: } \\frac{$currNum}{$simpDen} \\times 2 = \\frac{$doubled}{$simpDen} = \\mathbf{$bit}\\frac{$nextRem}{$simpDen} \\implies \\text{bit} = \\mathbf{$bit}");
        multPlain.add(
            "• Place $step: ($currNum/$simpDen) × 2 = $doubled/$simpDen = $bit + $nextRem/$simpDen  ➔  bit = $bit");
        currNum = nextRem;
        if (currNum == 0) break;
      }

      final String rawBits = bitsBuf.toString();
      final String groupedBitsPlain = "${groupDigitsPlain(rawBits)}...";
      final String groupedBitsLaTeX = "${groupDigitsLaTeX(rawBits)}\\dots";

      workings.addAll(multLatex);
      workings.add(
          "\\therefore \\; \\left(\\frac{$simpNum}{$simpDen}\\right)_{\\text{ten}} = \\mathbf{0.${groupedBitsLaTeX}_{\\text{two}}} \\text{ (to 6 bicimal places)}");

      steps.add(OtherBasesToBinaryStep(
        title:
        "Convert Fractional Part ($simpNum/$simpDen)₁₀ to Binary by Repeated Multiplication by 2",
        description:
        "Because the denominator ($simpDen) is not a power of 2, multiply the fraction repeatedly by 2 and record the whole-number part (0 or 1) at each step from top to bottom:\n"
            "${multPlain.join('\n')}\n"
            "• Reading the integer bits from top to bottom gives 0.${groupedBitsPlain}₂.",
        mathLaTeX:
        "${multLatex.join('\n')}\n\\left(\\frac{$simpNum}{$simpDen}\\right)_{\\text{ten}} = \\boxed{0.${groupedBitsLaTeX}_{\\text{two}}}",
      ));

      return {
        'fracBitsPlain': '$rawBits...',
        'fracBitsGroupedPlain': groupedBitsPlain,
        'fracBitsGroupedLaTeX': groupedBitsLaTeX,
        'isRecurring': true,
        'workings': workings,
        'steps': steps,
        'extraLadders': extraLadders,
      };
    }
  }

  // ===========================================================================
  // STAGE 1 ENGINE: EXPAND ANY BASE-b NUMBER INTO BASE 10
  // ===========================================================================
  static Map<String, dynamic> expandOtherBaseToBase10({
    required String rawInputStr,
    required int baseInt,
  }) {
    final String cleaned = sanitizeBaseInput(rawInputStr);
    if (cleaned.isEmpty) {
      throw FormatException(
        "Please enter a valid number in base $baseInt (${getBaseWord(baseInt)}).",
      );
    }
    if (cleaned.split('.').length > 2) {
      throw const FormatException(
          "A number can contain at most one fractional point (.).");
    }

    final List<String> parts = cleaned.split('.');
    final String intStr = parts[0].isEmpty ? '0' : parts[0];
    final String fracStr = parts.length > 1 ? parts[1] : '';

    if (intStr.length > 10 || fracStr.length > 5) {
      throw const FormatException(
          "Please enter up to 10 integer digits and up to 5 fractional digits.");
    }

    final String bWord = getBaseWord(baseInt);
    final String bSub = toUnicodeSubscript(baseInt);

    int parseBaseDigit(String ch) {
      final int? d = int.tryParse(ch, radix: 16);
      if (d == null) {
        throw FormatException("Invalid character '$ch' in number '$rawInputStr'.");
      }
      if (d >= baseInt) {
        throw FormatException(
            "Invalid digit '$ch' for base $baseInt ($bWord)! In base $baseInt, every digit must be strictly less than $baseInt (0 to ${baseInt - 1}).");
      }
      return d;
    }

    final List<BaseExpansionCell> cells = [];
    final int nInt = intStr.length;

    int wholeSum = 0;
    final List<String> tableDigitCols = [];
    final List<String> tablePowerCols = [];
    final List<String> bracketedTerms = [];
    final List<String> evaluatedTerms = [];
    final List<String> nonZeroWholeTerms = [];

    for (int i = 0; i < nInt; i++) {
      final String ch = intStr[i];
      final int d = parseBaseDigit(ch);
      final int p = nInt - 1 - i;
      final int pVal = intPow(baseInt, p);
      final int prod = d * pVal;
      wholeSum += prod;

      cells.add(BaseExpansionCell(
        digitChar: ch,
        digitVal: d,
        powerIndex: p,
        isPoint: false,
        isFractional: false,
        powerHeaderText: '$baseInt${toUnicodeSuperscript(p)}',
        placeValueText: '$pVal',
        productTermText: '$d×$pVal=$prod',
      ));

      tableDigitCols.add('\\mathbf{$ch}');
      tablePowerCols.add('$baseInt^{$p}');
      bracketedTerms.add('($d \\times $baseInt^{$p})');
      evaluatedTerms.add('($d \\times $pVal)');
      nonZeroWholeTerms.add('$prod');
    }

    final int mFrac = fracStr.length;
    final int rawFracDen = mFrac > 0 ? intPow(baseInt, mFrac) : 1;
    int rawFracNum = 0;
    final List<String> unitFractionTerms = [];
    final List<String> lcdScaledTerms = [];

    if (mFrac > 0) {
      cells.add(const BaseExpansionCell(
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
        final int d = parseBaseDigit(ch);
        final int k = j + 1;
        final int p = -k;
        final int denK = intPow(baseInt, k);
        final int multToLCD = rawFracDen ~/ denK;
        rawFracNum += d * multToLCD;

        cells.add(BaseExpansionCell(
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
        evaluatedTerms.add('\\left($d \\times \\frac{1}{$denK}\\right)');
        if (d > 0) {
          unitFractionTerms.add('\\frac{$d}{$denK}');
          if (multToLCD > 1) {
            lcdScaledTerms.add('\\frac{${d * multToLCD}}{$rawFracDen}');
          } else {
            lcdScaledTerms.add('\\frac{$d}{$rawFracDen}');
          }
        }
      }
    }

    final int g = gcd(rawFracNum, rawFracDen);
    final int simpNum = rawFracNum ~/ g;
    final int simpDen = rawFracDen ~/ g;
    final double exactDec = wholeSum + (rawFracNum / rawFracDen);

    final String cleanNumberStr = mFrac > 0 ? '$intStr.$fracStr' : intStr;
    final String groupedInLaTeX = groupDigitsLaTeX(cleanNumberStr);
    final String colSpec = List.filled(tableDigitCols.length + 1, 'c').join('|');
    final String placeValueTableLaTeX =
        "\\begin{array}{|$colSpec|} \\hline "
        "\\text{Digit} & ${tableDigitCols.join(' & ')} \\\\ \\hline "
        "\\text{Power of $baseInt} & ${tablePowerCols.join(' & ')} \\\\ \\hline "
        "\\end{array}";

    final List<String> stage1Workings = [
      "\\text{\\textbf{Stage 1: Express }} ${groupedInLaTeX}_{\\text{$bWord}} \\text{\\textbf{ in Base 10 (Expand in Powers of $baseInt)}}",
      placeValueTableLaTeX,
      "${groupedInLaTeX}_{\\text{$bWord}} = ${bracketedTerms.join(' + ')}",
      "= ${evaluatedTerms.join(' + ')}",
    ];

    String base10SummaryPlain = "$wholeSum₁₀";
    String base10SummaryLaTeX = "${wholeSum}_{\\text{ten}}";

    if (mFrac > 0 && rawFracNum > 0) {
      stage1Workings.add(
          "= ${nonZeroWholeTerms.join(' + ')} + ${unitFractionTerms.join(' + ')}");
      if (unitFractionTerms.length > 1) {
        stage1Workings.add(
            "= $wholeSum + ${lcdScaledTerms.join(' + ')} = $wholeSum + \\frac{$rawFracNum}{$rawFracDen}"
                "${g > 1 ? ' = $wholeSum\\frac{$simpNum}{$simpDen}_{\\text{ten}}' : ' = $wholeSum\\frac{$simpNum}{$simpDen}_{\\text{ten}}'}");
      } else {
        stage1Workings.add(
            "= \\mathbf{$wholeSum\\frac{$simpNum}{$simpDen}_{\\text{ten}}}");
      }
      base10SummaryPlain = "$wholeSum $simpNum/$simpDen₁₀";
      base10SummaryLaTeX = "$wholeSum\\frac{$simpNum}{$simpDen}_{\\text{ten}}";
    } else {
      stage1Workings.add(
          "= ${nonZeroWholeTerms.join(' + ')} = \\mathbf{${wholeSum}_{\\text{ten}}}");
    }

    final OtherBasesToBinaryStep stage1Step = OtherBasesToBinaryStep(
      title:
      "Stage 1: Express $cleanNumberStr$bSub in Base 10 by Expanding in Powers of $baseInt",
      description:
      "• Textbook Rule (Page 10): First express the given base-$baseInt number in base 10 by multiplying each digit by its positional power of $baseInt:\n"
          "• Whole-number part sum = ${nonZeroWholeTerms.join(' + ')} = $wholeSum.\n"
          "${mFrac > 0 && rawFracNum > 0 ? '• Fractional part sum = ${unitFractionTerms.map((s) => s.replaceAll('\\frac{', '').replaceAll('}{', '/').replaceAll('}', '')).join(' + ')} = $simpNum/$simpDen.\n' : ''}"
          "• Value in Base 10 = $base10SummaryPlain.",
      mathLaTeX: stage1Workings.sublist(1).join('\n'),
    );

    return {
      'cleanNumberStr': cleanNumberStr,
      'groupedInLaTeX': groupedInLaTeX,
      'bWord': bWord,
      'bSub': bSub,
      'cells': cells,
      'wholeSum': wholeSum,
      'simpNum': simpNum,
      'simpDen': simpDen,
      'exactDec': exactDec,
      'base10SummaryPlain': base10SummaryPlain,
      'base10SummaryLaTeX': base10SummaryLaTeX,
      'stage1Workings': stage1Workings,
      'stage1Step': stage1Step,
    };
  }

  // ===========================================================================
  // MODE 0: BASE 10 TO BINARY (WHOLE, DECIMAL, MIXED & PROPER FRACTIONS)
  // Matches Example 4a (324_ten) & Exercise 1.3 #1a–h, #3h
  // ===========================================================================
  static Map<String, int> _parseBase10Input(String rawInput) {
    String s = rawInput.trim();
    s = s.replaceAll(RegExp(r'[₀₁₂₃₄₅₆₇₈₉]+\s*$'), '');
    s = s.replaceAll(
        RegExp(r'(_|\s)*(base\s*)?(ten|10)\s*$', caseSensitive: false), '');
    s = s
        .replaceAll('¾', ' 3/4')
        .replaceAll('¼', ' 1/4')
        .replaceAll('½', ' 1/2')
        .replaceAll(',', '')
        .trim();

    if (s.isEmpty) {
      throw const FormatException(
          "Please enter a Base 10 number (e.g. 324, 25.0625, 20 3/4, or 15/16).");
    }

    int wholePart = 0;
    int fracNum = 0;
    int fracDen = 1;

    if (s.contains('/')) {
      final List<String> spaceParts =
      s.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
      if (spaceParts.length == 2) {
        wholePart = int.parse(spaceParts[0]);
        final List<String> fParts = spaceParts[1].split('/');
        fracNum = int.parse(fParts[0]);
        fracDen = int.parse(fParts[1]);
      } else if (spaceParts.length == 1) {
        final List<String> fParts = spaceParts[0].split('/');
        final int n = int.parse(fParts[0]);
        final int d = int.parse(fParts[1]);
        if (d <= 0) {
          throw const FormatException("Denominator must be greater than 0.");
        }
        wholePart = n ~/ d;
        fracNum = n % d;
        fracDen = d;
      } else {
        throw const FormatException(
            "Enter a mixed number as '20 3/4' or a fraction as '15/16'.");
      }
    } else if (s.contains('.')) {
      final String noSpaces = s.replaceAll(' ', '');
      final List<String> dotParts = noSpaces.split('.');
      if (dotParts.length > 2) {
        throw const FormatException("Invalid decimal number.");
      }
      wholePart = dotParts[0].isEmpty ? 0 : int.parse(dotParts[0]);
      final String decDigits = dotParts[1];
      if (decDigits.isNotEmpty) {
        if (decDigits.length > 7) {
          throw const FormatException("Please enter up to 7 decimal places.");
        }
        final int rawN = int.parse(decDigits);
        final int rawD = intPow(10, decDigits.length);
        final int g = gcd(rawN, rawD);
        fracNum = rawN ~/ g;
        fracDen = rawD ~/ g;
      }
    } else {
      final String noSpaces = s.replaceAll(' ', '');
      wholePart = int.parse(noSpaces);
    }

    if (wholePart < 0 || fracNum < 0 || fracDen <= 0) {
      throw const FormatException("Please enter a non-negative base 10 number.");
    }
    if (wholePart > 999999) {
      throw const FormatException(
          "Please enter a base 10 whole number up to 999,999.");
    }

    final int g = gcd(fracNum, fracDen);
    return {
      'whole': wholePart,
      'num': fracNum ~/ g,
      'den': fracDen ~/ g,
    };
  }

  static OtherBasesToBinaryResult solveBase10ToBinary({
    required String base10InputStr,
  }) {
    try {
      final Map<String, int> parsed = _parseBase10Input(base10InputStr);
      final int whole = parsed['whole']!;
      final int simpNum = parsed['num']!;
      final int simpDen = parsed['den']!;
      final bool hasFrac = simpNum > 0 && simpDen > 1;

      final List<String> workings = [];
      final List<OtherBasesToBinaryStep> steps = [];
      final List<DivisionLadderTable> ladders = [];

      // 1. Convert Whole-Number Part by Repeated Division by 2
      final List<BinaryDivisionRow> wholeRows = buildDivisionBy2Rows(whole);
      final String wholeBinRaw = rowsToBinaryString(wholeRows);
      final String wholeBinGroupedPlain = groupDigitsPlain(wholeBinRaw);
      final String wholeBinGroupedLaTeX = groupDigitsLaTeX(wholeBinRaw);

      if (whole > 0 || !hasFrac) {
        ladders.add(DivisionLadderTable(
          title: "Whole Part: $whole₁₀ → $wholeBinGroupedPlain₂",
          startNumber: whole,
          rows: wholeRows,
          binaryResultGrouped: "$wholeBinGroupedPlain₂",
        ));

        workings.add(
            "\\text{\\textbf{Step 1: Convert Whole Number }} ${groupDigitsLaTeX(whole.toString())}_{\\text{ten}} \\text{\\textbf{ to Binary by Repeated Division by 2}}");
        for (final r in wholeRows) {
          workings.add(
              "${r.dividend} \\div 2 = ${r.quotient} \\text{ remainder } \\mathbf{${r.remainder}}");
        }
        workings.add(formatDivisionTableLaTeX(wholeRows));
        workings.add(
            "\\text{Reading the remainders upwards from bottom to top } (\\uparrow):");
        workings.add(
            "\\therefore \\; ${groupDigitsLaTeX(whole.toString())}_{\\text{ten}} = \\mathbf{${wholeBinGroupedLaTeX}_{\\text{two}}}");

        final String divLinesPlain = wholeRows
            .map((r) =>
        "• ${r.dividend} ÷ 2 = ${r.quotient} remainder ${r.remainder}")
            .join('\n');

        steps.add(OtherBasesToBinaryStep(
          title:
          "Step 1: Divide ${groupDigitsPlain(whole.toString())}₁₀ Repeatedly by 2 (Example 4a Method)",
          description:
          "Divide $whole repeatedly by 2, writing down the quotient and the remainder (0 or 1) at each stage until the quotient becomes 0:\n"
              "$divLinesPlain\n"
              "• Read the remainders upwards from bottom to top (↑): $whole₁₀ = $wholeBinGroupedPlain₂!",
          mathLaTeX:
          "${formatDivisionTableLaTeX(wholeRows)} \\implies ${groupDigitsLaTeX(whole.toString())}_{\\text{ten}} = \\boxed{${wholeBinGroupedLaTeX}_{\\text{two}}}",
        ));
      } else {
        workings.add(
            "\\text{\\textbf{Step 1: Whole-Number Part is }} 0_{\\text{ten}} = 0_{\\text{two}}");
      }

      String finalBinPlain = "$wholeBinGroupedPlain₂";
      String finalBinLaTeX = "${wholeBinGroupedLaTeX}_{\\text{two}}";
      String inputDispPlain = "${groupDigitsPlain(whole.toString())}₁₀";
      String inputDispLaTeX = "${groupDigitsLaTeX(whole.toString())}_{\\text{ten}}";

      if (hasFrac) {
        inputDispPlain = whole > 0
            ? "$whole $simpNum/$simpDen₁₀ (${fmtDec(whole + simpNum / simpDen, maxDecimals: 6)}₁₀)"
            : "$simpNum/$simpDen₁₀ (${fmtDec(simpNum / simpDen, maxDecimals: 6)}₁₀)";
        inputDispLaTeX = whole > 0
            ? "$whole\\frac{$simpNum}{$simpDen}_{\\text{ten}}"
            : "\\left(\\frac{$simpNum}{$simpDen}\\right)_{\\text{ten}}";

        workings.add("");
        final Map<String, dynamic> fracRes = convertBase10FractionToBinary(
          rawNum: simpNum,
          rawDen: simpDen,
        );
        workings.addAll(fracRes['workings'] as List<String>);
        steps.addAll(fracRes['steps'] as List<OtherBasesToBinaryStep>);
        ladders.addAll(fracRes['extraLadders'] as List<DivisionLadderTable>);

        final String fracGroupedPlain =
        fracRes['fracBitsGroupedPlain'] as String;
        final String fracGroupedLaTeX =
        fracRes['fracBitsGroupedLaTeX'] as String;

        finalBinPlain = "$wholeBinGroupedPlain.$fracGroupedPlain₂";
        finalBinLaTeX = "$wholeBinGroupedLaTeX.${fracGroupedLaTeX}_{\\text{two}}";

        workings.add("");
        workings.add(
            "\\text{\\textbf{Final Step: Combine Whole-Number and Fractional Binary Parts}}");
        workings.add(
            "\\therefore \\; $inputDispLaTeX = \\mathbf{$finalBinLaTeX}");

        steps.add(OtherBasesToBinaryStep(
          title: "Final Step: Combine Whole and Fractional Binary Parts",
          description:
          "Join the binary whole-number part ($wholeBinGroupedPlain₂) and the binary fractional part (0.${fracGroupedPlain}₂) at the binary point:\n"
              "• $inputDispPlain = $finalBinPlain.",
          mathLaTeX: "$inputDispLaTeX = \\boxed{$finalBinLaTeX}",
        ));
      }

      return OtherBasesToBinaryResult(
        mode: 0,
        finalAnswers: {
          "Base 10 Input": inputDispPlain,
          "Binary Equivalent (Base 2)": finalBinPlain,
          if (hasFrac) "Fractional Part (Base 10)": "$simpNum/$simpDen₁₀",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: OtherBasesToBinaryCanvasData(
          mode: 0,
          baseInt: 10,
          baseWord: 'ten',
          stage1Cells: const [],
          divisionLadders: ladders,
          headerBadge: "$inputDispPlain  =  $finalBinPlain",
          subBadge:
          "Divide repeatedly by 2 and read the remainders (0 or 1) upwards from bottom to top (↑)",
          bottomSummaryBanner: "Final Binary Answer = $finalBinPlain",
        ),
      );
    } catch (e) {
      return OtherBasesToBinaryResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter a valid Base 10 whole number, decimal, mixed number, or fraction.",
      );
    }
  }

  // ===========================================================================
  // MODES 1 & 2: OTHER NUMBER BASES (WHOLE & FRACTIONAL) TO BINARY
  // Matches Example 4b (124_five), Example 4c (306.43_eight) & Exercise 1.3 #3a–i
  // ===========================================================================
  static OtherBasesToBinaryResult solveOtherBaseToBinary({
    required int mode, // 1: Whole Number in Base b, 2: Fractional Number in Base b
    required String rawInputStr,
    required int baseInt,
  }) {
    try {
      final Map<String, dynamic> stage1 = expandOtherBaseToBase10(
        rawInputStr: rawInputStr,
        baseInt: baseInt,
      );

      final String cleanNum = stage1['cleanNumberStr'] as String;
      final String groupedInLaTeX = stage1['groupedInLaTeX'] as String;
      final String bWord = stage1['bWord'] as String;
      final String bSub = stage1['bSub'] as String;
      final List<BaseExpansionCell> cells =
      stage1['cells'] as List<BaseExpansionCell>;
      final int wholeSum = stage1['wholeSum'] as int;
      final int simpNum = stage1['simpNum'] as int;
      final int simpDen = stage1['simpDen'] as int;
      final String base10SummaryPlain = stage1['base10SummaryPlain'] as String;
      final bool hasFrac = simpNum > 0 && simpDen > 1;

      final List<String> workings = [
        ...(stage1['stage1Workings'] as List<String>),
        "",
      ];
      final List<OtherBasesToBinaryStep> steps = [
        stage1['stage1Step'] as OtherBasesToBinaryStep,
      ];
      final List<DivisionLadderTable> ladders = [];

      // Stage 2A: Convert Whole-Number Part to Binary by Repeated Division by 2
      final List<BinaryDivisionRow> wholeRows = buildDivisionBy2Rows(wholeSum);
      final String wholeBinRaw = rowsToBinaryString(wholeRows);
      final String wholeBinGroupedPlain = groupDigitsPlain(wholeBinRaw);
      final String wholeBinGroupedLaTeX = groupDigitsLaTeX(wholeBinRaw);

      ladders.add(DivisionLadderTable(
        title: "Whole Part: $wholeSum₁₀ → $wholeBinGroupedPlain₂",
        startNumber: wholeSum,
        rows: wholeRows,
        binaryResultGrouped: "$wholeBinGroupedPlain₂",
      ));

      workings.add(
          "\\text{\\textbf{Stage 2: Convert Base 10 Whole Part }} ${wholeSum}_{\\text{ten}} \\text{\\textbf{ to Binary by Division by 2}}");
      for (final r in wholeRows) {
        workings.add(
            "${r.dividend} \\div 2 = ${r.quotient} \\text{ remainder } \\mathbf{${r.remainder}}");
      }
      workings.add(formatDivisionTableLaTeX(wholeRows));
      workings.add(
          "\\therefore \\; ${wholeSum}_{\\text{ten}} = \\mathbf{${wholeBinGroupedLaTeX}_{\\text{two}}}");

      final String divExplainPlain = wholeRows
          .map((r) =>
      "• ${r.dividend} ÷ 2 = ${r.quotient} remainder ${r.remainder}")
          .join('\n');

      steps.add(OtherBasesToBinaryStep(
        title:
        "Stage 2: Convert $wholeSum₁₀ to Binary by Repeated Division by 2",
        description:
        "Now convert the base 10 whole-number part ($wholeSum₁₀) to binary by dividing repeatedly by 2 down to quotient 0:\n"
            "$divExplainPlain\n"
            "• Reading the remainders upwards from bottom to top (↑) gives: $wholeSum₁₀ = ${wholeBinGroupedPlain}₂.",
        mathLaTeX:
        "${formatDivisionTableLaTeX(wholeRows)} \\implies ${wholeSum}_{\\text{ten}} = \\boxed{${wholeBinGroupedLaTeX}_{\\text{two}}}",
      ));

      String finalBinPlain = "$wholeBinGroupedPlain₂";
      String finalBinLaTeX = "${wholeBinGroupedLaTeX}_{\\text{two}}";

      if (hasFrac) {
        workings.add("");
        final Map<String, dynamic> fracRes = convertBase10FractionToBinary(
          rawNum: simpNum,
          rawDen: simpDen,
        );
        workings.addAll(fracRes['workings'] as List<String>);
        steps.addAll(fracRes['steps'] as List<OtherBasesToBinaryStep>);
        ladders.addAll(fracRes['extraLadders'] as List<DivisionLadderTable>);

        final String fracGroupedPlain =
        fracRes['fracBitsGroupedPlain'] as String;
        final String fracGroupedLaTeX =
        fracRes['fracBitsGroupedLaTeX'] as String;

        finalBinPlain = "$wholeBinGroupedPlain.$fracGroupedPlain₂";
        finalBinLaTeX = "$wholeBinGroupedLaTeX.${fracGroupedLaTeX}_{\\text{two}}";

        workings.add("");
        workings.add(
            "\\text{\\textbf{Final Step: Combine Whole and Fractional Binary Parts}}");
        workings.add(
            "\\therefore \\; ${groupedInLaTeX}_{\\text{$bWord}} = \\mathbf{$finalBinLaTeX}");

        steps.add(OtherBasesToBinaryStep(
          title:
          "Final Step: Combine Whole ($wholeBinGroupedPlain₂) & Fractional (0.$fracGroupedPlain₂) Parts",
          description:
          "Combine the binary whole-number part and the binary fractional part to complete the conversion of $cleanNum$bSub:\n"
              "• $cleanNum$bSub = $base10SummaryPlain = $finalBinPlain!",
          mathLaTeX:
          "\\therefore \\; ${groupedInLaTeX}_{\\text{$bWord}} = \\boxed{$finalBinLaTeX}",
        ));
      } else {
        workings.add(
            "\\therefore \\; ${groupedInLaTeX}_{\\text{$bWord}} = \\mathbf{$finalBinLaTeX}");
      }

      return OtherBasesToBinaryResult(
        mode: mode,
        finalAnswers: {
          "Given Number": "$cleanNum$bSub (Base $bWord)",
          "Stage 1 (In Base 10)": base10SummaryPlain,
          "Final Binary (Base 2)": finalBinPlain,
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: OtherBasesToBinaryCanvasData(
          mode: mode,
          baseInt: baseInt,
          baseWord: bWord,
          stage1Cells: cells,
          divisionLadders: ladders,
          headerBadge:
          "$cleanNum$bSub  ➔  $base10SummaryPlain  ➔  $finalBinPlain",
          subBadge:
          "Stage 1: Expand in Powers of $baseInt to Base 10   |   Stage 2: Divide by 2 to Get Binary",
          bottomSummaryBanner: "$cleanNum$bSub = $finalBinPlain",
        ),
      );
    } catch (e) {
      return OtherBasesToBinaryResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid number for base $baseInt.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: POWERS (N_b)^k TO BINARY (Ex 1.3 #3j) & BICIMAL REVISION (Ex 1.3 #2a–f)
  // ===========================================================================
  static OtherBasesToBinaryResult solvePowerOrBicimalRevision({
    required int subMode, // 0: Express (N_b)^k in Binary (Ex 1.3 #3j), 1: Bicimal to Base 10 Revision (Ex 1.3 #2a–f)
    required String inputStr,
    required int baseInt,
    required int exponentK,
  }) {
    try {
      if (subMode == 0) {
        // Sub-Mode 3A: Express (N_b)^k in Binary (Matches Exercise 1.3 #3j: (9_ten)^2)
        final Map<String, dynamic> stage1 = expandOtherBaseToBase10(
          rawInputStr: inputStr,
          baseInt: baseInt,
        );
        final int simpNum = stage1['simpNum'] as int;
        if (simpNum > 0) {
          throw const FormatException(
              "Please enter a whole number inside the brackets for Mode 3A.");
        }

        final String cleanNum = stage1['cleanNumberStr'] as String;
        final String bWord = stage1['bWord'] as String;
        final String bSub = stage1['bSub'] as String;
        final int base10Val = stage1['wholeSum'] as int;
        final int k = exponentK.clamp(1, 5);
        final String kSup = toUnicodeSuperscript(k);

        final int poweredBase10 = intPow(base10Val, k);
        final String repeatedMult =
        List.filled(k, base10Val.toString()).join(' \\times ');

        final List<BinaryDivisionRow> divRows =
        buildDivisionBy2Rows(poweredBase10);
        final String binRaw = rowsToBinaryString(divRows);
        final String binGroupedPlain = groupDigitsPlain(binRaw);
        final String binGroupedLaTeX = groupDigitsLaTeX(binRaw);

        final List<String> workings = [];
        final List<OtherBasesToBinaryStep> steps = [];

        if (baseInt != 10) {
          workings.addAll(stage1['stage1Workings'] as List<String>);
          workings.add("");
          steps.add(stage1['stage1Step'] as OtherBasesToBinaryStep);
        }

        workings.add(
            "\\text{\\textbf{Evaluate the Power }} (${cleanNum}_{\\text{$bWord}})^$k \\text{\\textbf{ in Base 10 (Exercise 1.3 \\#3j)}}");
        workings.add(
            "(${cleanNum}_{\\text{$bWord}})^$k = (${base10Val}_{\\text{ten}})^$k = $repeatedMult = \\mathbf{${poweredBase10}_{\\text{ten}}}");
        workings.add("");
        workings.add(
            "\\text{\\textbf{Convert }} ${poweredBase10}_{\\text{ten}} \\text{\\textbf{ to Binary by Repeated Division by 2}}");
        for (final r in divRows) {
          workings.add(
              "${r.dividend} \\div 2 = ${r.quotient} \\text{ remainder } \\mathbf{${r.remainder}}");
        }
        workings.add(formatDivisionTableLaTeX(divRows));
        workings.add(
            "\\therefore \\; (${cleanNum}_{\\text{$bWord}})^$k = ${poweredBase10}_{\\text{ten}} = \\mathbf{${binGroupedLaTeX}_{\\text{two}}}");

        steps.add(OtherBasesToBinaryStep(
          title:
          "Step ${steps.length + 1}: Evaluate ($cleanNum$bSub)$kSup in Base 10",
          description:
          "Multiply $base10Val₁₀ by itself $k times to find the value of ($cleanNum$bSub)$kSup in base 10:\n"
              "• ($base10Val₁₀)$kSup = ${List.filled(k, base10Val.toString()).join(' × ')} = ${poweredBase10}₁₀.",
          mathLaTeX:
          "(${cleanNum}_{\\text{$bWord}})^$k = $repeatedMult = ${poweredBase10}_{\\text{ten}}",
        ));

        steps.add(OtherBasesToBinaryStep(
          title:
          "Step ${steps.length + 1}: Convert $poweredBase10₁₀ to Binary by Division by 2",
          description:
          "Divide $poweredBase10 repeatedly by 2 and read the remainders upwards from bottom to top (↑):\n"
              "• $poweredBase10₁₀ = $binGroupedPlain₂.",
          mathLaTeX:
          "${formatDivisionTableLaTeX(divRows)} \\implies (${cleanNum}_{\\text{$bWord}})^$k = \\boxed{${binGroupedLaTeX}_{\\text{two}}}",
        ));

        return OtherBasesToBinaryResult(
          mode: 3,
          subMode: 0,
          finalAnswers: {
            "Given Expression": "($cleanNum$bSub)$kSup",
            "Value in Base 10": "$poweredBase10₁₀",
            "Value in Binary (Base 2)": "$binGroupedPlain₂",
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: OtherBasesToBinaryCanvasData(
            mode: 3,
            baseInt: baseInt,
            baseWord: bWord,
            stage1Cells: baseInt != 10
                ? (stage1['cells'] as List<BaseExpansionCell>)
                : const [],
            divisionLadders: [
              DivisionLadderTable(
                title: "($base10Val₁₀)$kSup = $poweredBase10₁₀ → $binGroupedPlain₂",
                startNumber: poweredBase10,
                rows: divRows,
                binaryResultGrouped: "$binGroupedPlain₂",
              ),
            ],
            headerBadge:
            "($cleanNum$bSub)$kSup  =  $poweredBase10₁₀  =  $binGroupedPlain₂",
            subBadge:
            "Step 1: Evaluate Power in Base 10   |   Step 2: Divide by 2 to Convert to Binary",
            bottomSummaryBanner: "($cleanNum$bSub)$kSup = $binGroupedPlain₂",
          ),
        );
      } else {
        // Sub-Mode 3B: Bicimal & Binary to Base 10 Revision (Exercise 1.3 #2a–f)
        final Map<String, dynamic> stage1 = expandOtherBaseToBase10(
          rawInputStr: inputStr,
          baseInt: 2,
        );
        final String cleanNum = stage1['cleanNumberStr'] as String;
        final List<BaseExpansionCell> cells =
        stage1['cells'] as List<BaseExpansionCell>;
        final int wholeSum = stage1['wholeSum'] as int;
        final int simpNum = stage1['simpNum'] as int;
        final int simpDen = stage1['simpDen'] as int;
        final double exactDec = stage1['exactDec'] as double;
        final bool hasFrac = simpNum > 0 && simpDen > 1;

        final String decPlain = "${fmtDec(exactDec, maxDecimals: 6)}₁₀";
        final String fracPlain =
        hasFrac ? "$wholeSum $simpNum/$simpDen₁₀" : "$wholeSum₁₀";

        final List<String> workings = [
          ...(stage1['stage1Workings'] as List<String>),
          if (hasFrac)
            "\\text{As a Base 10 Decimal: } $wholeSum + \\frac{$simpNum}{$simpDen} = \\mathbf{${fmtDec(exactDec, maxDecimals: 6)}_{\\text{ten}}}",
        ];

        return OtherBasesToBinaryResult(
          mode: 3,
          subMode: 1,
          finalAnswers: {
            "Binary / Bicimal Input": "${groupDigitsPlain(cleanNum)}₂",
            if (hasFrac) "Base 10 (Mixed Fraction)": fracPlain,
            "Base 10 (Decimal)": decPlain,
          },
          workingsLaTeX: workings,
          steps: [
            stage1['stage1Step'] as OtherBasesToBinaryStep,
          ],
          canvasData: OtherBasesToBinaryCanvasData(
            mode: 3,
            baseInt: 2,
            baseWord: 'two',
            stage1Cells: cells,
            divisionLadders: const [],
            headerBadge:
            "${groupDigitsPlain(cleanNum)}₂  =  ${hasFrac ? '$fracPlain  ($decPlain)' : decPlain}",
            subBadge:
            "Exercise 1.3 #2 Revision: Expand each binary digit in positive and negative powers of 2",
            bottomSummaryBanner:
            "Base 10 Value = ${hasFrac ? '$fracPlain = $decPlain' : decPlain}",
          ),
        );
      }
    } catch (e) {
      return OtherBasesToBinaryResult.error(
        mode: 3,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid number.",
      );
    }
  }
}