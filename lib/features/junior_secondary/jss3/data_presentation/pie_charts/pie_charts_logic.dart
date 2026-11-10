import 'pie_charts_models.dart';

/// Exact Rational Number (Fraction & Mixed Number) Engine so every fraction is rendered via \frac{num}{den} in Math.tex!
class _PieFrac {
  final int num;
  final int den;

  const _PieFrac(this.num, [this.den = 1]);

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

  factory _PieFrac.from(int n, [int d = 1]) {
    if (d == 0) throw const FormatException("Denominator cannot be zero.");
    if (n == 0) return const _PieFrac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _PieFrac(sign * (an ~/ g), ad ~/ g);
  }

  double get toDouble => num / den;
  bool get isInteger => den == 1;
  bool get isFraction => den != 1;

  _PieFrac operator +(_PieFrac other) =>
      _PieFrac.from(num * other.den + other.num * den, den * other.den);
  _PieFrac operator -(_PieFrac other) =>
      _PieFrac.from(num * other.den - other.num * den, den * other.den);
  _PieFrac operator *(_PieFrac other) =>
      _PieFrac.from(num * other.num, den * other.den);
  _PieFrac operator /(_PieFrac other) {
    if (other.num == 0) throw const FormatException("Cannot divide by zero.");
    return _PieFrac.from(num * other.den, den * other.num);
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

  String toPlain() {
    if (num == 0) return '0';
    final String sign = num < 0 ? '-' : '';
    final int an = num.abs();
    if (den == 1) return '$sign$an';
    if (an > den) {
      final int whole = an ~/ den;
      final int rem = an % den;
      if (rem == 0) return '$sign$whole';
      return '$sign$whole $rem/$den';
    }
    return '$sign$an/$den';
  }
}

class _PieUnitFormat {
  final String prefixLaTeX;
  final String suffixLaTeX;
  final String prefixPlain;
  final String suffixPlain;

  const _PieUnitFormat({
    this.prefixLaTeX = '',
    this.suffixLaTeX = '',
    this.prefixPlain = '',
    this.suffixPlain = '',
  });
}

class _PieParsedEntry {
  final String raw;
  final _PieFrac frac;
  final int origNum;
  final int origDen;
  final bool isMixed;
  final int? mixedWhole;
  final int? mixedNum;
  final int? mixedDen;
  final bool isFractionInput;
  final bool isDecimalInput;
  final bool isPercentToken;
  final bool isUnknownVar;
  final String unknownVarName;
  final _PieFrac unknownConstantOffset;
  final String displayLaTeX;
  final String displayPlain;

  const _PieParsedEntry({
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
    this.isPercentToken = false,
    this.isUnknownVar = false,
    this.unknownVarName = 'x',
    this.unknownConstantOffset = const _PieFrac(0, 1),
    required this.displayLaTeX,
    required this.displayPlain,
  });
}

class PieChartsLogic {
  // ===========================================================================
  // 15 TEXTBOOK PRESETS (Pages 228–233 & Pages 236–237)
  // ===========================================================================
  static const List<PieChartPreset> textbookPresets = [
    PieChartPreset(
      chipLabel: "Example 5 (Page 228, Fig. 19.12): 30 Students Reality Show",
      mode: 0,
      categoriesInput: "Producers, Mimers, Choreographers, Costumiers",
      valuesInput: "4, 6, 15, 5",
      chartTitle: "Students' Roles in School Reality Show",
      unit: "students",
    ),
    PieChartPreset(
      chipLabel:
      "Example 6 (Page 229, Fig. 19.13 & Table 19.11/19.12): 72,000 Drug Addicts",
      mode: 1,
      categoriesInput:
      "HIV/AIDS, Infection, Collapsed arteries, Abscesses, Hepatitis",
      valuesInput: "30 5/9, 27 7/9, 11 1/9, 16 2/3, 13 8/9",
      totalOrKnownInput: "72000",
      chartTitle: "Ailments Suffered by 72,000 Drug Addicts",
      unit: "addicts",
    ),
    PieChartPreset(
      chipLabel: "Fig. 19.4 / 19.11 (Page 221 & 228): Sports Day Events Angles",
      mode: 2,
      categoriesInput: "Football, Athletics, Swimming, Basketball",
      valuesInput: "90, 160, 60, 50",
      totalOrKnownInput: "360",
      chartTitle: "Numbers in Sports Day Events",
      unit: "students",
    ),
    PieChartPreset(
      chipLabel:
      "Ex 19.2 #1 Table 19.13 (Page 230): Zainab's 24 Hours at Weekends",
      mode: 0,
      categoriesInput: "Sleeping, Sport, Homework, Eating, Visiting friends",
      valuesInput: "9, 5, 2, 1, 7",
      chartTitle: "How Zainab Spends 24 Hours at Weekends (r = 4 cm)",
      unit: "hours",
    ),
    PieChartPreset(
      chipLabel:
      "Ex 19.2 #2 Table 19.14 (Page 231): 120 Mobile Phones Sold by Colour",
      mode: 0,
      categoriesInput: "Black, Yellow, Pink, Blue",
      valuesInput: "75, 5, 25, 15",
      chartTitle: "Mobile Phone Colours Sold in August (r = 5 cm)",
      unit: "phones",
    ),
    PieChartPreset(
      chipLabel:
      "Ex 19.2 #3 Table 19.15 (Page 231): 12,000 Children by School Type",
      mode: 0,
      categoriesInput:
      "State nursery, State primary, State secondary, Private schools, Special schools",
      valuesInput: "517, 5725, 4266, 998, 494",
      chartTitle: "Number of Children by School Type (Thousands)",
      unit: "thousand children",
    ),
    PieChartPreset(
      chipLabel:
      "Ex 19.2 #4 Table 19.16 (Page 231): Grades of 120 JSS 3 Students",
      mode: 0,
      categoriesInput: "Grade A, Grade B, Grade C, Grade D",
      valuesInput: "24, 58, 33, 5",
      chartTitle: "Grades of 120 JSS 3 Students (r = 4 1/2 cm)",
      unit: "students",
    ),
    PieChartPreset(
      chipLabel:
      "Ex 19.2 #5 Fig. 19.14 (Page 232): HIV/AIDS Contraction & Unknown (90+x)°",
      mode: 2,
      categoriesInput:
      "Unprotected sex, Unsterilised utensils, Blood transfusion",
      valuesInput: "165, 90 + x, 16 2/3%",
      totalOrKnownInput: "Unprotected sex = 11000",
      chartTitle: "How HIV/AIDS-Infected Persons Contracted the Disease",
      unit: "people",
    ),
    PieChartPreset(
      chipLabel:
      "Ex 19.2 #6 Fig. 19.15 & Table 19.17 (Page 232): 15,000,000 Youths Drug Abuse",
      mode: 2,
      categoriesInput:
      "Marijuana, Stimulants, Sedatives, Pain relievers, Inhalants, Crack",
      valuesInput: "122.4, 32.4, 14.4, 86.4, 32.4, 72",
      totalOrKnownInput: "15000000",
      chartTitle: "Non-Medically Prescribed Drugs Abused by 15 Million Youths",
      unit: "youths",
    ),
    PieChartPreset(
      chipLabel:
      "Ex 19.2 #7 Table 19.18 (Page 233): 216,000 Illicit Drug Symptoms",
      mode: 2,
      categoriesInput:
      "Insomnia, Loss of attention, Watery red eye, Stealing, Violence",
      valuesInput: "58, 25, 15%, 119, 28 8/9%",
      totalOrKnownInput: "216000",
      chartTitle: "Symptoms Exhibited by 216,000 Individuals",
      unit: "people",
    ),
    PieChartPreset(
      chipLabel: "Rev Ex 19 #4 Table 19.21 (Page 236): 120 g Cornflakes Packet",
      mode: 0,
      categoriesInput: "Carbohydrate, Fat, Protein, Other ingredients",
      valuesInput: "100, 2, 10, 8",
      chartTitle: "Composition of 120 g of Cornflakes",
      unit: "g",
    ),
    PieChartPreset(
      chipLabel:
      "Rev Ex 19 #5 Fig. 19.19 (Page 236): ₦3,840,000 Ebonee Superstore Sales",
      mode: 2,
      categoriesInput: "Food, Clothes, Drinks, Toys",
      valuesInput: "192, 60, 60, 48",
      totalOrKnownInput: "3840000",
      chartTitle: "Goods Sold by Ebonee Superstore (Total = ₦3,840,000)",
      unit: "₦",
    ),
    PieChartPreset(
      chipLabel:
      "Rev Ex 19 #6 (Page 236): Masses of A, B and C in Ratio 1 : 3/2 : 2",
      mode: 3,
      categoriesInput: "Mass A, Mass B, Mass C",
      valuesInput: "1, 3/2, 2",
      chartTitle: "Pie Chart of Masses A, B and C in Ratio 1 : 3/2 : 2",
    ),
    PieChartPreset(
      chipLabel:
      "Rev Ex 19 #7 Table 19.22 (Page 236): Cement Sold in 4 Countries (%)",
      mode: 1,
      categoriesInput: "Togo, Senegal, Zambia, Mozambique",
      valuesInput: "7, 13, 17, 63",
      chartTitle: "Cement Sold in Four Countries (%)",
    ),
    PieChartPreset(
      chipLabel:
      "Rev Ex 19 #8 Fig. 19.20 (Page 236): Election Parties X, Y and Z",
      mode: 2,
      categoriesInput: "Party X, Party Y, Party Z",
      valuesInput: "54, 135, a",
      totalOrKnownInput: "Party X = 1260000",
      chartTitle: "Votes Cast for Parties X, Y and Z",
      unit: "voters",
    ),
  ];

