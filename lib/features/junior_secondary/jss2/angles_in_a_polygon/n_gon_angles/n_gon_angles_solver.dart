import 'n_gon_angles_models.dart';

/// Helper class to parse and store algebraic inputs like "2x - 10" or "124"
class AlgTerm {
  final double coeff;
  final double constant;
  final String variable;
  final String rawString;

  AlgTerm(this.coeff, this.constant, this.variable, this.rawString);

  bool get isPureNumber => coeff == 0;
  bool get isPureVariable => coeff == 1 && constant == 0 && variable.isNotEmpty;
}

class NSidedPolygonSolver {
  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  static String _toAlgStr(AlgTerm t) {
    String res = "";
    if (t.coeff != 0) {
      String cStr = "";
      if (t.coeff == 1) {
        cStr = "";
      } else if (t.coeff == -1) {
        cStr = "-";
      } else {
        cStr = _fmt(t.coeff);
      }
      res += "$cStr${t.variable}";
    }
    if (t.constant > 0 && t.coeff != 0) {
      res += " + ${_fmt(t.constant)}";
    } else if (t.constant < 0 && t.coeff != 0) {
      res += " - ${_fmt(t.constant.abs())}";
    } else if (t.coeff == 0) {
      res += _fmt(t.constant);
    }
    return res;
  }

  static AlgTerm? _parseTerm(String input) {
    String s = input.replaceAll(' ', '');
    if (s.isEmpty) return null;

    double coeff = 0;
    double constant = 0;
    String variable = '';

    if (s.startsWith('-')) s = '0$s';
    s = s.replaceAll('-', '+-');

    List<String> parts = s.split('+');
    for (String p in parts) {
      if (p.isEmpty) continue;
      var match = RegExp(r'^([+-]?\d*\.?\d*)([a-zA-Z]+)$').firstMatch(p);
      if (match != null) {
        variable = match.group(2)!;
        String cStr = match.group(1)!;
        if (cStr == '' || cStr == '+') {
          coeff += 1;
        } else if (cStr == '-') {
          coeff -= 1;
        } else {
          coeff += double.parse(cStr);
        }
      } else if (RegExp(r'^[+-]?\d*\.?\d+$').hasMatch(p)) {
        constant += double.parse(p);
      }
    }
    return AlgTerm(coeff, constant, variable, input.trim());
  }

