import 'dart:math' as math;
import 'pythagoras_models.dart';

class PythagorasLogic {

  /// Formats decimals neatly, dropping trailing .0
  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  static String _fmt2SF(double v) {
    if (v == 0) return "0";
    int d = (math.log(v.abs()) / math.ln10).floor();
    double scale = math.pow(10, 1 - d).toDouble();
    double rounded = (v * scale).roundToDouble() / scale;
    String str = rounded.toString();
    if (str.endsWith('.0')) {
      str = str.substring(0, str.length - 2);
    }
    return str;
  }

  static bool _isNumeric(String s) {
    if (s.trim().isEmpty) return false;
    return double.tryParse(s.replaceAll(RegExp(r'[^\d\.]'), '')) != null;
  }

  static double _parse(String s) {
    return double.parse(s.replaceAll(RegExp(r'[^\d\.]'), ''));
  }

  static double? _getSq(String val, Map<String, double> knowns) {
    String cleanVal = val.trim();
    if (cleanVal.isEmpty) return null;

    if (_isNumeric(cleanVal)) {
      double v = _parse(cleanVal);
      return v * v;
    } else {
      if (knowns.containsKey(cleanVal)) return knowns[cleanVal];
      return null;
    }
  }

  static PythagorasResult solveSingle(PythagorasTriangleData t, String unit) {
    try {
      List<PythagorasStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};
      List<SolvedTriangle> shapes = [];

      String uStr = unit.trim().isNotEmpty ? "\\text{ ${unit.trim()}}" : "";
      String plainUStr = unit.trim().isNotEmpty ? " ${unit.trim()}" : "";

      bool bNum = _isNumeric(t.base);
      bool hNum = _isNumeric(t.height);
      bool hypNum = _isNumeric(t.hypotenuse);

      int numCount = (bNum ? 1 : 0) + (hNum ? 1 : 0) + (hypNum ? 1 : 0);
      if (numCount != 2) throw const FormatException("Provide exactly two known numeric sides.");

      String unknownVar = "";
      if (!bNum) unknownVar = t.base.trim().isEmpty ? "a" : t.base.trim();
      if (!hNum) unknownVar = t.height.trim().isEmpty ? "b" : t.height.trim();
      if (!hypNum) unknownVar = t.hypotenuse.trim().isEmpty ? "c" : t.hypotenuse.trim();

      String bStr = bNum ? _fmt(_parse(t.base)) : unknownVar;
      String hStr = hNum ? _fmt(_parse(t.height)) : unknownVar;
      String hypStr = hypNum ? _fmt(_parse(t.hypotenuse)) : unknownVar;

      workings.add("\\text{\\textbf{Triangle ${t.name}}}");
      workings.add("\\text{By Pythagoras' rule:}");
      workings.add("\\text{Hypotenuse}^2 = \\text{Base}^2 + \\text{Height}^2");

      steps.add(PythagorasStep(
          title: "Step 1: State Pythagoras' Rule",
          description: "Always start by stating the famous rule. The square of the longest side (the hypotenuse) is equal to the sum of the squares of the other two sides.",
          mathLaTeX: "\\text{Hyp}^2 = \\text{Base}^2 + \\text{Height}^2"
      ));

      workings.add("$hypStr^2 = $bStr^2 + $hStr^2");

      double finalVal = 0;

      if (!hypNum) {
        // FINDING HYPOTENUSE
        double bVal = _parse(t.base);
        double hVal = _parse(t.height);

        workings.add("$unknownVar^2 = ${_fmt(bVal*bVal)} + ${_fmt(hVal*hVal)}");
        workings.add("$unknownVar^2 = ${_fmt(bVal*bVal + hVal*hVal)}");

        steps.add(PythagorasStep(
            title: "Step 2: Square the Known Sides",
            description: "Substitute the known values into the equation and square them. Then, add the results together.",
            mathLaTeX: "$unknownVar^2 = ${_fmt(bVal*bVal)} + ${_fmt(hVal*hVal)} = ${_fmt(bVal*bVal + hVal*hVal)}"
        ));

        double sumSq = bVal*bVal + hVal*hVal;
        workings.add("\\sqrt{$unknownVar^2} = \\sqrt{${_fmt(sumSq)}}");

        finalVal = math.sqrt(sumSq);
        String ansStr = (finalVal % 1 == 0) ? _fmt(finalVal) : _fmt2SF(finalVal);

        if (finalVal % 1 != 0) {
          workings.add("$unknownVar = ${_fmt(finalVal)}$uStr \\approx $ansStr$uStr \\text{ (2 s.f.)}");
        } else {
          workings.add("$unknownVar = ${_fmt(finalVal)}$uStr");
        }

        steps.add(PythagorasStep(
            title: "Step 3: Find the Square Root",
            description: "The opposite of squaring a number is finding its square root. To isolate '$unknownVar', we take the square root of both sides.",
            mathLaTeX: "\\sqrt{$unknownVar^2} = \\sqrt{${_fmt(sumSq)}} \\Rightarrow $unknownVar = $ansStr$uStr"
        ));

        shapes.add(SolvedTriangle(
            name: t.name, baseVal: bVal, heightVal: hVal, hypVal: finalVal,
            baseLabel: "$bStr$plainUStr", heightLabel: "$hStr$plainUStr", hypLabel: "$ansStr$plainUStr"
        ));

      } else {
        // FINDING A SHORTER SIDE
        double hypVal = _parse(t.hypotenuse);
        double knownVal = bNum ? _parse(t.base) : _parse(t.height);

        workings.add("${_fmt(hypVal*hypVal)} = $unknownVar^2 + ${_fmt(knownVal*knownVal)}");

        steps.add(PythagorasStep(
            title: "Step 2: Square the Known Sides",
            description: "Substitute the known values into the equation and square them. Be careful: the unknown is NOT the hypotenuse this time!",
            mathLaTeX: "${_fmt(hypVal*hypVal)} = $unknownVar^2 + ${_fmt(knownVal*knownVal)}"
        ));

        double hypSq = hypVal*hypVal;
        double knSq = knownVal*knownVal;

        workings.add("${_fmt(hypSq)} - ${_fmt(knSq)} = $unknownVar^2 + ${_fmt(knSq)} - ${_fmt(knSq)}");
        workings.add("${_fmt(hypSq - knSq)} = $unknownVar^2");
        workings.add("$unknownVar^2 = ${_fmt(hypSq - knSq)}");

        steps.add(PythagorasStep(
            title: "Step 3: Balance the Equation",
            description: "To isolate '$unknownVar²', we must subtract ${_fmt(knSq)} from BOTH sides of the equation to keep it perfectly balanced.",
            mathLaTeX: "${_fmt(hypSq)} - ${_fmt(knSq)} = $unknownVar^2"
        ));

        double diffSq = hypSq - knSq;
        if (diffSq < 0) throw const FormatException("Hypotenuse must be the longest side.");

        workings.add("\\sqrt{$unknownVar^2} = \\sqrt{${_fmt(diffSq)}}");

        finalVal = math.sqrt(diffSq);
        String ansStr = (finalVal % 1 == 0) ? _fmt(finalVal) : _fmt2SF(finalVal);

        if (finalVal % 1 != 0) {
          workings.add("$unknownVar = ${_fmt(finalVal)}$uStr \\approx $ansStr$uStr \\text{ (2 s.f.)}");
        } else {
          workings.add("$unknownVar = ${_fmt(finalVal)}$uStr");
        }

        steps.add(PythagorasStep(
            title: "Step 4: Find the Square Root",
            description: "To isolate '$unknownVar', we take the square root of the remaining value.",
            mathLaTeX: "\\sqrt{$unknownVar^2} = \\sqrt{${_fmt(diffSq)}} \\Rightarrow $unknownVar = $ansStr$uStr"
        ));

        shapes.add(SolvedTriangle(
            name: t.name,
            baseVal: bNum ? knownVal : finalVal,
            heightVal: hNum ? knownVal : finalVal,
            hypVal: hypVal,
            baseLabel: "${bNum ? _fmt(knownVal) : ansStr}$plainUStr",
            heightLabel: "${hNum ? _fmt(knownVal) : ansStr}$plainUStr",
            hypLabel: "${_fmt(hypVal)}$plainUStr"
        ));
      }

      String finalAnsStr = (finalVal % 1 == 0) ? _fmt(finalVal) : _fmt2SF(finalVal);
      answers[unknownVar] = "$finalAnsStr$uStr";
      return PythagorasResult(mode: 'Single', finalAnswers: answers, workingsLaTeX: workings, steps: steps, drawnTriangles: shapes);

    } catch (e) {
      return PythagorasResult(mode: 'Single', finalAnswers: {}, workingsLaTeX: [], steps: [], drawnTriangles: [], valid: false, errorMessage: e is FormatException ? e.message : "Invalid input parameters.");
    }
  }

  static PythagorasResult solveComposite(List<PythagorasTriangleData> triangles, String unit) {
    try {
      if (triangles.length < 2) throw const FormatException("Add at least two triangles for composite mode.");

      String uStr = unit.trim().isNotEmpty ? "\\text{ ${unit.trim()}}" : "";
      String plainUStr = unit.trim().isNotEmpty ? " ${unit.trim()}" : "";
      String uSqStr = unit.trim().isNotEmpty ? "\\text{ ${unit.trim()}}^2" : "";

      List<PythagorasStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};
      List<SolvedTriangle> shapes = [];

      Map<String, double> knownSq = {}; // Stores x^2, y^2, etc to avoid decimals

      for (int i = 0; i < triangles.length; i++) {
        var t = triangles[i];

        workings.add("\\text{\\textbf{Part ${i+1}: Triangle ${t.name}}}");
        workings.add("\\text{By Pythagoras' rule:}");
        workings.add("\\text{Hypotenuse}^2 = \\text{Base}^2 + \\text{Height}^2");

        String bStr = t.base.trim();
        String hStr = t.height.trim();
        String hypStr = t.hypotenuse.trim();

        double? bSq = _getSq(bStr, knownSq);
        double? hSq = _getSq(hStr, knownSq);
        double? hypSq = _getSq(hypStr, knownSq);

        int unknowns = (bSq == null ? 1 : 0) + (hSq == null ? 1 : 0) + (hypSq == null ? 1 : 0);

        if (unknowns > 1) {
          throw FormatException("Triangle '${t.name}' is missing a shared link! Please use the exact letter (e.g., 'y') from the previous triangle to connect them.");
        } else if (unknowns == 0) {
          throw FormatException("Triangle '${t.name}' has no unknown variables to solve for.");
        }

        String unkVar = "";
        if (bSq == null) unkVar = bStr.isEmpty ? "x" : bStr;
        if (hSq == null) unkVar = hStr.isEmpty ? "x" : hStr;
        if (hypSq == null) unkVar = hypStr.isEmpty ? "x" : hypStr;

        String kbStr = bSq != null ? (knownSq.containsKey(bStr) ? bStr : _fmt(_parse(bStr))) : unkVar;
        String khStr = hSq != null ? (knownSq.containsKey(hStr) ? hStr : _fmt(_parse(hStr))) : unkVar;
        String khypStr = hypSq != null ? (knownSq.containsKey(hypStr) ? hypStr : _fmt(_parse(hypStr))) : unkVar;

        workings.add("$khypStr^2 = $kbStr^2 + $khStr^2");

        steps.add(PythagorasStep(
            title: "Step ${i*2 + 1}: Set up Triangle ${t.name}",
            description: i == 0
                ? "Start with the triangle where two sides are known. State Pythagoras' rule."
                : "Move to the next triangle. State Pythagoras' rule, then substitute the squared value ($khypStr², $kbStr², or $khStr²) directly into the equation to avoid messy decimals!",
            mathLaTeX: "\\text{Hyp}^2 = \\text{Base}^2 + \\text{Height}^2 \\Rightarrow $khypStr^2 = $kbStr^2 + $khStr^2"
        ));

        double targetSq = 0;

        if (hypSq == null) {
          targetSq = bSq! + hSq!;
          knownSq[unkVar] = targetSq;
          workings.add("$unkVar^2 = ${_fmt(bSq)} + ${_fmt(hSq)}");
          workings.add("$unkVar^2 = ${_fmt(targetSq)}");

          steps.add(PythagorasStep(
              title: "Step ${i*2 + 2}: Solve for $unkVar²",
              description: "Add the squared sides together.",
              mathLaTeX: "$unkVar^2 = ${_fmt(targetSq)}"
          ));

        } else {
          double knSq = bSq ?? hSq!;
          workings.add("${_fmt(hypSq)} = $unkVar^2 + ${_fmt(knSq)}");
          workings.add("${_fmt(hypSq)} - ${_fmt(knSq)} = $unkVar^2");

          targetSq = hypSq - knSq;
          if (targetSq < 0) throw FormatException("Hypotenuse must be the longest side in Triangle '${t.name}'.");

          knownSq[unkVar] = targetSq;
          workings.add("$unkVar^2 = ${_fmt(targetSq)}");

          steps.add(PythagorasStep(
              title: "Step ${i*2 + 2}: Solve for $unkVar²",
              description: "Subtract the known square from the hypotenuse square to isolate $unkVar².",
              mathLaTeX: "$unkVar^2 = ${_fmt(targetSq)}"
          ));
        }

        if (i == triangles.length - 1) {
          double finalVal = math.sqrt(targetSq);
          workings.add("$unkVar = \\sqrt{${_fmt(targetSq)}}");

          String ansStr = (finalVal % 1 == 0) ? _fmt(finalVal) : _fmt2SF(finalVal);
          if (finalVal % 1 != 0) {
            workings.add("$unkVar = ${_fmt(finalVal)}$uStr \\approx $ansStr$uStr \\text{ (2 s.f.)}");
          } else {
            workings.add("$unkVar = ${_fmt(finalVal)}$uStr");
          }

          answers[unkVar] = "$ansStr$uStr";

          steps.add(PythagorasStep(
              title: "Final Step: Find the Square Root",
              description: "Because this is our final target variable, we take the square root of $unkVar² to find the exact length.",
              mathLaTeX: "\\sqrt{$unkVar^2} = \\sqrt{${_fmt(targetSq)}} \\Rightarrow $unkVar = $ansStr$uStr"
          ));
        } else {
          workings.add("");
          answers["$unkVar^2"] = "${_fmt(targetSq)}$uSqStr";
        }

        double actualB = math.sqrt(bSq ?? targetSq);
        double actualH = math.sqrt(hSq ?? targetSq);
        double actualHyp = math.sqrt(hypSq ?? targetSq);

        shapes.add(SolvedTriangle(
            name: t.name,
            baseVal: actualB, heightVal: actualH, hypVal: actualHyp,
            baseLabel: "$kbStr$plainUStr", heightLabel: "$khStr$plainUStr", hypLabel: "$khypStr$plainUStr"
        ));
      }

      return PythagorasResult(mode: 'Composite', finalAnswers: answers, workingsLaTeX: workings, steps: steps, drawnTriangles: shapes);

    } catch (e) {
      return PythagorasResult(mode: 'Composite', finalAnswers: {}, workingsLaTeX: [], steps: [], drawnTriangles: [], valid: false, errorMessage: e is FormatException ? e.message : "Invalid input parameters.");
    }
  }

  static PythagorasResult solveRealLife({
    required String scenarioType,
    required String baseStr,
    required String heightStr,
    required String hypStr,
    required String unit
  }) {
    try {
      String uStr = unit.trim().isNotEmpty ? "\\text{ ${unit.trim()}}" : "";
      String plainUStr = unit.trim().isNotEmpty ? " ${unit.trim()}" : "";

      // Contextual Dictionaries for Real-Life Archetypes
      String baseName = "Base";
      String heightName = "Height";
      String hypName = "Hypotenuse";
      String scenarioDesc = "In this problem, the real-world scenario forms a right-angled triangle. ";

      if (scenarioType == 'ladder') {
        baseName = "Ground"; heightName = "Wall"; hypName = "Ladder";
        scenarioDesc += "The ladder leaning against the wall is the longest side (the hypotenuse). The wall is the vertical height, and the distance along the floor is the base.";
      } else if (scenarioType == 'rectangle') {
        baseName = "Length"; heightName = "Width"; hypName = "Diagonal";
        scenarioDesc += "The diagonal line cuts the rectangle into two right-angled triangles. The diagonal is the hypotenuse, and the length and width are the two shorter sides.";
      } else if (scenarioType == 'navigation') {
        baseName = "East/West"; heightName = "North/South"; hypName = "Direct Dist.";
        scenarioDesc += "Because North/South and East/West directions meet at a 90° angle, the path forms a right-angled triangle. The shortest direct distance back is the hypotenuse.";
      } else if (scenarioType == 'pole') {
        baseName = "Ground"; heightName = "Pole/Mast"; hypName = "Wire/Cable";
        scenarioDesc += "The pole stands perfectly vertical to the ground (90°). The supporting wire stretching from the top to the ground is the hypotenuse.";
      }

      bool bNum = _isNumeric(baseStr);
      bool hNum = _isNumeric(heightStr);
      bool hypNum = _isNumeric(hypStr);

      int numCount = (bNum ? 1 : 0) + (hNum ? 1 : 0) + (hypNum ? 1 : 0);
      if (numCount != 2) throw const FormatException("Provide exactly two known numeric measurements.");

      String unknownVar = "";
      if (!bNum) unknownVar = baseStr.trim().isEmpty ? "x" : baseStr.trim();
      if (!hNum) unknownVar = heightStr.trim().isEmpty ? "y" : heightStr.trim();
      if (!hypNum) unknownVar = hypStr.trim().isEmpty ? "z" : hypStr.trim();

      String bValStr = bNum ? _fmt(_parse(baseStr)) : unknownVar;
      String hValStr = hNum ? _fmt(_parse(heightStr)) : unknownVar;
      String hypValStr = hypNum ? _fmt(_parse(hypStr)) : unknownVar;

      List<PythagorasStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};

      workings.add("\\text{\\textbf{Real-Life Geometry Model}}");
      workings.add("\\text{Hypotenuse ($hypName)}^2 = \\text{Base ($baseName)}^2 + \\text{Height ($heightName)}^2");

      steps.add(PythagorasStep(
          title: "Step 1: Translate to Geometry",
          description: scenarioDesc,
          mathLaTeX: "\\text{$hypName}^2 = \\text{$baseName}^2 + \\text{$heightName}^2"
      ));

      workings.add("$hypValStr^2 = $bValStr^2 + $hValStr^2");

      double finalVal = 0;
      double bDraw = 0, hDraw = 0, hypDraw = 0;

      if (!hypNum) {
        // Find Hypotenuse
        double bVal = _parse(baseStr);
        double hVal = _parse(heightStr);
        bDraw = bVal; hDraw = hVal;

        workings.add("$unknownVar^2 = ${_fmt(bVal*bVal)} + ${_fmt(hVal*hVal)}");
        workings.add("$unknownVar^2 = ${_fmt(bVal*bVal + hVal*hVal)}");

        steps.add(PythagorasStep(
            title: "Step 2: Apply Pythagoras' Rule",
            description: "Substitute the known real-world values into the equation, square them, and add the results together.",
            mathLaTeX: "$unknownVar^2 = ${_fmt(bVal*bVal)} + ${_fmt(hVal*hVal)} = ${_fmt(bVal*bVal + hVal*hVal)}"
        ));

        double sumSq = bVal*bVal + hVal*hVal;
        finalVal = math.sqrt(sumSq);
        hypDraw = finalVal;

        workings.add("\\sqrt{$unknownVar^2} = \\sqrt{${_fmt(sumSq)}}");
        String ansStr = (finalVal % 1 == 0) ? _fmt(finalVal) : _fmt2SF(finalVal);

        if (finalVal % 1 != 0) {
          workings.add("$unknownVar = ${_fmt(finalVal)}$uStr \\approx $ansStr$uStr \\text{ (2 s.f.)}");
        } else {
          workings.add("$unknownVar = ${_fmt(finalVal)}$uStr");
        }

        steps.add(PythagorasStep(
            title: "Step 3: Find the Square Root",
            description: "Take the square root to find the actual real-world length of the $hypName.",
            mathLaTeX: "\\sqrt{$unknownVar^2} = \\sqrt{${_fmt(sumSq)}} \\Rightarrow $unknownVar = $ansStr$uStr"
        ));

      } else {
        // Find Base or Height
        double hypVal = _parse(hypStr);
        double knownVal = bNum ? _parse(baseStr) : _parse(heightStr);
        hypDraw = hypVal;
        if (bNum) { bDraw = knownVal; hDraw = 0; } else { hDraw = knownVal; bDraw = 0; }

        workings.add("${_fmt(hypVal*hypVal)} = $unknownVar^2 + ${_fmt(knownVal*knownVal)}");

        steps.add(PythagorasStep(
            title: "Step 2: Apply Pythagoras' Rule",
            description: "Substitute the known real-world values into the equation and square them.",
            mathLaTeX: "${_fmt(hypVal*hypVal)} = $unknownVar^2 + ${_fmt(knownVal*knownVal)}"
        ));

        double hypSq = hypVal*hypVal;
        double knSq = knownVal*knownVal;

        workings.add("${_fmt(hypSq)} - ${_fmt(knSq)} = $unknownVar^2");

        steps.add(PythagorasStep(
            title: "Step 3: Balance the Equation",
            description: "To isolate the unknown '$unknownVar²', we subtract the smaller square from the hypotenuse square.",
            mathLaTeX: "${_fmt(hypSq)} - ${_fmt(knSq)} = $unknownVar^2"
        ));

        double diffSq = hypSq - knSq;
        if (diffSq < 0) throw const FormatException("The hypotenuse must be the longest measurement in the real world.");

        finalVal = math.sqrt(diffSq);
        if (bNum) { hDraw = finalVal; } else { bDraw = finalVal; }

        workings.add("\\sqrt{$unknownVar^2} = \\sqrt{${_fmt(diffSq)}}");
        String ansStr = (finalVal % 1 == 0) ? _fmt(finalVal) : _fmt2SF(finalVal);

        if (finalVal % 1 != 0) {
          workings.add("$unknownVar = ${_fmt(finalVal)}$uStr \\approx $ansStr$uStr \\text{ (2 s.f.)}");
        } else {
          workings.add("$unknownVar = ${_fmt(finalVal)}$uStr");
        }

        steps.add(PythagorasStep(
            title: "Step 4: Find the Square Root",
            description: "Take the square root of the remaining value to find the real-world length of the ${bNum ? heightName : baseName}.",
            mathLaTeX: "\\sqrt{$unknownVar^2} = \\sqrt{${_fmt(diffSq)}} \\Rightarrow $unknownVar = $ansStr$uStr"
        ));
      }

      String finalAnsStr = (finalVal % 1 == 0) ? _fmt(finalVal) : _fmt2SF(finalVal);
      answers[unknownVar] = "$finalAnsStr$uStr";

      // Create a visual shape with real world labels!
      List<SolvedTriangle> shapes = [
        SolvedTriangle(
            name: "Real-Life Model",
            baseVal: bDraw, heightVal: hDraw, hypVal: hypDraw,
            baseLabel: "$baseName: ${bNum ? bValStr : finalAnsStr}$plainUStr",
            heightLabel: "$heightName: ${hNum ? hValStr : finalAnsStr}$plainUStr",
            hypLabel: "$hypName: ${hypNum ? hypValStr : finalAnsStr}$plainUStr"
        )
      ];

      return PythagorasResult(mode: 'RealLife', finalAnswers: answers, workingsLaTeX: workings, steps: steps, drawnTriangles: shapes);

    } catch (e) {
      return PythagorasResult(mode: 'RealLife', finalAnswers: {}, workingsLaTeX: [], steps: [], drawnTriangles: [], valid: false, errorMessage: e is FormatException ? e.message : "Invalid input parameters.");
    }
  }

  static PythagorasResult verifyTriple(String aStr, String bStr, String cStr) {
    try {
      double n1 = _parse(aStr);
      double n2 = _parse(bStr);
      double n3 = _parse(cStr);

      if (n1 <= 0 || n2 <= 0 || n3 <= 0) throw const FormatException("Lengths must be greater than zero.");

      List<double> sides = [n1, n2, n3];
      sides.sort();
      double a = sides[0], b = sides[1], c = sides[2];

      List<PythagorasStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};

      bool isWholeNumbers = (a % 1 == 0) && (b % 1 == 0) && (c % 1 == 0);

      workings.add("\\text{\\textbf{Verifying if (${_fmt(n1)}, ${_fmt(n2)}, ${_fmt(n3)}) is a Triple}}");

      steps.add(PythagorasStep(
          title: "Step 1: Identify the Longest Side",
          description: "In a right-angled triangle, the hypotenuse is always the longest side. Look at the three numbers provided and identify the largest one. Here, the largest number is ${_fmt(c)}.",
          mathLaTeX: "\\text{Hypotenuse Candidate (c)} = ${_fmt(c)}"
      ));

      double sumSq = a*a + b*b;
      workings.add("\\text{Sum of squares of shorter sides:}");
      workings.add("${_fmt(a)}^2 + ${_fmt(b)}^2 = ${_fmt(a*a)} + ${_fmt(b*b)}");
      workings.add("= ${_fmt(sumSq)}");

      steps.add(PythagorasStep(
          title: "Step 2: Square and Add the Two Shorter Sides",
          description: "Take the two smaller numbers, square them individually, and add the results together.",
          mathLaTeX: "${_fmt(a)}^2 + ${_fmt(b)}^2 = ${_fmt(sumSq)}"
      ));

      double hypSq = c*c;
      workings.add("\\text{Square of the longest side:}");
      workings.add("${_fmt(c)}^2 = ${_fmt(hypSq)}");

      steps.add(PythagorasStep(
          title: "Step 3: Square the Longest Side",
          description: "Now take the largest number (the hypotenuse candidate) and square it by itself.",
          mathLaTeX: "${_fmt(c)}^2 = ${_fmt(hypSq)}"
      ));

      bool isTriple = (sumSq == hypSq) && isWholeNumbers;

      workings.add("\\text{\\textbf{Comparison:}}");
      if (sumSq == hypSq) {
        workings.add("${_fmt(a)}^2 + ${_fmt(b)}^2 = ${_fmt(c)}^2");
        if (!isWholeNumbers) {
          workings.add("\\text{The sides form a right triangle, but are NOT whole numbers.}");
        }
      } else {
        workings.add("${_fmt(a)}^2 + ${_fmt(b)}^2 \\neq ${_fmt(c)}^2");
        workings.add("${_fmt(sumSq)} \\neq ${_fmt(hypSq)}");
      }

      String finalVerdict = "";
      if (isTriple) {
        finalVerdict = "Yes, (${_fmt(n1)}, ${_fmt(n2)}, ${_fmt(n3)}) is a Pythagorean Triple.";
        answers["Is it a Triple?"] = "YES";
      } else {
        finalVerdict = "No, (${_fmt(n1)}, ${_fmt(n2)}, ${_fmt(n3)}) is NOT a Pythagorean Triple.";
        answers["Is it a Triple?"] = "NO";
      }

      steps.add(PythagorasStep(
          title: "Step 4: Compare the Results",
          description: "Compare the sum from Step 2 with the square from Step 3. If they are exactly equal, AND all three original numbers are whole numbers, then it is a true Pythagorean Triple! ${sumSq == hypSq ? (isWholeNumbers ? "They are equal and whole numbers!" : "They are equal, but triples must be whole numbers.") : "They are not equal."}",
          mathLaTeX: "\\text{$finalVerdict}"
      ));

      List<SolvedTriangle> shapes = [];
      if (sumSq == hypSq) {
        shapes.add(SolvedTriangle(
            name: "Verified", baseVal: a, heightVal: b, hypVal: c,
            baseLabel: _fmt(a), heightLabel: _fmt(b), hypLabel: _fmt(c)
        ));
      }

      return PythagorasResult(mode: 'Triples', finalAnswers: answers, workingsLaTeX: workings, steps: steps, drawnTriangles: shapes);

    } catch (e) {
      return PythagorasResult(mode: 'Triples', finalAnswers: {}, workingsLaTeX: [], steps: [], drawnTriangles: [], valid: false, errorMessage: "Ensure all three inputs are valid numbers.");
    }
  }

  static PythagorasResult generateMultiples(String aStr, String bStr, String cStr, String countStr) {
    try {
      double n1 = _parse(aStr);
      double n2 = _parse(bStr);
      double n3 = _parse(cStr);
      int count = int.tryParse(countStr) ?? 4;

      if (n1 <= 0 || n2 <= 0 || n3 <= 0 || count <= 0) throw const FormatException();

      List<double> sides = [n1, n2, n3];
      sides.sort();
      double a = sides[0], b = sides[1], c = sides[2];

      List<PythagorasStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};

      bool isValidBase = (a*a + b*b == c*c) && (a % 1 == 0) && (b % 1 == 0) && (c % 1 == 0);
      if (!isValidBase) {
        throw const FormatException("The base numbers provided do not form a valid Pythagorean Triple.");
      }

      String baseTriple = "(${_fmt(a)}, ${_fmt(b)}, ${_fmt(c)})";
      workings.add("\\text{\\textbf{Generating $count Multiples of $baseTriple}}");

      steps.add(PythagorasStep(
          title: "Step 1: Understand Multiples",
          description: "If you multiply every number in a Pythagorean Triple by the same constant scale factor, the new set of numbers will ALSO be a Pythagorean Triple. This works because similar triangles preserve their right angles!",
          mathLaTeX: "k \\times (a, b, c) = (ka, kb, kc)"
      ));

      List<String> generated = [];
      for (int i = 2; i <= count + 1; i++) {
        double m1 = a * i;
        double m2 = b * i;
        double m3 = c * i;
        String trip = "(${_fmt(m1)}, ${_fmt(m2)}, ${_fmt(m3)})";
        generated.add(trip);
        workings.add("\\text{Multiply by $i: } $i \\times $baseTriple = $trip");
      }

      steps.add(PythagorasStep(
          title: "Step 2: Generate the Sets",
          description: "We systematically multiply the base triple $baseTriple by 2, 3, 4, etc. to generate the requested number of multiples.",
          mathLaTeX: generated.join(',\\quad')
      ));

      answers["Generated Multiples"] = generated.join(', ');

      return PythagorasResult(mode: 'Triples', finalAnswers: answers, workingsLaTeX: workings, steps: steps, drawnTriangles: []);

    } catch (e) {
      return PythagorasResult(mode: 'Triples', finalAnswers: {}, workingsLaTeX: [], steps: [], drawnTriangles: [], valid: false, errorMessage: e is FormatException ? e.message : "Invalid inputs.");
    }
  }

  static PythagorasResult completePattern(String startNumStr) {
    try {
      double nDouble = _parse(startNumStr);
      if (nDouble % 1 != 0 || nDouble < 3) {
        throw const FormatException("Starting number must be a whole number greater than 2.");
      }

      int n = nDouble.toInt();
      List<PythagorasStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};

      workings.add("\\text{\\textbf{Completing the Pattern for $n}}");

      if (n % 2 != 0) {
        // ODD NUMBER PATTERN
        int sq = n * n;
        int a = (sq - 1) ~/ 2;
        int b = (sq + 1) ~/ 2;

        workings.add("\\text{Since $n is an \\textbf{odd} number, we use the Odd Pattern:}");
        workings.add("$n^2 = $sq");

        steps.add(PythagorasStep(
            title: "Step 1: Square the Odd Number",
            description: "For the odd number pattern, we first find the square of the starting number.",
            mathLaTeX: "$n^2 = $sq"
        ));

        workings.add("\\text{Split $sq into two consecutive numbers (difference of 1):}");
        workings.add("$sq = $a + $b");

        steps.add(PythagorasStep(
            title: "Step 2: Split into Consecutive Numbers",
            description: "The textbook hint states that the difference between the last two numbers of an odd triple is 1. We split the square ($sq) into two numbers that add up to $sq and are exactly 1 apart. We do this by calculating ($sq - 1) ÷ 2 and ($sq + 1) ÷ 2.",
            mathLaTeX: "$a + $b = $sq"
        ));

        answers["Completed Triple"] = "($n, $a, $b)";

      } else {
        // EVEN NUMBER PATTERN
        int sq = n * n;
        int halfSq = sq ~/ 2;
        int a = (halfSq - 2) ~/ 2;
        int b = (halfSq + 2) ~/ 2;

        workings.add("\\text{Since $n is an \\textbf{even} number, we use the Even Pattern:}");
        workings.add("\\frac{1}{2} \\text{ of } $n^2 = \\frac{1}{2} \\times $sq = $halfSq");

        steps.add(PythagorasStep(
            title: "Step 1: Square and Halve the Even Number",
            description: "For the even number pattern, we square the starting number, and then find half of that square.",
            mathLaTeX: "\\frac{1}{2} \\times $n^2 = $halfSq"
        ));

        workings.add("\\text{Split $halfSq into two numbers with a difference of 2:}");
        workings.add("$halfSq = $a + $b");

        steps.add(PythagorasStep(
            title: "Step 2: Split with a Difference of 2",
            description: "The textbook hint states that the difference between the last two numbers of an even triple is 2. We split our halved square ($halfSq) into two numbers that add up to $halfSq and are exactly 2 apart.",
            mathLaTeX: "$a + $b = $halfSq"
        ));

        answers["Completed Triple"] = "($n, $a, $b)";
      }

      return PythagorasResult(mode: 'Triples', finalAnswers: answers, workingsLaTeX: workings, steps: steps, drawnTriangles: []);

    } catch (e) {
      return PythagorasResult(mode: 'Triples', finalAnswers: {}, workingsLaTeX: [], steps: [], drawnTriangles: [], valid: false, errorMessage: e is FormatException ? e.message : "Enter a whole number >= 3.");
    }
  }
}