  // ===========================================================================
  // PARSING & FORMATTING HELPERS
  // ===========================================================================
  static String _cleanNum(double v, {int digits = 2}) {
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    String s = v.toStringAsFixed(digits);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
    return s;
  }

  static String _sanitizeLaTeXText(String text) {
    return text
        .replaceAll('#', 'No. ')
        .replaceAll('%', r'\%')
        .replaceAll('&', r'\&')
        .replaceAll('_', ' ')
        .trim();
  }

  static _PieUnitFormat _formatUnit(String rawUnit) {
    final String u = rawUnit.trim();
    if (u.isEmpty) {
      return const _PieUnitFormat();
    }
    if (u == '₦' || u == r'$' || u == '£') {
      return _PieUnitFormat(
        prefixLaTeX: '\\text{$u}',
        suffixLaTeX: '',
        prefixPlain: u,
        suffixPlain: '',
      );
    }
    final String safe = _sanitizeLaTeXText(u);
    return _PieUnitFormat(
      prefixLaTeX: '',
      suffixLaTeX: '\\text{ $safe}',
      prefixPlain: '',
      suffixPlain: ' $u',
    );
  }

  static _PieParsedEntry _parseSingleEntry(String rawToken) {
    String s = rawToken
        .trim()
        .replaceAll('°', '')
        .replaceAll('degrees', '')
        .replaceAll('−', '-')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .trim();

    if (s.isEmpty) {
      throw const FormatException("Empty value detected in input list.");
    }

    bool isPct = false;
    if (s.endsWith('%')) {
      isPct = true;
      s = s.substring(0, s.length - 1).trim();
    }

    // Check for unknown angle expression like "x", "a", "90 + x", "x + 90"
    final RegExp unknownExprReg = RegExp(
        r'^(?:(\d+(?:\.\d+)?)\s*\+\s*([a-zA-Z])|([a-zA-Z])\s*\+\s*(\d+(?:\.\d+)?)|([a-zA-Z]))$');
    final Match? um = unknownExprReg.firstMatch(s);
    if (um != null) {
      String varName = 'x';
      _PieFrac offset = const _PieFrac(0, 1);
      if (um.group(1) != null && um.group(2) != null) {
        final _PieParsedEntry offEntry = _parseSingleEntry(um.group(1)!);
        offset = offEntry.frac;
        varName = um.group(2)!;
      } else if (um.group(3) != null && um.group(4) != null) {
        varName = um.group(3)!;
        final _PieParsedEntry offEntry = _parseSingleEntry(um.group(4)!);
        offset = offEntry.frac;
      } else if (um.group(5) != null) {
        varName = um.group(5)!;
      }
      final String disp =
      offset.num == 0 ? varName : "(${offset.toLaTeX()} + $varName)";
      return _PieParsedEntry(
        raw: rawToken.trim(),
        frac: const _PieFrac(0, 1),
        origNum: 0,
        origDen: 1,
        isUnknownVar: true,
        unknownVarName: varName,
        unknownConstantOffset: offset,
        displayLaTeX: disp,
        displayPlain:
        offset.num == 0 ? varName : "(${offset.toPlain()} + $varName)",
      );
    }

    // 1. Mixed fraction e.g. "30 5/9" or "16 2/3" or "28 8/9"
    final RegExp mixedReg = RegExp(r'^([+-]?\d+)\s+(\d+)\s*/\s*(\d+)$');
    final Match? mm = mixedReg.firstMatch(s);
    if (mm != null) {
      final int w = int.parse(mm.group(1)!);
      final int n = int.parse(mm.group(2)!);
      final int d = int.parse(mm.group(3)!);
      if (d == 0) throw const FormatException("Denominator cannot be zero.");
      final int sign = w < 0 ? -1 : 1;
      final int impNum = sign * (w.abs() * d + n);
      return _PieParsedEntry(
        raw: rawToken.trim(),
        frac: _PieFrac.from(impNum, d),
        origNum: impNum,
        origDen: d,
        isMixed: true,
        mixedWhole: w,
        mixedNum: n,
        mixedDen: d,
        isFractionInput: true,
        isPercentToken: isPct,
        displayLaTeX: '$w\\frac{$n}{$d}',
        displayPlain: '$w $n/$d',
      );
    }

    // 2. Simple fraction e.g. "3/2" or "275/9"
    final RegExp fracReg = RegExp(r'^([+-]?\d+)\s*/\s*(\d+)$');
    final Match? fm = fracReg.firstMatch(s);
    if (fm != null) {
      final int n = int.parse(fm.group(1)!);
      final int d = int.parse(fm.group(2)!);
      if (d == 0) throw const FormatException("Denominator cannot be zero.");
      return _PieParsedEntry(
        raw: rawToken.trim(),
        frac: _PieFrac.from(n, d),
        origNum: n,
        origDen: d,
        isFractionInput: true,
        isPercentToken: isPct,
        displayLaTeX: '\\frac{$n}{$d}',
        displayPlain: '$n/$d',
      );
    }

    final String cleanNoSpace = s.replaceAll(' ', '');

    // 3. Decimal e.g. "122.4" or "32.4"
    if (cleanNoSpace.contains('.')) {
      final double? dv = double.tryParse(cleanNoSpace);
      if (dv == null) {
        throw FormatException("Could not parse '$rawToken' as a valid number.");
      }
      final List<String> parts = cleanNoSpace.split('.');
      int d = 1;
      for (int i = 0; i < parts[1].length; i++) {
        d *= 10;
      }
      final int sign = cleanNoSpace.startsWith('-') ? -1 : 1;
      final String wRaw = parts[0].replaceAll('-', '').replaceAll('+', '');
      final int wAbs = wRaw.isEmpty ? 0 : int.parse(wRaw);
      final int decPart = int.parse(parts[1]);
      final int impNum = sign * (wAbs * d + decPart);
      return _PieParsedEntry(
        raw: rawToken.trim(),
        frac: _PieFrac.from(impNum, d),
        origNum: impNum,
        origDen: d,
        isDecimalInput: true,
        isPercentToken: isPct,
        displayLaTeX: cleanNoSpace,
        displayPlain: cleanNoSpace,
      );
    }

    // 4. Whole integer
    final int? iv = int.tryParse(cleanNoSpace);
    if (iv == null) {
      throw FormatException("Could not read '$rawToken' as a valid number.");
    }
    return _PieParsedEntry(
      raw: rawToken.trim(),
      frac: _PieFrac.from(iv, 1),
      origNum: iv,
      origDen: 1,
      isPercentToken: isPct,
      displayLaTeX: '$iv',
      displayPlain: '$iv',
    );
  }