  /// Solves word problems for regular polygons given one known property
  static NSidedResult solveRegular(String knownType, String inputVal) {
    try {
      double val = double.parse(inputVal.trim());
      if (val <= 0) throw const FormatException();

      int n = 0;
      List<String> workings = [];
      List<NSidedStep> steps = [];

      if (knownType == 'n') {
        n = val.toInt();
        if (n < 3) return _error("A polygon must have at least 3 sides.");

        workings.add("n = $n");
        workings.add("");
        steps.add(NSidedStep(
            title: "Step 1: Identify n",
            description: "We are given a regular polygon with $n sides.",
            mathLaTeX: "n = $n"
        ));
      }
      else if (knownType == 'int_sum') {
        // (n-2)*180 = val
        workings.add("(n - 2) \\times 180^\\circ = ${_fmt(val)}^\\circ");
        workings.add("n - 2 = \\frac{${_fmt(val)}^\\circ}{180^\\circ}");

        double div = val / 180;
        workings.add("n - 2 = ${_fmt(div)}");
        workings.add("n = ${_fmt(div)} + 2 = ${_fmt(div + 2)}");
        workings.add("");

        n = (div + 2).round();
        if (n < 3 || (div + 2) != n) return _error("Invalid sum for a polygon. It must be a multiple of 180°.");

        steps.add(NSidedStep(
            title: "Step 1: Use the Sum of Interior Angles Formula",
            description: "We know the formula is (n - 2) × 180°. We set it equal to our known sum.",
            mathLaTeX: "(n - 2) \\times 180^\\circ = ${_fmt(val)}^\\circ"
        ));
        steps.add(NSidedStep(
            title: "Step 2: Solve for n",
            description: "Divide both sides by 180, then add 2 to find the number of sides.",
            mathLaTeX: "n = \\frac{${_fmt(val)}^\\circ}{180^\\circ} + 2 \\Rightarrow n = $n"
        ));
      }
      else if (knownType == 'one_ext') {
        // 360 / n = val => n = 360 / val
        workings.add("\\frac{360^\\circ}{n} = ${_fmt(val)}^\\circ");
        workings.add("n = \\frac{360^\\circ}{${_fmt(val)}^\\circ}");

        double nCalc = 360 / val;
        workings.add("n = ${_fmt(nCalc)}");
        workings.add("");

        n = nCalc.round();
        if (n < 3 || nCalc != n) return _error("Invalid exterior angle. 360° must be perfectly divisible by this angle.");

        steps.add(NSidedStep(
            title: "Step 1: Use the Exterior Angle Formula",
            description: "The sum of all exterior angles is always 360°. For a regular polygon, one angle is 360° divided by n.",
            mathLaTeX: "\\frac{360^\\circ}{n} = ${_fmt(val)}^\\circ"
        ));
        steps.add(NSidedStep(
            title: "Step 2: Solve for n",
            description: "Swap n and the angle to find the number of sides.",
            mathLaTeX: "n = \\frac{360^\\circ}{${_fmt(val)}^\\circ} = $n"
        ));
      }
      else if (knownType == 'one_int') {
        // (n-2)*180 / n = val
        if (val >= 180) return _error("An interior angle must be strictly less than 180°.");

        workings.add("\\frac{(n - 2) \\times 180^\\circ}{n} = ${_fmt(val)}^\\circ");
        workings.add("180n - 360 = ${_fmt(val)}n");
        workings.add("180n - ${_fmt(val)}n = 360");

        double diff = 180 - val;
        workings.add("${_fmt(diff)}n = 360");
        workings.add("n = \\frac{360}{${_fmt(diff)}}");

        double nCalc = 360 / diff;
        workings.add("n = ${_fmt(nCalc)}");
        workings.add("");

        n = nCalc.round();
        if (n < 3 || nCalc != n) return _error("Invalid interior angle. It does not form a closed regular polygon.");

        steps.add(NSidedStep(
            title: "Step 1: Use the Interior Angle Formula",
            description: "We set the formula for a single regular interior angle equal to our known value.",
            mathLaTeX: "\\frac{(n - 2) \\times 180^\\circ}{n} = ${_fmt(val)}^\\circ"
        ));
        steps.add(NSidedStep(
            title: "Step 2: Cross Multiply & Expand",
            description: "Multiply both sides by n, and expand the brackets on the left.",
            mathLaTeX: "180n - 360 = ${_fmt(val)}n"
        ));
        steps.add(NSidedStep(
            title: "Step 3: Group Like Terms",
            description: "Bring the n's to one side and the numbers to the other.",
            mathLaTeX: "180n - ${_fmt(val)}n = 360 \\Rightarrow ${_fmt(diff)}n = 360"
        ));
        steps.add(NSidedStep(
            title: "Step 4: Solve for n",
            description: "Divide to find the final number of sides.",
            mathLaTeX: "n = \\frac{360}{${_fmt(diff)}} = $n"
        ));
      }

      // Calculate all properties now that we have 'n'
      double intSum = (n - 2) * 180.0;
      double extSum = 360.0;
      double oneExt = 360.0 / n;
      double oneInt = intSum / n;

      int stepCounter = steps.length + 1;

      // 1. Detailed workings for Sum of Interior Angles
      if (knownType != 'int_sum') {
        workings.add("\\text{Sum of Interior Angles} = (n - 2) \\times 180^\\circ");
        workings.add("\\text{Sum} = ($n - 2) \\times 180^\\circ");
        workings.add("\\text{Sum} = ${n - 2} \\times 180^\\circ = ${_fmt(intSum)}^\\circ");
        workings.add(""); // Empty line for neatness

        steps.add(NSidedStep(
            title: "Step $stepCounter: Calculate Sum of Interior Angles",
            description: "Using the polygon formula: (n - 2) × 180°. Substitute n = $n into the formula.",
            mathLaTeX: "\\text{Sum} = ($n - 2) \\times 180^\\circ = ${_fmt(intSum)}^\\circ"
        ));
        stepCounter++;
      }

      // 2. Detailed workings for Sum of Exterior Angles
      workings.add("\\text{Sum of Exterior Angles} = 360^\\circ \\quad \\text{(Fixed Rule)}");
      workings.add("");

      steps.add(NSidedStep(
          title: "Step $stepCounter: Sum of Exterior Angles",
          description: "A fundamental geometric rule states that the sum of exterior angles for ANY convex polygon is always exactly 360°.",
          mathLaTeX: "\\text{Exterior Sum} = 360^\\circ"
      ));
      stepCounter++;

      // 3. Detailed workings for One Exterior Angle
      if (knownType != 'one_ext') {
        workings.add("\\text{One Exterior Angle} = \\frac{360^\\circ}{n}");
        workings.add("\\text{One Ext. Angle} = \\frac{360^\\circ}{$n} = ${_fmt(oneExt)}^\\circ");
        workings.add("");

        steps.add(NSidedStep(
            title: "Step $stepCounter: Calculate One Exterior Angle",
            description: "Since it is a regular polygon, all exterior angles are equal. Divide the total exterior sum (360°) by the number of sides ($n).",
            mathLaTeX: "\\text{One Exterior} = \\frac{360^\\circ}{$n} = ${_fmt(oneExt)}^\\circ"
        ));
        stepCounter++;
      }

      // 4. Detailed workings for One Interior Angle
      if (knownType != 'one_int') {
        workings.add("\\text{One Interior Angle} = \\frac{\\text{Sum of Interior Angles}}{n}");
        workings.add("\\text{One Int. Angle} = \\frac{${_fmt(intSum)}^\\circ}{$n} = ${_fmt(oneInt)}^\\circ");
        workings.add("");

        steps.add(NSidedStep(
            title: "Step $stepCounter: Calculate One Interior Angle",
            description: "Since all interior angles are equal in a regular polygon, divide the total interior sum (${_fmt(intSum)}°) by the number of sides ($n).",
            mathLaTeX: "\\text{One Interior} = \\frac{${_fmt(intSum)}^\\circ}{$n} = ${_fmt(oneInt)}^\\circ"
        ));
        stepCounter++;
      }

      Map<String, String> finalProps = {
        "Number of Sides (n)": "$n",
        "Name of Polygon": _getPolygonName(n),
        "Sum of Interior Angles": "${_fmt(intSum)}°",
        "One Interior Angle": "${_fmt(oneInt)}°",
        "Sum of Exterior Angles": "360°",
        "One Exterior Angle": "${_fmt(oneExt)}°",
      };

      return NSidedResult(
        nSides: n,
        mode: 'Regular',
        finalAngles: finalProps,
        workings: workings,
        steps: steps,
      );

    } catch (e) {
      return _error("Please enter a valid numeric value.");
    }
  }

