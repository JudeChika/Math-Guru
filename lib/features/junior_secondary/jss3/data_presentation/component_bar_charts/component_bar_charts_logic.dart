import 'dart:math' as math;
import 'component_bar_charts_models.dart';

/// Exact Rational Number (Fraction & Mixed Number) Engine so every fraction is rendered via \frac{num}{den} in Math.tex!
class _CompFrac {
  final int num;
  final int den;

  const _CompFrac(this.num, [this.den = 1]);

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

  factory _CompFrac.from(int n, [int d = 1]) {
    if (d == 0) throw const FormatException("Denominator cannot be zero.");
    if (n == 0) return const _CompFrac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _CompFrac(sign * (an ~/ g), ad ~/ g);
  }

  double get toDouble => num / den;
  bool get isInteger => den == 1;
  bool get isFraction => den != 1;

  _CompFrac operator +(_CompFrac other) =>
      _CompFrac.from(num * other.den + other.num * den, den * other.den);
  _CompFrac operator -(_CompFrac other) =>
      _CompFrac.from(num * other.den - other.num * den, den * other.den);
  _CompFrac operator *(_CompFrac other) =>
      _CompFrac.from(num * other.num, den * other.den);
  _CompFrac operator /(_CompFrac other) {
    if (other.num == 0) throw const FormatException("Cannot divide by zero.");
    return _CompFrac.from(num * other.den, den * other.num);
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

class _CompParsedVal {
  final _CompFrac frac;
  final bool isFractionInput;
  final bool isDecimalInput;
  final String displayLaTeX;
  final String displayPlain;

  const _CompParsedVal({
    required this.frac,
    required this.isFractionInput,
    required this.isDecimalInput,
    required this.displayLaTeX,
    required this.displayPlain,
  });

  double get value => frac.toDouble;
}

class _CompScaleInfo {
  final double maxAxis;
  final double step;

  const _CompScaleInfo({
    required this.maxAxis,
    required this.step,
  });
}

class ComponentBarChartsLogic {
  // ===========================================================================
  // 11 TEXTBOOK PRESETS (Pages 222–227 & Pages 233–235)
  // ===========================================================================
  static const List<ComponentBarChartPreset> textbookPresets = [
    ComponentBarChartPreset(
      chipLabel: "Example 3 Method I (Page 222, Fig. 19.7): Side-by-Side TV Viewers",
      mode: 0,
      categoriesInput: "Mon, Tue, Wed, Thur, Fri, Sat, Sun",
      componentsRowsInput:
      "NTA: 500, 1500, 1000, 2000, 3000, 2500, 3000\nAIT: 1000, 500, 1000, 1500, 1500, 3000, 3000",
      chartTitle: "TV Viewers in Port Harcourt (Side-by-Side)",
      xAxisLabel: "Days",
      yAxisLabel: "Viewers",
      unit: "viewers",
    ),
    ComponentBarChartPreset(
      chipLabel: "Example 3 Method II (Page 223, Fig. 19.8): Stacked TV Viewers",
      mode: 1,
      categoriesInput: "Mon, Tue, Wed, Thur, Fri, Sat, Sun",
      componentsRowsInput:
      "NTA: 500, 1500, 1000, 2000, 3000, 2500, 3000\nAIT: 1000, 500, 1000, 1500, 1500, 3000, 3000",
      chartTitle: "TV Viewers in Port Harcourt (Stacked)",
      xAxisLabel: "Days",
      yAxisLabel: "Viewers",
      unit: "viewers",
    ),
    ComponentBarChartPreset(
      chipLabel: "Example 4 (Page 224): Interpret NTA & AIT Component Bar Graph",
      mode: 3,
      categoriesInput: "Mon, Tue, Wed, Thur, Fri, Sat, Sun",
      componentsRowsInput:
      "NTA: 500, 1500, 1000, 2000, 3000, 2500, 3000\nAIT: 1000, 500, 1000, 1500, 1500, 3000, 3000",
      chartTitle: "NTA vs AIT Viewers Analysis",
      xAxisLabel: "Days",
      yAxisLabel: "Viewers",
      unit: "people",
    ),
    ComponentBarChartPreset(
      chipLabel: "Ex 19.1 #3 Table 19.5 (Page 225): Child Immunisation % (2005–2011)",
      mode: 0,
      categoriesInput: "2005, 2006, 2007, 2008, 2009, 2010, 2011",
      componentsRowsInput:
      "PMT: 80, 84, 87, 90, 92, 91, 88\nWhooping cough: 75, 79, 84, 88, 94, 94, 94",
      chartTitle: "Percentage of Children Immunised by 2nd Birthday",
      xAxisLabel: "Year of 2nd birthday",
      yAxisLabel: "Percentage (%)",
      unit: "%",
    ),
    ComponentBarChartPreset(
      chipLabel: "Ex 19.1 #4 Table 19.6 (Page 225): Kadiri & Toba Typing Speed",
      mode: 3,
      categoriesInput: "Wk 2, Wk 4, Wk 6, Wk 8, Wk 10, Wk 12",
      componentsRowsInput:
      "Kadiri: 12, 14, 18, 24, 30, 42\nToba: 16, 16, 20, 24, 32, 48",
      chartTitle: "Typing Speed (Words Per Minute)",
      xAxisLabel: "Week",
      yAxisLabel: "Words per minute",
      unit: "wpm",
    ),
    ComponentBarChartPreset(
      chipLabel: "Ex 19.1 #5 Table 19.7 (Page 226, Fig. 19.10): Traffic Offenders",
      mode: 1,
      categoriesInput: "2005, 2006, 2007, 2008, 2009",
      componentsRowsInput:
      "Male: 2000, 1300, 5500, 2800, 1960\nFemale: 500, 100, 800, 1200, 1440",
      chartTitle: "Male & Female Traffic Offenders (2005–2009)",
      xAxisLabel: "Year",
      yAxisLabel: "Offenders",
      unit: "offenders",
    ),
    ComponentBarChartPreset(
      chipLabel: "Ex 19.1 #6 Table 19.8 (Page 227): Horizontal Air Emissions",
      mode: 2,
      categoriesInput: "2000, 2001, 2002, 2003, 2004",
      componentsRowsInput:
      "Carbon monoxide: 10000, 9000, 7500, 6700, 6000\nSulphur dioxide: 6900, 4900, 4100, 3400, 2700\nBlack smoke: 1000, 500, 600, 400, 400",
      chartTitle: "Air Emissions (Thousands of Tonnes)",
      xAxisLabel: "Thousands of tonnes",
      yAxisLabel: "Year",
      unit: "thousand tonnes",
    ),
    ComponentBarChartPreset(
      chipLabel: "Ex 19.1 #7 Table 19.9 (Page 227): 3 Nigerian Tourist Festivals",
      mode: 1,
      categoriesInput: "2006, 2007, 2008, 2009, 2010",
      componentsRowsInput:
      "Oshun Osogbo: 21, 25, 27, 28, 28\nCalabar carnival: 26, 23, 25, 26, 26\nAbuja carnival: 17, 9, 10, 11, 11",
      chartTitle: "Attendance at Tourist Festivals (Thousands)",
      xAxisLabel: "Year",
      yAxisLabel: "Attendance (thousands)",
      unit: "thousand",
    ),
    ComponentBarChartPreset(
      chipLabel: "Ex 19.1 #8 Table 19.10 (Page 227): 4 Students in JSS 3 Gold Exam",
      mode: 0,
      categoriesInput: "Dawodu, Osawaru, Nkechi, Afolabi",
      componentsRowsInput:
      "Mathematics: 77, 78, 81, 84\nEnglish Lang: 83, 74, 65, 81\nSocial Studies: 81, 92, 68, 76\nBasic Science: 69, 68, 49, 77",
      chartTitle: "Scores of 4 Students in JSS 3 Gold Examination",
      xAxisLabel: "Students",
      yAxisLabel: "Marks",
      unit: "marks",
    ),
    ComponentBarChartPreset(
      chipLabel: "Ex 19.2 #8 Table 19.19 (Page 233): Infectious Diseases (2000 & 2010)",
      mode: 0,
      categoriesInput: "Tuberculosis, Whooping cough, Meningitis, Malaria",
      componentsRowsInput:
      "Year 2000: 5000, 14000, 2500, 2500\nYear 2010: 6400, 1600, 2000, 8000",
      chartTitle: "Infectious Diseases in 2000 and 2010",
      xAxisLabel: "Disease",
      yAxisLabel: "Number of cases",
      unit: "cases",
    ),
    ComponentBarChartPreset(
      chipLabel: "Rev Ex 19 #3 Fig. 19.18 & Table 19.20 (Page 235): Sunshine Hours",
      mode: 1,
      categoriesInput: "Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep",
      componentsRowsInput:
      "Abuja: 1 1/2, 2 1/2, 3 1/2, 4, 5 1/2, 7, 5 1/2, 5 1/2, 5\nMinna: 2, 3, 4, 6, 7, 7 1/2, 7 1/2, 7, 6 1/2",
      chartTitle: "Daily Hours of Sunshine in Abuja and Minna",
      xAxisLabel: "Month of the year",
      yAxisLabel: "Daily hours of sunshine",
      unit: "h",
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

  static _CompParsedVal _parseSingleValue(String rawToken) {
    final String s = rawToken
        .trim()
        .replaceAll('−', '-')
        .replaceAll(
      RegExp(r'\b(h|hrs|hours|wpm|marks|viewers|people)\b',
          caseSensitive: false),
      '',
    )
        .replaceAll('%', '')
        .trim();

    if (s.isEmpty) {
      throw const FormatException("Empty value found in component row.");
    }

    // 1. Mixed fraction e.g. "1 1/2" or "7 1/2"
    final RegExp mixedReg = RegExp(r'^([+-]?\d+)\s+(\d+)\s*/\s*(\d+)$');
    final Match? mm = mixedReg.firstMatch(s);
    if (mm != null) {
      final int w = int.parse(mm.group(1)!);
      final int n = int.parse(mm.group(2)!);
      final int d = int.parse(mm.group(3)!);
      if (d == 0) throw const FormatException("Denominator cannot be zero.");
      final int sign = w < 0 ? -1 : 1;
      final int impNum = sign * (w.abs() * d + n);
      return _CompParsedVal(
        frac: _CompFrac.from(impNum, d),
        isFractionInput: true,
        isDecimalInput: false,
        displayLaTeX: '$w\\frac{$n}{$d}',
        displayPlain: '$w $n/$d',
      );
    }

    // 2. Simple fraction e.g. "3/2"
    final RegExp fracReg = RegExp(r'^([+-]?\d+)\s*/\s*(\d+)$');
    final Match? fm = fracReg.firstMatch(s);
    if (fm != null) {
      final int n = int.parse(fm.group(1)!);
      final int d = int.parse(fm.group(2)!);
      if (d == 0) throw const FormatException("Denominator cannot be zero.");
      return _CompParsedVal(
        frac: _CompFrac.from(n, d),
        isFractionInput: true,
        isDecimalInput: false,
        displayLaTeX: '\\frac{$n}{$d}',
        displayPlain: '$n/$d',
      );
    }

    final String noSpace = s.replaceAll(' ', '');

    // 3. Decimal
    if (noSpace.contains('.')) {
      final double? dv = double.tryParse(noSpace);
      if (dv == null) {
        throw FormatException("Could not parse '$rawToken' as a number.");
      }
      final List<String> parts = noSpace.split('.');
      int d = 1;
      for (int i = 0; i < parts[1].length; i++) {
        d *= 10;
      }
      final int sign = noSpace.startsWith('-') ? -1 : 1;
      final String wRaw = parts[0].replaceAll('-', '').replaceAll('+', '');
      final int wAbs = wRaw.isEmpty ? 0 : int.parse(wRaw);
      final int decPart = int.parse(parts[1]);
      return _CompParsedVal(
        frac: _CompFrac.from(sign * (wAbs * d + decPart), d),
        isFractionInput: false,
        isDecimalInput: true,
        displayLaTeX: noSpace,
        displayPlain: noSpace,
      );
    }

    // 4. Integer
    final int? iv = int.tryParse(noSpace);
    if (iv == null) {
      throw FormatException("Could not parse '$rawToken' as a valid number.");
    }
    return _CompParsedVal(
      frac: _CompFrac.from(iv, 1),
      isFractionInput: false,
      isDecimalInput: false,
      displayLaTeX: '$iv',
      displayPlain: '$iv',
    );
  }

  static _CompScaleInfo _computeNiceScale(double maxDataVal) {
    if (maxDataVal <= 0) {
      return const _CompScaleInfo(maxAxis: 10.0, step: 2.0);
    }
    final double rawStep = maxDataVal / 6.0;
    final double mag =
    math.pow(10, (math.log(rawStep) / math.ln10).floor()).toDouble();
    final double residual = rawStep / mag;
    double niceStep;
    if (residual <= 1.0) {
      niceStep = 1.0 * mag;
    } else if (residual <= 2.0) {
      niceStep = 2.0 * mag;
    } else if (residual <= 2.5) {
      niceStep = 2.5 * mag;
    } else if (residual <= 5.0) {
      niceStep = 5.0 * mag;
    } else {
      niceStep = 10.0 * mag;
    }
    final double maxAxis = (maxDataVal / niceStep).ceil() * niceStep;
    return _CompScaleInfo(
      maxAxis: maxAxis < maxDataVal ? maxAxis + niceStep : maxAxis,
      step: niceStep,
    );
  }

  // ===========================================================================
  // MASTER SOLVER: COMPONENT (COMPOUND) BAR CHARTS (Pages 222–227 & 234–235)
  // ===========================================================================
  static ComponentBarChartResult solveComponentBarChart({
    required int mode,
    required String rawCategoriesInput,
    required String rawComponentsRowsInput,
    String chartTitle = '',
    String xAxisLabel = '',
    String yAxisLabel = '',
    String unit = '',
  }) {
    try {
      final List<String> categories = rawCategoriesInput
          .split(RegExp(r'[,;\n]+'))
          .map((String s) => s.trim())
          .where((String s) => s.isNotEmpty)
          .toList();

      if (categories.length < 2) {
        throw const FormatException(
          "Please enter at least 2 category labels separated by commas (e.g. Mon, Tue, Wed, Thur).",
        );
      }

      final List<String> rowLines = rawComponentsRowsInput
          .split('\n')
          .map((String l) => l.trim())
          .where((String l) => l.isNotEmpty)
          .toList();

      if (rowLines.length < 2) {
        throw const FormatException(
          "A component (compound) bar chart requires at least 2 component series (one per line, e.g.:\nNTA: 500, 1500, 1000\nAIT: 1000, 500, 1000).",
        );
      }

      final List<String> componentNames = [];
      final List<List<_CompParsedVal>> matrix = [];

      for (int r = 0; r < rowLines.length; r++) {
        final String line = rowLines[r];
        String compName = "Component ${r + 1}";
        String valuesStr = line;
        if (line.contains(':')) {
          final int colonIdx = line.indexOf(':');
          compName = line.substring(0, colonIdx).trim();
          valuesStr = line.substring(colonIdx + 1).trim();
        }
        final List<String> tokens = valuesStr
            .split(RegExp(r'[,;]+'))
            .map((String e) => e.trim())
            .where((String e) => e.isNotEmpty)
            .toList();

        if (tokens.length != categories.length) {
          throw FormatException(
            "Component '$compName' has ${tokens.length} values, which does not match the ${categories.length} categories (${categories.join(', ')}).",
          );
        }

        componentNames.add(compName);
        matrix.add(tokens.map(_parseSingleValue).toList());
      }

      final int numCategories = categories.length;
      final int numComponents = componentNames.length;
      final bool hasFractions = matrix.any((List<_CompParsedVal> row) =>
          row.any((_CompParsedVal cell) => cell.isFractionInput));

      final String cleanUnit = _sanitizeLaTeXText(unit);
      final String unitSuffixLaTeX =
      cleanUnit.isEmpty ? '' : '\\text{ $cleanUnit}';
      final String unitSuffixPlain =
      unit.trim().isEmpty ? '' : ' ${unit.trim()}';

      final List<ComponentBarCategoryGroup> groups = [];
      final List<String> colSumLinesLaTeX = [];
      final List<String> colSumBulletsPlain = [];
      final List<_CompFrac> categoryTotalsFrac = [];

      double maxSingleComponentVal = 0;
      double maxStackedTotalVal = 0;

      for (int c = 0; c < numCategories; c++) {
        final String cat = categories[c];
        final String safeCat = _sanitizeLaTeXText(cat);
        _CompFrac colSumFrac = const _CompFrac(0, 1);
        final List<double> compVals = [];
        final List<String> compLaTeX = [];
        final List<String> compPlain = [];

        for (int r = 0; r < numComponents; r++) {
          final _CompParsedVal cell = matrix[r][c];
          colSumFrac = colSumFrac + cell.frac;
          compVals.add(cell.value);
          compLaTeX.add(cell.displayLaTeX);
          compPlain.add(cell.displayPlain);
          if (cell.value > maxSingleComponentVal) {
            maxSingleComponentVal = cell.value;
          }
        }

        categoryTotalsFrac.add(colSumFrac);
        final double totalVal = colSumFrac.toDouble;
        if (totalVal > maxStackedTotalVal) {
          maxStackedTotalVal = totalVal;
        }

        final String totalLaTeXStr = hasFractions && colSumFrac.isFraction
            ? colSumFrac.toMixedLaTeX()
            : _cleanNum(totalVal);
        final String totalPlainStr = hasFractions && colSumFrac.isFraction
            ? colSumFrac.toPlain()
            : _cleanNum(totalVal);

        groups.add(ComponentBarCategoryGroup(
          categoryLabel: cat,
          componentValues: compVals,
          componentLaTeX: compLaTeX,
          componentPlain: compPlain,
          totalValue: totalVal,
          totalLaTeX: totalLaTeXStr,
          totalPlain: totalPlainStr,
        ));

        final String addChainLaTeX = compLaTeX.join(' + ');
        final String addChainPlain = compPlain.join(' + ');
        if (hasFractions &&
            compVals.any((double v) => (v - v.roundToDouble()).abs() > 1e-9)) {
          final List<String> improperParts = [];
          for (int r = 0; r < numComponents; r++) {
            improperParts.add(matrix[r][c].frac.toLaTeX());
          }
          colSumLinesLaTeX.add(
            "\\bullet \\; \\mathbf{\\text{$safeCat}}: \\quad \\text{Total} = $addChainLaTeX = ${improperParts.join(' + ')} = ${colSumFrac.toLaTeX()} = \\mathbf{$totalLaTeXStr$unitSuffixLaTeX}",
          );
        } else {
          colSumLinesLaTeX.add(
            "\\bullet \\; \\mathbf{\\text{$safeCat}}: \\quad \\text{Total} = $addChainLaTeX = \\mathbf{$totalLaTeXStr$unitSuffixLaTeX}",
          );
        }
        colSumBulletsPlain.add(
          "• $cat Total: $addChainPlain = $totalPlainStr$unitSuffixPlain",
        );
      }

      final List<_CompFrac> componentRowTotalsFrac = [];
      final List<String> rowSumLinesLaTeX = [];
      final List<String> rowSumBulletsPlain = [];
      _CompFrac grandTotalFrac = const _CompFrac(0, 1);

      for (int r = 0; r < numComponents; r++) {
        final String compName = componentNames[r];
        final String safeComp = _sanitizeLaTeXText(compName);
        _CompFrac rowSum = const _CompFrac(0, 1);
        final List<String> rowTermsLaTeX = [];
        final List<String> rowTermsPlain = [];

        for (int c = 0; c < numCategories; c++) {
          rowSum = rowSum + matrix[r][c].frac;
          rowTermsLaTeX.add(matrix[r][c].displayLaTeX);
          rowTermsPlain.add(matrix[r][c].displayPlain);
        }

        componentRowTotalsFrac.add(rowSum);
        grandTotalFrac = grandTotalFrac + rowSum;

        final String rTotalLaTeX = hasFractions && rowSum.isFraction
            ? rowSum.toMixedLaTeX()
            : _cleanNum(rowSum.toDouble);
        final String rTotalPlain = hasFractions && rowSum.isFraction
            ? rowSum.toPlain()
            : _cleanNum(rowSum.toDouble);

        rowSumLinesLaTeX.add(
          "\\bullet \\; \\text{Total for } \\mathbf{\\text{$safeComp}} = ${rowTermsLaTeX.join(' + ')} = \\mathbf{$rTotalLaTeX$unitSuffixLaTeX}",
        );
        rowSumBulletsPlain.add(
          "• Total for $compName: ${rowTermsPlain.join(' + ')} = $rTotalPlain$unitSuffixPlain",
        );
      }

      final String grandTotalLaTeX = hasFractions && grandTotalFrac.isFraction
          ? grandTotalFrac.toMixedLaTeX()
          : _cleanNum(grandTotalFrac.toDouble);

      final int effectiveChartStyle =
      mode == 1 ? 1 : (mode == 2 ? 2 : 0);
      final double targetMaxForScale =
      effectiveChartStyle == 1 ? maxStackedTotalVal : maxSingleComponentVal;
      final _CompScaleInfo scaleInfo = _computeNiceScale(targetMaxForScale);

      final List<String> plottingLinesLaTeX = [];
      final List<String> plottingBulletsPlain = [];

      if (effectiveChartStyle == 1) {
        plottingLinesLaTeX.add(
          "\\text{Method II Rule (Page 223): Place the component bars on top of each other so the total height equals the Total frequency:}",
        );
        for (int c = 0; c < numCategories; c++) {
          final String safeCat = _sanitizeLaTeXText(categories[c]);
          _CompFrac runningTop = const _CompFrac(0, 1);
          final List<String> segDescriptionsLaTeX = [];
          final List<String> segDescriptionsPlain = [];

          for (int r = 0; r < numComponents; r++) {
            final String safeComp = _sanitizeLaTeXText(componentNames[r]);
            final String startLaTeX = hasFractions && runningTop.isFraction
                ? runningTop.toMixedLaTeX()
                : _cleanNum(runningTop.toDouble);
            final String startPlain = hasFractions && runningTop.isFraction
                ? runningTop.toPlain()
                : _cleanNum(runningTop.toDouble);

            runningTop = runningTop + matrix[r][c].frac;

            final String endLaTeX = hasFractions && runningTop.isFraction
                ? runningTop.toMixedLaTeX()
                : _cleanNum(runningTop.toDouble);
            final String endPlain = hasFractions && runningTop.isFraction
                ? runningTop.toPlain()
                : _cleanNum(runningTop.toDouble);

            segDescriptionsLaTeX.add(
              "\\text{$safeComp: from } $startLaTeX \\text{ to } \\mathbf{$endLaTeX}",
            );
            segDescriptionsPlain.add(
              "${componentNames[r]} ($startPlain to $endPlain)",
            );
          }
          plottingLinesLaTeX.add(
            "\\bullet \\; \\mathbf{\\text{$safeCat}} \\; (\\text{Total height} = ${groups[c].totalLaTeX}): \\quad ${segDescriptionsLaTeX.join(', \\; ')}",
          );
          plottingBulletsPlain.add(
            "• ${categories[c]} (Total height = ${groups[c].totalPlain}): ${segDescriptionsPlain.join(' -> ')}",
          );
        }
      } else {
        final String dirWord =
        effectiveChartStyle == 2 ? "horizontal length" : "vertical height";
        plottingLinesLaTeX.add(
          "\\text{Method I Rule (Page 222): Draw $numComponents adjoining bars side-by-side for each category with a clear KEY:}",
        );
        for (int c = 0; c < numCategories; c++) {
          final String safeCat = _sanitizeLaTeXText(categories[c]);
          final List<String> barPairsLaTeX = [];
          final List<String> barPairsPlain = [];
          for (int r = 0; r < numComponents; r++) {
            final String safeComp = _sanitizeLaTeXText(componentNames[r]);
            barPairsLaTeX.add(
              "\\text{$safeComp} = \\mathbf{${groups[c].componentLaTeX[r]}}",
            );
            barPairsPlain.add(
              "${componentNames[r]} = ${groups[c].componentPlain[r]}",
            );
          }
          plottingLinesLaTeX.add(
            "\\bullet \\; \\mathbf{\\text{$safeCat}}: \\quad ${barPairsLaTeX.join(', \\; ')} \\quad (\\text{Combined} = ${groups[c].totalLaTeX})",
          );
          plottingBulletsPlain.add(
            "• ${categories[c]} ($dirWord): ${barPairsPlain.join(', ')} (Total = ${groups[c].totalPlain})",
          );
        }
      }

      final List<String> interpLinesLaTeX = [];
      final List<String> interpBulletsPlain = [];

      int maxTotalCatIdx = 0;
      int minTotalCatIdx = 0;
      for (int c = 1; c < numCategories; c++) {
        if (groups[c].totalValue > groups[maxTotalCatIdx].totalValue) {
          maxTotalCatIdx = c;
        }
        if (groups[c].totalValue < groups[minTotalCatIdx].totalValue) {
          minTotalCatIdx = c;
        }
      }
      final String maxCatName = _sanitizeLaTeXText(categories[maxTotalCatIdx]);
      final String minCatName = _sanitizeLaTeXText(categories[minTotalCatIdx]);

      interpLinesLaTeX.add(
        "\\bullet \\; \\text{Highest overall total: } \\mathbf{\\text{$maxCatName}} \\text{ with } \\mathbf{${groups[maxTotalCatIdx].totalLaTeX}$unitSuffixLaTeX}",
      );
      interpLinesLaTeX.add(
        "\\bullet \\; \\text{Lowest overall total: } \\mathbf{\\text{$minCatName}} \\text{ with } \\mathbf{${groups[minTotalCatIdx].totalLaTeX}$unitSuffixLaTeX}",
      );
      interpBulletsPlain.add(
        "• Highest overall total: ${categories[maxTotalCatIdx]} (${groups[maxTotalCatIdx].totalPlain}$unitSuffixPlain); Lowest overall total: ${categories[minTotalCatIdx]} (${groups[minTotalCatIdx].totalPlain}$unitSuffixPlain).",
      );

      for (int r = 0; r < numComponents; r++) {
        int maxIdx = 0;
        int minIdx = 0;
        for (int c = 1; c < numCategories; c++) {
          if (matrix[r][c].value > matrix[r][maxIdx].value) maxIdx = c;
          if (matrix[r][c].value < matrix[r][minIdx].value) minIdx = c;
        }
        final String safeComp = _sanitizeLaTeXText(componentNames[r]);
        final String safeMaxCat = _sanitizeLaTeXText(categories[maxIdx]);
        final String safeMinCat = _sanitizeLaTeXText(categories[minIdx]);
        interpLinesLaTeX.add(
          "\\bullet \\; \\mathbf{\\text{$safeComp}}: \\text{ highest in } \\mathbf{\\text{$safeMaxCat}} \\; (${matrix[r][maxIdx].displayLaTeX}), \\; \\text{lowest in } \\mathbf{\\text{$safeMinCat}} \\; (${matrix[r][minIdx].displayLaTeX})",
        );
        interpBulletsPlain.add(
          "• ${componentNames[r]}: highest in ${categories[maxIdx]} (${matrix[r][maxIdx].displayPlain}), lowest in ${categories[minIdx]} (${matrix[r][minIdx].displayPlain}).",
        );
      }

      String equalCategoriesSummaryLaTeX = "\\text{None}";
      String biggestDiffSummaryLaTeX = "";
      String overallCompDiffLaTeX = "";

      if (numComponents == 2) {
        final String c1Name = _sanitizeLaTeXText(componentNames[0]);
        final String c2Name = _sanitizeLaTeXText(componentNames[1]);

        final List<String> equalCats = [];
        int maxDiffCatIdx = 0;
        _CompFrac maxDiffFrac = const _CompFrac(0, 1);

        for (int c = 0; c < numCategories; c++) {
          final _CompFrac v1 = matrix[0][c].frac;
          final _CompFrac v2 = matrix[1][c].frac;
          final _CompFrac diff =
          (v1.toDouble >= v2.toDouble) ? (v1 - v2) : (v2 - v1);

          if ((v1.toDouble - v2.toDouble).abs() < 1e-9) {
            equalCats.add(
                "${_sanitizeLaTeXText(categories[c])} \\; (${matrix[0][c].displayLaTeX})");
          }
          if (diff.toDouble > maxDiffFrac.toDouble) {
            maxDiffFrac = diff;
            maxDiffCatIdx = c;
          }
        }

        if (equalCats.isNotEmpty) {
          equalCategoriesSummaryLaTeX = equalCats.join(', \\; ');
          interpLinesLaTeX.add(
            "\\bullet \\; \\text{Equal values of $c1Name and $c2Name (Example 4a): } \\mathbf{$equalCategoriesSummaryLaTeX}",
          );
          interpBulletsPlain.add(
            "• Equal values for ${componentNames[0]} and ${componentNames[1]} occur on: ${equalCats.map((String e) => e.replaceAll(r'\;', '')).join(', ')}.",
          );
        } else {
          interpLinesLaTeX.add(
            "\\bullet \\; \\text{Equal values of $c1Name and $c2Name: No category has equal values.}",
          );
        }

        final String bigDiffCat = _sanitizeLaTeXText(categories[maxDiffCatIdx]);
        final String v1MaxStr = matrix[0][maxDiffCatIdx].displayLaTeX;
        final String v2MaxStr = matrix[1][maxDiffCatIdx].displayLaTeX;
        final String diffStr = hasFractions && maxDiffFrac.isFraction
            ? maxDiffFrac.toMixedLaTeX()
            : _cleanNum(maxDiffFrac.toDouble);

        biggestDiffSummaryLaTeX =
        "\\text{$bigDiffCat } (|$v1MaxStr - $v2MaxStr| = \\mathbf{$diffStr$unitSuffixLaTeX})";
        interpLinesLaTeX.add(
          "\\bullet \\; \\text{Biggest difference between $c1Name and $c2Name (Example 4b): } $biggestDiffSummaryLaTeX",
        );
        interpBulletsPlain.add(
          "• Biggest difference between ${componentNames[0]} and ${componentNames[1]} is on ${categories[maxDiffCatIdx]}: |$v1MaxStr - $v2MaxStr| = $diffStr$unitSuffixPlain.",
        );

        final _CompFrac tot1 = componentRowTotalsFrac[0];
        final _CompFrac tot2 = componentRowTotalsFrac[1];
        final _CompFrac overallDiff =
        tot1.toDouble >= tot2.toDouble ? (tot1 - tot2) : (tot2 - tot1);
        final String tot1Str = hasFractions && tot1.isFraction
            ? tot1.toMixedLaTeX()
            : _cleanNum(tot1.toDouble);
        final String tot2Str = hasFractions && tot2.isFraction
            ? tot2.toMixedLaTeX()
            : _cleanNum(tot2.toDouble);
        final String overallDiffStr = hasFractions && overallDiff.isFraction
            ? overallDiff.toMixedLaTeX()
            : _cleanNum(overallDiff.toDouble);
        final String higherComp =
        tot1.toDouble >= tot2.toDouble ? c1Name : c2Name;

        overallCompDiffLaTeX =
        "\\text{$higherComp has } |\\Sigma\\text{$c1Name} - \\Sigma\\text{$c2Name}| = |$tot1Str - $tot2Str| = \\mathbf{$overallDiffStr$unitSuffixLaTeX} \\text{ more}";
        interpLinesLaTeX.add(
          "\\bullet \\; \\text{Overall component difference (Example 4e): } $overallCompDiffLaTeX",
        );
        interpBulletsPlain.add(
          "• Overall component comparison: Total ${componentNames[0]} = $tot1Str, Total ${componentNames[1]} = $tot2Str. Difference = $overallDiffStr$unitSuffixPlain.",
        );

        if (numCategories >= 5) {
          final int idxA = numCategories - 3;
          final int idxB = numCategories - 2;
          final _CompFrac est1 = (matrix[0][idxA].frac + matrix[0][idxB].frac) /
              const _CompFrac(2, 1);
          final _CompFrac est2 = (matrix[1][idxA].frac + matrix[1][idxB].frac) /
              const _CompFrac(2, 1);
          final String catA = _sanitizeLaTeXText(categories[idxA]);
          final String catB = _sanitizeLaTeXText(categories[idxB]);
          interpLinesLaTeX.add(
            "\\bullet \\; \\text{Midpoint estimate halfway between $catA and $catB (Ex 19.1 No. 4c): } \\text{$c1Name} = \\frac{${matrix[0][idxA].displayLaTeX} + ${matrix[0][idxB].displayLaTeX}}{2} = \\mathbf{${_cleanNum(est1.toDouble)}}, \\quad \\text{$c2Name} = \\frac{${matrix[1][idxA].displayLaTeX} + ${matrix[1][idxB].displayLaTeX}}{2} = \\mathbf{${_cleanNum(est2.toDouble)}}",
          );
        }
      }

      final String colSpec = List.filled(numCategories + 2, 'c').join('|');
      final String catHeaders = categories
          .map((String c) => "\\mathbf{\\text{${_sanitizeLaTeXText(c)}}}")
          .join(' & ');

      final StringBuffer tableSb = StringBuffer();
      tableSb.write(
        "\\begin{array}{|$colSpec|} \\hline \\mathbf{\\text{Component}} & $catHeaders & \\mathbf{\\text{Row Total}} \\\\ \\hline ",
      );

      for (int r = 0; r < numComponents; r++) {
        final String safeComp = _sanitizeLaTeXText(componentNames[r]);
        final String rowCells = matrix[r]
            .map((_CompParsedVal cell) => cell.displayLaTeX)
            .join(' & ');
        final _CompFrac rTot = componentRowTotalsFrac[r];
        final String rTotStr = hasFractions && rTot.isFraction
            ? rTot.toMixedLaTeX()
            : _cleanNum(rTot.toDouble);
        tableSb.write(
          "\\mathbf{\\text{$safeComp}} & $rowCells & \\mathbf{$rTotStr} \\\\ \\hline ",
        );
      }

      final String colTotalCells = groups
          .map((ComponentBarCategoryGroup g) => "\\mathbf{${g.totalLaTeX}}")
          .join(' & ');
      tableSb.write(
        "\\mathbf{\\text{Total}} & $colTotalCells & \\mathbf{$grandTotalLaTeX} \\\\ \\hline \\end{array}",
      );
      final String completedTableLaTeX = tableSb.toString();

      final String effectiveTitle = chartTitle.trim().isEmpty
          ? (effectiveChartStyle == 1
          ? "Stacked Component Bar Chart (Method II)"
          : (effectiveChartStyle == 2
          ? "Horizontal Compound Bar Chart"
          : "Side-by-Side Component Bar Chart (Method I)"))
          : chartTitle.trim();

      final Map<String, String> finalAnswers = {
        "Highest Total (${_sanitizeLaTeXText(categories[maxTotalCatIdx])})":
        "\\mathbf{${groups[maxTotalCatIdx].totalLaTeX}$unitSuffixLaTeX}",
        "Lowest Total (${_sanitizeLaTeXText(categories[minTotalCatIdx])})":
        "\\mathbf{${groups[minTotalCatIdx].totalLaTeX}$unitSuffixLaTeX}",
        for (int r = 0; r < numComponents; r++)
          "Total ${_sanitizeLaTeXText(componentNames[r])}":
          "\\mathbf{${hasFractions && componentRowTotalsFrac[r].isFraction ? componentRowTotalsFrac[r].toMixedLaTeX() : _cleanNum(componentRowTotalsFrac[r].toDouble)}$unitSuffixLaTeX}",
        "Grand Total": "\\mathbf{$grandTotalLaTeX$unitSuffixLaTeX}",
        if (numComponents == 2 && biggestDiffSummaryLaTeX.isNotEmpty)
          "Biggest Difference": biggestDiffSummaryLaTeX,
      };

      final List<String> workings = [
        "\\text{\\textbf{Completed Component Bar Table (Chapter 19, Pages 222–235):}}",
        completedTableLaTeX,
        "",
        "\\text{\\textbf{Step 1: Add the Component Values in Each Category Column to Complete the Total Row}}",
        ...colSumLinesLaTeX,
        "",
        "\\text{\\textbf{Step 2: Add Across Each Component Row to Find Component Totals}}",
        ...rowSumLinesLaTeX,
        "\\text{Grand Total across all } $numCategories \\text{ categories} = \\mathbf{$grandTotalLaTeX$unitSuffixLaTeX}",
        "",
        "\\text{\\textbf{Step 3: Bar Heights \\& Plotting Coordinates}}",
        ...plottingLinesLaTeX,
        "",
        "\\text{\\textbf{Step 4: Interpretation of the Component Bar Chart (Example 4 Standard)}}",
        ...interpLinesLaTeX,
      ];

      final List<ComponentBarChartStep> steps = [
        ComponentBarChartStep(
          title:
          "Step 1: Complete the Table by Adding the Components for Each Category",
          description:
          "• For each category column, add all $numComponents component values together without skipping any step to obtain the column Total:\n"
              "${colSumBulletsPlain.join('\n')}",
          mathLinesLaTeX: [
            ...colSumLinesLaTeX,
            completedTableLaTeX,
          ],
        ),
        ComponentBarChartStep(
          title:
          "Step 2: Sum Each Component Row Across All $numCategories Categories",
          description:
          "• Add the values along each component row to find the overall total for each component:\n"
              "${rowSumBulletsPlain.join('\n')}",
          mathLinesLaTeX: [
            ...rowSumLinesLaTeX,
            "\\therefore \\; \\text{Grand Total} = \\mathbf{$grandTotalLaTeX$unitSuffixLaTeX}",
          ],
        ),
        ComponentBarChartStep(
          title: effectiveChartStyle == 1
              ? "Step 3: Draw the Stacked Component Bar Chart (Method II, Page 223)"
              : "Step 3: Draw the Side-by-Side / Compound Bar Chart (Method I, Page 222)",
          description: effectiveChartStyle == 1
              ? "• In Method II, place the component bars on top of each other so the top of the bar equals the column Total:\n"
              "${plottingBulletsPlain.join('\n')}"
              : "• In Method I, draw the component bars side-by-side in each category group with equal bar widths, equal gaps between groups, and a clear KEY:\n"
              "${plottingBulletsPlain.join('\n')}",
          mathLinesLaTeX: plottingLinesLaTeX,
        ),
        ComponentBarChartStep(
          title:
          "Step 4: Answer Examination Interpretation Questions from the Graph (Example 4, Page 224)",
          description:
          "• Compare component heights, differences, and totals directly from the completed table and graph:\n"
              "${interpBulletsPlain.join('\n')}",
          mathLinesLaTeX: interpLinesLaTeX,
        ),
      ];

      return ComponentBarChartResult(
        mode: mode,
        finalAnswersLaTeX: finalAnswers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: ComponentBarChartCanvasData(
          chartStyle: effectiveChartStyle,
          chartTitle: effectiveTitle,
          xAxisLabel:
          xAxisLabel.trim().isEmpty ? "Category" : xAxisLabel.trim(),
          yAxisLabel: yAxisLabel.trim().isEmpty
              ? "Frequency / Value"
              : yAxisLabel.trim(),
          componentNames: componentNames,
          groups: groups,
          yAxisMax: scaleInfo.maxAxis,
          yAxisStep: scaleInfo.step,
          headerLaTeX:
          "\\text{Chapter 19 Component Bar Chart: } $numCategories \\text{ Categories} \\times $numComponents \\text{ Components}",
          subHeaderLaTeX:
          "\\text{Highest Total: } ${_sanitizeLaTeXText(categories[maxTotalCatIdx])} \\; (${groups[maxTotalCatIdx].totalLaTeX}) \\quad | \\quad \\text{Grand Total} = \\mathbf{$grandTotalLaTeX$unitSuffixLaTeX}",
          card1Title: "Highest Category",
          card1LaTeX:
          "\\text{${_sanitizeLaTeXText(categories[maxTotalCatIdx])}: } \\mathbf{${groups[maxTotalCatIdx].totalLaTeX}}",
          card2Title: "Lowest Category",
          card2LaTeX:
          "\\text{${_sanitizeLaTeXText(categories[minTotalCatIdx])}: } \\mathbf{${groups[minTotalCatIdx].totalLaTeX}}",
          card3Title: "Grand Total",
          card3LaTeX: "\\mathbf{$grandTotalLaTeX$unitSuffixLaTeX}",
          summaryTableLaTeX: completedTableLaTeX,
          bottomSummaryLaTeX:
          numComponents == 2 && overallCompDiffLaTeX.isNotEmpty
              ? overallCompDiffLaTeX
              : "\\therefore \\; \\text{Grand Total across all } $numCategories \\text{ categories} = \\mathbf{$grandTotalLaTeX$unitSuffixLaTeX}",
        ),
      );
    } catch (e) {
      return ComponentBarChartResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please check your categories and component rows and try again.",
      );
    }
  }
}