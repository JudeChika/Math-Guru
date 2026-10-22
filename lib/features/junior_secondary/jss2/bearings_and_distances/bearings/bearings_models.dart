import 'package:flutter/material.dart';

/// Represents a single pedagogical step in the Bearings solver.
class BearingStep {
  final String title;
  final String description;
  final String mathLaTeX;

  const BearingStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Raw user input for a single ray in Mode 2 (Multi-Ray Bearings from a Central Point).
class MultiRayInput {
  final String pointLabel; // e.g., "A", "B", "C", "D" or "U", "V", "X", "Y", "Z"
  final String givenAngleStr; // e.g., "63", "35", "75", "52", "83"
  final String referenceType;
  // 'E_of_N': Clockwise from N (0° + θ)
  // 'E_of_S': Anticlockwise from S / East of South (180° - θ)
  // 'W_of_S': Clockwise from S / West of South (180° + θ)
  // 'W_of_N': Anticlockwise from N / West of North (360° - θ)
  // 'N_of_E': Anticlockwise from E / North of East (90° - θ)
  // 'S_of_E': Clockwise from E / South of East (90° + θ)
  // 'S_of_W': Anticlockwise from W / South of West (270° - θ)
  // 'N_of_W': Clockwise from W / North of West (270° + θ)
  // 'CW_from_Prev': Clockwise from Previous Ray (e.g., Fig 24.20 ∠UOV = 83°)

  const MultiRayInput({
    required this.pointLabel,
    required this.givenAngleStr,
    this.referenceType = 'E_of_N',
  });
}

/// Evaluated ray item for the Mode 2 Multi-Ray Star Visualizer.
class EvaluatedRayItem {
  final String pointLabel;
  final double givenAngleDeg;
  final String referenceLabel;
  final double threeFigDeg;
  final String threeFigFormatted; // e.g., "063°"
  final String acuteBearingFormatted; // e.g., "N63°E"
  final Color color;

  const EvaluatedRayItem({
    required this.pointLabel,
    required this.givenAngleDeg,
    required this.referenceLabel,
    required this.threeFigDeg,
    required this.threeFigFormatted,
    required this.acuteBearingFormatted,
    required this.color,
  });
}

/// Encapsulates all visual parameters for the Bearings CustomPaint canvas.
class BearingsCanvasData {
  final int mode;
  // 0: Acute-Angle Bearing <-> Three-Figure Bearing (Figs 24.8–24.10)
  // 1: Single-Ray Sketch Solver (Fig 24.18 / Ex 24e #1)
  // 2: Multi-Ray Bearings from Central Point (Figs 24.14, 24.19, 24.20)
  // 3: Parallel North Lines & Back Bearings (Figs 24.16, 24.17, 24.21)

  final String fromPointName;
  final String toPointName;

  /// Clockwise angle from North (0° to 360°) for Modes 0, 1, and 3
  final double threeFigAngleDeg;
  final String threeFigLabel; // e.g., "246°" or "037°"

  /// Acute angle with North or South (0° to 90°) for Modes 0, 1, and 3
  final double acuteAngleWithNS;
  final bool acuteIsFromNorth; // true: measured from N, false: measured from S
  final bool acuteIsTowardsEast; // true: towards E, false: towards W
  final String acuteBearingLabel; // e.g., "N37°E" or "S66°W"

  /// Optional complement angle if the diagram gave the angle with East or West (Fig 24.10 #4, #6, #7, #8)
  final double? givenAngleWithEW;
  final String? givenEWLabel;

  /// For Mode 2 (Multi-Ray Star Diagram)
  final String centerPointName;
  final List<EvaluatedRayItem> rays;

  /// For Mode 3 (Back Bearings / Parallel North Lines N₁ || N₂)
  final double backBearingDeg;
  final String backBearingThreeFigLabel; // e.g., "067°"
  final String backBearingAcuteLabel; // e.g., "N67°E"
  final double alternateAcuteDeg; // The z-angle between parallel North/South lines

  final String headerBadge;
  final String subBadge;

  const BearingsCanvasData({
    this.mode = 0,
    this.fromPointName = 'A',
    this.toPointName = 'B',
    this.threeFigAngleDeg = 37.0,
    this.threeFigLabel = '037°',
    this.acuteAngleWithNS = 37.0,
    this.acuteIsFromNorth = true,
    this.acuteIsTowardsEast = true,
    this.acuteBearingLabel = 'N37°E',
    this.givenAngleWithEW,
    this.givenEWLabel,
    this.centerPointName = 'X',
    this.rays = const [],
    this.backBearingDeg = 217.0,
    this.backBearingThreeFigLabel = '217°',
    this.backBearingAcuteLabel = 'S37°W',
    this.alternateAcuteDeg = 37.0,
    this.headerBadge = '',
    this.subBadge = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across all 4 modes.
class BearingPreset {
  final String chipLabel;
  final int mode;
  final int subMode;

  // Mode 0 & Mode 1 fields
  final String fromPoint;
  final String toPoint;
  final String bearingInputStr; // For Mode 0 SubMode 0 (e.g. "N37°E", "S66°W", "246°")
  final String quadrantCode; // For Mode 0 SubMode 1 ('NE', 'SE', 'SW', 'NW')
  final bool measuredFromNS; // true: from N/S, false: from E/W (Fig 24.10 #4,6,7,8)
  final String sketchRefType; // For Mode 1 (Ex 24e #1a–h)
  final String givenAngleStr;

  // Mode 2 fields (Multi-Ray)
  final String centerPoint;
  final List<MultiRayInput> multiRays;

  // Mode 3 fields (Back Bearings — Example 2 & Ex 24e #5a–g)
  final String point1Name;
  final String point2Name;
  final int backGivenType;
  // 0: 3-Figure Bearing of Point 1 from Point 2 (e.g. X from Y = 247°, or A from B = 250° in Fig 24.21a,b)
  // 1: 3-Figure Bearing of Point 2 from Point 1 (e.g. B from A = 195° in Fig 24.21g)
  // 2: Interior Acute Angle at Point 2 between North and Ray (e.g. 57° East of N in Fig 24.21c)
  // 3: Anticlockwise Reflex Angle at Point 2 from North to Ray (e.g. 319° in Fig 24.21f)
  // 4: Cardinal Alignment (0° Due North, 90° Due East, 180° Due South, 270° Due West — Fig 24.21d,e)

  const BearingPreset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    this.fromPoint = 'A',
    this.toPoint = 'B',
    this.bearingInputStr = '',
    this.quadrantCode = 'NE',
    this.measuredFromNS = true,
    this.sketchRefType = 'CW_N',
    this.givenAngleStr = '',
    this.centerPoint = 'X',
    this.multiRays = const [],
    this.point1Name = 'A',
    this.point2Name = 'B',
    this.backGivenType = 0,
  });
}

/// Holds the complete evaluated results, workings, steps, and canvas data.
class BearingsResult {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<BearingStep> steps;
  final BearingsCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const BearingsResult({
    required this.mode,
    this.subMode = 0,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory BearingsResult.error({
    required int mode,
    int subMode = 0,
    required String message,
  }) {
    return BearingsResult(
      mode: mode,
      subMode: subMode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const BearingsCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}