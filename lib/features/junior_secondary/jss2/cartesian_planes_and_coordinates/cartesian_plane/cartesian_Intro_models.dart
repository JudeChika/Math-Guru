/// Represents a single pedagogical concept or definition.
class CartesianIntroStep {
  final String title;
  final String description;
  final String? mathLaTeX;

  CartesianIntroStep({
    required this.title,
    required this.description,
    this.mathLaTeX,
  });
}

/// Holds the results and definitions for the selected feature.
class CartesianIntroResult {
  final String featureKey; // 'plane', 'axes', 'origin', 'x_axis', 'y_axis'
  final String title;
  final List<CartesianIntroStep> steps;

  CartesianIntroResult({
    required this.featureKey,
    required this.title,
    required this.steps,
  });
}