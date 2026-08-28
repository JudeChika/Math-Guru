import 'bar_chart_models.dart';

class BarChartSolver {

  /// Helper to format numbers nicely (e.g. 2.0 -> 2)
  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// Main public function to process raw or tabular data into a bar chart result.
  static BarChartResult processData(String input, bool isTableFormat) {
    try {
      if (input.trim().isEmpty) throw const FormatException("Empty input");

      List<String> rawData = [];
      Map<String, int> counts = {};

      if (!isTableFormat) {
        // --- RAW DATA PARSING ---
        if (input.contains(',')) {
          rawData = input.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        } else {
          rawData = input.split(RegExp(r'\s+')).where((s) => s.trim().isNotEmpty).toList();
        }

        if (rawData.length < 2) throw const FormatException("Enter at least two items.");

        for (var val in rawData) {
          counts[val] = (counts[val] ?? 0) + 1;
        }
      } else {
        // --- TABLE DATA PARSING (e.g., "Apple: 5, Banana: 3") ---
        List<String> pairs = [];
        if (input.contains(',')) {
          pairs = input.split(',');
        } else if (input.contains('\n')) {
          pairs = input.split('\n');
        } else {
          throw const FormatException("Table data must be separated by commas or new lines.");
        }

        for (var pair in pairs) {
          if (pair.trim().isEmpty) continue;

          // Matches "Label: 5" or "Label = 5"
          var match = RegExp(r'^(.+)[:=]\s*(\d+)$').firstMatch(pair.trim());
          if (match == null) throw const FormatException("Invalid table format. Use 'Label: Number'");

          String label = match.group(1)!.trim();
          int freq = int.parse(match.group(2)!);

          if (freq < 0) throw const FormatException("Frequencies cannot be negative.");
          counts[label] = (counts[label] ?? 0) + freq;
        }
      }

      if (counts.isEmpty) throw const FormatException("No valid data found.");

      // Check if keys are entirely numerical to sort ascending, else sort alphabetically
      bool keysAreNumeric = true;
      List<double> numericKeys = [];
      for (var key in counts.keys) {
        double? val = double.tryParse(key);
        if (val == null) {
          keysAreNumeric = false;
          break;
        }
        numericKeys.add(val);
      }

      List<BarChartRow> tableRows = [];
      counts.forEach((label, freq) {
        tableRows.add(BarChartRow(label: label, frequency: freq));
      });

      // Rank Order
      if (keysAreNumeric) {
        tableRows.sort((a, b) => double.parse(a.label).compareTo(double.parse(b.label)));
      } else {
        tableRows.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
      }

      int maxFreq = 0;
      int totalItems = 0;
      for (var row in tableRows) {
        if (row.frequency > maxFreq) maxFreq = row.frequency;
        totalItems += row.frequency;
      }

      // Ensure we have a reasonable max frequency for the chart scale
      if (maxFreq == 0) maxFreq = 1;

      List<BarChartStep> steps = [];
      if (!isTableFormat) {
        steps.add(BarChartStep(
            title: "Step 1: Collect & Organize Data",
            description: "We start by looking at your jumbled list of $totalItems items. We group identical items together and count how many times each one appears."
        ));
      } else {
        steps.add(BarChartStep(
            title: "Step 1: Read the Frequency Table",
            description: "You provided the data already counted! We read your table to see that there are $totalItems items in total."
        ));
      }

      steps.add(BarChartStep(
          title: "Step 2: Draw the Axes",
          description: "We draw an L-shape. The vertical line (Y-axis) is for the 'Frequency' (how many). The horizontal line (X-axis) is for the 'Items' or 'Categories'."
      ));

      steps.add(BarChartStep(
          title: "Step 3: Scale the Y-Axis",
          description: "The highest frequency is $maxFreq. We mark numbers evenly on the vertical line from 0 up to a number slightly above $maxFreq so our tallest bar fits perfectly."
      ));

      steps.add(BarChartStep(
          title: "Step 4: Draw the Bars",
          description: "For each item, we draw a rectangular bar going up. The height of the bar stops exactly at the number on the Y-axis that matches its frequency. We leave equal gaps between the bars to make it neat!"
      ));

      List<String> interpretations = [];
      interpretations.add("Total Items: If we stack all the items together, we have a total of $totalItems.");

      // Calculate Mode (Most Frequent / Tallest Bar)
      List<String> modes = tableRows.where((r) => r.frequency == maxFreq).map((r) => r.label).toList();

      if (modes.length == tableRows.length && tableRows.length > 1) {
        interpretations.add("Mode: Every single item has a frequency of $maxFreq. All the bars are the exact same height! There is no specific mode.");
      } else {
        String modeStr = modes.join(' and ');
        interpretations.add("Tallest Bar (Mode): '$modeStr' is the most popular, showing up $maxFreq time(s).");
      }

      // Calculate Least Frequent / Shortest Bar
      int minFreq = totalItems + 1;
      for (var row in tableRows) {
        if (row.frequency < minFreq) minFreq = row.frequency;
      }
      List<String> leastFrequent = tableRows.where((r) => r.frequency == minFreq).map((r) => r.label).toList();
      if (leastFrequent.length != tableRows.length) {
        String leastStr = leastFrequent.join(' and ');
        interpretations.add("Shortest Bar: '$leastStr' appeared the least, showing up only $minFreq time(s).");
      }

      if (keysAreNumeric && numericKeys.length > 1) {
        numericKeys.sort();
        double range = numericKeys.last - numericKeys.first;
        interpretations.add("Data Range: Since your items are numbers, the difference between the highest item (${_fmt(numericKeys.last)}) and the lowest item (${_fmt(numericKeys.first)}) is ${_fmt(range)}.");
      }

      return BarChartResult(
        isRawData: !isTableFormat,
        rawData: rawData,
        tableRows: tableRows,
        maxFrequency: maxFreq,
        interpretations: interpretations,
        steps: steps,
        valid: true,
      );

    } catch (e) {
      return BarChartResult(
          isRawData: !isTableFormat, rawData: [], tableRows: [], maxFrequency: 0, interpretations: [], steps: [],
          valid: false, errorMessage: e is FormatException ? e.message : "Invalid format. Please check your input."
      );
    }
  }
}