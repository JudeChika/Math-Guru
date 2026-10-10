import 'real_life_graphs_models.dart';

class RealLifeGraphsLogic {

  /// Formats decimals cleanly
  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// Safely parse numeric input
  static double _parse(String input, {double defaultVal = 1.0}) {
    return double.tryParse(input.replaceAll(RegExp(r'[^\d\.\-]'), '')) ?? defaultVal;
  }

  static RealLifeGraphResult solve({
    required int mode,
    required String xLabelStr,
    required String yLabelStr,
    required String scaleXStr,
    required String scaleYStr,
    // Mode 0 args
    String? fixedChargeStr, String? rateStr,
    // Mode 1 args
    String? conversionRateStr,
    // Mode 2 args
    String? x1Str, String? y1Str, String? x2Str, String? y2Str,
    required List<RealLifeGraphQuestion> questions,
  }) {
    try {
      String xLabel = xLabelStr.trim().isEmpty ? "X-Axis" : xLabelStr.trim();
      String yLabel = yLabelStr.trim().isEmpty ? "Y-Axis" : yLabelStr.trim();

      double scaleX = _parse(scaleXStr, defaultVal: 1.0);
      double scaleY = _parse(scaleYStr, defaultVal: 10.0);
      if (scaleX <= 0 || scaleY <= 0) throw const FormatException("Scales must be positive.");

      double m = 0; // Gradient
      double c = 0; // Y-Intercept
      String modeName = "";

      List<RealLifeGraphStep> steps = [];
      List<String> workings = [];

      if (mode == 0) {
        modeName = 'FixedVariable';
        c = _parse(fixedChargeStr ?? '0', defaultVal: 0);
        m = _parse(rateStr ?? '1', defaultVal: 1);

        workings.add("\\text{\\textbf{1. The Algebraic Relationship}}");
        workings.add("\\text{Total } $yLabel = \\text{Standing Charge} + (\\text{Rate} \\times $xLabel)");
        workings.add("y = ${_fmt(c)} + ${_fmt(m)}x");

        steps.add(RealLifeGraphStep(
            title: "Step 1: Form the Equation",
            description: "This real-life situation has a fixed cost (standing charge) and a variable cost (rate per unit). We can write this as a linear equation: y = mx + c.",
            mathLaTeX: "y = ${_fmt(m)}x + ${_fmt(c)}"
        ));
      } else if (mode == 1) {
        modeName = 'DirectConversion';
        c = 0;
        m = _parse(conversionRateStr ?? '1', defaultVal: 1);

        workings.add("\\text{\\textbf{1. The Conversion Rate}}");
        workings.add("1 \\text{ $xLabel} = ${_fmt(m)} \\text{ $yLabel}");
        workings.add("y = ${_fmt(m)}x");

        steps.add(RealLifeGraphStep(
            title: "Step 1: Form the Equation",
            description: "This is a direct conversion graph. It starts exactly at the origin (0,0) because 0 $xLabel equals 0 $yLabel.",
            mathLaTeX: "y = ${_fmt(m)}x"
        ));
      } else if (mode == 2) {
        modeName = 'TwoPoint';
        double x1 = _parse(x1Str ?? '0', defaultVal: 0);
        double y1 = _parse(y1Str ?? '0', defaultVal: 0);
        double x2 = _parse(x2Str ?? '1', defaultVal: 1);
        double y2 = _parse(y2Str ?? '1', defaultVal: 1);

        if (x1 == x2) throw const FormatException("Points cannot have the same X value.");

        m = (y2 - y1) / (x2 - x1);
        c = y1 - (m * x1);

        workings.add("\\text{\\textbf{1. Calculate the Conversion Formula}}");
        workings.add("\\text{Gradient (m)} = \\frac{y_2 - y_1}{x_2 - x_1} = \\frac{${_fmt(y2)} - ${_fmt(y1)}}{${_fmt(x2)} - ${_fmt(x1)}} = ${_fmt(m)}");
        workings.add("\\text{Y-Intercept (c)} = y_1 - m(x_1) = ${_fmt(y1)} - (${_fmt(m)} \\times ${_fmt(x1)}) = ${_fmt(c)}");

        String signC = c >= 0 ? "+ ${_fmt(c)}" : "- ${_fmt(c.abs())}";
        workings.add("\\text{Equation: } y = ${_fmt(m)}x $signC");

        steps.add(RealLifeGraphStep(
            title: "Step 1: Determine the Formula",
            description: "We use the two given points to find the gradient (rate of change) and the y-intercept (starting value). This gives us the exact formula to convert any value!",
            mathLaTeX: "y = ${_fmt(m)}x $signC"
        ));
      }

      workings.add("");
      workings.add("\\text{\\textbf{2. Table of Values}}");

      List<Map<String, double>> table = [];
      // Generate sensible x values based on the scale!
      double startX = mode == 2 ? _parse(x1Str ?? '0', defaultVal: 0) : 0;
      if (mode == 2 && startX > 0) startX = 0; // Always try to show origin if positive

      double stepX = scaleX; // Use user's scale to pick nice points
      if (stepX < 1) stepX = 1; // Fallback

      for (int i = 0; i <= 4; i++) {
        double xVal = startX + (i * stepX);
        double yVal = (m * xVal) + c;
        table.add({'x': xVal, 'y': yVal});
      }

      String tableMath = "\\begin{array}{|c|c|c|c|c|c|} \\hline ";
      tableMath += "\\text{$xLabel} & ${_fmt(table[0]['x']!)} & ${_fmt(table[1]['x']!)} & ${_fmt(table[2]['x']!)} & ${_fmt(table[3]['x']!)} & ${_fmt(table[4]['x']!)} \\\\ \\hline ";
      tableMath += "\\text{$yLabel} & ${_fmt(table[0]['y']!)} & ${_fmt(table[1]['y']!)} & ${_fmt(table[2]['y']!)} & ${_fmt(table[3]['y']!)} & ${_fmt(table[4]['y']!)} \\\\ \\hline ";
      tableMath += "\\end{array}";

      workings.add(tableMath);

      steps.add(RealLifeGraphStep(
          title: "Step 2: Create a Table of Values",
          description: "To draw the graph, we calculate corresponding y-values for a set of x-values using our formula. We chose x-values that match your chosen scale ($scaleX) to make plotting easier.",
          mathLaTeX: tableMath
      ));

      workings.add("");
      workings.add("\\text{\\textbf{3. Graph Scale}}");
      workings.add("\\text{Horizontal Axis: } 2\\text{cm} = ${_fmt(scaleX)} \\text{ $xLabel}");
      workings.add("\\text{Vertical Axis: } 2\\text{cm} = ${_fmt(scaleY)} \\text{ $yLabel}");

      steps.add(RealLifeGraphStep(
        title: "Step 3: Apply the Scale",
        description: "A scale tells us how much each major grid line (2cm block) represents on the graph paper. This ensures the graph fits perfectly on the page.",
      ));

      Map<String, String> answers = {};
      if (questions.isNotEmpty) {
        workings.add("");
        workings.add("\\text{\\textbf{4. Reading the Graph}}");

        for (int i = 0; i < questions.length; i++) {
          var q = questions[i];
          if (q.type == 'findY') {
            double ansY = (m * q.givenValue) + c;
            answers["When $xLabel is ${_fmt(q.givenValue)}"] = "${_fmt(ansY)} $yLabel";
            String signC = c >= 0 ? "+ ${_fmt(c)}" : "- ${_fmt(c.abs())}";
            workings.add("\\text{Q${i+1}: If } x = ${_fmt(q.givenValue)}, \\text{ then } y = ${_fmt(m)}(${_fmt(q.givenValue)}) $signC = ${_fmt(ansY)}");

            steps.add(RealLifeGraphStep(
              title: "Reading from the Graph: Find $yLabel",
              description: "Start at ${_fmt(q.givenValue)} on the $xLabel axis. Move straight UP to the line, then directly LEFT to read the $yLabel axis. The value is ${_fmt(ansY)}.",
            ));
          } else {
            double ansX = (q.givenValue - c) / m;
            answers["When $yLabel is ${_fmt(q.givenValue)}"] = "${_fmt(ansX)} $xLabel";
            String signC = c >= 0 ? "- ${_fmt(c)}" : "+ ${_fmt(c.abs())}";
            workings.add("\\text{Q${i+1}: If } y = ${_fmt(q.givenValue)}, \\text{ then } x = \\frac{${_fmt(q.givenValue)} $signC}{${_fmt(m)}} = ${_fmt(ansX)}");

            steps.add(RealLifeGraphStep(
              title: "Reading from the Graph: Find $xLabel",
              description: "Start at ${_fmt(q.givenValue)} on the $yLabel axis. Move straight RIGHT to the line, then directly DOWN to read the $xLabel axis. The value is ${_fmt(ansX)}.",
            ));
          }
        }
      }

      return RealLifeGraphResult(
          mode: modeName,
          xLabel: xLabel, yLabel: yLabel, m: m, c: c,
          scaleX: scaleX, scaleY: scaleY,
          tableOfValues: table, questions: questions,
          finalAnswers: answers, workingsLaTeX: workings, steps: steps
      );

    } catch (e) {
      return RealLifeGraphResult(
          mode: "", xLabel: "", yLabel: "", m: 0, c: 0, scaleX: 0, scaleY: 0,
          tableOfValues: [], questions: [], finalAnswers: {}, workingsLaTeX: [], steps: [],
          valid: false, errorMessage: "Invalid input. Check your numbers."
      );
    }
  }
}