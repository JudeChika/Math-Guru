import 'package:math_guru/features/junior_secondary/jss2/angles_in_a_polygon/triangle_angles/triangle_angles_model.dart';

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

/// Abstract base class for geometric rules
abstract class TriangleRule {
  final String name;
  TriangleRule(this.name);

  bool tryNumericalDeduce(Map<String, double> solved, List<TriangleAnglesStep> steps, List<String> workings);
  bool tryAlgebraicDeduce(Map<String, AlgTerm> inputs, Map<String, double> solved, List<TriangleAnglesStep> steps, List<String> workings);

  String fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}

/// Rule for angles that sum up to a target (e.g. 180 for triangles/straight lines)
class SumRule extends TriangleRule {
  final List<String> positions;
  final double target;

  SumRule(this.positions, this.target, String name) : super(name);

  @override
  bool tryNumericalDeduce(Map<String, double> solved, List<TriangleAnglesStep> steps, List<String> workings) {
    int missing = 0;
    String? missingPos;
    double sum = 0;
    for (var p in positions) {
      if (solved.containsKey(p)) { sum += solved[p]!; }
      else { missing++; missingPos = p; }
    }

    if (missing == 1) {
      double val = target - sum;
      solved[missingPos!] = val;

      String formula = "${positions.map((p) => p.toUpperCase()).join(' + ')} = ${fmt(target)}^\\circ";
      String substitution = "${positions.map((p) => p == missingPos ? missingPos!.toUpperCase() : "${fmt(solved[p]!)}^\\circ").join(' + ')} = ${fmt(target)}^\\circ";
      String simplification = "${fmt(sum)}^\\circ + ${missingPos.toUpperCase()} = ${fmt(target)}^\\circ";
      String isolation = "${missingPos.toUpperCase()} = ${fmt(target)}^\\circ - ${fmt(sum)}^\\circ";
      String result = "${missingPos.toUpperCase()} = ${fmt(val)}^\\circ";

      workings.addAll([formula, substitution, simplification, isolation, result]);
      workings.add(""); // Add empty line after calculation

      steps.add(TriangleAnglesStep(
          title: "Step 1: Apply the Formula",
          description: "Rule: $name.\nFirst, we write out the geometric formula for the angles.",
          mathLaTeX: formula
      ));

      steps.add(TriangleAnglesStep(
          title: "Step 2: Substitute Known Values",
          description: "Next, we replace the letters with the angle numbers we already know, and add them together.",
          mathLaTeX: "$substitution \\Rightarrow $simplification"
      ));

      steps.add(TriangleAnglesStep(
          title: "Step 3: Solve for Angle ${missingPos.toUpperCase()}",
          description: "Finally, we subtract our total from ${fmt(target)}° to find the missing angle.",
          mathLaTeX: "$isolation \\Rightarrow $result"
      ));

      return true;
    }
    return false;
  }

