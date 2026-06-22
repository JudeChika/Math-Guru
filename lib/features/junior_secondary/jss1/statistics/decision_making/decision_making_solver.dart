import 'decision_making_models.dart';

class DecisionMakingSolver {
  static String _format(double n) {
    return n == n.truncateToDouble() ? n.toInt().toString() : n.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  // --- RAW DATA PARSERS ---
  static List<FreqRow>? parseRawData(String rawText) {
    try {
      String cleanText = rawText.replaceAll(RegExp(r'[^\d.,\s-]'), ' ');
      List<String> parts = cleanText.split(RegExp(r'[, \n]+'));

      Map<double, int> freqMap = {};
      for (String part in parts) {
        if (part.trim().isEmpty) continue;
        double val = double.parse(part.trim());
        freqMap[val] = (freqMap[val] ?? 0) + 1;
      }

      if (freqMap.isEmpty) return null;

      List<double> keys = freqMap.keys.toList()..sort();
      return keys.map((k) => FreqRow(x: k, f: freqMap[k]!)).toList();
    } catch (_) {
      return null;
    }
  }

  static List<double> _extractRawList(String rawText) {
    String cleanText = rawText.replaceAll(RegExp(r'[^\d.,\s-]'), ' ');
    List<String> parts = cleanText.split(RegExp(r'[, \n]+'));
    List<double> list = [];
    for (String part in parts) {
      if (part.trim().isNotEmpty) {
        list.add(double.parse(part.trim()));
      }
    }
    return list;
  }

  // --- INTERPRETATION ENGINE ---
  static StatisticsResult solve(List<FreqRow> data, String interpretation, String xHead, String fHead, {bool isRawMode = false, String? rawText}) {
    if (data.isEmpty) return StatisticsResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "No data provided.");

    data.sort((a, b) => a.x.compareTo(b.x));

    List<StatisticsStep> steps = [];

    // --- TABLE GENERATION EXPLANATION (Hidden from Workings UI) ---
    if (isRawMode && rawText != null) {
      steps.add(StatisticsStep(
          workingLaTeX: "\\text{Step 1: Organize Data}",
          explanation: "First, we must convert the messy raw data into an organized Frequency Distribution Table.",
          showInWorkings: false
      ));

      List<double> rawList = _extractRawList(rawText);
      rawList.sort();
      String sortedStr = rawList.take(12).map((e) => _format(e)).join(', ');
      if (rawList.length > 12) sortedStr += ", \\dots";

      steps.add(StatisticsStep(
          workingLaTeX: sortedStr,
          explanation: "We arrange all the raw numbers from lowest to highest to make counting easier.",
          showInWorkings: false
      ));

      steps.add(StatisticsStep(
          workingLaTeX: "\\text{Tally and Count}",
          explanation: "We list each unique number under the '$xHead' column, draw tallies to count how many times it appears, and record this final count as the '$fHead'.",
          showInWorkings: false
      ));
    } else {
      steps.add(StatisticsStep(
          workingLaTeX: "\\text{Given Table}",
          explanation: "We start with the frequency distribution table already provided to us.",
          showInWorkings: false
      ));
    }
    // ------------------------------------

    // --- CALCULATIONS ---
    if (interpretation == 'Mode') {
      int maxF = 0;
      for (var row in data) { if (row.f > maxF) maxF = row.f; }

      List<double> modes = data.where((r) => r.f == maxF).map((r) => r.x).toList();

      steps.add(StatisticsStep(workingLaTeX: "\\text{Highest Frequency} = $maxF", explanation: "Scan the Frequency column to find the highest number."));

      String modeStr = modes.map((m) => _format(m)).join(', ');
      steps.add(StatisticsStep(workingLaTeX: "\\text{Mode} = $modeStr", explanation: "The Mode is the Data value(s) that corresponds to this highest frequency.", isFinalAnswer: true));

      return StatisticsResult(steps: steps, finalAnswerLaTeX: "\\text{Mode} = $modeStr", tableData: data, xHeader: xHead, fHeader: fHead);
    }

    else if (interpretation == 'Mean') {
      steps.add(StatisticsStep(workingLaTeX: "\\text{Mean} = \\frac{\\sum fx}{\\sum f}", explanation: "The formula for the Mean of grouped data is the Total Sum (fx) divided by the Total Frequency (f)."));

      int sumF = 0;
      double sumFX = 0;
      for (var row in data) {
        sumF += row.f;
        sumFX += row.fx;
      }

      steps.add(StatisticsStep(workingLaTeX: "\\sum f = $sumF", explanation: "Add all the numbers in the Frequency column together."));
      steps.add(StatisticsStep(workingLaTeX: "\\sum fx = ${_format(sumFX)}", explanation: "Multiply each data value (x) by its frequency (f) to create an 'fx' column, then add them all together."));

      double mean = sumFX / sumF;
      steps.add(StatisticsStep(workingLaTeX: "\\text{Mean} = \\frac{${_format(sumFX)}}{$sumF}", explanation: "Divide the Total Sum by the Total Frequency."));
      steps.add(StatisticsStep(workingLaTeX: "\\text{Mean} = ${_format(mean)}", explanation: "Calculate the final Mean.", isFinalAnswer: true));

      return StatisticsResult(steps: steps, finalAnswerLaTeX: "\\text{Mean} = ${_format(mean)}", tableData: data, xHeader: xHead, fHeader: fHead, showFxColumn: true);
    }

    else if (interpretation == 'Median') {
      int n = data.fold(0, (sum, row) => sum + row.f);
      steps.add(StatisticsStep(workingLaTeX: "N = \\sum f = $n", explanation: "First, find the total number of items (Total Frequency)."));

      if (n % 2 != 0) {
        int pos = (n + 1) ~/ 2;
        steps.add(StatisticsStep(workingLaTeX: "\\text{Position} = \\frac{$n + 1}{2} = ${pos}\\text{th item}", explanation: "Since N is an odd number, the median is the value at the exact middle position."));

        double median = _getValAtPosition(data, pos);
        steps.add(StatisticsStep(workingLaTeX: "\\text{Median} = ${_format(median)}", explanation: "Using cumulative frequency (counting down the frequency column until we reach item #$pos), we find the median.", isFinalAnswer: true));
        return StatisticsResult(steps: steps, finalAnswerLaTeX: "\\text{Median} = ${_format(median)}", tableData: data, xHeader: xHead, fHeader: fHead);
      } else {
        int pos1 = n ~/ 2;
        int pos2 = pos1 + 1;
        steps.add(StatisticsStep(workingLaTeX: "\\text{Positions} = \\frac{$n}{2} \\text{ and } \\frac{$n}{2} + 1 = ${pos1}\\text{th and } ${pos2}\\text{th}", explanation: "Since N is an even number, the median is the average of the two middle positions."));

        double v1 = _getValAtPosition(data, pos1);
        double v2 = _getValAtPosition(data, pos2);

        steps.add(StatisticsStep(workingLaTeX: "\\text{Values} = ${_format(v1)} \\text{ and } ${_format(v2)}", explanation: "Counting down the frequencies, we find the values at these positions."));

        double median = (v1 + v2) / 2;
        steps.add(StatisticsStep(workingLaTeX: "\\text{Median} = \\frac{${_format(v1)} + ${_format(v2)}}{2} = ${_format(median)}", explanation: "Add them together and divide by 2.", isFinalAnswer: true));
        return StatisticsResult(steps: steps, finalAnswerLaTeX: "\\text{Median} = ${_format(median)}", tableData: data, xHeader: xHead, fHeader: fHead);
      }
    }

    else if (interpretation == 'Range') {
      double lowest = data.first.x;
      double highest = data.last.x;
      double range = highest - lowest;

      steps.add(StatisticsStep(workingLaTeX: "\\text{Highest} = ${_format(highest)}, \\; \\text{Lowest} = ${_format(lowest)}", explanation: "Identify the highest and lowest values in the Data column (not the frequency)."));
      steps.add(StatisticsStep(workingLaTeX: "\\text{Range} = ${_format(highest)} - ${_format(lowest)} = ${_format(range)}", explanation: "Subtract the lowest value from the highest value to find the Range.", isFinalAnswer: true));
      return StatisticsResult(steps: steps, finalAnswerLaTeX: "\\text{Range} = ${_format(range)}", tableData: data, xHeader: xHead, fHeader: fHead);
    }

    return StatisticsResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Unknown interpretation.");
  }

  static double _getValAtPosition(List<FreqRow> data, int targetPos) {
    int cumF = 0;
    for (var row in data) {
      cumF += row.f;
      if (cumF >= targetPos) return row.x;
    }
    return data.last.x;
  }

  static String generateTally(int f) {
    if (f == 0) return "-";
    int fives = f ~/ 5;
    int ones = f % 5;

    String res = "";
    for(int i=0; i<fives; i++) {
      res += "卌 ";
    }
    for(int i=0; i<ones; i++) {
      res += "|";
    }
    return res.trim();
  }
}