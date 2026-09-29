import 'dart:math' as math;
import 'factorisation_models.dart';

class AlgTerm {
  final int coeff;
  final Map<String, int> vars;
  final String rawString;

  AlgTerm(this.coeff, this.vars, this.rawString);

  String toLaTeX({bool isFirst = false}) {
    if (coeff == 0) return "0";
    String sign = coeff < 0 ? "-" : (isFirst ? "" : "+");

    int absC = coeff.abs();
    String cStr = (absC == 1 && vars.isNotEmpty) ? "" : absC.toString();

    List<String> vStrs = [];
    var sortedKeys = vars.keys.toList()..sort();
    for (var k in sortedKeys) {
      int p = vars[k]!;
      if (p == 1) {
        vStrs.add(k);
      } else if (p > 1) vStrs.add("$k^{$p}");
    }
    return "$sign $cStr${vStrs.join('')}".trim();
  }
}

class FactorisationLogic {

  static AlgTerm? _parseTerm(String input) {
    String s = input.replaceAll(' ', '');
    if (s.isEmpty) return null;

    int coeff = 1;
    Map<String, int> vars = {};

    var match = RegExp(r'^([-+]?\d*)(.*)$').firstMatch(s);
    if (match != null) {
      String cStr = match.group(1) ?? '';
      String vStr = match.group(2) ?? '';

      if (cStr == '-') {
        coeff = -1;
      } else if (cStr == '+' || cStr == '') coeff = 1;
      else coeff = int.tryParse(cStr) ?? 1;

      var vMatches = RegExp(r'([a-zA-Z])(?:\^([-+]?\d+))?').allMatches(vStr);
      for (var m in vMatches) {
        String v = m.group(1)!;
        int p = m.group(2) != null ? int.parse(m.group(2)!) : 1;
        vars[v] = (vars[v] ?? 0) + p;
      }
    }
    return AlgTerm(coeff, vars, input.trim());
  }

  static List<AlgTerm> _splitPolynomial(String s) {
    s = s.replaceAll(' ', '').replaceAll('-', '+-');
    if (s.startsWith('+-')) s = '-${s.substring(2)}';
    List<String> parts = s.split('+').where((e) => e.isNotEmpty).toList();

    List<AlgTerm> terms = [];
    for (var p in parts) {
      var t = _parseTerm(p);
      if (t != null) terms.add(t);
    }
    return terms;
  }

  static AlgTerm _divideTerms(AlgTerm num, AlgTerm den) {
    int newCoeff = num.coeff ~/ den.coeff;
    Map<String, int> newVars = Map.from(num.vars);
    den.vars.forEach((k, v) {
      newVars[k] = (newVars[k] ?? 0) - v;
    });
    newVars.removeWhere((k, v) => v == 0);
    return AlgTerm(newCoeff, newVars, "");
  }

