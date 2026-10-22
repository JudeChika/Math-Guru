/// Represents a single pedagogical step in the Compass Directions solver.
class CompassDirectionStep {
  final String title;
  final String description;
  final String mathLaTeX;

  const CompassDirectionStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Metadata for a standard 8-point or 16-point compass direction.
class CompassPointInfo {
  final String code; // e.g., "N", "NE", "E", "SE", "S", "SW", "W", "NW"
  final String fullName; // e.g., "North", "North-East"
  final double angleDeg; // Clockwise angle from North (0° to 360°)
  final bool isMainCardinal; // true for N, E, S, W

  const CompassPointInfo({
    required this.code,
    required this.fullName,
    required this.angleDeg,
    this.isMainCardinal = false,
  });
}

/// Encapsulates all visual parameters for the 8-Point Magnetic Compass Rose & Two-Point Bearing Painter.
class CompassCanvasData {
  final int mode;
  // 0: Turning from a Starting Direction (Ex 24a #1)
  // 1: Angle Between Two Directions (Ex 24a #2)
  // 2: Relative Two-Point Compass Bearing B from A & A from B (Fig 24.5 / Ex 24b)
  // 3: Sunrise, Sunset & Body Orientation Explorer (Fig 24.1 & 24.3)

  final double startAngleDeg;
  final String startLabel;
  final double endAngleDeg;
  final String endLabel;

  /// Signed turn angle in degrees (+ for clockwise/right, - for anticlockwise/left)
  final double turnSweepDeg;

  /// Optional second turn sweep for multi-step turns
  final double? secondTurnSweepDeg;
  final double? finalAfterSecondTurnDeg;
  final String? finalAfterSecondLabel;

  /// For Mode 2 (Two-Point Compass Bearing diagram like Figure 24.5)
  final String pointAName;
  final String pointBName;
  final String dirBFromACode;
  final String dirAFromBCode;

  final String headerBadge;
  final String subBadge;

  const CompassCanvasData({
    this.mode = 0,
    this.startAngleDeg = 90.0,
    this.startLabel = 'E (90°)',
    this.endAngleDeg = 180.0,
    this.endLabel = 'S (180°)',
    this.turnSweepDeg = 90.0,
    this.secondTurnSweepDeg,
    this.finalAfterSecondTurnDeg,
    this.finalAfterSecondLabel,
    this.pointAName = 'A',
    this.pointBName = 'B',
    this.dirBFromACode = 'NW',
    this.dirAFromBCode = 'SE',
    this.headerBadge = '',
    this.subBadge = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across all 4 modes.
class CompassDirectionPreset {
  final String chipLabel;
  final int mode;
  final String startDir;
  final bool turnClockwise; // true: Right (Clockwise), false: Left (Anticlockwise)
  final String turnAngleStr;
  final String secondTurnAngleStr;
  final bool secondTurnClockwise;
  final String secondDir; // Used in Mode 1 (Angle between two directions)
  final String pointAName; // Used in Mode 2 (Figure 24.5)
  final String pointBName;
  final String dirBFromA;

  const CompassDirectionPreset({
    required this.chipLabel,
    required this.mode,
    this.startDir = '',
    this.turnClockwise = true,
    this.turnAngleStr = '',
    this.secondTurnAngleStr = '',
    this.secondTurnClockwise = true,
    this.secondDir = '',
    this.pointAName = 'A',
    this.pointBName = 'B',
    this.dirBFromA = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and compass canvas data.
class CompassDirectionResult {
  final int mode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<CompassDirectionStep> steps;
  final CompassCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const CompassDirectionResult({
    required this.mode,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory CompassDirectionResult.error({
    required int mode,
    required String message,
  }) {
    return CompassDirectionResult(
      mode: mode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const CompassCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}