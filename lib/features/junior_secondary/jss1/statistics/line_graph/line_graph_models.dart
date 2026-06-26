class ChartStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;
  final bool showInWorkings;

  ChartStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
    this.showInWorkings = true,
  });
}

class PointData {
  final String xLabel;
  final double yValue;

  PointData({required this.xLabel, required this.yValue});
}

class LineGraphResult {
  final List<ChartStep> steps;
  final bool valid;
  final String? errorMessage;

  // Data for the Native CustomPaint Renderer
  final List<PointData>? chartData;
  final String xAxisLabel;
  final String yAxisLabel;
  final double maxYValue;
  final int yAxisStep;

  LineGraphResult({
    required this.steps,
    this.valid = true,
    this.errorMessage,
    this.chartData,
    this.xAxisLabel = "Time / Category",
    this.yAxisLabel = "Value",
    this.maxYValue = 10.0,
    this.yAxisStep = 2,
  });
}