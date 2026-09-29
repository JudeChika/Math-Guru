import 'dart:math' as math;
import 'package:math_guru/features/junior_secondary/jss2/cartesian_planes_and_coordinates/position_of_points/position_of_points_models.dart';


class PositionLogic {

  /// Formats decimals neatly, dropping trailing .0
  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// Parses inputs that might be fractions (e.g. "1 1/2" -> 1.5, "-6 1/2" -> -6.5)
  static double? _parseCoordinate(String input) {
    String s = input.trim();
    if (s.isEmpty) return null;

    try {
      if (s.contains('/')) {
        if (s.contains(RegExp(r'\s+'))) {
          // Mixed fraction
          var parts = s.split(RegExp(r'\s+'));
          double whole = double.parse(parts[0]);
          var fParts = parts[1].split('/');
          double n = double.parse(fParts[0]);
          double d = double.parse(fParts[1]);
          return whole < 0 ? whole - (n/d) : whole + (n/d);
        } else {
          // Normal fraction
          var parts = s.split('/');
          double n = double.parse(parts[0]);
          double d = double.parse(parts[1]);
          return n / d;
        }
      }
      return double.parse(s);
    } catch (e) {
      return null;
    }
  }

  static PositionResult solve1D(List<Map<String, String>> rawPoints) {
    List<Point1D> points = [];
    for (var rp in rawPoints) {
      String name = rp['name']?.trim().toUpperCase() ?? '';
      double? x = _parseCoordinate(rp['x'] ?? '');
      if (name.isNotEmpty && x != null) {
        points.add(Point1D(name: name, x: x));
      }
    }

    if (points.isEmpty) {
      return PositionResult(mode: '1D', finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Enter at least one valid point.");
    }

    List<PositionStep> steps = [];
    List<String> workings = [];
    Map<String, String> answers = {};

    workings.add("\\text{\\textbf{Plotting Points on a Number Line}}");
    workings.add("");

    for (var p in points) {
      String xStr = _fmt(p.x);
      answers["Point ${p.name}"] = xStr;
      workings.add("${p.name}($xStr)");

      String direction = p.x > 0 ? "right" : (p.x < 0 ? "left" : "nowhere");
      String desc = "To plot point ${p.name}($xStr), start at the zero mark (0). ";

      if (p.x == 0) {
        desc += "Because the value is 0, the point stays exactly at the origin.";
      } else {
        desc += "Because the number is ${p.x > 0 ? 'positive' : 'negative'}, move ${_fmt(p.x.abs())} units to the $direction.";
      }

      steps.add(PositionStep(
          title: "Plotting Point ${p.name}",
          description: desc,
          mathLaTeX: "${p.name}($xStr)"
      ));
    }

    return PositionResult(
      mode: '1D',
      points1D: points,
      finalAnswers: answers,
      workingsLaTeX: workings,
      steps: steps,
    );
  }

  static PositionResult solve2D(List<Map<String, String>> rawPoints) {
    List<Point2D> points = [];
    for (var rp in rawPoints) {
      String name = rp['name']?.trim().toUpperCase() ?? '';
      double? x = _parseCoordinate(rp['x'] ?? '');
      double? y = _parseCoordinate(rp['y'] ?? '');
      if (name.isNotEmpty && x != null && y != null) {
        points.add(Point2D(name: name, x: x, y: y));
      }
    }

    if (points.isEmpty) {
      return PositionResult(mode: '2D', finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Enter at least one valid 2D point.");
    }

    List<PositionStep> steps = [];
    List<String> workings = [];
    Map<String, String> answers = {};

    workings.add("\\text{\\textbf{Plotting on the Cartesian Plane}}");
    workings.add("");

    for (var p in points) {
      String pair = "(${_fmt(p.x)}, ${_fmt(p.y)})";
      answers["Point ${p.name}"] = pair;
      workings.add("${p.name}$pair");

      String xDir = p.x > 0 ? "right" : (p.x < 0 ? "left" : "");
      String yDir = p.y > 0 ? "up" : (p.y < 0 ? "down" : "");

      String desc = "To plot ${p.name}$pair, start at the origin (0,0). \n\n";

      desc += "1. The x-coordinate is ${_fmt(p.x)}. ";
      if (p.x == 0) {
        desc += "Stay at 0 on the horizontal x-axis. \n";
      } else {
        desc += "Move ${_fmt(p.x.abs())} units to the $xDir along the x-axis. \n";
      }

      desc += "2. The y-coordinate is ${_fmt(p.y)}. ";
      if (p.y == 0) {
        desc += "Stay there; do not move up or down. Mark the point.";
      } else {
        desc += "From there, move ${_fmt(p.y.abs())} units $yDir parallel to the y-axis. Mark the point.";
      }

      steps.add(PositionStep(
          title: "Plotting Point ${p.name}",
          description: desc,
          mathLaTeX: "${p.name}$pair"
      ));
    }

    // If exactly 4 points are given, perform Quadrilateral Analysis!
    if (points.length == 4) {
      Point2D A = points[0]; Point2D B = points[1];
      Point2D C = points[2]; Point2D D = points[3];

      workings.add("");
      workings.add("\\text{\\textbf{Geometric Analysis}}");

      // Calculate distances squared to avoid float issues
      double d2(Point2D p1, Point2D p2) => math.pow(p2.x - p1.x, 2) + math.pow(p2.y - p1.y, 2).toDouble();

      double ab = d2(A, B); double bc = d2(B, C);
      double cd = d2(C, D); double da = d2(D, A);
      double ac = d2(A, C); double bd = d2(B, D); // Diagonals

      String shape = "Quadrilateral";

      // Basic tolerance for floating point comparisons
      bool eq(double v1, double v2) => (v1 - v2).abs() < 1e-4;

      if (eq(ab, bc) && eq(bc, cd) && eq(cd, da)) {
        if (eq(ac, bd)) {
          shape = "Square";
        } else {
          shape = "Rhombus";
        }
      } else if (eq(ab, cd) && eq(bc, da)) {
        if (eq(ac, bd)) {
          shape = "Rectangle";
        } else {
          shape = "Parallelogram";
        }
      } else if ((eq(ab, bc) && eq(cd, da)) || (eq(ab, da) && eq(bc, cd))) {
        shape = "Kite";
      }

      answers["Shape Formed"] = shape;
      workings.add("\\text{Shape formed by } ${A.name}${B.name}${C.name}${D.name} \\text{ is a } \\textbf{$shape}");

      steps.add(PositionStep(
        title: "Geometry Analysis: Identify Shape",
        description: "By connecting the points ${A.name}, ${B.name}, ${C.name}, and ${D.name} in order, we can measure their side lengths and angles. The coordinates form a $shape.",
      ));

      // Calculate diagonals intersection (Midpoint)
      // For standard parallelograms/squares/rectangles, midpoints of diagonals are equal.
      double midX = (A.x + C.x) / 2;
      double midY = (A.y + C.y) / 2;

      answers["Diagonals Intersect At"] = "(${_fmt(midX)}, ${_fmt(midY)})";
      workings.add("\\text{Midpoint of diagonals} = \\left( \\frac{x_1 + x_2}{2}, \\frac{y_1 + y_2}{2} \\right)");
      workings.add("= \\left( \\frac{${_fmt(A.x)} + ${_fmt(C.x)}}{2}, \\frac{${_fmt(A.y)} + ${_fmt(C.y)}}{2} \\right)");
      workings.add("= (${_fmt(midX)}, ${_fmt(midY)})");

      steps.add(PositionStep(
          title: "Find Diagonal Intersection",
          description: "To find where the diagonals cross, we calculate the midpoint of the line connecting opposite corners (like ${A.name} and ${C.name}). We add their x-coordinates and divide by 2, then do the same for the y-coordinates.",
          mathLaTeX: "\\text{Intersection} = (${_fmt(midX)}, ${_fmt(midY)})"
      ));
    }

    return PositionResult(
      mode: '2D',
      points2D: points,
      finalAnswers: answers,
      workingsLaTeX: workings,
      steps: steps,
    );
  }
}