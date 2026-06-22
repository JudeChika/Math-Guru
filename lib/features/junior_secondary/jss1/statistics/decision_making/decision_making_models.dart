class StatisticsStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;
  final bool showInWorkings; // Added flag to filter out pure explanations from the Workings UI

  StatisticsStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
    this.showInWorkings = true, // Defaults to true for standard math steps
  });
}

class FreqRow {
  final double x; // Data Value
  final int f;    // Frequency
  final double fx; // f * x

  FreqRow({required this.x, required this.f}) : fx = x * f;
}

class StatisticsResult {
  final List<StatisticsStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;

  // Table Data for UI Rendering
  final List<FreqRow>? tableData;
  final String xHeader;
  final String fHeader;
  final bool showFxColumn;

  StatisticsResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
    this.tableData,
    this.xHeader = "Data (x)",
    this.fHeader = "Frequency (f)",
    this.showFxColumn = false,
  });
}