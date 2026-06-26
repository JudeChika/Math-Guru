import 'line_graph_models.dart';

class LineGraphSolver {
  // --- RAW DATA PARSER (Sequential Trend Data) ---
  static List<PointData>? parseRawData(String rawText) {
    try {
      // Extract numbers separated by commas or spaces
      String cleanText = rawText.replaceAll(RegExp(r'[^\d.,\s-]'), ' ');
      List<String> parts = cleanText.split(RegExp(r'[, \n]+'));

      List<PointData> data = [];
      int index = 1;

      for (String part in parts) {
        if (part.trim().isEmpty) continue;
        double? val = double.tryParse(part.trim());
        if (val != null) {
          data.add(PointData(xLabel: "Pt $index", yValue: val));
          index++;
        }
      }

      if (data.isEmpty) return null;
      return data;
    } catch (_) {
      return null;
    }
  }

  // --- PEDAGOGICAL SOLVER ---
  static LineGraphResult solve(List<PointData> data, String xHead, String yHead, {bool isRawMode = false}) {
    if (data.isEmpty) return LineGraphResult(steps: [], valid: false, errorMessage: "No data provided.");

    List<ChartStep> steps = [];

    // Find Max Y Value
    double maxVal = 0;
    for (var point in data) { if (point.yValue > maxVal) maxVal = point.yValue; }

    // Determine a "nice" pedagogical scale step (1, 2, 5, 10, etc.)
    int stepSize = 1;
    if (maxVal > 100) stepSize = 20;
    else if (maxVal > 50) stepSize = 10;
    else if (maxVal > 20) stepSize = 5;
    else if (maxVal > 10) stepSize = 2;

    // Ensure the Y-axis goes slightly above the max value
    int yMax = ((maxVal ~/ stepSize) + 1) * stepSize;
    if (maxVal % stepSize == 0 && maxVal != 0) yMax = maxVal.toInt() + stepSize;

    // --- PHASE 1: DATA ORGANIZATION ---
    if (isRawMode) {
      steps.add(ChartStep(
          workingLaTeX: "\\text{Step 1: Assign Time/Points}",
          explanation: "Since only a list of values was provided, we assign each value to a sequential point in time (Pt 1, Pt 2, etc.) to show the trend.",
          showInWorkings: false
      ));
    }

    // --- PHASE 2: AXES ---
    steps.add(ChartStep(
        workingLaTeX: "\\text{X-axis: } $xHead \\\\ \\text{Y-axis: } $yHead",
        explanation: "We draw our axes. The horizontal X-axis represents the progression ($xHead). The vertical Y-axis represents the measurement ($yHead)."
    ));

    // --- PHASE 3: SCALE ---
    steps.add(ChartStep(
        workingLaTeX: "\\text{Highest Value} = $maxVal",
        explanation: "We look at our highest value to decide how to number the Y-axis."
    ));

    steps.add(ChartStep(
        workingLaTeX: "\\text{Scale: 1 unit} = $stepSize",
        explanation: "Since our highest number is $maxVal, numbering the Y-axis in steps of $stepSize provides the best scale."
    ));

    // --- PHASE 4: PLOTTING & JOINING ---
    steps.add(ChartStep(
        workingLaTeX: "\\text{Plot the coordinates}",
        explanation: "For each pair of data, we find where the X-value and Y-value meet on the grid and mark it with a small dot."
    ));

    steps.add(ChartStep(
        workingLaTeX: "\\text{Join the dots}",
        explanation: "Finally, we use a straight edge to draw a line connecting each dot to the next one in order. This creates our Line Graph!",
        isFinalAnswer: true
    ));

    return LineGraphResult(
      steps: steps,
      chartData: data,
      xAxisLabel: xHead,
      yAxisLabel: yHead,
      maxYValue: yMax.toDouble(),
      yAxisStep: stepSize,
    );
  }
}