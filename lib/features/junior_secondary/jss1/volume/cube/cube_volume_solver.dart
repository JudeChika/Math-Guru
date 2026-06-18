import 'dart:math';
import 'cube_volume_models.dart';

class CubeVolumeSolver {
  // Base conversion logic (Relative to smallest unit 'mm')
  static final Map<String, double> _lengthFactors = {
    'mm': 1,
    'cm': 10,
    'm': 1000,
    'km': 1000000,
  };

  static String _format(double n) {
    if (n >= 1000 && n == n.truncateToDouble()) {
      RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      return n.toInt().toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
    }
    return n == n.truncateToDouble()
        ? n.toInt().toString()
        : n.toStringAsFixed(6).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  // Helper to fix floating point inaccuracies in cube roots (e.g. 64^(1/3) yielding 3.9999999)
  static double _cbrt(double v) {
    double res = pow(v, 1 / 3).toDouble();
    return (res.round() - res).abs() < 1e-10 ? res.roundToDouble() : res;
  }

  static CubeVolumeResult solveForVolume(String aInput, String fromUnit, String toUnit) {
    try {
      double a = double.parse(aInput.trim());
      List<CubeVolumeStep> steps = [];

      double volume = pow(a, 3).toDouble();

      String aStr = _format(a);
      String vStr = _format(volume);
      String uf = "\\text{$fromUnit}";

      steps.add(CubeVolumeStep(
          workingLaTeX: "V = a^3",
          explanation: "Start with the formula for the volume of a cube, where 'V' is volume and 'a' is the length of one side."
      ));
      steps.add(CubeVolumeStep(
          workingLaTeX: "V = ($aStr \\; $uf)^3",
          explanation: "Substitute the side length ($aStr $fromUnit) into the formula."
      ));
      steps.add(CubeVolumeStep(
          workingLaTeX: "V = $aStr \\times $aStr \\times $aStr",
          explanation: "Cube the number by multiplying it by itself three times."
      ));

      if (fromUnit == toUnit) {
        steps.add(CubeVolumeStep(
            workingLaTeX: "V = $vStr \\; $uf^3",
            explanation: "Calculate the final volume. Remember, volume is measured in cubic units.",
            isFinalAnswer: true
        ));
        return CubeVolumeResult(steps: steps, finalAnswerLaTeX: "V = $vStr \\; $uf^3");
      } else {
        // --- VOLUME CONVERSION LOGIC ---
        steps.add(CubeVolumeStep(
            workingLaTeX: "V = $vStr \\; $uf^3",
            explanation: "This gives us the volume in cubic $fromUnit."
        ));

        double fVal = _lengthFactors[fromUnit]!;
        double tVal = _lengthFactors[toUnit]!;
        bool isMultiply = fVal > tVal;

        double linearFactor = isMultiply ? (fVal / tVal) : (tVal / fVal);
        double cubicFactor = pow(linearFactor, 3).toDouble();

        String ut = "\\text{$toUnit}";
        String lfStr = _format(linearFactor);
        String cfStr = _format(cubicFactor);

        steps.add(CubeVolumeStep(
            workingLaTeX: "\\text{Volume Factor} = \\text{Length Factor}^3",
            explanation: "CONVERSION: To convert to $toUnit³, we must cube the standard length factor. Since 1 ${isMultiply ? fromUnit : toUnit} = $lfStr ${isMultiply ? toUnit : fromUnit}, then 1 ${isMultiply ? fromUnit : toUnit}³ = $lfStr³ = $cfStr ${isMultiply ? toUnit : fromUnit}³."
        ));

        double finalConvertedVol = isMultiply ? (volume * cubicFactor) : (volume / cubicFactor);
        String finalVStr = _format(finalConvertedVol);

        if (isMultiply) {
          steps.add(CubeVolumeStep(
              workingLaTeX: "V = $vStr \\times $cfStr",
              explanation: "Because we are converting to a SMALLER unit ($toUnit³), we MULTIPLY."
          ));
        } else {
          steps.add(CubeVolumeStep(
              workingLaTeX: "V = \\frac{$vStr}{$cfStr}",
              explanation: "Because we are converting to a LARGER unit ($toUnit³), we DIVIDE."
          ));
        }

        steps.add(CubeVolumeStep(
            workingLaTeX: "V = $finalVStr \\; $ut^3",
            explanation: "Calculate to find the final converted volume.",
            isFinalAnswer: true
        ));

        return CubeVolumeResult(steps: steps, finalAnswerLaTeX: "\\text{Base: } $vStr \\; $uf^3 \\\\ \\text{Converted: } $finalVStr \\; $ut^3");
      }
    } catch (_) {
      return CubeVolumeResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }

  static CubeVolumeResult solveForSide(String vInput, String fromUnit, String toUnit) {
    try {
      double v = double.parse(vInput.trim());
      List<CubeVolumeStep> steps = [];

      double side = _cbrt(v);

      String vStr = _format(v);
      String aStr = _format(side);
      String uf = "\\text{$fromUnit}";

      steps.add(CubeVolumeStep(
          workingLaTeX: "V = a^3",
          explanation: "Start with the formula for the volume of a cube."
      ));
      steps.add(CubeVolumeStep(
          workingLaTeX: "a = \\sqrt[3]{V}",
          explanation: "Rearrange the formula to solve for the side 'a' by finding the cube root of the volume."
      ));
      steps.add(CubeVolumeStep(
          workingLaTeX: "a = \\sqrt[3]{$vStr \\; $uf^3}",
          explanation: "Substitute the given volume ($vStr $fromUnit³) into the formula."
      ));

      if (fromUnit == toUnit) {
        steps.add(CubeVolumeStep(
            workingLaTeX: "a = $aStr \\; $uf",
            explanation: "Calculate the cube root to find the side length. Notice the unit is now linear (not cubed).",
            isFinalAnswer: true
        ));
        return CubeVolumeResult(steps: steps, finalAnswerLaTeX: "a = $aStr \\; $uf");
      } else {
        // --- LENGTH CONVERSION LOGIC ---
        steps.add(CubeVolumeStep(
            workingLaTeX: "a = $aStr \\; $uf",
            explanation: "This gives us the side length in $fromUnit. Now we convert to $toUnit."
        ));

        double fVal = _lengthFactors[fromUnit]!;
        double tVal = _lengthFactors[toUnit]!;
        bool isMultiply = fVal > tVal;

        double linearFactor = isMultiply ? (fVal / tVal) : (tVal / fVal);

        String ut = "\\text{$toUnit}";
        String lfStr = _format(linearFactor);

        double finalSide = isMultiply ? (side * linearFactor) : (side / linearFactor);
        String finalSStr = _format(finalSide);

        if (isMultiply) {
          steps.add(CubeVolumeStep(
              workingLaTeX: "a = $aStr \\times $lfStr",
              explanation: "Converting to a SMALLER unit ($toUnit), so we MULTIPLY by $lfStr."
          ));
        } else {
          steps.add(CubeVolumeStep(
              workingLaTeX: "a = \\frac{$aStr}{$lfStr}",
              explanation: "Converting to a LARGER unit ($toUnit), so we DIVIDE by $lfStr."
          ));
        }

        steps.add(CubeVolumeStep(
            workingLaTeX: "a = $finalSStr \\; $ut",
            explanation: "Calculate to find the final converted side length.",
            isFinalAnswer: true
        ));

        return CubeVolumeResult(steps: steps, finalAnswerLaTeX: "\\text{Base: } $aStr \\; $uf \\\\ \\text{Converted: } $finalSStr \\; $ut");
      }
    } catch (_) {
      return CubeVolumeResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid inputs.");
    }
  }
}