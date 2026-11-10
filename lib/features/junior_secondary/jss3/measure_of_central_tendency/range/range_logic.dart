import 'range_models.dart';

class _Frac {
  final int num;
  final int den;

  const _Frac(this.num, [this.den = 1]);

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
    return ((a * b).abs()) ~/ gcd(a, b);
  }

  factory _Frac.from(int n, [int d = 1]) {
    if (d == 0) throw const FormatException("Denominator cannot be zero.");
    if (n == 0) return const _Frac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _Frac(sign * (an ~/ g), ad ~/ g);
  }

  double get toDouble => num / den;
  bool get isInteger => den == 1;
  bool get isFraction => den != 1;

  _Frac operator +(_Frac other) =>
      _Frac.from(num * other.den + other.num * den, den * other.den);
  _Frac operator -(_Frac other) =>
      _Frac.from(num * other.den - other.num * den, den * other.den);

  String toLaTeX() {
    if (num == 0) return '0';
    final String sign = num < 0 ? '-' : '';
    final int an = num.abs();
    if (den == 1) return '$sign$an';
    return '$sign\\frac{$an}{$den}';
  }

  String toMixedLaTeX() {
    if (den == 1 || num.abs() < den) return toLaTeX();
    final String sign = num < 0 ? '-' : '';
    final int an = num.abs();
    final int whole = an ~/ den;
    final int rem = an % den;
    if (rem == 0) return '$sign$whole';
    return '$sign$whole\\frac{$rem}{$den}';
  }
}

class _RangeUnitFormat {
  final String prefixLaTeX;
  final String suffixLaTeX;
  final String prefixPlain;
  final String suffixPlain;

  const _RangeUnitFormat({
    this.prefixLaTeX = '',
    this.suffixLaTeX = '',
    this.prefixPlain = '',
    this.suffixPlain = '',
  });
}

class _RangeToken {
  final String raw;
  final _Frac frac;
  final int origNum;
  final int origDen;
  final bool isMixed;
  final int? mixedWhole;
  final int? mixedNum;
  final int? mixedDen;
  final bool isFractionInput;
  final bool isDecimalInput;
  final String displayLaTeX;
  final String displayPlain;

  const _RangeToken({
    required this.raw,
    required this.frac,
    required this.origNum,
    required this.origDen,
    this.isMixed = false,
    this.mixedWhole,
    this.mixedNum,
    this.mixedDen,
    this.isFractionInput = false,
    this.isDecimalInput = false,
    required this.displayLaTeX,
    required this.displayPlain,
  });

  double get value => frac.toDouble;
}

class RangeLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Page 217 Example 7, Exercise 18.4 & Page 218 Rev Ex 18)
  // ===========================================================================
  static const List<RangePreset> textbookPresets = [
    RangePreset(
      chipLabel:
      "Example 7 (Page 217): 10 Girls' Heights 1.2, 1.3, 1.2, 1.7, 1.2, 1.3, 1.4, 1.1, 1.5, 1.3",
      mode: 0,
      input1: "1.2, 1.3, 1.2, 1.7, 1.2, 1.3, 1.4, 1.1, 1.5, 1.3",
      unit: "m",
    ),
    RangePreset(
      chipLabel: "Ex 18.4 #1a (Page 217): 63, 55, 43, 52, 44",
      mode: 0,
      input1: "63, 55, 43, 52, 44",
    ),
    RangePreset(
      chipLabel: "Ex 18.4 #1b (Page 217): 120, 100, 130, 1000, 150, 140",
      mode: 0,
      input1: "120, 100, 130, 1000, 150, 140",
    ),
    RangePreset(
      chipLabel: "Ex 18.4 #1c (Page 217): 6, 7, 8, 9, 10, 20",
      mode: 0,
      input1: "6, 7, 8, 9, 10, 20",
    ),
    RangePreset(
      chipLabel: "Ex 18.4 #1d (Page 217): 65, 72, 77, 84, 90",
      mode: 0,
      input1: "65, 72, 77, 84, 90",
    ),
    RangePreset(
      chipLabel:
      "Ex 18.4 #1e (Page 217): 50, 54, 60, 63, 52, 63, 70, 59, 67, 50",
      mode: 0,
      input1: "50, 54, 60, 63, 52, 63, 70, 59, 67, 50",
    ),
    RangePreset(
      chipLabel:
      "Ex 18.4 #1f (Page 217): 149, 148, 150, 145, 148, 151, 152",
      mode: 0,
      input1: "149, 148, 150, 145, 148, 151, 152",
    ),
    RangePreset(
      chipLabel:
      "Ex 18.4 #2 (Page 217): Oldest = 20 years, Youngest = 12 years",
      mode: 1,
      input1: "20",
      input2: "12",
      unit: "years",
    ),
    RangePreset(
      chipLabel:
      "Ex 18.4 #3 (Page 217): Range = 105, Highest = 199 (Find Smallest)",
      mode: 2,
      input1: "105",
      input2: "199",
    ),
    RangePreset(
      chipLabel:
      "Ex 18.4 #4 (Page 217): 10 Students' Heights 1.2, 1.1, 1.4, 1.3, 1.0, 1.5, 1.7, 1.15, 1.6, 1.3",
      mode: 0,
      input1: "1.2, 1.1, 1.4, 1.3, 1.0, 1.5, 1.7, 1.15, 1.6, 1.3",
      unit: "m",
    ),
    RangePreset(
      chipLabel:
      "Ex 18.4 #5 (Page 217): Six Pigs' Weights 24.3, 21.0, 27.0, 16, 21, 20 kg",
      mode: 0,
      input1: "24.3, 21.0, 27.0, 16, 21, 20",
      unit: "kg",
    ),
    RangePreset(
      chipLabel:
      "Rev Ex 18 #1b (Page 218): Swimming Club Ages 10, 11, 9, 11, 12, 9, 13, 10, 11, 12, 11, 13",
      mode: 0,
      input1: "10, 11, 9, 11, 12, 9, 13, 10, 11, 12, 11, 13",
      unit: "years",
    ),
    RangePreset(
      chipLabel: "Rev Ex 18 #2a (Page 218): 4, 8, 16, 8, 14, 2, 14, 12, 10, 12",
      mode: 0,
      input1: "4, 8, 16, 8, 14, 2, 14, 12, 10, 12",
    ),
    RangePreset(
      chipLabel:
      "Rev Ex 18 #2b (Page 218, Mixed Fractions): 6, 7 1/2, 6 1/2, 5, 12, 8",
      mode: 0,
      input1: "6, 7 1/2, 6 1/2, 5, 12, 8",
    ),
    RangePreset(
      chipLabel:
      "Rev Ex 18 #2c (Page 218, Mixed Fractions): 12, 17 1/2, 22, 14, 17",
      mode: 0,
      input1: "12, 17 1/2, 22, 14, 17",
    ),
    RangePreset(
      chipLabel:
      "Rev Ex 18 #2e (Page 218, Decimals): 6.2, 8.25, 13.95, 1.75, 13.05",
      mode: 0,
      input1: "6.2, 8.25, 13.95, 1.75, 13.05",
    ),
  ];

  static String _cleanDouble(double v, {int decimals = 4}) {
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    String s = v.toStringAsFixed(decimals);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
    return s;
  }

  static _RangeUnitFormat _formatUnit(String rawUnit) {
    final String u = rawUnit.trim();
    if (u.isEmpty) return const _RangeUnitFormat();
    if (u == '₦' || u == r'$' || u == '£') {
      return _RangeUnitFormat(
        prefixLaTeX: '\\text{$u}',
        suffixLaTeX: '',
        prefixPlain: u,
        suffixPlain: '',
      );
    }
    return _RangeUnitFormat(
      prefixLaTeX: '',
      suffixLaTeX: '\\text{ $u}',
      prefixPlain: '',
      suffixPlain: ' $u',
    );
  }

  static _RangeToken _parseToken(String rawToken) {
    final String s = rawToken
        .trim()
        .replaceAll('₦', '')
        .replaceAll(r'$', '')
        .replaceAll('£', '')
        .replaceAll('−', '-')
        .replaceAll(
      RegExp(r'\b(kg|cm|mm|km|m|g|years|yrs|marks|goals|children)\b',
          caseSensitive: false),
      '',
    )
        .trim();

    if (s.isEmpty) {
      throw const FormatException("Empty number entry detected.");
    }

    final RegExp mixedReg = RegExp(r'^([+-]?\d+)\s+(\d+)\s*/\s*(\d+)$');
    final Match? mm = mixedReg.firstMatch(s);
    if (mm != null) {
      final int w = int.parse(mm.group(1)!);
      final int n = int.parse(mm.group(2)!);
      final int d = int.parse(mm.group(3)!);
      if (d == 0) throw const FormatException("Denominator cannot be zero.");
      final int sign = w < 0 ? -1 : 1;
      final int impNum = sign * (w.abs() * d + n);
      return _RangeToken(
        raw: s,
        frac: _Frac.from(impNum, d),
        origNum: impNum,
        origDen: d,
        isMixed: true,
        mixedWhole: w,
        mixedNum: n,
        mixedDen: d,
        isFractionInput: true,
        displayLaTeX: '$w\\frac{$n}{$d}',
        displayPlain: '$w $n/$d',
      );
    }

    final RegExp fracReg = RegExp(r'^([+-]?\d+)\s*/\s*(\d+)$');
    final Match? fm = fracReg.firstMatch(s);
    if (fm != null) {
      final int n = int.parse(fm.group(1)!);
      final int d = int.parse(fm.group(2)!);
      if (d == 0) throw const FormatException("Denominator cannot be zero.");
      return _RangeToken(
        raw: s,
        frac: _Frac.from(n, d),
        origNum: n,
        origDen: d,
        isFractionInput: true,
        displayLaTeX: '\\frac{$n}{$d}',
        displayPlain: '$n/$d',
      );
    }

    if (s.contains('.')) {
      final double? dv = double.tryParse(s);
      if (dv == null) throw FormatException("Invalid decimal '$rawToken'.");
      final List<String> parts = s.split('.');
      int d = 1;
      for (int i = 0; i < parts[1].length; i++) {
        d *= 10;
      }
      final int sign = s.startsWith('-') ? -1 : 1;
      final String wholeRaw = parts[0].replaceAll('-', '').replaceAll('+', '');
      final int wholeAbs = wholeRaw.isEmpty ? 0 : int.parse(wholeRaw);
      final int decInt = int.parse(parts[1]);
      final int totalNum = sign * (wholeAbs * d + decInt);
      return _RangeToken(
        raw: s,
        frac: _Frac.from(totalNum, d),
        origNum: totalNum,
        origDen: d,
        isDecimalInput: true,
        displayLaTeX: s,
        displayPlain: s,
      );
    }

    final int? iv = int.tryParse(s);
    if (iv == null) {
      throw FormatException("Could not read '$rawToken' as a valid number.");
    }
    return _RangeToken(
      raw: s,
      frac: _Frac.from(iv, 1),
      origNum: iv,
      origDen: 1,
      displayLaTeX: '$iv',
      displayPlain: '$iv',
    );
  }

  static List<_RangeToken> _parseList(String rawList) {
    final String normalized =
    rawList.replaceAll(RegExp(r'\band\b', caseSensitive: false), ',');
    final List<String> parts = normalized
        .split(RegExp(r'[,;\n]+'))
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      throw const FormatException(
        "Please enter numbers separated by commas (e.g. 63, 55, 43, 52, 44).",
      );
    }
    return parts.map(_parseToken).toList();
  }

  // ===========================================================================
  // MASTER ROUTER
  // ===========================================================================
  static RangeResult solveRange({
    required int mode,
    required String rawInput1,
    String rawInput2 = '',
    String unit = '',
  }) {
    try {
      String detectedUnit = unit.trim();
      if (detectedUnit.isEmpty) {
        final Match? um = RegExp(
          r'\b(kg|cm|mm|km|m|g|years|yrs|marks|goals)\b',
          caseSensitive: false,
        ).firstMatch(rawInput1);
        if (um != null) detectedUnit = um.group(1)!;
      }

      if (mode == 0) {
        return _solveDataListRange(rawInput1, detectedUnit);
      } else if (mode == 1) {
        return _solveDirectExtremes(rawInput1, rawInput2, detectedUnit);
      } else if (mode == 2) {
        return _solveMissingSmallest(rawInput1, rawInput2, detectedUnit);
      } else {
        return _solveMissingHighest(rawInput1, rawInput2, detectedUnit);
      }
    } catch (e) {
      return RangeResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please check your numbers and try again.",
      );
    }
  }

  // ===========================================================================
  // MODE 0: UNGROUPED DATA LIST RANGE (Example 7, Ex 18.4 #1, #4, #5 & Rev Ex 18 #2)
  // ===========================================================================
  static RangeResult _solveDataListRange(String rawList, String unit) {
    final List<_RangeToken> items = _parseList(rawList);
    if (items.length < 2) {
      throw const FormatException(
        "Please enter at least 2 values separated by commas to find the range.",
      );
    }

    final _RangeUnitFormat u = _formatUnit(unit);
    final bool hasFractions = items.any((_RangeToken e) => e.isFractionInput);

    final List<String> conversionLinesLaTeX = [];
    final List<String> conversionBulletsPlain = [];
    if (hasFractions) {
      for (final _RangeToken item in items) {
        if (item.isMixed) {
          final int w = item.mixedWhole!.abs();
          final int mn = item.mixedNum!;
          final int md = item.mixedDen!;
          conversionLinesLaTeX.add(
            "\\bullet \\; ${item.displayLaTeX} = \\frac{(${item.mixedWhole} \\times $md) + $mn}{$md} = \\frac{${w * md} + $mn}{$md} = \\frac{${item.origNum}}{$md} = ${_cleanDouble(item.value)}",
          );
          conversionBulletsPlain.add(
            "• Convert ${item.displayPlain} = ${item.origNum}/$md = ${_cleanDouble(item.value)}",
          );
        } else if (item.isFractionInput) {
          conversionLinesLaTeX.add(
            "\\bullet \\; ${item.displayLaTeX} = ${_cleanDouble(item.value)}",
          );
          conversionBulletsPlain.add(
            "• Convert ${item.displayPlain} = ${_cleanDouble(item.value)}",
          );
        }
      }
    }

    final List<_RangeToken> sorted = List<_RangeToken>.from(items)
      ..sort((_RangeToken a, _RangeToken b) => a.value.compareTo(b.value));

    final _RangeToken lowest = sorted.first;
    final _RangeToken highest = sorted.last;
    final _Frac diffFrac = highest.frac - lowest.frac;
    final double diffVal = highest.value - lowest.value;
    final String diffDecStr = _cleanDouble(diffVal);

    final List<String> subtractionLinesLaTeX = [
      "\\text{Range} = \\text{Highest value} - \\text{Lowest value}",
      "\\text{Range} = \\left(${highest.displayLaTeX} - ${lowest.displayLaTeX}\\right)${u.suffixLaTeX}",
    ];

    if (hasFractions && (highest.isFractionInput || lowest.isFractionInput)) {
      final int lcd = _Frac.lcm(highest.origDen, lowest.origDen);
      final int hScaled = highest.origNum * (lcd ~/ highest.origDen);
      final int lScaled = lowest.origNum * (lcd ~/ lowest.origDen);
      final int diffScaled = hScaled - lScaled;
      subtractionLinesLaTeX.addAll([
        "\\text{Convert to improper fractions with common denominator } ($lcd):",
        "\\text{Range} = \\frac{${highest.origNum}}{${highest.origDen}} - \\frac{${lowest.origNum}}{${lowest.origDen}} = \\frac{$hScaled - $lScaled}{$lcd} = \\frac{$diffScaled}{$lcd}",
        if (diffFrac.isFraction)
          "\\text{Simplified fraction / mixed number: } \\mathbf{${u.prefixLaTeX}${diffFrac.toMixedLaTeX()}${u.suffixLaTeX}} \\; \\left(\\text{or } ${u.prefixLaTeX}$diffDecStr${u.suffixLaTeX}\\right)",
      ]);
    }

    subtractionLinesLaTeX.add(
      "\\therefore \\; \\text{Range} = \\mathbf{${u.prefixLaTeX}$diffDecStr${u.suffixLaTeX}}",
    );

    final String colSpec = List.filled(sorted.length, 'c').join('|');
    final String headers = List.generate(sorted.length, (int i) {
      if (i == 0) return "\\mathbf{\\text{Lowest (Min)}}";
      if (i == sorted.length - 1) return "\\mathbf{\\text{Highest (Max)}}";
      return "\\text{Item ${i + 1}}";
    }).join(' & ');
    final String rowCells = List.generate(sorted.length, (int i) {
      if (i == 0 || i == sorted.length - 1) {
        return "\\mathbf{[${sorted[i].displayLaTeX}]}";
      }
      return sorted[i].displayLaTeX;
    }).join(' & ');

    final String orderedBoxLaTeX =
        "\\begin{array}{|$colSpec|} \\hline $headers \\\\ \\hline $rowCells \\\\ \\hline \\end{array}";

    final String finalRangeDisplayLaTeX = hasFractions && diffFrac.isFraction
        ? "${u.prefixLaTeX}${diffFrac.toMixedLaTeX()}${u.suffixLaTeX} \\; (${u.prefixLaTeX}$diffDecStr${u.suffixLaTeX})"
        : "${u.prefixLaTeX}$diffDecStr${u.suffixLaTeX}";

    final List<String> workings = [
      "\\text{\\textbf{Given Set of Data (Page 217):}}",
      "\\mathbf{${items.map((_RangeToken e) => e.displayLaTeX).join(', \\; ')}}",
      "",
      if (hasFractions) ...[
        "\\text{\\textbf{Step 1: Convert Mixed Numbers / Fractions}}",
        ...conversionLinesLaTeX,
        "",
      ],
      "\\text{\\textbf{Step ${hasFractions ? 2 : 1}: Arrange in Ascending Order to Identify Lowest \\& Highest Values}}",
      "\\text{Ordered Data: } ${sorted.map((_RangeToken e) => e.displayLaTeX).join(', \\; ')}",
      "\\text{Highest value} = \\mathbf{${u.prefixLaTeX}${highest.displayLaTeX}${u.suffixLaTeX}}",
      "\\text{Lowest value} = \\mathbf{${u.prefixLaTeX}${lowest.displayLaTeX}${u.suffixLaTeX}}",
      "",
      "\\text{\\textbf{Step ${hasFractions ? 3 : 2}: Subtract the Lowest Value from the Highest Value (Example 7, Page 217)}}",
      ...subtractionLinesLaTeX,
    ];

    final List<RangeStep> steps = [
      const RangeStep(
        title: "Step 1: State the Definition and Formula for Range (Page 217)",
        description:
        "• The range is the difference between the highest and lowest values in a given set of data.",
        mathLinesLaTeX: [
          r"\text{Range} = \text{Highest value} - \text{Lowest value}",
        ],
      ),
      if (hasFractions)
        RangeStep(
          title: "Step 2: Convert Mixed Numbers into Improper Fractions & Decimals",
          description:
          "• Convert each mixed fraction so we can compare their sizes and subtract accurately:\n"
              "${conversionBulletsPlain.join('\n')}",
          mathLinesLaTeX: conversionLinesLaTeX,
        ),
      RangeStep(
        title:
        "Step ${hasFractions ? 3 : 2}: Arrange the Data in Order of Size to Pick the Highest and Lowest Values",
        description:
        "• Arrange the values from smallest to largest: ${sorted.map((_RangeToken e) => e.displayPlain).join(', ')}.\n"
            "• Highest value = ${u.prefixPlain}${highest.displayPlain}${u.suffixPlain}; Lowest value = ${u.prefixPlain}${lowest.displayPlain}${u.suffixPlain}.",
        mathLinesLaTeX: [
          "\\text{Ascending order: } ${sorted.map((_RangeToken e) => e.displayLaTeX).join(', \\; ')}",
          "\\text{Highest value} = \\mathbf{${u.prefixLaTeX}${highest.displayLaTeX}${u.suffixLaTeX}}, \\quad \\text{Lowest value} = \\mathbf{${u.prefixLaTeX}${lowest.displayLaTeX}${u.suffixLaTeX}}",
        ],
      ),
      RangeStep(
        title:
        "Step ${hasFractions ? 4 : 3}: Subtract the Lowest Value from the Highest Value",
        description:
        "• Subtract ${lowest.displayPlain} from ${highest.displayPlain} to get ${u.prefixPlain}$diffDecStr${u.suffixPlain}.",
        mathLinesLaTeX: subtractionLinesLaTeX,
      ),
    ];

    return RangeResult(
      mode: 0,
      finalAnswersLaTeX: {
        "Highest Value": "${u.prefixLaTeX}${highest.displayLaTeX}${u.suffixLaTeX}",
        "Lowest Value": "${u.prefixLaTeX}${lowest.displayLaTeX}${u.suffixLaTeX}",
        "Range": "\\mathbf{$finalRangeDisplayLaTeX}",
      },
      workingsLaTeX: workings,
      steps: steps,
      canvasData: RangeCanvasData(
        headerLaTeX:
        "\\text{Chapter 18 Range of Data (Example 7, Page 217): } \\text{Range} = \\text{Highest} - \\text{Lowest}",
        subHeaderLaTeX:
        "\\text{Range} = \\left(${highest.displayLaTeX} - ${lowest.displayLaTeX}\\right)${u.suffixLaTeX} = \\mathbf{$finalRangeDisplayLaTeX}",
        card1Title: "Lowest Value (Min)",
        card1LaTeX: "${u.prefixLaTeX}${lowest.displayLaTeX}${u.suffixLaTeX}",
        card2Title: "Highest Value (Max)",
        card2LaTeX: "${u.prefixLaTeX}${highest.displayLaTeX}${u.suffixLaTeX}",
        card3Title: "Range (Max − Min)",
        card3LaTeX: "\\mathbf{$finalRangeDisplayLaTeX}",
        mainBoxLaTeX: orderedBoxLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Range} = ${highest.displayLaTeX} - ${lowest.displayLaTeX} = \\mathbf{$finalRangeDisplayLaTeX}",
      ),
    );
  }

  // ===========================================================================
  // MODE 1: DIRECT EXTREMES (Exercise 18.4 #2, Page 217)
  // ===========================================================================
  static RangeResult _solveDirectExtremes(
      String rawHigh,
      String rawLow,
      String unit,
      ) {
    final _RangeToken t1 = _parseToken(rawHigh);
    final _RangeToken t2 = _parseToken(rawLow);

    final _RangeToken highest = t1.value >= t2.value ? t1 : t2;
    final _RangeToken lowest = t1.value >= t2.value ? t2 : t1;
    final _RangeUnitFormat u = _formatUnit(unit);

    final double diff = highest.value - lowest.value;
    final String diffStr = _cleanDouble(diff);

    final String boxLaTeX =
        "\\begin{array}{|c|c|c|} \\hline \\mathbf{\\text{Highest / Oldest}} & \\mathbf{\\text{Lowest / Youngest}} & \\mathbf{\\text{Range = Highest} - \\text{Lowest}} \\\\ \\hline "
        "${u.prefixLaTeX}${highest.displayLaTeX}${u.suffixLaTeX} & ${u.prefixLaTeX}${lowest.displayLaTeX}${u.suffixLaTeX} & ${highest.displayLaTeX} - ${lowest.displayLaTeX} = \\mathbf{${u.prefixLaTeX}$diffStr${u.suffixLaTeX}} \\\\ \\hline \\end{array}";

    return RangeResult(
      mode: 1,
      finalAnswersLaTeX: {
        "Highest Value": "${u.prefixLaTeX}${highest.displayLaTeX}${u.suffixLaTeX}",
        "Lowest Value": "${u.prefixLaTeX}${lowest.displayLaTeX}${u.suffixLaTeX}",
        "Range": "\\mathbf{${u.prefixLaTeX}$diffStr${u.suffixLaTeX}}",
      },
      workingsLaTeX: [
        "\\text{\\textbf{Step 1: Identify the Highest and Lowest Values (Exercise 18.4 No. 2, Page 217)}}",
        "\\text{Highest (Oldest) value} = \\mathbf{${u.prefixLaTeX}${highest.displayLaTeX}${u.suffixLaTeX}}",
        "\\text{Lowest (Youngest) value} = \\mathbf{${u.prefixLaTeX}${lowest.displayLaTeX}${u.suffixLaTeX}}",
        "",
        "\\text{\\textbf{Step 2: Subtract the Lowest Value from the Highest Value}}",
        "\\text{Range} = \\text{Highest value} - \\text{Lowest value}",
        "\\text{Range} = \\left(${highest.displayLaTeX} - ${lowest.displayLaTeX}\\right)${u.suffixLaTeX}",
        "\\therefore \\; \\text{Range} = \\mathbf{${u.prefixLaTeX}$diffStr${u.suffixLaTeX}}",
      ],
      steps: [
        RangeStep(
          title: "Step 1: Write Down the Given Extreme Values (Ex 18.4 #2)",
          description:
          "• Highest value = ${u.prefixPlain}${highest.displayPlain}${u.suffixPlain}\n"
              "• Lowest value = ${u.prefixPlain}${lowest.displayPlain}${u.suffixPlain}",
          mathLinesLaTeX: [
            "\\text{Highest value} = ${u.prefixLaTeX}${highest.displayLaTeX}${u.suffixLaTeX}, \\quad \\text{Lowest value} = ${u.prefixLaTeX}${lowest.displayLaTeX}${u.suffixLaTeX}",
          ],
        ),
        RangeStep(
          title: "Step 2: Subtract Lowest from Highest",
          description:
          "• Subtract ${lowest.displayPlain} from ${highest.displayPlain} to get ${u.prefixPlain}$diffStr${u.suffixPlain}.",
          mathLinesLaTeX: [
            "\\text{Range} = \\left(${highest.displayLaTeX} - ${lowest.displayLaTeX}\\right)${u.suffixLaTeX} = \\mathbf{${u.prefixLaTeX}$diffStr${u.suffixLaTeX}}",
          ],
        ),
      ],
      canvasData: RangeCanvasData(
        headerLaTeX:
        "\\text{Exercise 18.4 No. 2 Direct Extremes Range (Page 217)}",
        subHeaderLaTeX:
        "\\text{Range} = ${highest.displayLaTeX} - ${lowest.displayLaTeX} = \\mathbf{${u.prefixLaTeX}$diffStr${u.suffixLaTeX}}",
        card1Title: "Lowest Value",
        card1LaTeX: "${u.prefixLaTeX}${lowest.displayLaTeX}${u.suffixLaTeX}",
        card2Title: "Highest Value",
        card2LaTeX: "${u.prefixLaTeX}${highest.displayLaTeX}${u.suffixLaTeX}",
        card3Title: "Range",
        card3LaTeX: "\\mathbf{${u.prefixLaTeX}$diffStr${u.suffixLaTeX}}",
        mainBoxLaTeX: boxLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Range} = \\left(${highest.displayLaTeX} - ${lowest.displayLaTeX}\\right)${u.suffixLaTeX} = \\mathbf{${u.prefixLaTeX}$diffStr${u.suffixLaTeX}}",
      ),
    );
  }

  // ===========================================================================
  // MODE 2: FIND SMALLEST QUANTITY GIVEN RANGE & HIGHEST (Ex 18.4 #3, Page 217)
  // ===========================================================================
  static RangeResult _solveMissingSmallest(
      String rawRange,
      String rawHighest,
      String unit,
      ) {
    final _RangeToken rangeTok = _parseToken(rawRange);
    final _RangeToken highTok = _parseToken(rawHighest);
    final _RangeUnitFormat u = _formatUnit(unit);

    final double smallestVal = highTok.value - rangeTok.value;
    final String smallestStr = _cleanDouble(smallestVal);

    final String boxLaTeX =
        "\\begin{array}{|c|c|c|} \\hline \\mathbf{\\text{Given Highest}} & \\mathbf{\\text{Given Range}} & \\mathbf{\\text{Smallest = Highest} - \\text{Range}} \\\\ \\hline "
        "${highTok.displayLaTeX} & ${rangeTok.displayLaTeX} & ${highTok.displayLaTeX} - ${rangeTok.displayLaTeX} = \\mathbf{${u.prefixLaTeX}$smallestStr${u.suffixLaTeX}} \\\\ \\hline \\end{array}";

    return RangeResult(
      mode: 2,
      finalAnswersLaTeX: {
        "Given Range": "${u.prefixLaTeX}${rangeTok.displayLaTeX}${u.suffixLaTeX}",
        "Highest Quantity": "${u.prefixLaTeX}${highTok.displayLaTeX}${u.suffixLaTeX}",
        "Smallest Quantity": "\\mathbf{${u.prefixLaTeX}$smallestStr${u.suffixLaTeX}}",
      },
      workingsLaTeX: [
        "\\text{\\textbf{Step 1: Write Down the Range Formula (Exercise 18.4 No. 3, Page 217)}}",
        "\\text{Range} = \\text{Highest quantity} - \\text{Smallest quantity}",
        "",
        "\\text{\\textbf{Step 2: Substitute the Given Range and Highest Quantity}}",
        "${rangeTok.displayLaTeX} = ${highTok.displayLaTeX} - \\text{Smallest quantity}",
        "",
        "\\text{\\textbf{Step 3: Make Smallest Quantity the Subject of the Formula}}",
        "\\text{Smallest quantity} = \\text{Highest quantity} - \\text{Range}",
        "\\text{Smallest quantity} = ${highTok.displayLaTeX} - ${rangeTok.displayLaTeX}",
        "\\therefore \\; \\text{Smallest quantity} = \\mathbf{${u.prefixLaTeX}$smallestStr${u.suffixLaTeX}}",
      ],
      steps: [
        const RangeStep(
          title: "Step 1: State the Formula for Range (Page 217)",
          description:
          "• Start with the standard formula: Range = Highest quantity − Smallest quantity.",
          mathLinesLaTeX: [
            r"\text{Range} = \text{Highest quantity} - \text{Smallest quantity}",
          ],
        ),
        RangeStep(
          title: "Step 2: Substitute Known Values & Rearrange for Smallest Quantity",
          description:
          "• Substitute Range = ${rangeTok.displayPlain} and Highest quantity = ${highTok.displayPlain}.\n"
              "• Rearrange the equation so that Smallest quantity = Highest quantity − Range.",
          mathLinesLaTeX: [
            "${rangeTok.displayLaTeX} = ${highTok.displayLaTeX} - \\text{Smallest quantity}",
            "\\text{Smallest quantity} = ${highTok.displayLaTeX} - ${rangeTok.displayLaTeX} = \\mathbf{${u.prefixLaTeX}$smallestStr${u.suffixLaTeX}}",
          ],
        ),
      ],
      canvasData: RangeCanvasData(
        headerLaTeX:
        "\\text{Exercise 18.4 No. 3 Missing Smallest Quantity (Page 217)}",
        subHeaderLaTeX:
        "\\text{Smallest} = \\text{Highest} - \\text{Range} = ${highTok.displayLaTeX} - ${rangeTok.displayLaTeX} = \\mathbf{${u.prefixLaTeX}$smallestStr${u.suffixLaTeX}}",
        card1Title: "Given Range",
        card1LaTeX: "${u.prefixLaTeX}${rangeTok.displayLaTeX}${u.suffixLaTeX}",
        card2Title: "Highest Quantity",
        card2LaTeX: "${u.prefixLaTeX}${highTok.displayLaTeX}${u.suffixLaTeX}",
        card3Title: "Smallest Quantity",
        card3LaTeX: "\\mathbf{${u.prefixLaTeX}$smallestStr${u.suffixLaTeX}}",
        mainBoxLaTeX: boxLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Smallest quantity} = ${highTok.displayLaTeX} - ${rangeTok.displayLaTeX} = \\mathbf{${u.prefixLaTeX}$smallestStr${u.suffixLaTeX}}",
      ),
    );
  }

  // ===========================================================================
  // MODE 3: FIND HIGHEST QUANTITY GIVEN RANGE & SMALLEST
  // ===========================================================================
  static RangeResult _solveMissingHighest(
      String rawRange,
      String rawSmallest,
      String unit,
      ) {
    final _RangeToken rangeTok = _parseToken(rawRange);
    final _RangeToken lowTok = _parseToken(rawSmallest);
    final _RangeUnitFormat u = _formatUnit(unit);

    final double highestVal = rangeTok.value + lowTok.value;
    final String highestStr = _cleanDouble(highestVal);

    final String boxLaTeX =
        "\\begin{array}{|c|c|c|} \\hline \\mathbf{\\text{Given Smallest}} & \\mathbf{\\text{Given Range}} & \\mathbf{\\text{Highest = Smallest + Range}} \\\\ \\hline "
        "${lowTok.displayLaTeX} & ${rangeTok.displayLaTeX} & ${lowTok.displayLaTeX} + ${rangeTok.displayLaTeX} = \\mathbf{${u.prefixLaTeX}$highestStr${u.suffixLaTeX}} \\\\ \\hline \\end{array}";

    return RangeResult(
      mode: 3,
      finalAnswersLaTeX: {
        "Given Range": "${u.prefixLaTeX}${rangeTok.displayLaTeX}${u.suffixLaTeX}",
        "Smallest Quantity": "${u.prefixLaTeX}${lowTok.displayLaTeX}${u.suffixLaTeX}",
        "Highest Quantity": "\\mathbf{${u.prefixLaTeX}$highestStr${u.suffixLaTeX}}",
      },
      workingsLaTeX: [
        "\\text{\\textbf{Step 1: Write Down the Range Formula}}",
        "\\text{Range} = \\text{Highest quantity} - \\text{Smallest quantity}",
        "",
        "\\text{\\textbf{Step 2: Substitute the Given Range and Smallest Quantity}}",
        "${rangeTok.displayLaTeX} = \\text{Highest quantity} - ${lowTok.displayLaTeX}",
        "",
        "\\text{\\textbf{Step 3: Add Smallest Quantity to Both Sides}}",
        "\\text{Highest quantity} = \\text{Range} + \\text{Smallest quantity}",
        "\\text{Highest quantity} = ${rangeTok.displayLaTeX} + ${lowTok.displayLaTeX}",
        "\\therefore \\; \\text{Highest quantity} = \\mathbf{${u.prefixLaTeX}$highestStr${u.suffixLaTeX}}",
      ],
      steps: [
        const RangeStep(
          title: "Step 1: State the Formula for Range",
          description:
          "• Range = Highest quantity − Smallest quantity.",
          mathLinesLaTeX: [
            r"\text{Range} = \text{Highest quantity} - \text{Smallest quantity}",
          ],
        ),
        RangeStep(
          title: "Step 2: Make Highest Quantity the Subject and Add",
          description:
          "• Add the Smallest quantity (${lowTok.displayPlain}) to the Range (${rangeTok.displayPlain}) to obtain ${u.prefixPlain}$highestStr${u.suffixPlain}.",
          mathLinesLaTeX: [
            "\\text{Highest quantity} = \\text{Range} + \\text{Smallest quantity}",
            "\\text{Highest quantity} = ${rangeTok.displayLaTeX} + ${lowTok.displayLaTeX} = \\mathbf{${u.prefixLaTeX}$highestStr${u.suffixLaTeX}}",
          ],
        ),
      ],
      canvasData: RangeCanvasData(
        headerLaTeX: "\\text{Missing Highest Quantity Given Range \\& Smallest}",
        subHeaderLaTeX:
        "\\text{Highest} = \\text{Range} + \\text{Smallest} = ${rangeTok.displayLaTeX} + ${lowTok.displayLaTeX} = \\mathbf{${u.prefixLaTeX}$highestStr${u.suffixLaTeX}}",
        card1Title: "Given Range",
        card1LaTeX: "${u.prefixLaTeX}${rangeTok.displayLaTeX}${u.suffixLaTeX}",
        card2Title: "Smallest Quantity",
        card2LaTeX: "${u.prefixLaTeX}${lowTok.displayLaTeX}${u.suffixLaTeX}",
        card3Title: "Highest Quantity",
        card3LaTeX: "\\mathbf{${u.prefixLaTeX}$highestStr${u.suffixLaTeX}}",
        mainBoxLaTeX: boxLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Highest quantity} = ${rangeTok.displayLaTeX} + ${lowTok.displayLaTeX} = \\mathbf{${u.prefixLaTeX}$highestStr${u.suffixLaTeX}}",
      ),
    );
  }
}