  // ===========================================================================
  // MASTER ROUTER
  // ===========================================================================
  static PieChartResult solvePieChart({
    required int mode,
    required String rawCategoriesInput,
    required String rawValuesInput,
    String rawTotalOrKnownInput = '',
    String chartTitle = '',
    String unit = '',
  }) {
    try {
      final List<String> categories = rawCategoriesInput
          .split(RegExp(r'[,;\n]+'))
          .map((String s) => s.trim())
          .where((String s) => s.isNotEmpty)
          .toList();

      final List<String> valueTokens = rawValuesInput
          .replaceAll(':', ',')
          .split(RegExp(r'[,;\n]+'))
          .map((String s) => s.trim())
          .where((String s) => s.isNotEmpty)
          .toList();

      if (categories.length < 2) {
        throw const FormatException(
          "Please enter at least 2 category names separated by commas (e.g. Producers, Mimers, Choreographers, Costumiers).",
        );
      }
      if (categories.length != valueTokens.length) {
        throw FormatException(
          "You entered ${categories.length} categories but ${valueTokens.length} values. Please ensure every category has a matching value.",
        );
      }

      final List<_PieParsedEntry> entries =
      valueTokens.map(_parseSingleEntry).toList();

      if (mode == 0) {
        return _solveFromQuantities(categories, entries, chartTitle, unit);
      } else if (mode == 1) {
        return _solveFromPercentages(
          categories,
          entries,
          rawTotalOrKnownInput,
          chartTitle,
          unit,
        );
      } else if (mode == 2) {
        return _solveFromAnglesAndMissing(
          categories,
          entries,
          rawTotalOrKnownInput,
          chartTitle,
          unit,
        );
      } else {
        return _solveFromRatios(
          categories,
          entries,
          rawTotalOrKnownInput,
          chartTitle,
        );
      }
    } catch (e) {
      return PieChartResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please check your category names and numbers and try again.",
      );
    }
  }

  // ===========================================================================
  // MODE 0: CONSTRUCT PIE CHART FROM FREQUENCIES / QUANTITIES
  // ===========================================================================
  static PieChartResult _solveFromQuantities(
      List<String> categories,
      List<_PieParsedEntry> entries,
      String chartTitle,
      String unit,
      ) {
    final _PieUnitFormat u = _formatUnit(unit);
    final int n = categories.length;

    final List<String> sumStepLaTeX = [
      "\\text{Total} = ${entries.map((_PieParsedEntry e) => e.displayLaTeX).join(' + ')}",
    ];
    final List<String> sumBulletsPlain = [];
    _PieFrac runningTotal = entries[0].frac;

    for (int i = 1; i < n; i++) {
      final String prevStr = _cleanNum(runningTotal.toDouble);
      final String curStr = entries[i].displayPlain;
      runningTotal = runningTotal + entries[i].frac;
      final String nextStr = _cleanNum(runningTotal.toDouble);
      sumStepLaTeX.add(
        "\\bullet \\text{ Add item ${i + 1}: } $prevStr + ${entries[i].displayLaTeX} = \\mathbf{$nextStr}",
      );
      sumBulletsPlain.add("• Step $i: $prevStr + $curStr = $nextStr");
    }

    if (runningTotal.toDouble <= 0) {
      throw const FormatException(
          "The sum of quantities must be greater than zero.");
    }

    final String totalStr = _cleanNum(runningTotal.toDouble);
    sumStepLaTeX.add(
      "\\therefore \\; \\text{Total quantity} = \\mathbf{${u.prefixLaTeX}$totalStr${u.suffixLaTeX}}",
    );

    final List<PieChartSectorData> sectors = [];
    final List<String> angleWorkingsLaTeX = [];
    final List<String> angleBulletsPlain = [];
    final List<String> tableRowsLaTeX = [];
    final Map<String, String> finalAnswers = {
      "Total Quantity": "\\mathbf{${u.prefixLaTeX}$totalStr${u.suffixLaTeX}}",
    };

    _PieFrac sumAnglesFrac = const _PieFrac(0, 1);

    for (int i = 0; i < n; i++) {
      final String cat = categories[i];
      final String safeCat = _sanitizeLaTeXText(cat);
      final _PieParsedEntry entry = entries[i];

      final _PieFrac fractionOfWhole = entry.frac / runningTotal;
      final _PieFrac exactAngle = fractionOfWhole * const _PieFrac(360, 1);
      final _PieFrac exactPct = fractionOfWhole * const _PieFrac(100, 1);
      sumAnglesFrac = sumAnglesFrac + exactAngle;

      final double angleDeg = exactAngle.toDouble;
      final String angleStr = _cleanNum(angleDeg, digits: 1);
      final String pctStr = _cleanNum(exactPct.toDouble, digits: 1);

      final String unsimplifiedFracLaTeX =
          "\\frac{${entry.displayLaTeX}}{$totalStr}";
      final String simplifiedFracLaTeX = fractionOfWhole.toLaTeX();
      final bool canSimplify = unsimplifiedFracLaTeX != simplifiedFracLaTeX;

      angleWorkingsLaTeX.add(
        "\\bullet \\; \\mathbf{\\text{$safeCat}}: \\quad $unsimplifiedFracLaTeX \\text{ of } 360^\\circ = $unsimplifiedFracLaTeX \\times 360^\\circ"
            "${canSimplify ? ' = $simplifiedFracLaTeX \\times 360^\\circ' : ''}"
            " = \\frac{${entry.origNum} \\times 360}{$totalStr} = \\mathbf{$angleStr^\\circ} \\quad (\\text{Nearest degree: } \\mathbf{${angleDeg.round()}^\\circ})",
      );
      angleBulletsPlain.add(
        "• $cat: (${entry.displayPlain} / $totalStr) × 360° = $angleStr° (Nearest degree: ${angleDeg.round()}°)",
      );

      tableRowsLaTeX.add(
        "\\text{$safeCat} & ${u.prefixLaTeX}${entry.displayLaTeX}${u.suffixLaTeX} & $simplifiedFracLaTeX & $unsimplifiedFracLaTeX \\times 360^\\circ = \\mathbf{$angleStr^\\circ} \\\\ \\hline ",
      );

      finalAnswers["$cat Angle"] =
      "$unsimplifiedFracLaTeX \\times 360^\\circ = \\mathbf{$angleStr^\\circ}";

      sectors.add(PieChartSectorData(
        label: cat,
        angleDegrees: angleDeg,
        percentage: exactPct.toDouble,
        quantityValue: entry.frac.toDouble,
        fractionOfCircleLaTeX: simplifiedFracLaTeX,
        angleLaTeX: "$angleStr^\\circ",
        percentageLaTeX: "$pctStr\\%",
        quantityLaTeX: "${u.prefixLaTeX}${entry.displayLaTeX}${u.suffixLaTeX}",
        anglePlain: "$angleStr°",
        percentagePlain: "$pctStr%",
        quantityPlain: "${u.prefixPlain}${entry.displayPlain}${u.suffixPlain}",
      ));
    }

    final String angleSumChain = sectors
        .map((PieChartSectorData s) =>
    "${_cleanNum(s.angleDegrees, digits: 1)}^\\circ")
        .join(' + ');
    final String angleCheckLaTeX =
        "\\text{Check sum of angles: } $angleSumChain = \\mathbf{${_cleanNum(sumAnglesFrac.toDouble, digits: 1)}^\\circ}";

    final String table1912LaTeX = "\\begin{array}{|c|c|c|c|} \\hline "
        "\\mathbf{\\text{Category / Item}} & \\mathbf{\\text{Quantity}} & \\mathbf{\\text{Fraction}} & \\mathbf{\\text{Sectorial Angle}} \\\\ \\hline "
        "${tableRowsLaTeX.join()}"
        "\\mathbf{\\text{Total}} & \\mathbf{${u.prefixLaTeX}$totalStr${u.suffixLaTeX}} & \\mathbf{1} & \\mathbf{360^\\circ} \\\\ \\hline \\end{array}";

    int maxIdx = 0;
    int minIdx = 0;
    for (int i = 1; i < n; i++) {
      if (sectors[i].angleDegrees > sectors[maxIdx].angleDegrees) maxIdx = i;
      if (sectors[i].angleDegrees < sectors[minIdx].angleDegrees) minIdx = i;
    }

    final List<String> workings = [
      "\\text{\\textbf{Completed Sectorial Angle Table (Table 19.12 / 19.14 Standard, Pages 228–231):}}",
      table1912LaTeX,
      "",
      "\\text{\\textbf{Step 1: Add All the Given Quantities Together to Find the Total}}",
      ...sumStepLaTeX,
      "",
      "\\text{\\textbf{Step 2: Calculate the Sectorial Angle at the Centre for Each Sector}}",
      "\\text{Formula: } \\text{Sectorial Angle} = \\frac{\\text{Quantity}}{\\text{Total}} \\times 360^\\circ",
      ...angleWorkingsLaTeX,
      "",
      "\\text{\\textbf{Step 3: Check That the Sum of All Sectorial Angles Equals }} 360^\\circ",
      angleCheckLaTeX,
    ];

    final List<PieChartStep> steps = [
      PieChartStep(
        title:
        "Step 1: Find the Total of All Given Quantities (Example 5 Step I, Page 228)",
        description:
        "• Add all $n given quantities together step-by-step to find the whole population/total:\n"
            "${sumBulletsPlain.join('\n')}",
        mathLinesLaTeX: sumStepLaTeX,
      ),
      PieChartStep(
        title:
        "Step 2: Calculate the Angle at the Centre for Each Sector (Fraction of 360°)",
        description:
        "• The whole pie chart has an angle of 360° at the centre. Express each category as a fraction of $totalStr and multiply by 360°:\n"
            "${angleBulletsPlain.join('\n')}",
        mathLinesLaTeX: [
          r"\text{Sectorial Angle} = \frac{\text{Quantity}}{\text{Total Quantity}} \times 360^\circ",
          ...angleWorkingsLaTeX,
        ],
      ),
      PieChartStep(
        title:
        "Step 3: Verify Total Angle = 360° & Construct the Pie Chart (Example 5 Step II, Page 228–229)",
        description:
        "• 1. Add all calculated angles to confirm they total 360°.\n"
            "• 2. Draw a circle using a pair of compasses and draw a starting radius line.\n"
            "• 3. Use a protractor to measure each sectorial angle around the centre and label every sector clearly.",
        mathLinesLaTeX: [
          angleCheckLaTeX,
          table1912LaTeX,
        ],
      ),
    ];

    return PieChartResult(
      mode: 0,
      finalAnswersLaTeX: finalAnswers,
      workingsLaTeX: workings,
      steps: steps,
      canvasData: PieChartCanvasData(
        chartTitle: chartTitle.trim().isEmpty
            ? "Pie Chart Showing Sectorial Angles"
            : chartTitle.trim(),
        sectors: sectors,
        headerLaTeX:
        "\\text{Chapter 19 Pie Chart Construction (Page 228): } \\theta = \\frac{\\text{Quantity}}{$totalStr} \\times 360^\\circ",
        subHeaderLaTeX: angleCheckLaTeX,
        card1Title: "Total Quantity",
        card1LaTeX: "\\mathbf{${u.prefixLaTeX}$totalStr${u.suffixLaTeX}}",
        card2Title: "Largest Sector",
        card2LaTeX:
        "\\text{${_sanitizeLaTeXText(sectors[maxIdx].label)}: } \\mathbf{${sectors[maxIdx].angleLaTeX}}",
        card3Title: "Smallest Sector",
        card3LaTeX:
        "\\text{${_sanitizeLaTeXText(sectors[minIdx].label)}: } \\mathbf{${sectors[minIdx].angleLaTeX}}",
        sectorTableLaTeX: table1912LaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\sum \\theta = $angleSumChain = \\mathbf{360^\\circ}",
      ),
    );
  }