  @override
  bool tryAlgebraicDeduce(Map<String, AlgTerm> inputs, Map<String, double> solved, List<TriangleAnglesStep> steps, List<String> workings) {
    bool hasAll = true;
    double coeffSum = 0;
    double constSum = 0;
    Set<String> vars = {};
    List<String> exprs = [];

    for (var p in positions) {
      if (solved.containsKey(p)) {
        constSum += solved[p]!;
        exprs.add("${fmt(solved[p]!)}^\\circ");
      } else if (inputs.containsKey(p)) {
        var t = inputs[p]!;
        coeffSum += t.coeff;
        constSum += t.constant;
        if (t.variable.isNotEmpty) vars.add(t.variable);
        exprs.add(t.rawString);
      } else {
        hasAll = false; break;
      }
    }

    if (hasAll && vars.length == 1) {
      String v = vars.first;
      if (coeffSum != 0) {
        double xVal = (target - constSum) / coeffSum;

        String formula = "${positions.map((p) => p.toUpperCase()).join(' + ')} = ${fmt(target)}^\\circ";
        String eq1 = "${exprs.join(' + ')} = ${fmt(target)}^\\circ";

        workings.add(formula);
        workings.add(eq1);

        steps.add(TriangleAnglesStep(
            title: "Set up the Equation",
            description: "Rule: $name.\nWe add all the algebraic expressions together and set them equal to ${fmt(target)}°.",
            mathLaTeX: eq1
        ));

        if (exprs.length > 1) {
          String sign = constSum < 0 ? '-' : '+';
          String eq2 = "${fmt(coeffSum)}$v $sign ${fmt(constSum.abs())} = ${fmt(target)}^\\circ";
          workings.add(eq2);
          steps.add(TriangleAnglesStep(
              title: "Group Like Terms",
              description: "We collect and add all the '$v's together, and we add all the plain numbers together.",
              mathLaTeX: eq2
          ));
        }

        double diff = target - constSum;
        String moveSign = constSum < 0 ? '+' : '-';
        String eq3 = "${fmt(coeffSum)}$v = ${fmt(target)}^\\circ $moveSign ${fmt(constSum.abs())}^\\circ";
        String eq4 = "${fmt(coeffSum)}$v = ${fmt(diff)}^\\circ";

        workings.add(eq3);
        workings.add(eq4);

        steps.add(TriangleAnglesStep(
            title: "Isolate the Unknown Variable",
            description: "We move the plain number to the other side of the equals sign. Remember, when a number crosses the equals sign, its sign changes (positive becomes negative, negative becomes positive).",
            mathLaTeX: eq4
        ));

        String res = "$v = ${fmt(xVal)}";
        if (coeffSum != 1 && coeffSum != -1) {
          String eq5 = "$v = \\frac{${fmt(diff)}^\\circ}{${fmt(coeffSum)}}";
          workings.add(eq5);
          workings.add(res);
          steps.add(TriangleAnglesStep(
              title: "Solve for '$v'",
              description: "Divide both sides by ${fmt(coeffSum)} to find the final value of '$v'.",
              mathLaTeX: "$eq5 \\Rightarrow $res"
          ));
        } else {
          workings.add(res);
          steps.add(TriangleAnglesStep(
              title: "Solve for '$v'",
              description: "We have successfully found the value of our unknown variable!",
              mathLaTeX: res
          ));
        }

        workings.add(""); // Add empty line after variable is solved

        bool substituted = false;
        inputs.forEach((pos, term) {
          if (term.variable == v && !solved.containsKey(pos)) {
            double val = term.coeff * xVal + term.constant;
            solved[pos] = val;

            String subLatex = "${pos.toUpperCase()} = ${AnglesRulesSolver._toAlgStr(term)}";
            String subLatex2 = "${pos.toUpperCase()} = ${fmt(term.coeff)}(${fmt(xVal)}) ${term.constant < 0 ? '-' : '+'} ${fmt(term.constant.abs())}";
            String finalVal = "${pos.toUpperCase()} = ${fmt(val)}^\\circ";

            workings.add(subLatex);
            workings.add(subLatex2);
            workings.add(finalVal);
            workings.add(""); // Add empty line after substitution

            steps.add(TriangleAnglesStep(
                title: "Calculate Angle ${pos.toUpperCase()}",
                description: "Now that we know $v = ${fmt(xVal)}, we replace '$v' in the original expression with ${fmt(xVal)} and solve it to find the actual angle.",
                mathLaTeX: "$subLatex2 \\Rightarrow $finalVal"
            ));
            substituted = true;
          }
        });
        return substituted;
      }
    }
    return false;
  }
}

/// Rule for angles that are perfectly equal (e.g. Isosceles Base Angles)
class EqualRule extends TriangleRule {
  final String p1, p2;

  EqualRule(this.p1, this.p2, String name) : super(name);

