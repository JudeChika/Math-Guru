import 'dart:math' as math;
import 'bar_charts_models.dart';

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

class _ParsedBarValue {
  final String raw;
  final _Frac frac;
  final double value;
  final String displayLaTeX;
  final String displayPlain;

  const _ParsedBarValue({
    required this.raw,
    required this.frac,
    required this.value,
    required this.displayLaTeX,
    required this.displayPlain,
  });
}

class _ScaleConfig {
  final double maxScale;
  final double step;

  const _ScaleConfig({
    required this.maxScale,
    required this.step,
  });
}

class BarChartsLogic {
  // ===========================================================================
  // TEXTBOOK PRESETS (Chapter 19, Pages 220–225 & Pages 233–234)
  // ===========================================================================
  static const List<BarChartPreset> textbookPresets = [
    BarChartPreset(
      chipLabel: "Example 1 Table 19.2 (Page 221): Lagos Temperatures (Mar–Nov)",
      mode: 0,
      categoriesInput: "Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov",
      valuesInput: "33, 30, 26, 32, 26, 24, 30, 24, 34",
      chartTitle: "Average Temperatures in Lagos (Mar - Nov 2011)",
      xAxisLabel: "Months",
      yAxisLabel: "Temperature (°C)",
    ),
    BarChartPreset(
      chipLabel: "Example 2 Fig. 19.6 (Page 221–222): Scores in a Mathematics Quiz",
      mode: 0,
      categoriesInput: "Audu, Udoh, Iyabo, Nkem, Tola",
      valuesInput: "40, 30, 25, 35, 30",
      chartTitle: "Scores in a Mathematics Quiz (Max = 50)",
      xAxisLabel: "Students",
      yAxisLabel: "Scores",
      extraInput: "30",
    ),
    BarChartPreset(
      chipLabel: "Fig. 19.2 (Page 220): Travel to School by Bus",
      mode: 0,
      categoriesInput: "Mon, Tue, Wed, Thu, Fri",
      valuesInput: "10, 20, 15, 25, 15",
      chartTitle: "Travel to School by Bus",
      xAxisLabel: "Day",
      yAxisLabel: "Number of Students",
    ),
    BarChartPreset(
      chipLabel: "Fig. 19.3 (Page 220): Bar Line Graph of Dog Owners",
      mode: 2,
      categoriesInput: "1, 2, 3, 4, 5",
      valuesInput: "15, 5, 20, 6, 4",
      chartTitle: "Bar Line Graph of Dog Owners",
      xAxisLabel: "Number of dogs",
      yAxisLabel: "Dog owners",
    ),
    BarChartPreset(
      chipLabel: "Ex 19.1 #1 Fig. 19.9 (Page 224): Favourite Colours of JSS 3A (Boys & Girls)",
      mode: 3,
      categoriesInput: "Blue, Red, Green, Yellow, Pink",
      valuesInput: "8, 6, 5, 7, 6",
      chartTitle: "Favourite Colours of JSS 3A Students",
      xAxisLabel: "Favourite colours",
      yAxisLabel: "Number of students",
      extraInput: "Blue: 1/2 boys; Red: 6 boys; Green: girls = boys + 3; Yellow: 3 girls; Pink: 2/3 girls",
    ),
    BarChartPreset(
      chipLabel: "Ex 19.1 #2 Table 19.4 (Page 225): Horizontal Bar Graph of PMS Sales",
      mode: 1,
      categoriesInput: "Mon, Tue, Wed, Thur, Fri, Sat, Sun",
      valuesInput: "600, 550, 400, 600, 300, 475, 325",
      chartTitle: "Daily Sales of PMS (Litres)",
      xAxisLabel: "Sales in Litres",
      yAxisLabel: "Day",
    ),
    BarChartPreset(
      chipLabel: "Rev Ex 19 #1 Fig. 19.16 (Page 233): Bar Line Graph of Pets in JSS 3 Blue",
      mode: 2,
      categoriesInput: "Dog, Cat, Rabbit, Parrot, Others",
      valuesInput: "8, 10, 2, 7, 3",
      chartTitle: "Pets Owned by Students of JSS 3 Blue",
      xAxisLabel: "Pets",
      yAxisLabel: "Frequency",
    ),
    BarChartPreset(
      chipLabel: "Rev Ex 19 #2 Fig. 19.17 (Page 234): Favourite Subjects of Students",
      mode: 0,
      categoriesInput: "S. Stu, Math, Eng, C.Af, P. E., French",
      valuesInput: "6, 6, 4, 8, 7, 3",
      chartTitle: "Favourite Subjects of Students",
      xAxisLabel: "Subjects",
      yAxisLabel: "Number of Students",
    ),
    BarChartPreset(
      chipLabel: "Table 19.1 (Page 220): Frequency Distribution Table of Scores",
      mode: 0,
      categoriesInput: "45, 50, 60, 75, 80",
      valuesInput: "4, 5, 6, 3, 8",
      chartTitle: "Frequency Distribution of Scores",
      xAxisLabel: "Score",
      yAxisLabel: "Frequency",
    ),
  ];

