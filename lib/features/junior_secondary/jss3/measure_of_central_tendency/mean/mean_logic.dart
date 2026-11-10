import 'mean_models.dart';

/// Exact Rational Number (Fraction & Mixed Number) Engine so every fraction is rendered via \frac{num}{den} in Math.tex!
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
  _Frac operator *(_Frac other) => _Frac.from(num * other.num, den * other.den);
  _Frac operator /(_Frac other) {
    if (other.num == 0) throw const FormatException("Cannot divide by zero.");
    return _Frac.from(num * other.den, den * other.num);
  }

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

class _UnitFormat {
  final String prefixLaTeX;
  final String suffixLaTeX;
  final String prefixPlain;
  final String suffixPlain;

  const _UnitFormat({
    this.prefixLaTeX = '',
    this.suffixLaTeX = '',
    this.prefixPlain = '',
    this.suffixPlain = '',
  });
}

class _ParsedToken {
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

  const _ParsedToken({
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

class MeanLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 211–213 & Page 218 Revision Exercise 18)
  // ===========================================================================
  static const List<MeanPreset> textbookPresets = [
    MeanPreset(
      chipLabel: "Example 1 (Page 211): 7, 5, 6, 4, 4, 2, 3, 5, 3, 4",
      mode: 0,
      input1: "7, 5, 6, 4, 4, 2, 3, 5, 3, 4",
      unit: "marks",
    ),
    MeanPreset(
      chipLabel: "Table 18.1 / 18.2 (Page 212): Freq Table of Scores",
      mode: 1,
      input1: "2, 3, 4, 5, 6, 7",
      input2: "1, 2, 3, 2, 1, 1",
    ),
    MeanPreset(
      chipLabel: "Ex 18.1 #1a (Page 212): 4, 8, 1, 6, 10",
      mode: 0,
      input1: "4, 8, 1, 6, 10",
    ),
    MeanPreset(
      chipLabel: "Ex 18.1 #1b (Page 212): 5.4, 2.8, 1.0, 3.6, 4.2",
      mode: 0,
      input1: "5.4, 2.8, 1.0, 3.6, 4.2",
    ),
    MeanPreset(
      chipLabel: "Ex 18.1 #1c (Page 212): 16, 18, 22, 12, 8",
      mode: 0,
      input1: "16, 18, 22, 12, 8",
    ),
    MeanPreset(
      chipLabel: "Ex 18.1 #1d (Page 212): 4 kg, 1 kg, 0 kg, 5 kg, 3 kg, 2 kg",
      mode: 0,
      input1: "4, 1, 0, 5, 3, 2",
      unit: "kg",
    ),
    MeanPreset(
      chipLabel:
      "Ex 18.1 #1e (Page 212): ₦75.30, ₦38.70, ₦86.50, ₦100.50, ₦94.50, ₦90.10, ₦73.40",
      mode: 0,
      input1: "75.30, 38.70, 86.50, 100.50, 94.50, 90.10, 73.40",
      unit: "₦",
    ),
    MeanPreset(
      chipLabel: "Ex 18.1 #2 Table 18.3 (Page 212): Score 0–5 Freq Table",
      mode: 1,
      input1: "0, 1, 2, 3, 4, 5",
      input2: "5, 6, 4, 2, 1, 2",
    ),
    MeanPreset(
      chipLabel: "Ex 18.1 #3 Table 18.4 (Page 213): 5 Students in 4 Subjects",
      mode: 3,
      input1:
      "Ibrahim: 94, 57, 44, 34\nAbiola: 83, 35, 14, 26\nEghosa: 74, 48, 73, 80\nChukwudi: 54, 42, 60, 68\nKamo: 67, 73, 69, 52",
      input2: "Maths, English, Civic Educ, Basic Science",
    ),
    MeanPreset(
      chipLabel: "Ex 18.1 #4 (Page 213): Ages 21, 20, 18, 16, 15, 19, 13, 14",
      mode: 0,
      input1: "21, 20, 18, 16, 15, 19, 13, 14",
      unit: "years",
    ),
    MeanPreset(
      chipLabel: "Ex 18.1 #5 Table 18.5 (Page 213): Football Goals in 20 Matches",
      mode: 1,
      input1: "0, 1, 2, 3, 4, 5",
      input2: "3, 5, 7, 4, 1, 0",
      unit: "goals",
    ),
    MeanPreset(
      chipLabel: "Rev Ex 18 #2b (Page 218): 6, 7 1/2, 6 1/2, 5, 12, 8",
      mode: 0,
      input1: "6, 7 1/2, 6 1/2, 5, 12, 8",
    ),
    MeanPreset(
      chipLabel: "Rev Ex 18 #2c (Page 218): 12, 17 1/2, 22, 14, 17",
      mode: 0,
      input1: "12, 17 1/2, 22, 14, 17",
    ),
    MeanPreset(
      chipLabel: "Rev Ex 18 #3 (Page 218): Children in Each Family Table",
      mode: 1,
      input1: "1, 2, 3, 4",
      input2: "8, 12, 4, 2",
      unit: "children",
    ),
    MeanPreset(
      chipLabel: "Rev Ex 18 #5 (Page 218): Students Absent in JS 3 Gold",
      mode: 1,
      input1: "0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10",
      input2: "20, 2, 4, 0, 2, 0, 1, 2, 0, 0, 1",
    ),
    MeanPreset(
      chipLabel: "Missing Score Exam Problem: Mean of 5 numbers is 8",
      mode: 2,
      input1: "6, 9, 7, 10",
      input2: "8",
      input3: "5",
    ),
  ];

  // ===========================================================================
  // FORMATTING & PARSING HELPERS
  // ===========================================================================

  static String _cleanDouble(double v, {int decimals = 4}) {
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    String s = v.toStringAsFixed(decimals);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
    return s;
  }

  static _UnitFormat _formatUnit(String rawUnit) {
    final String u = rawUnit.trim();
    if (u.isEmpty) {
      return const _UnitFormat();
    }
    if (u == '₦' || u == r'$' || u == '£') {
      return _UnitFormat(
        prefixLaTeX: '\\text{$u}',
        suffixLaTeX: '',
        prefixPlain: u,
        suffixPlain: '',
      );
    }
    return _UnitFormat(
      prefixLaTeX: '',
      suffixLaTeX: '\\text{ $u}',
      prefixPlain: '',
      suffixPlain: ' $u',
    );
  }

  static _ParsedToken _parseToken(String rawToken) {
    final String s = rawToken
        .trim()
        .replaceAll('₦', '')
        .replaceAll(r'$', '')
        .replaceAll('£', '')
        .replaceAll('−', '-')
        .replaceAll(
      RegExp(
        r'\b(kg|cm|mm|km|m|g|years|yrs|marks|goals|children|students|pupils)\b',
        caseSensitive: false,
      ),
      '',
    )
        .trim();

    if (s.isEmpty) {
      throw const FormatException("Empty number entry detected.");
    }

    // 1. Mixed fraction e.g. "7 1/2" or "17 1/2"
    final RegExp mixedReg = RegExp(r'^([+-]?\d+)\s+(\d+)\s*/\s*(\d+)$');
    final Match? mm = mixedReg.firstMatch(s);
    if (mm != null) {
      final int w = int.parse(mm.group(1)!);
      final int n = int.parse(mm.group(2)!);
      final int d = int.parse(mm.group(3)!);
      if (d == 0) throw const FormatException("Denominator cannot be zero.");
      final int sign = w < 0 ? -1 : 1;
      final int impNum = sign * (w.abs() * d + n);
      return _ParsedToken(
        raw: s,
        frac: _Frac.from(impNum, d),
        origNum: impNum,
        origDen: d,
        isMixed: true,
        mixedWhole: w,
        mixedNum: n,
        mixedDen: d,
        isFractionInput: true,
        isDecimalInput: false,
        displayLaTeX: '$w\\frac{$n}{$d}',
        displayPlain: '$w $n/$d',
      );
    }

    // 2. Simple fraction e.g. "3/4"
    final RegExp fracReg = RegExp(r'^([+-]?\d+)\s*/\s*(\d+)$');
    final Match? fm = fracReg.firstMatch(s);
    if (fm != null) {
      final int n = int.parse(fm.group(1)!);
      final int d = int.parse(fm.group(2)!);
      if (d == 0) throw const FormatException("Denominator cannot be zero.");
      return _ParsedToken(
        raw: s,
        frac: _Frac.from(n, d),
        origNum: n,
        origDen: d,
        isMixed: false,
        isFractionInput: true,
        isDecimalInput: false,
        displayLaTeX: '\\frac{$n}{$d}',
        displayPlain: '$n/$d',
      );
    }

    // 3. Decimal e.g. "5.4" or "75.30"
    if (s.contains('.')) {
      final double? dv = double.tryParse(s);
      if (dv == null) {
        throw FormatException("Invalid decimal number '$rawToken'.");
      }
      final List<String> parts = s.split('.');
      final int decPlaces = parts[1].length;
      int d = 1;
      for (int i = 0; i < decPlaces; i++) {
        d *= 10;
      }
      final int sign = s.startsWith('-') ? -1 : 1;
      final String wholeRaw = parts[0].replaceAll('-', '').replaceAll('+', '');
      final int wholeAbs = wholeRaw.isEmpty ? 0 : int.parse(wholeRaw);
      final int decInt = int.parse(parts[1]);
      final int totalNum = sign * (wholeAbs * d + decInt);
      return _ParsedToken(
        raw: s,
        frac: _Frac.from(totalNum, d),
        origNum: totalNum,
        origDen: d,
        isMixed: false,
        isFractionInput: false,
        isDecimalInput: true,
        displayLaTeX: s,
        displayPlain: s,
      );
    }

    // 4. Whole integer
    final int? iv = int.tryParse(s);
    if (iv == null) {
      throw FormatException("Could not read '$rawToken' as a valid number.");
    }
    return _ParsedToken(
      raw: s,
      frac: _Frac.from(iv, 1),
      origNum: iv,
      origDen: 1,
      isMixed: false,
      isFractionInput: false,
      isDecimalInput: false,
      displayLaTeX: '$iv',
      displayPlain: '$iv',
    );
  }

  static List<_ParsedToken> _parseNumberList(String rawList) {
    final String normalized =
    rawList.replaceAll(RegExp(r'\band\b', caseSensitive: false), ',');
    final List<String> chunks = normalized
        .split(RegExp(r'[,;\n]+'))
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList();
    if (chunks.isEmpty) {
      throw const FormatException(
        "Please enter numbers separated by commas (e.g. 7, 5, 6, 4, 4).",
      );
    }
    return chunks.map(_parseToken).toList();
  }

  // ===========================================================================
  // MASTER ROUTER
  // ===========================================================================
  static MeanResult solveMean({
    required int mode,
    required String rawInput1,
    String rawInput2 = '',
    String rawInput3 = '',
    String unit = '',
  }) {
    try {
      String detectedUnit = unit.trim();
      if (detectedUnit.isEmpty) {
        if (rawInput1.contains('₦')) {
          detectedUnit = '₦';
        } else {
          final Match? um = RegExp(
            r'\b(kg|cm|mm|km|m|g|years|yrs|marks|goals|children)\b',
            caseSensitive: false,
          ).firstMatch(rawInput1);
          if (um != null) detectedUnit = um.group(1)!;
        }
      }

      if (mode == 0) {
        return _solveUngroupedData(rawInput1, detectedUnit);
      } else if (mode == 1) {
        return _solveFrequencyTable(rawInput1, rawInput2, detectedUnit);
      } else if (mode == 2) {
        return _solveMissingScore(
            rawInput1, rawInput2, rawInput3, detectedUnit);
      } else {
        return _solveSubjectMatrix(rawInput1, rawInput2);
      }
    } catch (e) {
      return MeanResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please check your input values and try again.",
      );
    }
  }