  // ===========================================================================
  // MODE 1: CONSTRUCT PIE CHART FROM PERCENTAGES (INCLUDING MIXED FRACTIONS)
  // ===========================================================================
  static PieChartResult _solveFromPercentages(
      List<String> categories,
      List<_PieParsedEntry> entries,
      String rawTotalPopulation,
      String chartTitle,
      String unit,
      ) {
    final _PieUnitFormat u = _formatUnit(unit);
    final int n = categories.length;

    _PieFrac? totalPopFrac;
    if (rawTotalPopulation.trim().isNotEmpty) {
      final String numOnly =
      rawTotalPopulation.replaceAll(RegExp(r'[^0-9./]'), '').trim();
      if (numOnly.isNotEmpty) {
        totalPopFrac = _parseSingleEntry(numOnly).frac;
      }
    }

    _PieFrac sumPctFrac = const _PieFrac(0, 1);
    for (final _PieParsedEntry e in entries) {
      sumPctFrac = sumPctFrac + e.frac;
    }
    if ((sumPctFrac.toDouble - 100.0).abs() > 0.5) {
      throw FormatException(
        "The given percentages sum to ${_cleanNum(sumPctFrac.toDouble)}%, but the percentages of a complete pie chart must add up to 100%.",
      );
    }

    final List<PieChartSectorData> sectors = [];
    final List<String> conversionLinesLaTeX = [];
    final List<String> popLinesLaTeX = [];
    final List<String> popBulletsPlain = [];
    final List<String> angleLinesLaTeX = [];
    final List<String> angleBulletsPlain = [];
    final List<String> tableRowsLaTeX = [];
    final Map<String, String> finalAnswers = {};

    for (int i = 0; i < n; i++) {
      final String cat = categories[i];
      final String safeCat = _sanitizeLaTeXText(cat);
      final _PieParsedEntry entry = entries[i];

      final _PieFrac unsimplifiedOver100 =
      _PieFrac(entry.origNum, entry.origDen * 100);
      final _PieFrac exactFraction = entry.frac / const _PieFrac(100, 1);

      if (entry.isMixed) {
        final int w = entry.mixedWhole!.abs();
        final int mn = entry.mixedNum!;
        final int md = entry.mixedDen!;
        conversionLinesLaTeX.add(
          "\\bullet \\; \\mathbf{\\text{$safeCat}} \\; (${entry.displayLaTeX}\\%): \\quad ${entry.displayLaTeX}\\% = \\frac{($w \\times $md) + $mn}{$md}\\% = \\frac{${entry.origNum}}{$md} \\times \\frac{1}{100} = \\frac{${entry.origNum}}{${md * 100}} = \\mathbf{${exactFraction.toLaTeX()}}",
        );
      } else {
        conversionLinesLaTeX.add(
          "\\bullet \\; \\mathbf{\\text{$safeCat}} \\; (${entry.displayLaTeX}\\%): \\quad ${entry.displayLaTeX}\\% = \\frac{${entry.displayLaTeX}}{100} = \\mathbf{${exactFraction.toLaTeX()}}",
        );
      }

      String qtyLaTeX = '-';
      String qtyPlain = '-';
      double? qtyDouble;
      if (totalPopFrac != null) {
        final _PieFrac popFrac = exactFraction * totalPopFrac;
        qtyDouble = popFrac.toDouble;
        final String qtyClean = _cleanNum(qtyDouble);
        final String totalPopClean = _cleanNum(totalPopFrac.toDouble);
        qtyLaTeX = "${u.prefixLaTeX}$qtyClean${u.suffixLaTeX}";
        qtyPlain = "${u.prefixPlain}$qtyClean${u.suffixPlain}";

        popLinesLaTeX.add(
          "\\bullet \\; \\mathbf{\\text{$safeCat}}: \\quad \\frac{${entry.origNum}}{${entry.origDen * 100}} \\times $totalPopClean = ${exactFraction.toLaTeX()} \\times $totalPopClean = \\mathbf{$qtyLaTeX}",
        );
        popBulletsPlain.add(
          "• $cat population: (${entry.origNum}/${entry.origDen * 100}) × $totalPopClean = $qtyPlain",
        );
        finalAnswers["$cat Count"] = "\\mathbf{$qtyLaTeX}";
      }

      final _PieFrac angleFrac = exactFraction * const _PieFrac(360, 1);
      final double angleDeg = angleFrac.toDouble;
      final String angleClean = _cleanNum(angleDeg, digits: 1);

      if (totalPopFrac != null && qtyDouble != null) {
        final String qtyClean = _cleanNum(qtyDouble);
        final String totalPopClean = _cleanNum(totalPopFrac.toDouble);
        angleLinesLaTeX.add(
          "\\bullet \\; \\mathbf{\\text{$safeCat}}: \\quad \\frac{$qtyClean}{$totalPopClean} \\times 360^\\circ = ${exactFraction.toLaTeX()} \\times 360^\\circ = \\mathbf{$angleClean^\\circ}",
        );
      } else {
        angleLinesLaTeX.add(
          "\\bullet \\; \\mathbf{\\text{$safeCat}}: \\quad \\frac{${entry.displayLaTeX}}{100} \\times 360^\\circ = ${exactFraction.toLaTeX()} \\times 360^\\circ = \\mathbf{$angleClean^\\circ}",
        );
      }
      angleBulletsPlain.add(
        "• $cat sectorial angle: (${entry.displayPlain}% / 100%) × 360° = $angleClean°",
      );

      finalAnswers["$cat Angle"] = "\\mathbf{$angleClean^\\circ}";

      tableRowsLaTeX.add(
        "\\text{$safeCat} & ${entry.displayLaTeX}\\% & ${unsimplifiedOver100.den != 100 ? '\\frac{${entry.origNum}}{${entry.origDen * 100}} = ' : ''}${exactFraction.toLaTeX()} & $qtyLaTeX & \\mathbf{$angleClean^\\circ} \\\\ \\hline ",
      );

      sectors.add(PieChartSectorData(
        label: cat,
        angleDegrees: angleDeg,
        percentage: entry.frac.toDouble,
        quantityValue: qtyDouble,
        fractionOfCircleLaTeX: exactFraction.toLaTeX(),
        angleLaTeX: "$angleClean^\\circ",
        percentageLaTeX: "${entry.displayLaTeX}\\%",
        quantityLaTeX: qtyLaTeX,
        anglePlain: "$angleClean°",
        percentagePlain: "${entry.displayPlain}%",
        quantityPlain: qtyPlain,
      ));
    }

    int maxIdx = 0;
    int minIdx = 0;
    for (int i = 1; i < n; i++) {
      if (sectors[i].angleDegrees > sectors[maxIdx].angleDegrees) maxIdx = i;
      if (sectors[i].angleDegrees < sectors[minIdx].angleDegrees) minIdx = i;
    }

    final _PieFrac ratioLastToFirst = entries.last.frac / entries.first.frac;
    final String ratioExplanationLaTeX =
        "\\text{Ratio of ${_sanitizeLaTeXText(categories.last)} to ${_sanitizeLaTeXText(categories.first)} (Example 6e)} = ${sectors.last.quantityPlain != '-' ? '${_cleanNum(sectors.last.quantityValue!)} : ${_cleanNum(sectors.first.quantityValue!)} = ' : ''}\\mathbf{${ratioLastToFirst.num.abs()} : ${ratioLastToFirst.den}}";

    final String table1911And12LaTeX =
        "\\begin{array}{|c|c|c|c|c|} \\hline "
        "\\mathbf{\\text{Category}} & \\mathbf{\\text{Percentage}} & \\mathbf{\\text{Fraction}} & \\mathbf{\\text{Population / Qty}} & \\mathbf{\\text{Sectorial Angle}} \\\\ \\hline "
        "${tableRowsLaTeX.join()}"
        "\\mathbf{\\text{Total}} & \\mathbf{100\\%} & \\mathbf{1} & \\mathbf{${totalPopFrac != null ? '${u.prefixLaTeX}${_cleanNum(totalPopFrac.toDouble)}${u.suffixLaTeX}' : '-'}} & \\mathbf{360^\\circ} \\\\ \\hline \\end{array}";

    final List<String> workings = [
      "\\text{\\textbf{Completed Tables 19.11 \\& 19.12 / 19.22 (Pages 229–230 \\& 236):}}",
      table1911And12LaTeX,
      "",
      "\\text{\\textbf{Step 1: Convert Each Percentage to a Fraction of the Whole Circle (Divide by 100)}}",
      ...conversionLinesLaTeX,
      if (totalPopFrac != null) ...[
        "",
        "\\text{\\textbf{Step 2 (Example 6a): Multiply Each Fraction by Total Population (${_cleanNum(totalPopFrac.toDouble)})}}",
        ...popLinesLaTeX,
      ],
      "",
      "\\text{\\textbf{Step ${totalPopFrac != null ? 3 : 2} (Example 6c): Multiply Each Fraction by }} 360^\\circ \\text{\\textbf{ to Find Sectorial Angles}}",
      ...angleLinesLaTeX,
      "",
      "\\text{\\textbf{Step ${totalPopFrac != null ? 4 : 3} (Example 6b, d, e): Most, Least \\& Ratio Comparison}}",
      "\\bullet \\; \\text{Highest (Most): } \\mathbf{\\text{${_sanitizeLaTeXText(sectors[maxIdx].label)}}} \\; (${sectors[maxIdx].percentageLaTeX}, \\; ${sectors[maxIdx].angleLaTeX})",
      "\\bullet \\; \\text{Lowest (Least): } \\mathbf{\\text{${_sanitizeLaTeXText(sectors[minIdx].label)}}} \\; (${sectors[minIdx].percentageLaTeX}, \\; ${sectors[minIdx].angleLaTeX})",
      "\\bullet \\; $ratioExplanationLaTeX",
    ];

    final List<PieChartStep> steps = [
      PieChartStep(
        title:
        "Step 1: Convert Each Percentage into an Exact Fraction (Example 6, Page 229)",
        description:
        "• Convert any mixed-number percentage into an improper fraction and divide by 100 (multiply denominator by 100) to get its exact fraction of the circle.",
        mathLinesLaTeX: conversionLinesLaTeX,
      ),
      if (totalPopFrac != null)
        PieChartStep(
          title:
          "Step 2: Find the Number / Population for Each Sector (Table 19.11, Page 229)",
          description:
          "• Multiply each sector's fraction by the total population (${_cleanNum(totalPopFrac.toDouble)}):\n"
              "${popBulletsPlain.join('\n')}",
          mathLinesLaTeX: popLinesLaTeX,
        ),
      PieChartStep(
        title:
        "Step ${totalPopFrac != null ? 3 : 2}: Calculate the Sectorial Angle for Each Section (Table 19.12, Page 230)",
        description:
        "• Multiply each sector's fraction of the circle by 360°:\n"
            "${angleBulletsPlain.join('\n')}",
        mathLinesLaTeX: [
          ...angleLinesLaTeX,
          table1911And12LaTeX,
        ],
      ),
      PieChartStep(
        title:
        "Step ${totalPopFrac != null ? 4 : 3}: Identify Highest, Lowest & Simplified Ratio (Example 6b, d, e)",
        description:
        "• Highest sector: ${sectors[maxIdx].label} (${sectors[maxIdx].percentagePlain}, ${sectors[maxIdx].anglePlain}).\n"
            "• Lowest sector: ${sectors[minIdx].label} (${sectors[minIdx].percentagePlain}, ${sectors[minIdx].anglePlain}).\n"
            "• Ratio of ${categories.last} to ${categories.first} in lowest terms is ${ratioLastToFirst.num.abs()} : ${ratioLastToFirst.den}.",
        mathLinesLaTeX: [
          "\\text{Most: } \\mathbf{\\text{${_sanitizeLaTeXText(sectors[maxIdx].label)}}} \\quad | \\quad \\text{Least: } \\mathbf{\\text{${_sanitizeLaTeXText(sectors[minIdx].label)}}}",
          ratioExplanationLaTeX,
        ],
      ),
    ];

    return PieChartResult(
      mode: 1,
      finalAnswersLaTeX: finalAnswers,
      workingsLaTeX: workings,
      steps: steps,
      canvasData: PieChartCanvasData(
        chartTitle: chartTitle.trim().isEmpty
            ? "Pie Chart from Percentages"
            : chartTitle.trim(),
        sectors: sectors,
        headerLaTeX:
        "\\text{Chapter 19 Pie Chart from Percentages (Example 6, Page 229): } \\theta = \\frac{\\text{Percentage}}{100} \\times 360^\\circ",
        subHeaderLaTeX: ratioExplanationLaTeX,
        card1Title: "Most (Highest)",
        card1LaTeX:
        "\\text{${_sanitizeLaTeXText(sectors[maxIdx].label)}: } \\mathbf{${sectors[maxIdx].angleLaTeX}}",
        card2Title: "Least (Lowest)",
        card2LaTeX:
        "\\text{${_sanitizeLaTeXText(sectors[minIdx].label)}: } \\mathbf{${sectors[minIdx].angleLaTeX}}",
        card3Title: totalPopFrac != null ? "Total Population" : "Total Angle",
        card3LaTeX: totalPopFrac != null
            ? "\\mathbf{${u.prefixLaTeX}${_cleanNum(totalPopFrac.toDouble)}${u.suffixLaTeX}}"
            : "\\mathbf{360^\\circ}",
        sectorTableLaTeX: table1911And12LaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Sum of Percentages} = 100\\% \\iff \\text{Sum of Sectorial Angles} = \\mathbf{360^\\circ}",
      ),
    );
  }

  // ===========================================================================
  // MODE 2: INTERPRET PIE CHART — MISSING ANGLE (x or a), MIXED % SECTORS &
  //         REVERSE QUANTITY SOLVER
  // ===========================================================================
  static PieChartResult _solveFromAnglesAndMissing(
      List<String> categories,
      List<_PieParsedEntry> entries,
      String rawTotalOrKnownInput,
      String chartTitle,
      String unit,
      ) {
    final _PieUnitFormat u = _formatUnit(unit);
    final int n = categories.length;

    final List<_PieFrac> resolvedAngles =
    List<_PieFrac>.filled(n, const _PieFrac(0, 1));
    final List<String> pctToAngleStepsLaTeX = [];
    final List<String> pctToAnglePlain = [];

    int unknownIdx = -1;
    _PieFrac knownAnglesSum = const _PieFrac(0, 1);

    for (int i = 0; i < n; i++) {
      final _PieParsedEntry e = entries[i];
      final String safeCat = _sanitizeLaTeXText(categories[i]);
      if (e.isUnknownVar) {
        if (unknownIdx != -1) {
          throw const FormatException(
            "Only one sector can contain an unknown angle variable (like x or a).",
          );
        }
        unknownIdx = i;
        knownAnglesSum = knownAnglesSum + e.unknownConstantOffset;
      } else if (e.isPercentToken) {
        final _PieFrac fracOfCircle = e.frac / const _PieFrac(100, 1);
        final _PieFrac degFrac = fracOfCircle * const _PieFrac(360, 1);
        resolvedAngles[i] = degFrac;
        knownAnglesSum = knownAnglesSum + degFrac;

        pctToAngleStepsLaTeX.add(
          "\\bullet \\; \\mathbf{\\text{$safeCat}} \\; (${e.displayLaTeX}\\%): \\quad \\text{Angle} = \\frac{${e.origNum}}{${e.origDen * 100}} \\times 360^\\circ = ${fracOfCircle.toLaTeX()} \\times 360^\\circ = \\mathbf{${_cleanNum(degFrac.toDouble)}^\\circ}",
        );
        pctToAnglePlain.add(
          "• ${categories[i]} (${e.displayPlain}%): (${e.displayPlain} / 100) × 360° = ${_cleanNum(degFrac.toDouble)}°",
        );
      } else {
        resolvedAngles[i] = e.frac;
        knownAnglesSum = knownAnglesSum + e.frac;
      }
    }

    final List<String> missingAngleWorkingsLaTeX = [];
    String solvedUnknownSummaryLaTeX = '';

    if (unknownIdx != -1) {
      final _PieParsedEntry unkEntry = entries[unknownIdx];
      final String vName = unkEntry.unknownVarName;
      final _PieFrac solvedVarVal = const _PieFrac(360, 1) - knownAnglesSum;

      if (solvedVarVal.toDouble <= 0) {
        throw const FormatException(
          "The known angles already add up to 360° or more, leaving no positive angle for the unknown.",
        );
      }

      final _PieFrac fullSectorAngle =
          unkEntry.unknownConstantOffset + solvedVarVal;
      resolvedAngles[unknownIdx] = fullSectorAngle;

      final String exprChain = List.generate(n, (int i) {
        if (i == unknownIdx) return "${unkEntry.displayLaTeX}^\\circ";
        return "${_cleanNum(resolvedAngles[i].toDouble)}^\\circ";
      }).join(' + ');

      final String knownSumStr = _cleanNum(knownAnglesSum.toDouble);
      final String varValStr = _cleanNum(solvedVarVal.toDouble);
      final String sectorDegStr = _cleanNum(fullSectorAngle.toDouble);

      missingAngleWorkingsLaTeX.addAll([
        "\\text{Sum of angles at the centre of a circle} = 360^\\circ",
        "$exprChain = 360^\\circ",
        "$knownSumStr^\\circ + $vName = 360^\\circ",
        "$vName = 360^\\circ - $knownSumStr^\\circ = \\mathbf{$varValStr^\\circ}",
        if (unkEntry.unknownConstantOffset.num != 0)
          "\\therefore \\; \\text{Sector angle for ${_sanitizeLaTeXText(categories[unknownIdx])}} = (${unkEntry.unknownConstantOffset.toLaTeX()} + $varValStr)^\\circ = \\mathbf{$sectorDegStr^\\circ}",
      ]);

      solvedUnknownSummaryLaTeX = "$vName = \\mathbf{$varValStr^\\circ}";
    } else {
      if ((knownAnglesSum.toDouble - 360.0).abs() > 1.0) {
        throw FormatException(
          "The sectorial angles add up to ${_cleanNum(knownAnglesSum.toDouble)}° instead of 360°. Tip: If a sector has an unknown angle, enter 'x' or 'a' for that sector.",
        );
      }
    }

    _PieFrac? totalPopFrac;
    final List<String> reverseTotalWorkingsLaTeX = [];

    final String rawSpec = rawTotalOrKnownInput.trim();
    if (rawSpec.isNotEmpty) {
      if (rawSpec.contains('=')) {
        final List<String> parts = rawSpec.split('=');
        final String targetCat = parts[0].trim().toLowerCase();
        final String targetValStr =
        parts[1].replaceAll(RegExp(r'[^0-9./]'), '').trim();
        final _PieFrac knownSectorQty = _parseSingleEntry(targetValStr).frac;

        int matchIdx = categories.indexWhere(
              (String c) =>
          c.toLowerCase() == targetCat ||
              c.toLowerCase().contains(targetCat),
        );
        if (matchIdx == -1) matchIdx = 0;

        final _PieFrac sectorAngle = resolvedAngles[matchIdx];
        final _PieFrac sectorFrac = sectorAngle / const _PieFrac(360, 1);
        totalPopFrac = knownSectorQty / sectorFrac;

        final String safeMatchCat = _sanitizeLaTeXText(categories[matchIdx]);
        final String knownQtyStr = _cleanNum(knownSectorQty.toDouble);
        final String secDegStr = _cleanNum(sectorAngle.toDouble);
        final String deducedTotalStr = _cleanNum(totalPopFrac.toDouble);

        reverseTotalWorkingsLaTeX.addAll([
          "\\text{Given: Sector for } \\mathbf{\\text{$safeMatchCat}} \\; ($secDegStr^\\circ) \\text{ represents } \\mathbf{${u.prefixLaTeX}$knownQtyStr${u.suffixLaTeX}}",
          "\\frac{$secDegStr^\\circ}{360^\\circ} \\times \\text{Total} = $knownQtyStr \\implies ${sectorFrac.toLaTeX()} \\times \\text{Total} = $knownQtyStr",
          "\\text{Total} = $knownQtyStr \\times \\frac{360}{$secDegStr} = \\mathbf{${u.prefixLaTeX}$deducedTotalStr${u.suffixLaTeX}}",
        ]);
      } else {
        final String cleanNumStr =
        rawSpec.replaceAll(RegExp(r'[^0-9./]'), '').trim();
        if (cleanNumStr.isNotEmpty) {
          final double? v = double.tryParse(cleanNumStr);
          if (v != null && v != 360.0) {
            totalPopFrac = _parseSingleEntry(cleanNumStr).frac;
          }
        }
      }
    }

    final List<PieChartSectorData> sectors = [];
    final List<String> sectorBreakdownLaTeX = [];
    final List<String> sectorBreakdownPlain = [];
    final List<String> tableRowsLaTeX = [];
    final Map<String, String> finalAnswers = {};

    if (solvedUnknownSummaryLaTeX.isNotEmpty) {
      finalAnswers["Unknown Angle (${entries[unknownIdx].unknownVarName})"] =
          solvedUnknownSummaryLaTeX;
    }
    if (totalPopFrac != null) {
      finalAnswers["Total Population / Amount"] =
      "\\mathbf{${u.prefixLaTeX}${_cleanNum(totalPopFrac.toDouble)}${u.suffixLaTeX}}";
    }

    for (int i = 0; i < n; i++) {
      final String cat = categories[i];
      final String safeCat = _sanitizeLaTeXText(cat);
      final _PieFrac angleFrac = resolvedAngles[i];
      final _PieFrac fracOfCircle = angleFrac / const _PieFrac(360, 1);
      final _PieFrac pctFrac = fracOfCircle * const _PieFrac(100, 1);

      final String degStr = _cleanNum(angleFrac.toDouble, digits: 1);
      final String pctStr =
      pctFrac.isFraction && (pctFrac.den == 3 || pctFrac.den == 9)
          ? "${pctFrac.toMixedLaTeX()}\\%"
          : "${_cleanNum(pctFrac.toDouble, digits: 1)}\\%";
      final String pctPlain =
      pctFrac.isFraction && (pctFrac.den == 3 || pctFrac.den == 9)
          ? "${pctFrac.toPlain()}%"
          : "${_cleanNum(pctFrac.toDouble, digits: 1)}%";

      String qtyLaTeX = '-';
      String qtyPlain = '-';
      double? qtyVal;

      if (totalPopFrac != null) {
        final _PieFrac qFrac = fracOfCircle * totalPopFrac;
        qtyVal = qFrac.toDouble;
        final String qClean = _cleanNum(qtyVal);
        final String totClean = _cleanNum(totalPopFrac.toDouble);
        qtyLaTeX = "${u.prefixLaTeX}$qClean${u.suffixLaTeX}";
        qtyPlain = "${u.prefixPlain}$qClean${u.suffixPlain}";

        sectorBreakdownLaTeX.add(
          "\\bullet \\; \\mathbf{\\text{$safeCat}} \\; ($degStr^\\circ): \\quad \\text{Fraction} = \\frac{$degStr}{360} = \\mathbf{${fracOfCircle.toLaTeX()}}, \\quad \\text{Quantity} = \\frac{$degStr}{360} \\times $totClean = \\mathbf{$qtyLaTeX}, \\quad \\text{\\%} = \\mathbf{$pctStr}",
        );
        sectorBreakdownPlain.add(
          "• $cat ($degStr°): Fraction in lowest terms = ${fracOfCircle.toPlain()}, Quantity = ($degStr/360) × $totClean = $qtyPlain, Percentage = $pctPlain",
        );
        finalAnswers["$cat ($degStr°)"] = "\\mathbf{$qtyLaTeX}";
      } else {
        sectorBreakdownLaTeX.add(
          "\\bullet \\; \\mathbf{\\text{$safeCat}} \\; ($degStr^\\circ): \\quad \\text{Fraction in lowest terms} = \\frac{$degStr}{360} = \\mathbf{${fracOfCircle.toLaTeX()}}, \\quad \\text{Percentage} = \\mathbf{$pctStr}",
        );
        sectorBreakdownPlain.add(
          "• $cat ($degStr°): Fraction = ${fracOfCircle.toPlain()}, Percentage = $pctPlain",
        );
        finalAnswers["$cat Fraction"] =
        "\\frac{$degStr}{360} = \\mathbf{${fracOfCircle.toLaTeX()}} \\; ($pctStr)";
      }

      tableRowsLaTeX.add(
        "\\text{$safeCat} & \\mathbf{$degStr^\\circ} & ${fracOfCircle.toLaTeX()} & $pctStr & $qtyLaTeX \\\\ \\hline ",
      );

      sectors.add(PieChartSectorData(
        label: cat,
        angleDegrees: angleFrac.toDouble,
        percentage: pctFrac.toDouble,
        quantityValue: qtyVal,
        fractionOfCircleLaTeX: fracOfCircle.toLaTeX(),
        angleLaTeX: "$degStr^\\circ",
        percentageLaTeX: pctStr,
        quantityLaTeX: qtyLaTeX,
        anglePlain: "$degStr°",
        percentagePlain: pctPlain,
        quantityPlain: qtyPlain,
      ));
    }

    int maxIdx = 0;
    int minIdx = 0;
    for (int i = 1; i < n; i++) {
      if (sectors[i].angleDegrees > sectors[maxIdx].angleDegrees) maxIdx = i;
      if (sectors[i].angleDegrees < sectors[minIdx].angleDegrees) minIdx = i;
    }

    final String table1917LaTeX =
        "\\begin{array}{|c|c|c|c|c|} \\hline "
        "\\mathbf{\\text{Sector}} & \\mathbf{\\text{Sectorial Angle}} & \\mathbf{\\text{Lowest Fraction}} & \\mathbf{\\text{Sectorial \\%}} & \\mathbf{\\text{Population / Amount}} \\\\ \\hline "
        "${tableRowsLaTeX.join()}"
        "\\mathbf{\\text{Total}} & \\mathbf{360^\\circ} & \\mathbf{1} & \\mathbf{100\\%} & \\mathbf{${totalPopFrac != null ? '${u.prefixLaTeX}${_cleanNum(totalPopFrac.toDouble)}${u.suffixLaTeX}' : '-'}} \\\\ \\hline \\end{array}";

    final List<String> workings = [
      "\\text{\\textbf{Completed Pie Chart Interpretation Table (Tables 19.17 \\& 19.18 Standard, Pages 232–233):}}",
      table1917LaTeX,
      if (pctToAngleStepsLaTeX.isNotEmpty) ...[
        "",
        "\\text{\\textbf{Step 1: Convert Given Sector Percentages into Sectorial Angles}}",
        ...pctToAngleStepsLaTeX,
      ],
      if (missingAngleWorkingsLaTeX.isNotEmpty) ...[
        "",
        "\\text{\\textbf{Step ${pctToAngleStepsLaTeX.isNotEmpty ? 2 : 1}: Solve for the Unknown Angle Using }} \\sum \\theta = 360^\\circ",
        ...missingAngleWorkingsLaTeX,
      ],
      if (reverseTotalWorkingsLaTeX.isNotEmpty) ...[
        "",
        "\\text{\\textbf{Step: Find Total Population from the Known Sector (Ex 19.2 No. 5a \\& Rev Ex 19 No. 8d)}}",
        ...reverseTotalWorkingsLaTeX,
      ],
      "",
      "\\text{\\textbf{Step: Calculate Lowest Fraction, Percentage \\& Quantity for Each Sector}}",
      ...sectorBreakdownLaTeX,
    ];

    final List<PieChartStep> steps = [
      if (pctToAngleStepsLaTeX.isNotEmpty)
        PieChartStep(
          title: "Step 1: Convert Sector Percentages to Angles (Ex 19.2 #5c & #7)",
          description:
          "• Multiply each percentage by 360° ÷ 100 to find its angle at the centre:\n"
              "${pctToAnglePlain.join('\n')}",
          mathLinesLaTeX: pctToAngleStepsLaTeX,
        ),
      if (missingAngleWorkingsLaTeX.isNotEmpty)
        PieChartStep(
          title:
          "Step: Find the Unknown Angle Using the Sum of Angles at a Point = 360°",
          description:
          "• All sectorial angles at the centre of a pie chart add up to 360°. Subtract the sum of the known angles from 360°.",
          mathLinesLaTeX: missingAngleWorkingsLaTeX,
        ),
      if (reverseTotalWorkingsLaTeX.isNotEmpty)
        PieChartStep(
          title:
          "Step: Calculate the Total Population from the Given Sector",
          description:
          "• Since one sector's angle and population are known, set up the proportion (Angle / 360°) × Total = Sector Quantity and solve for Total.",
          mathLinesLaTeX: reverseTotalWorkingsLaTeX,
        ),
      PieChartStep(
        title:
        "Step: Find Each Sector's Fraction (in Lowest Terms), Percentage & Quantity",
        description:
        "• For each sector, divide its angle by 360° to get its fraction in lowest terms, multiply by 100% for its percentage, and multiply by the Total for its quantity:\n"
            "${sectorBreakdownPlain.join('\n')}",
        mathLinesLaTeX: [
          ...sectorBreakdownLaTeX,
          table1917LaTeX,
        ],
      ),
    ];

    return PieChartResult(
      mode: 2,
      finalAnswersLaTeX: finalAnswers,
      workingsLaTeX: workings,
      steps: steps,
      canvasData: PieChartCanvasData(
        chartTitle: chartTitle.trim().isEmpty
            ? "Pie Chart Sector Interpretation"
            : chartTitle.trim(),
        sectors: sectors,
        headerLaTeX:
        "\\text{Chapter 19 Pie Chart Interpretation (Pages 232–236): } \\sum \\theta = 360^\\circ",
        subHeaderLaTeX: solvedUnknownSummaryLaTeX.isNotEmpty
            ? "\\text{Solved Unknown Angle: } $solvedUnknownSummaryLaTeX"
            : "\\text{Largest: } ${_sanitizeLaTeXText(sectors[maxIdx].label)} \\; (${sectors[maxIdx].angleLaTeX}) \\quad | \\quad \\text{Smallest: } ${_sanitizeLaTeXText(sectors[minIdx].label)} \\; (${sectors[minIdx].angleLaTeX})",
        card1Title: solvedUnknownSummaryLaTeX.isNotEmpty
            ? "Unknown Angle"
            : "Largest Sector",
        card1LaTeX: solvedUnknownSummaryLaTeX.isNotEmpty
            ? solvedUnknownSummaryLaTeX
            : "\\text{${_sanitizeLaTeXText(sectors[maxIdx].label)}: } \\mathbf{${sectors[maxIdx].angleLaTeX}}",
        card2Title: "Smallest Sector",
        card2LaTeX:
        "\\text{${_sanitizeLaTeXText(sectors[minIdx].label)}: } \\mathbf{${sectors[minIdx].angleLaTeX}}",
        card3Title: totalPopFrac != null ? "Total Quantity" : "Circle Total",
        card3LaTeX: totalPopFrac != null
            ? "\\mathbf{${u.prefixLaTeX}${_cleanNum(totalPopFrac.toDouble)}${u.suffixLaTeX}}"
            : "\\mathbf{360^\\circ}",
        sectorTableLaTeX: table1917LaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{All } $n \\text{ sectors verified: } \\sum \\theta = \\mathbf{360^\\circ}",
      ),
    );
  }

  // ===========================================================================
  // MODE 3: PIE CHART ANGLES FROM RATIOS (INCLUDING FRACTIONAL RATIOS)
  // ===========================================================================
  static PieChartResult _solveFromRatios(
      List<String> categories,
      List<_PieParsedEntry> entries,
      String rawTotalQuantity,
      String chartTitle,
      ) {
    final int n = categories.length;

    int denomLcm = 1;
    for (final _PieParsedEntry e in entries) {
      denomLcm = _PieFrac.lcm(denomLcm, e.frac.den);
    }

    final List<int> wholeRatioParts = [];
    for (final _PieParsedEntry e in entries) {
      final int scaled = (e.frac.num * (denomLcm ~/ e.frac.den));
      if (scaled <= 0) {
        throw const FormatException("All ratio parts must be positive.");
      }
      wholeRatioParts.add(scaled);
    }

    final int sumRatioParts =
    wholeRatioParts.fold(0, (int a, int b) => a + b);
    final String givenRatioLaTeX =
    entries.map((_PieParsedEntry e) => e.displayLaTeX).join(' : ');
    final String wholeRatioLaTeX = wholeRatioParts.join(' : ');

    final List<String> ratioPrepLinesLaTeX = [
      "\\text{Given Ratio} = $givenRatioLaTeX",
    ];
    if (denomLcm > 1) {
      ratioPrepLinesLaTeX.addAll([
        "\\text{Multiply every ratio term by the LCM of the denominators } ($denomLcm) \\text{ to clear fractions:}",
        "($givenRatioLaTeX) \\times $denomLcm = \\mathbf{$wholeRatioLaTeX}",
      ]);
    }
    ratioPrepLinesLaTeX.add(
      "\\text{Total ratio parts} = ${wholeRatioParts.join(' + ')} = \\mathbf{$sumRatioParts}",
    );

    final List<PieChartSectorData> sectors = [];
    final List<String> angleWorkingsLaTeX = [];
    final List<String> angleBulletsPlain = [];
    final List<String> tableRowsLaTeX = [];
    final Map<String, String> finalAnswers = {
      "Whole-Number Ratio": "\\mathbf{$wholeRatioLaTeX}",
      "Sum of Ratio Parts": "\\mathbf{$sumRatioParts}",
    };

    for (int i = 0; i < n; i++) {
      final String cat = categories[i];
      final String safeCat = _sanitizeLaTeXText(cat);
      final int part = wholeRatioParts[i];
      final _PieFrac fracOfCircle = _PieFrac.from(part, sumRatioParts);
      final _PieFrac angleFrac = fracOfCircle * const _PieFrac(360, 1);
      final _PieFrac pctFrac = fracOfCircle * const _PieFrac(100, 1);

      final String angleStr = _cleanNum(angleFrac.toDouble, digits: 1);
      final String pctStr = _cleanNum(pctFrac.toDouble, digits: 1);

      angleWorkingsLaTeX.add(
        "\\bullet \\; \\mathbf{\\text{$safeCat}}: \\quad \\frac{$part}{$sumRatioParts} \\times 360^\\circ = \\frac{${part * 360}}{$sumRatioParts}^\\circ = \\mathbf{$angleStr^\\circ}",
      );
      angleBulletsPlain.add(
        "• $cat: ($part / $sumRatioParts) × 360° = $angleStr°",
      );

      finalAnswers["$cat Angle"] =
      "\\frac{$part}{$sumRatioParts} \\times 360^\\circ = \\mathbf{$angleStr^\\circ}";

      tableRowsLaTeX.add(
        "\\text{$safeCat} & ${entries[i].displayLaTeX} & $part & \\frac{$part}{$sumRatioParts} & \\frac{$part}{$sumRatioParts} \\times 360^\\circ = \\mathbf{$angleStr^\\circ} \\\\ \\hline ",
      );

      sectors.add(PieChartSectorData(
        label: cat,
        angleDegrees: angleFrac.toDouble,
        percentage: pctFrac.toDouble,
        fractionOfCircleLaTeX: fracOfCircle.toLaTeX(),
        angleLaTeX: "$angleStr^\\circ",
        percentageLaTeX: "$pctStr\\%",
        quantityLaTeX: "$part \\text{ parts}",
        anglePlain: "$angleStr°",
        percentagePlain: "$pctStr%",
        quantityPlain: "$part parts",
      ));
    }

    final String tableLaTeX =
        "\\begin{array}{|c|c|c|c|c|} \\hline "
        "\\mathbf{\\text{Item}} & \\mathbf{\\text{Given Ratio}} & \\mathbf{\\text{Whole Parts}} & \\mathbf{\\text{Fraction}} & \\mathbf{\\text{Sectorial Angle}} \\\\ \\hline "
        "${tableRowsLaTeX.join()}"
        "\\mathbf{\\text{Total}} & - & \\mathbf{$sumRatioParts} & \\mathbf{1} & \\mathbf{360^\\circ} \\\\ \\hline \\end{array}";

    return PieChartResult(
      mode: 3,
      finalAnswersLaTeX: finalAnswers,
      workingsLaTeX: [
        "\\text{\\textbf{Pie Chart Sectorial Angles from Ratios (Revision Exercise 19 No. 6, Page 236):}}",
        tableLaTeX,
        "",
        "\\text{\\textbf{Step 1: Clear Fractions in the Ratio \\& Add the Ratio Parts}}",
        ...ratioPrepLinesLaTeX,
        "",
        "\\text{\\textbf{Step 2: Multiply Each Share of the Ratio by }} 360^\\circ",
        ...angleWorkingsLaTeX,
      ],
      steps: [
        PieChartStep(
          title:
          "Step 1: Convert Ratio to Whole Numbers & Add the Parts (Rev Ex 19 #6, Page 236)",
          description: denomLcm > 1
              ? "• Multiply every term in the ratio ($givenRatioLaTeX) by $denomLcm to clear the fraction, giving $wholeRatioLaTeX, then add the parts together to get $sumRatioParts."
              : "• Add all parts of the ratio ($wholeRatioLaTeX) together to get $sumRatioParts.",
          mathLinesLaTeX: ratioPrepLinesLaTeX,
        ),
        PieChartStep(
          title:
          "Step 2: Calculate the Sectorial Angle for Each Share of 360°",
          description:
          "• Divide each ratio part by the total parts ($sumRatioParts) and multiply by 360°:\n"
              "${angleBulletsPlain.join('\n')}",
          mathLinesLaTeX: [
            ...angleWorkingsLaTeX,
            tableLaTeX,
          ],
        ),
      ],
      canvasData: PieChartCanvasData(
        chartTitle: chartTitle.trim().isEmpty
            ? "Pie Chart from Ratio $wholeRatioLaTeX"
            : chartTitle.trim(),
        sectors: sectors,
        headerLaTeX:
        "\\text{Pie Chart from Ratio (Page 236): } $givenRatioLaTeX = $wholeRatioLaTeX \\; (\\text{Total parts} = $sumRatioParts)",
        subHeaderLaTeX:
        "\\text{Sectorial Angle} = \\frac{\\text{Ratio Part}}{$sumRatioParts} \\times 360^\\circ",
        card1Title: "Simplified Ratio",
        card1LaTeX: "\\mathbf{$wholeRatioLaTeX}",
        card2Title: "Total Ratio Parts",
        card2LaTeX: "\\mathbf{$sumRatioParts}",
        card3Title: "Total Circle Angle",
        card3LaTeX: "\\mathbf{360^\\circ}",
        sectorTableLaTeX: tableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Angles: } ${sectors.map((PieChartSectorData s) => '${_sanitizeLaTeXText(s.label)} = \\mathbf{${s.angleLaTeX}}').join(', \\; ')}",
      ),
    );
  }
}