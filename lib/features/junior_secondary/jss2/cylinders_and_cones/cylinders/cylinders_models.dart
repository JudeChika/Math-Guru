/// Represents a single pedagogical step during the evaluation.
class CylinderStep {
  final String title;
  final String description;
  final String mathLaTeX;

  CylinderStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// A configuration object to pass the chosen Pi format cleanly
class PiConfig {
  final String text; // e.g., "22/7", "3.14", "3.1", "3"
  final String latex; // e.g., "\\frac{22}{7}", "3.14"
  final double value;

  PiConfig({required this.text, required this.latex, required this.value});
}

/// Holds the results of a solved Cylinder problem.
class CylinderResult {
  final int mode; // 0: SA, 1: Net, 2: Volume, 3: Reverse, 4: Transfer
  final int subMode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<CylinderStep> steps;

  // Visualizer Data required by the CustomPainter
  final double r;
  final double h;
  final double? r2; // For Mode 4 transfer scenarios
  final double? h2;
  final String displayUnit;
  final String title;

  // Error handling state
  final bool valid;
  final String? errorMessage;

  CylinderResult({
    required this.mode,
    required this.subMode,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.r = 0,
    this.h = 0,
    this.r2,
    this.h2,
    this.displayUnit = 'cm',
    this.title = 'Cylinder Analysis',
    this.valid = true,
    this.errorMessage,
  });
}