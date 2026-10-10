/// Represents a single pedagogical step during the evaluation.
class PythagorasStep {
  final String title;
  final String description;
  final String mathLaTeX;

  PythagorasStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Represents a Right-Angled Triangle with raw string inputs
class PythagorasTriangleData {
  final String name;
  final String base;
  final String height;
  final String hypotenuse;

  PythagorasTriangleData({
    required this.name,
    required this.base,
    required this.height,
    required this.hypotenuse,
  });
}

/// Represents a mathematically solved triangle for the visualizer
class SolvedTriangle {
  final String name;
  final double baseVal;
  final double heightVal;
  final double hypVal;
  final String baseLabel;
  final String heightLabel;
  final String hypLabel;

  SolvedTriangle({
    required this.name,
    required this.baseVal,
    required this.heightVal,
    required this.hypVal,
    required this.baseLabel,
    required this.heightLabel,
    required this.hypLabel,
  });
}

/// Holds the results of a solved Pythagoras problem.
class PythagorasResult {
  final String mode; // 'Single', 'Composite', 'Triples', or 'RealLife'
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<PythagorasStep> steps;
  final List<SolvedTriangle> drawnTriangles;
  final bool valid;
  final String? errorMessage;

  PythagorasResult({
    required this.mode,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.drawnTriangles,
    this.valid = true,
    this.errorMessage,
  });
}