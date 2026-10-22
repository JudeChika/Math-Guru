/// Represents a single pedagogical step in the Scale Drawings solver.
class ScaleDrawingStep {
  final String title;
  final String description;
  final String mathLaTeX;

  const ScaleDrawingStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Pre-configured textbook preset for instant one-tap loading.
class ScaleDrawingPreset {
  final String chipLabel;
  final int mode; // 0: Elevation, 1: Depression, 2: Two-Point, 3: Reverse Angle
  final int subMode; // 0A, 0B, 1A, 1B, etc.
  final double realDistOrHeight;
  final double angleDeg;
  final double observerEyeHeight;
  final double secondAngleDeg; // For Mode 2
  final double baselineSeparation; // For Mode 2
  final String scaleStr;
  final String roundRule; // 'metre', 'half_metre', '10_cm', '5_metre', '100_metre'

  const ScaleDrawingPreset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    required this.realDistOrHeight,
    required this.angleDeg,
    this.observerEyeHeight = 0.0,
    this.secondAngleDeg = 0.0,
    this.baselineSeparation = 0.0,
    this.scaleStr = '1 cm to 2 m',
    this.roundRule = 'metre',
  });
}

/// Holds the evaluated results, step-by-step workings, and visualizer data.
class ScaleDrawingResult {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<ScaleDrawingStep> steps;

  // Visualizer / Canvas data
  final double scaleFactorCmPerUnit; // e.g., 0.5 cm per m (if 1 cm to 2 m)
  final String scaleText;
  final double realHorizontal;
  final double realVertical;
  final double realEyeHeight;
  final double angleDeg;
  final double? secondAngleDeg;
  final double? baselineSeparation;
  final String roundRule;

  final bool valid;
  final String? errorMessage;

  const ScaleDrawingResult({
    required this.mode,
    required this.subMode,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.scaleFactorCmPerUnit,
    required this.scaleText,
    required this.realHorizontal,
    required this.realVertical,
    required this.realEyeHeight,
    required this.angleDeg,
    this.secondAngleDeg,
    this.baselineSeparation,
    required this.roundRule,
    this.valid = true,
    this.errorMessage,
  });

  factory ScaleDrawingResult.error({
    required int mode,
    required int subMode,
    required String message,
  }) {
    return ScaleDrawingResult(
      mode: mode,
      subMode: subMode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      scaleFactorCmPerUnit: 1.0,
      scaleText: '',
      realHorizontal: 0,
      realVertical: 0,
      realEyeHeight: 0,
      angleDeg: 0,
      roundRule: 'metre',
      valid: false,
      errorMessage: message,
    );
  }
}
