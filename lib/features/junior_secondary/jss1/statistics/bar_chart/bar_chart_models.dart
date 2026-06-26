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

class CategoryData {
  final String category;
  final int frequency;

  CategoryData({required this.category, required this.frequency});
}

class BarChartResult {
  final List<ChartStep> steps;
  final bool valid;
  final String? errorMessage;

  // Data for the Native Chart Renderer
  final List<CategoryData>? chartData;
  final String xAxisLabel;
  final String yAxisLabel;
  final int maxFrequency;
  final int yAxisStep;

  BarChartResult({
    required this.steps,
    this.valid = true,
    this.errorMessage,
    this.chartData,
    this.xAxisLabel = "Categories",
    this.yAxisLabel = "Frequency",
    this.maxFrequency = 10,
    this.yAxisStep = 2,
  });
}