import 'coordinates_models.dart';

class CoordinatesLogic {

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

  static CoordinateResult decodeCoordinates(List<Map<String, String>> rawPoints) {
    List<CoordinatePoint> points = [];
    for (int i = 0; i < rawPoints.length; i++) {
      var rp = rawPoints[i];
      double? x = _parseCoordinate(rp['x'] ?? '');
      double? y = _parseCoordinate(rp['y'] ?? '');
      if (x != null && y != null) {
        String name = rp['name']?.trim().toUpperCase() ?? String.fromCharCode(65 + i);
        if (name.isEmpty) name = String.fromCharCode(65 + i);
        points.add(CoordinatePoint(name: name, x: x, y: y));
      }
    }

    if (points.isEmpty) {
      return CoordinateResult(points: [], finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Enter at least one valid coordinate.");
    }

    List<CoordinateStep> steps = [];
    List<String> workings = [];
    Map<String, String> answers = {};

    workings.add("\\text{\\textbf{Understanding Ordered Pairs}}");

    steps.add(CoordinateStep(
        title: "The Ordered Pair",
        description: "Coordinates are always written as an ordered pair (x, y) separated by a comma or a semi-colon. The order is very important!",
        mathLaTeX: "(x\\text{-coordinate}, \\; y\\text{-coordinate})"
    ));

    for (var p in points) {
      String pair = "(${_fmt(p.x)}, ${_fmt(p.y)})";
      answers["Point ${p.name}"] = pair;
      workings.add("${p.name}$pair");

      String explanation = "For point ${p.name}$pair:\n\n";

      // X-Coordinate explanation
      explanation += "• The first number (${_fmt(p.x)}) is the x-coordinate. It gives the distance of the point along the horizontal x-axis. ";
      if (p.x == 0) {
        explanation += "Because the x-coordinate is 0, the point does not move left or right. It sits perfectly on the y-axis.\n";
      } else {
        explanation += "We move ${_fmt(p.x.abs())} units to the ${p.x > 0 ? 'right' : 'left'} of the Origin (O).\n";
      }

      // Y-Coordinate explanation
      explanation += "• The second number (${_fmt(p.y)}) is the y-coordinate. It gives the distance of the point along the vertical y-axis. ";
      if (p.y == 0) {
        explanation += "Because the y-coordinate is 0, the point does not move up or down. It sits perfectly on the x-axis.";
      } else {
        explanation += "We move ${_fmt(p.y.abs())} units ${p.y > 0 ? 'up' : 'down'} parallel to the y-axis.";
      }

      steps.add(CoordinateStep(
          title: "Decoding Point ${p.name}",
          description: explanation,
          mathLaTeX: "\\text{x} = ${_fmt(p.x)}, \\quad \\text{y} = ${_fmt(p.y)}"
      ));
    }

    return CoordinateResult(
      points: points,
      finalAnswers: answers,
      workingsLaTeX: workings,
      steps: steps,
    );
  }
}