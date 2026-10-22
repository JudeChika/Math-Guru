import 'package:flutter/material.dart';

/// Represents a single pedagogical step in the Properties of Linear Graphs solver.
class LinearGraphPropStep {
  final String title;
  final String description;
  final String mathLaTeX;

  const LinearGraphPropStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Represents a plotted point or intercept marker on the Cartesian plane.
class PropPlottedPoint {
  final double x;
  final double y;
  final String label;
  final bool isIntercept;

  const PropPlottedPoint({
    required this.x,
    required this.y,
    required this.label,
    this.isIntercept = false,
  });
}

/// Represents a straight line series to be drawn on the 4-Quadrant Cartesian Graph Paper.
class PropLineSeries {
  final String equationLabel;
  final double a; // ax + by + c = 0
  final double b;
  final double c;
  final List<PropPlottedPoint> points;
  final Color color;
  final bool isDashed;

  const PropLineSeries({
    required this.equationLabel,
    required this.a,
    required this.b,
    required this.c,
    this.points = const [],
    required this.color,
    this.isDashed = false,
  });

  bool get isVertical => b.abs() < 1e-9;
  bool get isHorizontal => a.abs() < 1e-9;

  double evaluateY(double xVal) => isVertical ? 0.0 : (-a * xVal - c) / b;
  double evaluateX(double yVal) => isHorizontal ? 0.0 : (-b * yVal - c) / a;
}

/// Encapsulates all visual parameters for the 4-Quadrant Cartesian Graph Paper painter.
class PropCartesianCanvasData {
  final List<PropLineSeries> lines;
  final List<PropPlottedPoint> highlightIntercepts;
  final double scaleXUnitsPer2Cm;
  final double scaleYUnitsPer2Cm;
  final String scaleBannerText;
  final String headerBadge;

  const PropCartesianCanvasData({
    this.lines = const [],
    this.highlightIntercepts = const [],
    this.scaleXUnitsPer2Cm = 1.0,
    this.scaleYUnitsPer2Cm = 5.0,
    this.scaleBannerText =
    'Scale: 2 cm to 1 unit on x-axis; 2 cm to 5 units on y-axis',
    this.headerBadge = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across all 4 modes.
class LinearGraphPropPreset {
  final String chipLabel;
  final int mode;
  // 0: Coefficient of x, x- & y-Intercepts & Parallel Through Origin (Table 23.7, Ex 4, Ex 23c #1, #5, #7, #9)
  // 1: Parallel vs. Non-Parallel Line Generator (Ex 23c #2, #3, #4)
  // 2: Multi-Line Parallel Detector & Family Relationship (Fig 23.5, Ex 3, Ex 23c #6, #8)
  // 3: Reverse Graph Reader — Find Equation from 2 Points / Intercepts (Ex 23c #10 / Fig 23.6)

  final int subMode; // For Mode 1: 0 = Write Parallel Lines, 1 = Write Non-Parallel Lines; For Mode 3: 0 = 1 Line, 1 = 2 Lines (M & N)
  final String equationStr;
  final String xValuesCsv;
  final bool drawParallelOrigin;
  final String scaleXStr;
  final String scaleYStr;

  // Mode 2 fields (up to 4 equations)
  final List<String> multiEquations;

  // Mode 3 fields (Line M & Line N coordinates)
  final String line1Name;
  final String line1Pt1;
  final String line1Pt2;
  final String line2Name;
  final String line2Pt1;
  final String line2Pt2;

  const LinearGraphPropPreset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    this.equationStr = 'y = 4x - 9',
    this.xValuesCsv = '-2, -1, 0, 1, 2, 3, 4',
    this.drawParallelOrigin = false,
    this.scaleXStr = '1',
    this.scaleYStr = '5',
    this.multiEquations = const [],
    this.line1Name = 'Line M',
    this.line1Pt1 = '0;0',
    this.line1Pt2 = '2;2',
    this.line2Name = 'Line N',
    this.line2Pt1 = '0;3',
    this.line2Pt2 = '2;0',
  });
}

/// Holds the complete evaluated results, workings, steps, and 4-quadrant graph data.
class LinearGraphPropResult {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<LinearGraphPropStep> steps;
  final PropCartesianCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const LinearGraphPropResult({
    required this.mode,
    this.subMode = 0,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory LinearGraphPropResult.error({
    required int mode,
    int subMode = 0,
    required String message,
  }) {
    return LinearGraphPropResult(
      mode: mode,
      subMode: subMode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const PropCartesianCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}