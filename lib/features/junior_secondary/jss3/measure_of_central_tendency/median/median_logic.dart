import 'median_models.dart';

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
  _Frac operator /(_Frac other) =>
      _Frac.from(num * other.den, den * other.num);
}

class _MedianUnitFormat {
  final String prefixLaTeX;
  final String suffixLaTeX;
  final String prefixPlain;
  final String suffixPlain;

  const _MedianUnitFormat({
    this.prefixLaTeX = '',
    this.suffixLaTeX = '',
    this.prefixPlain = '',
    this.suffixPlain = '',
  });
}

class _MedianToken {
  final String raw;
  final _Frac frac;
  final bool isMixed;
  final bool isFractionInput;
  final bool isDecimalInput;
  final String displayLaTeX;
  final String displayPlain;

  const _MedianToken({
    required this.raw,
    required this.frac,
    this.isMixed = false,
    this.isFractionInput = false,
    this.isDecimalInput = false,
    required this.displayLaTeX,
    required this.displayPlain,
  });

  double get value => frac.toDouble;
}

class _ScoreFreqPair {
  final _MedianToken score;
  final int freq;

  const _ScoreFreqPair({
    required this.score,
    required this.freq,
  });
}

class MedianLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 213–215 & Page 218)
  // ===========================================================================
  static const List<MedianPreset> textbookPresets = [
    MedianPreset(
      chipLabel: "Example 2 (Page 213, Odd n=7): 16, 49, 53, 8, 32, 19, 62",
      mode: 0,
      input1: "16, 49, 53, 8, 32, 19, 62",
    ),
    MedianPreset(
      chipLabel:
      "Example 3 (Page 214, Even n=8): 24, 32, 36, 29, 31, 34, 35, 39",
      mode: 0,
      input1: "24, 32, 36, 29, 31, 34, 35, 39",
    ),
    MedianPreset(
      chipLabel: "Example 4 Table 18.6 (Page 214, N=33): Marks 0 to 5",
      mode: 1,
      input1: "0, 1, 2, 3, 4, 5",
      input2: "1, 5, 7, 8, 8, 4",
      unit: "marks",
    ),
    MedianPreset(
      chipLabel: "Ex 18.2 #1a (Page 214): 9, 7, 29, 4, 18, 32, 16",
      mode: 0,
      input1: "9, 7, 29, 4, 18, 32, 16",
    ),
    MedianPreset(
      chipLabel: "Ex 18.2 #1b (Page 214): 11, 13, 5, 7, 19, 17",
      mode: 0,
      input1: "11, 13, 5, 7, 19, 17",
    ),
    MedianPreset(
      chipLabel: "Ex 18.2 #1c (Page 214): 17, 36, 13, 6, 13, 24, 19",
      mode: 0,
      input1: "17, 36, 13, 6, 13, 24, 19",
    ),
    MedianPreset(
      chipLabel: "Ex 18.2 #1d (Page 214): 26, 39, 33, 64, 42, 90, 87",
      mode: 0,
      input1: "26, 39, 33, 64, 42, 90, 87",
    ),
    MedianPreset(
      chipLabel: "Ex 18.2 #1e (Page 214): 0.4, 3.4, 1.2, 3.2, 6.5, 9.8, 1.8",
      mode: 0,
      input1: "0.4, 3.4, 1.2, 3.2, 6.5, 9.8, 1.8",
    ),
    MedianPreset(
      chipLabel: "Ex 18.2 #1f (Page 214): 88, 46, 34, 92, 144, 104, 116, 118",
      mode: 0,
      input1: "88, 46, 34, 92, 144, 104, 116, 118",
    ),
    MedianPreset(
      chipLabel:
      "Ex 18.2 #1g (Page 214): 1.73, 1.84, 1.86, 1.88, 1.89, 1.92, 1.96, 1.98",
      mode: 0,
      input1: "1.73, 1.84, 1.86, 1.88, 1.89, 1.92, 1.96, 1.98",
    ),
    MedianPreset(
      chipLabel: "Ex 18.2 #2 Table 18.7 (Page 214): 10 Students Civic Educ Test",
      mode: 1,
      input1: "0, 1, 2, 3, 4, 5",
      input2: "2, 1, 1, 2, 3, 1",
    ),
    MedianPreset(
      chipLabel: "Ex 18.2 #3c (Page 214): 6, 1, 6, 4, 3, 7, 8",
      mode: 0,
      input1: "6, 1, 6, 4, 3, 7, 8",
    ),
    MedianPreset(
      chipLabel:
      "Ex 18.2 #3e (Page 214): 78, 63, 59, 55, 50, 48, 47, 42, 30, 27, 25",
      mode: 0,
      input1: "78, 63, 59, 55, 50, 48, 47, 42, 30, 27, 25",
    ),
    MedianPreset(
      chipLabel: "Ex 18.2 #4 Table 18.8 (Page 214): Football Goals Last Season",
      mode: 1,
      input1: "0, 1, 2, 3, 4, 5, 6",
      input2: "16, 7, 12, 2, 0, 4, 1",
      unit: "goals",
    ),
    MedianPreset(
      chipLabel: "Ex 18.2 #5 Table 18.9 (Page 215): Supermarket Queue Count",
      mode: 1,
      input1: "0, 1, 2, 3, 4",
      input2: "2, 6, 5, 2, 2",
      unit: "people",
    ),
    MedianPreset(
      chipLabel:
      "Rev Ex 18 #4 (Page 218): Boys' Heights 159, 155, 153, 154, 157, 162, 152, 160, 161, 157",
      mode: 0,
      input1: "159, 155, 153, 154, 157, 162, 152, 160, 161, 157",
      unit: "cm",
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

  static String _ordinal(int n) {
    if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }

  static _MedianUnitFormat _formatUnit(String rawUnit) {
    final String u = rawUnit.trim();
    if (u.isEmpty) {
      return const _MedianUnitFormat();
    }
    if (u == '₦' || u == r'$' || u == '£') {
      return _MedianUnitFormat(
        prefixLaTeX: '\\text{$u}',
        suffixLaTeX: '',
        prefixPlain: u,
        suffixPlain: '',
      );
    }
    return _MedianUnitFormat(
      prefixLaTeX: '',
      suffixLaTeX: '\\text{ $u}',
      prefixPlain: '',
      suffixPlain: ' $u',
    );
  }

  static _MedianToken _parseToken(String rawToken) {
    final String s = rawToken
        .trim()
        .replaceAll('₦', '')
        .replaceAll(r'$', '')
        .replaceAll('£', '')
        .replaceAll('−', '-')
        .replaceAll(
      RegExp(r'\b(kg|cm|mm|km|m|g|years|yrs|marks|goals|people)\b',
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
      return _MedianToken(
        raw: s,
        frac: _Frac.from(impNum, d),
        isMixed: true,
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
      return _MedianToken(
        raw: s,
        frac: _Frac.from(n, d),
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
      return _MedianToken(
        raw: s,
        frac: _Frac.from(sign * (wholeAbs * d + decInt), d),
        isDecimalInput: true,
        displayLaTeX: s,
        displayPlain: s,
      );
    }

    final int? iv = int.tryParse(s);
    if (iv == null) {
      throw FormatException("Could not read '$rawToken' as a valid number.");
    }
    return _MedianToken(
      raw: s,
      frac: _Frac.from(iv, 1),
      displayLaTeX: '$iv',
      displayPlain: '$iv',
    );
  }

  static List<_MedianToken> _parseList(String rawList) {
    final String normalized =
    rawList.replaceAll(RegExp(r'\band\b', caseSensitive: false), ',');
    final List<String> parts = normalized
        .split(RegExp(r'[,;\n]+'))
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      throw const FormatException(
        "Please enter numbers separated by commas (e.g. 16, 49, 53, 8, 32, 19, 62).",
      );
    }
    return parts.map(_parseToken).toList();
  }

  // ===========================================================================
  // MASTER ROUTER
  // ===========================================================================
  static MedianResult solveMedian({
    required int mode,
    required String rawInput1,
    String rawInput2 = '',
    String unit = '',
  }) {
    try {
      if (mode == 0) {
        return _solveUngroupedMedian(rawInput1, unit);
      } else {
        return _solveFrequencyTableMedian(rawInput1, rawInput2, unit);
      }
    } catch (e) {
      return MedianResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please check your numbers and try again.",
      );
    }
  }

  // ===========================================================================
  // MODE 0: UNGROUPED DATA MEDIAN (Example 2 Odd & Example 3 Even, Pages 213–214)
  // ===========================================================================
  static MedianResult _solveUngroupedMedian(String rawList, String unit) {
    final List<_MedianToken> original = _parseList(rawList);
    if (original.length < 2) {
      throw const FormatException(
        "Please enter at least 2 numbers separated by commas to find the median.",
      );
    }

    final _MedianUnitFormat u = _formatUnit(unit);
    final List<_MedianToken> sortedAsc = List<_MedianToken>.from(original)
      ..sort((_MedianToken a, _MedianToken b) => a.value.compareTo(b.value));
    final List<_MedianToken> sortedDesc =
    List<_MedianToken>.from(sortedAsc.reversed);

    final int n = sortedAsc.length;
    final bool isEven = n % 2 == 0;

    final String origLaTeX =
    original.map((_MedianToken e) => e.displayLaTeX).join(', \\; ');
    final String ascLaTeX =
    sortedAsc.map((_MedianToken e) => e.displayLaTeX).join(', \\; ');
    final String descLaTeX =
    sortedDesc.map((_MedianToken e) => e.displayLaTeX).join(', \\; ');
    final String ascPlain =
    sortedAsc.map((_MedianToken e) => e.displayPlain).join(', ');

    if (!isEven) {
      // ODD NUMBER OF TERMS (Example 2, Page 213)
      final int midPos = (n + 1) ~/ 2;
      final _MedianToken midItem = sortedAsc[midPos - 1];
      final String ordPos = _ordinal(midPos);

      final List<String> highlightedAsc = [];
      for (int i = 0; i < n; i++) {
        if (i == midPos - 1) {
          highlightedAsc.add("\\mathbf{[${sortedAsc[i].displayLaTeX}]}");
        } else {
          highlightedAsc.add(sortedAsc[i].displayLaTeX);
        }
      }

      final String colSpec = List.filled(n, 'c').join('|');
      final String posHeaders = List.generate(n, (int i) {
        final int p = i + 1;
        return p == midPos
            ? "\\mathbf{\\text{Mid (${_ordinal(p)})}}"
            : "\\text{${_ordinal(p)}}";
      }).join(' & ');
      final String valRow = List.generate(n, (int i) {
        final int p = i + 1;
        return p == midPos
            ? "\\mathbf{[${sortedAsc[i].displayLaTeX}]}"
            : sortedAsc[i].displayLaTeX;
      }).join(' & ');
      final String stripBoxLaTeX =
          "\\begin{array}{|$colSpec|} \\hline $posHeaders \\\\ \\hline $valRow \\\\ \\hline \\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Given Set of Data (Page 213):}}",
        "\\mathbf{$origLaTeX}",
        "",
        "\\text{\\textbf{Step 1: Rearrange the Numbers in Ascending Order of Magnitude}}",
        "\\text{Ascending order (smallest to largest): } \\mathbf{$ascLaTeX}",
        "\\text{Descending order (largest to smallest): } $descLaTeX",
        "",
        "\\text{\\textbf{Step 2: Count the Total Number of Values (n)}}",
        "n = \\mathbf{$n} \\quad (\\text{Odd number of values})",
        "",
        "\\text{\\textbf{Step 3: Calculate the Middle Position Using }} \\frac{n + 1}{2}",
        "\\text{Middle Position} = \\left(\\frac{n + 1}{2}\\right)\\text{th term} = \\left(\\frac{$n + 1}{2}\\right)\\text{th term} = \\frac{${n + 1}}{2}\\text{th term} = \\mathbf{\\text{$ordPos term}}",
        "",
        "\\text{\\textbf{Step 4: Identify the $ordPos Term in the Ordered List}}",
        "\\text{Ordered Data: } ${highlightedAsc.join(', \\; ')}",
        "\\therefore \\; \\text{Median} = \\mathbf{${u.prefixLaTeX}${midItem.displayLaTeX}${u.suffixLaTeX}}",
      ];

      final List<MedianStep> steps = [
        MedianStep(
          title:
          "Step 1: Arrange the Given Data in Order of Magnitude (Example 2, Page 213)",
          description:
          "• Rearrange the numbers from smallest to largest (ascending order): $ascPlain.\n"
              "• Note that the result is the exact same if arranged in descending order.",
          mathLinesLaTeX: [
            "\\text{Original models: } $origLaTeX",
            "\\text{Ascending order: } \\mathbf{$ascLaTeX}",
            "\\text{Descending order: } $descLaTeX",
          ],
        ),
        MedianStep(
          title:
          "Step 2: Count the Number of Terms (n) and Find the Middle Position",
          description:
          "• There are $n terms in the set (which is an odd number).\n"
              "• Substitute n = $n into the middle position formula (n + 1) ÷ 2.",
          mathLinesLaTeX: [
            "n = $n \\quad (\\text{Odd})",
            "\\text{Middle Position} = \\left(\\frac{n + 1}{2}\\right)\\text{th term} = \\frac{$n + 1}{2} = \\frac{${n + 1}}{2} = \\mathbf{\\text{$ordPos term}}",
          ],
        ),
        MedianStep(
          title: "Step 3: Read Off the $ordPos Term as the Median",
          description:
          "• Counting to the $ordPos number in the ordered list gives ${u.prefixPlain}${midItem.displayPlain}${u.suffixPlain}.",
          mathLinesLaTeX: [
            "\\text{Ordered list: } ${highlightedAsc.join(', \\; ')}",
            "\\therefore \\; \\text{Median} = \\mathbf{${u.prefixLaTeX}${midItem.displayLaTeX}${u.suffixLaTeX}}",
          ],
        ),
      ];

      return MedianResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Total Terms (n)": "$n \\text{ (Odd)}",
          "Middle Position": "\\frac{$n + 1}{2} = \\text{$ordPos term}",
          "Median":
          "\\mathbf{${u.prefixLaTeX}${midItem.displayLaTeX}${u.suffixLaTeX}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: MedianCanvasData(
          headerLaTeX:
          "\\text{Chapter 18 Median for Odd } n \\text{ (Example 2, Page 213): } \\text{Position} = \\frac{n + 1}{2}",
          subHeaderLaTeX:
          "\\text{Middle Position} = \\frac{$n + 1}{2} = \\frac{${n + 1}}{2} = \\text{$ordPos term} \\implies \\mathbf{${midItem.displayLaTeX}}",
          card1Title: "Total Terms (n)",
          card1LaTeX: "$n \\text{ (Odd)}",
          card2Title: "Middle Position",
          card2LaTeX: "\\frac{$n + 1}{2} = \\text{$ordPos}",
          card3Title: "Median Value",
          card3LaTeX:
          "\\mathbf{${u.prefixLaTeX}${midItem.displayLaTeX}${u.suffixLaTeX}}",
          mainBoxLaTeX: stripBoxLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{The middle ($ordPos) number is } \\mathbf{${u.prefixLaTeX}${midItem.displayLaTeX}${u.suffixLaTeX}}",
        ),
      );
    } else {
      // EVEN NUMBER OF TERMS (Example 3, Page 214)
      final int pos1 = n ~/ 2;
      final int pos2 = pos1 + 1;
      final String ord1 = _ordinal(pos1);
      final String ord2 = _ordinal(pos2);
      final _MedianToken item1 = sortedAsc[pos1 - 1];
      final _MedianToken item2 = sortedAsc[pos2 - 1];

      final double sumMiddle = item1.value + item2.value;
      final String sumMidStr = _cleanDouble(sumMiddle);
      final double medianVal = sumMiddle / 2.0;
      final String medianStr = _cleanDouble(medianVal);

      final List<String> highlightedAsc = [];
      for (int i = 0; i < n; i++) {
        if (i == pos1 - 1 || i == pos2 - 1) {
          highlightedAsc.add("\\mathbf{[${sortedAsc[i].displayLaTeX}]}");
        } else {
          highlightedAsc.add(sortedAsc[i].displayLaTeX);
        }
      }

      final String colSpec = List.filled(n, 'c').join('|');
      final String posHeaders = List.generate(n, (int i) {
        final int p = i + 1;
        return (p == pos1 || p == pos2)
            ? "\\mathbf{\\text{Mid (${_ordinal(p)})}}"
            : "\\text{${_ordinal(p)}}";
      }).join(' & ');
      final String valRow = List.generate(n, (int i) {
        final int p = i + 1;
        return (p == pos1 || p == pos2)
            ? "\\mathbf{[${sortedAsc[i].displayLaTeX}]}"
            : sortedAsc[i].displayLaTeX;
      }).join(' & ');
      final String stripBoxLaTeX =
          "\\begin{array}{|$colSpec|} \\hline $posHeaders \\\\ \\hline $valRow \\\\ \\hline \\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Given Set of Data (Example 3, Page 214):}}",
        "\\mathbf{$origLaTeX}",
        "",
        "\\text{\\textbf{Step 1: Arrange the Data in Ascending Order of Magnitude}}",
        "\\text{Ascending order: } \\mathbf{$ascLaTeX}",
        "\\text{Descending order: } $descLaTeX",
        "",
        "\\text{\\textbf{Step 2: Count the Terms and Locate the Two Middle Positions}}",
        "n = \\mathbf{$n} \\quad (\\text{Even number of terms})",
        "\\text{1st Middle Position} = \\frac{n}{2} = \\frac{$n}{2} = \\mathbf{\\text{$ord1 term}} = ${item1.displayLaTeX}",
        "\\text{2nd Middle Position} = \\frac{n}{2} + 1 = $pos1 + 1 = \\mathbf{\\text{$ord2 term}} = ${item2.displayLaTeX}",
        "\\text{Ordered list with middle pair highlighted: } ${highlightedAsc.join(', \\; ')}",
        "",
        "\\text{\\textbf{Step 3: Add the Two Middle Terms and Divide their Sum by 2}}",
        "\\text{Median} = \\frac{\\text{$ord1 term} + \\text{$ord2 term}}{2}",
        "\\text{Median} = \\frac{${item1.displayLaTeX} + ${item2.displayLaTeX}}{2}",
        "\\text{Median} = \\frac{$sumMidStr}{2}",
        "\\therefore \\; \\text{Median} = \\mathbf{${u.prefixLaTeX}$medianStr${u.suffixLaTeX}}",
      ];

      final List<MedianStep> steps = [
        MedianStep(
          title:
          "Step 1: Arrange the Data in Ascending Order of Magnitude (Page 214)",
          description:
          "• Arrange the given values from smallest to largest: $ascPlain.",
          mathLinesLaTeX: [
            "\\text{Original models: } $origLaTeX",
            "\\text{Ascending order: } \\mathbf{$ascLaTeX}",
          ],
        ),
        MedianStep(
          title: "Step 2: Identify the Two Middle Terms (Since n = $n is Even)",
          description:
          "• Since there are $n terms in the set (which is even), the two middle terms are at positions n ÷ 2 ($ord1 term) and (n ÷ 2) + 1 ($ord2 term).",
          mathLinesLaTeX: [
            "\\text{First middle position} = \\frac{n}{2} = \\frac{$n}{2} = \\text{$ord1 term} = \\mathbf{${item1.displayLaTeX}}",
            "\\text{Second middle position} = \\frac{n}{2} + 1 = $pos1 + 1 = \\text{$ord2 term} = \\mathbf{${item2.displayLaTeX}}",
            "\\text{Ordered list: } ${highlightedAsc.join(', \\; ')}",
          ],
        ),
        MedianStep(
          title:
          "Step 3: Add the Two Middle Terms and Divide the Sum by 2 (Example 3)",
          description:
          "• Add ${item1.displayPlain} and ${item2.displayPlain} to get $sumMidStr, then divide by 2 to get ${u.prefixPlain}$medianStr${u.suffixPlain}.",
          mathLinesLaTeX: [
            "\\text{Median} = \\frac{${item1.displayLaTeX} + ${item2.displayLaTeX}}{2} = \\frac{$sumMidStr}{2} = \\mathbf{${u.prefixLaTeX}$medianStr${u.suffixLaTeX}}",
          ],
        ),
      ];

      return MedianResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Total Terms (n)": "$n \\text{ (Even)}",
          "Two Middle Terms":
          "${item1.displayLaTeX} \\text{ and } ${item2.displayLaTeX}",
          "Median":
          "\\frac{${item1.displayLaTeX} + ${item2.displayLaTeX}}{2} = \\frac{$sumMidStr}{2} = \\mathbf{${u.prefixLaTeX}$medianStr${u.suffixLaTeX}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: MedianCanvasData(
          headerLaTeX:
          "\\text{Chapter 18 Median for Even } n \\text{ (Example 3, Page 214): } \\text{Median} = \\frac{x_{(n/2)} + x_{(n/2+1)}}{2}",
          subHeaderLaTeX:
          "\\text{Two Middle Terms ($ord1 \\& $ord2): } \\frac{${item1.displayLaTeX} + ${item2.displayLaTeX}}{2} = \\frac{$sumMidStr}{2} = \\mathbf{${u.prefixLaTeX}$medianStr${u.suffixLaTeX}}",
          card1Title: "Total Terms (n)",
          card1LaTeX: "$n \\text{ (Even)}",
          card2Title: "Middle Pair ($ord1 & $ord2)",
          card2LaTeX: "${item1.displayLaTeX}, \\; ${item2.displayLaTeX}",
          card3Title: "Average (Median)",
          card3LaTeX:
          "\\frac{$sumMidStr}{2} = \\mathbf{${u.prefixLaTeX}$medianStr${u.suffixLaTeX}}",
          mainBoxLaTeX: stripBoxLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Median} = \\frac{${item1.displayLaTeX} + ${item2.displayLaTeX}}{2} = \\frac{$sumMidStr}{2} = \\mathbf{${u.prefixLaTeX}$medianStr${u.suffixLaTeX}}",
        ),
      );
    }
  }

  // ===========================================================================
  // MODE 1: FREQUENCY TABLE MEDIAN (Example 4, Page 214 — Both Textbook Methods!)
  // ===========================================================================
  static MedianResult _solveFrequencyTableMedian(
      String rawScores,
      String rawFrequencies,
      String unit,
      ) {
    final List<_MedianToken> scores = _parseList(rawScores);
    final List<_MedianToken> freqs = _parseList(rawFrequencies);

    if (scores.length != freqs.length) {
      throw FormatException(
        "The number of Marks/Scores (${scores.length}) must match the number of Frequencies (${freqs.length}).",
      );
    }
    if (scores.length < 2) {
      throw const FormatException(
        "Please enter at least 2 marks/scores and their frequencies.",
      );
    }

    final List<_ScoreFreqPair> pairs = [];

    for (int i = 0; i < scores.length; i++) {
      if (!freqs[i].frac.isInteger || freqs[i].frac.num < 0) {
        throw FormatException(
          "Frequency at position ${i + 1} must be a non-negative whole number.",
        );
      }
      final int f = freqs[i].frac.num;
      if (f > 0) {
        pairs.add(_ScoreFreqPair(score: scores[i], freq: f));
      }
    }

    if (pairs.isEmpty) {
      throw const FormatException("Total frequency must be greater than zero.");
    }

    pairs.sort(
            (_ScoreFreqPair a, _ScoreFreqPair b) => a.score.value.compareTo(b.score.value));

    final int totalFreq =
    pairs.fold(0, (int s, _ScoreFreqPair e) => s + e.freq);
    final bool isEven = totalFreq % 2 == 0;
    final List<int> targetPositions = isEven
        ? [totalFreq ~/ 2, (totalFreq ~/ 2) + 1]
        : [(totalFreq + 1) ~/ 2];

    final _MedianUnitFormat u = _formatUnit(unit);

    final List<String> freqAddLaTeX = [
      "\\sum f = ${pairs.map((_ScoreFreqPair p) => p.freq).join(' + ')}",
    ];
    int runF = pairs[0].freq;
    for (int i = 1; i < pairs.length; i++) {
      final int prev = runF;
      final int cur = pairs[i].freq;
      runF += cur;
      freqAddLaTeX
          .add("\\bullet \\text{ Step $i: } $prev + $cur = \\mathbf{$runF}");
    }
    freqAddLaTeX
        .add("\\therefore \\; \\text{Total Frequency } (N) = \\mathbf{$totalFreq}");

    final List<String> countdownLinesLaTeX = [];
    final List<String> countdownPlain = [];
    final List<String> tableRowsLaTeX = [];
    int cum = 0;

    _MedianToken scoreAtPosition(int pos) {
      int c = 0;
      for (final _ScoreFreqPair p in pairs) {
        final int start = c + 1;
        c += p.freq;
        if (pos >= start && pos <= c) return p.score;
      }
      return pairs.last.score;
    }

    for (final _ScoreFreqPair p in pairs) {
      final int startPos = cum + 1;
      cum += p.freq;
      final int endPos = cum;
      final bool hitsMedian =
      targetPositions.any((int t) => t >= startPos && t <= endPos);

      final String posRangeStr = startPos == endPos
          ? _ordinal(startPos)
          : "${_ordinal(startPos)} \\text{ to } ${_ordinal(endPos)}";

      countdownLinesLaTeX.add(
        "\\bullet \\text{ Score } \\mathbf{${p.score.displayLaTeX}}: \\text{ freq } = ${p.freq}, \\; \\text{cumulative } = \\mathbf{$cum} \\; (\\text{positions: } $posRangeStr)${hitsMedian ? ' \\; \\longleftarrow \\mathbf{\\text{Median class!}}' : ''}",
      );
      countdownPlain.add(
        "• Score ${p.score.displayPlain}: frequency = ${p.freq}, cumulative total = $cum (positions ${_ordinal(startPos)} to ${_ordinal(endPos)})${hitsMedian ? ' <-- Median is here!' : ''}",
      );
      tableRowsLaTeX.add(
        "${p.score.displayLaTeX} & ${p.freq} & $cum & $posRangeStr${hitsMedian ? ' \\; \\mathbf{\\star}' : ''} \\\\ \\hline ",
      );
    }

    String expandedListLaTeX = '';
    if (totalFreq <= 60) {
      final List<String> expanded = [];
      int idx = 0;
      for (final _ScoreFreqPair p in pairs) {
        for (int k = 0; k < p.freq; k++) {
          idx++;
          if (targetPositions.contains(idx)) {
            expanded.add("\\mathbf{[${p.score.displayLaTeX}]}");
          } else {
            expanded.add(p.score.displayLaTeX);
          }
        }
      }
      expandedListLaTeX = expanded.join(', \\; ');
    }

    final String cumTableLaTeX =
        "\\begin{array}{|c|c|c|c|} \\hline \\mathbf{\\text{Mark/Score } (x)} & \\mathbf{\\text{Frequency } (f)} & \\mathbf{\\text{Cumulative Freq}} & \\mathbf{\\text{Position Range}} \\\\ \\hline "
        "${tableRowsLaTeX.join()}"
        "\\mathbf{\\text{Total}} & \\mathbf{N = $totalFreq} & - & - \\\\ \\hline \\end{array}";

    if (!isEven) {
      final int midPos = targetPositions.first;
      final String ordPos = _ordinal(midPos);
      final _MedianToken medScore = scoreAtPosition(midPos);

      final List<String> workings = [
        "\\text{\\textbf{Frequency Table with Cumulative Positions (Example 4, Page 214):}}",
        cumTableLaTeX,
        "",
        "\\text{\\textbf{Step 1: Find the Total Frequency (N)}}",
        ...freqAddLaTeX,
        "",
        "\\text{\\textbf{Step 2: Find the Middle Position Using }} \\frac{N + 1}{2}",
        "\\text{Median Position} = \\left(\\frac{N + 1}{2}\\right)\\text{th mark} = \\frac{$totalFreq + 1}{2} = \\frac{${totalFreq + 1}}{2} = \\mathbf{\\text{$ordPos mark}}",
        "",
        if (expandedListLaTeX.isNotEmpty) ...[
          "\\text{\\textbf{Step 3 (Textbook Method 1, Page 214): Write Out All $totalFreq Scores in Ascending Order}}",
          expandedListLaTeX,
          "\\text{The $ordPos mark is } \\mathbf{${medScore.displayLaTeX}}.",
          "",
        ],
        "\\text{\\textbf{Step ${expandedListLaTeX.isNotEmpty ? 4 : 3} (Textbook Method 2, Page 214): Count Down the Frequencies}}",
        ...countdownLinesLaTeX,
        "\\text{The $ordPos mark is in the list of } \\mathbf{${medScore.displayLaTeX}}\\text{'s.}",
        "\\therefore \\; \\text{Median} = \\mathbf{${u.prefixLaTeX}${medScore.displayLaTeX}${u.suffixLaTeX}}",
      ];

      final List<MedianStep> steps = [
        MedianStep(
          title: "Step 1: Add All Frequencies Together to Find Total Scores (N)",
          description:
          "• Sum all the frequencies in the table to find the total number of scores (N = $totalFreq).",
          mathLinesLaTeX: freqAddLaTeX,
        ),
        MedianStep(
          title: "Step 2: Calculate the Median Position (Example 4, Page 214)",
          description:
          "• Since there are $totalFreq scores (an odd total), when arranged in ascending order of magnitude, the ((N + 1) ÷ 2)th mark is the median.",
          mathLinesLaTeX: [
            "\\text{Median Position} = \\frac{N + 1}{2} = \\frac{$totalFreq + 1}{2} = \\frac{${totalFreq + 1}}{2} = \\mathbf{\\text{$ordPos mark}}",
          ],
        ),
        if (expandedListLaTeX.isNotEmpty)
          MedianStep(
            title:
            "Step 3 (Method 1): Write Out All $totalFreq Scores in Ascending Order",
            description:
            "• As shown in Example 4 on page 214, writing out all $totalFreq scores in ascending order shows that the $ordPos score is ${medScore.displayPlain}.",
            mathLinesLaTeX: [
              expandedListLaTeX,
              "\\text{The $ordPos score is } \\mathbf{${medScore.displayLaTeX}}",
            ],
          ),
        MedianStep(
          title:
          "Step ${expandedListLaTeX.isNotEmpty ? 4 : 3} (Method 2): Count Down the Frequencies Without Listing All Scores",
          description:
          "• Count down the frequencies row by row until we reach the $ordPos item:\n"
              "${countdownPlain.join('\n')}",
          mathLinesLaTeX: [
            ...countdownLinesLaTeX,
            cumTableLaTeX,
            "\\therefore \\; \\text{Median} = \\mathbf{${u.prefixLaTeX}${medScore.displayLaTeX}${u.suffixLaTeX}}",
          ],
        ),
      ];

      return MedianResult(
        mode: 1,
        finalAnswersLaTeX: {
          "Total Frequency (N)": "$totalFreq \\text{ (Odd)}",
          "Median Position": "\\frac{$totalFreq + 1}{2} = \\text{$ordPos item}",
          "Median":
          "\\mathbf{${u.prefixLaTeX}${medScore.displayLaTeX}${u.suffixLaTeX}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: MedianCanvasData(
          headerLaTeX:
          "\\text{Example 4 Frequency Table Median (Page 214): } N = $totalFreq",
          subHeaderLaTeX:
          "\\text{Median Position} = \\frac{N + 1}{2} = \\frac{$totalFreq + 1}{2} = \\text{$ordPos item} \\implies \\mathbf{${medScore.displayLaTeX}}",
          card1Title: "Total Frequency (N)",
          card1LaTeX: "$totalFreq",
          card2Title: "Median Position",
          card2LaTeX: "\\frac{$totalFreq + 1}{2} = \\text{$ordPos}",
          card3Title: "Median Score",
          card3LaTeX:
          "\\mathbf{${u.prefixLaTeX}${medScore.displayLaTeX}${u.suffixLaTeX}}",
          mainBoxLaTeX: cumTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{The $ordPos item falls in score } ${medScore.displayLaTeX} \\implies \\text{Median} = \\mathbf{${u.prefixLaTeX}${medScore.displayLaTeX}${u.suffixLaTeX}}",
        ),
      );
    } else {
      // EVEN TOTAL FREQUENCY IN TABLE
      final int pos1 = targetPositions[0];
      final int pos2 = targetPositions[1];
      final String ord1 = _ordinal(pos1);
      final String ord2 = _ordinal(pos2);
      final _MedianToken item1 = scoreAtPosition(pos1);
      final _MedianToken item2 = scoreAtPosition(pos2);

      final double sumMid = item1.value + item2.value;
      final String sumMidStr = _cleanDouble(sumMid);
      final double medVal = sumMid / 2.0;
      final String medStr = _cleanDouble(medVal);

      final List<String> workings = [
        "\\text{\\textbf{Frequency Table with Cumulative Positions (Page 214):}}",
        cumTableLaTeX,
        "",
        "\\text{\\textbf{Step 1: Find the Total Frequency (N)}}",
        ...freqAddLaTeX,
        "",
        "\\text{\\textbf{Step 2: Locate the Two Middle Positions (Since N = $totalFreq is Even)}}",
        "\\text{1st Middle Position} = \\frac{N}{2} = \\frac{$totalFreq}{2} = \\mathbf{\\text{$ord1 item}}",
        "\\text{2nd Middle Position} = \\frac{N}{2} + 1 = $pos1 + 1 = \\mathbf{\\text{$ord2 item}}",
        "",
        if (expandedListLaTeX.isNotEmpty) ...[
          "\\text{\\textbf{Step 3 (Method 1): Expanded List of All $totalFreq Scores}}",
          expandedListLaTeX,
          "",
        ],
        "\\text{\\textbf{Step ${expandedListLaTeX.isNotEmpty ? 4 : 3} (Method 2): Count Down the Frequencies}}",
        ...countdownLinesLaTeX,
        "\\text{The $ord1 item is } \\mathbf{${item1.displayLaTeX}} \\text{ and the $ord2 item is } \\mathbf{${item2.displayLaTeX}}.",
        "",
        "\\text{\\textbf{Step ${expandedListLaTeX.isNotEmpty ? 5 : 4}: Find the Mean of the Two Middle Scores}}",
        "\\text{Median} = \\frac{${item1.displayLaTeX} + ${item2.displayLaTeX}}{2} = \\frac{$sumMidStr}{2} = \\mathbf{${u.prefixLaTeX}$medStr${u.suffixLaTeX}}",
      ];

      final List<MedianStep> steps = [
        MedianStep(
          title: "Step 1: Add All Frequencies Together to Find Total Items (N)",
          description:
          "• Add the frequencies in the table step-by-step to get N = $totalFreq.",
          mathLinesLaTeX: freqAddLaTeX,
        ),
        MedianStep(
          title:
          "Step 2: Find the Two Middle Positions (Since N = $totalFreq is Even)",
          description:
          "• Because $totalFreq is an even number, the median is the mean of the (N ÷ 2)th ($ord1) and ((N ÷ 2) + 1)th ($ord2) items.",
          mathLinesLaTeX: [
            "\\text{1st Middle Position} = \\frac{$totalFreq}{2} = \\text{$ord1 item}",
            "\\text{2nd Middle Position} = \\frac{$totalFreq}{2} + 1 = \\text{$ord2 item}",
          ],
        ),
        MedianStep(
          title:
          "Step 3: Count Down the Frequencies & Average the Two Middle Scores",
          description:
          "• Count down the cumulative frequencies to locate the $ord1 and $ord2 scores:\n"
              "${countdownPlain.join('\n')}",
          mathLinesLaTeX: [
            ...countdownLinesLaTeX,
            "\\text{Median} = \\frac{${item1.displayLaTeX} + ${item2.displayLaTeX}}{2} = \\frac{$sumMidStr}{2} = \\mathbf{${u.prefixLaTeX}$medStr${u.suffixLaTeX}}",
          ],
        ),
      ];

      return MedianResult(
        mode: 1,
        finalAnswersLaTeX: {
          "Total Frequency (N)": "$totalFreq \\text{ (Even)}",
          "Middle Positions":
          "\\text{$ord1 and $ord2 items} \\; (${item1.displayLaTeX}, \\; ${item2.displayLaTeX})",
          "Median":
          "\\frac{${item1.displayLaTeX} + ${item2.displayLaTeX}}{2} = \\frac{$sumMidStr}{2} = \\mathbf{${u.prefixLaTeX}$medStr${u.suffixLaTeX}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: MedianCanvasData(
          headerLaTeX:
          "\\text{Frequency Table Median for Even } N = $totalFreq \\text{ (Page 214)}",
          subHeaderLaTeX:
          "\\text{Middle Items ($ord1 \\& $ord2): } \\frac{${item1.displayLaTeX} + ${item2.displayLaTeX}}{2} = \\frac{$sumMidStr}{2} = \\mathbf{${u.prefixLaTeX}$medStr${u.suffixLaTeX}}",
          card1Title: "Total Frequency (N)",
          card1LaTeX: "$totalFreq \\text{ (Even)}",
          card2Title: "$ord1 & $ord2 Items",
          card2LaTeX: "${item1.displayLaTeX}, \\; ${item2.displayLaTeX}",
          card3Title: "Median Score",
          card3LaTeX:
          "\\frac{$sumMidStr}{2} = \\mathbf{${u.prefixLaTeX}$medStr${u.suffixLaTeX}}",
          mainBoxLaTeX: cumTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Median} = \\frac{${item1.displayLaTeX} + ${item2.displayLaTeX}}{2} = \\frac{$sumMidStr}{2} = \\mathbf{${u.prefixLaTeX}$medStr${u.suffixLaTeX}}",
        ),
      );
    }
  }
}