/// Represents a single question/query to read from the graph
class GraphQuestion {
  final String type; // 'findY' (given X) or 'findX' (given Y)
  final double givenValue;

  GraphQuestion({required this.type, required this.givenValue});
}

/// Represents a single pedagogical step
class LinearGraphStep {
  final String title;
  final String description;
  final String? mathLaTeX;

  LinearGraphStep({
    required this.title,
    required this.description,
    this.mathLaTeX,
  });
}

/// Holds the final evaluated results, graph plotting data, and steps
class LinearGraphResult {
  final String xLabel;
  final String yLabel;
  final double rate;
  final bool isContinuous;

  final double scaleX;
  final double scaleY;

  final List<Map<String, double>> tableOfValues;
  final List<GraphQuestion> questions;
  final Map<String, String> finalAnswers;

  final List<String> workingsLaTeX;
  final List<LinearGraphStep> steps;

  final bool valid;
  final String? errorMessage;

  LinearGraphResult({
    required this.xLabel,
    required this.yLabel,
    required this.rate,
    required this.isContinuous,
    required this.scaleX,
    required this.scaleY,
    required this.tableOfValues,
    required this.questions,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}