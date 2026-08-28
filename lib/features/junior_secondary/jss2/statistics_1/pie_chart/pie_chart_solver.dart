import 'pie_chart_models.dart';

class PieChartSolver {

  /// Helper to format numbers nicely (e.g. 90.0 -> 90, 45.567 -> 45.6)
  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }

  /// Main public function to process raw or tabular data into a pie chart result.
  static PieChartResult processData(String input, bool isTableFormat) {
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
        // --- TABLE DATA PARSING (e.g., "Red: 5, Blue: 3") ---
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
      for (var key in counts.keys) {
        if (double.tryParse(key) == null) {
          keysAreNumeric = false;
          break;
        }
      }

      List<String> sortedLabels = counts.keys.toList();
      if (keysAreNumeric) {
        sortedLabels.sort((a, b) => double.parse(a).compareTo(double.parse(b)));
      } else {
        sortedLabels.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      }

      int totalFrequency = 0;
      for (var freq in counts.values) {
        totalFrequency += freq;
      }

      if (totalFrequency == 0) throw const FormatException("Total frequency cannot be zero.");

      List<PieChartRow> tableRows = [];
      double totalDegreesCalculated = 0;

      for (int i = 0; i < sortedLabels.length; i++) {
        String label = sortedLabels[i];
        int freq = counts[label]!;

        // Calculate degree: (frequency / total) * 360
        double exactDegree = (freq / totalFrequency) * 360;

        // Format the working string for the student to see
        String working = "($freq / $totalFrequency) × 360° = ${_fmt(exactDegree)}°";

        tableRows.add(PieChartRow(
          label: label,
          frequency: freq,
          degree: exactDegree,
          workingString: working,
        ));

        totalDegreesCalculated += exactDegree;
      }

      List<PieChartStep> steps = [];
      if (!isTableFormat) {
        steps.add(PieChartStep(
            title: "Step 1: Collect & Count Data",
            description: "First, we look at the raw data and count how many times each item appears. This gives us our Total Frequency of $totalFrequency."
        ));
      } else {
        steps.add(PieChartStep(
            title: "Step 1: Find the Total Frequency",
            description: "We add up all the numbers in your table to find the Total Frequency. The total is $totalFrequency."
        ));
      }

      steps.add(PieChartStep(
          title: "Step 2: Understand the Circle",
          description: "A full circle represents a total of 360 degrees (360°). We need to share this 360° among all our items based on how big their frequency is."
      ));

      steps.add(PieChartStep(
          title: "Step 3: Calculate the Sector Angles",
          description: "For each item, we divide its frequency by the Total Frequency, and then multiply by 360°. Look at the 'Angle Calculation' column in the table above to see the exact math!"
      ));

      steps.add(PieChartStep(
          title: "Step 4: Draw the Pie Chart",
          description: "Using a protractor, we draw slices (sectors) in a circle using the angles we just calculated. The bigger the angle, the bigger the slice!"
      ));

      List<String> interpretations = [];
      interpretations.add("Total Items: The sum of all frequencies is $totalFrequency. This represents the entire 360° of the pie chart.");

      // Find highest and lowest frequencies
      int maxFreq = -1;
      int minFreq = totalFrequency + 1;
      for (var row in tableRows) {
        if (row.frequency > maxFreq) maxFreq = row.frequency;
        if (row.frequency < minFreq) minFreq = row.frequency;
      }

      List<String> modes = tableRows.where((r) => r.frequency == maxFreq).map((r) => r.label).toList();
      List<String> least = tableRows.where((r) => r.frequency == minFreq).map((r) => r.label).toList();

      if (modes.length == tableRows.length && tableRows.length > 1) {
        interpretations.add("Equal Slices: Every item has a frequency of $maxFreq. This means every slice of the pie is the exact same size!");
      } else {
        String modeStr = modes.join(' and ');
        double modeDeg = (maxFreq / totalFrequency) * 360;
        interpretations.add("Biggest Slice (Mode): '$modeStr' is the most frequent item ($maxFreq times). It takes up the largest slice of the pie (${_fmt(modeDeg)}°).");
      }

      if (least.length != tableRows.length) {
        String leastStr = least.join(' and ');
        double leastDeg = (minFreq / totalFrequency) * 360;
        interpretations.add("Smallest Slice: '$leastStr' appeared the least ($minFreq times), so it gets the smallest slice (${_fmt(leastDeg)}°).");
      }

      return PieChartResult(
        isRawData: !isTableFormat,
        rawData: rawData,
        tableRows: tableRows,
        totalFrequency: totalFrequency,
        interpretations: interpretations,
        steps: steps,
        valid: true,
      );

    } catch (e) {
      return PieChartResult(
          isRawData: !isTableFormat, rawData: [], tableRows: [], totalFrequency: 0, interpretations: [], steps: [],
          valid: false, errorMessage: e is FormatException ? e.message : "Invalid format. Please check your input."
      );
    }
  }
}