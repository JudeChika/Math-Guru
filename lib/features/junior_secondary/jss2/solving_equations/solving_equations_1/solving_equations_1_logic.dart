import 'package:math_guru/features/junior_secondary/jss2/solving_equations/solving_equations_1/solving_equations_1_model.dart';

class SolvingEquationsLogic {

  static int _gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      int t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// Formats exact fractions and mixed numbers (e.g. 23/9 -> 2 \frac{5}{9})
  static String _fmtFrac(int num, int den, {bool allowMixed = true}) {
    if (num == 0) return "0";
    bool isNeg = (num < 0) ^ (den < 0);
    num = num.abs();
    den = den.abs();

    int gcd = _gcd(num, den);
    num ~/= gcd;
    den ~/= gcd;

    String sign = isNeg ? "-" : "";

    if (den == 1) return "$sign$num";

    if (allowMixed && num > den) {
      int whole = num ~/ den;
      int rem = num % den;
      return "$sign$whole \\frac{$rem}{$den}";
    }

    return "$sign\\frac{$num}{$den}";
  }

  /// Parses a single side of an equation (e.g. "25 - 9x" or "15 + 9")
  static Map<String, dynamic> _parseSide(String side) {
    String s = side.replaceAll(' ', '').replaceAll('-', '+-');
    if (s.startsWith('+-')) s = '-${s.substring(2)}';

    double coeffSum = 0;
    double constSum = 0;
    String varName = "";

    List<String> parts = s.split('+');
    for (String p in parts) {
      if (p.isEmpty) continue;

      var matchVar = RegExp(r'^([+-]?\d*\.?\d*)([a-zA-Z]+)$').firstMatch(p);
      if (matchVar != null) {
        String cStr = matchVar.group(1)!;
        String vStr = matchVar.group(2)!;

        if (varName.isEmpty) {
          varName = vStr;
        } else if (varName != vStr) {
          throw const FormatException("Multiple variable types found.");
        }

        if (cStr == '' || cStr == '+') {
          coeffSum += 1;
        } else if (cStr == '-') {
          coeffSum -= 1;
        } else {
          coeffSum += double.parse(cStr);
        }
      } else if (RegExp(r'^[+-]?\d*\.?\d+$').hasMatch(p)) {
        constSum += double.parse(p);
      }
    }
    return {'coeff': coeffSum, 'const': constSum, 'var': varName};
  }

  static String _toAlgStr(double coeff, double constant, String v) {
    String res = "";
    if (coeff != 0) {
      if (coeff == 1) {
        res = v;
      } else if (coeff == -1) {
        res = "-$v";
      } else {
        res = "${_fmt(coeff)}$v";
      }
    }

    if (constant != 0) {
      if (res.isNotEmpty) {
        res += constant > 0 ? " + ${_fmt(constant)}" : " - ${_fmt(constant.abs())}";
      } else {
        res = _fmt(constant);
      }
    }

    if (res.isEmpty) return "0";
    return res;
  }

