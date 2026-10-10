import 'travel_graphs_models.dart';

class TravelGraphsLogic {

  /// Formats decimals neatly, dropping trailing .0
  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// Extracts the unit from the axis label (e.g. "Time (s)" -> "s")
  static String _extractUnit(String label, String defaultUnit) {
    var match = RegExp(r'\(([^)]+)\)').firstMatch(label);
    return match != null ? match.group(1)!.trim() : defaultUnit;
  }

  /// Calculates intersection of two line segments (p1->p2 and p3->p4). Returns null if none.
  static TravelIntersection? _getIntersection(TravelWaypoint p1, TravelWaypoint p2, TravelWaypoint p3, TravelWaypoint p4) {
    double x1 = p1.time, y1 = p1.value;
    double x2 = p2.time, y2 = p2.value;
    double x3 = p3.time, y3 = p3.value;
    double x4 = p4.time, y4 = p4.value;

    double denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (denom.abs() < 1e-6) return null; // Parallel or identical

    double t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom;
    double u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denom;

    if (t >= 0 && t <= 1 && u >= 0 && u <= 1) {
      double px = x1 + t * (x2 - x1);
      double py = y1 + t * (y2 - y1);
      return TravelIntersection(time: px, value: py);
    }
    return null;
  }

  static TravelResult solveDistanceTime({
    required List<TravelJourney> journeys,
    required String timeLabel,
    required String distLabel,
    required double scaleX,
    required double scaleY,
  }) {
    try {
      if (journeys.isEmpty || journeys[0].waypoints.length < 2) {
        throw const FormatException("Add at least one journey with 2+ waypoints.");
      }

      // Dynamic SI Unit Extraction
      String tUnit = _extractUnit(timeLabel, "min");
      String dUnit = _extractUnit(distLabel, "km");
      String sUnit = "$dUnit/$tUnit"; // e.g., km/h or m/s

      List<TravelStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};
      TravelIntersection? meetingPoint;

      workings.add("\\text{\\textbf{Distance-Time Graph Analysis}}");

      for (int j = 0; j < journeys.length; j++) {
        var journey = journeys[j];
        workings.add("");
        workings.add("\\text{\\textbf{Journey: ${journey.name}}}");

        double totalDistance = 0;
        double startTime = journey.waypoints.first.time;
        double endTime = journey.waypoints.last.time;

        for (int i = 0; i < journey.waypoints.length - 1; i++) {
          var p1 = journey.waypoints[i];
          var p2 = journey.waypoints[i + 1];

          double dt = p2.time - p1.time;
          double dd = p2.value - p1.value;
          double absDist = dd.abs();
          totalDistance += absDist;

          String stageName = "Stage ${i + 1} (${_fmt(p1.time)} to ${_fmt(p2.time)} $tUnit)";
          if (dt <= 0) continue;

          if (dd == 0) {
            workings.add("\\text{$stageName: Stopped for } ${_fmt(dt)} \\text{ $tUnit}");
            steps.add(TravelStep(
              title: "${journey.name}: $stageName",
              description: "The line is horizontal (gradient is 0). The distance does not change, meaning the object is stationary or stopped.",
            ));
          } else {
            double speed = absDist / dt;
            String direction = dd > 0 ? "away from" : "towards";
            workings.add("\\text{$stageName:}");
            workings.add("\\text{Speed} = \\frac{\\text{Distance}}{\\text{Time}} = \\frac{${_fmt(absDist)}\\text{ $dUnit}}{${_fmt(dt)}\\text{ $tUnit}} = ${_fmt(speed)} \\text{ $sUnit}");

            steps.add(TravelStep(
                title: "${journey.name}: $stageName",
                description: "The gradient of a distance-time graph tells us the speed. It traveled ${_fmt(absDist)} $dUnit in ${_fmt(dt)} $tUnit moving $direction the origin.",
                mathLaTeX: "\\text{Speed} = \\frac{${_fmt(absDist)}}{${_fmt(dt)}} = ${_fmt(speed)} \\text{ $sUnit}"
            ));
          }
        }

        double totalTime = endTime - startTime;
        if (totalTime > 0) {
          double avgSpeed = totalDistance / totalTime;
          workings.add("\\text{Total Distance} = ${_fmt(totalDistance)} \\text{ $dUnit}");
          workings.add("\\text{Average Speed} = \\frac{\\text{Total Distance}}{\\text{Total Time}} = \\frac{${_fmt(totalDistance)}}{${_fmt(totalTime)}} = ${_fmt(avgSpeed)} \\text{ $sUnit}");

          answers["${journey.name} Avg Speed"] = "${_fmt(avgSpeed)} $sUnit";
          steps.add(TravelStep(
              title: "${journey.name}: Average Speed",
              description: "To find the average speed, divide the TOTAL distance traveled (including return trips) by the TOTAL time taken (including stops).",
              mathLaTeX: "\\text{Avg Speed} = \\frac{${_fmt(totalDistance)}}{${_fmt(totalTime)}} = ${_fmt(avgSpeed)} \\text{ $sUnit}"
          ));
        }
      }

      if (journeys.length == 2) {
        var j1 = journeys[0];
        var j2 = journeys[1];
        for (int i = 0; i < j1.waypoints.length - 1; i++) {
          for (int k = 0; k < j2.waypoints.length - 1; k++) {
            var cross = _getIntersection(j1.waypoints[i], j1.waypoints[i+1], j2.waypoints[k], j2.waypoints[k+1]);
            if (cross != null) {
              meetingPoint = cross;
              workings.add("");
              workings.add("\\text{\\textbf{Intersection Point}}");
              workings.add("\\text{Met at Time = } ${_fmt(cross.time)}\\text{ $tUnit}, \\text{ Distance = } ${_fmt(cross.value)}\\text{ $dUnit}");
              answers["Meeting Point"] = "At ${_fmt(cross.time)} $tUnit, ${_fmt(cross.value)} $dUnit";

              steps.add(TravelStep(
                  title: "Intersection (Where they meet)",
                  description: "The point where the two lines cross represents the exact moment they pass each other in real life.",
                  mathLaTeX: "\\text{Meet at } (${_fmt(cross.time)}, ${_fmt(cross.value)})"
              ));
              break;
            }
          }
          if (meetingPoint != null) break;
        }
      }

      return TravelResult(
          graphType: 'Distance-Time', timeLabel: timeLabel, valueLabel: distLabel, scaleX: scaleX, scaleY: scaleY,
          journeys: journeys, intersection: meetingPoint, finalAnswers: answers, workingsLaTeX: workings, steps: steps
      );
    } catch (e) {
      return TravelResult(graphType: 'Distance-Time', timeLabel: '', valueLabel: '', scaleX: 1, scaleY: 1, journeys: [], finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Ensure all inputs are valid numbers.");
    }
  }

