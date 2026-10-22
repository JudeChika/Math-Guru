import 'dart:math' as math;
import 'cylinders_models.dart';

class CylindersLogic {
  /// Formats decimals neatly, dropping trailing .0
  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// Formats a number to exactly 2 significant figures (as per JSS2 syllabus examples)
  static String _fmt2SF(double v) {
    if (v == 0) return "0";
    int d = (math.log(v.abs()) / math.ln10).floor();
    double scale = math.pow(10, 1 - d).toDouble();
    double rounded = (v * scale).roundToDouble() / scale;
    String str = rounded.toString();
    if (str.endsWith('.0')) str = str.substring(0, str.length - 2);
    return str;
  }

  /// Parses inputs that might be fractions (e.g. "3 1/2" -> 3.5)
  static double? parseInput(String input) {
    String s = input.trim();
    if (s.isEmpty) return null;
    try {
      if (s.contains('/')) {
        if (s.contains(RegExp(r'\s+'))) {
          var parts = s.split(RegExp(r'\s+'));
          double whole = double.parse(parts[0]);
          var fParts = parts[1].split('/');
          double n = double.parse(fParts[0]);
          double d = double.parse(fParts[1]);
          return whole < 0 ? whole - (n / d) : whole + (n / d);
        } else {
          var parts = s.split('/');
          double n = double.parse(parts[0]);
          double d = double.parse(parts[1]);
          return n / d;
        }
      }
      return double.parse(s.replaceAll(RegExp(r'[^\d\.\-]'), ''));
    } catch (e) {
      return null;
    }
  }

  /// Returns multiplier to convert FROM a given unit TO a target unit
  static double getConversion(String from, String to) {
    if (from == to) return 1.0;
    if (from == 'mm' && to == 'cm') return 0.1;
    if (from == 'mm' && to == 'm') return 0.001;
    if (from == 'cm' && to == 'mm') return 10.0;
    if (from == 'cm' && to == 'm') return 0.01;
    if (from == 'm' && to == 'mm') return 1000.0;
    if (from == 'm' && to == 'cm') return 100.0;
    return 1.0;
  }

  /// Harmonizes a dimension into the target unit and adds pedagogical steps if a conversion occurred
  static double _harmonize(
      String label,
      double val,
      String fromUnit,
      String toUnit,
      List<String> workings,
      List<CylinderStep> steps,
      ) {
    if (fromUnit == toUnit) return val;
    double conv = getConversion(fromUnit, toUnit);
    double newVal = val * conv;
    String op =
    conv < 1 ? "\\div ${(1 / conv).round()}" : "\\times ${conv.toInt()}";
    String plainOp =
    conv < 1 ? "divide by ${(1 / conv).round()}" : "multiply by ${conv.toInt()}";
    String rel = conv < 1
        ? "1 $toUnit = ${(1 / conv).round()} $fromUnit"
        : "1 $fromUnit = ${conv.toInt()} $toUnit";

    if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
    workings.add("\\text{\\textbf{Unit Conversion ($label)}}");
    workings.add(
        "\\text{Convert $label from $fromUnit to $toUnit: } ${_fmt(val)}\\text{ $fromUnit} $op = ${_fmt(newVal)}\\text{ $toUnit}");

    steps.add(CylinderStep(
      title: "Convert $label to Target Unit ($toUnit)",
      description:
      "Before substituting into any formula, all dimensions must be in the same unit ($toUnit).\n"
          "• Recall that $rel.\n"
          "• To convert ${_fmt(val)} $fromUnit to $toUnit, we $plainOp:\n"
          "  ${_fmt(val)} $fromUnit → ${_fmt(newVal)} $toUnit.",
      mathLaTeX:
      "\\text{$label} = ${_fmt(val)}\\text{ $fromUnit} $op = ${_fmt(newVal)}\\text{ $toUnit}",
    ));
    return newVal;
  }

  /// Handles the exact Step 1 for Diameter -> Radius conversion
  static double _processRadius(
      bool isRadius,
      double inputVal,
      String unit,
      List<String> workings,
      List<CylinderStep> steps,
      ) {
    if (isRadius) return inputVal;
    double r = inputVal / 2;
    if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
    workings.add("\\text{\\textbf{Find Radius (r) from Diameter (d)}}");
    workings.add(
        "r = \\frac{d}{2} = \\frac{${_fmt(inputVal)}\\text{ $unit}}{2} = ${_fmt(r)}\\text{ $unit}");
    steps.add(CylinderStep(
      title: "Find the Radius (r) from the Diameter (d)",
      description:
      "Every cylinder formula uses the radius (r) of the circular face, which is half of the diameter (d).\n"
          "• Given diameter (d) = ${_fmt(inputVal)} $unit.\n"
          "• Divide the diameter by 2 to get the radius:\n"
          "  r = ${_fmt(inputVal)} ÷ 2 = ${_fmt(r)} $unit.",
      mathLaTeX:
      "r = \\frac{d}{2} = \\frac{${_fmt(inputVal)}}{2} = ${_fmt(r)}\\text{ $unit}",
    ));
    return r;
  }