  static EquationResult solve(String equationStr) {
    try {
      if (!equationStr.contains('=')) throw const FormatException("Equation must contain an '=' sign.");

      List<String> sides = equationStr.split('=');
      if (sides.length != 2) throw const FormatException("Invalid equation format.");

      var lhsData = _parseSide(sides[0]);
      var rhsData = _parseSide(sides[1]);

      double lCoeff = lhsData['coeff'];
      double lConst = lhsData['const'];
      double rCoeff = rhsData['coeff'];
      double rConst = rhsData['const'];

      String v = lhsData['var'].isNotEmpty ? lhsData['var'] : rhsData['var'];
      if (v.isEmpty) v = "x"; // Fallback if no variable is found at all (though technically invalid equation)

      if (lCoeff == rCoeff) throw const FormatException("Variables cancel out. No solution.");

      List<EquationStep> steps = [];
      List<String> workings = [];

      String originalLatex = "${_toAlgStr(lCoeff, lConst, v)} = ${_toAlgStr(rCoeff, rConst, v)}";
      workings.add(originalLatex);

      steps.add(EquationStep(
          title: "Step 1: The Equation",
          description: "To solve an equation means to find the exact value of the unknown ('$v') that makes both sides perfectly balanced.",
          mathLaTeX: originalLatex
      ));

      // 1. Balance Variables (Bring to LHS)
      if (rCoeff != 0) {
        String invSign = rCoeff > 0 ? "-" : "+";
        String actionStr = rCoeff > 0 ? "Subtract ${_fmt(rCoeff.abs())}$v from" : "Add ${_fmt(rCoeff.abs())}$v to";

        String stepLhs = "${_toAlgStr(lCoeff, lConst, v)} $invSign ${_fmt(rCoeff.abs())}$v";
        String stepRhs = "${_toAlgStr(rCoeff, rConst, v)} $invSign ${_fmt(rCoeff.abs())}$v";

        workings.add("$stepLhs = $stepRhs");

        lCoeff -= rCoeff;
        rCoeff = 0;

        String newEq = "${_toAlgStr(lCoeff, lConst, v)} = ${_toAlgStr(rCoeff, rConst, v)}";
        workings.add(newEq);

        steps.add(EquationStep(
            title: "Step 2: Balance the Variables",
            description: "$actionStr both sides to move all the unknown variables to the Left-Hand Side (LHS).",
            mathLaTeX: "$stepLhs = $stepRhs \\Rightarrow $newEq"
        ));
      }

      // 2. Balance Constants (Bring to RHS)
      if (lConst != 0) {
        String invSign = lConst > 0 ? "-" : "+";
        String addOrSub = lConst > 0 ? "Subtract" : "Add";
        double absC = lConst.abs();

        String stepLhs = "${_toAlgStr(lCoeff, lConst, v)} $invSign ${_fmt(absC)}";
        String stepRhs = "${_toAlgStr(rCoeff, rConst, v)} $invSign ${_fmt(absC)}";

        workings.add("$stepLhs = $stepRhs");

        rConst -= lConst;
        lConst = 0;

        String newEq = "${_toAlgStr(lCoeff, lConst, v)} = ${_toAlgStr(rCoeff, rConst, v)}";
        workings.add(newEq);

        steps.add(EquationStep(
            title: "Step 3: Additive Inverse (Balance Constants)",
            description: "We need the '$v' term to be completely alone. The additive inverse of ${_fmt(lConst + absC * (invSign == '-' ? 1 : -1))} is $invSign${_fmt(absC)}. $addOrSub ${_fmt(absC)} on BOTH sides to keep the equation balanced.",
            mathLaTeX: "$stepLhs = $stepRhs \\Rightarrow $newEq"
        ));
      }

      // 3. Divide by Coefficient
      int finalNum = rConst.round();
      int finalDen = lCoeff.round();

      // Safety handling for decimals in the input (multiply by 10/100 to make integers for the fraction engine)
      if (rConst != rConst.toInt() || lCoeff != lCoeff.toInt()) {
        finalNum = (rConst * 100).round();
        finalDen = (lCoeff * 100).round();
      }

      String finalAnsStr = "";

      if (lCoeff != 1) {
        String divLhs = "\\frac{${_toAlgStr(lCoeff, 0, v)}}{${_fmt(lCoeff)}}";
        String divRhs = "\\frac{${_fmt(rConst)}}{${_fmt(lCoeff)}}";

        workings.add("$divLhs = $divRhs");

        String rawFrac = _fmtFrac(finalNum, finalDen, allowMixed: false);
        String mixedFrac = _fmtFrac(finalNum, finalDen, allowMixed: true);

        finalAnsStr = "$v = $mixedFrac";

        if (rawFrac != mixedFrac && rConst/lCoeff != (rConst/lCoeff).toInt()) {
          workings.add("$v = $rawFrac");
          workings.add("$v = $mixedFrac");
        } else {
          workings.add("$v = $mixedFrac");
        }

        steps.add(EquationStep(
            title: "Step 4: Divide by the Coefficient",
            description: "The equation is now much simpler. To isolate '$v' completely, divide both sides by its coefficient (${_fmt(lCoeff)}). Pay close attention to directed numbers (negative/positive rules).",
            mathLaTeX: "$divLhs = $divRhs \\Rightarrow $finalAnsStr"
        ));
      } else {
        finalAnsStr = "$v = ${_fmt(rConst)}";
        steps.add(EquationStep(
            title: "Step 4: Simplified",
            description: "The variable is isolated, and we have our final answer.",
            mathLaTeX: finalAnsStr
        ));
      }

      // 4. The "Check" Step
      double origLhsCoeff = lhsData['coeff'];
      double origLhsConst = lhsData['const'];
      double ansVal = rConst / lCoeff;

      double checkVal = origLhsCoeff * ansVal + origLhsConst;

      String checkSub = "";
      if (origLhsCoeff != 0) {
        checkSub = origLhsCoeff == 1
            ? _fmtFrac(finalNum, finalDen)
            : "${_fmt(origLhsCoeff)} \\times ${_fmtFrac(finalNum, finalDen, allowMixed: false)}";
      }

      String checkConstPart = "";
      if (origLhsConst != 0) {
        if (origLhsCoeff != 0) {
          checkConstPart = origLhsConst > 0 ? "+ ${_fmt(origLhsConst)}" : "- ${_fmt(origLhsConst.abs())}";
        } else {
          checkConstPart = _fmt(origLhsConst);
        }
      } else if (origLhsCoeff == 0) {
        checkConstPart = "0";
      }

      String checkLatex = "\\text{When } $finalAnsStr, \\quad \\text{LHS} = $checkSub $checkConstPart = ${_fmt(checkVal)} = \\text{RHS}";

      workings.add("");
      workings.add("\\text{\\textbf{Check:}}");
      workings.add(checkLatex);

      steps.add(EquationStep(
          title: "Step 5: The Check",
          description: "Always verify your answer! Substitute the value of $v back into the original Left-Hand Side (LHS) of the equation to prove that it perfectly matches the Right-Hand Side (RHS).",
          mathLaTeX: checkLatex
      ));

      return EquationResult(
          originalEquationLaTeX: originalLatex,
          finalAnswerLaTeX: finalAnsStr,
          workingsLaTeX: workings,
          steps: steps
      );

    } catch (e) {
      return EquationResult(
          originalEquationLaTeX: equationStr, finalAnswerLaTeX: "", workingsLaTeX: [], steps: [],
          valid: false, errorMessage: "Invalid equation. Please ensure it has an '=' sign and valid algebraic terms."
      );
    }
  }
}