import 'dart:math' as math;
import 'bisect_angle_models.dart';

class BisectAngleLogic {

  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }

  static double _degToRad(double deg) => deg * math.pi / 180.0;

  static BisectAngleResult solve({
    required String angleNameStr,
    required String angleSizeStr,
    required String armLengthStr,
  }) {
    try {
      // 1. Parse Inputs
      String name = angleNameStr.trim().toUpperCase();
      if (name.isEmpty) name = "ABC";

      String pt1 = name.length >= 3 ? name[0] : "A";
      String vertex = name.length >= 3 ? name[1] : (name.length == 1 ? name[0] : "B");
      String pt2 = name.length >= 3 ? name[2] : "C";

      double angleDeg = double.tryParse(angleSizeStr.replaceAll(RegExp(r'[^\d\.]'), '')) ?? 0;
      double armLen = double.tryParse(armLengthStr.replaceAll(RegExp(r'[^\d\.]'), '')) ?? 6.0;

      if (angleDeg <= 0 || angleDeg >= 180) throw const FormatException("Angle must be between 1 and 179 degrees.");
      if (armLen <= 0) armLen = 6.0;

      // 2. Calculate Base Coordinates
      // Let Vertex be at (0,0). Arm2 goes along the positive X-axis. Arm1 goes up at the specified angle.
      BisectPoint vPt = BisectPoint(name: vertex, x: 0, y: 0);
      BisectPoint arm2Pt = BisectPoint(name: pt2, x: armLen, y: 0);

      double rad = _degToRad(angleDeg);
      BisectPoint arm1Pt = BisectPoint(name: pt1, x: armLen * math.cos(rad), y: armLen * math.sin(rad));

      // 3. Calculate Arc Intersections (P and Q)
      // Pick a radius for the first arc (e.g., 40% of the arm length)
      double r1 = armLen * 0.4;
      BisectPoint ptQ = BisectPoint(name: "Q", x: r1, y: 0); // On Arm 2
      BisectPoint ptP = BisectPoint(name: "P", x: r1 * math.cos(rad), y: r1 * math.sin(rad)); // On Arm 1

      // 4. Calculate Final Intersection (R)
      // Point R lies exactly on the bisector (angle / 2).
      // Pick a visually pleasing distance for R from the vertex (e.g., 75% of arm length)
      double dR = armLen * 0.75;
      double halfRad = _degToRad(angleDeg / 2);
      BisectPoint ptR = BisectPoint(name: "R", x: dR * math.cos(halfRad), y: dR * math.sin(halfRad));

      // 5. Generate Arc Data for the CustomPainter
      BisectArc baseArc = BisectArc(
          centerX: 0, centerY: 0, radius: r1,
          startAngle: 0, sweepAngle: rad
      );

      // Calculate the radius needed from P and Q to reach R exactly
      double r2 = math.sqrt(math.pow(ptR.x - ptQ.x, 2) + math.pow(ptR.y - ptQ.y, 2));

      // Angle from P to R
      double anglePR = math.atan2(ptR.y - ptP.y, ptR.x - ptP.x);
      BisectArc arcP = BisectArc(
          centerX: ptP.x, centerY: ptP.y, radius: r2,
          startAngle: anglePR - 0.4, sweepAngle: 0.8 // Draw a small 45-degree stroke
      );

      // Angle from Q to R
      double angleQR = math.atan2(ptR.y - ptQ.y, ptR.x - ptQ.x);
      BisectArc arcQ = BisectArc(
          centerX: ptQ.x, centerY: ptQ.y, radius: r2,
          startAngle: angleQR - 0.4, sweepAngle: 0.8 // Draw a small 45-degree stroke
      );

      // 6. Generate Step-by-Step Textbook Logic
      List<BisectStep> steps = [];

      steps.add(BisectStep(
          title: "Step 1: The Initial Angle",
          description: "Draw the given angle $name = ${_fmt(angleDeg)}°. This gives us a vertex at $vertex, and two arms pointing towards $pt1 and $pt2.",
          mathLaTeX: "\\angle $name = ${_fmt(angleDeg)}^\\circ"
      ));

      steps.add(BisectStep(
          title: "Step 2: Draw the Base Arc",
          description: "Open a pair of compasses to a suitable radius (e.g., ${_fmt(r1)} cm). Place the sharp compass point exactly at the vertex $vertex. Draw a smooth arc to cut the arm $vertex$pt1 at point P, and the arm $vertex$pt2 at point Q.",
          mathLaTeX: "\\text{Mark points P and Q}"
      ));

      steps.add(BisectStep(
          title: "Step 3: The Intersecting Arcs",
          description: "Without changing the compass radius too much (or keeping it exactly the same), place the sharp point at P and draw a small arc inside the angle. Then, move the sharp point to Q and draw another arc to cut the first one. Let's call the exact point where they cross R.",
          mathLaTeX: "\\text{Intersect at point R}"
      ));

      steps.add(BisectStep(
          title: "Step 4: Draw the Bisector",
          description: "Use a ruler to draw a straight line from the vertex $vertex directly through the crossing point R. The line $vertex R is the official bisector of the angle!",
          mathLaTeX: "$vertex R \\text{ bisects } \\angle $name"
      ));

      double halfDeg = angleDeg / 2;
      steps.add(BisectStep(
          title: "Step 5: Verify by Measurement",
          description: "If you measure the two new smaller angles with a protractor, they will be perfectly equal. Both will be exactly half of the original angle.",
          mathLaTeX: "\\angle $pt1 $vertex R = \\angle R $vertex $pt2 = ${_fmt(halfDeg)}^\\circ"
      ));

      Map<String, String> answers = {
        "Original Angle ($name)": "${_fmt(angleDeg)}°",
        "Bisected Angles": "${_fmt(halfDeg)}° each",
        "Bisector Line": "$vertex R",
      };

      return BisectAngleResult(
          totalAngle: angleDeg, bisectedAngle: halfDeg,
          vertex: vPt, arm1End: arm1Pt, arm2End: arm2Pt,
          pointP: ptP, pointQ: ptQ, pointR: ptR,
          baseArc: baseArc, intersectArcP: arcP, intersectArcQ: arcQ,
          finalAnswers: answers, steps: steps
      );

    } catch (e) {
      return BisectAngleResult(
          totalAngle: 0, bisectedAngle: 0,
          vertex: BisectPoint(name: '', x: 0, y: 0), arm1End: BisectPoint(name: '', x: 0, y: 0), arm2End: BisectPoint(name: '', x: 0, y: 0),
          pointP: BisectPoint(name: '', x: 0, y: 0), pointQ: BisectPoint(name: '', x: 0, y: 0), pointR: BisectPoint(name: '', x: 0, y: 0),
          baseArc: BisectArc(centerX: 0, centerY: 0, radius: 0, startAngle: 0, sweepAngle: 0),
          intersectArcP: BisectArc(centerX: 0, centerY: 0, radius: 0, startAngle: 0, sweepAngle: 0),
          intersectArcQ: BisectArc(centerX: 0, centerY: 0, radius: 0, startAngle: 0, sweepAngle: 0),
          finalAnswers: {}, steps: [], valid: false, errorMessage: "Ensure the angle is a valid number between 1 and 179."
      );
    }
  }
}