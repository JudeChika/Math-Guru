import 'proportion_models.dart';

class ProportionLogic {

  /// Formats numbers to drop trailing .0 for cleaner display
  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// The main public solver method for the Unitary Method
  static ProportionResult solve({
    required String givenQuantityStr,
    required String givenUnit,
    required String givenTargetStr,
    required String targetUnit,
    required String newQuantityStr,
    required bool isDirect,
  }) {
    try {
      if (givenQuantityStr.trim().isEmpty || givenTargetStr.trim().isEmpty || newQuantityStr.trim().isEmpty) {
        throw const FormatException("Missing numeric values.");
      }

      double givenQty = double.parse(givenQuantityStr.trim());
      double givenTgt = double.parse(givenTargetStr.trim());

      // Determine if newQuantity is a number (e.g. 5) or a variable (e.g. x)
      double? newQtyNum = double.tryParse(newQuantityStr.trim());
      bool isVariable = newQtyNum == null;
      String variableName = isVariable ? newQuantityStr.trim() : "";

      if (givenQty <= 0) throw const FormatException("Given quantity must be greater than zero.");

      List<ProportionStep> steps = [];
      List<String> workings = [];

      // Step 1: Establish the facts and the target unit
      steps.add(ProportionStep(
          title: "Step 1: Write the Given Facts",
          description: "We are asked to find the value in '$targetUnit'. According to the rules of the unitary method, the quantity to be found MUST come last in every line of working.",
          mathLaTeX: "\\text{For } ${_fmt(givenQty)} \\text{ $givenUnit} \\rightarrow ${_fmt(givenTgt)} \\text{ $targetUnit}"
      ));
      workings.add("${_fmt(givenQty)} \\text{ $givenUnit} = ${_fmt(givenTgt)} \\text{ $targetUnit}");

      // Step 2: Determine Proportion Type and Find 1 Unit
      double oneUnitValue = 0;
      String oneUnitEq = "";
      String step2Desc = "";

      if (isDirect) {
        // Direct Proportion: Less means Less, More means More. Find 1 unit by DIVIDING.
        oneUnitValue = givenTgt / givenQty;
        oneUnitEq = "${_fmt(givenTgt)} \\div ${_fmt(givenQty)}";
        step2Desc = "This is an example of DIRECT proportion. Less $givenUnit means less $targetUnit. To find the rate for exactly 1 unit, we DIVIDE.";
      } else {
        // Inverse Proportion: Less means More, More means Less. Find 1 unit by MULTIPLYING.
        oneUnitValue = givenTgt * givenQty;
        oneUnitEq = "${_fmt(givenTgt)} \\times ${_fmt(givenQty)}";
        step2Desc = "This is an example of INVERSE proportion. Fewer $givenUnit take MORE $targetUnit. To find the rate for exactly 1 unit, we MULTIPLY.";
      }

      workings.add("1 \\text{ $givenUnit} = $oneUnitEq = ${_fmt(oneUnitValue)} \\text{ $targetUnit}");
      steps.add(ProportionStep(
          title: "Step 2: Find the Rate for 1 Unit",
          description: step2Desc,
          mathLaTeX: "1 \\text{ $givenUnit} = $oneUnitEq = ${_fmt(oneUnitValue)} \\text{ $targetUnit}"
      ));

      // Step 3: Find the Target Quantity
      String finalAnswerStr = "";
      String finalEq = "";
      String step3Desc = "";

      if (isVariable) {
        // Handle algebraic requests (e.g. "x hours")
        if (isDirect) {
          finalAnswerStr = "${_fmt(oneUnitValue)}$variableName";
          finalEq = "$variableName \\times ${_fmt(oneUnitValue)}";
          step3Desc = "To find the amount for '$variableName' $givenUnit in direct proportion, we multiply the 1-unit value by $variableName.";
        } else {
          finalAnswerStr = "\\frac{${_fmt(oneUnitValue)}}{$variableName}";
          finalEq = "${_fmt(oneUnitValue)} \\div $variableName";
          step3Desc = "To find the amount for '$variableName' $givenUnit in inverse proportion, we divide the 1-unit value by $variableName.";
        }
        workings.add("$variableName \\text{ $givenUnit} = $finalEq = $finalAnswerStr \\text{ $targetUnit}");

      } else {
        // Handle standard numeric requests
        double finalAnsNum = 0;
        if (isDirect) {
          finalAnsNum = oneUnitValue * newQtyNum;
          finalEq = "${_fmt(newQtyNum)} \\times ${_fmt(oneUnitValue)}";
          step3Desc = "Now we find the final amount. In direct proportion, more units mean more $targetUnit, so we MULTIPLY our 1-unit rate by ${_fmt(newQtyNum)}.";
        } else {
          finalAnsNum = oneUnitValue / newQtyNum;
          finalEq = "${_fmt(oneUnitValue)} \\div ${_fmt(newQtyNum)}";
          step3Desc = "Now we find the final amount. In inverse proportion, more units mean less $targetUnit, so we DIVIDE our 1-unit rate by ${_fmt(newQtyNum)}.";
        }
        finalAnswerStr = _fmt(finalAnsNum);
        workings.add("${_fmt(newQtyNum)} \\text{ $givenUnit} = $finalEq = $finalAnswerStr \\text{ $targetUnit}");
      }

      steps.add(ProportionStep(
          title: "Step 3: Solve for the Target Quantity",
          description: step3Desc,
          mathLaTeX: isVariable
              ? "$variableName \\text{ $givenUnit} = $finalEq = $finalAnswerStr"
              : "${_fmt(newQtyNum)} \\text{ $givenUnit} = $finalEq = $finalAnswerStr"
      ));

      return ProportionResult(
        givenQuantity: _fmt(givenQty),
        givenUnit: givenUnit,
        givenTarget: _fmt(givenTgt),
        targetUnit: targetUnit,
        newQuantity: isVariable ? variableName : _fmt(newQtyNum),
        isDirect: isDirect,
        finalAnswerLaTeX: "$finalAnswerStr \\text{ $targetUnit}",
        workingsLaTeX: workings,
        steps: steps,
        valid: true,
      );

    } catch (e) {
      return ProportionResult(
          givenQuantity: "", givenUnit: "", givenTarget: "", targetUnit: "", newQuantity: "", isDirect: true,
          finalAnswerLaTeX: "", workingsLaTeX: [], steps: [],
          valid: false, errorMessage: "Invalid input. Please ensure quantities are numbers (or a single variable like 'x' for the target)."
      );
    }
  }
}