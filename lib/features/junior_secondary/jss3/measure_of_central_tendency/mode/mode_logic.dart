import 'mode_models.dart';

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

  String toLaTeX() {
    if (num == 0) return '0';
    final String sign = num < 0 ? '-' : '';
    final int an = num.abs();
    if (den == 1) return '$sign$an';
    return '$sign\\frac{$an}{$den}';
  }
}

class _ModeItem {
  final String rawLabel;
  final String displayLaTeX;
  final String displayPlain;
  final double? numericValue;
  final int frequency;

  const _ModeItem({
    required this.rawLabel,
    required this.displayLaTeX,
    required this.displayPlain,
    this.numericValue,
    required this.frequency,
  });
}

class _ModeUnitFormat {
  final String prefixLaTeX;
  final String suffixLaTeX;
  final String prefixPlain;
  final String suffixPlain;

  const _ModeUnitFormat({
    this.prefixLaTeX = '',
    this.suffixLaTeX = '',
    this.prefixPlain = '',
    this.suffixPlain = '',
  });
}

class ModeLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 215–216 & Page 218)
  // ===========================================================================
  static const List<ModePreset> textbookPresets = [
    ModePreset(
      chipLabel: "Example 5 (Page 216): 7, 4, 7, 8, 10, 7, 3, 8, 4",
      mode: 0,
      input1: "7, 4, 7, 8, 10, 7, 3, 8, 4",
    ),
    ModePreset(
      chipLabel: "Example 6 Table 18.10 (Page 216, Bimodal): Grades A to F",
      mode: 1,
      input1: "A, B, C, D, E, F",
      input2: "12, 9, 18, 6, 7, 18",
    ),
    ModePreset(
      chipLabel: "Ex 18.3 #1a (Page 216): 3, 3, 6, 8, 8, 8, 8, 11",
      mode: 0,
      input1: "3, 3, 6, 8, 8, 8, 8, 11",
    ),
    ModePreset(
      chipLabel: "Ex 18.3 #1b (Page 216, Bimodal): 4, 4, 3, 3, 4, 5, 7, 6, 5, 7",
      mode: 0,
      input1: "4, 4, 3, 3, 4, 5, 7, 6, 5, 7",
    ),
    ModePreset(
      chipLabel:
      "Ex 18.3 #1c (Page 216, Bimodal): 13, 12, 11, 9, 13, 12, 14, 13, 12, 12",
      mode: 0,
      input1: "13, 12, 11, 9, 13, 12, 14, 13, 12, 12",
    ),
    ModePreset(
      chipLabel: "Ex 18.3 #1d (Page 216): 30, 32, 33, 33, 33, 34, 35, 35, 35",
      mode: 0,
      input1: "30, 32, 33, 33, 33, 34, 35, 35, 35",
    ),
    ModePreset(
      chipLabel:
      "Ex 18.3 #1e (Page 216): 10, 10, 10, 10, 10, 11, 11, 12, 12, 12, 12, 12, 13, 13, 14, 14",
      mode: 0,
      input1:
      "10, 10, 10, 10, 10, 11, 11, 12, 12, 12, 12, 12, 13, 13, 14, 14",
    ),
    ModePreset(
      chipLabel:
      "Ex 18.3 #2 Table 18.11 (Page 216): Age Distribution & % Aged 15",
      mode: 1,
      input1: "12, 13, 14, 15, 16",
      input2: "8, 6, 7, 11, 8",
      targetValue: "15",
      unit: "years",
    ),
    ModePreset(
      chipLabel: "Ex 18.3 #3 (Page 216): Football Goals in 25 Matches",
      mode: 0,
      input1:
      "0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4",
      unit: "goals",
    ),
    ModePreset(
      chipLabel: "Ex 18.3 #4 (Page 216): 30 Pupils English Test Marks",
      mode: 0,
      input1:
      "9, 8, 8, 6, 5, 7, 8, 9, 10, 10, 3, 7, 3, 5, 4, 8, 7, 8, 10, 9, 8, 7, 10, 9, 9, 7, 5, 4, 8, 1",
      unit: "marks",
    ),
    ModePreset(
      chipLabel:
      "Ex 18.3 #5 (Page 216): Boys' Heights 155, 148, 153, 154, 155, 149, 162, 154, 156, 155",
      mode: 0,
      input1: "155, 148, 153, 154, 155, 149, 162, 154, 156, 155",
      unit: "cm",
    ),
    ModePreset(
      chipLabel: "Rev Ex 18 #3 (Page 218): Children in Each Family Table",
      mode: 1,
      input1: "1, 2, 3, 4",
      input2: "8, 12, 4, 2",
      unit: "children",
    ),
    ModePreset(
      chipLabel:
      "Rev Ex 18 #4 (Page 218): Heights 159, 155, 153, 154, 157, 162, 152, 160, 161, 157",
      mode: 0,
      input1: "159, 155, 153, 154, 157, 162, 152, 160, 161, 157",
      unit: "cm",
    ),
    ModePreset(
      chipLabel: "Rev Ex 18 #5 (Page 218): Students Absent in JS 3 Gold",
      mode: 1,
      input1: "0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10",
      input2: "20, 2, 4, 0, 2, 0, 1, 2, 0, 0, 1",
    ),
    ModePreset(
      chipLabel: "Rev Ex 18 #6 (Page 218): Quiz Marks 1 to 10",
      mode: 1,
      input1: "1, 2, 3, 4, 5, 6, 7, 8, 9, 10",
      input2: "10, 20, 28, 20, 18, 16, 16, 12, 12, 18",
      targetValue: "4",
      unit: "marks",
    ),
    ModePreset(
      chipLabel: "No Mode Example (Page 215): 2, 5, 8, 11, 14, 19",
      mode: 0,
      input1: "2, 5, 8, 11, 14, 19",
    ),
  ];

  static String _cleanDouble(double v, {int decimals = 2}) {
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    String s = v.toStringAsFixed(decimals);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
    return s;
  }

  static _ModeUnitFormat _formatUnit(String rawUnit) {
    final String u = rawUnit.trim();
    if (u.isEmpty) return const _ModeUnitFormat();
    if (u == '₦' || u == r'$' || u == '£') {
      return _ModeUnitFormat(
        prefixLaTeX: '\\text{$u}',
        suffixLaTeX: '',
        prefixPlain: u,
        suffixPlain: '',
      );
    }
    return _ModeUnitFormat(
      prefixLaTeX: '',
      suffixLaTeX: '\\text{ $u}',
      prefixPlain: '',
      suffixPlain: ' $u',
    );
  }

  static ({String displayLaTeX, String displayPlain, double? numVal})
  _parseItemToken(String raw) {
    final String s = raw
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
      throw const FormatException("Empty models item detected.");
    }

    // Check mixed number e.g. "7 1/2"
    final RegExp mixedReg = RegExp(r'^([+-]?\d+)\s+(\d+)\s*/\s*(\d+)$');
    final Match? mm = mixedReg.firstMatch(s);
    if (mm != null) {
      final int w = int.parse(mm.group(1)!);
      final int n = int.parse(mm.group(2)!);
      final int d = int.parse(mm.group(3)!);
      if (d == 0) throw const FormatException("Denominator cannot be zero.");
      final double v = (w < 0 ? -1 : 1) * (w.abs() + n / d);
      return (
      displayLaTeX: '$w\\frac{$n}{$d}',
      displayPlain: '$w $n/$d',
      numVal: v,
      );
    }

    // Check simple fraction e.g. "3/4"
    final RegExp fracReg = RegExp(r'^([+-]?\d+)\s*/\s*(\d+)$');
    final Match? fm = fracReg.firstMatch(s);
    if (fm != null) {
      final int n = int.parse(fm.group(1)!);
      final int d = int.parse(fm.group(2)!);
      if (d == 0) throw const FormatException("Denominator cannot be zero.");
      return (
      displayLaTeX: '\\frac{$n}{$d}',
      displayPlain: '$n/$d',
      numVal: n / d,
      );
    }

    final double? dv = double.tryParse(s);
    if (dv != null) {
      return (
      displayLaTeX: s,
      displayPlain: s,
      numVal: dv,
      );
    }

    // Qualitative / Grade label (e.g. A, B, C, D, E, F in Example 6 Table 18.10)
    return (
    displayLaTeX: '\\text{$s}',
    displayPlain: s,
    numVal: null,
    );
  }

  static ModeResult solveMode({
    required int mode,
    required String rawInput1,
    String rawInput2 = '',
    String targetValue = '',
    String unit = '',
  }) {
    try {
      final _ModeUnitFormat u = _formatUnit(unit);
      final List<_ModeItem> freqTable = [];

      if (mode == 0) {
        // Mode 0: Ungrouped Data List — tally items and build frequency table
        final String normalized =
        rawInput1.replaceAll(RegExp(r'\band\b', caseSensitive: false), ',');
        final List<String> tokens = normalized
            .split(RegExp(r'[,;\n]+'))
            .map((String e) => e.trim())
            .where((String e) => e.isNotEmpty)
            .toList();

        if (tokens.length < 2) {
          throw const FormatException(
            "Please enter at least 2 items separated by commas (e.g. 7, 4, 7, 8, 10, 7, 3, 8, 4).",
          );
        }

        final Map<String, int> counts = {};
        final Map<String, ({String displayLaTeX, String displayPlain, double? numVal})>
        meta = {};
        final List<String> keyOrder = [];

        for (final String t in tokens) {
          final parsed = _parseItemToken(t);
          final String key = parsed.numVal != null
              ? 'num:${parsed.numVal!.toStringAsFixed(6)}'
              : 'str:${parsed.displayPlain.toUpperCase()}';
          if (!counts.containsKey(key)) {
            counts[key] = 0;
            meta[key] = parsed;
            keyOrder.add(key);
          }
          counts[key] = counts[key]! + 1;
        }

        for (final String k in keyOrder) {
          final m = meta[k]!;
          freqTable.add(_ModeItem(
            rawLabel: m.displayPlain,
            displayLaTeX: m.displayLaTeX,
            displayPlain: m.displayPlain,
            numericValue: m.numVal,
            frequency: counts[k]!,
          ));
        }

        // If all items are numeric, sort frequency table in ascending order of score
        if (freqTable.every((_ModeItem item) => item.numericValue != null)) {
          freqTable.sort((_ModeItem a, _ModeItem b) =>
              a.numericValue!.compareTo(b.numericValue!));
        }
      } else {
        // Mode 1: Frequency Distribution Table
        final List<String> rawItems = rawInput1
            .split(RegExp(r'[,;\n]+'))
            .map((String e) => e.trim())
            .where((String e) => e.isNotEmpty)
            .toList();
        final List<String> rawFreqs = rawInput2
            .split(RegExp(r'[,;\n]+'))
            .map((String e) => e.trim())
            .where((String e) => e.isNotEmpty)
            .toList();

        if (rawItems.length < 2) {
          throw const FormatException(
            "Please enter at least 2 items/grades and their frequencies.",
          );
        }
        if (rawItems.length != rawFreqs.length) {
          throw FormatException(
            "The number of Items/Grades (${rawItems.length}) must match the number of Frequencies (${rawFreqs.length}).",
          );
        }

        for (int i = 0; i < rawItems.length; i++) {
          final parsed = _parseItemToken(rawItems[i]);
          final int? f = int.tryParse(rawFreqs[i]);
          if (f == null || f < 0) {
            throw FormatException(
              "Frequency at position ${i + 1} (${rawFreqs[i]}) must be a whole number (0 or greater).",
            );
          }
          freqTable.add(_ModeItem(
            rawLabel: parsed.displayPlain,
            displayLaTeX: parsed.displayLaTeX,
            displayPlain: parsed.displayPlain,
            numericValue: parsed.numVal,
            frequency: f,
          ));
        }
      }

      final int totalFreq =
      freqTable.fold(0, (int sum, _ModeItem item) => sum + item.frequency);
      if (totalFreq <= 0) {
        throw const FormatException(
            "Total frequency must be greater than zero.");
      }

      // Find highest frequency and minimum frequency
      final List<_ModeItem> nonZeroItems =
      freqTable.where((_ModeItem e) => e.frequency > 0).toList();
      final int maxFreq = nonZeroItems
          .map((_ModeItem e) => e.frequency)
          .reduce((int a, int b) => a > b ? a : b);
      final int minFreq = nonZeroItems
          .map((_ModeItem e) => e.frequency)
          .reduce((int a, int b) => a < b ? a : b);

      // Textbook Page 215 rule: "if all the items in a given set of models are different, there cannot be a mode, for no item occurs more frequently than all the others."
      final bool hasNoMode =
          nonZeroItems.length > 1 && maxFreq == minFreq;

      final List<_ModeItem> modalItems = hasNoMode
          ? const []
          : nonZeroItems
          .where((_ModeItem e) => e.frequency == maxFreq)
          .toList();

      String distributionType = "Unimodal (One Mode)";
      if (hasNoMode) {
        distributionType = "No Mode (All items occur equally)";
      } else if (modalItems.length == 2) {
        distributionType = "Bimodal (Two Modes)";
      } else if (modalItems.length > 2) {
        distributionType = "Multimodal (${modalItems.length} Modes)";
      }

      final String modeLaTeX = hasNoMode
          ? "\\text{No Mode}"
          : modalItems
          .map((_ModeItem e) =>
      "${u.prefixLaTeX}${e.displayLaTeX}${u.suffixLaTeX}")
          .join('\\text{ and }');
      final String modePlain = hasNoMode
          ? "No Mode"
          : modalItems
          .map((_ModeItem e) =>
      "${u.prefixPlain}${e.displayPlain}${u.suffixPlain}")
          .join(' and ');

      // Step-by-Step Tally & Frequency Comparison
      final List<String> tallyLinesLaTeX = [];
      final List<String> tallyBulletsPlain = [];
      final List<String> tableRowsLaTeX = [];

      for (final _ModeItem item in freqTable) {
        final bool isModal = !hasNoMode && item.frequency == maxFreq;
        final _Frac propFrac = _Frac.from(item.frequency, totalFreq);
        final String pctStr =
        _cleanDouble((item.frequency / totalFreq) * 100.0);

        tallyLinesLaTeX.add(
          "\\bullet \\text{ Item } \\mathbf{${item.displayLaTeX}}: \\text{ occurs } \\mathbf{${item.frequency}} \\text{ time${item.frequency == 1 ? '' : 's'}} \\quad \\left(\\text{Fraction} = \\frac{${item.frequency}}{$totalFreq} = ${propFrac.toLaTeX()}, \\; \\text{Percentage} = $pctStr\\%\\right)${isModal ? ' \\; \\longleftarrow \\mathbf{\\text{Highest Frequency!}}' : ''}",
        );
        tallyBulletsPlain.add(
          "• Item ${item.displayPlain}: frequency = ${item.frequency} (${item.frequency}/$totalFreq = $pctStr%)${isModal ? ' <-- Highest frequency!' : ''}",
        );
        tableRowsLaTeX.add(
          "${item.displayLaTeX} & ${item.frequency} & \\frac{${item.frequency}}{$totalFreq} = ${propFrac.toLaTeX()} & $pctStr\\%${isModal ? ' \\; \\mathbf{\\star}' : ''} \\\\ \\hline ",
        );
      }

      final String freqTableLaTeX =
          "\\begin{array}{|c|c|c|c|} \\hline \\mathbf{\\text{Item / Score / Grade}} & \\mathbf{\\text{Frequency } (f)} & \\mathbf{\\text{Fraction of Total}} & \\mathbf{\\text{Percentage}} \\\\ \\hline "
          "${tableRowsLaTeX.join()}"
          "\\mathbf{\\text{Total}} & \\mathbf{\\sum f = $totalFreq} & \\mathbf{1} & \\mathbf{100\\%} \\\\ \\hline \\end{array}";

      // Bonus Exam Follow-Up Calculations (Exercise 18.3 #2b, #4c, Rev Ex 18 #6c)
      final List<String> examFollowUpLaTeX = [];
      final List<String> examFollowUpPlain = [];

      // 1. If numeric and unimodal, calculate how many scored below and above the mode (Ex 18.3 #4c)
      if (!hasNoMode &&
          modalItems.isNotEmpty &&
          freqTable.every((_ModeItem e) => e.numericValue != null)) {
        final double firstModeVal = modalItems.first.numericValue!;
        final List<_ModeItem> belowItems = freqTable
            .where((_ModeItem e) => e.numericValue! < firstModeVal)
            .toList();
        final int countBelow =
        belowItems.fold(0, (int s, _ModeItem e) => s + e.frequency);
        final String belowChain = belowItems.isEmpty
            ? "0"
            : belowItems.map((_ModeItem e) => "${e.frequency}").join(' + ');

        examFollowUpLaTeX.add(
          "\\bullet \\text{ Number of items below the mode (${modalItems.first.displayLaTeX}): } $belowChain = \\mathbf{$countBelow} \\quad \\left(\\text{Fraction} = \\frac{$countBelow}{$totalFreq}\\right)",
        );
        examFollowUpPlain.add(
          "• Number of items scoring below the mode (${modalItems.first.displayPlain}): $belowChain = $countBelow out of $totalFreq",
        );
      }

      // 2. If user supplied a target query value (e.g. Ex 18.3 #2b: age 15, or Rev Ex 18 #6c: score >= 4)
      if (targetValue.trim().isNotEmpty) {
        final String tClean = targetValue.trim();
        final double? tNum = double.tryParse(tClean);
        for (final _ModeItem item in freqTable) {
          if (item.rawLabel.toLowerCase() == tClean.toLowerCase() ||
              (tNum != null && item.numericValue == tNum)) {
            final _Frac red = _Frac.from(item.frequency, totalFreq);
            final String pct =
            _cleanDouble((item.frequency / totalFreq) * 100.0);
            examFollowUpLaTeX.add(
              "\\bullet \\text{ Percentage for item ${item.displayLaTeX} (Ex 18.3 \\#2b): } \\frac{${item.frequency}}{$totalFreq} \\times 100\\% = ${red.toLaTeX()} \\times 100\\% = \\mathbf{$pct\\%}",
            );
            examFollowUpPlain.add(
              "• Percentage for item ${item.displayPlain}: (${item.frequency}/$totalFreq) × 100% = $pct%",
            );
          }
        }
        if (tNum != null &&
            freqTable.every((_ModeItem e) => e.numericValue != null)) {
          final List<_ModeItem> atLeast = freqTable
              .where((_ModeItem e) => e.numericValue! >= tNum)
              .toList();
          if (atLeast.isNotEmpty) {
            final int cAtLeast =
            atLeast.fold(0, (int s, _ModeItem e) => s + e.frequency);
            final String chain =
            atLeast.map((_ModeItem e) => "${e.frequency}").join(' + ');
            examFollowUpLaTeX.add(
              "\\bullet \\text{ Count of items } \\ge $tClean \\text{ (Rev Ex 18 \\#6c): } $chain = \\mathbf{$cAtLeast}",
            );
            examFollowUpPlain.add(
              "• Number of items with score $tClean or more: $chain = $cAtLeast",
            );
          }
        }
      }

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Construct the Frequency Distribution Table (Pages 215–216)}}",
        freqTableLaTeX,
        "",
        "\\text{\\textbf{Step 2: Count and Compare the Frequency of Each Item}}",
        ...tallyLinesLaTeX,
        "",
        "\\text{\\textbf{Step 3: Identify the Item(s) with the Highest Frequency}}",
        if (hasNoMode) ...[
          "\\text{Every item occurs the exact same number of times ($maxFreq time${maxFreq == 1 ? '' : 's'}).}",
          "\\text{By the textbook rule (Page 215), since no item occurs more frequently than the others, there is \\textbf{No Mode}.}",
        ] else ...[
          "\\text{Highest frequency } (f_{\\max}) = \\mathbf{$maxFreq} \\quad \\left(\\text{Proportion} = \\frac{$maxFreq}{$totalFreq}\\right)",
          "\\text{Distribution Classification: \\textbf{$distributionType}}",
          "\\therefore \\; \\text{Mode} = \\mathbf{$modeLaTeX}",
        ],
        if (examFollowUpLaTeX.isNotEmpty) ...[
          "",
          "\\text{\\textbf{Step 4: Additional Examination Follow-Up Calculations}}",
          ...examFollowUpLaTeX,
        ],
      ];

      final List<ModeStep> steps = [
        const ModeStep(
          title: "Step 1: Define the Mode (Page 215)",
          description:
          "• The item that occurs most often in a given set of models is called the mode.\n"
              "• In a frequency table, the number or grade that has the highest frequency is the mode.",
          mathLinesLaTeX: [
            r"\text{Mode} = \text{Item with the highest frequency } (f_{\max})",
          ],
        ),
        ModeStep(
          title:
          "Step 2: Tally Every Distinct Item and Build the Frequency Table",
          description:
          "• Count how many times each value or grade appears out of the $totalFreq total items:\n"
              "${tallyBulletsPlain.join('\n')}",
          mathLinesLaTeX: [
            ...tallyLinesLaTeX,
            freqTableLaTeX,
          ],
        ),
        ModeStep(
          title:
          "Step 3: Identify the Highest Frequency and Classify the Distribution",
          description: hasNoMode
              ? "• Every item has the same frequency ($maxFreq). As stated on Page 215 of the textbook, when all items occur the same number of times, there is no mode."
              : "• The highest frequency in the table is $maxFreq.\n"
              "• The item(s) with frequency $maxFreq: $modePlain ($distributionType).",
          mathLinesLaTeX: [
            if (hasNoMode)
              r"\text{All frequencies are equal } \implies \mathbf{\text{No Mode}}"
            else ...[
              "\\text{Highest Frequency } (f_{\\max}) = \\mathbf{$maxFreq} \\text{ out of } $totalFreq \\; \\left(\\frac{$maxFreq}{$totalFreq}\\right)",
              "\\therefore \\; \\text{Mode} = \\mathbf{$modeLaTeX} \\quad (\\text{$distributionType})",
            ],
          ],
        ),
        if (examFollowUpLaTeX.isNotEmpty)
          ModeStep(
            title:
            "Step 4: Examination Follow-Up Metrics (Percentage & Count Below/Above Mode)",
            description:
            "• Use the frequency table to answer standard examination sub-questions:\n"
                "${examFollowUpPlain.join('\n')}",
            mathLinesLaTeX: examFollowUpLaTeX,
          ),
      ];

      return ModeResult(
        mode: mode,
        finalAnswersLaTeX: {
          "Total Items (\\Sigma f)": "$totalFreq",
          "Highest Frequency": "$maxFreq \\; \\left(\\frac{$maxFreq}{$totalFreq}\\right)",
          "Distribution Type": "\\text{$distributionType}",
          "Mode": "\\mathbf{$modeLaTeX}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: ModeCanvasData(
          headerLaTeX:
          "\\text{Chapter 18 Mode \\& Frequency Table (Pages 215–216): } \\text{$distributionType}",
          subHeaderLaTeX: hasNoMode
              ? "\\text{All items occur $maxFreq time(s)} \\implies \\mathbf{\\text{No Mode}}"
              : "\\text{Highest Frequency } f_{\\max} = $maxFreq \\; \\left(\\frac{$maxFreq}{$totalFreq}\\right) \\implies \\text{Mode} = \\mathbf{$modeLaTeX}",
          card1Title: "Total Items (Σf)",
          card1LaTeX: "$totalFreq",
          card2Title: "Highest Freq (f_max)",
          card2LaTeX: "$maxFreq \\; \\left(\\frac{$maxFreq}{$totalFreq}\\right)",
          card3Title: "Mode",
          card3LaTeX: "\\mathbf{$modeLaTeX}",
          mainBoxLaTeX: freqTableLaTeX,
          bottomSummaryLaTeX: hasNoMode
              ? "\\therefore \\; \\text{No item occurs more frequently than the others} \\implies \\mathbf{\\text{No Mode}}"
              : "\\therefore \\; \\text{Mode} = \\mathbf{$modeLaTeX} \\quad (\\text{occurs } $maxFreq \\text{ times})",
        ),
      );
    } catch (e) {
      return ModeResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please check your input models and try again.",
      );
    }
  }
}