  // ===========================================================================
  // MODE 0: UNGROUPED DATA LIST (Example 1, Page 211 & Exercise 18.1 #1, #4)
  // ===========================================================================
  static MeanResult _solveUngroupedData(String rawInput, String unit) {
    final List<_ParsedToken> items = _parseNumberList(rawInput);
    if (items.length < 2) {
      throw const FormatException(
        "Please enter at least 2 numbers separated by commas to find their mean.",
      );
    }

    final _UnitFormat u = _formatUnit(unit);
    final int n = items.length;
    final bool hasFractions = items.any((_ParsedToken t) => t.isFractionInput);
    final bool hasDecimals = items.any((_ParsedToken t) => t.isDecimalInput);

    final String givenLaTeX =
    items.map((_ParsedToken e) => e.displayLaTeX).join(', \\; ');
    final String givenPlain =
    items.map((_ParsedToken e) => e.displayPlain).join(', ');

    final List<String> conversionLinesLaTeX = [];
    final List<String> conversionBulletsPlain = [];
    if (hasFractions) {
      for (final _ParsedToken item in items) {
        if (item.isMixed) {
          final int w = item.mixedWhole!.abs();
          final int mn = item.mixedNum!;
          final int md = item.mixedDen!;
          conversionLinesLaTeX.add(
            "\\bullet \\; ${item.displayLaTeX} = \\frac{(${item.mixedWhole} \\times $md) + $mn}{$md} = \\frac{${w * md} + $mn}{$md} = \\frac{${item.origNum}}{$md} = ${_cleanDouble(item.value)}",
          );
          conversionBulletsPlain.add(
            "• Convert ${item.displayPlain}: ((${item.mixedWhole} × $md) + $mn)/$md = ${item.origNum}/$md = ${_cleanDouble(item.value)}",
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

    final List<String> additionLinesLaTeX = [];
    final List<String> additionBulletsPlain = [];
    final String sumExprLaTeX =
    items.map((_ParsedToken e) => e.displayLaTeX).join(' + ');
    additionLinesLaTeX.add("\\text{Sum of values} = $sumExprLaTeX");

    double runningSum = items[0].value;
    _Frac runningFrac = items[0].frac;

    for (int i = 1; i < items.length; i++) {
      final String prevStr = _cleanDouble(runningSum);
      final String curStr = _cleanDouble(items[i].value);
      runningSum += items[i].value;
      runningFrac = runningFrac + items[i].frac;
      final String nextStr = _cleanDouble(runningSum);

      additionLinesLaTeX.add(
        "\\bullet \\text{ Add item ${i + 1}: } $prevStr + $curStr = \\mathbf{$nextStr}",
      );
      additionBulletsPlain.add(
        "• Step $i of addition: $prevStr + $curStr = $nextStr",
      );
    }

    int commonDen = 1;
    for (final _ParsedToken item in items) {
      if (item.isFractionInput) {
        commonDen = _Frac.lcm(commonDen, item.origDen);
      }
    }
    if (hasFractions && commonDen > 1) {
      final List<String> scaledNums = [];
      int sumScaled = 0;
      for (final _ParsedToken item in items) {
        final int mult = commonDen ~/ item.origDen;
        final int sc = item.origNum * mult;
        sumScaled += sc;
        scaledNums.add('$sc');
      }
      additionLinesLaTeX.add(
        "\\text{Exact fraction sum (LCD = $commonDen): } \\frac{${scaledNums.join(' + ')}}{$commonDen} = \\frac{$sumScaled}{$commonDen} = \\mathbf{${_cleanDouble(runningSum)}}",
      );
    }

    final String sumStr = _cleanDouble(runningSum);
    additionLinesLaTeX.add(
      "\\therefore \\; \\text{Sum of all values} = \\mathbf{${u.prefixLaTeX}$sumStr${u.suffixLaTeX}}",
    );

    final _Frac exactMean = runningFrac / _Frac(n, 1);
    final double meanDouble = runningSum / n;
    final String meanDecStr = _cleanDouble(meanDouble);

    final List<String> divisionLinesLaTeX = [
      "\\text{Mean} = \\frac{\\text{Sum of all values}}{\\text{Total number of items}}",
      "\\text{Mean} = \\frac{$sumExprLaTeX}{$n}",
      "\\text{Mean} = \\frac{$sumStr}{$n}",
    ];

    if (hasFractions) {
      divisionLinesLaTeX.add(
        "\\text{Exact fraction division: } ${runningFrac.toLaTeX()} \\div $n = ${runningFrac.toLaTeX()} \\times \\frac{1}{$n} = ${exactMean.toLaTeX()}",
      );
      if (exactMean.isFraction && exactMean.num.abs() > exactMean.den) {
        divisionLinesLaTeX.add(
          "\\text{As a mixed number: } \\mathbf{${u.prefixLaTeX}${exactMean.toMixedLaTeX()}${u.suffixLaTeX}}",
        );
      }
    } else if (!hasDecimals && exactMean.isFraction) {
      final int g = _Frac.gcd(runningFrac.num, n);
      if (g > 1) {
        divisionLinesLaTeX.add(
          "\\text{Divide numerator and denominator by } $g: \\quad \\text{Mean} = ${exactMean.toLaTeX()}",
        );
      }
      if (exactMean.num.abs() > exactMean.den) {
        divisionLinesLaTeX.add(
          "\\text{As a mixed fraction: } \\text{Mean} = ${exactMean.toMixedLaTeX()}",
        );
      }
    }

    divisionLinesLaTeX.add(
      "\\therefore \\; \\text{Mean} = \\mathbf{${u.prefixLaTeX}$meanDecStr${u.suffixLaTeX}}",
    );

    final String colSpec = List.filled(items.length, 'c').join('|');
    final String indexHeaders =
    List.generate(items.length, (int i) => "\\text{Item ${i + 1}}")
        .join(' & ');
    final String valCells =
    items.map((_ParsedToken e) => "\\mathbf{${e.displayLaTeX}}").join(' & ');
    final String visualBoxLaTeX =
        "\\begin{array}{|$colSpec|} \\hline $indexHeaders \\\\ \\hline $valCells \\\\ \\hline \\end{array}";

    final String finalMeanSummaryLaTeX = hasFractions && exactMean.isFraction
        ? "\\frac{$sumStr}{$n} = ${u.prefixLaTeX}${exactMean.toMixedLaTeX()}${u.suffixLaTeX} \\; (${u.prefixLaTeX}$meanDecStr${u.suffixLaTeX})"
        : "\\frac{$sumStr}{$n} = ${u.prefixLaTeX}$meanDecStr${u.suffixLaTeX}";

    final List<String> workings = [
      "\\text{\\textbf{Given Ungrouped Data (Page 211):}}",
      "\\mathbf{$givenLaTeX}",
      "",
      "\\text{\\textbf{Step 1: State the Formula for the Mean}}",
      "\\text{Mean} = \\frac{\\text{Sum of all values}}{\\text{Total number of items}}",
      "",
      if (hasFractions) ...[
        "\\text{\\textbf{Step 2: Convert Mixed Numbers / Fractions}}",
        ...conversionLinesLaTeX,
        "",
      ],
      "\\text{\\textbf{Step ${hasFractions ? 3 : 2}: Add All the Values Together Step-by-Step}}",
      ...additionLinesLaTeX,
      "",
      "\\text{\\textbf{Step ${hasFractions ? 4 : 3}: Count the Total Number of Items}}",
      "\\text{Total number of items } (n) = \\mathbf{$n}",
      "",
      "\\text{\\textbf{Step ${hasFractions ? 5 : 4}: Divide the Sum by the Total Number of Items}}",
      ...divisionLinesLaTeX,
    ];

    final List<MeanStep> steps = [
      const MeanStep(
        title: "Step 1: Write Down the Formula for the Mean (Page 211)",
        description:
        "• The arithmetic mean (average) is determined by adding all the items together and dividing the sum by the total number of items in the given set of ungrouped data.",
        mathLinesLaTeX: [
          r"\text{Mean} = \frac{\text{Sum of all values}}{\text{Total number of items}}",
        ],
      ),
      if (hasFractions)
        MeanStep(
          title:
          "Step 2: Convert Mixed Numbers into Improper Fractions & Decimals",
          description:
          "• Convert each mixed fraction into an improper fraction and decimal so all items can be added without error:\n"
              "${conversionBulletsPlain.join('\n')}",
          mathLinesLaTeX: conversionLinesLaTeX,
        ),
      MeanStep(
        title:
        "Step ${hasFractions ? 3 : 2}: Add All the Items Together Without Skipping Any Step",
        description:
        "• Add the $n given numbers ($givenPlain) one after another:\n"
            "${additionBulletsPlain.join('\n')}",
        mathLinesLaTeX: additionLinesLaTeX,
      ),
      MeanStep(
        title: "Step ${hasFractions ? 4 : 3}: Count the Total Number of Items (n)",
        description:
        "• Count how many values are in the data set ($givenPlain). There are $n items in total.",
        mathLinesLaTeX: [
          "\\text{Total number of items } (n) = \\mathbf{$n}",
        ],
      ),
      MeanStep(
        title:
        "Step ${hasFractions ? 5 : 4}: Substitute Into the Formula and Divide by $n",
        description:
        "• Divide the sum of all values (${u.prefixPlain}$sumStr${u.suffixPlain}) by the total number of items ($n) to get ${u.prefixPlain}$meanDecStr${u.suffixPlain}.",
        mathLinesLaTeX: divisionLinesLaTeX,
      ),
    ];

    return MeanResult(
      mode: 0,
      finalAnswersLaTeX: {
        "Sum of Values": "${u.prefixLaTeX}$sumStr${u.suffixLaTeX}",
        "Number of Items (n)": "$n",
        "Mean": "\\mathbf{$finalMeanSummaryLaTeX}",
      },
      workingsLaTeX: workings,
      steps: steps,
      canvasData: MeanCanvasData(
        headerLaTeX:
        "\\text{Chapter 18 Mean of Ungrouped Data (Page 211): } \\text{Mean} = \\frac{\\text{Sum of all values}}{\\text{Total number of items}}",
        subHeaderLaTeX:
        "\\text{Substitute Values: } \\text{Mean} = \\frac{$sumExprLaTeX}{$n} = \\frac{$sumStr}{$n}",
        card1Title: "Sum of Values",
        card1LaTeX: "${u.prefixLaTeX}$sumStr${u.suffixLaTeX}",
        card2Title: "Total Items (n)",
        card2LaTeX: "$n",
        card3Title: "Arithmetic Mean",
        card3LaTeX: "\\mathbf{${u.prefixLaTeX}$meanDecStr${u.suffixLaTeX}}",
        mainBoxLaTeX: visualBoxLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Mean} = \\frac{$sumStr}{$n} = \\mathbf{$finalMeanSummaryLaTeX}",
      ),
    );
  }

  // ===========================================================================
  // MODE 1: FREQUENCY DISTRIBUTION TABLE (Table 18.1 / 18.2, Page 212)
  // ===========================================================================
  static MeanResult _solveFrequencyTable(
      String rawScores,
      String rawFrequencies,
      String unit,
      ) {
    final List<_ParsedToken> scores = _parseNumberList(rawScores);
    final List<_ParsedToken> freqs = _parseNumberList(rawFrequencies);

    if (scores.length != freqs.length) {
      throw FormatException(
        "The number of Scores (${scores.length}) must match the number of Frequencies (${freqs.length}).",
      );
    }
    if (scores.length < 2) {
      throw const FormatException(
        "Please enter at least 2 scores and their corresponding frequencies.",
      );
    }

    final List<int> intFreqs = [];
    for (int i = 0; i < freqs.length; i++) {
      if (!freqs[i].frac.isInteger || freqs[i].frac.num < 0) {
        throw FormatException(
          "Frequency at position ${i + 1} (${freqs[i].raw}) must be a whole number (0 or greater).",
        );
      }
      intFreqs.add(freqs[i].frac.num);
    }

    final int totalFreq = intFreqs.fold(0, (int a, int b) => a + b);
    if (totalFreq <= 0) {
      throw const FormatException(
          "The sum of frequencies must be greater than zero.");
    }

    final _UnitFormat u = _formatUnit(unit);

    final List<double> fxDoubles = [];
    _Frac totalFxFrac = const _Frac(0, 1);
    final List<String> rowMultLaTeX = [];
    final List<String> rowMultPlain = [];
    final List<String> tableRowsLaTeX = [];

    for (int i = 0; i < scores.length; i++) {
      final _ParsedToken x = scores[i];
      final int f = intFreqs[i];
      final double fxVal = f * x.value;
      final _Frac fxFrac = x.frac * _Frac(f, 1);
      fxDoubles.add(fxVal);
      totalFxFrac = totalFxFrac + fxFrac;

      final String fxStr = _cleanDouble(fxVal);
      rowMultLaTeX.add(
        "\\bullet \\text{ Row ${i + 1} } (x = ${x.displayLaTeX}, \\; f = $f): \\quad f \\times x = $f \\times ${x.displayLaTeX} = \\mathbf{$fxStr}",
      );
      rowMultPlain.add(
        "• Row ${i + 1} (Score = ${x.displayPlain}, Freq = $f): $f × ${x.displayPlain} = $fxStr",
      );
      tableRowsLaTeX.add(
        "${x.displayLaTeX} & $f & $f \\times ${x.displayLaTeX} = \\mathbf{$fxStr} \\\\ \\hline ",
      );
    }

    final List<String> freqAddLinesLaTeX = [
      "\\sum f = ${intFreqs.join(' + ')}",
    ];
    final List<String> freqAddPlain = [];
    int runningF = intFreqs[0];
    for (int i = 1; i < intFreqs.length; i++) {
      final int prev = runningF;
      final int cur = intFreqs[i];
      runningF += cur;
      freqAddLinesLaTeX.add(
        "\\bullet \\text{ Step $i: } $prev + $cur = \\mathbf{$runningF}",
      );
      freqAddPlain.add("• Step $i: $prev + $cur = $runningF");
    }
    freqAddLinesLaTeX.add("\\therefore \\; \\sum f = \\mathbf{$totalFreq}");

    final List<String> fxAddLinesLaTeX = [
      "\\sum (f \\times x) = ${fxDoubles.map(_cleanDouble).join(' + ')}",
    ];
    final List<String> fxAddPlain = [];
    double runningFx = fxDoubles[0];
    for (int i = 1; i < fxDoubles.length; i++) {
      final String prev = _cleanDouble(runningFx);
      final String cur = _cleanDouble(fxDoubles[i]);
      runningFx += fxDoubles[i];
      final String next = _cleanDouble(runningFx);
      fxAddLinesLaTeX.add(
        "\\bullet \\text{ Step $i: } $prev + $cur = \\mathbf{$next}",
      );
      fxAddPlain.add("• Step $i: $prev + $cur = $next");
    }
    final String sumFxStr = _cleanDouble(runningFx);
    fxAddLinesLaTeX
        .add("\\therefore \\; \\sum (f \\times x) = \\mathbf{$sumFxStr}");

    final double meanVal = runningFx / totalFreq;
    final String meanStr = _cleanDouble(meanVal);
    final _Frac exactMean = totalFxFrac / _Frac(totalFreq, 1);

    final List<String> divLinesLaTeX = [
      "\\text{Mean score} = \\frac{\\text{Sum of } (\\text{frequency} \\times \\text{score})}{\\text{Sum of frequencies}} = \\frac{\\sum (f \\times x)}{\\sum f}",
      "\\text{Mean} = \\frac{$sumFxStr}{$totalFreq}",
    ];
    if (totalFxFrac.isInteger && exactMean.isFraction) {
      final int g = _Frac.gcd(totalFxFrac.num, totalFreq);
      if (g > 1) {
        divLinesLaTeX.add(
          "\\text{Simplify fraction by dividing top and bottom by } $g: \\quad \\text{Mean} = ${exactMean.toLaTeX()}",
        );
      }
      if (exactMean.num.abs() > exactMean.den) {
        divLinesLaTeX.add(
          "\\text{As a mixed number: } \\text{Mean} = ${exactMean.toMixedLaTeX()}",
        );
      }
    }
    divLinesLaTeX.add(
      "\\therefore \\; \\text{Mean} = \\mathbf{${u.prefixLaTeX}$meanStr${u.suffixLaTeX}}",
    );

    final String table182LaTeX =
        "\\begin{array}{|c|c|c|} \\hline \\mathbf{\\text{Score } (x)} & \\mathbf{\\text{Frequency } (f)} & \\mathbf{\\text{Frequency} \\times \\text{Score } (f \\times x)} \\\\ \\hline "
        "${tableRowsLaTeX.join()}"
        "\\mathbf{\\text{Total}} & \\mathbf{\\sum f = $totalFreq} & \\mathbf{\\sum (f \\times x) = $sumFxStr} \\\\ \\hline \\end{array}";

    final List<String> workings = [
      "\\text{\\textbf{Completed Frequency Table (Table 18.2 Standard, Page 212):}}",
      table182LaTeX,
      "",
      "\\text{\\textbf{Step 1: State the Formula for Mean from a Frequency Table}}",
      "\\text{Mean} = \\frac{\\text{Sum of } (\\text{frequency} \\times \\text{score})}{\\text{Sum of frequencies}} = \\frac{\\sum (f \\times x)}{\\sum f}",
      "",
      "\\text{\\textbf{Step 2: Multiply Frequency (f) by Score (x) for Each Row}}",
      ...rowMultLaTeX,
      "",
      "\\text{\\textbf{Step 3: Add All the Frequencies Together}}",
      ...freqAddLinesLaTeX,
      "",
      "\\text{\\textbf{Step 4: Add All the (f \\times x) Products Together}}",
      ...fxAddLinesLaTeX,
      "",
      "\\text{\\textbf{Step 5: Divide Sum of (f \\times x) by Sum of Frequencies}}",
      ...divLinesLaTeX,
    ];

    final List<MeanStep> steps = [
      const MeanStep(
        title: "Step 1: Write Down the Frequency Table Mean Formula (Page 212)",
        description:
        "• To determine the mean using a frequency table, add a third column (Frequency × Score), then divide the sum of (frequency × score) by the sum of frequencies.",
        mathLinesLaTeX: [
          r"\text{Mean score} = \frac{\text{sum of } (\text{frequency} \times \text{score})}{\text{sum of frequencies}} = \frac{\sum (f \times x)}{\sum f}",
        ],
      ),
      MeanStep(
        title: "Step 2: Calculate (Frequency × Score) for Every Row",
        description:
        "• Multiply each score (x) by how many times it occurs (its frequency f):\n"
            "${rowMultPlain.join('\n')}",
        mathLinesLaTeX: [
          ...rowMultLaTeX,
          table182LaTeX,
        ],
      ),
      MeanStep(
        title: "Step 3: Find the Total Frequency (Σf) Step-by-Step",
        description:
        "• Add all frequencies in the second column to find the total number of items:\n"
            "${freqAddPlain.join('\n')}",
        mathLinesLaTeX: freqAddLinesLaTeX,
      ),
      MeanStep(
        title: "Step 4: Find the Sum of (Frequency × Score) Step-by-Step",
        description:
        "• Add all products in the third column to find the total score:\n"
            "${fxAddPlain.join('\n')}",
        mathLinesLaTeX: fxAddLinesLaTeX,
      ),
      MeanStep(
        title: "Step 5: Divide Σ(f × x) by Σf to Find the Mean",
        description:
        "• Divide the total sum of scores ($sumFxStr) by the total frequency ($totalFreq) to obtain ${u.prefixPlain}$meanStr${u.suffixPlain}.",
        mathLinesLaTeX: divLinesLaTeX,
      ),
    ];

    return MeanResult(
      mode: 1,
      finalAnswersLaTeX: {
        "Total Frequency": "$totalFreq",
        "Total Score": "${u.prefixLaTeX}$sumFxStr${u.suffixLaTeX}",
        "Mean Score":
        "\\frac{$sumFxStr}{$totalFreq} = \\mathbf{${u.prefixLaTeX}$meanStr${u.suffixLaTeX}}",
      },
      workingsLaTeX: workings,
      steps: steps,
      canvasData: MeanCanvasData(
        headerLaTeX:
        "\\text{Table 18.2 Frequency Table Mean (Page 212): } \\bar{x} = \\frac{\\sum (f \\times x)}{\\sum f}",
        subHeaderLaTeX:
        "\\text{Substitute Totals: } \\bar{x} = \\frac{$sumFxStr}{$totalFreq} = \\mathbf{${u.prefixLaTeX}$meanStr${u.suffixLaTeX}}",
        card1Title: "Sum of Frequencies (Σf)",
        card1LaTeX: "$totalFreq",
        card2Title: "Sum of (f × x)",
        card2LaTeX: "${u.prefixLaTeX}$sumFxStr${u.suffixLaTeX}",
        card3Title: "Mean Score",
        card3LaTeX:
        "\\frac{$sumFxStr}{$totalFreq} = \\mathbf{${u.prefixLaTeX}$meanStr${u.suffixLaTeX}}",
        mainBoxLaTeX: table182LaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Mean} = \\frac{\\sum (f \\times x)}{\\sum f} = \\frac{$sumFxStr}{$totalFreq} = \\mathbf{${u.prefixLaTeX}$meanStr${u.suffixLaTeX}}",
      ),
    );
  }

  // ===========================================================================
  // MODE 2: MISSING SCORE GIVEN MEAN
  // ===========================================================================
  static MeanResult _solveMissingScore(
      String rawKnownList,
      String rawGivenMean,
      String rawTotalItems,
      String unit,
      ) {
    final List<_ParsedToken> knownItems = _parseNumberList(rawKnownList);
    if (rawGivenMean.trim().isEmpty) {
      throw const FormatException("Please enter the given Mean.");
    }
    final _ParsedToken meanToken = _parseToken(rawGivenMean);

    final int n = rawTotalItems.trim().isEmpty
        ? knownItems.length + 1
        : (int.tryParse(rawTotalItems.trim()) ?? (knownItems.length + 1));

    if (n != knownItems.length + 1) {
      throw FormatException(
        "You entered ${knownItems.length} known numbers, so the total count including 1 missing value should be ${knownItems.length + 1}.",
      );
    }

    final _UnitFormat u = _formatUnit(unit);
    final String knownChainLaTeX =
    knownItems.map((_ParsedToken e) => e.displayLaTeX).join(' + ');

    final List<String> addKnownLines = [
      "\\text{Sum of known values} = $knownChainLaTeX",
    ];
    double knownSum = knownItems[0].value;
    for (int i = 1; i < knownItems.length; i++) {
      final String p = _cleanDouble(knownSum);
      final String c = _cleanDouble(knownItems[i].value);
      knownSum += knownItems[i].value;
      addKnownLines.add(
        "\\bullet \\text{ Step $i: } $p + $c = \\mathbf{${_cleanDouble(knownSum)}}",
      );
    }

    final String knownSumStr = _cleanDouble(knownSum);
    final String meanStr = _cleanDouble(meanToken.value);
    final double requiredSum = meanToken.value * n;
    final String reqSumStr = _cleanDouble(requiredSum);
    final double missingVal = requiredSum - knownSum;
    final String missingStr = _cleanDouble(missingVal);

    final String boxLaTeX = "\\begin{array}{|c|c|c|c|} \\hline "
        "\\mathbf{\\text{Known Sum}} & \\mathbf{\\text{Given Mean}} & \\mathbf{\\text{Total Count } (n)} & \\mathbf{\\text{Missing Value } (x)} \\\\ \\hline "
        "$knownSumStr & $meanStr & $n & \\mathbf{x = $missingStr} \\\\ \\hline \\end{array}";

    final List<String> workings = [
      "\\text{\\textbf{Step 1: Let the Missing Value be }} x \\text{\\textbf{ and State the Mean Formula}}",
      "\\text{Mean} = \\frac{\\text{Sum of all } $n \\text{ values}}{$n}",
      "",
      "\\text{\\textbf{Step 2: Add the ${knownItems.length} Known Numbers Step-by-Step}}",
      ...addKnownLines,
      "",
      "\\text{\\textbf{Step 3: Substitute into the Mean Formula}}",
      "\\frac{$knownChainLaTeX + x}{$n} = ${meanToken.displayLaTeX}",
      "\\frac{$knownSumStr + x}{$n} = $meanStr",
      "",
      "\\text{\\textbf{Step 4: Multiply Both Sides by $n and Solve for }} x",
      "$knownSumStr + x = $meanStr \\times $n",
      "$knownSumStr + x = $reqSumStr",
      "x = $reqSumStr - $knownSumStr",
      "\\therefore \\; x = \\mathbf{${u.prefixLaTeX}$missingStr${u.suffixLaTeX}}",
    ];

    final List<MeanStep> steps = [
      MeanStep(
        title: "Step 1: Represent the Missing Value with x",
        description:
        "• Let the unknown number be x. Substitute the known numbers, x, the total number of items ($n), and the given mean ($meanStr) into the mean formula.",
        mathLinesLaTeX: [
          r"\text{Mean} = \frac{\text{Sum of all values}}{\text{Total number of items}}",
          "\\frac{$knownChainLaTeX + x}{$n} = ${meanToken.displayLaTeX}",
        ],
      ),
      MeanStep(
        title: "Step 2: Add the Known Numbers Step-by-Step",
        description:
        "• Add all ${knownItems.length} given numbers together to simplify the numerator.",
        mathLinesLaTeX: addKnownLines,
      ),
      MeanStep(
        title: "Step 3: Clear the Fraction and Solve for x",
        description:
        "• Multiply both sides of the equation by $n to find the required sum of all $n numbers ($reqSumStr), then subtract $knownSumStr from $reqSumStr.",
        mathLinesLaTeX: [
          "\\frac{$knownSumStr + x}{$n} = $meanStr",
          "$knownSumStr + x = $meanStr \\times $n = $reqSumStr",
          "x = $reqSumStr - $knownSumStr = \\mathbf{${u.prefixLaTeX}$missingStr${u.suffixLaTeX}}",
        ],
      ),
    ];

    return MeanResult(
      mode: 2,
      finalAnswersLaTeX: {
        "Sum of Known Items": knownSumStr,
        "Required Total Sum": "$meanStr \\times $n = $reqSumStr",
        "Missing Value (x)":
        "\\mathbf{${u.prefixLaTeX}$missingStr${u.suffixLaTeX}}",
      },
      workingsLaTeX: workings,
      steps: steps,
      canvasData: MeanCanvasData(
        headerLaTeX:
        "\\text{Missing Score Given Mean: } \\frac{$knownSumStr + x}{$n} = $meanStr",
        subHeaderLaTeX:
        "\\text{Required Sum} = $meanStr \\times $n = $reqSumStr \\implies x = $reqSumStr - $knownSumStr",
        card1Title: "Known Sum",
        card1LaTeX: knownSumStr,
        card2Title: "Required Total",
        card2LaTeX: reqSumStr,
        card3Title: "Missing Score (x)",
        card3LaTeX: "\\mathbf{${u.prefixLaTeX}$missingStr${u.suffixLaTeX}}",
        mainBoxLaTeX: boxLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; x = $reqSumStr - $knownSumStr = \\mathbf{${u.prefixLaTeX}$missingStr${u.suffixLaTeX}}",
      ),
    );
  }

  // ===========================================================================
  // MODE 3: STUDENT × SUBJECT MATRIX TABLE (Exercise 18.1 #3 Table 18.4, Page 213)
  // ===========================================================================
  static MeanResult _solveSubjectMatrix(String rawRows, String rawSubjects) {
    final List<String> lines = rawRows
        .split('\n')
        .map((String l) => l.trim())
        .where((String l) => l.isNotEmpty)
        .toList();

    if (lines.length < 2) {
      throw const FormatException(
        "Please enter at least 2 student rows in the format:\nIbrahim: 94, 57, 44, 34\nAbiola: 83, 35, 14, 26",
      );
    }

    final List<String> studentNames = [];
    final List<List<double>> matrix = [];

    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i];
      String name = "Student ${i + 1}";
      String scoresPart = line;
      if (line.contains(':')) {
        final int idx = line.indexOf(':');
        name = line.substring(0, idx).trim();
        scoresPart = line.substring(idx + 1).trim();
      }
      final List<_ParsedToken> parsed = _parseNumberList(scoresPart);
      studentNames.add(name);
      matrix.add(parsed.map((_ParsedToken e) => e.value).toList());
    }

    final int numCols = matrix.first.length;
    for (final List<double> row in matrix) {
      if (row.length != numCols) {
        throw const FormatException(
          "Every student row must have the same number of subject scores.",
        );
      }
    }

    List<String> subjects = rawSubjects
        .split(',')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();
    if (subjects.length != numCols) {
      subjects = List.generate(numCols, (int j) => "Subject ${j + 1}");
    }

    final int numStudents = studentNames.length;

    final List<String> studentWorkingsLaTeX = [];
    final List<String> studentBulletsPlain = [];
    final Map<String, String> finalMap = {};

    for (int i = 0; i < numStudents; i++) {
      final String name = studentNames[i];
      final List<double> row = matrix[i];
      final double sum = row.fold(0.0, (double a, double b) => a + b);
      final double mean = sum / numCols;
      final String chain = row.map(_cleanDouble).join(' + ');
      final String sumStr = _cleanDouble(sum);
      final String meanStr = _cleanDouble(mean);

      studentWorkingsLaTeX.add(
        "\\bullet \\; \\mathbf{\\text{$name}}: \\quad \\text{Mean} = \\frac{$chain}{$numCols} = \\frac{$sumStr}{$numCols} = \\mathbf{$meanStr}",
      );
      studentBulletsPlain.add(
        "• $name: ($chain) ÷ $numCols = $sumStr ÷ $numCols = $meanStr",
      );
      finalMap["$name's Mean"] =
      "\\frac{$sumStr}{$numCols} = \\mathbf{$meanStr}";
    }

    final List<String> subjectWorkingsLaTeX = [];
    final List<String> subjectBulletsPlain = [];
    for (int j = 0; j < numCols; j++) {
      final String subj = subjects[j];
      final List<double> col =
      List.generate(numStudents, (int i) => matrix[i][j]);
      final double sum = col.fold(0.0, (double a, double b) => a + b);
      final double mean = sum / numStudents;
      final String chain = col.map(_cleanDouble).join(' + ');
      final String sumStr = _cleanDouble(sum);
      final String meanStr = _cleanDouble(mean);

      subjectWorkingsLaTeX.add(
        "\\bullet \\; \\mathbf{\\text{$subj}}: \\quad \\text{Mean} = \\frac{$chain}{$numStudents} = \\frac{$sumStr}{$numStudents} = \\mathbf{$meanStr}",
      );
      subjectBulletsPlain.add(
        "• $subj: ($chain) ÷ $numStudents = $sumStr ÷ $numStudents = $meanStr",
      );
      finalMap["$subj Mean"] =
      "\\frac{$sumStr}{$numStudents} = \\mathbf{$meanStr}";
    }

    final String colSpec = List.filled(numCols + 2, 'c').join('|');
    final String subjHeaders =
    subjects.map((String s) => "\\mathbf{\\text{$s}}").join(' & ');
    final StringBuffer sb = StringBuffer();
    sb.write(
        "\\begin{array}{|$colSpec|} \\hline \\mathbf{\\text{Student}} & $subjHeaders & \\mathbf{\\text{Student Mean}} \\\\ \\hline ");
    for (int i = 0; i < numStudents; i++) {
      final double rSum = matrix[i].fold(0.0, (double a, double b) => a + b);
      final String rMean = _cleanDouble(rSum / numCols);
      final String cells = matrix[i].map(_cleanDouble).join(' & ');
      sb.write(
          "\\text{${studentNames[i]}} & $cells & \\frac{${_cleanDouble(rSum)}}{$numCols} = \\mathbf{$rMean} \\\\ \\hline ");
    }
    final List<String> colMeanCells = [];
    for (int j = 0; j < numCols; j++) {
      final double cSum = List.generate(numStudents, (int i) => matrix[i][j])
          .fold(0.0, (double a, double b) => a + b);
      colMeanCells.add(
          "\\frac{${_cleanDouble(cSum)}}{$numStudents} = \\mathbf{${_cleanDouble(cSum / numStudents)}}");
    }
    sb.write(
        "\\mathbf{\\text{Subject Mean}} & ${colMeanCells.join(' & ')} & - \\\\ \\hline \\end{array}");

    final String table184LaTeX = sb.toString();

    return MeanResult(
      mode: 3,
      finalAnswersLaTeX: finalMap,
      workingsLaTeX: [
        "\\text{\\textbf{Table 18.4 Multi-Subject Score Matrix (Page 213):}}",
        table184LaTeX,
        "",
        "\\text{\\textbf{(a) Mean Score of Each Student (Divide Row Sum by $numCols Subjects):}}",
        ...studentWorkingsLaTeX,
        "",
        "\\text{\\textbf{(b) Mean Score in Each Subject (Divide Column Sum by $numStudents Students):}}",
        ...subjectWorkingsLaTeX,
      ],
      steps: [
        MeanStep(
          title:
          "Step 1: (a) Find the Mean Score of Each Student Across $numCols Subjects",
          description:
          "• For each student, add their scores across all $numCols subjects and divide by $numCols:\n"
              "${studentBulletsPlain.join('\n')}",
          mathLinesLaTeX: studentWorkingsLaTeX,
        ),
        MeanStep(
          title:
          "Step 2: (b) Find the Mean Score of the $numStudents Students in Each Subject",
          description:
          "• For each subject column, add the scores of all $numStudents students and divide by $numStudents:\n"
              "${subjectBulletsPlain.join('\n')}",
          mathLinesLaTeX: [
            ...subjectWorkingsLaTeX,
            table184LaTeX,
          ],
        ),
      ],
      canvasData: MeanCanvasData(
        headerLaTeX:
        "\\text{Exercise 18.1 \\#3 Table 18.4 (Page 213): Student \\& Subject Means}",
        subHeaderLaTeX:
        "\\text{Student Mean} = \\frac{\\text{Row Sum}}{$numCols}, \\quad \\text{Subject Mean} = \\frac{\\text{Column Sum}}{$numStudents}",
        card1Title: "No. of Students",
        card1LaTeX: "$numStudents",
        card2Title: "No. of Subjects",
        card2LaTeX: "$numCols",
        card3Title: "Total Scores",
        card3LaTeX: "${numStudents * numCols}",
        mainBoxLaTeX: table184LaTeX,
        bottomSummaryLaTeX:
        "\\text{Completed Table 18.4 with Row \\& Column Fractional Means Verified}",
      ),
    );
  }
}