  static TravelResult solveSpeedTime({
    required TravelJourney journey,
    required String timeLabel,
    required String speedLabel,
    required double scaleX,
    required double scaleY,
  }) {
    try {
      if (journey.waypoints.length < 2) throw const FormatException("Add at least two waypoints.");

      // Dynamic SI Unit Extraction
      String tUnit = _extractUnit(timeLabel, "s");
      String vUnit = _extractUnit(speedLabel, "m/s");

      // Smart resolution of derived units
      String accelUnit = vUnit.contains("/$tUnit") ? vUnit.replaceAll("/$tUnit", "/$tUnit^2") : "$vUnit/$tUnit";
      String distUnit = vUnit.contains("/$tUnit") ? vUnit.replaceAll("/$tUnit", "") : "$vUnit \\cdot $tUnit";

      List<TravelStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};

      workings.add("\\text{\\textbf{Speed-Time Graph Analysis}}");
      double totalDistance = 0;

      for (int i = 0; i < journey.waypoints.length - 1; i++) {
        var p1 = journey.waypoints[i];
        var p2 = journey.waypoints[i + 1];

        double dt = p2.time - p1.time;
        double dv = p2.value - p1.value;
        if (dt <= 0) continue;

        String stageName = "Stage ${i + 1} (${_fmt(p1.time)} to ${_fmt(p2.time)} $tUnit)";
        workings.add("");
        workings.add("\\text{\\textbf{$stageName}}");

        // 1. Acceleration
        double accel = dv / dt;
        if (dv > 0) {
          workings.add("\\text{Acceleration} = \\frac{\\text{Change in Speed}}{\\text{Time}} = \\frac{${_fmt(dv)}}{${_fmt(dt)}} = ${_fmt(accel)} \\text{ $accelUnit}");
          steps.add(TravelStep(
              title: "$stageName: Acceleration",
              description: "The line goes UP. The gradient (slope) of a speed-time graph gives us the acceleration.",
              mathLaTeX: "\\text{Accel} = \\frac{${_fmt(dv)}}{${_fmt(dt)}} = ${_fmt(accel)} \\text{ $accelUnit}"
          ));
        } else if (dv < 0) {
          workings.add("\\text{Deceleration} = \\frac{${_fmt(dv.abs())}}{${_fmt(dt)}} = ${_fmt(accel.abs())} \\text{ $accelUnit}");
          steps.add(TravelStep(
              title: "$stageName: Deceleration",
              description: "The line goes DOWN. A negative gradient means the object is slowing down (decelerating).",
              mathLaTeX: "\\text{Decel} = \\frac{${_fmt(dv.abs())}}{${_fmt(dt)}} = ${_fmt(accel.abs())} \\text{ $accelUnit}"
          ));
        } else {
          workings.add("\\text{Acceleration} = 0 \\text{ (Constant Speed)}");
          steps.add(TravelStep(
            title: "$stageName: Constant Speed",
            description: "The line is flat. The speed does not change, meaning acceleration is 0.",
          ));
        }

        // 2. Distance (Area under curve)
        double area = 0;
        String areaMath = "";
        String shapeName = "";

        if (p1.value == 0 && p2.value > 0) {
          shapeName = "Triangle";
          area = 0.5 * dt * p2.value;
          areaMath = "\\frac{1}{2} \\times \\text{base} \\times \\text{height} = \\frac{1}{2} \\times ${_fmt(dt)} \\times ${_fmt(p2.value)} = ${_fmt(area)} \\text{ $distUnit}";
        } else if (p2.value == 0 && p1.value > 0) {
          shapeName = "Triangle";
          area = 0.5 * dt * p1.value;
          areaMath = "\\frac{1}{2} \\times \\text{base} \\times \\text{height} = \\frac{1}{2} \\times ${_fmt(dt)} \\times ${_fmt(p1.value)} = ${_fmt(area)} \\text{ $distUnit}";
        } else if (p1.value == p2.value) {
          shapeName = "Rectangle";
          area = dt * p1.value;
          areaMath = "\\text{base} \\times \\text{height} = ${_fmt(dt)} \\times ${_fmt(p1.value)} = ${_fmt(area)} \\text{ $distUnit}";
        } else {
          shapeName = "Trapezium";
          area = 0.5 * (p1.value + p2.value) * dt;
          areaMath = "\\frac{1}{2}(a+b)h = \\frac{1}{2}(${_fmt(p1.value)} + ${_fmt(p2.value)}) \\times ${_fmt(dt)} = ${_fmt(area)} \\text{ $distUnit}";
        }

        totalDistance += area;
        workings.add("\\text{Distance (Area of $shapeName)} = $areaMath");

        steps.add(TravelStep(
            title: "$stageName: Distance Travelled",
            description: "Crucial Rule: The distance travelled is exactly equal to the AREA UNDER THE GRAPH. For this stage, the shape formed under the line is a $shapeName.",
            mathLaTeX: "\\text{Area} = $areaMath"
        ));
      }

      workings.add("");
      workings.add("\\text{\\textbf{Total Journey}}");
      workings.add("\\text{Total Distance} = ${_fmt(totalDistance)} \\text{ $distUnit}");
      answers["Total Distance"] = "${_fmt(totalDistance)} $distUnit";

      return TravelResult(
          graphType: 'Speed-Time', timeLabel: timeLabel, valueLabel: speedLabel, scaleX: scaleX, scaleY: scaleY,
          journeys: [journey], finalAnswers: answers, workingsLaTeX: workings, steps: steps
      );

    } catch (e) {
      return TravelResult(graphType: 'Speed-Time', timeLabel: '', valueLabel: '', scaleX: 1, scaleY: 1, journeys: [], finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Ensure all inputs are valid numbers.");
    }
  }
}