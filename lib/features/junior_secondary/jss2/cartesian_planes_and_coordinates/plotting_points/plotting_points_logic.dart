import 'plotting_points_models.dart';

class PlottingPointsLogic {

  /// Formats decimals neatly, dropping trailing .0
  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// Parses inputs that might be fractions (e.g. "1 1/2" -> 1.5)
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

  static PlottingResult plotPoints(List<Map<String, String>> rawPoints) {
    List<PlotPoint> points = [];
    for (int i = 0; i < rawPoints.length; i++) {
      var rp = rawPoints[i];
      double? x = _parseCoordinate(rp['x'] ?? '');
      double? y = _parseCoordinate(rp['y'] ?? '');
      if (x != null && y != null) {
        String name = rp['name']?.trim().toUpperCase() ?? String.fromCharCode(65 + i);
        if (name.isEmpty) name = String.fromCharCode(65 + i);
        points.add(PlotPoint(name: name, x: x, y: y));
      }
    }

    if (points.isEmpty) {
      return PlottingResult(points: [], finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Enter at least one valid coordinate.");
    }

    List<PlottingStep> steps = [];
    List<String> workings = [];
    Map<String, String> answers = {};

    workings.add("\\text{\\textbf{Rules for Plotting Points}}");
    workings.add("\\text{1. Start at the origin (0, 0)}");
    workings.add("\\text{2. Move along the x-axis}");
    workings.add("\\text{3. Move parallel to the y-axis}");
    workings.add("\\text{4. Plot with a small vertical cross (+)}");
    workings.add("");

    for (var p in points) {
      String pair = "(${_fmt(p.x)}; ${_fmt(p.y)})"; // Using semi-colon as sometimes seen in textbooks for decimal clarity
      answers["Point ${p.name}"] = pair;
      workings.add("\\text{Plotting } ${p.name}$pair");

      String explanation = "For ${p.name}$pair:\n";
      explanation += "a) Start at the origin (O).\n";

      // X-Coordinate explanation
      explanation += "b) The x-coordinate is ${_fmt(p.x)}. ";
      if (p.x == 0) {
        explanation += "Stay exactly at the origin on the horizontal x-axis.\n";
      } else {
        explanation += "Move ${_fmt(p.x.abs())} unit(s) to the ${p.x > 0 ? 'right' : 'left'} along the x-axis.\n";
      }

      // Y-Coordinate explanation
      explanation += "c) The y-coordinate is ${_fmt(p.y)}. ";
      if (p.y == 0) {
        explanation += "Do not move up or down. Stay exactly on the x-axis.\n";
      } else {
        explanation += "From there, move ${_fmt(p.y.abs())} unit(s) ${p.y > 0 ? 'up' : 'down'} parallel to the y-axis.\n";
      }

      explanation += "d) Plot the point with a small vertical cross (+).";

      steps.add(PlottingStep(
          title: "Plotting Point ${p.name}",
          description: explanation,
          mathLaTeX: "${p.name}(${_fmt(p.x)}, ${_fmt(p.y)})"
      ));
    }

    return PlottingResult(
      points: points,
      finalAnswers: answers,
      workingsLaTeX: workings,
      steps: steps,
    );
  }
}