  /// Solves an irregular polygon given n and a comma-separated list of algebraic angles
  static NSidedResult solveIrregular(int n, String anglesStr) {
    try {
      if (n < 3) return _error("A polygon must have at least 3 sides.");

      List<String> rawAngles = anglesStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      if (rawAngles.length != n) {
        return _error("You entered ${rawAngles.length} angles, but n is set to $n. They must match exactly.");
      }

      List<AlgTerm> parsed = [];
      for (var raw in rawAngles) {
        var t = _parseTerm(raw);
        if (t == null) return _error("Could not understand the angle '$raw'. Use formats like 'x', '2x', or '90'.");
        parsed.add(t);
      }

      List<String> workings = [];
      List<NSidedStep> steps = [];

      double targetSum = (n - 2) * 180.0;

      workings.add("\\text{Sum} = ($n - 2) \\times 180^\\circ = ${_fmt(targetSum)}^\\circ");
      workings.add(""); // Empty line for neatness

      steps.add(NSidedStep(
          title: "Step 1: Find the Target Sum",
          description: "First, use the polygon formula to find out what all the angles must add up to for a $n-sided shape.",
          mathLaTeX: "\\text{Sum} = ($n - 2) \\times 180^\\circ = ${_fmt(targetSum)}^\\circ"
      ));

      double coeffSum = 0;
      double constSum = 0;
      Set<String> vars = {};
      List<String> exprs = [];

      for (var t in parsed) {
        coeffSum += t.coeff;
        constSum += t.constant;
        if (t.variable.isNotEmpty) vars.add(t.variable);
        exprs.add(t.rawString);
      }

      if (vars.isEmpty) {
        // Pure numbers validation
        if ((constSum - targetSum).abs() > 0.01) {
          return _error("Invalid geometry. Those numbers add up to ${_fmt(constSum)}°, but a $n-sided polygon must add up to ${_fmt(targetSum)}°.");
        }
        return NSidedResult(
          nSides: n, mode: 'Irregular',
          finalAngles: {"Sum Validated": "${_fmt(targetSum)}°"},
          workings: workings..add("${exprs.join(' + ')} = ${_fmt(targetSum)}^\\circ"),
          steps: steps..add(NSidedStep(title: "Step 2: Verification", description: "The provided numbers perfectly match the geometric formula.", mathLaTeX: "${_fmt(constSum)} = ${_fmt(targetSum)}^\\circ")),
        );
      }

      if (vars.length > 1) return _error("Please use only ONE type of unknown variable (e.g., only 'x' or only 'y').");

      String v = vars.first;
      if (coeffSum == 0) return _error("The variables cancel each other out. Cannot solve.");

      String eq1 = "${exprs.join(' + ')} = ${_fmt(targetSum)}^\\circ";
      workings.add(eq1);
      steps.add(NSidedStep(
          title: "Step 2: Set up the Equation",
          description: "Add all the given angle expressions together and set them equal to our target sum.",
          mathLaTeX: eq1
      ));

      String eq2 = "";
      if (constSum > 0) {
        eq2 = "${_fmt(coeffSum)}$v + ${_fmt(constSum)} = ${_fmt(targetSum)}^\\circ";
      } else if (constSum < 0) {
        eq2 = "${_fmt(coeffSum)}$v - ${_fmt(constSum.abs())} = ${_fmt(targetSum)}^\\circ";
      } else {
        eq2 = "${_fmt(coeffSum)}$v = ${_fmt(targetSum)}^\\circ";
      }

      if (exprs.length > 1) {
        workings.add(eq2);
        steps.add(NSidedStep(
            title: "Step 3: Group Like Terms",
            description: "Collect and add all the '$v's together, and add all the plain numbers together.",
            mathLaTeX: eq2
        ));
      }

      double diff = targetSum - constSum;
      if (constSum != 0) {
        String moveSign = constSum < 0 ? '+' : '-';
        String eq3 = "${_fmt(coeffSum)}$v = ${_fmt(targetSum)}^\\circ $moveSign ${_fmt(constSum.abs())}^\\circ";
        workings.add(eq3);

        String eq4 = "${_fmt(coeffSum)}$v = ${_fmt(diff)}^\\circ";
        workings.add(eq4);

        steps.add(NSidedStep(
            title: "Step 4: Isolate the Unknown Variable",
            description: "Move the plain number to the other side of the equals sign. Remember, its sign changes!",
            mathLaTeX: "$eq3 \\Rightarrow $eq4"
        ));
      }

      double xVal = diff / coeffSum;
      String res = "$v = ${_fmt(xVal)}";

      if (coeffSum != 1 && coeffSum != -1) {
        String eq5 = "$v = \\frac{${_fmt(diff)}^\\circ}{${_fmt(coeffSum)}}";
        workings.add(eq5);
        workings.add(res);
        steps.add(NSidedStep(
            title: "Step 5: Solve for '$v'",
            description: "Divide both sides by ${_fmt(coeffSum)} to find the final value of '$v'.",
            mathLaTeX: "$eq5 \\Rightarrow $res"
        ));
      } else {
        String finalEq = res;
        if (coeffSum == -1) {
          finalEq = "-$v = ${_fmt(diff)}^\\circ \\Rightarrow $res";
          workings.add("-$v = ${_fmt(diff)}^\\circ");
          workings.add(res);
        } else {
          workings.add(res);
        }
        steps.add(NSidedStep(
            title: "Step 5: Solve for '$v'",
            description: "We have successfully found the value of our unknown variable!",
            mathLaTeX: finalEq
        ));
      }

      workings.add("");

      Map<String, String> finalAngles = {};
      finalAngles["Variable $v"] = _fmt(xVal);

      for (int i = 0; i < parsed.length; i++) {
        var term = parsed[i];
        if (term.coeff != 0) {
          double val = term.coeff * xVal + term.constant;
          finalAngles["Angle ${i+1}"] = "${_fmt(val)}°";

          String subLatex = "\\text{Angle } ${i+1} = ${_toAlgStr(term)}";

          String constStr = "";
          if (term.constant > 0) {
            constStr = " + ${_fmt(term.constant)}";
          } else if (term.constant < 0) constStr = " - ${_fmt(term.constant.abs())}";

          String subLatex2 = "";
          if (term.isPureVariable) {
            subLatex2 = "\\text{Angle } ${i+1} = ${_fmt(xVal)}^\\circ";
          } else {
            subLatex2 = "\\text{Angle } ${i+1} = ${_fmt(term.coeff)}(${_fmt(xVal)})$constStr";
          }

          String finalVal = "\\text{Angle } ${i+1} = ${_fmt(val)}^\\circ";

          workings.add(subLatex);
          if (!term.isPureVariable) workings.add(subLatex2);
          workings.add(finalVal);
          workings.add("");
        } else {
          finalAngles["Angle ${i+1}"] = "${_fmt(term.constant)}°";
        }
      }

      steps.add(NSidedStep(
          title: "Step 6: Calculate Final Angles",
          description: "Substitute the value of $v back into the original expressions to find the size of each angle.",
          mathLaTeX: "\\text{Check the Workings section above for the full substitution breakdown.}"
      ));

      return NSidedResult(
        nSides: n,
        mode: 'Irregular',
        finalAngles: finalAngles,
        workings: workings,
        steps: steps,
      );

    } catch (e) {
      return _error("Check your algebraic input format.");
    }
  }

  static String _getPolygonName(int n) {
    switch (n) {
      case 3: return "Triangle";
      case 4: return "Quadrilateral";
      case 5: return "Pentagon";
      case 6: return "Hexagon";
      case 7: return "Heptagon";
      case 8: return "Octagon";
      case 9: return "Nonagon";
      case 10: return "Decagon";
      case 11: return "Hendecagon";
      case 12: return "Dodecagon";
      case 13: return "Tridecagon";
      case 14: return "Tetradecagon";
      case 15: return "Pentadecagon";
      case 20: return "Icosagon";
      default: return "$n-gon";
    }
  }

  static NSidedResult _error(String msg) {
    return NSidedResult(nSides: 0, mode: '', finalAngles: {}, workings: [], steps: [], valid: false, errorMessage: msg);
  }
}