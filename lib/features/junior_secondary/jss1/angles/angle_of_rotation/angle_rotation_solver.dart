import 'angle_rotation_models.dart';

class AngleRotationSolver {
  static String _format(double n) {
    return n == n.truncateToDouble() ? n.toInt().toString() : n.toStringAsFixed(2);
  }

  // ==========================================
  // MODE 1: CLOCK INTERVALS (e.g. 4.00 to 9.00)
  // ==========================================
  static AngleRotationResult solveInterval(String startIn, String endIn) {
    try {
      double start = double.parse(startIn.trim());
      double end = double.parse(endIn.trim());
      List<AngleRotationStep> steps = [];

      double diff = end - start;
      if (diff < 0) diff += 12; // E.g., from 10.00 to 1.00 -> 1 - 10 = -9 + 12 = 3

      steps.add(AngleRotationStep(
          workingLaTeX: "\\text{Interval} = ${_format(end)} - ${_format(start)} = ${_format(diff)}",
          explanation: "Calculate how many spaces the hand moves on the clock face."
      ));

      steps.add(AngleRotationStep(
          workingLaTeX: "\\text{Rotation} = \\frac{${_format(diff)}}{12}",
          explanation: "Since there are 12 main numbers on a clock, the hand covers ${_format(diff)} out of 12 spaces."
      ));

      double angle = (diff / 12) * 360;

      steps.add(AngleRotationStep(
          workingLaTeX: "\\text{Angle} = \\frac{${_format(diff)}}{12} \\times 360^\\circ",
          explanation: "Multiply the fraction by 360° (a full rotation) to find the angle."
      ));

      steps.add(AngleRotationStep(
          workingLaTeX: "\\text{Angle} = ${_format(angle)}^\\circ",
          explanation: "Calculate to find the final degrees.", isFinalAnswer: true
      ));

      return AngleRotationResult(steps: steps, finalAnswerLaTeX: "${_format(angle)}^\\circ");
    } catch (_) {
      return AngleRotationResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid input.");
    }
  }

  // ==========================================
  // MODE 2: TIME TO DEGREES / DEGREES TO TIME
  // ==========================================
  static AngleRotationResult solveTimeAndAngle(String valIn, String handType, bool solvingForDegrees) {
    try {
      double val = double.parse(valIn.trim());
      List<AngleRotationStep> steps = [];

      String unit = handType == 'Hour' ? 'hours' : (handType == 'Minute' ? 'minutes' : 'seconds');
      double baseDivisor = handType == 'Hour' ? 12 : 60;

      if (solvingForDegrees) {
        // Time to Degrees (e.g. 28 seconds)
        steps.add(AngleRotationStep(
            workingLaTeX: "\\text{Fraction} = \\frac{\\text{Time Passed}}{\\text{Full Turn Time}}",
            explanation: "Find the fraction of a full rotation. The $handType Hand takes ${_format(baseDivisor)} $unit to make a full turn."
        ));

        double angle = (val / baseDivisor) * 360;

        steps.add(AngleRotationStep(
            workingLaTeX: "\\text{Angle} = \\frac{${_format(val)}}{${_format(baseDivisor)}} \\times 360^\\circ",
            explanation: "Multiply the fraction by 360° to find the angle."
        ));

        steps.add(AngleRotationStep(
            workingLaTeX: "\\text{Angle} = ${_format(angle)}^\\circ",
            explanation: "Calculate to find the final angle covered.", isFinalAnswer: true
        ));

        return AngleRotationResult(steps: steps, finalAnswerLaTeX: "${_format(angle)}^\\circ");
      } else {
        // Degrees to Time (e.g. 120°)
        steps.add(AngleRotationStep(
            workingLaTeX: "30^\\circ = 5 \\text{ $unit}",
            explanation: "On the clock face, every number gap is 30°. For the $handType Hand, 30° represents 5 $unit." // Adapting book logic
        ));

        steps.add(AngleRotationStep(
            workingLaTeX: "1^\\circ = \\frac{5}{30} \\text{ $unit}",
            explanation: "Divide by 30 to find the time for a single degree."
        ));

        double time = (5 / 30) * val;

        steps.add(AngleRotationStep(
            workingLaTeX: "${_format(val)}^\\circ = \\frac{5}{30} \\times ${_format(val)} \\text{ $unit}",
            explanation: "Multiply by the given degrees (${_format(val)}°) to find the total time."
        ));

        steps.add(AngleRotationStep(
            workingLaTeX: "\\text{Time} = ${_format(time)} \\text{ $unit}",
            explanation: "Calculate to find the final time elapsed.", isFinalAnswer: true
        ));

        return AngleRotationResult(steps: steps, finalAnswerLaTeX: "${_format(time)} \\text{ $unit}");
      }
    } catch (_) {
      return AngleRotationResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid input.");
    }
  }

