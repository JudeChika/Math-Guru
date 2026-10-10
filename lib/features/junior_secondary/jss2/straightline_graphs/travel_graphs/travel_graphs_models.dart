/// Represents a single point in time during a journey.
class TravelWaypoint {
  final double time;
  final double value; // Distance or Speed

  TravelWaypoint({required this.time, required this.value});
}

/// Represents a complete journey made up of connected waypoints.
class TravelJourney {
  final String name;
  final List<TravelWaypoint> waypoints;

  TravelJourney({required this.name, required this.waypoints});
}

/// Represents the exact point where two journeys cross.
class TravelIntersection {
  final double time;
  final double value;

  TravelIntersection({required this.time, required this.value});
}

/// Represents a single pedagogical step during the evaluation.
class TravelStep {
  final String title;
  final String description;
  final String? mathLaTeX;

  TravelStep({
    required this.title,
    required this.description,
    this.mathLaTeX,
  });
}

/// Holds the results of a solved Travel Graph.
class TravelResult {
  final String graphType; // 'Distance-Time' or 'Speed-Time'
  final String timeLabel;
  final String valueLabel;
  final double scaleX;
  final double scaleY;

  final List<TravelJourney> journeys;
  final TravelIntersection? intersection;

  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<TravelStep> steps;

  final bool valid;
  final String? errorMessage;

  TravelResult({
    required this.graphType,
    required this.timeLabel,
    required this.valueLabel,
    required this.scaleX,
    required this.scaleY,
    required this.journeys,
    this.intersection,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}