  // ==========================================
  // MODE 0: Surface Area & Cost
  // ==========================================
  static CylinderResult solveSurfaceArea({
    required PiConfig pi,
    required int saMode, // 0: CSA, 1: Open 1 End, 2: Closed, 3: All
    required bool isRadius,
    required String dimStr,
    required String dimUnit,
    required String hStr,
    required String hUnit,
    required String targetUnit,
    required String costStr,
  }) {
    try {
      double? rawDim = parseInput(dimStr);
      double? rawH = parseInput(hStr);
      if (rawDim == null || rawH == null) throw const FormatException();

      List<CylinderStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};

      double dimHarm = _harmonize(
        isRadius ? "Radius" : "Diameter",
        rawDim,
        dimUnit,
        targetUnit,
        workings,
        steps,
      );
      double hHarm =
      _harmonize("Height", rawH, hUnit, targetUnit, workings, steps);
      double r = _processRadius(isRadius, dimHarm, targetUnit, workings, steps);

      double rSq = r * r;
      double twoRh = 2 * r * hHarm;
      double csa = 2 * pi.value * r * hHarm;
      double baseArea = pi.value * rSq;
      double twoBasesArea = 2 * baseArea;
      String piL = pi.latex;
      String piTxt = pi.text;

      // 1. Curved Surface Area (Always computed first as a building block)
      if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
      workings.add("\\text{\\textbf{Curved Surface Area (CSA)}}");
      workings.add("\\text{CSA} = 2\\pi r h");
      workings.add(
          "= 2 \\times $piL \\times ${_fmt(r)} \\times ${_fmt(hHarm)}");
      workings.add(
          "= ${_fmt(twoRh)} \\times $piL = ${_fmt(csa)} \\text{ $targetUnit}^2");

      if (saMode == 0) {
        workings.add(
            "\\approx ${_fmt2SF(csa)} \\text{ $targetUnit}^2 \\text{ (to 2 s.f.)}");
        answers["Curved Surface Area"] = "${_fmt(csa)} $targetUnit²";
        answers["CSA (to 2 s.f.)"] = "${_fmt2SF(csa)} $targetUnit²";
      } else if (saMode == 3) {
        answers["Curved Surface Area"] = "${_fmt(csa)} $targetUnit²";
      }

      steps.add(CylinderStep(
        title: "Calculate the Curved Surface Area (CSA = 2πrh)",
        description:
        "When you unroll the curved body of a cylinder, it forms a flat rectangle whose length is the circumference of the circular base (2πr) and whose breadth is the height (h).\n"
            "1. Write the formula: CSA = 2πrh.\n"
            "2. Substitute π = $piTxt, r = ${_fmt(r)} $targetUnit, and h = ${_fmt(hHarm)} $targetUnit:\n"
            "   CSA = 2 × $piTxt × ${_fmt(r)} × ${_fmt(hHarm)}\n"
            "3. Multiply 2 × ${_fmt(r)} × ${_fmt(hHarm)} = ${_fmt(twoRh)}, then multiply by $piTxt:\n"
            "   CSA = ${_fmt(twoRh)} × $piTxt = ${_fmt(csa)} $targetUnit² (or ${_fmt2SF(csa)} $targetUnit² to 2 s.f.).",
        mathLaTeX:
        "\\text{CSA} = 2\\pi r h = 2 \\times $piL \\times ${_fmt(r)} \\times ${_fmt(hHarm)}\n"
            "= ${_fmt(twoRh)} \\times $piL = ${_fmt(csa)}\\text{ $targetUnit}^2",
      ));

      // 2. Area of Circular Base(s)
      if (saMode == 1 || saMode == 2 || saMode == 3) {
        if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
        workings.add("\\text{\\textbf{Area of Circular Base(s)}}");
        workings.add("\\text{Area of 1 Circular Face} = \\pi r^2");
        workings.add(
            "= $piL \\times ${_fmt(r)} \\times ${_fmt(r)} = $piL \\times ${_fmt(rSq)} = ${_fmt(baseArea)} \\text{ $targetUnit}^2");

        if (saMode == 2 || saMode == 3) {
          workings.add(
              "\\text{Area of 2 Circular Faces} = 2\\pi r^2 = 2 \\times ${_fmt(baseArea)} = ${_fmt(twoBasesArea)} \\text{ $targetUnit}^2");
        }

        steps.add(CylinderStep(
          title: "Calculate the Area of the Circular End Face(s)",
          description:
          "Each flat end of a cylinder is a circle of radius r = ${_fmt(r)} $targetUnit.\n"
              "1. Area of 1 circular base = πr²:\n"
              "   First square the radius: r² = ${_fmt(r)} × ${_fmt(r)} = ${_fmt(rSq)} $targetUnit².\n"
              "   Multiply by π ($piTxt): $piTxt × ${_fmt(rSq)} = ${_fmt(baseArea)} $targetUnit².\n"
              "${(saMode == 2 || saMode == 3) ? '2. Since a closed cylinder has 2 circular ends (top and bottom), double the 1-base area:\n   2πr² = 2 × ${_fmt(baseArea)} = ${_fmt(twoBasesArea)} $targetUnit².' : ''}",
          mathLaTeX:
          "\\text{1 Base } (\\pi r^2) = $piL \\times ${_fmt(r)}^2 = $piL \\times ${_fmt(rSq)} = ${_fmt(baseArea)}\\text{ $targetUnit}^2"
              "${(saMode == 2 || saMode == 3) ? '\n\\text{2 Bases } (2\\pi r^2) = 2 \\times ${_fmt(baseArea)} = ${_fmt(twoBasesArea)}\\text{ $targetUnit}^2' : ''}",
        ));
      }

      // 3. Open Cylinder (1 Base + CSA)
      if (saMode == 1 || saMode == 3) {
        double area1End = baseArea + csa;
        if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
        workings.add("\\text{\\textbf{Open Cylinder (1 Base + CSA)}}");
        workings.add("\\text{Total Area (Open)} = \\pi r^2 + 2\\pi r h");
        workings.add(
            "= ${_fmt(baseArea)} + ${_fmt(csa)} = ${_fmt(area1End)} \\text{ $targetUnit}^2");
        workings.add(
            "\\approx ${_fmt2SF(area1End)} \\text{ $targetUnit}^2 \\text{ (to 2 s.f.)}");

        answers["Area (Open 1 End)"] = "${_fmt(area1End)} $targetUnit²";
        answers["Open (to 2 s.f.)"] = "${_fmt2SF(area1End)} $targetUnit²";

        steps.add(CylinderStep(
          title: "Total Surface Area of an Open Cylinder (1 End Open)",
          description:
          "A cylinder open at one end (like a drinking cup or open tin) has only ONE circular base at the bottom plus the curved side:\n"
              "1. Formula: Total Area = πr² + 2πrh.\n"
              "2. Add the 1 circular base area (${_fmt(baseArea)} $targetUnit²) and the curved surface area (${_fmt(csa)} $targetUnit²):\n"
              "   ${_fmt(baseArea)} + ${_fmt(csa)} = ${_fmt(area1End)} $targetUnit².\n"
              "3. Rounding to 2 significant figures (as in Example 2b) gives ${_fmt2SF(area1End)} $targetUnit².",
          mathLaTeX:
          "\\text{Area (Open)} = \\pi r^2 + 2\\pi r h\n"
              "= ${_fmt(baseArea)} + ${_fmt(csa)} = ${_fmt(area1End)}\\text{ $targetUnit}^2 \\approx ${_fmt2SF(area1End)}\\text{ $targetUnit}^2\\text{ (2 s.f.)}",
        ));
      }

      // 4. Closed Cylinder (2 Bases + CSA)
      if (saMode == 2 || saMode == 3) {
        double areaClosed = twoBasesArea + csa;
        double rPlusH = r + hHarm;
        if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
        workings.add("\\text{\\textbf{Closed Cylinder (2 Bases + CSA)}}");
        workings.add("\\text{Total Surface Area (TSA)} = 2\\pi r^2 + 2\\pi r h");
        workings.add(
            "= ${_fmt(twoBasesArea)} + ${_fmt(csa)} = ${_fmt(areaClosed)} \\text{ $targetUnit}^2");
        workings.add(
            "\\approx ${_fmt2SF(areaClosed)} \\text{ $targetUnit}^2 \\text{ (to 2 s.f.)}");

        answers["Total Surface Area (Closed)"] =
        "${_fmt(areaClosed)} $targetUnit²";
        answers["Closed TSA (to 2 s.f.)"] =
        "${_fmt2SF(areaClosed)} $targetUnit²";

        steps.add(CylinderStep(
          title: "Total Surface Area of a Closed Cylinder (Both Ends Closed)",
          description:
          "A solid or closed cylinder has TWO circular bases (top and bottom) plus the curved surface:\n"
              "1. Formula: TSA = 2πr² + 2πrh.\n"
              "2. Add the area of the 2 circular bases (${_fmt(twoBasesArea)} $targetUnit²) and the curved surface area (${_fmt(csa)} $targetUnit²):\n"
              "   TSA = ${_fmt(twoBasesArea)} + ${_fmt(csa)} = ${_fmt(areaClosed)} $targetUnit².\n"
              "3. Factored Formula Check: You can also factor out 2πr to get TSA = 2πr(r + h) = 2 × $piTxt × ${_fmt(r)} × (${_fmt(r)} + ${_fmt(hHarm)}) = 2 × $piTxt × ${_fmt(r)} × ${_fmt(rPlusH)} = ${_fmt(areaClosed)} $targetUnit².\n"
              "4. Rounding to 2 significant figures (as in Example 2a) gives ${_fmt2SF(areaClosed)} $targetUnit².",
          mathLaTeX:
          "\\text{TSA} = 2\\pi r^2 + 2\\pi r h = ${_fmt(twoBasesArea)} + ${_fmt(csa)} = ${_fmt(areaClosed)}\\text{ $targetUnit}^2\n"
              "\\text{Check: } 2\\pi r(r + h) = 2 \\times $piL \\times ${_fmt(r)} \\times ${_fmt(rPlusH)} = ${_fmt(areaClosed)}\\text{ $targetUnit}^2 \\approx ${_fmt2SF(areaClosed)}\\text{ $targetUnit}^2",
        ));
      }

      // 5. Material Costing
      double? costRate = parseInput(costStr);
      if (costRate != null && (saMode == 2 || saMode == 3)) {
        double areaClosed = twoBasesArea + csa;
        double areaM2 = areaClosed;
        if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
        workings.add("\\text{\\textbf{Material Costing}}");

        if (targetUnit == 'cm') {
          areaM2 = areaClosed / 10000;
          workings.add(
              "\\text{Since } 1\\text{ m} = 100\\text{ cm}, \\; 1\\text{ m}^2 = 100 \\times 100 = 10,000\\text{ cm}^2");
          workings.add(
              "\\text{Area in m}^2 = \\frac{${_fmt(areaClosed)}}{10000} = ${areaM2.toStringAsFixed(4).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '')}\\text{ m}^2");
          steps.add(CylinderStep(
            title: "Convert Surface Area from cm² to m²",
            description:
            "The cost rate is given per square metre (m²), so we must convert our surface area from cm² to m²:\n"
                "• Be careful: 1 m = 100 cm, so 1 m² = 100 cm × 100 cm = 10,000 cm².\n"
                "• Divide ${_fmt(areaClosed)} cm² by 10,000 to get ${areaM2.toStringAsFixed(4).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '')} m².",
            mathLaTeX:
            "1\\text{ m}^2 = 100\\text{ cm} \\times 100\\text{ cm} = 10,000\\text{ cm}^2\n"
                "\\text{Area} = \\frac{${_fmt(areaClosed)}}{10000} = ${areaM2.toStringAsFixed(4).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '')}\\text{ m}^2",
          ));
        }

        double totalCost = areaM2 * costRate;
        double roundedCost = (totalCost / 10).round() * 10;
        String exactAreaM2Str = areaM2
            .toStringAsFixed(4)
            .replaceAll(RegExp(r'0*$'), '')
            .replaceAll(RegExp(r'\.$'), '');
        workings.add(
            "\\text{Exact Cost} = $exactAreaM2Str \\times ${_fmt(costRate)} = \\text{N}${_fmt(totalCost)}");
        workings.add(
            "\\text{Rounded Cost} \\approx \\text{N}${_fmt(roundedCost)} \\text{ (to nearest N10)}");
        answers["Exact Cost"] = "₦${_fmt(totalCost)}";
        answers["Cost (Nearest ₦10)"] = "₦${_fmt(roundedCost)}";

        steps.add(CylinderStep(
          title: "Multiply by Cost Rate and Round to Nearest ₦10",
          description:
          "1. Multiply the area in m² ($exactAreaM2Str m²) by the cost per m² (₦${_fmt(costRate)}):\n"
              "   $exactAreaM2Str × ${_fmt(costRate)} = ₦${_fmt(totalCost)}.\n"
              "2. Round ₦${_fmt(totalCost)} to the nearest 10 naira (as in Exercise 19b #5b) to get ₦${_fmt(roundedCost)}.",
          mathLaTeX:
          "\\text{Cost} = $exactAreaM2Str \\times ${_fmt(costRate)} = \\text{N}${_fmt(totalCost)}\n"
              "\\approx \\text{N}${_fmt(roundedCost)}\\text{ (to nearest N10)}",
        ));
      }

      return CylinderResult(
        mode: 0,
        subMode: saMode,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        r: r,
        h: hHarm,
        displayUnit: targetUnit,
      );
    } catch (e) {
      return CylinderResult(
        mode: 0,
        subMode: saMode,
        finalAnswers: {},
        workingsLaTeX: [],
        steps: [],
        valid: false,
        errorMessage: "Invalid dimensions provided.",
      );
    }
  }

  // ==========================================
  // MODE 1: Net & Winding
  // ==========================================
  static CylinderResult solveNetAndWinding({
    required PiConfig pi,
    required int subMode, // 0: Net, 1: Roll Strip, 2: Winding
    required bool isRadius,
    required String dimStr,
    required String hStr,
    required String stripLCtrl,
    required String stripWCtrl,
    required String nTurnsCtrl,
  }) {
    try {
      List<CylinderStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};
      double rToDraw = 5;
      double hToDraw = 10;
      String piL = pi.latex;
      String piTxt = pi.text;

      if (subMode == 0) {
        double? dim = parseInput(dimStr);
        double? h = parseInput(hStr);
        if (dim == null || h == null) throw const FormatException();
        double r = _processRadius(isRadius, dim, 'cm', workings, steps);
        double d = 2 * r;
        double circ = 2 * pi.value * r;
        double rectArea = circ * h;

        if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
        workings.add("\\text{\\textbf{1. Circular End Faces of the Net}}");
        workings.add(
            "\\text{Radius (r)} = ${_fmt(r)}\\text{ cm} \\quad ; \\quad \\text{Diameter (d)} = 2r = 2 \\times ${_fmt(r)} = ${_fmt(d)}\\text{ cm}");

        workings.add("");
        workings.add("\\text{\\textbf{2. Central Rectangle of the Net}}");
        workings.add(
            "\\text{Rectangle Breadth} = \\text{Height (h)} = ${_fmt(h)}\\text{ cm}");
        workings.add(
            "\\text{Rectangle Length} = \\text{Circumference of Circle} = 2\\pi r");
        workings.add(
            "= 2 \\times $piL \\times ${_fmt(r)} = ${_fmt(circ)}\\text{ cm}");

        workings.add("");
        workings.add("\\text{\\textbf{3. Area of Rectangle (Curved Surface)}}");
        workings.add(
            "\\text{Area} = \\text{Length} \\times \\text{Breadth} = ${_fmt(circ)} \\times ${_fmt(h)} = ${_fmt(rectArea)}\\text{ cm}^2");

        answers["Circle Diameter (d)"] = "${_fmt(d)} cm";
        answers["Rectangle Length (2πr)"] = "${_fmt(circ)} cm";
        answers["Rectangle Breadth (h)"] = "${_fmt(h)} cm";
        answers["Rectangle Area"] = "${_fmt(rectArea)} cm²";
        rToDraw = r;
        hToDraw = h;

        steps.add(CylinderStep(
          title: "Find the Dimensions of the 2 Circular Faces (Figure 19.5)",
          description:
          "When a closed cylinder is cut open and laid flat, its net has 2 identical circles (top and bottom) and 1 central rectangle:\n"
              "• Each circle has radius r = ${_fmt(r)} cm.\n"
              "• The diameter of each circle is d = 2 × r = 2 × ${_fmt(r)} = ${_fmt(d)} cm.",
          mathLaTeX:
          "r = ${_fmt(r)}\\text{ cm} \\quad ; \\quad d = 2r = 2 \\times ${_fmt(r)} = ${_fmt(d)}\\text{ cm}",
        ));

        steps.add(CylinderStep(
          title: "Find the Length and Breadth of the Rectangle",
          description:
          "The rectangular sheet wraps around the circular base:\n"
              "1. The breadth (width) of the rectangle is simply the height of the cylinder: h = ${_fmt(h)} cm.\n"
              "2. The length of the rectangle must wrap all the way around the circle's edge, so Length = Circumference of the circle (2πr):\n"
              "   Length = 2 × $piTxt × ${_fmt(r)} = ${_fmt(circ)} cm.\n"
              "3. Multiplying Length × Breadth gives the Curved Surface Area: ${_fmt(circ)} × ${_fmt(h)} = ${_fmt(rectArea)} cm².",
          mathLaTeX:
          "\\text{Length} = 2\\pi r = 2 \\times $piL \\times ${_fmt(r)} = ${_fmt(circ)}\\text{ cm}\n"
              "\\text{Area} = ${_fmt(circ)} \\times ${_fmt(h)} = ${_fmt(rectArea)}\\text{ cm}^2",
        ));
      } else if (subMode == 1) {
        double? L = parseInput(stripLCtrl);
        double? W = parseInput(stripWCtrl);
        if (L == null || W == null) throw const FormatException();

        double stripArea = L * W;
        double d = L / pi.value;
        double r = d / 2;

        workings.add("\\text{\\textbf{1. Height and Circumference from Strip}}");
        workings.add(
            "\\text{Height of Cylinder (h)} = \\text{Strip Width} = ${_fmt(W)}\\text{ cm}");
        workings.add(
            "\\text{Circumference of Circle (C)} = \\text{Strip Length} = ${_fmt(L)}\\text{ cm}");
        workings.add(
            "\\text{Area of Strip (CSA)} = ${_fmt(L)} \\times ${_fmt(W)} = ${_fmt(stripArea)}\\text{ cm}^2");

        workings.add("");
        workings.add("\\text{\\textbf{2. Solve for Diameter (d) and Radius (r)}}");
        workings.add("C = \\pi d \\implies ${_fmt(L)} = $piL \\times d");
        workings.add(
            "d = \\frac{${_fmt(L)}}{$piL} = ${_fmt(d)}\\text{ cm} \\quad ; \\quad r = \\frac{d}{2} = ${_fmt(r)}\\text{ cm}");

        answers["Cylinder Height (h)"] = "${_fmt(W)} cm";
        answers["Base Circumference"] = "${_fmt(L)} cm";
        answers["Curved Surface Area"] = "${_fmt(stripArea)} cm²";
        answers["Circle Diameter (d)"] = "${_fmt(d)} cm";
        rToDraw = r;
        hToDraw = W;

        steps.add(CylinderStep(
          title: "Identify Height, Circumference, and Area (Exercise 19a #1)",
          description:
          "When you cut a rectangular strip of paper ${_fmt(L)} cm long by ${_fmt(W)} cm wide and roll it into a cylinder:\n"
              "• The width of the strip becomes the cylinder's height: h = ${_fmt(W)} cm.\n"
              "• The length of the strip curls into the circular rim, so Circumference (C) = ${_fmt(L)} cm.\n"
              "• The area of the rectangle is ${_fmt(L)} cm × ${_fmt(W)} cm = ${_fmt(stripArea)} cm² (this area does NOT change when rolled!).",
          mathLaTeX:
          "h = ${_fmt(W)}\\text{ cm}, \\quad C = ${_fmt(L)}\\text{ cm}, \\quad \\text{Area} = ${_fmt(L)} \\times ${_fmt(W)} = ${_fmt(stripArea)}\\text{ cm}^2",
        ));

        steps.add(CylinderStep(
          title: "Calculate the Diameter (d) and Radius (r) of the Open Ends",
          description:
          "Since Circumference C = πd, we can find the diameter of the circle by dividing the circumference (${_fmt(L)} cm) by π ($piTxt):\n"
              "• d = ${_fmt(L)} ÷ $piTxt = ${_fmt(d)} cm.\n"
              "• Radius r = d ÷ 2 = ${_fmt(d)} ÷ 2 = ${_fmt(r)} cm.",
          mathLaTeX:
          "d = \\frac{C}{\\pi} = \\frac{${_fmt(L)}}{$piL} = ${_fmt(d)}\\text{ cm} \\implies r = \\frac{${_fmt(d)}}{2} = ${_fmt(r)}\\text{ cm}",
        ));
      } else if (subMode == 2) {
        double? dim = parseInput(dimStr);
        double? n = parseInput(nTurnsCtrl);
        if (dim == null || n == null) throw const FormatException();

        double r = _processRadius(isRadius, dim, 'units', workings, steps);
        double d = 2 * r;
        double c = 2 * pi.value * r;
        double totalL = n * c;

        if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
        workings.add(
            "\\text{\\textbf{1. Length of 1 Complete Turn (Circumference)}}");
        workings.add(
            "C = \\pi d = 2\\pi r = 2 \\times $piL \\times ${_fmt(r)} = ${_fmt(c)}\\text{ units}");

        workings.add("");
        workings.add("\\text{\\textbf{2. Total Length for ${_fmt(n)} Turns}}");
        workings.add(
            "\\text{Total Length} = N \\times C = ${_fmt(n)} \\times ${_fmt(c)} = ${_fmt(totalL)}\\text{ units}");

        answers["1 Complete Turn (C)"] = "${_fmt(c)} units";
        answers["Total Length (${_fmt(n)}×)"] = "${_fmt(totalL)} units";
        rToDraw = r;
        hToDraw = r * 3;

        steps.add(CylinderStep(
          title: "Find the Length of 1 Complete Turn (Circumference)",
          description:
          "Winding a strip of paper or string once around a cylinder covers a distance equal to the circumference of its circular cross-section:\n"
              "• Formula: C = πd (or 2πr).\n"
              "• Substitute π = $piTxt and d = ${_fmt(d)} (r = ${_fmt(r)}):\n"
              "  C = 2 × $piTxt × ${_fmt(r)} = ${_fmt(c)} units for 1 turn.",
          mathLaTeX:
          "\\text{1 Turn (C)} = 2\\pi r = 2 \\times $piL \\times ${_fmt(r)} = ${_fmt(c)}\\text{ units}",
        ));

        steps.add(CylinderStep(
          title: "Multiply by the Number of Turns (N = ${_fmt(n)})",
          description:
          "Since the paper or string goes around the cylinder ${_fmt(n)} times, multiply the length of 1 turn (${_fmt(c)}) by ${_fmt(n)}:\n"
              "• Total Length = ${_fmt(n)} × ${_fmt(c)} = ${_fmt(totalL)} units.",
          mathLaTeX:
          "\\text{Total Length} = N \\times C = ${_fmt(n)} \\times ${_fmt(c)} = ${_fmt(totalL)}\\text{ units}",
        ));
      }

      return CylinderResult(
        mode: 1,
        subMode: subMode,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        r: rToDraw,
        h: hToDraw,
        displayUnit: "cm",
      );
    } catch (e) {
      return CylinderResult(
        mode: 1,
        subMode: subMode,
        finalAnswers: {},
        workingsLaTeX: [],
        steps: [],
        valid: false,
        errorMessage: "Invalid net or winding dimensions provided.",
      );
    }
  }

  // ==========================================
  // MODE 2: Volume, Capacity & Mass
  // ==========================================
  static CylinderResult solveVolume({
    required PiConfig pi,
    required bool isRadius,
    required String dimStr,
    required String dimUnit,
    required String hStr,
    required String hUnit,
    required String targetUnit,
    required String qtyStr,
    required String densityStr,
  }) {
    try {
      double? rawDim = parseInput(dimStr);
      double? rawH = parseInput(hStr);
      if (rawDim == null || rawH == null) throw const FormatException();

      List<CylinderStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};

      double dimHarm = _harmonize(
        isRadius ? "Radius" : "Diameter",
        rawDim,
        dimUnit,
        targetUnit,
        workings,
        steps,
      );
      double hHarm =
      _harmonize("Height", rawH, hUnit, targetUnit, workings, steps);
      double r = _processRadius(isRadius, dimHarm, targetUnit, workings, steps);

      double rSq = r * r;
      double baseArea = pi.value * rSq;
      double vol1 = baseArea * hHarm;
      String piL = pi.latex;
      String piTxt = pi.text;

      if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
      workings.add("\\text{\\textbf{Volume of 1 Cylinder (Prism Formula)}}");
      workings.add(
          "\\text{Volume} = \\text{Area of Circular Base} \\times \\text{Height} = \\pi r^2 h");
      workings.add(
          "= $piL \\times ${_fmt(r)} \\times ${_fmt(r)} \\times ${_fmt(hHarm)}");
      workings.add(
          "= ${_fmt(baseArea)} \\times ${_fmt(hHarm)} = ${_fmt(vol1)} \\text{ $targetUnit}^3");

      steps.add(CylinderStep(
        title: "Calculate the Volume of the Cylinder (V = πr²h)",
        description:
        "A cylinder is a special prism with a circular cross-section, so Volume = Area of circular end face (πr²) × height (h):\n"
            "1. Find the circular base area (πr²):\n"
            "   $piTxt × ${_fmt(r)} × ${_fmt(r)} = $piTxt × ${_fmt(rSq)} = ${_fmt(baseArea)} $targetUnit².\n"
            "2. Multiply the base area by the height/length (h = ${_fmt(hHarm)} $targetUnit):\n"
            "   Volume = ${_fmt(baseArea)} × ${_fmt(hHarm)} = ${_fmt(vol1)} $targetUnit³.",
        mathLaTeX:
        "V = \\pi r^2 h = $piL \\times ${_fmt(r)} \\times ${_fmt(r)} \\times ${_fmt(hHarm)}\n"
            "= ${_fmt(baseArea)} \\times ${_fmt(hHarm)} = ${_fmt(vol1)}\\text{ $targetUnit}^3",
      ));

      double qty = parseInput(qtyStr) ?? 1.0;
      double totalVol = vol1;
      if (qty > 1) {
        totalVol = vol1 * qty;
        workings.add("");
        workings.add("\\text{\\textbf{Total Volume for ${_fmt(qty)} Cylinders}}");
        workings.add(
            "\\text{Total Volume} = ${_fmt(qty)} \\times ${_fmt(vol1)} = ${_fmt(totalVol)} \\text{ $targetUnit}^3");
        answers["Volume (1 Item)"] = "${_fmt(vol1)} $targetUnit³";
        answers["Total Volume (${_fmt(qty)})"] =
        "${_fmt(totalVol)} $targetUnit³";

        steps.add(CylinderStep(
          title: "Multiply by Number of Cylinders (Qty = ${_fmt(qty)})",
          description:
          "Since there are ${_fmt(qty)} identical cylinders (e.g. ${_fmt(qty)} concrete pillars in Ex 19c #8), multiply the volume of 1 cylinder by ${_fmt(qty)}:\n"
              "• Total Volume = ${_fmt(qty)} × ${_fmt(vol1)} = ${_fmt(totalVol)} $targetUnit³.",
          mathLaTeX:
          "\\text{Total Volume} = ${_fmt(qty)} \\times ${_fmt(vol1)} = ${_fmt(totalVol)}\\text{ $targetUnit}^3",
        ));
      } else {
        answers["Volume"] = "${_fmt(vol1)} $targetUnit³";
      }

      // Capacity (Litres / Kilolitres)
      if (targetUnit == 'cm') {
        double litres = totalVol / 1000;
        workings.add("");
        workings.add("\\text{\\textbf{Fluid Capacity in Litres}}");
        workings.add("\\text{Recall: } 1,000\\text{ cm}^3 = 1\\text{ litre } (\\ell)");
        workings.add(
            "\\text{Capacity} = \\frac{${_fmt(totalVol)}}{1000} = ${_fmt(litres)} \\text{ }\\ell");
        answers["Capacity (Litres)"] = "${_fmt(litres)} ℓ";

        steps.add(CylinderStep(
          title: "Convert Volume (cm³) to Capacity in Litres (ℓ)",
          description:
          "By definition, 1 litre (ℓ) takes up exactly 1,000 cm³ of space.\n"
              "• To convert ${_fmt(totalVol)} cm³ into litres, divide by 1,000:\n"
              "  ${_fmt(totalVol)} ÷ 1,000 = ${_fmt(litres)} litres (or about ${litres.round()} ℓ to the nearest litre).",
          mathLaTeX:
          "1\\text{ }\\ell = 1,000\\text{ cm}^3 \\implies \\text{Capacity} = \\frac{${_fmt(totalVol)}}{1000} = ${_fmt(litres)}\\text{ }\\ell",
        ));
      } else if (targetUnit == 'm') {
        double kilolitres = totalVol;
        double litres = totalVol * 1000;
        workings.add("");
        workings.add("\\text{\\textbf{Capacity in Kilolitres and Litres}}");
        workings.add(
            "\\text{Recall: } 1\\text{ m}^3 = 1\\text{ kilolitre (kl)} = 1,000\\text{ litres } (\\ell)");
        workings.add(
            "\\text{Capacity} = ${_fmt(kilolitres)}\\text{ kl} = ${_fmt(totalVol)} \\times 1000 = ${_fmt(litres)} \\text{ }\\ell");
        answers["Capacity (kl)"] = "${_fmt(kilolitres)} kl";
        answers["Capacity (Litres)"] = "${_fmt(litres)} ℓ";

        steps.add(CylinderStep(
          title: "Convert Volume (m³) to Kilolitres (kl) and Litres (ℓ)",
          description:
          "A cubic metre (1 m³) holds exactly 1 kilolitre (1 kl) or 1,000 litres:\n"
              "• In kilolitres: ${_fmt(totalVol)} m³ = ${_fmt(kilolitres)} kl.\n"
              "• In litres: ${_fmt(totalVol)} × 1,000 = ${_fmt(litres)} litres.",
          mathLaTeX:
          "1\\text{ m}^3 = 1\\text{ kl} = 1,000\\text{ }\\ell \\implies ${_fmt(kilolitres)}\\text{ kl} = ${_fmt(litres)}\\text{ }\\ell",
        ));
      }

      double? density = parseInput(densityStr);
      if (density != null) {
        workings.add("");
        workings.add("\\text{\\textbf{Mass from Density}}");
        workings.add("\\text{Mass} = \\text{Volume} \\times \\text{Density}");

        double mass = totalVol * density;
        String mUnit = targetUnit == 'cm' ? 'g' : 'tons';

        workings.add(
            "= ${_fmt(totalVol)} \\times ${_fmt(density)} = ${_fmt(mass)}\\text{ $mUnit}");

        if (targetUnit == 'cm' && mass >= 1000) {
          double kg = mass / 1000;
          workings.add(
              "\\text{Convert grams to kilograms (}\\div 1,000\\text{): } \\frac{${_fmt(mass)}}{1000} = ${_fmt(kg)}\\text{ kg}");
          answers["Mass (g)"] = "${_fmt(mass)} g";
          answers["Mass (kg)"] = "${_fmt(kg)} kg";

          steps.add(CylinderStep(
            title: "Calculate Mass and Convert Grams to Kilograms",
            description:
            "1. Since 1 cm³ has a mass of ${_fmt(density)} g, multiply the total volume (${_fmt(totalVol)} cm²) by ${_fmt(density)} g/cm³:\n"
                "   Mass = ${_fmt(totalVol)} × ${_fmt(density)} = ${_fmt(mass)} g.\n"
                "2. Since 1,000 g = 1 kg, divide by 1,000 to express the mass in kilograms:\n"
                "   ${_fmt(mass)} ÷ 1,000 = ${_fmt(kg)} kg.",
            mathLaTeX:
            "\\text{Mass} = ${_fmt(totalVol)} \\times ${_fmt(density)} = ${_fmt(mass)}\\text{ g}\n"
                "= \\frac{${_fmt(mass)}}{1000} = ${_fmt(kg)}\\text{ kg}",
          ));
        } else {
          answers["Total Mass"] = "${_fmt(mass)} $mUnit";
          steps.add(CylinderStep(
            title: "Calculate Total Mass from Density",
            description:
            "Multiply the total volume (${_fmt(totalVol)} $targetUnit³) by the mass per unit volume (${_fmt(density)} $mUnit/$targetUnit³):\n"
                "• Total Mass = ${_fmt(totalVol)} × ${_fmt(density)} = ${_fmt(mass)} $mUnit.",
            mathLaTeX:
            "\\text{Mass} = ${_fmt(totalVol)} \\times ${_fmt(density)} = ${_fmt(mass)}\\text{ $mUnit}",
          ));
        }
      }

      return CylinderResult(
        mode: 2,
        subMode: 0,
        finalAnswers: answers,
        workingsLaTeX: workings,
        steps: steps,
        r: r,
        h: hHarm,
        displayUnit: targetUnit,
      );
    } catch (e) {
      return CylinderResult(
        mode: 2,
        subMode: 0,
        finalAnswers: {},
        workingsLaTeX: [],
        steps: [],
        valid: false,
        errorMessage: "Invalid volume dimensions provided.",
      );
    }
  }

  // ==========================================
  // MODE 3: Reverse Mensuration
  // ==========================================
  static CylinderResult solveReverse({
    required PiConfig pi,
    required int subMode, // 0: Find h, 1: Find r
    required bool isRadius,
    required String dimStr,
    required String hStr,
    required String volStr,
    required bool isLitres,
  }) {
    try {
      double? vRaw = parseInput(volStr);
      if (vRaw == null) throw const FormatException();

      List<CylinderStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};
      String piL = pi.latex;
      String piTxt = pi.text;

      double vol = vRaw;
      if (isLitres) {
        vol = vRaw * 1000;
        workings.add("\\text{\\textbf{Convert Capacity (Litres) to Volume (cm}^3\\text{)}}");
        workings.add(
            "\\text{Volume} = ${_fmt(vRaw)}\\text{ }\\ell \\times 1,000 = ${_fmt(vol)} \\text{ cm}^3");
        steps.add(CylinderStep(
          title: "Convert Capacity from Litres to Cubic Centimetres (cm³)",
          description:
          "Since the drum's dimensions are in centimetres (cm), we must first convert the liquid capacity from litres (ℓ) into cubic centimetres (cm³):\n"
              "• Recall that 1 litre = 1,000 cm³.\n"
              "• Volume = ${_fmt(vRaw)} × 1,000 = ${_fmt(vol)} cm³.",
          mathLaTeX:
          "V = ${_fmt(vRaw)}\\text{ }\\ell \\times 1,000\\text{ cm}^3/\\ell = ${_fmt(vol)}\\text{ cm}^3",
        ));
      }

      if (subMode == 0) {
        double? dim = parseInput(dimStr);
        if (dim == null) throw const FormatException();
        double r = _processRadius(isRadius, dim, 'cm', workings, steps);

        if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
        workings.add("\\text{\\textbf{Substitute into Volume Formula and Solve for h}}");
        workings.add("\\pi r^2 h = V");
        workings.add(
            "$piL \\times ${_fmt(r)} \\times ${_fmt(r)} \\times h = ${_fmt(vol)}");

        double h = vol / (pi.value * r * r);

        if (pi.text == '22/7') {
          double numProd = vol * 7;
          double denProd = 22 * r * r;
          workings.add(
              "h = \\frac{${_fmt(vol)} \\times 7}{22 \\times ${_fmt(r)} \\times ${_fmt(r)}}");
          workings.add(
              "h = \\frac{${_fmt(numProd)}}{${_fmt(denProd)}} = ${_fmt(h)}\\text{ cm}");
          steps.add(CylinderStep(
            title: "Isolate Depth/Height (h) Using the Golden Rule (Example 4)",
            description:
            "Set the cylinder volume formula (πr²h) equal to ${_fmt(vol)} cm³ and follow the textbook rule: 'Always leave numerical simplification until the last step':\n"
                "1. Equation: (22/7) × ${_fmt(r)} × ${_fmt(r)} × h = ${_fmt(vol)}.\n"
                "2. Multiply both sides by 7 and divide by (22 × ${_fmt(r)} × ${_fmt(r)}) to isolate h:\n"
                "   h = (${_fmt(vol)} × 7) ÷ (22 × ${_fmt(r)} × ${_fmt(r)}).\n"
                "3. Simplify: h = ${_fmt(numProd)} ÷ ${_fmt(denProd)} = ${_fmt(h)} cm.",
            mathLaTeX:
            "\\frac{22}{7} \\times ${_fmt(r)} \\times ${_fmt(r)} \\times h = ${_fmt(vol)}\n"
                "h = \\frac{${_fmt(vol)} \\times 7}{22 \\times ${_fmt(r)} \\times ${_fmt(r)}} = \\frac{${_fmt(numProd)}}{${_fmt(denProd)}} = ${_fmt(h)}\\text{ cm}",
          ));
        } else {
          double baseArea = pi.value * r * r;
          workings.add(
              "h = \\frac{${_fmt(vol)}}{$piL \\times ${_fmt(r * r)}} = \\frac{${_fmt(vol)}}{${_fmt(baseArea)}} = ${_fmt(h)}\\text{ cm}");
          steps.add(CylinderStep(
            title: "Isolate Depth/Height (h) Algebraically",
            description:
            "1. Set up the equation: πr²h = ${_fmt(vol)}.\n"
                "2. Calculate the circular base area: πr² = $piTxt × ${_fmt(r * r)} = ${_fmt(baseArea)} cm².\n"
                "3. Divide the total volume by the base area: h = ${_fmt(vol)} ÷ ${_fmt(baseArea)} = ${_fmt(h)} cm.",
            mathLaTeX:
            "h = \\frac{${_fmt(vol)}}{$piL \\times ${_fmt(r)}^2} = \\frac{${_fmt(vol)}}{${_fmt(baseArea)}} = ${_fmt(h)}\\text{ cm}",
          ));
        }

        answers["Depth / Height (h)"] = "${_fmt(h)} cm";
        return CylinderResult(
          mode: 3,
          subMode: subMode,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          r: r,
          h: h,
          displayUnit: "cm",
        );
      } else {
        double? h = parseInput(hStr);
        if (h == null) throw const FormatException();

        if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
        workings.add("\\text{\\textbf{Solve for Radius (r) and Diameter (d)}}");
        workings.add("\\pi r^2 h = V");
        workings.add("$piL \\times r^2 \\times ${_fmt(h)} = ${_fmt(vol)}");

        double rSq = vol / (pi.value * h);

        if (pi.text == '22/7') {
          workings.add(
              "r^2 = \\frac{${_fmt(vol)} \\times 7}{22 \\times ${_fmt(h)}} = ${_fmt(rSq)}");
        } else {
          workings.add(
              "r^2 = \\frac{${_fmt(vol)}}{$piL \\times ${_fmt(h)}} = ${_fmt(rSq)}");
        }

        double r = math.sqrt(rSq);
        workings.add(
            "r = \\sqrt{${_fmt(rSq)}} = ${_fmt(r)}\\text{ cm} \\quad ; \\quad d = 2r = ${_fmt(r * 2)}\\text{ cm}");

        answers["Radius (r)"] = "${_fmt(r)} cm";
        answers["Diameter (d)"] = "${_fmt(r * 2)} cm";

        steps.add(CylinderStep(
          title: "Isolate r² First, Then Take the Square Root",
          description:
          "1. Substitute h = ${_fmt(h)} cm and V = ${_fmt(vol)} cm³ into πr²h = V.\n"
              "2. Isolate r² by dividing the volume by (π × h): r² = ${_fmt(rSq)}.\n"
              "3. Take the square root of ${_fmt(rSq)} to find the radius: r = √${_fmt(rSq)} = ${_fmt(r)} cm.\n"
              "4. Multiply by 2 to get the diameter: d = 2 × ${_fmt(r)} = ${_fmt(r * 2)} cm.",
          mathLaTeX:
          "r^2 = ${_fmt(rSq)} \\implies r = \\sqrt{${_fmt(rSq)}} = ${_fmt(r)}\\text{ cm}\n"
              "d = 2r = 2 \\times ${_fmt(r)} = ${_fmt(r * 2)}\\text{ cm}",
        ));

        return CylinderResult(
          mode: 3,
          subMode: subMode,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          r: r,
          h: h,
          displayUnit: "cm",
        );
      }
    } catch (e) {
      return CylinderResult(
        mode: 3,
        subMode: subMode,
        finalAnswers: {},
        workingsLaTeX: [],
        steps: [],
        valid: false,
        errorMessage: "Invalid inputs for reverse calculation.",
      );
    }
  }

  // ==========================================
  // MODE 4: Transfer & Leaks
  // ==========================================
  static CylinderResult solveTransferAndLeak({
    required PiConfig pi,
    required int subMode, // 0: Transfer, 1: Leak
    required bool isRadius1,
    required String dim1Str,
    required String h1Str,
    required bool isRadius2,
    required String dim2Str,
    required String dropStr,
    required String rateStr,
  }) {
    try {
      List<CylinderStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};
      String piL = pi.latex;

      if (subMode == 0) {
        double? d1 = parseInput(dim1Str);
        double? h1 = parseInput(h1Str);
        double? d2 = parseInput(dim2Str);
        if (d1 == null || h1 == null || d2 == null) {
          throw const FormatException();
        }

        double r1 = _processRadius(isRadius1, d1, 'cm', workings, steps);
        double r2 = _processRadius(isRadius2, d2, 'cm', workings, steps);
        double v1 = pi.value * r1 * r1 * h1;

        if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
        workings.add("\\text{\\textbf{1. Volume of Water in Cylinder 1}}");
        workings.add(
            "V_1 = \\pi r_1^2 h_1 = $piL \\times ${_fmt(r1)}^2 \\times ${_fmt(h1)} = ${_fmt(v1)}\\text{ cm}^3");

        workings.add("");
        workings.add(
            "\\text{\\textbf{2. Conservation of Volume (Cylinder 1 \\rightarrow Cylinder 2)}}");
        workings.add("\\pi r_2^2 h_2 = \\pi r_1^2 h_1");
        workings.add(
            "\\text{Cancel } \\pi \\text{ on both sides: } r_2^2 h_2 = r_1^2 h_1");
        workings.add(
            "${_fmt(r2)}^2 \\times h_2 = ${_fmt(r1)}^2 \\times ${_fmt(h1)}");

        double h2 = (r1 * r1 * h1) / (r2 * r2);
        workings.add(
            "h_2 = \\frac{${_fmt(r1)} \\times ${_fmt(r1)} \\times ${_fmt(h1)}}{${_fmt(r2)} \\times ${_fmt(r2)}} = \\frac{${_fmt(r1 * r1 * h1)}}{${_fmt(r2 * r2)}} = ${_fmt(h2)}\\text{ cm}");

        answers["Water Volume (V₁)"] = "${_fmt(v1)} cm³";
        answers["New Depth (h₂)"] = "${_fmt(h2)} cm";

        steps.add(CylinderStep(
          title: "Equate the Volumes of Both Cylinders (V₂ = V₁)",
          description:
          "When water is poured from the first cylinder into the second cylinder, the volume of water does not change:\n"
              "• Volume in Cylinder 1: V₁ = π × ${_fmt(r1)}² × ${_fmt(h1)} = ${_fmt(v1)} cm³.\n"
              "• Volume in Cylinder 2: V₂ = π × ${_fmt(r2)}² × h₂.\n"
              "• Since V₂ = V₁, we write: π × ${_fmt(r2)}² × h₂ = π × ${_fmt(r1)}² × ${_fmt(h1)}.",
          mathLaTeX:
          "\\pi r_2^2 h_2 = \\pi r_1^2 h_1 \\implies \\pi \\times ${_fmt(r2)}^2 \\times h_2 = \\pi \\times ${_fmt(r1)}^2 \\times ${_fmt(h1)}",
        ));

        steps.add(CylinderStep(
          title: "Cancel π and Solve for the New Depth (h₂)",
          description:
          "1. Because π appears as a factor on both sides of the equation, divide both sides by π so it cancels out cleanly!\n"
              "2. Isolate h₂ by dividing (${_fmt(r1)}² × ${_fmt(h1)}) by ${_fmt(r2)}²:\n"
              "   h₂ = (${_fmt(r1 * r1)} × ${_fmt(h1)}) ÷ ${_fmt(r2 * r2)} = ${_fmt(r1 * r1 * h1)} ÷ ${_fmt(r2 * r2)} = ${_fmt(h2)} cm.",
          mathLaTeX:
          "h_2 = \\frac{${_fmt(r1)}^2 \\times ${_fmt(h1)}}{${_fmt(r2)}^2} = \\frac{${_fmt(r1 * r1 * h1)}}{${_fmt(r2 * r2)}} = ${_fmt(h2)}\\text{ cm}",
        ));

        return CylinderResult(
          mode: 4,
          subMode: 0,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          r: r1,
          h: h1,
          r2: r2,
          h2: h2,
          displayUnit: "cm",
        );
      } else {
        double? dim = parseInput(dim1Str);
        double? hDrop = parseInput(dropStr);
        double? rate = parseInput(rateStr);
        if (dim == null || hDrop == null || rate == null) {
          throw const FormatException();
        }

        double r = _processRadius(isRadius1, dim, 'cm', workings, steps);

        if (workings.isNotEmpty && workings.last.isNotEmpty) workings.add("");
        workings.add("\\text{\\textbf{1. Volume of Water Lost in cm}^3}");
        double vDrop = pi.value * r * r * hDrop;
        workings.add(
            "V_{\\text{lost}} = \\pi r^2 h_{\\text{drop}} = $piL \\times ${_fmt(r)} \\times ${_fmt(r)} \\times ${_fmt(hDrop)} = ${_fmt(vDrop)} \\text{ cm}^3");

        workings.add("");
        workings.add("\\text{\\textbf{2. Convert Volume Lost to Litres}}");
        double litresDrop = vDrop / 1000;
        workings.add(
            "\\text{Litres Lost} = \\frac{${_fmt(vDrop)}}{1000} = ${_fmt(litresDrop)} \\text{ }\\ell");

        workings.add("");
        workings.add("\\text{\\textbf{3. Time Taken at ${_fmt(rate)} Litres/Hour}}");
        double timeHrs = litresDrop / rate;
        workings.add(
            "\\text{Time} = \\frac{\\text{Litres Lost}}{\\text{Leak Rate}} = \\frac{${_fmt(litresDrop)}}{${_fmt(rate)}} = ${_fmt(timeHrs)}\\text{ hours}");

        answers["Volume Lost (cm³)"] = "${_fmt(vDrop)} cm³";
        answers["Volume Lost (Litres)"] = "${_fmt(litresDrop)} ℓ";

        if (timeHrs % 1 == 0) {
          answers["Time Taken"] = "${_fmt(timeHrs)} hours";
        } else {
          int h = timeHrs.floor();
          int m = ((timeHrs - h) * 60).round();
          answers["Time Taken"] = "${_fmt(timeHrs)} h ($h h $m min)";
        }

        steps.add(CylinderStep(
          title: "Calculate the Volume of Water That Leaked Out",
          description:
          "When the water level in a cylindrical tank falls by ${_fmt(hDrop)} cm, the water lost forms a cylinder of radius r = ${_fmt(r)} cm and height h = ${_fmt(hDrop)} cm:\n"
              "• V = πr²h = ${pi.text} × ${_fmt(r)} × ${_fmt(r)} × ${_fmt(hDrop)} = ${_fmt(vDrop)} cm³.",
          mathLaTeX:
          "V_{\\text{lost}} = \\pi r^2 h = $piL \\times ${_fmt(r)}^2 \\times ${_fmt(hDrop)} = ${_fmt(vDrop)}\\text{ cm}^3",
        ));

        steps.add(CylinderStep(
          title: "Convert to Litres and Divide by Leak Rate",
          description:
          "1. Convert the volume lost from cm³ to litres (since 1,000 cm³ = 1 litre):\n"
              "   ${_fmt(vDrop)} ÷ 1,000 = ${_fmt(litresDrop)} litres.\n"
              "2. Since the tank loses ${_fmt(rate)} litres every hour, divide the litres lost by ${_fmt(rate)}:\n"
              "   Time = ${_fmt(litresDrop)} ÷ ${_fmt(rate)} = ${_fmt(timeHrs)} hours.",
          mathLaTeX:
          "\\text{Litres Lost} = \\frac{${_fmt(vDrop)}}{1000} = ${_fmt(litresDrop)}\\text{ }\\ell\n"
              "\\text{Time} = \\frac{${_fmt(litresDrop)}}{${_fmt(rate)}} = ${_fmt(timeHrs)}\\text{ hours}",
        ));

        return CylinderResult(
          mode: 4,
          subMode: 1,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
          r: r,
          h: hDrop,
          displayUnit: "cm",
        );
      }
    } catch (e) {
      return CylinderResult(
        mode: 4,
        subMode: subMode,
        finalAnswers: {},
        workingsLaTeX: [],
        steps: [],
        valid: false,
        errorMessage: "Invalid transfer or leak inputs.",
      );
    }
  }
}