  // ===========================================================================
  // HELPERS
  // ===========================================================================
  static String _cleanDouble(double v, {int decimals = 2}) {
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    String s = v.toStringAsFixed(decimals);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
    return s;
  }

  static String _safeText(String raw) {
    return raw
        .replaceAll('#', 'No. ')
        .replaceAll('%', r'\%')
        .replaceAll('&', r'\&')
        .replaceAll('_', ' ')
        .trim();
  }

  static _ParsedBarValue _parseValue(String rawToken) {
    final String s = rawToken
        .trim()
        .replaceAll('₦', '')
        .replaceAll(r'$', '')
        .replaceAll('−', '-')
        .replaceAll(RegExp(r'[a-zA-Z°%]+'), '')
        .trim();

    if (s.isEmpty) {
      throw const FormatException("Empty bar value detected.");
    }

    // Mixed number e.g. "7 1/2"
    final RegExp mixedReg = RegExp(r'^([+-]?\d+)\s+(\d+)\s*/\s*(\d+)$');
    final Match? mm = mixedReg.firstMatch(s);
    if (mm != null) {
      final int w = int.parse(mm.group(1)!);
      final int n = int.parse(mm.group(2)!);
      final int d = int.parse(mm.group(3)!);
      if (d == 0) throw const FormatException("Denominator cannot be zero.");
      final int sign = w < 0 ? -1 : 1;
      final int impNum = sign * (w.abs() * d + n);
      final _Frac f = _Frac.from(impNum, d);
      return _ParsedBarValue(
        raw: s,
        frac: f,
        value: f.toDouble,
        displayLaTeX: '$w\\frac{$n}{$d}',
        displayPlain: '$w $n/$d',
      );
    }

    // Simple fraction e.g. "3/4"
    final RegExp fracReg = RegExp(r'^([+-]?\d+)\s*/\s*(\d+)$');
    final Match? fm = fracReg.firstMatch(s);
    if (fm != null) {
      final int n = int.parse(fm.group(1)!);
      final int d = int.parse(fm.group(2)!);
      if (d == 0) throw const FormatException("Denominator cannot be zero.");
      final _Frac f = _Frac.from(n, d);
      return _ParsedBarValue(
        raw: s,
        frac: f,
        value: f.toDouble,
        displayLaTeX: '\\frac{$n}{$d}',
        displayPlain: '$n/$d',
      );
    }

    // Decimal e.g. "12.5"
    if (s.contains('.')) {
      final double? dv = double.tryParse(s);
      if (dv == null) throw FormatException("Invalid number '$rawToken'.");
      final List<String> parts = s.split('.');
      int d = 1;
      for (int i = 0; i < parts[1].length; i++) {
        d *= 10;
      }
      final int sign = s.startsWith('-') ? -1 : 1;
      final String wholeRaw = parts[0].replaceAll('-', '').replaceAll('+', '');
      final int wholeAbs = wholeRaw.isEmpty ? 0 : int.parse(wholeRaw);
      final int decInt = int.parse(parts[1]);
      final _Frac f = _Frac.from(sign * (wholeAbs * d + decInt), d);
      return _ParsedBarValue(
        raw: s,
        frac: f,
        value: dv,
        displayLaTeX: s,
        displayPlain: s,
      );
    }

    final int? iv = int.tryParse(s);
    if (iv == null) {
      throw FormatException("Could not parse '$rawToken' as a valid number.");
    }
    final _Frac f = _Frac.from(iv, 1);
    return _ParsedBarValue(
      raw: s,
      frac: f,
      value: iv.toDouble(),
      displayLaTeX: '$iv',
      displayPlain: '$iv',
    );
  }

