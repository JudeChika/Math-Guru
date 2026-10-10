import 'dart:math' as math;
import 'construct_triangles_models.dart';

class ConstructTrianglesLogic {

  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }

  static double _degToRad(double deg) => deg * math.pi / 180.0;
  static double _radToDeg(double rad) => rad * 180.0 / math.pi;

  /// Calculates distance between two points
  static double _distance(TrianglePoint p1, TrianglePoint p2) {
    return math.sqrt(math.pow(p2.x - p1.x, 2) + math.pow(p2.y - p1.y, 2));
  }

  /// Calculates angle of a point relative to a center vertex (using cosine rule)
  static double _calcAngle(double a, double b, double c) {
    // Cosine rule: c^2 = a^2 + b^2 - 2ab cos(C)
    // cos(C) = (a^2 + b^2 - c^2) / 2ab
    double cosC = (a * a + b * b - c * c) / (2 * a * b);
    return _radToDeg(math.acos(cosC));
  }

  // ==========================================
  // MODE 1: SAS (Side-Angle-Side)
  // ==========================================
  static TriangleConstructionResult solveSAS({
    required String baseName, required double baseLen,
    required String angleVertex, required double angleDeg,
    required String side2Name, required double side2Len,
  }) {
    try {
      if (baseLen <= 0 || side2Len <= 0 || angleDeg <= 0 || angleDeg >= 180) {
        throw const FormatException("Invalid lengths or angle.");
      }

      baseName = baseName.toUpperCase();
      angleVertex = angleVertex.toUpperCase();
      side2Name = side2Name.toUpperCase();

      if (baseName.length != 2) throw const FormatException("Base name must be 2 letters (e.g., BC).");

      String v1Name = baseName[0];
      String v2Name = baseName[1];

      if (angleVertex != v1Name && angleVertex != v2Name) {
        throw const FormatException("Angle vertex must be one of the base letters.");
      }

      // Determine the 3rd letter
      String v3Name = side2Name.replaceAll(v1Name, '').replaceAll(v2Name, '');
      if (v3Name.isEmpty || v3Name.length != 1) v3Name = "X"; // Fallback

      TrianglePoint p1 = TrianglePoint(name: v1Name, x: 0, y: 0);
      TrianglePoint p2 = TrianglePoint(name: v2Name, x: baseLen, y: 0);
      TrianglePoint p3;

      // Calculate 3rd point using Trigonometry
      if (angleVertex == v1Name) {
        double rad = _degToRad(angleDeg);
        p3 = TrianglePoint(name: v3Name, x: side2Len * math.cos(rad), y: side2Len * math.sin(rad));
      } else {
        // Angle is at V2. Line goes backwards from V2.
        double rad = _degToRad(180 - angleDeg);
        p3 = TrianglePoint(name: v3Name, x: baseLen + side2Len * math.cos(rad), y: side2Len * math.sin(rad));
      }

      double missingSideLen = _distance(angleVertex == v1Name ? p2 : p1, p3);
      String missingSideStart = angleVertex == v1Name ? v2Name : v1Name;
      String missingSideName = "$missingSideStart$v3Name";

      List<ConstructionStep> steps = [
        ConstructionStep(
            title: "Step 1: Draw the base line",
            description: "Use a ruler to draw a straight horizontal line $baseName exactly ${_fmt(baseLen)} cm long.",
            mathLaTeX: "\\text{Line } $baseName = ${_fmt(baseLen)}\\text{ cm}"
        ),
        ConstructionStep(
            title: "Step 2: Measure the angle",
            description: "Place the center of your protractor exactly over point $angleVertex. Mark a dot at exactly ${_fmt(angleDeg)}°.",
            mathLaTeX: "\\angle $angleVertex = ${_fmt(angleDeg)}^\\circ"
        ),
        ConstructionStep(
            title: "Step 3: Draw the second side",
            description: "Use your ruler to draw a line from $angleVertex through the dot you made. Measure exactly ${_fmt(side2Len)} cm along this line and mark point $v3Name.",
            mathLaTeX: "\\text{Line } $angleVertex$v3Name = ${_fmt(side2Len)}\\text{ cm}"
        ),
        ConstructionStep(
            title: "Step 4: Complete the triangle",
            description: "Join the final point $v3Name to the other end of the base to complete triangle $v3Name$baseName.",
            mathLaTeX: "\\text{Join to form } \\Delta $v3Name$baseName"
        ),
        ConstructionStep(
            title: "Step 5: Measure the missing side",
            description: "Place the zero mark of your ruler at point $missingSideStart and physically measure the straight distance to the newly found point $v3Name to complete the exercise.",
            mathLaTeX: "\\text{Measure line } $missingSideName"
        ),
      ];

      return TriangleConstructionResult(
        mode: "SAS",
        vertices: [p1, p2, p3],
        measurements: {
          "Missing Side ($missingSideName)": "${_fmt(missingSideLen)} cm"
        },
        steps: steps,
      );
    } catch (e) {
      return TriangleConstructionResult(mode: "SAS", vertices: [], measurements: {}, steps: [], valid: false, errorMessage: e is FormatException ? e.message : "Invalid input parameters.");
    }
  }

  // ==========================================
  // MODE 2: ASA (Angle-Side-Angle)
  // ==========================================
  static TriangleConstructionResult solveASA({
    required String baseName, required double baseLen,
    required double angle1Deg, required double angle2Deg,
    required String topVertexName,
  }) {
    try {
      if (baseLen <= 0 || angle1Deg <= 0 || angle2Deg <= 0) throw const FormatException("Values must be positive.");
      if (angle1Deg + angle2Deg >= 180) throw const FormatException("Angles must sum to less than 180°.");

      baseName = baseName.toUpperCase();
      if (baseName.length != 2) throw const FormatException("Base name must be 2 letters (e.g., QR).");

      String v1Name = baseName[0];
      String v2Name = baseName[1];
      String v3Name = topVertexName.toUpperCase().isEmpty ? "P" : topVertexName.toUpperCase();

      TrianglePoint p1 = TrianglePoint(name: v1Name, x: 0, y: 0);
      TrianglePoint p2 = TrianglePoint(name: v2Name, x: baseLen, y: 0);

      // Use Law of Sines to find lengths of other two sides mathematically
      double angle3Deg = 180 - (angle1Deg + angle2Deg);
      double side1Len = (baseLen * math.sin(_degToRad(angle2Deg))) / math.sin(_degToRad(angle3Deg));
      double side2Len = (baseLen * math.sin(_degToRad(angle1Deg))) / math.sin(_degToRad(angle3Deg));

      double rad1 = _degToRad(angle1Deg);
      TrianglePoint p3 = TrianglePoint(name: v3Name, x: side1Len * math.cos(rad1), y: side1Len * math.sin(rad1));

      List<String> workings = [
        "\\text{Check accuracy by calculating the 3rd angle:}",
        "\\text{Sum of interior angles} = 180^\\circ",
        "\\angle $v3Name = 180^\\circ - (\\angle $v1Name + \\angle $v2Name)",
        "\\angle $v3Name = 180^\\circ - (${_fmt(angle1Deg)}^\\circ + ${_fmt(angle2Deg)}^\\circ)",
        "\\angle $v3Name = 180^\\circ - ${_fmt(angle1Deg + angle2Deg)}^\\circ = ${_fmt(angle3Deg)}^\\circ"
      ];

      List<ConstructionStep> steps = [
        ConstructionStep(
            title: "Step 1: Draw the base line",
            description: "Use a ruler to draw base line $baseName = ${_fmt(baseLen)} cm.",
            mathLaTeX: "\\text{Line } $baseName = ${_fmt(baseLen)}\\text{ cm}"
        ),
        ConstructionStep(
            title: "Step 2: Construct the first angle",
            description: "Place your protractor at $v1Name and mark an angle of ${_fmt(angle1Deg)}°. Draw a long, light line from $v1Name through the mark.",
            mathLaTeX: "\\angle $v1Name = ${_fmt(angle1Deg)}^\\circ"
        ),
        ConstructionStep(
            title: "Step 3: Construct the second angle",
            description: "Place your protractor at $v2Name and mark an angle of ${_fmt(angle2Deg)}° (measuring from the inside). Draw another long, light line from $v2Name.",
            mathLaTeX: "\\angle $v2Name = ${_fmt(angle2Deg)}^\\circ"
        ),
        ConstructionStep(
            title: "Step 4: Mark the intersection",
            description: "The exact point where the two lines cross is point $v3Name. The construction is complete.",
            mathLaTeX: "\\text{Intersection } = $v3Name"
        ),
        ConstructionStep(
            title: "Step 5: Find the third angle",
            description: "Place the center of your protractor precisely over the new vertex $v3Name to measure the missing angle. You can also verify this mathematically using the rule that a triangle's interior angles sum to 180°.",
            mathLaTeX: "\\angle $v3Name = 180^\\circ - (${_fmt(angle1Deg)}^\\circ + ${_fmt(angle2Deg)}^\\circ) = ${_fmt(angle3Deg)}^\\circ"
        ),
      ];

      return TriangleConstructionResult(
        mode: "ASA",
        vertices: [p1, p2, p3],
        measurements: {
          "Side $v1Name$v3Name": "${_fmt(side1Len)} cm",
          "Side $v2Name$v3Name": "${_fmt(side2Len)} cm",
          "Angle $v3Name": "${_fmt(angle3Deg)}°",
        },
        workingsLaTeX: workings,
        steps: steps,
      );
    } catch (e) {
      return TriangleConstructionResult(mode: "ASA", vertices: [], measurements: {}, steps: [], valid: false, errorMessage: e is FormatException ? e.message : "Invalid input parameters.");
    }
  }

  // ==========================================
  // MODE 3: SSS (Side-Side-Side)
  // ==========================================
  static TriangleConstructionResult solveSSS({
    required String baseName, required double baseLen,
    required String side1Name, required double side1Len,
    required String side2Name, required double side2Len,
  }) {
    try {
      if (baseLen <= 0 || side1Len <= 0 || side2Len <= 0) throw const FormatException("All sides must be > 0.");

      // Triangle Inequality Theorem Check
      if (baseLen + side1Len <= side2Len || baseLen + side2Len <= side1Len || side1Len + side2Len <= baseLen) {
        throw const FormatException("These sides cannot form a closed triangle.");
      }

      baseName = baseName.toUpperCase();
      if (baseName.length != 2) throw const FormatException("Base name must be 2 letters (e.g., LM).");

      String v1Name = baseName[0];
      String v2Name = baseName[1];

      String topName = side1Name.toUpperCase().replaceAll(v1Name, '').replaceAll(v2Name, '');
      if (topName.isEmpty) topName = "K";

      TrianglePoint p1 = TrianglePoint(name: v1Name, x: 0, y: 0);
      TrianglePoint p2 = TrianglePoint(name: v2Name, x: baseLen, y: 0);

      // Use Law of Cosines to find angle at V1 to place it on Cartesian plane
      // c^2 = a^2 + b^2 - 2ab*cos(C)
      // side2Len^2 = side1Len^2 + baseLen^2 - 2(side1Len)(baseLen)cos(A)
      double cosV1 = (side1Len * side1Len + baseLen * baseLen - side2Len * side2Len) / (2 * side1Len * baseLen);
      double angleV1Rad = math.acos(cosV1);

      TrianglePoint p3 = TrianglePoint(name: topName, x: side1Len * math.cos(angleV1Rad), y: side1Len * math.sin(angleV1Rad));

      // Create Construction Arcs (To simulate compass sweeping)
      // Arc 1 from V1
      ConstructionArc arc1 = ConstructionArc(
          centerX: p1.x, centerY: p1.y, radius: side1Len,
          startAngle: angleV1Rad - 0.3, sweepAngle: 0.6 // Draw an arc spanning ~34 degrees around intersection
      );

      // Arc 2 from V2
      double angleV2Rad = math.atan2(p3.y - p2.y, p3.x - p2.x);
      ConstructionArc arc2 = ConstructionArc(
          centerX: p2.x, centerY: p2.y, radius: side2Len,
          startAngle: angleV2Rad - 0.3, sweepAngle: 0.6
      );

      // Calculate missing angles for the result breakdown
      double angleV1Deg = _radToDeg(angleV1Rad);
      double angleV2Deg = _calcAngle(baseLen, side2Len, side1Len);
      double angleV3Deg = 180 - (angleV1Deg + angleV2Deg);

      List<ConstructionStep> steps = [
        ConstructionStep(
            title: "Step 1: Draw the base line",
            description: "Use your ruler to draw base line $baseName exactly ${_fmt(baseLen)} cm long.",
            mathLaTeX: "\\text{Line } $baseName = ${_fmt(baseLen)}\\text{ cm}"
        ),
        ConstructionStep(
            title: "Step 2: Draw the first compass arc",
            description: "Open your pair of compasses to exactly ${_fmt(side1Len)} cm using a ruler. Place the sharp point at $v1Name and draw an arc lightly near where the top of the triangle should be.",
            mathLaTeX: "\\text{Radius from } $v1Name = ${_fmt(side1Len)}\\text{ cm}"
        ),
        ConstructionStep(
            title: "Step 3: Draw the second compass arc",
            description: "Adjust your compasses to exactly ${_fmt(side2Len)} cm. Place the sharp point at $v2Name and draw an arc to cross (intersect) the first arc.",
            mathLaTeX: "\\text{Radius from } $v2Name = ${_fmt(side2Len)}\\text{ cm}"
        ),
        ConstructionStep(
            title: "Step 4: Join the points",
            description: "Mark the intersection of the two arcs as point $topName. Use your ruler to draw straight lines from $v1Name to $topName, and from $v2Name to $topName.",
            mathLaTeX: "\\text{Join to complete } \\Delta $v1Name$v2Name$topName"
        ),
        ConstructionStep(
            title: "Step 5: Measure the required angles",
            description: "To find the missing angles, place the center of your protractor exactly over each vertex. Align the baseline of the protractor with one side, and read the angle where the other side crosses the scale.",
            mathLaTeX: "\\text{Measure } \\angle $v1Name, \\angle $v2Name, \\text{ and } \\angle $topName"
        ),
      ];

      return TriangleConstructionResult(
        mode: "SSS",
        vertices: [p1, p2, p3],
        arcs: [arc1, arc2],
        measurements: {
          "Angle $v1Name": "${_fmt(angleV1Deg)}°",
          "Angle $v2Name": "${_fmt(angleV2Deg)}°",
          "Angle $topName": "${_fmt(angleV3Deg)}°",
        },
        steps: steps,
      );

    } catch (e) {
      return TriangleConstructionResult(mode: "SSS", vertices: [], measurements: {}, steps: [], valid: false, errorMessage: e is FormatException ? e.message : "Invalid input parameters.");
    }
  }
}