  // ==========================================
  // MODE 3: DMS CONVERSIONS (Degrees, Minutes, Seconds)
  // ==========================================
  static AngleRotationResult solveDMS(String dIn, String mIn, String decIn) {
    try {
      List<AngleRotationStep> steps = [];

      if (decIn.isEmpty) {
        // Convert DMS to Decimal (e.g. 53° 48')
        double d = double.tryParse(dIn.trim()) ?? 0;
        double m = double.tryParse(mIn.trim()) ?? 0;

        steps.add(AngleRotationStep(
            workingLaTeX: "$d^\\circ \\; $m'",
            explanation: "We need to convert the minutes (') into decimal degrees. There are 60 minutes in 1 degree."
        ));

        steps.add(AngleRotationStep(
            workingLaTeX: "$d^\\circ + (\\frac{$m}{60})^\\circ",
            explanation: "Change $m' to degrees by dividing by 60."
        ));

        double mDec = m / 60;
        double finalDec = d + mDec;

        steps.add(AngleRotationStep(
            workingLaTeX: "$d^\\circ + ${_format(mDec)}^\\circ",
            explanation: "Add the decimal to the whole degrees."
        ));

        steps.add(AngleRotationStep(
            workingLaTeX: "${finalDec.toStringAsFixed(2)}^\\circ",
            explanation: "Final answer formatted to 2 decimal places.", isFinalAnswer: true
        ));

        return AngleRotationResult(steps: steps, finalAnswerLaTeX: "${finalDec.toStringAsFixed(2)}^\\circ");
      } else {
        // Convert Decimal to DMS (e.g. 53.8°)
        double dec = double.parse(decIn.trim());

        int d = dec.truncate();
        double remainder = dec - d;

        steps.add(AngleRotationStep(
            workingLaTeX: "${dec}^\\circ = $d^\\circ + 0.${dec.toString().split('.')[1]}^\\circ",
            explanation: "Separate the whole degrees from the decimal part."
        ));

        double m = remainder * 60;

        steps.add(AngleRotationStep(
            workingLaTeX: "0.${dec.toString().split('.')[1]}^\\circ \\times 60 = ${_format(m)}'",
            explanation: "Multiply the decimal part by 60 to convert it into minutes (')."
        ));

        steps.add(AngleRotationStep(
            workingLaTeX: "$d^\\circ \\; ${_format(m)}'",
            explanation: "Combine the degrees and the minutes.", isFinalAnswer: true
        ));

        return AngleRotationResult(steps: steps, finalAnswerLaTeX: "$d^\\circ \\; ${_format(m)}'");
      }
    } catch (_) {
      return AngleRotationResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid input.");
    }
  }

