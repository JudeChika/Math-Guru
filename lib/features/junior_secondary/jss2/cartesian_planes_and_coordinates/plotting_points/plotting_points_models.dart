/// A simple class to hold an inputted coordinate point.
class PlotPoint {
  final String name;
  final double x;
  final double y;

  PlotPoint({required this.name, required this.x, required this.y});
}

/// Represents a single pedagogical step during the plotting process.
class PlottingStep {
  final String title;
  final String description;
  final String? mathLaTeX;

  PlottingStep({
    required this.title,
    required this.description,
    this.mathLaTeX,
  });
}

/// Holds the final evaluated results and the step-by-step breakdown.
class PlottingResult {
  final List<PlotPoint> points;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<PlottingStep> steps;
  final bool valid;
  final String? errorMessage;

  PlottingResult({
    required this.points,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}