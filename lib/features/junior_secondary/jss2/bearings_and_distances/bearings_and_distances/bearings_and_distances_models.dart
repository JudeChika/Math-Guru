import 'package:flutter/material.dart';

/// Represents a single pedagogical step in the Bearings & Distances solver.
class BearingDistanceStep {
  final String title;
  final String description;
  final String mathLaTeX;

  const BearingDistanceStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Raw user input for a single surveyed landmark from central point P in Mode 2.
class SurveyLandmarkInput {
  final String label; // e.g., "A", "B", "C", "Tree", "Water Tower"
  final String bearingStr; // e.g., "030°", "070°", "118°", "East"
  final String distanceStr; // e.g., "18", "30", "15"

  const SurveyLandmarkInput({
    required this.label,
    required this.bearingStr,
    required this.distanceStr,
  });
}

/// Evaluated landmark coordinate on the scale drawing (in cm and real units) for Mode 2.
class EvaluatedSurveyPoint {
  final String label;
  final double bearingDeg;
  final String bearingFormatted;
  final double realDist;
  final double paperDistCm;
  final double xCm; // East-West offset from P in cm (+East, -West)
  final double yCm; // North-South offset from P in cm (+North, -South)
  final Color color;

  const EvaluatedSurveyPoint({
    required this.label,
    required this.bearingDeg,
    required this.bearingFormatted,
    required this.realDist,
    required this.paperDistCm,
    required this.xCm,
    required this.yCm,
    required this.color,
  });
}

/// Encapsulates all visual parameters for the Millimetre Graph Paper & Surveyor Painter.
class BearingsDistancesCanvasData {
  final int mode;
  // 0: Multi-Leg Journey Scale Drawing (A -> B -> C) (Figs 24.28 & 24.29)
  // 1: N/S & E/W Components Right-Angled Triangle (Fig 24.30 & Ex 24g #6-8)
  // 2: Radial Polar Survey from Point P (Figs 24.22-24.24, 24.26, 24.27)
  // 3: Two-Point Bearing Intersection / River Width Triangulation (Fig 24.25 & Rev Test 24 #8)

  final int subMode;
  final String unit; // 'km' or 'm'
  final double scaleUnitsPerCm; // e.g., 20 km per 1 cm
  final String scaleBannerText; // e.g., "Scale: 1 cm represents 20 km"

  // Mode 0 & Mode 1 coordinates in paper cm (relative to Start Point A / L at (0,0))
  final String pt1Name;
  final String pt2Name;
  final String pt3Name;
  final Offset pt1Cm; // (0, 0)
  final Offset pt2Cm; // (xB, yB) or K(0, yK)
  final Offset pt3Cm; // (xC, yC) or I(xI, yI)

  final double leg1BearingDeg;
  final String leg1BearingLabel;
  final double leg1RealDist;
  final double leg1PaperCm;

  final double leg2BearingDeg;
  final String leg2BearingLabel;
  final double leg2RealDist;
  final double leg2PaperCm;

  final double resultantBearingDeg;
  final String resultantBearingLabel;
  final double resultantRealDist;
  final double resultantPaperCm;

  // Mode 2 (Radial Survey from P)
  final String centerPointName;
  final List<EvaluatedSurveyPoint> surveyPoints;
  final int targetIdx1;
  final int targetIdx2;
  final Offset? perpFootCm; // Foot of perpendicular from 3rd point to line 1-2
  final double? perpPaperCm;
  final double? perpRealDist;

  final String headerBadge;
  final String subBadge;

  const BearingsDistancesCanvasData({
    this.mode = 0,
    this.subMode = 0,
    this.unit = 'km',
    this.scaleUnitsPerCm = 1.0,
    this.scaleBannerText = 'Scale: 1 cm to 1 km',
    this.pt1Name = 'A',
    this.pt2Name = 'B',
    this.pt3Name = 'C',
    this.pt1Cm = Offset.zero,
    this.pt2Cm = const Offset(3, 0),
    this.pt3Cm = const Offset(5.3, -4.4),
    this.leg1BearingDeg = 90.0,
    this.leg1BearingLabel = '090°',
    this.leg1RealDist = 3.0,
    this.leg1PaperCm = 3.0,
    this.leg2BearingDeg = 152.0,
    this.leg2BearingLabel = '152°',
    this.leg2RealDist = 5.0,
    this.leg2PaperCm = 5.0,
    this.resultantBearingDeg = 130.0,
    this.resultantBearingLabel = '130°',
    this.resultantRealDist = 6.9,
    this.resultantPaperCm = 6.9,
    this.centerPointName = 'P',
    this.surveyPoints = const [],
    this.targetIdx1 = 0,
    this.targetIdx2 = 1,
    this.perpFootCm,
    this.perpPaperCm,
    this.perpRealDist,
    this.headerBadge = '',
    this.subBadge = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across all 4 modes.
class BearingDistancePreset {
  final String chipLabel;
  final int mode;
  final int subMode;
  final String unit;
  final String scaleStr;

  // Mode 0, 1, 3 fields
  final String pt1Name;
  final String pt2Name;
  final String pt3Name;
  final String dist1Str;
  final String bearing1Str;
  final String dist2Str;
  final String bearing2Str;

  // Mode 2 fields (Radial Polar Survey from P)
  final String centerPointName;
  final List<SurveyLandmarkInput> landmarks;
  final int pairIdx1;
  final int pairIdx2;

  const BearingDistancePreset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    this.unit = 'km',
    this.scaleStr = '1',
    this.pt1Name = 'A',
    this.pt2Name = 'B',
    this.pt3Name = 'C',
    this.dist1Str = '',
    this.bearing1Str = '',
    this.dist2Str = '',
    this.bearing2Str = '',
    this.centerPointName = 'P',
    this.landmarks = const [],
    this.pairIdx1 = 0,
    this.pairIdx2 = 1,
  });
}

/// Holds the complete evaluated results, workings, steps, and canvas data.
class BearingsDistancesResult {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<BearingDistanceStep> steps;
  final BearingsDistancesCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const BearingsDistancesResult({
    required this.mode,
    this.subMode = 0,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory BearingsDistancesResult.error({
    required int mode,
    int subMode = 0,
    required String message,
  }) {
    return BearingsDistancesResult(
      mode: mode,
      subMode: subMode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const BearingsDistancesCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}