  // ==========================================
  // MODE 4: ARITHMETIC (+, -, *, /)
  // ==========================================
  static AngleRotationResult solveArithmetic(
      String d1In, String m1In, String op, String d2In, String m2In, String scalarIn) {

    try {
      List<AngleRotationStep> steps = [];

      int d1 = int.tryParse(d1In.trim()) ?? 0;
      double m1 = double.tryParse(m1In.trim()) ?? 0;

      if (op == 'add') {
        int d2 = int.tryParse(d2In.trim()) ?? 0;
        double m2 = double.tryParse(m2In.trim()) ?? 0;

        steps.add(AngleRotationStep(workingLaTeX: "\\text{Add Degrees: } $d1^\\circ + $d2^\\circ = ${d1 + d2}^\\circ", explanation: "First, add the degrees together."));
        steps.add(AngleRotationStep(workingLaTeX: "\\text{Add Minutes: } ${_format(m1)}' + ${_format(m2)}' = ${_format(m1 + m2)}'", explanation: "Next, add the minutes together."));

        int totalD = d1 + d2;
        double totalM = m1 + m2;

        if (totalM >= 60) {
          int extraD = (totalM / 60).truncate();
          double leftM = totalM % 60;
          steps.add(AngleRotationStep(workingLaTeX: "${_format(totalM)}' = $extraD^\\circ \\; ${_format(leftM)}'", explanation: "Because the minutes are 60 or more, convert them into degrees. 60' = 1°."));
          totalD += extraD;
          totalM = leftM;
          steps.add(AngleRotationStep(workingLaTeX: "\\text{Total} = $totalD^\\circ \\; ${_format(totalM)}'", explanation: "Add the carried-over degrees to the total.", isFinalAnswer: true));
        } else {
          steps.add(AngleRotationStep(workingLaTeX: "\\text{Total} = $totalD^\\circ \\; ${_format(totalM)}'", explanation: "Combine the results.", isFinalAnswer: true));
        }
        return AngleRotationResult(steps: steps, finalAnswerLaTeX: "$totalD^\\circ \\; ${_format(totalM)}'");

      }
      else if (op == 'sub') {
        int d2 = int.tryParse(d2In.trim()) ?? 0;
        double m2 = double.tryParse(m2In.trim()) ?? 0;

        if (m1 < m2) {
          steps.add(AngleRotationStep(workingLaTeX: "${_format(m1)}' < ${_format(m2)}'", explanation: "We cannot subtract ${_format(m2)}' from ${_format(m1)}'. We must borrow 1° from the degrees column."));
          d1 -= 1;
          m1 += 60;
          steps.add(AngleRotationStep(workingLaTeX: "\\text{Borrow: } $d1^\\circ \\; (${_format(m1 - 60)}' + 60') = $d1^\\circ \\; ${_format(m1)}'", explanation: "Since 1° = 60', adding it to the minutes gives us ${_format(m1)}'. Now we can subtract."));
        }

        int finalD = d1 - d2;
        double finalM = m1 - m2;

        steps.add(AngleRotationStep(workingLaTeX: "\\text{Subtract Degrees: } $d1^\\circ - $d2^\\circ = $finalD^\\circ", explanation: "Subtract the degrees."));
        steps.add(AngleRotationStep(workingLaTeX: "\\text{Subtract Minutes: } ${_format(m1)}' - ${_format(m2)}' = ${_format(finalM)}'", explanation: "Subtract the minutes."));
        steps.add(AngleRotationStep(workingLaTeX: "\\text{Total} = $finalD^\\circ \\; ${_format(finalM)}'", explanation: "Combine the results.", isFinalAnswer: true));

        return AngleRotationResult(steps: steps, finalAnswerLaTeX: "$finalD^\\circ \\; ${_format(finalM)}'");

      }
      else if (op == 'mul') {
        double k = double.parse(scalarIn.trim());

        int totalD = (d1 * k).truncate();
        double totalM = m1 * k;

        steps.add(AngleRotationStep(workingLaTeX: "\\text{Multiply Degrees: } $d1^\\circ \\times ${_format(k)} = $totalD^\\circ", explanation: "Multiply the degrees by ${_format(k)}."));
        steps.add(AngleRotationStep(workingLaTeX: "\\text{Multiply Minutes: } ${_format(m1)}' \\times ${_format(k)} = ${_format(totalM)}'", explanation: "Multiply the minutes by ${_format(k)}."));

        if (totalM >= 60) {
          int extraD = (totalM / 60).truncate();
          double leftM = totalM % 60;
          steps.add(AngleRotationStep(workingLaTeX: "${_format(totalM)}' = $extraD^\\circ \\; ${_format(leftM)}'", explanation: "Because the minutes are 60 or more, convert them. Divide by 60."));
          totalD += extraD;
          totalM = leftM;
          steps.add(AngleRotationStep(workingLaTeX: "\\text{Total} = $totalD^\\circ \\; ${_format(totalM)}'", explanation: "Add the carried-over degrees.", isFinalAnswer: true));
        } else {
          steps.add(AngleRotationStep(workingLaTeX: "\\text{Total} = $totalD^\\circ \\; ${_format(totalM)}'", explanation: "Combine the results.", isFinalAnswer: true));
        }
        return AngleRotationResult(steps: steps, finalAnswerLaTeX: "$totalD^\\circ \\; ${_format(totalM)}'");

      }
      else if (op == 'div') {
        double k = double.parse(scalarIn.trim());

        int dAns = (d1 / k).truncate();
        double dRem = d1 % k;

        steps.add(AngleRotationStep(workingLaTeX: "\\text{Divide Degrees: } $d1^\\circ \\div ${_format(k)} = $dAns^\\circ \\text{ R } ${_format(dRem)}^\\circ", explanation: "Divide the degrees by ${_format(k)}. The whole number answer is $dAns°."));

        double totalM = m1;
        if (dRem > 0) {
          steps.add(AngleRotationStep(workingLaTeX: "${_format(dRem)}^\\circ \\times 60 = ${_format(dRem * 60)}'", explanation: "Take the remainder (${_format(dRem)}°) and convert it to minutes by multiplying by 60."));
          totalM += (dRem * 60);
          steps.add(AngleRotationStep(workingLaTeX: "\\text{Total Minutes} = ${_format(m1)}' + ${_format(dRem * 60)}' = ${_format(totalM)}'", explanation: "Add these new minutes to the existing minutes."));
        }

        double mAns = totalM / k;
        steps.add(AngleRotationStep(workingLaTeX: "\\text{Divide Minutes: } ${_format(totalM)}' \\div ${_format(k)} = ${_format(mAns)}'", explanation: "Now divide the total minutes by ${_format(k)}."));
        steps.add(AngleRotationStep(workingLaTeX: "\\text{Total} = $dAns^\\circ \\; ${_format(mAns)}'", explanation: "Combine the degrees and minutes results.", isFinalAnswer: true));

        return AngleRotationResult(steps: steps, finalAnswerLaTeX: "$dAns^\\circ \\; ${_format(mAns)}'");
      }

      return AngleRotationResult(steps: [], finalAnswerLaTeX: "", valid: false);
    } catch (_) {
      return AngleRotationResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid input.");
    }
  }
}