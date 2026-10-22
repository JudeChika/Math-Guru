/// Represents a single pedagogical step in the 19-2 Cones solver.
class ConeStep {
  final String title;
  final String description;
  final String mathLaTeX;

  const ConeStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Configuration for the chosen representation of Pi (including symbolic "In terms of π").
class ConePiConfig {
  final String text; // e.g., "In terms of π", "22/7", "3.14", "3", "3.1"
  final String latex; // e.g., "\\pi", "\\frac{22}{7}", "3.14", "3", "3.1"
  final double value;
  final bool isSymbolic;

  const ConePiConfig({
    required this.text,
    required this.latex,
    required this.value,
    this.isSymbolic = false,
  });
}

/// Holds the evaluated results, step-by-step workings, and custom canvas data for a Cone problem.
class ConeResult {
  final int mode; // 0: SA & Pythagoras, 1: Sector Net, 2: Volume & Mass, 3: Composite, 4: Comparison & Reverse
  final int subMode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<ConeStep> steps;

  // Visualizer dimensions
  final double r;
  final double h;
  final double l;
  final double thetaDeg;
  final double? h2; // Second cone height or cylinder height for composite/comparison modes
  final String displayUnit;

  final bool valid;
  final String? errorMessage;

  const ConeResult({
    required this.mode,
    required this.subMode,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.r = 5,
    this.h = 12,
    this.l = 13,
    this.thetaDeg = 138.5,
    this.h2,
    this.displayUnit = 'cm',
    this.valid = true,
    this.errorMessage,
  });

  factory ConeResult.error({
    required int mode,
    required int subMode,
    required String message,
  }) {
    return ConeResult(
      mode: mode,
      subMode: subMode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      valid: false,
      errorMessage: message,
    );
  }
}