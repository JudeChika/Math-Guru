import 'linear_graphs_models.dart';

class LinearGraphsLogic {

  /// Formats decimals cleanly (e.g., 2.0 -> 2, 2.50 -> 2.5)
  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// Safely parse numeric input
  static double _parse(String input, {double defaultVal = 1.0}) {
    return double.tryParse(input.replaceAll(RegExp(r'[^\d\.]'), '')) ?? defaultVal;
  }

  static LinearGraphResult solve({
    required String xLabelStr,
    required String yLabelStr,
    required String rateStr,
    required bool isContinuous,
    required String scaleXStr,
    required String scaleYStr,
    required List<GraphQuestion> questions,
  }) {
    try {
      String xLabel = xLabelStr.trim().isEmpty ? "X-Axis" : xLabelStr.trim();
      String yLabel = yLabelStr.trim().isEmpty ? "Y-Axis" : yLabelStr.trim();

      double rate = _parse(rateStr, defaultVal: 1.0);
      if (rate <= 0) throw const FormatException("Rate must be positive.");

      double scaleX = _parse(scaleXStr, defaultVal: 1.0);
      double scaleY = _parse(scaleYStr, defaultVal: 10.0);

      List<LinearGraphStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};
      List<Map<String, double>> table = [];

      // Step 1: Generate Table of Values
      workings.add("\\text{\\textbf{1. Table of Values}}");
      workings.add("\\text{Relationship: } 1 \\text{ $xLabel} = ${_fmt(rate)} \\text{ $yLabel}");

      for (int i = 0; i <= 5; i++) {
        double xVal = i.toDouble();
        double yVal = xVal * rate;
        table.add({'x': xVal, 'y': yVal});
      }

      String tableMath = "\\begin{array}{|c|c|c|c|c|c|c|} \\hline ";
      tableMath += "\\text{$xLabel} & 0 & 1 & 2 & 3 & 4 & 5 \\\\ \\hline ";
      tableMath += "\\text{$yLabel} & 0 & ${_fmt(1 * rate)} & ${_fmt(2 * rate)} & ${_fmt(3 * rate)} & ${_fmt(4 * rate)} & ${_fmt(5 * rate)} \\\\ \\hline ";
      tableMath += "\\end{array}";

      workings.add(tableMath);

      steps.add(LinearGraphStep(
          title: "Step 1: Create a Table of Values",
          description: "To draw a graph, we first calculate corresponding values. Since 1 $xLabel equals ${_fmt(rate)} $yLabel, we multiply each $xLabel value (0, 1, 2, 3...) by ${_fmt(rate)} to find its $yLabel.",
          mathLaTeX: tableMath
      ));

      // Step 2: Scale Explanation
      workings.add("");
      workings.add("\\text{\\textbf{2. Graph Scale}}");
      workings.add("\\text{Horizontal Axis: } 2\\text{cm} = ${_fmt(scaleX)} \\text{ $xLabel}");
      workings.add("\\text{Vertical Axis: } 2\\text{cm} = ${_fmt(scaleY)} \\text{ $yLabel}");

      steps.add(LinearGraphStep(
          title: "Step 2: Choose the Scale",
          description: "A scale tells us how much each major grid line (2cm block) represents. \n• Horizontal scale: 2cm to ${_fmt(scaleX)} unit(s).\n• Vertical scale: 2cm to ${_fmt(scaleY)} unit(s).",
          mathLaTeX: "\\text{Scale: } 2\\text{cm to } ${_fmt(scaleX)} \\text{ on x, } ${_fmt(scaleY)} \\text{ on y.}"
      ));

      // Step 3: Graph Plotting Rule
      steps.add(LinearGraphStep(
        title: "Step 3: Plot the Points",
        description: isContinuous
            ? "Plot the ordered pairs from the table. Because these values can have fractions (like 1.5m of string), we connect the points with a solid, continuous straight line."
            : "Plot the ordered pairs from the table. Because it is impossible to have fractions of these items (like 1.5 drinking glasses), we DO NOT connect the points. This is a discontinuous graph.",
      ));

      // Step 4: Reading the Graph (Questions)
      if (questions.isNotEmpty) {
        workings.add("");
        workings.add("\\text{\\textbf{3. Reading the Graph}}");

        for (int i = 0; i < questions.length; i++) {
          var q = questions[i];
          if (q.type == 'findY') {
            double ansY = q.givenValue * rate;
            answers["When $xLabel is ${_fmt(q.givenValue)}"] = "${_fmt(ansY)} $yLabel";
            workings.add("\\text{Q${i+1}: If } x = ${_fmt(q.givenValue)}, \\text{ then } y = ${_fmt(q.givenValue)} \\times ${_fmt(rate)} = ${_fmt(ansY)}");

            steps.add(LinearGraphStep(
              title: "Reading from the Graph: Find $yLabel",
              description: "Start at ${_fmt(q.givenValue)} on the $xLabel axis. Move straight UP until you hit the line, then move directly LEFT to read the value on the $yLabel axis. The corresponding value is ${_fmt(ansY)}.",
            ));
          } else {
            double ansX = q.givenValue / rate;
            answers["When $yLabel is ${_fmt(q.givenValue)}"] = "${_fmt(ansX)} $xLabel";
            workings.add("\\text{Q${i+1}: If } y = ${_fmt(q.givenValue)}, \\text{ then } x = ${_fmt(q.givenValue)} \\div ${_fmt(rate)} = ${_fmt(ansX)}");

            steps.add(LinearGraphStep(
              title: "Reading from the Graph: Find $xLabel",
              description: "Start at ${_fmt(q.givenValue)} on the $yLabel axis. Move straight RIGHT until you hit the line, then move directly DOWN to read the value on the $xLabel axis. The corresponding value is ${_fmt(ansX)}.",
            ));
          }
        }
      }

      return LinearGraphResult(
          xLabel: xLabel, yLabel: yLabel, rate: rate,
          isContinuous: isContinuous, scaleX: scaleX, scaleY: scaleY,
          tableOfValues: table, questions: questions,
          finalAnswers: answers, workingsLaTeX: workings, steps: steps
      );

    } catch (e) {
      return LinearGraphResult(
          xLabel: "", yLabel: "", rate: 0, isContinuous: true, scaleX: 0, scaleY: 0,
          tableOfValues: [], questions: [], finalAnswers: {}, workingsLaTeX: [], steps: [],
          valid: false, errorMessage: "Invalid input. Check your numbers and rates."
      );
    }
  }
}