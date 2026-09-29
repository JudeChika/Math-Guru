import 'dart:math' as math;
import 'algebraic_fractions_models.dart';

class AlgTerm {
  final double coeff;
  final Map<String, int> vars;
  final String rawString;

  AlgTerm(this.coeff, this.vars, this.rawString);

  bool get isPureNumber => vars.isEmpty;

  String get sig {
    var keys = vars.keys.toList()..sort();
    return keys.map((k) => '$k${vars[k]}').join();
  }

  AlgTerm multiply(AlgTerm other) {
    double newCoeff = coeff * other.coeff;
    Map<String, int> newVars = Map.from(vars);
    other.vars.forEach((k, v) {
      newVars[k] = (newVars[k] ?? 0) + v;
    });
    newVars.removeWhere((k, v) => v == 0);
    return AlgTerm(newCoeff, newVars, "");
  }

  AlgTerm divide(AlgTerm other) {
    double newCoeff = coeff / other.coeff;
    Map<String, int> newVars = Map.from(vars);
    other.vars.forEach((k, v) {
      newVars[k] = (newVars[k] ?? 0) - v;
    });
    newVars.removeWhere((k, v) => v == 0);
    return AlgTerm(newCoeff, newVars, "");
  }

  String toLaTeX({bool isFirst = false, bool forceSign = false}) {
    if (coeff == 0) return "0";
    String sign = "";
    if (coeff < 0) {
      sign = "-";
    } else if (forceSign && !isFirst) {
      sign = "+";
    } else if (!isFirst && coeff > 0) {
      sign = "+";
    }

    double absC = coeff.abs();
    String cStr = (absC == absC.round()) ? absC.round().toString() : absC.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');

    List<String> vStrs = [];
    var sortedKeys = vars.keys.toList()..sort();
    for (var k in sortedKeys) {
      int p = vars[k]!;
      if (p == 1) {
        vStrs.add(k);
      } else if (p != 0) vStrs.add("$k^{$p}");
    }
    String vStr = vStrs.join('');

    if (cStr == "1" && vStr.isNotEmpty) cStr = "";

    return "$sign $cStr$vStr".trim();
  }
}

class Polynomial {
  final List<AlgTerm> terms;
  Polynomial(this.terms);

  String toLaTeX() {
    if (terms.isEmpty) return "0";
    return terms.asMap().entries.map((e) => e.value.toLaTeX(isFirst: e.key == 0)).join(' ');
  }
}

class AlgebraicFractionsLogic {

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

  static int _lcmNum(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return (a * b).abs() ~/ _gcd(a, b);
  }

  static String _resolveSigns(String s) {
    int safeguard = 0;
    bool changed = true;
    while (changed && safeguard < 50) {
      changed = false;
      String next = s.replaceAll('--', '+').replaceAll('++', '+').replaceAll('+-', '-').replaceAll('-+', '-');
      next = next.replaceAll('+ -', '- ').replaceAll('- -', '+ ');
      if (next != s) {
        s = next;
        changed = true;
      }
      safeguard++;
    }
    return s;
  }

  static AlgTerm? _parseSingleTerm(String input) {
    String s = input.trim();
    if (s.isEmpty) return null;

    double coeff = 1.0;
    Map<String, int> vars = {};

    // Safely extract the coefficient (including decimals) and the variables
    var match = RegExp(r'^([-+]?\d*\.?\d*)(.*)$').firstMatch(s);
    if (match != null) {
      String cStr = match.group(1) ?? '';
      String vStr = match.group(2) ?? '';

      // Handle standalone signs or blank coefficients
      if (cStr == '-' || cStr == '+-') {
        coeff = -1.0;
      } else if (cStr == '+' || cStr == '') coeff = 1.0;
      else coeff = double.tryParse(cStr) ?? 1.0;

      // Extract variables and their powers
      var vMatches = RegExp(r'([a-zA-Z])(?:\^([-+]?\d+))?').allMatches(vStr);
      for (var m in vMatches) {
        String v = m.group(1)!;
        int p = m.group(2) != null ? int.parse(m.group(2)!) : 1;
        vars[v] = (vars[v] ?? 0) + p;
      }
    }
    return AlgTerm(coeff, vars, input);
  }

