class BisectPoint {
  final String name;
  final double x;
  final double y;

  BisectPoint({required this.name, required this.x, required this.y});
}

class BisectArc {
  final double centerX;
  final double centerY;
  final double radius;
  final double startAngle;
  final double sweepAngle;

  BisectArc({
    required this.centerX,
    required this.centerY,
    required this.radius,
    required this.startAngle,
    required this.sweepAngle,
  });
}

class BisectStep {
  final String title;
  final String description;
  final String mathLaTeX;

  BisectStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

class BisectAngleResult {
  final double totalAngle;
  final double bisectedAngle;
  final BisectPoint vertex;
  final BisectPoint arm1End;
  final BisectPoint arm2End;
  final BisectPoint pointP;
  final BisectPoint pointQ;
  final BisectPoint pointR;
  final BisectArc baseArc;
  final BisectArc intersectArcP;
  final BisectArc intersectArcQ;

  final Map<String, String> finalAnswers;
  final List<BisectStep> steps;
  final bool valid;
  final String? errorMessage;

  BisectAngleResult({
    required this.totalAngle,
    required this.bisectedAngle,
    required this.vertex,
    required this.arm1End,
    required this.arm2End,
    required this.pointP,
    required this.pointQ,
    required this.pointR,
    required this.baseArc,
    required this.intersectArcP,
    required this.intersectArcQ,
    required this.finalAnswers,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}