import 'geometry_angles_models.dart';

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

class AnglesRulesSolver {

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

  /// Parses an input string into coefficients, constants, and variables
  static AlgTerm? _parseTerm(String input) {
    String s = input.replaceAll(' ', '');
    if (s.isEmpty) return null;

    double coeff = 0;
    double constant = 0;
    String variable = '';

    // Handle signs cleanly
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

  /// Solves dynamic inputs for a straight line (180°) or a point (360°).
  static AnglesRuleResult solveAlgebraicAngles(List<String> inputs, String diagramType) {
    try {
      double targetSum = diagramType == 'Straight Line' ? 180.0 : 360.0;
      List<AnglesRuleStep> steps = [];
      List<String> workings = [];
      Map<String, String> finalAngles = {};

      Map<String, double> varCoeffs = {};
      double constSum = 0;
      List<String> originalExpressions = [];

      for (String box in inputs) {
        var term = _parseTerm(box);
        if (term == null) continue;

        originalExpressions.add(box.trim());
        constSum += term.constant;
        if (term.coeff != 0) {
          varCoeffs[term.variable] = (varCoeffs[term.variable] ?? 0) + term.coeff;
        }
      }

      if (originalExpressions.isEmpty) throw const FormatException("Empty");

      String equationLeft = originalExpressions.join(' + ');
      String math1 = "$equationLeft = $targetSum^\\circ";
      workings.add(math1);
      steps.add(AnglesRuleStep(
        title: "Step 1: Apply the Geometric Rule",
        description: diagramType == 'Straight Line'
            ? "Angles on a straight line always add up to $targetSum°."
            : "Angles around a central point always add up to $targetSum° (a full circle).",
        mathLaTeX: math1,
      ));

      // Handle pure numbers
      if (varCoeffs.isEmpty) {
        if ((constSum - targetSum).abs() > 0.01) {
          return AnglesRuleResult(diagramType: diagramType, finalAngles: {}, workings: [], steps: [], valid: false, errorMessage: "The numbers provided add up to $constSum°, but they should add up to $targetSum°!");
        } else {
          String mathV = "${_fmt(constSum)} = $targetSum^\\circ";
          workings.add(mathV);
          steps.add(AnglesRuleStep(title: "Step 2: Verification", description: "All the provided numbers perfectly add up to $targetSum°.", mathLaTeX: mathV));
          return AnglesRuleResult(diagramType: diagramType, finalAngles: {}, workings: workings, steps: steps);
        }
      }

      // Handle multiple different variables on the same line
      if (varCoeffs.length > 1) {
        String groupedEq = "";
        varCoeffs.forEach((v, c) {
          if (c > 0 && groupedEq.isNotEmpty) {
            groupedEq += " + ";
          } else if (c < 0) {
            groupedEq += " - ";
          }
          groupedEq += "${c.abs() == 1 ? '' : _fmt(c.abs())}$v";
        });

        double diff = targetSum - constSum;
        String finalEq = "$groupedEq = ${_fmt(diff)}^\\circ";
        workings.add(finalEq);

        steps.add(AnglesRuleStep(
            title: "Step 2: Simplify Equation",
            description: "Since there are multiple different unknown variables (${varCoeffs.keys.join(', ')}), we cannot find a single numerical value. We leave the equation in its simplest form.",
            mathLaTeX: finalEq
        ));

        return AnglesRuleResult(diagramType: diagramType, finalAngles: {"Equation": finalEq}, workings: workings, steps: steps);
      }

      // Handle single variable solving
      String variable = varCoeffs.keys.first;
      double coeffSum = varCoeffs[variable]!;

      String groupedEq = '';
      groupedEq += '${_fmt(coeffSum)}$variable';
      if (constSum > 0) {
        groupedEq += ' + ${_fmt(constSum)}';
      } else if (constSum < 0) {
        groupedEq += ' - ${_fmt(constSum.abs())}';
      }

      String math2 = "$groupedEq = $targetSum^\\circ";
      workings.add(math2);
      steps.add(AnglesRuleStep(title: "Step 2: Group Like Terms", description: "Group all the '$variable's and numbers together.", mathLaTeX: math2));

      double diff = targetSum - constSum;
      String math3 = "${_fmt(coeffSum)}$variable = ${_fmt(targetSum)} - ${_fmt(constSum)} \\Rightarrow ${_fmt(coeffSum)}$variable = ${_fmt(diff)}^\\circ";
      workings.add("${_fmt(coeffSum)}$variable = ${_fmt(diff)}^\\circ");
      steps.add(AnglesRuleStep(title: "Step 3: Isolate the Variable", description: "Move the numbers to the other side.", mathLaTeX: math3));

      double variableValue = diff / coeffSum;
      String math4 = "$variable = \\frac{${_fmt(diff)}}{${_fmt(coeffSum)}} = ${_fmt(variableValue)}^\\circ";
      workings.add(math4);
      steps.add(AnglesRuleStep(title: "Step 4: Solve for $variable", description: "Divide both sides to find the variable.", mathLaTeX: math4));

      for (int i = 0; i < originalExpressions.length; i++) {
        var term = _parseTerm(originalExpressions[i]);
        if (term != null && term.coeff != 0) {
          double localVal = term.coeff * variableValue + term.constant;
          finalAngles['Angle ${i+1}'] = "${_fmt(localVal)}°";
        } else {
          finalAngles['Angle ${i+1}'] = "${originalExpressions[i]}°";
        }
      }
      finalAngles[variable] = _fmt(variableValue);

      return AnglesRuleResult(diagramType: diagramType, finalAngles: finalAngles, workings: workings, steps: steps);

    } catch (e) {
      return AnglesRuleResult(diagramType: diagramType, finalAngles: {}, workings: [], steps: [], valid: false, errorMessage: "Invalid format. Try 'x', '2x', or '45'.");
    }
  }

  /// Solves intersecting lines (X-Shape) using Vertically Opposite + 360 Sum rules
  static AnglesRuleResult solveIntersectingLines(Map<String, String> inputs) {
    try {
      Map<String, AlgTerm> parsed = {};
      inputs.forEach((k, v) {
        var t = _parseTerm(v);
        if (t != null) parsed[k] = t;
      });

      if (parsed.isEmpty) return AnglesRuleResult(diagramType: 'Intersecting Lines', finalAngles: {}, workings: [], steps: [], valid: false, errorMessage: "Enter at least one known angle.");

      String? numPos;
      double? numVal;

      // Look for a pure number
      for (var entry in parsed.entries) {
        if (entry.value.isPureNumber) {
          numPos = entry.key;
          numVal = entry.value.constant;
          break;
        }
      }

      if (numPos == null || numVal == null) {
        return AnglesRuleResult(diagramType: 'Intersecting Lines', finalAngles: {}, workings: [], steps: [], valid: false, errorMessage: "Please provide one pure number to solve the intersection.");
      }

      List<AnglesRuleStep> steps = [];
      List<String> workings = [];
      Map<String, double> solved = {};

      String oppPos = "";
      if (numPos == 'top') oppPos = 'bottom';
      if (numPos == 'bottom') oppPos = 'top';
      if (numPos == 'left') oppPos = 'right';
      if (numPos == 'right') oppPos = 'left';

      String unk1 = (numPos == 'top' || numPos == 'bottom') ? 'left' : 'top';
      String unk2 = (numPos == 'top' || numPos == 'bottom') ? 'right' : 'bottom';

      // Explicitly follow the user's requested pedagogical method
      solved[numPos] = numVal;
      solved[oppPos] = numVal;

      steps.add(AnglesRuleStep(
        title: "Step 1: Vertically Opposite Angles",
        description: "The ${oppPos.toUpperCase()} angle is vertically opposite to the ${numPos.toUpperCase()} angle ($numVal°), so they are equal.",
        mathLaTeX: "\\text{$oppPos} = $numVal^\\circ",
      ));

      steps.add(AnglesRuleStep(
        title: "Step 2: Assign Variables to Unknowns",
        description: "The ${unk1.toUpperCase()} and ${unk2.toUpperCase()} angles are also vertically opposite, so they are equal. Let's call them 'x'.",
        mathLaTeX: "\\text{$unk1} = \\text{$unk2} = x",
      ));

      String sumEq1 = "${_fmt(numVal)} + ${parsed.containsKey(unk1) ? parsed[unk1]!.rawString : unk1} + ${_fmt(numVal)} + ${parsed.containsKey(unk2) ? parsed[unk2]!.rawString : unk2} = 360^\\circ";
      String sumEq2 = "${_fmt(numVal)}^\\circ + x^\\circ + ${_fmt(numVal)}^\\circ + x^\\circ = 360^\\circ";

      workings.add(sumEq1);
      workings.add(sumEq2);

      steps.add(AnglesRuleStep(
        title: "Step 3: Sum of Angles at a Point",
        description: "All the angles around the intersection point must add up to 360°.",
        mathLaTeX: sumEq2,
      ));

      double doubleNum = numVal * 2;
      String sumEq3 = "${_fmt(doubleNum)}^\\circ + 2x^\\circ = 360^\\circ";
      workings.add(sumEq3);
      steps.add(AnglesRuleStep(
        title: "Step 4: Group Like Terms",
        description: "Add the numbers together and add the 'x's together.",
        mathLaTeX: sumEq3,
      ));

      double diff = 360 - doubleNum;
      String sumEq4 = "2x^\\circ = 360^\\circ - ${_fmt(doubleNum)}^\\circ";
      String sumEq5 = "2x^\\circ = ${_fmt(diff)}^\\circ";
      workings.add(sumEq5);
      steps.add(AnglesRuleStep(
        title: "Step 5: Isolate 2x",
        description: "Move the number to the other side of the equation and subtract.",
        mathLaTeX: sumEq5,
      ));

      double finalX = diff / 2;
      String sumEq6 = "x^\\circ = \\frac{${_fmt(diff)}^\\circ}{2}";
      String sumEq7 = "x^\\circ = ${_fmt(finalX)}^\\circ";
      workings.add(sumEq7);
      steps.add(AnglesRuleStep(
        title: "Step 6: Solve for x",
        description: "Divide by 2 to find the value of x.",
        mathLaTeX: sumEq7,
      ));

      solved[unk1] = finalX;
      solved[unk2] = finalX;

      steps.add(AnglesRuleStep(
        title: "Step 7: Final Values",
        description: "Substitute the value of x back into the positions.",
        mathLaTeX: "\\text{$unk1} = ${_fmt(finalX)}^\\circ \\quad \\text{and} \\quad \\text{$unk2} = ${_fmt(finalX)}^\\circ",
      ));

      Map<String, String> finalAngles = {};

      // Map user variables back
      parsed.forEach((pos, term) {
        if (term.coeff != 0 && !term.isPureNumber) {
          double varValue = (solved[pos]! - term.constant) / term.coeff;
          finalAngles[term.variable] = "${_fmt(varValue)}°";
        }
      });

      for (var k in ['top', 'right', 'bottom', 'left']) {
        finalAngles["Angle ${k.toUpperCase()}"] = "${_fmt(solved[k]!)}°";
      }

      return AnglesRuleResult(diagramType: 'Intersecting Lines', finalAngles: finalAngles, workings: workings, steps: steps);

    } catch (e) {
      return AnglesRuleResult(diagramType: 'Intersecting Lines', finalAngles: {}, workings: [], steps: [], valid: false, errorMessage: "Invalid input format.");
    }
  }


  /// Solves the standard 8 angles of a transversal across parallel lines.
  static AnglesRuleResult solveParallelLines(Map<String, String> inputs) {
    try {
      Map<String, AlgTerm> parsed = {};
      inputs.forEach((k, v) {
        var t = _parseTerm(v);
        if (t != null) parsed[k] = t;
      });

      if (parsed.isEmpty) return AnglesRuleResult(diagramType: 'Parallel Lines', finalAngles: {}, workings: [], steps: [], valid: false, errorMessage: "Enter at least one known angle.");

      List<AnglesRuleStep> steps = [];
      List<String> workings = [];
      Map<String, double> solved = {};

      double? seedValue;
      String? seedPos;

      var g1 = ['a', 'c', 'e', 'g'];
      var g2 = ['b', 'd', 'f', 'h'];

      // PHASE 1: Try to find a numeric seed
      // 1A. Look for a pure number
      for (var entry in parsed.entries) {
        if (entry.value.isPureNumber) {
          seedPos = entry.key;
          seedValue = entry.value.constant;
          break;
        }
      }

      // 1B. If no pure number, try to solve an algebraic relationship
      if (seedValue == null) {
        Map<String, List<MapEntry<String, AlgTerm>>> byVar = {};
        for (var entry in parsed.entries) {
          if (!entry.value.isPureNumber) {
            String v = entry.value.variable;
            byVar[v] = (byVar[v] ?? [])..add(entry);
          }
        }

        for (var v in byVar.keys) {
          if (byVar[v]!.length >= 2) {
            var e1 = byVar[v]![0];
            var e2 = byVar[v]![1];

            bool e1G1 = g1.contains(e1.key);
            bool e2G1 = g1.contains(e2.key);

            double c1 = e1.value.coeff;
            double k1 = e1.value.constant;
            double c2 = e2.value.coeff;
            double k2 = e2.value.constant;

            double xVal = 0;
            if (e1G1 == e2G1) {
              // Equal: c1*x + k1 = c2*x + k2
              if (c1 - c2 == 0) continue;
              xVal = (k2 - k1) / (c1 - c2);
              String eq = "${_toAlgStr(e1.value)} = ${_toAlgStr(e2.value)}";
              workings.add(eq);
              steps.add(AnglesRuleStep(title: "Algebraic Check: Solve for $v", description: "The system detected variables in Position ${e1.key.toUpperCase()} and ${e2.key.toUpperCase()}. Because of their positions on the parallel lines, they are geometrically equal.", mathLaTeX: eq));
            } else {
              // Supplementary: c1*x + k1 + c2*x + k2 = 180
              if (c1 + c2 == 0) continue;
              xVal = (180 - k1 - k2) / (c1 + c2);
              String eq = "${_toAlgStr(e1.value)} + ${_toAlgStr(e2.value)} = 180^\\circ";
              workings.add(eq);
              steps.add(AnglesRuleStep(title: "Algebraic Check: Solve for $v", description: "The system detected variables in Position ${e1.key.toUpperCase()} and ${e2.key.toUpperCase()}. Because of their positions, they are supplementary (they add up to 180°).", mathLaTeX: eq));
            }

            seedPos = e1.key;
            seedValue = c1 * xVal + k1;
            String math4 = "$v = ${_fmt(xVal)}";
            workings.add(math4);
            steps.add(AnglesRuleStep(title: "Calculate Position ${e1.key.toUpperCase()}", description: "Now that we know $v = ${_fmt(xVal)}, we substitute it back into the expression to find our starting angle.", mathLaTeX: "\\text{Position } ${e1.key.toUpperCase()} = ${_fmt(seedValue)}^\\circ"));
            break;
          }
        }
      }

      if (seedValue == null || seedValue <= 0 || seedValue >= 180) {
        return AnglesRuleResult(diagramType: 'Parallel Lines', finalAngles: {}, workings: [], steps: [], valid: false, errorMessage: "Not enough information. Provide a pure number or two related algebraic angles.");
      }

      // PHASE 2: Numeric Deduction
      solved[seedPos!] = seedValue;
      workings.add("Pos ${seedPos.toUpperCase()} = ${_fmt(seedValue)}^\\circ \\quad \\text{(Base Angle)}");
      steps.add(AnglesRuleStep(title: "Base Angle", description: "We use the angle at Position ${seedPos.toUpperCase()} (${_fmt(seedValue)}°) to map out all other angles on the board.", mathLaTeX: "\\text{Position } ${seedPos.toUpperCase()} = ${_fmt(seedValue)}^\\circ"));

      void deduce(String target, String from, String rule, bool isSupp) {
        if (solved.containsKey(target)) return;
        double fromVal = solved[from]!;
        double targetVal = isSupp ? 180.0 - fromVal : fromVal;
        solved[target] = targetVal;

        String mathStr = isSupp
            ? "\\text{Pos } ${target.toUpperCase()} = 180^\\circ - ${_fmt(fromVal)}^\\circ = ${_fmt(targetVal)}^\\circ"
            : "\\text{Pos } ${target.toUpperCase()} = ${_fmt(targetVal)}^\\circ";

        workings.add(mathStr);
        steps.add(AnglesRuleStep(title: "Find Position ${target.toUpperCase()}", description: rule, mathLaTeX: mathStr));
      }

      if (['a', 'b', 'c', 'd'].contains(seedPos)) {
        if (seedPos == 'a') { deduce('b', 'a', "Angles on a straight line add to 180°.", true); deduce('d', 'a', "Vertically opposite angles are equal.", false); }
        else if (seedPos == 'b') { deduce('a', 'b', "Angles on a straight line add to 180°.", true); deduce('c', 'b', "Vertically opposite angles are equal.", false); }
        else if (seedPos == 'c') { deduce('a', 'c', "Angles on a straight line add to 180°.", true); deduce('b', 'c', "Vertically opposite angles are equal.", false); }
        else if (seedPos == 'd') { deduce('b', 'd', "Angles on a straight line add to 180°.", true); deduce('a', 'd', "Vertically opposite angles are equal.", false); }

        if (solved.containsKey('a') && !solved.containsKey('c')) deduce('c', 'b', "Vertically opposite angles are equal.", false);
        if (solved.containsKey('b') && !solved.containsKey('d')) deduce('d', 'a', "Vertically opposite angles are equal.", false);

        deduce('e', 'a', "Corresponding angles (F-angles) are equal.", false);
        deduce('f', 'b', "Corresponding angles (F-angles) are equal.", false);
        deduce('g', 'c', "Corresponding angles (F-angles) are equal.", false);
        deduce('h', 'd', "Corresponding angles (F-angles) are equal.", false);
      } else {
        if (seedPos == 'e') { deduce('f', 'e', "Angles on a straight line add to 180°.", true); deduce('h', 'e', "Vertically opposite angles are equal.", false); }
        else if (seedPos == 'f') { deduce('e', 'f', "Angles on a straight line add to 180°.", true); deduce('g', 'f', "Vertically opposite angles are equal.", false); }
        else if (seedPos == 'g') { deduce('e', 'g', "Angles on a straight line add to 180°.", true); deduce('f', 'g', "Vertically opposite angles are equal.", false); }
        else if (seedPos == 'h') { deduce('f', 'h', "Angles on a straight line add to 180°.", true); deduce('e', 'h', "Vertically opposite angles are equal.", false); }

        if (solved.containsKey('e') && !solved.containsKey('g')) deduce('g', 'f', "Vertically opposite angles are equal.", false);
        if (solved.containsKey('f') && !solved.containsKey('h')) deduce('h', 'e', "Vertically opposite angles are equal.", false);

        deduce('a', 'e', "Corresponding angles (F-angles) are equal.", false);
        deduce('b', 'f', "Corresponding angles (F-angles) are equal.", false);
        deduce('c', 'g', "Corresponding angles (F-angles) are equal.", false);
        deduce('d', 'h', "Corresponding angles (F-angles) are equal.", false);
      }

      // PHASE 3: Map back to user variables AND fill empty angles
      Map<String, String> finalAngles = {};

      parsed.forEach((pos, term) {
        if (term.coeff != 0) {
          double varValue = (solved[pos]! - term.constant) / term.coeff;
          finalAngles[term.variable] = "${_fmt(varValue)}°";

          if (term.isPureVariable) {
            steps.add(AnglesRuleStep(title: "Resolve Variable ${term.variable}", description: "Position ${pos.toUpperCase()} maps directly to ${term.variable}.", mathLaTeX: "${term.variable} = ${_fmt(varValue)}^\\circ"));
          } else {
            steps.add(AnglesRuleStep(title: "Resolve Variable ${term.variable}", description: "Set the expression at Position ${pos.toUpperCase()} equal to the solved angle.", mathLaTeX: "${_toAlgStr(term)} = ${_fmt(solved[pos]!)}^\\circ \\Rightarrow ${term.variable} = ${_fmt(varValue)}"));
          }
        }
      });

      List<String> sortedKeys = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
      for (var k in sortedKeys) {
        finalAngles["Angle ${k.toUpperCase()}"] = "${_fmt(solved[k]!)}°";
      }

      return AnglesRuleResult(diagramType: 'Parallel Lines', finalAngles: finalAngles, workings: workings, steps: steps);

    } catch (e) {
      return AnglesRuleResult(diagramType: 'Parallel Lines', finalAngles: {}, workings: [], steps: [], valid: false, errorMessage: "Invalid input format.");
    }
  }

  /// Iterative Inference Engine to solve complex combinations of rules
  static AnglesRuleResult solveTriangleParallels(Map<String, String> inputs) {
    try {
      Map<String, AlgTerm> parsed = {};
      inputs.forEach((k, v) {
        var t = _parseTerm(v);
        if (t != null) parsed[k] = t;
      });

      if (parsed.isEmpty) return AnglesRuleResult(diagramType: 'Triangle Parallels', finalAngles: {}, workings: [], steps: [], valid: false, errorMessage: "Enter at least one known angle.");

      Map<String, double> solved = {};
      List<AnglesRuleStep> steps = [];
      List<String> workings = [];

      double? seedValue;
      String? seedPos;

      // PHASE 1: Find numeric seed
      for (var entry in parsed.entries) {
        if (entry.value.isPureNumber) {
          seedPos = entry.key;
          seedValue = entry.value.constant;
          solved[seedPos] = seedValue;
          workings.add("Pos ${seedPos.toUpperCase()} = ${_fmt(seedValue)}^\\circ \\quad \\text{(Given)}");
        }
      }

      // If no pure number, solve algebraically
      if (solved.isEmpty) {
        Map<String, List<MapEntry<String, AlgTerm>>> byVar = {};
        for (var entry in parsed.entries) {
          if (!entry.value.isPureNumber) {
            String v = entry.value.variable;
            byVar[v] = (byVar[v] ?? [])..add(entry);
          }
        }

        bool? checkEqual(String p1, String p2) {
          var pair = [p1, p2]..sort();
          String key = pair.join('');
          if (['ae', 'cf'].contains(key)) return true; // Alternate
          if (['de', 'ad', 'fg', 'cg'].contains(key)) return false; // Supplementary
          return null;
        }

        for (var v in byVar.keys) {
          if (byVar[v]!.length >= 2) {
            bool solvedVar = false;
            for (int i=0; i<byVar[v]!.length; i++) {
              for (int j=i+1; j<byVar[v]!.length; j++) {
                var e1 = byVar[v]![i];
                var e2 = byVar[v]![j];
                bool? isEqual = checkEqual(e1.key, e2.key);

                if (isEqual != null) {
                  double c1 = e1.value.coeff; double k1 = e1.value.constant;
                  double c2 = e2.value.coeff; double k2 = e2.value.constant;
                  double xVal = 0;

                  if (isEqual) {
                    if (c1 - c2 == 0) continue;
                    xVal = (k2 - k1) / (c1 - c2);
                    String eq = "${_toAlgStr(e1.value)} = ${_toAlgStr(e2.value)}";
                    workings.add(eq);
                    steps.add(AnglesRuleStep(title: "Algebraic Check: Solve for $v", description: "Positions ${e1.key.toUpperCase()} and ${e2.key.toUpperCase()} are equal.", mathLaTeX: eq));
                  } else {
                    if (c1 + c2 == 0) continue;
                    xVal = (180 - k1 - k2) / (c1 + c2);
                    String eq = "${_toAlgStr(e1.value)} + ${_toAlgStr(e2.value)} = 180^\\circ";
                    workings.add(eq);
                    steps.add(AnglesRuleStep(title: "Algebraic Check: Solve for $v", description: "Positions ${e1.key.toUpperCase()} and ${e2.key.toUpperCase()} add to 180°.", mathLaTeX: eq));
                  }

                  seedPos = e1.key;
                  seedValue = c1 * xVal + k1;
                  solved[seedPos] = seedValue;
                  workings.add("$v = ${_fmt(xVal)}");
                  steps.add(AnglesRuleStep(title: "Calculate ${e1.key.toUpperCase()}", description: "Substitute $v to find the base angle.", mathLaTeX: "\\text{Position } ${e1.key.toUpperCase()} = ${_fmt(seedValue)}^\\circ"));
                  solvedVar = true; break;
                }
              }
              if (solvedVar) break;
            }
            if (solvedVar) break;
          }

          // Check Triplets (Triangle sum to 180)
          if (byVar[v]!.length >= 3) {
            var keys = byVar[v]!.map((e) => e.key).toList();
            if ((keys.contains('a') && keys.contains('b') && keys.contains('c')) ||
                (keys.contains('e') && keys.contains('b') && keys.contains('f'))) {

              var p1 = keys.contains('a') ? 'a' : 'e';
              var p2 = 'b';
              var p3 = keys.contains('c') ? 'c' : 'f';

              var t1 = byVar[v]!.firstWhere((e) => e.key == p1).value;
              var t2 = byVar[v]!.firstWhere((e) => e.key == p2).value;
              var t3 = byVar[v]!.firstWhere((e) => e.key == p3).value;

              double cSum = t1.coeff + t2.coeff + t3.coeff;
              double kSum = t1.constant + t2.constant + t3.constant;

              if (cSum != 0) {
                double xVal = (180 - kSum) / cSum;
                String eq = "${_toAlgStr(t1)} + ${_toAlgStr(t2)} + ${_toAlgStr(t3)} = 180^\\circ";
                workings.add(eq);
                steps.add(AnglesRuleStep(title: "Algebraic Check: Solve for $v", description: "These three angles form a straight line or a triangle, adding up to 180°.", mathLaTeX: eq));

                seedPos = p1;
                seedValue = t1.coeff * xVal + t1.constant;
                solved[seedPos] = seedValue;
                workings.add("$v = ${_fmt(xVal)}");
                break;
              }
            }
          }
        }
      }

      if (solved.isEmpty) {
        return AnglesRuleResult(diagramType: 'Triangle Parallels', finalAngles: {}, workings: [], steps: [], valid: false, errorMessage: "Not enough related angles to solve for the variable.");
      }

      // PHASE 2: Numeric Deduction Engine
      bool changed = true;
      int safeguard = 0;

      while (changed && safeguard < 20) {
        changed = false;

        bool deduce(String target, double val, String rule, String mathStr) {
          if (!solved.containsKey(target)) {
            solved[target] = val;
            steps.add(AnglesRuleStep(title: "Find Angle ${target.toUpperCase()}", description: rule, mathLaTeX: mathStr));
            workings.add(mathStr);
            return true;
          }
          return false;
        }

        // Left Transversal
        if (solved.containsKey('a')) { if (deduce('e', solved['a']!, "Alternate interior angles (Z-angles) are equal.", "E = A = ${_fmt(solved['a']!)}^\\circ")) changed = true; }
        if (solved.containsKey('e')) { if (deduce('a', solved['e']!, "Alternate interior angles (Z-angles) are equal.", "A = E = ${_fmt(solved['e']!)}^\\circ")) changed = true; }
        if (solved.containsKey('d')) { if (deduce('e', 180 - solved['d']!, "Angles on a straight line add to 180°.", "E = 180^\\circ - D = ${_fmt(180 - solved['d']!)}^\\circ")) changed = true; }
        if (solved.containsKey('e')) { if (deduce('d', 180 - solved['e']!, "Angles on a straight line add to 180°.", "D = 180^\\circ - E = ${_fmt(180 - solved['e']!)}^\\circ")) changed = true; }
        if (solved.containsKey('a')) { if (deduce('d', 180 - solved['a']!, "Interior angles on the same side add to 180°.", "D = 180^\\circ - A = ${_fmt(180 - solved['a']!)}^\\circ")) changed = true; }
        if (solved.containsKey('d')) { if (deduce('a', 180 - solved['d']!, "Interior angles on the same side add to 180°.", "A = 180^\\circ - D = ${_fmt(180 - solved['d']!)}^\\circ")) changed = true; }

        // Right Transversal
        if (solved.containsKey('c')) { if (deduce('f', solved['c']!, "Alternate interior angles (Z-angles) are equal.", "F = C = ${_fmt(solved['c']!)}^\\circ")) changed = true; }
        if (solved.containsKey('f')) { if (deduce('c', solved['f']!, "Alternate interior angles (Z-angles) are equal.", "C = F = ${_fmt(solved['f']!)}^\\circ")) changed = true; }
        if (solved.containsKey('g')) { if (deduce('f', 180 - solved['g']!, "Angles on a straight line add to 180°.", "F = 180^\\circ - G = ${_fmt(180 - solved['g']!)}^\\circ")) changed = true; }
        if (solved.containsKey('f')) { if (deduce('g', 180 - solved['f']!, "Angles on a straight line add to 180°.", "G = 180^\\circ - F = ${_fmt(180 - solved['f']!)}^\\circ")) changed = true; }
        if (solved.containsKey('c')) { if (deduce('g', 180 - solved['c']!, "Interior angles on the same side add to 180°.", "G = 180^\\circ - C = ${_fmt(180 - solved['c']!)}^\\circ")) changed = true; }
        if (solved.containsKey('g')) { if (deduce('c', 180 - solved['g']!, "Interior angles on the same side add to 180°.", "C = 180^\\circ - G = ${_fmt(180 - solved['g']!)}^\\circ")) changed = true; }

        // Triangle Sum / Straight Line Sum
        if (solved.containsKey('a') && solved.containsKey('b') && !solved.containsKey('c')) { if (deduce('c', 180 - solved['a']! - solved['b']!, "Angles on a straight line add to 180°.", "C = 180^\\circ - (${_fmt(solved['a']!)} + ${_fmt(solved['b']!)}) = ${_fmt(180 - solved['a']! - solved['b']!)}^\\circ")) changed = true; }
        if (solved.containsKey('a') && solved.containsKey('c') && !solved.containsKey('b')) { if (deduce('b', 180 - solved['a']! - solved['c']!, "Angles on a straight line add to 180°.", "B = 180^\\circ - (${_fmt(solved['a']!)} + ${_fmt(solved['c']!)}) = ${_fmt(180 - solved['a']! - solved['c']!)}^\\circ")) changed = true; }
        if (solved.containsKey('b') && solved.containsKey('c') && !solved.containsKey('a')) { if (deduce('a', 180 - solved['b']! - solved['c']!, "Angles on a straight line add to 180°.", "A = 180^\\circ - (${_fmt(solved['b']!)} + ${_fmt(solved['c']!)}) = ${_fmt(180 - solved['b']! - solved['c']!)}^\\circ")) changed = true; }

        if (solved.containsKey('e') && solved.containsKey('f') && !solved.containsKey('b')) { if (deduce('b', 180 - solved['e']! - solved['f']!, "Sum of angles in a triangle is 180°.", "B = 180^\\circ - (${_fmt(solved['e']!)} + ${_fmt(solved['f']!)}) = ${_fmt(180 - solved['e']! - solved['f']!)}^\\circ")) changed = true; }
        if (solved.containsKey('e') && solved.containsKey('b') && !solved.containsKey('f')) { if (deduce('f', 180 - solved['e']! - solved['b']!, "Sum of angles in a triangle is 180°.", "F = 180^\\circ - (${_fmt(solved['e']!)} + ${_fmt(solved['b']!)}) = ${_fmt(180 - solved['e']! - solved['b']!)}^\\circ")) changed = true; }
        if (solved.containsKey('b') && solved.containsKey('f') && !solved.containsKey('e')) { if (deduce('e', 180 - solved['b']! - solved['f']!, "Sum of angles in a triangle is 180°.", "E = 180^\\circ - (${_fmt(solved['b']!)} + ${_fmt(solved['f']!)}) = ${_fmt(180 - solved['b']! - solved['f']!)}^\\circ")) changed = true; }

        safeguard++;
      }

      // PHASE 3: Map back to user variables AND fill empty angles
      Map<String, String> finalAngles = {};
      parsed.forEach((pos, term) {
        if (term.coeff != 0 && solved.containsKey(pos)) {
          double varValue = (solved[pos]! - term.constant) / term.coeff;
          finalAngles[term.variable] = "${_fmt(varValue)}°";

          if (term.isPureVariable) {
            steps.add(AnglesRuleStep(title: "Resolve Variable ${term.variable}", description: "Position ${pos.toUpperCase()} maps directly to ${term.variable}.", mathLaTeX: "${term.variable} = ${_fmt(varValue)}^\\circ"));
          } else {
            steps.add(AnglesRuleStep(title: "Resolve Variable ${term.variable}", description: "Set the expression at Position ${pos.toUpperCase()} equal to the solved angle.", mathLaTeX: "${_toAlgStr(term)} = ${_fmt(solved[pos]!)}^\\circ \\Rightarrow ${term.variable} = ${_fmt(varValue)}"));
          }
        }
      });

      List<String> sortedKeys = ['a', 'b', 'c', 'd', 'e', 'f', 'g'];
      for (var k in sortedKeys) {
        if (solved.containsKey(k)) {
          finalAngles["Angle ${k.toUpperCase()}"] = "${_fmt(solved[k]!)}°";
        }
      }

      return AnglesRuleResult(diagramType: 'Triangle Parallels', finalAngles: finalAngles, workings: workings, steps: steps);

    } catch (e) {
      return AnglesRuleResult(diagramType: 'Triangle Parallels', finalAngles: {}, workings: [], steps: [], valid: false, errorMessage: "Invalid input format.");
    }
  }
}