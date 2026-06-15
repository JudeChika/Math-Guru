import 'unit_conversion_models.dart';

class UnitConversionSolver {
  // A relative value map where the smallest unit is the base (1)
  static final Map<String, Map<String, double>> unitData = {
    'Length': {'mm': 1, 'cm': 10, 'm': 1000, 'km': 1000000},
    'Mass': {'mg': 1, 'g': 1000, 'kg': 1000000, 't': 1000000000},
    'Capacity': {'ml': 1, 'cl': 10, 'l': 1000},
    'Time': {'sec': 1, 'min': 60, 'hr': 3600, 'day': 86400, 'week': 604800},
    'Area': {'mm²': 1, 'cm²': 100, 'm²': 1000000, 'ha': 10000000000, 'km²': 1000000000000},
  };

  // Helper to cleanly format decimals and add commas to large whole numbers
  static String _format(double n) {
    if (n >= 1000 && n == n.truncateToDouble()) {
      RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      return n.toInt().toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
    }
    return n == n.truncateToDouble()
        ? n.toInt().toString()
        : n.toStringAsFixed(5).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  static ConversionResult solve(String category, double value, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) {
      return ConversionResult(
          steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Please select two different units.");
    }

    Map<String, double> units = unitData[category]!;
    double fromVal = units[fromUnit]!;
    double toVal = units[toUnit]!;

    List<ConversionStep> steps = [];
    String valStr = _format(value);

    // Determine multiplier/divider
    bool isMultiply = fromVal > toVal;
    double factor = isMultiply ? (fromVal / toVal) : (toVal / fromVal);
    String fStr = _format(factor);

    // Step 1: Base relationship
    steps.add(ConversionStep(
        workingLaTeX: "1 \\text{ ${isMultiply ? fromUnit : toUnit}} = $fStr \\text{ ${isMultiply ? toUnit : fromUnit}}",
        explanation: "First, identify the standard relationship between the two units."
    ));

    // Area Teaching Moment
    if (category == 'Area' && factor >= 100) {
      steps.add(ConversionStep(
          workingLaTeX: "\\text{Area Factor} = \\text{Length Factor}^2",
          explanation: "Remember: Because area is measured in square units, its conversion factor is the square of the standard length factor (e.g. if 1 m = 100 cm, then 1 m² = 100 × 100 = 10,000 cm²)."
      ));
    }

    // Step 2 & 3: The Arithmetic
    double resultVal = isMultiply ? (value * factor) : (value / factor);
    String rStr = _format(resultVal);

    if (isMultiply) {
      steps.add(ConversionStep(
          workingLaTeX: "\\text{Value} \\times $fStr",
          explanation: "Rule: When converting from a LARGER unit ($fromUnit) to a SMALLER unit ($toUnit), we MULTIPLY."
      ));
      steps.add(ConversionStep(
          workingLaTeX: "$valStr \\times $fStr",
          explanation: "Multiply your value by the conversion factor."
      ));
    } else {
      steps.add(ConversionStep(
          workingLaTeX: "\\frac{\\text{Value}}{$fStr}",
          explanation: "Rule: When converting from a SMALLER unit ($fromUnit) to a LARGER unit ($toUnit), we DIVIDE."
      ));
      steps.add(ConversionStep(
          workingLaTeX: "\\frac{$valStr}{$fStr}",
          explanation: "Divide your value by the conversion factor."
      ));
    }

    // Step 4: Final Answer
    steps.add(ConversionStep(
        workingLaTeX: "$rStr \\text{ $toUnit}",
        explanation: "Calculate the arithmetic to find the final converted measurement.",
        isFinalAnswer: true
    ));

    return ConversionResult(steps: steps, finalAnswerLaTeX: "$rStr \\; \\text{$toUnit}");
  }
}