  static _ScaleConfig _computeNiceScale(double maxVal) {
    if (maxVal <= 0) return const _ScaleConfig(maxScale: 10, step: 2);
    final double rawStep = maxVal / 5.0;
    final double mag =
    math.pow(10, (math.log(rawStep) / math.ln10).floor()).toDouble();
    final double norm = rawStep / mag;
    double step;
    if (norm <= 1.0) {
      step = 1.0 * mag;
    } else if (norm <= 2.0) {
      step = 2.0 * mag;
    } else if (norm <= 5.0) {
      step = 5.0 * mag;
    } else {
      step = 10.0 * mag;
    }
    final double niceMax = (maxVal / step).ceil() * step;
    return _ScaleConfig(
      maxScale: niceMax < maxVal ? niceMax + step : niceMax,
      step: step,
    );
  }

  // ===========================================================================
  // MASTER SOLVER
  // ===========================================================================
  static BarChartResult solveBarChart({
    required int mode,
    required String rawCategories,
    required String rawValues,
    String chartTitle = '',
    String xAxisLabel = '',
    String yAxisLabel = '',
    String extraInput = '',
  }) {
    try {
      final List<String> categories = rawCategories
          .split(RegExp(r'[,;\n]+'))
          .map((String e) => e.trim())
          .where((String e) => e.isNotEmpty)
          .toList();

      final List<String> valueStrings = rawValues
          .split(RegExp(r'[,;\n]+'))
          .map((String e) => e.trim())
          .where((String e) => e.isNotEmpty)
          .toList();

      if (categories.length < 2) {
        throw const FormatException(
          "Please enter at least 2 categories separated by commas (e.g. Audu, Udoh, Iyabo, Nkem, Tola).",
        );
      }
      if (categories.length != valueStrings.length) {
        throw FormatException(
          "The number of Categories (${categories.length}) must match the number of Values/Frequencies (${valueStrings.length}).",
        );
      }

      final List<_ParsedBarValue> parsedValues =
      valueStrings.map(_parseValue).toList();
      for (int i = 0; i < parsedValues.length; i++) {
        if (parsedValues[i].value < 0) {
          throw FormatException(
            "Bar length/frequency for '${categories[i]}' cannot be negative.",
          );
        }
      }

      final int n = categories.length;
      final double maxVal = parsedValues
          .map((_ParsedBarValue e) => e.value)
          .reduce((double a, double b) => a > b ? a : b);
      final double minVal = parsedValues
          .map((_ParsedBarValue e) => e.value)
          .reduce((double a, double b) => a < b ? a : b);

      // Step 1: Progressive Sum of all frequencies/values
      final List<String> sumStepsLaTeX = [
        "\\text{Total } (\\sum f) = ${parsedValues.map((_ParsedBarValue e) => e.displayLaTeX).join(' + ')}",
      ];
      final List<String> sumStepsPlain = [];
      double runningTotal = parsedValues[0].value;
      _Frac runningFrac = parsedValues[0].frac;

      for (int i = 1; i < n; i++) {
        final String prevStr = _cleanDouble(runningTotal);
        final String currStr = _cleanDouble(parsedValues[i].value);
        runningTotal += parsedValues[i].value;
        runningFrac = runningFrac + parsedValues[i].frac;
        final String nextStr = _cleanDouble(runningTotal);
        sumStepsLaTeX.add(
          "\\bullet \\text{ Add bar ${i + 1} (${_safeText(categories[i])}): } $prevStr + $currStr = \\mathbf{$nextStr}",
        );
        sumStepsPlain.add(
          "• Step $i: $prevStr + $currStr = $nextStr",
        );
      }

      final String totalStr = _cleanDouble(runningTotal);
      sumStepsLaTeX
          .add("\\therefore \\; \\text{Total} = \\mathbf{$totalStr}");

      if (runningTotal <= 0) {
        throw const FormatException(
          "The sum of bar values must be greater than zero.",
        );
      }

      // Step 2: Calculate Average / Mean Value
      final double meanVal = runningTotal / n;
      final String meanStr = _cleanDouble(meanVal);
      final _Frac exactMeanFrac = runningFrac / _Frac(n, 1);

      // Step 3: Identify Highest (Mode), Lowest, Equal Bars, and Below/Above Average
      final List<String> highestCategories = [];
      final List<String> lowestCategories = [];
      final List<String> belowMeanCategories = [];
      final List<String> aboveMeanCategories = [];

      for (int i = 0; i < n; i++) {
        final double v = parsedValues[i].value;
        if ((v - maxVal).abs() < 1e-9) highestCategories.add(categories[i]);
        if ((v - minVal).abs() < 1e-9) lowestCategories.add(categories[i]);
        if (v < meanVal - 1e-9) belowMeanCategories.add(categories[i]);
        if (v > meanVal + 1e-9) aboveMeanCategories.add(categories[i]);
      }

      // Group categories with identical bar heights (Example 2c, Page 221 & Rev Ex 19 #2d, Page 234)
      final Map<String, List<String>> equalGroups = {};
      for (int i = 0; i < n; i++) {
        final String key = _cleanDouble(parsedValues[i].value);
        equalGroups.putIfAbsent(key, () => []).add(categories[i]);
      }
      final List<String> equalBarNotesLaTeX = [];
      final List<String> equalBarNotesPlain = [];
      equalGroups.forEach((String valKey, List<String> cats) {
        if (cats.length > 1) {
          final String joined = cats.map(_safeText).join(' \\text{ and } ');
          equalBarNotesLaTeX.add(
            "\\bullet \\; \\mathbf{\\text{$joined}} \\text{ have the same bar value } (\\mathbf{$valKey}).",
          );
          equalBarNotesPlain.add(
            "• ${cats.join(' and ')} have the exact same value ($valKey).",
          );
        }
      });

      // Step 4: Fraction & Percentage of Total for Each Bar
      final List<BarChartItemData> barItems = [];
      final List<String> barSetupLinesLaTeX = [];
      final List<String> barSetupPlain = [];
      final List<String> tableRowsLaTeX = [];

      for (int i = 0; i < n; i++) {
        final String cat = categories[i];
        final String safeCat = _safeText(cat);
        final _ParsedBarValue pv = parsedValues[i];
        final _Frac propFrac = pv.frac / runningFrac;
        final String pctStr = _cleanDouble((pv.value / runningTotal) * 100.0);
        final bool isMax = (pv.value - maxVal).abs() < 1e-9;
        final bool isMin = (pv.value - minVal).abs() < 1e-9;

        barItems.add(BarChartItemData(
          label: cat,
          value: pv.value,
          valueDisplayPlain: pv.displayPlain,
          valueLaTeX: pv.displayLaTeX,
          fractionOfTotalLaTeX: propFrac.toLaTeX(),
          percentagePlain: "$pctStr%",
          isHighest: isMax,
          isLowest: isMin,
        ));

        barSetupLinesLaTeX.add(
          "\\bullet \\; \\mathbf{\\text{$safeCat}}: \\text{ Bar length/height} = \\mathbf{${pv.displayLaTeX}}, \\quad \\text{Fraction of total} = \\frac{${pv.displayLaTeX}}{$totalStr} = ${propFrac.toLaTeX()}, \\quad \\text{Percentage} = \\frac{${pv.displayLaTeX}}{$totalStr} \\times 100\\% = \\mathbf{$pctStr\\%}",
        );
        barSetupPlain.add(
          "• $cat: bar value = ${pv.displayPlain}, fraction = ${pv.displayPlain}/$totalStr, percentage = $pctStr%",
        );
        tableRowsLaTeX.add(
          "\\text{$safeCat} & \\mathbf{${pv.displayLaTeX}} & \\frac{${pv.displayLaTeX}}{$totalStr} = ${propFrac.toLaTeX()} & $pctStr\\% \\\\ \\hline ",
        );
      }

      final String summaryTableLaTeX =
          "\\begin{array}{|c|c|c|c|} \\hline \\mathbf{\\text{Category}} & \\mathbf{\\text{Value / Freq } (f)} & \\mathbf{\\text{Fraction } \\left(\\frac{f}{\\sum f}\\right)} & \\mathbf{\\text{Percentage}} \\\\ \\hline "
          "${tableRowsLaTeX.join()}"
          "\\mathbf{\\text{Total}} & \\mathbf{$totalStr} & \\mathbf{1} & \\mathbf{100\\%} \\\\ \\hline \\end{array}";

      final _ScaleConfig scale = _computeNiceScale(maxVal);

      // Optional Pass Mark or Fractional Subgroup Analysis (Example 2c or Ex 19.1 #1d–e)
      double? passMarkVal;
      final List<String> extraAnalysisLaTeX = [];
      final List<String> extraAnalysisPlain = [];

      if (mode == 3 || extraInput.contains('/')) {
        // Exercise 19.1 #1 (Page 224) Boys & Girls Fractional Breakdown
        extraAnalysisLaTeX.add(
          "\\text{\\textbf{Fractional Subgroup Breakdown (Exercise 19.1 No. 1d–e, Page 224):}}",
        );
        int totalBoys = 0;
        int totalGirls = 0;
        final List<String> boysTerms = [];
        final List<String> girlsTerms = [];

        for (int i = 0; i < n; i++) {
          final String cat = categories[i];
          final String safeCat = _safeText(cat);
          final int catTotal = parsedValues[i].value.round();
          int boys = 0;
          int girls = 0;
          String ruleExplanationLaTeX = '';
          String ruleExplanationPlain = '';

          final String lowerCat = cat.toLowerCase();
          if (lowerCat == 'blue') {
            // "Half of those who like blue are boys"
            boys = catTotal ~/ 2;
            girls = catTotal - boys;
            ruleExplanationLaTeX =
            "\\text{Half of Blue ($catTotal) are boys: } \\text{Boys} = \\frac{1}{2} \\times $catTotal = \\frac{$catTotal}{2} = \\mathbf{$boys}, \\quad \\text{Girls} = $catTotal - $boys = \\mathbf{$girls}";
            ruleExplanationPlain =
            "Blue ($catTotal): Half are boys -> (1/2) × $catTotal = $boys boys, and $catTotal - $boys = $girls girls.";
          } else if (lowerCat == 'pink') {
            // "Two-thirds of those who like pink are girls"
            girls = (2 * catTotal) ~/ 3;
            boys = catTotal - girls;
            ruleExplanationLaTeX =
            "\\text{Two-thirds of Pink ($catTotal) are girls: } \\text{Girls} = \\frac{2}{3} \\times $catTotal = \\frac{${2 * catTotal}}{3} = \\mathbf{$girls}, \\quad \\text{Boys} = $catTotal - $girls = \\mathbf{$boys}";
            ruleExplanationPlain =
            "Pink ($catTotal): Two-thirds are girls -> (2/3) × $catTotal = $girls girls, and $catTotal - $girls = $boys boys.";
          } else if (lowerCat == 'red') {
            // "Six boys like red"
            boys = math.min(6, catTotal);
            girls = catTotal - boys;
            ruleExplanationLaTeX =
            "\\text{Six boys like Red ($catTotal): } \\text{Boys} = \\mathbf{$boys}, \\quad \\text{Girls} = $catTotal - $boys = \\mathbf{$girls}";
            ruleExplanationPlain =
            "Red ($catTotal): $boys boys, and $catTotal - $boys = $girls girls.";
          } else if (lowerCat == 'yellow') {
            // "Three girls like yellow"
            girls = math.min(3, catTotal);
            boys = catTotal - girls;
            ruleExplanationLaTeX =
            "\\text{Three girls like Yellow ($catTotal): } \\text{Girls} = \\mathbf{$girls}, \\quad \\text{Boys} = $catTotal - $girls = \\mathbf{$boys}";
            ruleExplanationPlain =
            "Yellow ($catTotal): $girls girls, and $catTotal - $girls = $boys boys.";
          } else if (lowerCat == 'green') {
            // "Three more girls like green than boys" -> b + (b + 3) = catTotal
            boys = (catTotal - 3) ~/ 2;
            girls = catTotal - boys;
            ruleExplanationLaTeX =
            "\\text{Green ($catTotal): Let boys } = b, \\text{ then girls } = b + 3 \\implies b + (b + 3) = $catTotal \\implies 2b = ${catTotal - 3} \\implies b = \\frac{${catTotal - 3}}{2} = \\mathbf{$boys \\text{ boys}}, \\; \\text{Girls} = $boys + 3 = \\mathbf{$girls}";
            ruleExplanationPlain =
            "Green ($catTotal): 3 more girls than boys -> 2b + 3 = $catTotal -> b = $boys boys, and girls = $boys + 3 = $girls girls.";
          } else {
            boys = catTotal ~/ 2;
            girls = catTotal - boys;
            ruleExplanationLaTeX =
            "\\text{$safeCat ($catTotal): } \\text{Boys} = \\frac{1}{2} \\times $catTotal = \\mathbf{$boys}, \\quad \\text{Girls} = $catTotal - $boys = \\mathbf{$girls}";
            ruleExplanationPlain =
            "$cat ($catTotal): $boys boys and $girls girls.";
          }

          totalBoys += boys;
          totalGirls += girls;
          boysTerms.add('$boys');
          girlsTerms.add('$girls');
          extraAnalysisLaTeX.add("\\bullet \\; $ruleExplanationLaTeX");
          extraAnalysisPlain.add("• $ruleExplanationPlain");
        }

        extraAnalysisLaTeX.addAll([
          "\\text{d) Total number of boys in the class} = ${boysTerms.join(' + ')} = \\mathbf{$totalBoys \\text{ boys}}",
          "\\text{e) Total number of girls in the class} = ${girlsTerms.join(' + ')} = \\mathbf{$totalGirls \\text{ girls}}",
          "\\text{Check: } $totalBoys \\text{ boys} + $totalGirls \\text{ girls} = \\mathbf{${totalBoys + totalGirls} \\text{ students}}",
        ]);
        extraAnalysisPlain.addAll([
          "• Total number of boys in the class = ${boysTerms.join(' + ')} = $totalBoys boys.",
          "• Total number of girls in the class = ${girlsTerms.join(' + ')} = $totalGirls girls.",
        ]);
      } else if (extraInput.trim().isNotEmpty) {
        final double? pm = double.tryParse(extraInput.trim());
        if (pm != null) {
          passMarkVal = pm;
          final String pmStr = _cleanDouble(pm);
          final List<String> passed = [];
          final List<String> failed = [];
          for (int i = 0; i < n; i++) {
            if (parsedValues[i].value >= pm - 1e-9) {
              passed.add(categories[i]);
            } else {
              failed.add(categories[i]);
            }
          }
          extraAnalysisLaTeX.addAll([
            "\\bullet \\text{ Pass mark given} = \\mathbf{$pmStr}",
            "\\bullet \\text{ Scored at or above pass mark ($pmStr): } \\mathbf{\\text{${passed.isEmpty ? 'None' : passed.map(_safeText).join(', ')}}}",
            "\\bullet \\text{ Scored below pass mark (Failed): } \\mathbf{\\text{${failed.isEmpty ? 'None' : failed.map(_safeText).join(', ')}}}",
          ]);
          extraAnalysisPlain.addAll([
            "• Pass mark = $pmStr",
            "• Passed (>= $pmStr): ${passed.isEmpty ? 'None' : passed.join(', ')}",
            "• Failed (< $pmStr): ${failed.isEmpty ? 'None' : failed.join(', ')}",
          ]);
        }
      }

      final String modeName = mode == 1
          ? "Horizontal Bar Chart"
          : (mode == 2
          ? "Bar Line Graph"
          : (mode == 3
          ? "Bar Chart & Fractional Subgroup Analysis"
          : "Vertical Bar Chart"));

      final String effectiveTitle = chartTitle.trim().isNotEmpty
          ? chartTitle.trim()
          : "Chapter 19 $modeName";
      final String effectiveX =
      xAxisLabel.trim().isNotEmpty ? xAxisLabel.trim() : "Categories";
      final String effectiveY =
      yAxisLabel.trim().isNotEmpty ? yAxisLabel.trim() : "Frequency / Value";

      final String highestStr = highestCategories.map(_safeText).join(', ');
      final String lowestStr = lowestCategories.map(_safeText).join(', ');
      final String belowMeanStr = belowMeanCategories.isEmpty
          ? "None"
          : belowMeanCategories.map(_safeText).join(', ');

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Choose Axes \\& Scale and Tabulate Bar Lengths (Pages 220–221)}}",
        "\\text{Chart Type: \\textbf{$modeName}} \\quad \\left(\\text{Scale step} = ${_cleanDouble(scale.step)}, \\; \\text{Max axis} = ${_cleanDouble(scale.maxScale)}\\right)",
        ...barSetupLinesLaTeX,
        summaryTableLaTeX,
        "",
        "\\text{\\textbf{Step 2: Read Off the Highest, Lowest \\& Equal Bars (Example 2a–c, Page 221)}}",
        "\\text{a) Highest (Modal) category: } \\mathbf{\\text{$highestStr}} \\quad (\\text{Value} = \\mathbf{${_cleanDouble(maxVal)}})",
        "\\text{b) Lowest (Least popular) category: } \\mathbf{\\text{$lowestStr}} \\quad (\\text{Value} = \\mathbf{${_cleanDouble(minVal)}})",
        "\\text{Range of bar values} = ${_cleanDouble(maxVal)} - ${_cleanDouble(minVal)} = \\mathbf{${_cleanDouble(maxVal - minVal)}}",
        if (equalBarNotesLaTeX.isNotEmpty) ...equalBarNotesLaTeX,
        "",
        "\\text{\\textbf{Step 3: Find the Total of All Bars Step-by-Step (Example 2d, Page 222)}}",
        ...sumStepsLaTeX,
        "",
        "\\text{\\textbf{Step 4: Find the Average (Mean) and Identify Bars Below Average (Example 2e–f, Page 222)}}",
        "\\text{Average (Mean)} = \\frac{\\text{Total sum of bars}}{\\text{Number of categories}} = \\frac{$totalStr}{$n} = ${exactMeanFrac.toLaTeX()} = \\mathbf{$meanStr}",
        "\\text{Categories below the average ($meanStr): } \\mathbf{\\text{$belowMeanStr}}",
        if (extraAnalysisLaTeX.isNotEmpty) ...[
          "",
          ...extraAnalysisLaTeX,
        ],
      ];

      final List<BarChartStep> steps = [
        BarChartStep(
          title:
          "Step 1: Choose Suitable Scales & Draw Equal-Width Bars (Pages 220–221)",
          description:
          "• Bar charts are rectangular bars of equal width drawn in lengths proportional to the magnitude of the numbers being represented, with equal gaps between bars.\n"
              "• Axis scale chosen: 0 to ${_cleanDouble(scale.maxScale)} in steps of ${_cleanDouble(scale.step)}.\n"
              "${barSetupPlain.join('\n')}",
          mathLinesLaTeX: [
            ...barSetupLinesLaTeX,
            summaryTableLaTeX,
          ],
        ),
        BarChartStep(
          title:
          "Step 2: Identify the Highest (Mode), Lowest, and Equal Bars (Example 2a–c)",
          description:
          "• Highest bar (Mode / Most popular): ${highestCategories.join(', ')} with ${_cleanDouble(maxVal)}.\n"
              "• Lowest bar (Least popular): ${lowestCategories.join(', ')} with ${_cleanDouble(minVal)}.\n"
              "${equalBarNotesPlain.isNotEmpty ? equalBarNotesPlain.join('\n') : '• All bars have distinct values.'}",
          mathLinesLaTeX: [
            "\\text{Highest (Mode): } \\mathbf{\\text{$highestStr}} \\; (${_cleanDouble(maxVal)})",
            "\\text{Lowest: } \\mathbf{\\text{$lowestStr}} \\; (${_cleanDouble(minVal)})",
            if (equalBarNotesLaTeX.isNotEmpty) ...equalBarNotesLaTeX,
          ],
        ),
        BarChartStep(
          title:
          "Step 3: Add All Bar Values Step-by-Step to Find the Total (Example 2d)",
          description:
          "• Add the values of all $n bars one after another without skipping any step:\n"
              "${sumStepsPlain.join('\n')}",
          mathLinesLaTeX: sumStepsLaTeX,
        ),
        BarChartStep(
          title:
          "Step 4: Calculate the Average (Mean) & Find Who Scored Below Average (Example 2e–f)",
          description:
          "• Divide the total ($totalStr) by the number of categories ($n) to get the average ($meanStr).\n"
              "• Categories below the average ($meanStr): ${belowMeanCategories.isEmpty ? 'None' : belowMeanCategories.join(', ')}.\n"
              "• Categories above the average ($meanStr): ${aboveMeanCategories.isEmpty ? 'None' : aboveMeanCategories.join(', ')}.",
          mathLinesLaTeX: [
            "\\text{Average (Mean)} = \\frac{\\text{Total}}{\\text{No. of bars}} = \\frac{$totalStr}{$n} = ${exactMeanFrac.toLaTeX()} = \\mathbf{$meanStr}",
            "\\text{Below average ($meanStr): } \\mathbf{\\text{$belowMeanStr}}",
          ],
        ),
        if (extraAnalysisLaTeX.isNotEmpty)
          BarChartStep(
            title:
            "Step 5: Additional Pass Mark / Fractional Subgroup Interpretation",
            description: extraAnalysisPlain.join('\n'),
            mathLinesLaTeX: extraAnalysisLaTeX,
          ),
      ];

      return BarChartResult(
        mode: mode,
        finalAnswersLaTeX: {
          "Highest (Mode)": "\\text{$highestStr } (${_cleanDouble(maxVal)})",
          "Lowest": "\\text{$lowestStr } (${_cleanDouble(minVal)})",
          "Total (\\Sigma f)": "\\mathbf{$totalStr}",
          "Average (Mean)":
          "\\frac{$totalStr}{$n} = \\mathbf{$meanStr}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BarChartCanvasData(
          mode: mode,
          chartTitle: effectiveTitle,
          xAxisLabel: effectiveX,
          yAxisLabel: effectiveY,
          bars: barItems,
          maxScaleY: scale.maxScale,
          scaleStepY: scale.step,
          meanValue: meanVal,
          passMark: passMarkVal,
          headerLaTeX:
          "\\text{Chapter 19 ${_safeText(modeName)}: Total} = $totalStr, \\; \\text{Mean} = \\frac{$totalStr}{$n} = \\mathbf{$meanStr}",
          subHeaderLaTeX:
          "\\text{Highest (Mode): } \\mathbf{\\text{$highestStr}} \\; (${_cleanDouble(maxVal)}) \\quad | \\quad \\text{Lowest: } \\mathbf{\\text{$lowestStr}} \\; (${_cleanDouble(minVal)})",
          card1Title: "Highest Bar (Mode)",
          card1LaTeX: "\\text{$highestStr } (${_cleanDouble(maxVal)})",
          card2Title: "Total of All Bars",
          card2LaTeX: "\\sum f = \\mathbf{$totalStr}",
          card3Title: "Average (Mean)",
          card3LaTeX: "\\frac{$totalStr}{$n} = \\mathbf{$meanStr}",
          tableBoxLaTeX: summaryTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Total} = $totalStr, \\quad \\text{Mean} = \\frac{$totalStr}{$n} = $meanStr, \\quad \\text{Below Mean: } \\mathbf{\\text{$belowMeanStr}}",
        ),
      );
    } catch (e) {
      return BarChartResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please check your categories and values and try again.",
      );
    }
  }
}