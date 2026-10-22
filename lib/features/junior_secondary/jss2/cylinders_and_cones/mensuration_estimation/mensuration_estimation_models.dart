/// Represents a single pedagogical step in the 19-3 Mensuration and Estimation solver.
class MensurationEstStep {
  final String title;
  final String description;
  final String mathLaTeX;

  const MensurationEstStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Pre-configured textbook preset for instant one-tap loading.
class MensurationEstPreset {
  final String chipLabel;
  final int topicMode; // 0: Estimation by 1 s.f., 1: Rounding (s.f. & d.p.), 2: Compound Mensuration Problem
  final String expression;
  final String shapeType; // 'cylinder', 'cone', 'sphere', 'composite'
  final String dim1;
  final String dim2;
  final String dim3;
  final String unit;

  const MensurationEstPreset({
    required this.chipLabel,
    required this.topicMode,
    this.expression = '',
    this.shapeType = 'cylinder',
    this.dim1 = '',
    this.dim2 = '',
    this.dim3 = '',
    this.unit = 'cm',
  });
}

/// Holds the evaluated results, step-by-step workings, and visualizer data.
class MensurationEstResult {
  final int topicMode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<MensurationEstStep> steps;

  // Visualizer data
  final String shapeType;
  final double dim1Val;
  final double dim2Val;
  final double dim3Val;
  final String displayUnit;

  final bool valid;
  final String? errorMessage;

  const MensurationEstResult({
    required this.topicMode,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.shapeType = 'cylinder',
    this.dim1Val = 7,
    this.dim2Val = 10,
    this.dim3Val = 0,
    this.displayUnit = 'cm',
    this.valid = true,
    this.errorMessage,
  });

  factory MensurationEstResult.error({
    required int topicMode,
    required String message,
  }) {
    return MensurationEstResult(
      topicMode: topicMode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      valid: false,
      errorMessage: message,
    );
  }
}