  static Polynomial _parsePolynomial(String input) {
    String s = input.replaceAll(' ', '');

    // Safely tag all minus signs (except those inside powers like x^-2) for chunking
    s = s.replaceAllMapped(RegExp(r'(?<!\^)-'), (match) => '+-');
    if (s.startsWith('+-')) s = '-${s.substring(2)}';

    List<String> parts = s.split('+').where((e) => e.isNotEmpty).toList();
    List<AlgTerm> terms = [];

    for (var p in parts) {
      var t = _parseSingleTerm(p);
      if (t != null) terms.add(t);
    }

    // Remove blank 0 terms unless it's the absolute only term
    terms.removeWhere((t) => t.coeff == 0 && t.vars.isEmpty && terms.length > 1);
    if (terms.isEmpty) terms.add(AlgTerm(0, {}, "0"));

    return Polynomial(terms);
  }

  static AlgFractionsResult solveEquivalent(String n1Str, String d1Str, String n2Str, String d2Str) {
    try {
      int emptyCount = 0;
      if (n1Str.trim().isEmpty) emptyCount++;
      if (d1Str.trim().isEmpty) emptyCount++;
      if (n2Str.trim().isEmpty) emptyCount++;
      if (d2Str.trim().isEmpty) emptyCount++;

      if (emptyCount != 1) throw const FormatException("Leave exactly one box blank.");

      AlgTerm? n1 = _parseSingleTerm(n1Str);
      AlgTerm? d1 = _parseSingleTerm(d1Str);
      AlgTerm? n2 = _parseSingleTerm(n2Str);
      AlgTerm? d2 = _parseSingleTerm(d2Str);

      List<AlgFractionsStep> steps = [];
      List<String> workings = [];

      String pN1 = n1 == null ? "\\Box" : n1.toLaTeX(isFirst: true);
      String pD1 = d1 == null ? "\\Box" : d1.toLaTeX(isFirst: true);
      String pN2 = n2 == null ? "\\Box" : n2.toLaTeX(isFirst: true);
      String pD2 = d2 == null ? "\\Box" : d2.toLaTeX(isFirst: true);

      String originalLatex = "\\frac{$pN1}{$pD1} = \\frac{$pN2}{$pD2}";
      workings.add(originalLatex);

      steps.add(AlgFractionsStep(
          title: "Step 1: The Problem",
          description: "Equivalent fractions are like identical twins wearing different clothes; they look different but have the exact same value! To find the missing piece, we must first look at the complete pair (either both numerators or both denominators).",
          mathLaTeX: originalLatex
      ));

      AlgTerm missingVal;

      if (n1 == null || n2 == null) {
        // Compare denominators
        AlgTerm knownD1 = d1!;
        AlgTerm knownD2 = d2!;

        bool isMultiplication = knownD2.coeff.abs() >= knownD1.coeff.abs();
        AlgTerm multiplier = isMultiplication ? knownD2.divide(knownD1) : knownD1.divide(knownD2);

        String multStr = multiplier.toLaTeX(isFirst: true);
        String compDesc = isMultiplication
            ? "Look at the denominators. We see that multiplying the smaller denominator by $multStr gives the larger denominator."
            : "Look at the denominators. We see that dividing the larger denominator by $multStr gives the smaller denominator.";

        String compMath = isMultiplication
            ? "${knownD1.toLaTeX(isFirst: true)} \\times $multStr = ${knownD2.toLaTeX(isFirst: true)}"
            : "${knownD1.toLaTeX(isFirst: true)} \\div $multStr = ${knownD2.toLaTeX(isFirst: true)}";

        workings.add("\\text{Relationship: } ${isMultiplication ? '\\times' : '\\div'} $multStr");

        steps.add(AlgFractionsStep(
            title: "Step 2: Find the Relationship",
            description: compDesc,
            mathLaTeX: compMath
        ));

        if (n1 == null) { // We are missing the left numerator
          missingVal = isMultiplication ? n2!.divide(multiplier) : n2!.multiply(multiplier);
          String opStr = isMultiplication ? "\\div" : "\\times";

          workings.add("\\text{Numerator} = ${n2.toLaTeX(isFirst: true)} $opStr $multStr = ${missingVal.toLaTeX(isFirst: true)}");
          steps.add(AlgFractionsStep(
              title: "Step 3: Apply the Rule to the Numerator",
              description: "To find the missing numerator on the left side, we must do the REVERSE operation to the right numerator.",
              mathLaTeX: "${n2.toLaTeX(isFirst: true)} $opStr $multStr = ${missingVal.toLaTeX(isFirst: true)}"
          ));
        } else { // We are missing the right numerator
          missingVal = isMultiplication ? n1.multiply(multiplier) : n1.divide(multiplier);
          String opStr = isMultiplication ? "\\times" : "\\div";

          workings.add("\\text{Numerator} = ${n1.toLaTeX(isFirst: true)} $opStr $multStr = ${missingVal.toLaTeX(isFirst: true)}");
          steps.add(AlgFractionsStep(
              title: "Step 3: Apply the Rule to the Numerator",
              description: "Whatever we do to the bottom, we MUST do to the top! Because the denominator was ${isMultiplication ? 'multiplied' : 'divided'} by $multStr, we must also ${isMultiplication ? 'multiply' : 'divide'} the numerator by $multStr.",
              mathLaTeX: "${n1.toLaTeX(isFirst: true)} $opStr $multStr = ${missingVal.toLaTeX(isFirst: true)}"
          ));
        }
      } else {
        // Compare numerators
        AlgTerm knownN1 = n1;
        AlgTerm knownN2 = n2;

        bool isMultiplication = knownN2.coeff.abs() >= knownN1.coeff.abs();
        AlgTerm multiplier = isMultiplication ? knownN2.divide(knownN1) : knownN1.divide(knownN2);

        String multStr = multiplier.toLaTeX(isFirst: true);
        String compDesc = isMultiplication
            ? "Look at the numerators. We see that multiplying the smaller numerator by $multStr gives the larger numerator."
            : "Look at the numerators. We see that dividing the larger numerator by $multStr gives the smaller numerator.";

        String compMath = isMultiplication
            ? "${knownN1.toLaTeX(isFirst: true)} \\times $multStr = ${knownN2.toLaTeX(isFirst: true)}"
            : "${knownN1.toLaTeX(isFirst: true)} \\div $multStr = ${knownN2.toLaTeX(isFirst: true)}";

        workings.add("\\text{Relationship: } ${isMultiplication ? '\\times' : '\\div'} $multStr");

        steps.add(AlgFractionsStep(
            title: "Step 2: Find the Relationship",
            description: compDesc,
            mathLaTeX: compMath
        ));

        if (d1 == null) { // We are missing the left denominator
          missingVal = isMultiplication ? d2!.divide(multiplier) : d2!.multiply(multiplier);
          String opStr = isMultiplication ? "\\div" : "\\times";

          workings.add("\\text{Denominator} = ${d2.toLaTeX(isFirst: true)} $opStr $multStr = ${missingVal.toLaTeX(isFirst: true)}");
          steps.add(AlgFractionsStep(
              title: "Step 3: Apply the Rule to the Denominator",
              description: "To find the missing denominator on the left side, we must do the REVERSE operation to the right denominator.",
              mathLaTeX: "${d2.toLaTeX(isFirst: true)} $opStr $multStr = ${missingVal.toLaTeX(isFirst: true)}"
          ));
        } else { // We are missing the right denominator
          missingVal = isMultiplication ? d1.multiply(multiplier) : d1.divide(multiplier);
          String opStr = isMultiplication ? "\\times" : "\\div";

          workings.add("\\text{Denominator} = ${d1.toLaTeX(isFirst: true)} $opStr $multStr = ${missingVal.toLaTeX(isFirst: true)}");
          steps.add(AlgFractionsStep(
              title: "Step 3: Apply the Rule to the Denominator",
              description: "Whatever we do to the top, we MUST do to the bottom! Because the numerator was ${isMultiplication ? 'multiplied' : 'divided'} by $multStr, we must also ${isMultiplication ? 'multiply' : 'divide'} the denominator by $multStr.",
              mathLaTeX: "${d1.toLaTeX(isFirst: true)} $opStr $multStr = ${missingVal.toLaTeX(isFirst: true)}"
          ));
        }
      }

      return AlgFractionsResult(
          mode: "Equivalent",
          finalAnswers: {"Missing Value": missingVal.toLaTeX(isFirst: true)},
          workingsLaTeX: workings,
          steps: steps
      );

    } catch (e) {
      return AlgFractionsResult(mode: "Equivalent", finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Invalid terms. Please check your inputs.");
    }
  }

  static AlgFractionsResult solveAddSub(List<AlgFractionItem> fractions) {
    try {
      if (fractions.length < 2) throw const FormatException("Add at least two fractions.");

      List<AlgFractionsStep> steps = [];
      List<String> workings = [];

      // Build Original Problem string
      List<String> probParts = [];
      for (int i = 0; i < fractions.length; i++) {
        var f = fractions[i];
        if (f.numStr.trim().isEmpty || f.denStr.trim().isEmpty) throw const FormatException();
        String fracLatex = "\\frac{${_parsePolynomial(f.numStr).toLaTeX()}}{${_parseSingleTerm(f.denStr)!.toLaTeX(isFirst: true)}}";
        if (i == 0) {
          if (f.sign == '-') {
            probParts.add("- $fracLatex");
          } else {
            probParts.add(fracLatex);
          }
        } else {
          probParts.add("${f.sign} $fracLatex");
        }
      }
      String problemLatex = _resolveSigns(probParts.join(' '));
      workings.add(problemLatex);

      steps.add(AlgFractionsStep(
          title: "Step 1: The Problem",
          description: "We need to combine these algebraic fractions. Just like with normal numbers, we CANNOT add or subtract fractions until their denominators are exactly the same.",
          mathLaTeX: problemLatex
      ));

      // 1. Find LCM of Denominators
      int lcmCoeff = 1;
      Map<String, int> lcmVars = {};
      List<AlgTerm> denominators = [];

      for (var f in fractions) {
        AlgTerm den = _parseSingleTerm(f.denStr)!;
        denominators.add(den);

        int dCoeff = den.coeff.abs().round();
        if (dCoeff == 0) dCoeff = 1;
        lcmCoeff = _lcmNum(lcmCoeff, dCoeff);

        den.vars.forEach((k, v) {
          lcmVars[k] = math.max(lcmVars[k] ?? 0, v);
        });
      }

      AlgTerm lcmTerm = AlgTerm(lcmCoeff.toDouble(), lcmVars, "");
      String lcmLatex = lcmTerm.toLaTeX(isFirst: true);

      workings.add("\\text{LCM of denominators} = $lcmLatex");
      steps.add(AlgFractionsStep(
          title: "Step 2: Find the Common Denominator",
          description: "We find the Lowest Common Multiple (LCM) of the denominators. This will be our new shared denominator. To do this, we find the LCM of the numbers, and take the highest power of any letters.",
          mathLaTeX: "\\text{LCM} = $lcmLatex"
      ));

      // 2. Equivalent Fractions (Inserting Brackets)
      List<String> numExpParts = [];
      List<Polynomial> numerators = [];
      List<AlgTerm> multipliers = [];

      for (int i = 0; i < fractions.length; i++) {
        var f = fractions[i];
        AlgTerm den = denominators[i];
        Polynomial num = _parsePolynomial(f.numStr);
        numerators.add(num);

        AlgTerm multiplier = lcmTerm.divide(den);
        multipliers.add(multiplier);

        String sign = f.sign;
        if (i == 0 && sign == '+') sign = '';

        String multStr = multiplier.toLaTeX(isFirst: true);
        if (multStr == "1") multStr = "";

        numExpParts.add("$sign $multStr(${num.toLaTeX()})");
      }

      String bracketLatex = "\\frac{${numExpParts.join(' ')}}{$lcmLatex}";
      bracketLatex = _resolveSigns(bracketLatex);

      workings.add("= $bracketLatex");
      steps.add(AlgFractionsStep(
          title: "Step 3: Create Equivalent Fractions (Use Brackets!)",
          description: "Divide the new LCM by each old denominator to find the multiplier. The most important rule in algebra is that a fraction line acts as a HIDDEN BRACKET for its numerator! We MUST wrap the numerators in brackets to prevent sign errors.",
          mathLaTeX: bracketLatex
      ));

      // 3. Remove Brackets
      List<AlgTerm> expandedTerms = [];
      List<String> expandedParts = [];

      for (int i = 0; i < fractions.length; i++) {
        String sign = fractions[i].sign;
        AlgTerm multiplier = multipliers[i];
        if (sign == '-') {
          multiplier = AlgTerm(-multiplier.coeff, multiplier.vars, "");
        }

        Polynomial num = numerators[i];
        for (var term in num.terms) {
          AlgTerm result = multiplier.multiply(term);
          expandedTerms.add(result);
        }
      }

      String expandedLatexTop = expandedTerms.asMap().entries.map((e) => e.value.toLaTeX(isFirst: e.key == 0)).join(' ');
      expandedLatexTop = _resolveSigns(expandedLatexTop);
      String expandedFraction = "\\frac{$expandedLatexTop}{$lcmLatex}";

      workings.add("= $expandedFraction");
      steps.add(AlgFractionsStep(
          title: "Step 4: Remove the Brackets",
          description: "Multiply the outside factor by every single term inside the bracket. Be extremely careful when a negative sign is outside a bracket—it flips the signs of everything inside!",
          mathLaTeX: expandedFraction
      ));

      // 4. Collect Like Terms
      Map<String, double> grouped = {};
      Map<String, Map<String, int>> signatures = {};
      for (var t in expandedTerms) {
        String sig = t.sig;
        grouped[sig] = (grouped[sig] ?? 0) + t.coeff;
        signatures[sig] = t.vars;
      }

      List<AlgTerm> collectedTerms = [];
      grouped.forEach((sig, coeff) {
        if (coeff != 0 || grouped.length == 1) {
          collectedTerms.add(AlgTerm(coeff, signatures[sig]!, ""));
        }
      });

      collectedTerms.sort((a, b) {
        if (a.vars.isEmpty && b.vars.isNotEmpty) return 1;
        if (b.vars.isEmpty && a.vars.isNotEmpty) return -1;
        return b.sig.compareTo(a.sig);
      });

      // Aesthetic Fix: Ensure positive terms come first to avoid leading negatives
      if (collectedTerms.isNotEmpty && collectedTerms.first.coeff < 0) {
        int firstPosIdx = collectedTerms.indexWhere((t) => t.coeff > 0);
        if (firstPosIdx != -1) {
          var posTerm = collectedTerms.removeAt(firstPosIdx);
          collectedTerms.insert(0, posTerm);
        }
      }

      String collectedTop = collectedTerms.isEmpty ? "0" : collectedTerms.asMap().entries.map((e) => e.value.toLaTeX(isFirst: e.key == 0)).join(' ');
      collectedTop = _resolveSigns(collectedTop);
      String collectedFraction = "\\frac{$collectedTop}{$lcmLatex}";

      if (collectedTop != expandedLatexTop) {
        workings.add("= $collectedFraction");
        steps.add(AlgFractionsStep(
            title: "Step 5: Group and Collect Like Terms",
            description: "Rearrange the top of the fraction so identical letters and plain numbers sit next to each other. Then, add or subtract them to simplify.",
            mathLaTeX: collectedFraction
        ));
      }

      // 5. Final Factorisation and Simplification
      String finalAns = collectedFraction;
      if (collectedTerms.isNotEmpty && collectedTop != "0") {
        int numHCF = collectedTerms[0].coeff.abs().round();
        for (int i = 1; i < collectedTerms.length; i++) {
          numHCF = _gcd(numHCF, collectedTerms[i].coeff.abs().round());
        }

        if (collectedTerms[0].coeff < 0) numHCF = -numHCF;

        int finalGCD = _gcd(numHCF, lcmCoeff);

        if (finalGCD > 1 || finalGCD < -1) {
          int sHCF = numHCF ~/ finalGCD;
          int sLCM = lcmCoeff ~/ finalGCD;

          String factTop = "";
          if (sHCF != 1 && sHCF != -1) {
            factTop += "$sHCF";
          } else if (sHCF == -1) factTop += "-";

          List<String> insideParts = [];
          for (var t in collectedTerms) {
            AlgTerm divided = AlgTerm(t.coeff / numHCF, t.vars, "");
            insideParts.add(divided.toLaTeX(isFirst: insideParts.isEmpty));
          }
          factTop += "(${_resolveSigns(insideParts.join(' '))})";

          String factDenom = sLCM == 1 ? "" : AlgTerm(sLCM.toDouble(), lcmVars, "").toLaTeX(isFirst: true);

          String fullySimplified = factDenom.isEmpty ? factTop : "\\frac{$factTop}{$factDenom}";

          workings.add("= \\frac{$numHCF(${_resolveSigns(insideParts.join(' '))})}{$lcmLatex}");
          workings.add("= $fullySimplified");

          steps.add(AlgFractionsStep(
              title: "Step 6: Final Factorisation & Simplification",
              description: "We check if the final numerator can be factorised. It shares a common factor with the denominator! We divide the top and bottom by ${finalGCD.abs()} to reduce the fraction to its absolute lowest terms.",
              mathLaTeX: fullySimplified
          ));
          finalAns = fullySimplified;
        } else {
          steps.add(AlgFractionsStep(
              title: "Step 6: Check Simplification",
              description: "The numerator cannot be factorised to share a common factor with the denominator, so our fraction is already in its simplest form!",
              mathLaTeX: finalAns
          ));
        }
      } else if (collectedTop == "0") {
        finalAns = "0";
        workings.add("= 0");
        steps.add(AlgFractionsStep(
            title: "Step 6: Simplify",
            description: "Zero divided by anything is exactly zero.",
            mathLaTeX: "0"
        ));
      }

      return AlgFractionsResult(
          mode: "AddSub",
          finalAnswers: {"Simplified Fraction": finalAns},
          workingsLaTeX: workings,
          steps: steps
      );

    } catch (e) {
      return AlgFractionsResult(mode: "AddSub", finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Ensure all numerators and denominators are valid algebraic terms.");
    }
  }
}