  static FactorisationResult solveFactorise(String expression) {
    try {
      List<AlgTerm> terms = _splitPolynomial(expression);
      if (terms.isEmpty) throw const FormatException("Invalid expression.");
      if (terms.length == 1) throw const FormatException("Enter a binomial (e.g. 15x + 10).");

      List<FactorisationStep> steps = [];
      List<String> workings = [];

      String originalLatex = terms.asMap().entries.map((e) => e.value.toLaTeX(isFirst: e.key == 0)).join(' ');
      workings.add("\\text{Factorise: } $originalLatex");

      int hcfCoeff = terms[0].coeff.abs();
      for (int i = 1; i < terms.length; i++) {
        hcfCoeff = hcfCoeff.gcd(terms[i].coeff.abs());
      }

      if (terms[0].coeff < 0) hcfCoeff = -hcfCoeff;

      Map<String, int> hcfVars = Map.from(terms[0].vars);
      for (int i = 1; i < terms.length; i++) {
        var tVars = terms[i].vars;
        var keys = hcfVars.keys.toList();
        for (var k in keys) {
          if (!tVars.containsKey(k)) {
            hcfVars.remove(k);
          } else {
            hcfVars[k] = math.min(hcfVars[k]!, tVars[k]!);
          }
        }
      }

      AlgTerm hcfTerm = AlgTerm(hcfCoeff, hcfVars, "");
      String outsideStr = hcfTerm.toLaTeX(isFirst: true);

      steps.add(FactorisationStep(
          title: "Step 1: Find the Highest Common Factor (HCF)",
          description: "Factorisation is the reverse of expanding brackets. The first step is to find the HCF of all the terms. We find the biggest number that divides the coefficients, and the letters that are shared by all terms.",
          mathLaTeX: "\\text{HCF of terms} = $outsideStr"
      ));

      List<AlgTerm> insideTerms = [];
      List<String> divFractions = [];
      List<String> divisionBreakdown = [];
      for (var t in terms) {
        var result = _divideTerms(t, hcfTerm);
        insideTerms.add(result);
        divFractions.add("\\frac{${t.toLaTeX(isFirst: true)}}{$outsideStr}");
        divisionBreakdown.add("\\frac{${t.toLaTeX(isFirst: true)}}{$outsideStr} = ${result.toLaTeX(isFirst: true)}");
      }

      steps.add(FactorisationStep(
          title: "Step 2: Set up the Bracket",
          description: "We place our HCF outside the bracket: $outsideStr( ... ). To find exactly what goes inside the bracket, we must divide every original term by the HCF.",
          mathLaTeX: "$outsideStr \\left( ${divFractions.join(' + ')} \\right)".replaceAll('+ -', '- ')
      ));

      String divStepStr = "$outsideStr \\left( ${divFractions.join(' + ')} \\right)";
      divStepStr = divStepStr.replaceAll('+ -', '- ');
      workings.add("= $divStepStr");

      steps.add(FactorisationStep(
          title: "Step 3: Divide to find the Inside",
          description: "Perform the division for each term. Notice how the shared numbers and letters cancel out.",
          mathLaTeX: divisionBreakdown.join('\\quad ; \\quad')
      ));

      String insideStr = insideTerms.asMap().entries.map((e) => e.value.toLaTeX(isFirst: e.key == 0)).join(' ');
      String finalResult = "$outsideStr ($insideStr)";

      workings.add("= $finalResult");

      steps.add(FactorisationStep(
          title: "Step 4: Final Answer",
          description: "Write the results of your division inside the bracket. You have successfully factorised the expression! You can always check your answer by expanding the bracket to see if it gives you the original expression.",
          mathLaTeX: finalResult
      ));

      return FactorisationResult(
          mode: "Factorise",
          finalAnswers: {"Factorised Expression": finalResult},
          workingsLaTeX: workings,
          steps: steps
      );

    } catch (e) {
      return FactorisationResult(mode: "Factorise", finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Invalid polynomial expression.");
    }
  }

  static FactorisationResult solveCompleteBracket(String fullStr, String outStr, String inStr) {
    try {
      if (fullStr.trim().isEmpty) throw const FormatException("Full expression is required.");

      List<AlgTerm> fullTerms = _splitPolynomial(fullStr);
      String fullLatex = fullTerms.asMap().entries.map((e) => e.value.toLaTeX(isFirst: e.key == 0)).join(' ');

      List<FactorisationStep> steps = [];
      List<String> workings = [];

      if (inStr.trim().isEmpty && outStr.trim().isNotEmpty) {

        AlgTerm outside = _parseTerm(outStr)!;
        String outLatex = outside.toLaTeX(isFirst: true);

        workings.add("$fullLatex = $outLatex(\\quad ? \\quad)");
        steps.add(FactorisationStep(
            title: "Step 1: Understand the Missing Part",
            description: "We are given the Full Expression and the Outside Factor (HCF). We need to find the contents of the missing Inside Bracket.",
            mathLaTeX: "\\text{Full Exp.} = \\text{Outside} \\times \\text{Inside}"
        ));

        List<AlgTerm> insideTerms = [];
        List<String> divFractions = [];
        List<String> divisionBreakdown = [];
        for (var t in fullTerms) {
          var result = _divideTerms(t, outside);
          insideTerms.add(result);
          divFractions.add("\\frac{${t.toLaTeX(isFirst: true)}}{$outLatex}");
          divisionBreakdown.add("\\frac{${t.toLaTeX(isFirst: true)}}{$outLatex} = ${result.toLaTeX(isFirst: true)}");
        }

        String divStepStr = divFractions.join(' + ').replaceAll('+ -', '- ');
        workings.add("\\text{Inside} = $divStepStr");

        steps.add(FactorisationStep(
            title: "Step 2: The Division Rule",
            description: "Because multiplication and division are opposites, if `Full = Outside × Inside`, then `Inside = Full ÷ Outside`. We divide every term in the full expression by the outside factor.",
            mathLaTeX: "\\text{Inside} = $divStepStr"
        ));

        String insideStr = insideTerms.asMap().entries.map((e) => e.value.toLaTeX(isFirst: e.key == 0)).join(' ');
        workings.add("\\text{Inside} = $insideStr");

        steps.add(FactorisationStep(
            title: "Step 3: Perform the Division",
            description: "Perform the division term-by-term. The letters and numbers will cancel out, revealing the missing contents of the bracket.",
            mathLaTeX: divisionBreakdown.join('\\quad ; \\quad')
        ));

        steps.add(FactorisationStep(
            title: "Step 4: Final Statement",
            description: "We have successfully completed the binomial box!",
            mathLaTeX: "$fullLatex = $outLatex($insideStr)"
        ));

        return FactorisationResult(
            mode: "Complete Bracket",
            finalAnswers: {"Inside Bracket contents": insideStr, "Full Statement": "$fullLatex = $outLatex($insideStr)"},
            workingsLaTeX: workings,
            steps: steps
        );

      } else if (outStr.trim().isEmpty && inStr.trim().isNotEmpty) {

        List<AlgTerm> insideTerms = _splitPolynomial(inStr);
        String inLatex = insideTerms.asMap().entries.map((e) => e.value.toLaTeX(isFirst: e.key == 0)).join(' ');

        workings.add("$fullLatex = \\text{Outside} ($inLatex)");
        steps.add(FactorisationStep(
            title: "Step 1: Understand the Missing Part",
            description: "We are given the Full Expression and the Inside Bracket. We need to find the missing Outside Factor.",
            mathLaTeX: "\\text{Full Exp.} = \\text{Outside} \\times \\text{Inside}"
        ));

        AlgTerm outside = _divideTerms(fullTerms[0], insideTerms[0]);
        String outLatex = outside.toLaTeX(isFirst: true);

        String divMath = "\\frac{${fullTerms[0].toLaTeX(isFirst: true)}}{${insideTerms[0].toLaTeX(isFirst: true)}} = $outLatex";
        workings.add("\\text{Outside} = $divMath");

        steps.add(FactorisationStep(
            title: "Step 2: Divide to Find the Outside",
            description: "Because `Full = Outside × Inside`, we can easily find the Outside factor by dividing. We don't even need to divide every term; dividing the FIRST term of the full expression by the FIRST term of the inside bracket is enough!",
            mathLaTeX: divMath
        ));

        steps.add(FactorisationStep(
            title: "Step 3: Final Statement",
            description: "We have successfully completed the binomial box!",
            mathLaTeX: "$fullLatex = $outLatex($inLatex)"
        ));

        return FactorisationResult(
            mode: "Complete Bracket",
            finalAnswers: {"Outside Factor": outLatex, "Full Statement": "$fullLatex = $outLatex($inLatex)"},
            workingsLaTeX: workings,
            steps: steps
        );
      } else {
        throw const FormatException("Leave exactly one field (Inside or Outside) blank.");
      }
    } catch (e) {
      return FactorisationResult(mode: "Complete Bracket", finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Invalid input format.");
    }
  }
}