  @override
  bool tryNumericalDeduce(Map<String, double> solved, List<TriangleAnglesStep> steps, List<String> workings) {
    if (solved.containsKey(p1) && !solved.containsKey(p2)) {
      solved[p2] = solved[p1]!;
      String formula = "${p2.toUpperCase()} = ${p1.toUpperCase()}";
      String res = "${p2.toUpperCase()} = ${fmt(solved[p1]!)}^\\circ";

      workings.add(formula);
      workings.add(res);
      workings.add(""); // Add empty line

      steps.add(TriangleAnglesStep(
          title: "Find Angle ${p2.toUpperCase()}",
          description: "Rule: $name.\nThis means angle ${p2.toUpperCase()} is exactly the same as angle ${p1.toUpperCase()}. We just copy the value over!",
          mathLaTeX: "$formula \\Rightarrow $res"
      ));
      return true;
    }
    if (solved.containsKey(p2) && !solved.containsKey(p1)) {
      solved[p1] = solved[p2]!;
      String formula = "${p1.toUpperCase()} = ${p2.toUpperCase()}";
      String res = "${p1.toUpperCase()} = ${fmt(solved[p2]!)}^\\circ";

      workings.add(formula);
      workings.add(res);
      workings.add(""); // Add empty line

      steps.add(TriangleAnglesStep(
          title: "Find Angle ${p1.toUpperCase()}",
          description: "Rule: $name.\nThis means angle ${p1.toUpperCase()} is exactly the same as angle ${p2.toUpperCase()}. We just copy the value over!",
          mathLaTeX: "$formula \\Rightarrow $res"
      ));
      return true;
    }
    return false;
  }

  @override
  bool tryAlgebraicDeduce(Map<String, AlgTerm> inputs, Map<String, double> solved, List<TriangleAnglesStep> steps, List<String> workings) {
    if (!solved.containsKey(p1) && !solved.containsKey(p2) && inputs.containsKey(p1) && inputs.containsKey(p2)) {
      var t1 = inputs[p1]!;
      var t2 = inputs[p2]!;
      Set<String> vars = {};
      if (t1.variable.isNotEmpty) vars.add(t1.variable);
      if (t2.variable.isNotEmpty) vars.add(t2.variable);

      if (vars.length == 1) {
        String v = vars.first;
        double cDiff = t1.coeff - t2.coeff;
        double kDiff = t2.constant - t1.constant;

        if (cDiff != 0) {
          double xVal = kDiff / cDiff;

          String eq1 = "${t1.rawString} = ${t2.rawString}";
          workings.add(eq1);
          steps.add(TriangleAnglesStep(
              title: "Set up the Equation",
              description: "Rule: $name.\nBecause the angles are identical, we set their algebraic expressions equal to each other.",
              mathLaTeX: eq1
          ));

          String eq2 = "${fmt(t1.coeff)}$v - ${fmt(t2.coeff)}$v = ${fmt(t2.constant)} - ${fmt(t1.constant)}";
          String eq3 = "${fmt(cDiff)}$v = ${fmt(kDiff)}";

          workings.add(eq2);
          workings.add(eq3);
          steps.add(TriangleAnglesStep(
              title: "Group Like Terms",
              description: "We bring all the '$v's to the left side of the equals sign, and all the plain numbers to the right side. Remember to change their signs when crossing over!",
              mathLaTeX: "$eq2 \\Rightarrow $eq3"
          ));

          String res = "$v = ${fmt(xVal)}";
          if (cDiff != 1 && cDiff != -1) {
            String eq4 = "$v = \\frac{${fmt(kDiff)}}{${fmt(cDiff)}}";
            workings.add(eq4);
            workings.add(res);
            steps.add(TriangleAnglesStep(
                title: "Solve for '$v'",
                description: "Divide both sides by ${fmt(cDiff)} to find '$v'.",
                mathLaTeX: "$eq4 \\Rightarrow $res"
            ));
          } else {
            workings.add(res);
            steps.add(TriangleAnglesStep(
                title: "Solve for '$v'",
                description: "We have found the value of our unknown variable!",
                mathLaTeX: res
            ));
          }

          workings.add(""); // Add empty line after variable is solved

          bool substituted = false;
          inputs.forEach((pos, term) {
            if (term.variable == v && !solved.containsKey(pos)) {
              double val = term.coeff * xVal + term.constant;
              solved[pos] = val;

              String subLatex = "${pos.toUpperCase()} = ${AnglesRulesSolver._toAlgStr(term)}";
              String subLatex2 = "${pos.toUpperCase()} = ${fmt(term.coeff)}(${fmt(xVal)}) ${term.constant < 0 ? '-' : '+'} ${fmt(term.constant.abs())}";
              String finalVal = "${pos.toUpperCase()} = ${fmt(val)}^\\circ";

              workings.add(subLatex);
              workings.add(subLatex2);
              workings.add(finalVal);
              workings.add(""); // Add empty line after substitution

              steps.add(TriangleAnglesStep(
                  title: "Calculate Angle ${pos.toUpperCase()}",
                  description: "Now that we know $v = ${fmt(xVal)}, we replace '$v' in the expression and solve it to find the actual angle.",
                  mathLaTeX: "$subLatex2 \\Rightarrow $finalVal"
              ));
              substituted = true;
            }
          });
          return substituted;
        }
      }
    }
    return false;
  }
}

