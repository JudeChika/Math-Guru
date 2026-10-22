import 'package:flutter/material.dart';

/// Represents a single pedagogical step in the 23-1 Linear Equations and Graphs solver.
class LinearEqGraphStep {
  final String title;
  final String description;
  final String mathLaTeX;

  const LinearEqGraphStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Represents a single plotted coordinate on the Cartesian plane.
class PlottedPointData {
  final double x;
  final double y;
  final String label; // e.g. "(-3;-19)" or "A(-3;-5)"
  final bool isErrorPoint; // true if student plotted wrongly (Mode 2A)
  final double? correctedY;

  const PlottedPointData({
    required this.x,
    required this.y,
    required this.label,
    this.isErrorPoint = false,
    this.correctedY,
  });
}

/// Represents a straight line to be drawn on the 4-Quadrant Cartesian Graph Paper.
class LineSeriesData {
  final String equationLabel;
  final double a; // ax + by + c = 0
  final double b;
  final double c;
  final List<PlottedPointData> points;
  final Color color;

  const LineSeriesData({
    required this.equationLabel,
    required this.a,
    required this.b,
    required this.c,
    required this.points,
    required this.color,
  });

  bool get isVertical => b.abs() < 1e-9;
  bool get isHorizontal => a.abs() < 1e-9;

  double evaluateY(double xVal) {
    if (isVertical) return 0.0;
    return (-a * xVal - c) / b;
  }

  double evaluateX(double yVal) {
    if (isHorizontal) return 0.0;
    return (-b * yVal - c) / a;
  }
}

/// Represents a dotted graphical trace arrow (like 'a' and 'b' in Figure 23.2).
class GraphTraceQuery {
  final String markerLabel; // 'a' or 'b'
  final bool givenX; // true: trace from x-axis to y-axis; false: trace from y-axis to x-axis
  final double xVal;
  final double yVal;

  const GraphTraceQuery({
    required this.markerLabel,
    required this.givenX,
    required this.xVal,
    required this.yVal,
  });
}

/// Encapsulates all visual parameters for the 4-Quadrant Cartesian Graph Paper painter.
class CartesianCanvasData {
  final List<LineSeriesData> lines;
  final List<GraphTraceQuery> traces;
  final PlottedPointData? xIntercept;
  final PlottedPointData? yIntercept;
  final PlottedPointData? intersectionPoint;
  final double scaleXUnitsPer2Cm; // e.g., 1 unit per 2 cm (or 2 units per 2 cm)
  final double scaleYUnitsPer2Cm; // e.g., 5 units per 2 cm
  final String scaleBannerText;
  final String headerBadge;

  const CartesianCanvasData({
    this.lines = const [],
    this.traces = const [],
    this.xIntercept,
    this.yIntercept,
    this.intersectionPoint,
    this.scaleXUnitsPer2Cm = 1.0,
    this.scaleYUnitsPer2Cm = 5.0,
    this.scaleBannerText = 'Scale: 2 cm to 1 unit on x-axis; 2 cm to 5 units on y-axis',
    this.headerBadge = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across all 4 modes.
class LinearEqGraphPreset {
  final String chipLabel;
  final int mode;
  // 0: Explicit Equation y = mx + c (Tables 23.1, 23.2, 23.4, 23.5, Example 1, Ex 23a #2–4)
  // 1: General Form ax + by + c = 0 (Example 2, Table 23.6, Fig 23.4, Ex 23b #1–10)
  // 2: Point Inspector & Missing Coordinates (Ex 23a #1 / Fig 23.3 & Ex 23a #5)
  // 3: Multi-Line Comparator (Ex 23a #6 Parallel, #7 Common Intercept, #8 Intersection)

  final int subMode; // For Mode 2: 0 = Spot Wrong Point (Ex 23a #1), 1 = Find a,b,c (Ex 23a #5)
  final String equationStr;
  final String xValuesCsv; // e.g. "-3, -2, -1, 0, 1, 2, 3" or "-2, 0, 2"
  final String queryXStr; // Find y when x = ...
  final String queryYStr; // Find x when y = ...
  final String scaleXStr; // Units per 2 cm on x-axis
  final String scaleYStr; // Units per 2 cm on y-axis

  // Mode 2 fields
  final String pointAStr;
  final String pointBStr;
  final String pointCStr;

  // Mode 3 fields
  final List<String> multiEquations;

  const LinearEqGraphPreset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    this.equationStr = 'y = 4x - 7',
    this.xValuesCsv = '-3, -2, -1, 0, 1, 2, 3',
    this.queryXStr = '',
    this.queryYStr = '',
    this.scaleXStr = '1',
    this.scaleYStr = '5',
    this.pointAStr = '-3;-5',
    this.pointBStr = '-1;1',
    this.pointCStr = '3;5',
    this.multiEquations = const [],
  });
}

/// Holds the complete evaluated results, workings, steps, and 4-quadrant graph data.
class LinearEqGraphResult {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<LinearEqGraphStep> steps;
  final CartesianCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const LinearEqGraphResult({
    required this.mode,
    this.subMode = 0,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory LinearEqGraphResult.error({
    required int mode,
    int subMode = 0,
    required String message,
  }) {
    return LinearEqGraphResult(
      mode: mode,
      subMode: subMode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const CartesianCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}