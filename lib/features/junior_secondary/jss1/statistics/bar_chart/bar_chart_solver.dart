import 'bar_chart_models.dart';

class BarChartSolver {
  // --- RAW DATA PARSER (Handles Strings/Words) ---
  static List<CategoryData>? parseRawData(String rawText) {
    try {
      // Split by comma
      List<String> parts = rawText.split(',');

      Map<String, int> freqMap = {};
      for (String part in parts) {
        String cleanPart = part.trim();
        if (cleanPart.isEmpty) continue;

        // Make the first letter uppercase for neatness
        if (cleanPart.length > 1) {
          cleanPart = cleanPart[0].toUpperCase() + cleanPart.substring(1).toLowerCase();
        } else {
          cleanPart = cleanPart.toUpperCase();
        }

        freqMap[cleanPart] = (freqMap[cleanPart] ?? 0) + 1;
      }

      if (freqMap.isEmpty) return null;

      // Convert to list
      List<CategoryData> data = [];
      freqMap.forEach((key, value) => data.add(CategoryData(category: key, frequency: value)));
      return data;
    } catch (_) {
      return null;
    }
  }

  // --- PEDAGOGICAL SOLVER ---
  static BarChartResult solve(List<CategoryData> data, String xHead, String yHead, {bool isRawMode = false}) {
    if (data.isEmpty) return BarChartResult(steps: [], valid: false, errorMessage: "No data provided.");

    List<ChartStep> steps = [];

    // Find Max Frequency
    int maxF = 0;
    for (var row in data) { if (row.frequency > maxF) maxF = row.frequency; }

    // Determine a "nice" pedagogical scale step (1, 2, 5, or 10)
    int stepSize = 1;
    if (maxF > 50) {
      stepSize = 10;
    } else if (maxF > 20) {
      stepSize = 5;
    } else if (maxF > 10) {
      stepSize = 2;
    }

    // Ensure the Y-axis goes slightly above the max frequency
    int yMax = ((maxF ~/ stepSize) + 1) * stepSize;
    if (maxF % stepSize == 0 && maxF != 0) yMax = maxF + stepSize;

    // --- PHASE 1: DATA ORGANIZATION ---
    if (isRawMode) {
      steps.add(ChartStep(
          workingLaTeX: "\\text{Step 1: Organize Data}",
          explanation: "First, we count how many times each item appears in the raw list to create our frequencies.",
          showInWorkings: false
      ));
    }

    // --- PHASE 2: AXES ---
    steps.add(ChartStep(
        workingLaTeX: "\\text{X-axis: } $xHead \\\\ \\text{Y-axis: } $yHead",
        explanation: "We draw our axes. The horizontal X-axis will show the categories ($xHead). The vertical Y-axis will show how many there are ($yHead)."
    ));

    // --- PHASE 3: SCALE ---
    steps.add(ChartStep(
        workingLaTeX: "\\text{Highest Frequency} = $maxF",
        explanation: "We look at our highest frequency to decide how to number the Y-axis."
    ));

    steps.add(ChartStep(
        workingLaTeX: "\\text{Scale: 1 unit} = $stepSize",
        explanation: "Since our highest number is $maxF, numbering the Y-axis in steps of $stepSize is the best scale."
    ));

    // --- PHASE 4: PLOTTING ---
    steps.add(ChartStep(
        workingLaTeX: "\\text{Draw the Bars}",
        explanation: "We draw a rectangular bar for each category. The height of the bar matches its frequency. Remember: A Bar Chart must have equal gaps between the bars!",
        isFinalAnswer: true
    ));

    return BarChartResult(
      steps: steps,
      chartData: data,
      xAxisLabel: xHead,
      yAxisLabel: yHead,
      maxFrequency: yMax,
      yAxisStep: stepSize,
    );
  }
}