import 'cartesian_intro_models.dart';

class CartesianIntroLogic {

  /// Returns the exact textbook explanations based on the selected feature
  static CartesianIntroResult explainFeature(String featureKey) {
    List<CartesianIntroStep> steps = [];
    String title = "";

    switch (featureKey) {
      case 'plane':
        title = "The Cartesian Plane";
        steps.add(CartesianIntroStep(
          title: "What is it?",
          description: "A plane surface with axes on it is called a Cartesian plane. It is a flat, 2D surface that extends infinitely in all directions.",
        ));
        steps.add(CartesianIntroStep(
          title: "History of the Name",
          description: "Its name comes from the French philosopher and mathematician, René Descartes. His brilliant work made it possible to use numbers to represent geometry!",
        ));
        break;

      case 'axes':
        title = "The Axes";
        steps.add(CartesianIntroStep(
          title: "What are they?",
          description: "The two number lines that form the framework of the graph are called axes.",
        ));
        steps.add(CartesianIntroStep(
          title: "Plural Form",
          description: "Note that 'Axes' is simply the plural word for 'axis'. When we talk about both the x and y lines together, we call them the axes.",
        ));
        steps.add(CartesianIntroStep(
          title: "Right Angles",
          description: "The two axes cross each other perfectly at right angles (90 degrees).",
        ));
        break;

      case 'origin':
        title = "The Origin (O)";
        steps.add(CartesianIntroStep(
          title: "The Intersection",
          description: "The number lines cross exactly at the zero-point of each axis.",
        ));
        steps.add(CartesianIntroStep(
            title: "The Zero-Point",
            description: "We call this exact center point the 'origin'. It is always labeled with the letter 'O' or the numbers (0, 0). Every journey on a graph starts here!",
            mathLaTeX: "O = (0, 0)"
        ));
        break;

      case 'x_axis':
        title = "The x-axis";
        steps.add(CartesianIntroStep(
          title: "The Horizontal Line",
          description: "The axis going straight across from left to right is called the x-axis.",
        ));
        steps.add(CartesianIntroStep(
          title: "Positive Scale",
          description: "It has a positive scale to the right of the Origin (O). Moving right increases the value.",
        ));
        steps.add(CartesianIntroStep(
          title: "Negative Scale",
          description: "It has a negative scale to the left of the Origin (O). Moving left decreases the value into negatives.",
        ));
        break;

      case 'y_axis':
        title = "The y-axis";
        steps.add(CartesianIntroStep(
          title: "The Vertical Line",
          description: "The axis going up and down the page is called the y-axis.",
        ));
        steps.add(CartesianIntroStep(
          title: "Positive Scale",
          description: "It has a positive scale heading upwards from the Origin (O). Moving up increases the value.",
        ));
        steps.add(CartesianIntroStep(
          title: "Negative Scale",
          description: "It has a negative scale heading downwards from the Origin (O). Moving down decreases the value into negatives.",
        ));
        break;
    }

    return CartesianIntroResult(
      featureKey: featureKey,
      title: title,
      steps: steps,
    );
  }
}