/// Rule for angles with fixed values (e.g. Equilateral triangles)
class FixedRule extends TriangleRule {
  final String pos;
  final double val;

  FixedRule(this.pos, this.val, String name) : super(name);

  @override
  bool tryNumericalDeduce(Map<String, double> solved, List<TriangleAnglesStep> steps, List<String> workings) {
    if (!solved.containsKey(pos)) {
      solved[pos] = val;
      String res = "${pos.toUpperCase()} = ${fmt(val)}^\\circ";
      workings.add(res);
      workings.add(""); // Add empty line
      steps.add(TriangleAnglesStep(
          title: "Find Angle ${pos.toUpperCase()}",
          description: "Rule: $name.\nWe don't need to calculate anything, this angle is a fixed rule in geometry!",
          mathLaTeX: res
      ));
      return true;
    }
    return false;
  }

  @override
  bool tryAlgebraicDeduce(Map<String, AlgTerm> inputs, Map<String, double> solved, List<TriangleAnglesStep> steps, List<String> workings) => false;
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
      } else if (t.coeff == -1) cStr = "-";
      else cStr = _fmt(t.coeff);
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
        } else if (cStr == '-') coeff -= 1;
        else coeff += double.parse(cStr);
      } else if (RegExp(r'^[+-]?\d*\.?\d+$').hasMatch(p)) {
        constant += double.parse(p);
      }
    }
    return AlgTerm(coeff, constant, variable, input.trim());
  }

  /// Master Inference Engine for solving Triangles
  static TriangleAnglesResult solveTriangleDiagram(Map<String, String> inputs, int diagramType) {
    try {
      Map<String, AlgTerm> parsed = {};
      inputs.forEach((k, v) {
        var t = _parseTerm(v);
        if (t != null) parsed[k] = t;
      });

      if (parsed.isEmpty && diagramType != 3) { // Diagram 3 (Equilateral) solves itself
        return TriangleAnglesResult(diagramType: 'Triangle', finalAngles: {}, workings: [], steps: [], valid: false, errorMessage: "Enter at least one known angle.");
      }

      Map<String, double> solved = {};
      List<TriangleAnglesStep> steps = [];
      List<String> workings = [];

      // Phase 1: Seed Pure Numbers
      parsed.forEach((pos, term) {
        if (term.isPureNumber) {
          if (term.constant <= 0 || term.constant >= 360) throw const FormatException();
          solved[pos] = term.constant;
          workings.add("${pos.toUpperCase()} = ${_fmt(term.constant)}^\\circ \\quad \\text{(Given)}");
          workings.add(""); // Add empty line
        }
      });

      // Phase 2: Build the Rulebook based on selected diagram
      List<TriangleRule> rules = [];
      if (diagramType == 0) {
        rules.add(SumRule(['a', 'b', 'c'], 180, "The sum of angles in a triangle is exactly 180°"));
      } else if (diagramType == 1) {
        rules.add(SumRule(['a', 'b', 'c'], 180, "The sum of angles in a triangle is exactly 180°"));
        rules.add(SumRule(['b', 'd'], 180, "Adjacent angles on a straight line add up to 180°"));
        rules.add(SumRule(['c', 'e'], 180, "Adjacent angles on a straight line add up to 180°"));
      } else if (diagramType == 2) {
        rules.add(EqualRule('b', 'c', "Base angles of an isosceles triangle are always equal"));
        rules.add(SumRule(['a', 'b', 'c'], 180, "The sum of angles in a triangle is exactly 180°"));
      } else if (diagramType == 3) {
        rules.add(FixedRule('a', 60, "Every interior angle in an equilateral triangle is 60°"));
        rules.add(FixedRule('b', 60, "Every interior angle in an equilateral triangle is 60°"));
        rules.add(FixedRule('c', 60, "Every interior angle in an equilateral triangle is 60°"));
        rules.add(SumRule(['c', 'd'], 180, "Adjacent angles on a straight line add up to 180°"));
      } else if (diagramType == 4) {
        rules.add(SumRule(['a', 'b', 'c'], 180, "Sum of angles in the Left triangle is 180°"));
        rules.add(SumRule(['d', 'e', 'f'], 180, "Sum of angles in the Right triangle is 180°"));
        rules.add(SumRule(['c', 'e'], 180, "Adjacent angles on a straight line base add up to 180°"));
        rules.add(SumRule(['a', 'd', 'b', 'f'], 180, "Sum of angles in the large outer triangle is 180°"));
      }

      // Phase 3: Iterative Deduction Loop
      bool changed = true;
      int safeguard = 0;

      while (changed && safeguard < 20) {
        changed = false;

        // Try purely numerical deductions first (easier to explain to kids)
        for (var rule in rules) {
          if (rule.tryNumericalDeduce(solved, steps, workings)) {
            changed = true;
          }
        }
        if (changed) continue;

        // If numerical is stuck, try algebraic solving
        for (var rule in rules) {
          if (rule.tryAlgebraicDeduce(parsed, solved, steps, workings)) {
            changed = true;
            break;
          }
        }
        safeguard++;
      }

      if (solved.isEmpty && diagramType != 3) {
        return TriangleAnglesResult(diagramType: 'Triangle', finalAngles: {}, workings: [], steps: [], valid: false, errorMessage: "Not enough related information to solve. Please provide more values or matching variables.");
      }

      // Phase 4: Map back to user variables and finalize output
      Map<String, String> finalAngles = {};
      parsed.forEach((pos, term) {
        if (term.coeff != 0 && solved.containsKey(pos)) {
          double varValue = (solved[pos]! - term.constant) / term.coeff;
          finalAngles[term.variable] = "${_fmt(varValue)}°";
        }
      });

      // Add the final numerical values of the standard positions
      List<String> expectedKeys = [];
      if (diagramType == 0) expectedKeys = ['a', 'b', 'c'];
      if (diagramType == 1) expectedKeys = ['a', 'b', 'c', 'd', 'e'];
      if (diagramType == 2) expectedKeys = ['a', 'b', 'c'];
      if (diagramType == 3) expectedKeys = ['a', 'b', 'c', 'd'];
      if (diagramType == 4) expectedKeys = ['a', 'b', 'c', 'd', 'e', 'f'];

      for (var k in expectedKeys) {
        if (solved.containsKey(k)) {
          finalAngles["Angle ${k.toUpperCase()}"] = "${_fmt(solved[k]!)}°";
        }
      }

      return TriangleAnglesResult(diagramType: 'Triangle', finalAngles: finalAngles, workings: workings, steps: steps);

    } catch (e) {
      return TriangleAnglesResult(diagramType: 'Triangle', finalAngles: {}, workings: [], steps: [], valid: false, errorMessage: "Invalid input format.");
    }
  }
}