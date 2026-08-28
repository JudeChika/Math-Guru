import 'frequency_table_models.dart';

class FrequencyTableLogic {

  /// Helper to format numbers nicely (e.g. 2.0 -> 2)
  static String fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// Main public function to process raw data into a frequency table.
  static FrequencyResult processData(String input) {
    try {
      // 1. Sanitize and parse input (Split by commas primarily, fallback to spaces)
      List<String> rawStrings = [];
      if (input.contains(',')) {
        rawStrings = input.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      } else {
        rawStrings = input.split(RegExp(r'\s+')).where((s) => s.trim().isNotEmpty).toList();
      }

      if (rawStrings.isEmpty) {
        throw const FormatException("Empty input");
      }

      if (rawStrings.length < 2) {
        return FrequencyResult(
            rawData: [], sortedData: [], tableRows: [], interpretations: [], steps: [],
            valid: false, errorMessage: "Please enter at least two items to create a table."
        );
      }

      if (rawStrings.length > 200) {
        return FrequencyResult(
            rawData: [], sortedData: [], tableRows: [], interpretations: [], steps: [],
            valid: false, errorMessage: "That's a lot of data! Please enter 200 items or fewer."
        );
      }

      // 2. Check if data is purely numerical
      bool isNumeric = true;
      List<double> numericData = [];
      for (var s in rawStrings) {
        double? val = double.tryParse(s);
        if (val == null) {
          isNumeric = false;
          break;
        }
        numericData.add(val);
      }

      // 3. Rank Order (Sort appropriately based on data type)
      List<String> sortedData;
      if (isNumeric) {
        numericData.sort();
        sortedData = numericData.map((d) => fmt(d)).toList();
      } else {
        // Natural alphabetical sort for text/categorical data
        sortedData = List.from(rawStrings)..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      }

      // 4. Group by frequency
      Map<String, int> counts = {};
      for (var val in sortedData) {
        counts[val] = (counts[val] ?? 0) + 1;
      }

      List<FrequencyRow> tableRows = [];
      counts.forEach((val, freq) {
        tableRows.add(FrequencyRow(value: val, frequency: freq));
      });

      // Keep the table sorted
      if (isNumeric) {
        tableRows.sort((a, b) => double.parse(a.value).compareTo(double.parse(b.value)));
      } else {
        tableRows.sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));
      }

      // 5. Generate Step-by-Step Breakdown
      List<FrequencyStep> steps = [];
      steps.add(FrequencyStep(
          title: "Step 1: Collect Raw Data",
          description: "We start with the jumbled list of ${rawStrings.length} items you provided."
      ));

      steps.add(FrequencyStep(
          title: "Step 2: Arrange in Rank Order",
          description: isNumeric
              ? "To make sense of the data, we sort the numbers from smallest to largest."
              : "To make sense of the data, we group identical items together and sort them alphabetically."
      ));

      steps.add(FrequencyStep(
          title: "Step 3: Count and Tally",
          description: "We go through our sorted list and make a 'Tally Mark' each time an item appears. Every 5th tally mark crosses through the previous four to make groups of 5 easy to see."
      ));

      steps.add(FrequencyStep(
          title: "Step 4: Record the Frequency",
          description: "Finally, we count the tally marks for each item and write it down as a standard digit under the 'Frequency' column."
      ));

      // 6. Generate Interpretations
      List<String> interpretations = [];
      interpretations.add("Total Observations: There are exactly ${rawStrings.length} items in your data set.");

      if (isNumeric) {
        double minVal = numericData.first;
        double maxVal = numericData.last;
        double range = maxVal - minVal;

        interpretations.add("Lowest Value: The smallest number in the data is ${fmt(minVal)}.");
        interpretations.add("Highest Value: The largest number in the data is ${fmt(maxVal)}.");
        interpretations.add("Range: The difference between the highest and lowest value is ${fmt(range)} (${fmt(maxVal)} - ${fmt(minVal)}).");
      }

      // Calculate Mode (Most Frequent)
      int maxFreq = 0;
      for (var row in tableRows) {
        if (row.frequency > maxFreq) maxFreq = row.frequency;
      }

      List<String> modes = tableRows.where((r) => r.frequency == maxFreq).map((r) => r.value).toList();

      if (modes.length == tableRows.length) {
        interpretations.add("Mode (Most Frequent): All items appear exactly ${maxFreq} time(s). There is no specific mode!");
      } else {
        String modeStr = modes.join(', ');
        interpretations.add("Mode (Most Frequent): [$modeStr] appeared the most, showing up $maxFreq time(s).");
      }

      // Calculate Least Frequent
      int minFreq = rawStrings.length + 1;
      for (var row in tableRows) {
        if (row.frequency < minFreq) minFreq = row.frequency;
      }
      List<String> leastFrequent = tableRows.where((r) => r.frequency == minFreq).map((r) => r.value).toList();
      if (leastFrequent.length != tableRows.length) {
        String leastStr = leastFrequent.join(', ');
        interpretations.add("Least Frequent: [$leastStr] appeared the least, showing up only $minFreq time(s).");
      }

      return FrequencyResult(
        rawData: rawStrings,
        sortedData: sortedData,
        tableRows: tableRows,
        interpretations: interpretations,
        steps: steps,
        valid: true,
      );

    } catch (e) {
      return FrequencyResult(
          rawData: [], sortedData: [], tableRows: [], interpretations: [], steps: [],
          valid: false, errorMessage: "Invalid format. Please enter items separated by commas or spaces."
      );
    }
  }
}