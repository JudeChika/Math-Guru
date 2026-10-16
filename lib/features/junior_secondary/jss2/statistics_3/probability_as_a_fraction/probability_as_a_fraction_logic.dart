import 'dart:math' as math;
import 'probability_as_a_fraction_models.dart';

class ProbabilityAsAFractionLogic {
  /// Calculates the Greatest Common Divisor (Highest Common Factor)
  static int _gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      int t = b;
      b = a % b;
      a = t;
    }
    return a == 0 ? 1 : a;
  }

  /// Formats decimals neatly, dropping trailing zeros
  static String _fmt(double v, {int maxDecimals = 4}) {
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// Formats a positive number to N significant figures (matches Example 5: 2 s.f. & 1 s.f.)
  static String _fmtSF(double v, int sf) {
    if (v == 0 || v.abs() < 1e-12) return "0";
    int d = (math.log(v.abs()) / math.ln10).floor();
    int power = sf - 1 - d;
    double scale = math.pow(10, power).toDouble();
    double rounded = (v * scale).roundToDouble() / scale;
    if (power <= 0) {
      return rounded.round().toString();
    }
    // If the original value is already exact at fewer decimal places, avoid padding trailing zeros
    if ((v - rounded).abs() < 1e-9) {
      return _fmt(rounded, maxDecimals: power);
    }
    return rounded.toStringAsFixed(power);
  }

  /// Rounds an integer to the nearest 10, 100, or 1000 (matches Ex. 21c #15)
  static int _roundToNearest(int val, int base) {
    if (base <= 1) return val;
    return ((val / base).round()) * base;
  }

  /// Sanitizes user labels so they never break LaTeX \text{...} blocks
  static String _cleanTex(String s) {
    return s
        .replaceAll('\\', '')
        .replaceAll('{', '(')
        .replaceAll('}', ')')
        .replaceAll('\$', '')
        .replaceAll('%', '\\%')
        .replaceAll('&', ' and ')
        .replaceAll('_', ' ')
        .trim();
  }

  /// Parses a count string that may be a single integer ("18")
  /// or a multi-column sum ("51 + 56 + 57 + 65 + 70")
  static Map<String, dynamic> _parseCountExpression(String expr) {
    String clean = expr.trim();
    if (clean.isEmpty) {
      throw const FormatException("Count field cannot be empty.");
    }

    List<String> parts = clean
        .split(RegExp(r'[+,;\s]+'))
        .where((p) => p.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      throw const FormatException("Enter valid whole numbers.");
    }

    List<int> nums = [];
    int sum = 0;
    for (String p in parts) {
      int? val = int.tryParse(p.trim().replaceAll(',', ''));
      if (val == null || val < 0) {
        throw FormatException("'$p' is not a valid non-negative whole number.");
      }
      nums.add(val);
      sum += val;
    }

    return {
      'nums': nums,
      'sum': sum,
      'breakdown': nums.length > 1 ? nums.join(' + ') : null,
    };
  }

  /// Parses a probability input that can be a fraction ("9/12"), decimal ("0.8"), or percentage ("25%")
  static Map<String, dynamic> _parseProbabilityValue(String input) {
    String s = input.trim();
    if (s.isEmpty) {
      throw const FormatException("Enter a probability value (e.g. 0.8 or 9/12).");
    }

    if (s.endsWith('%')) {
      double? pct = double.tryParse(s.replaceAll('%', '').trim());
      if (pct == null || pct < 0 || pct > 100) {
        throw const FormatException("Percentage probability must be between 0% and 100%.");
      }
      int num = (pct * 100).round();
      int den = 10000;
      int g = _gcd(num, den);
      return {
        'type': 'percentage',
        'decimal': pct / 100.0,
        'num': num ~/ g,
        'den': den ~/ g,
        'rawNum': pct,
        'rawDen': 100,
      };
    } else if (s.contains('/')) {
      List<String> parts = s.split('/');
      if (parts.length != 2) {
        throw const FormatException("Invalid fraction format. Use a/b (e.g. 9/12).");
      }
      int? n = int.tryParse(parts[0].trim());
      int? d = int.tryParse(parts[1].trim());
      if (n == null || d == null || d <= 0 || n < 0 || n > d) {
        throw const FormatException(
            "Fraction probability must be between 0 and 1 (numerator <= denominator).");
      }
      int g = _gcd(n, d);
      return {
        'type': 'fraction',
        'decimal': n / d,
        'num': n ~/ g,
        'den': d ~/ g,
        'rawNum': n,
        'rawDen': d,
      };
    } else {
      double? dec = double.tryParse(s);
      if (dec == null || dec < 0 || dec > 1) {
        throw const FormatException("Probability must be between 0 and 1 (e.g. 0.8 or 0.05).");
      }
      String decClean = _fmt(dec, maxDecimals: 4);
      int decPlaces = decClean.contains('.') ? decClean.split('.')[1].length : 0;
      int den = math.pow(10, decPlaces).round();
      int num = (dec * den).round();
      int g = _gcd(num, den);
      return {
        'type': 'decimal',
        'decimal': dec,
        'num': num ~/ g,
        'den': den ~/ g,
        'rawNum': num,
        'rawDen': den,
      };
    }
  }

  // ===========================================================================
  // MODE A: MULTI-CATEGORY BAG / BOX / SURVEY / STATISTICAL TABLE SOLVER
  // ===========================================================================
  static ProbFractionResult solveMultiCategory({
    required List<CategoryRowInput> rows,
    required Set<int> selectedIndices,
    required int queryType, // 0: Selected (Either/Or), 1: Complement (Neither/Nor), 2: Unlisted (0)
    required String unlistedName,
    required String knownTotalStr,
    required String preRoundRule, // 'none', '10', '100', '1000'
    required String futureTrialsStr,
  }) {
    try {
      if (rows.isEmpty) {
        throw const FormatException("Add at least one category row.");
      }
      if (queryType != 2 && selectedIndices.isEmpty) {
        throw const FormatException("Select at least one category chip.");
      }

      int roundBase = 1;
      if (preRoundRule == '10') roundBase = 10;
      if (preRoundRule == '100') roundBase = 100;
      if (preRoundRule == '1000') roundBase = 1000;

      List<ProbFractionStep> steps = [];
      List<String> workings = [];

      // Step 1: Foundational Formula
      workings.add("\\text{\\textbf{Probability as a Fraction Formula}}");
      workings.add(
          "\\text{Probability} = \\frac{\\text{Number of required outcomes}}{\\text{Number of possible outcomes}}");
      workings.add("");

      steps.add(ProbFractionStep(
        title: "Step 1: State the Probability Formula",
        description:
        "Probability measures the likelihood of a required outcome happening as a fraction between 0 (impossible) and 1 (certain).",
        mathLaTeX:
        "\\text{Probability} = \\frac{\\text{Number of required outcomes}}{\\text{Number of possible outcomes}}",
      ));

      List<ParsedCategoryItem> parsedCategories = [];
      bool hasMultiSums = false;
      int sumOfListed = 0;
      List<String> roundingLines = [];
      List<String> sumLines = [];

      for (int i = 0; i < rows.length; i++) {
        String rName = rows[i].name.trim().isEmpty
            ? "Category ${i + 1}"
            : rows[i].name.trim();
        var parsed = _parseCountExpression(rows[i].countExpression);
        int rawSum = parsed['sum'];
        String? breakdown = parsed['breakdown'];
        if (breakdown != null) hasMultiSums = true;

        int effectiveCount =
        roundBase > 1 ? _roundToNearest(rawSum, roundBase) : rawSum;

        if (roundBase > 1) {
          roundingLines.add(
              "\\text{${_cleanTex(rName)}}: $rawSum \\approx $effectiveCount");
        }
        if (breakdown != null) {
          sumLines.add(
              "\\text{${_cleanTex(rName)}} = $breakdown = $rawSum");
        }

        bool isSelected = selectedIndices.contains(i);
        bool isTarget = false;
        if (queryType == 0) {
          isTarget = isSelected;
        } else if (queryType == 1) {
          isTarget = !isSelected;
        }

        sumOfListed += effectiveCount;
        parsedCategories.add(ParsedCategoryItem(
          name: rName,
          rawCount: rawSum,
          effectiveCount: effectiveCount,
          isTarget: isTarget,
          sumBreakdown: breakdown,
        ));
      }

      if (hasMultiSums) {
        workings.add("\\text{\\textbf{Add Up Each Category:}}");
        for (String line in sumLines) {
          workings.add(line);
        }
        workings.add("");

        steps.add(ProbFractionStep(
          title: "Step ${steps.length + 1}: Sum the Multi-Part Category Counts",
          description:
          "Add the individual numbers for each category row before finding the grand total.",
          mathLaTeX: sumLines.join(" \\quad ; \\quad "),
        ));
      }

      if (roundBase > 1) {
        workings.add(
            "\\text{\\textbf{Round Each Number to the Nearest $roundBase:}}");
        for (String rLine in roundingLines) {
          workings.add(rLine);
        }
        workings.add("");

        steps.add(ProbFractionStep(
          title:
          "Step ${steps.length + 1}: Round Counts to the Nearest $roundBase",
          description:
          "As required by the question, we first round each category's number to the nearest $roundBase before calculating the total and probability.",
          mathLaTeX: roundingLines.join(" \\quad ; \\quad "),
        ));
      }

      // Check Optional Known Grand Total (for "The Rest" problems like Ex. 21c #5, #13, #20)
      int totalOutcomes = sumOfListed;
      String cleanKnownTotal = knownTotalStr.trim();
      if (cleanKnownTotal.isNotEmpty) {
        int? parsedKnownTotal =
        int.tryParse(cleanKnownTotal.replaceAll(RegExp(r'[^\d]'), ''));
        if (parsedKnownTotal == null || parsedKnownTotal <= 0) {
          throw const FormatException(
              "Known Grand Total must be a positive whole number.");
        }
        int effectiveKnownTotal = roundBase > 1
            ? _roundToNearest(parsedKnownTotal, roundBase)
            : parsedKnownTotal;

        if (effectiveKnownTotal < sumOfListed) {
          throw FormatException(
              "Known Grand Total ($effectiveKnownTotal) cannot be less than the sum of the listed categories ($sumOfListed).");
        } else if (effectiveKnownTotal > sumOfListed) {
          int remainder = effectiveKnownTotal - sumOfListed;
          bool remIsTarget = (queryType == 1); // Included in "Neither/Nor" complement!

          parsedCategories.add(ParsedCategoryItem(
            name: "Other / Remainder",
            rawCount: remainder,
            effectiveCount: remainder,
            isTarget: remIsTarget,
            isAutoRemainder: true,
          ));

          String listedSumExpr = parsedCategories
              .where((c) => !c.isAutoRemainder)
              .map((c) => c.effectiveCount.toString())
              .join(' + ');

          workings.add("\\text{\\textbf{Find the Remaining Outcomes (The Rest):}}");
          workings.add(
              "\\text{Listed Outcomes} = $listedSumExpr = $sumOfListed");
          workings.add(
              "\\text{Other / Remainder} = $effectiveKnownTotal - $sumOfListed = $remainder");
          workings.add("");

          steps.add(ProbFractionStep(
            title:
            "Step ${steps.length + 1}: Calculate the Remaining ('Other') Outcomes",
            description:
            "The total number of possible outcomes is given as $effectiveKnownTotal, while the listed categories add up to $sumOfListed. Subtracting $sumOfListed from $effectiveKnownTotal gives $remainder remaining items.",
            mathLaTeX:
            "\\text{Remainder} = $effectiveKnownTotal - ($listedSumExpr) = $remainder",
          ));

          totalOutcomes = effectiveKnownTotal;
        }
      } else {
        // Auto-sum total possible outcomes
        String totalAddExpr = parsedCategories
            .map((c) => c.effectiveCount.toString())
            .join(' + ');
        workings.add("\\text{\\textbf{Total Possible Outcomes:}}");
        if (parsedCategories.length > 1) {
          workings.add("\\text{Total} = $totalAddExpr = $totalOutcomes");
        } else {
          workings.add("\\text{Total} = $totalOutcomes");
        }
        workings.add("");

        steps.add(ProbFractionStep(
          title:
          "Step ${steps.length + 1}: Find the Total Number of Possible Outcomes",
          description:
          "Add the counts of all categories together to find the total number of possible outcomes (the denominator).",
          mathLaTeX: parsedCategories.length > 1
              ? "\\text{Total Outcomes} = $totalAddExpr = $totalOutcomes"
              : "\\text{Total Outcomes} = $totalOutcomes",
        ));
      }

      if (totalOutcomes <= 0) {
        throw const FormatException(
            "Total possible outcomes must be greater than zero.");
      }

      // Determine Favorable Outcomes and Event Label based on queryType
      int favorableOutcomes = 0;
      String eventLabel = "";
      List<String> selectedNames = [];
      int selectedSum = 0;

      for (int i = 0; i < rows.length; i++) {
        if (selectedIndices.contains(i)) {
          selectedNames.add(parsedCategories[i].name);
          selectedSum += parsedCategories[i].effectiveCount;
        }
      }

      if (queryType == 2) {
        // Unlisted / Impossible Event (e.g., Green ball in Example 6e)
        eventLabel =
        unlistedName.trim().isEmpty ? "Unlisted Item" : unlistedName.trim();
        favorableOutcomes = 0;
        String safeUnlisted = _cleanTex(eventLabel);

        workings.add("\\text{\\textbf{Required Outcomes ($safeUnlisted):}}");
        workings.add(
            "\\text{There are } 0 \\text{ outcomes for '$safeUnlisted' out of } $totalOutcomes.");

        steps.add(ProbFractionStep(
          title:
          "Step ${steps.length + 1}: Identify Required Outcomes (Impossible Event)",
          description:
          "There are no '$eventLabel' items in the sample space, so it is impossible to select one. The number of required outcomes is 0.",
          mathLaTeX:
          "\\text{Required Outcomes} = 0 \\implies P(\\text{$safeUnlisted}) = \\frac{0}{$totalOutcomes} = 0",
        ));
      } else if (queryType == 0) {
        // Selected (Single or "Either A or B")
        eventLabel = selectedNames.length > 1
            ? "Either ${selectedNames.join(' or ')}"
            : selectedNames.first;
        favorableOutcomes = selectedSum;
        String safeEvent = _cleanTex(eventLabel);

        List<ParsedCategoryItem> targetItems =
        parsedCategories.where((c) => c.isTarget).toList();
        String favAddExpr =
        targetItems.map((c) => c.effectiveCount.toString()).join(' + ');

        workings.add("\\text{\\textbf{Required Outcomes ($safeEvent):}}");
        if (targetItems.length > 1) {
          workings.add(
              "\\text{Required Outcomes} = $favAddExpr = $favorableOutcomes");
        } else {
          workings.add("\\text{Required Outcomes} = $favorableOutcomes");
        }

        steps.add(ProbFractionStep(
          title:
          "Step ${steps.length + 1}: Identify the Number of Required Outcomes",
          description: targetItems.length > 1
              ? "Since the event is '$eventLabel', we add the counts of the selected categories together."
              : "The number of required outcomes for '$eventLabel' is $favorableOutcomes.",
          mathLaTeX: targetItems.length > 1
              ? "\\text{Required Outcomes} = $favAddExpr = $favorableOutcomes"
              : "\\text{Required Outcomes} = $favorableOutcomes",
        ));
      } else {
        // Complement ("NOT Selected" / "Neither A nor B")
        String baseLabel = selectedNames.length > 1
            ? "Neither ${selectedNames.join(' nor ')}"
            : "NOT ${selectedNames.first}";
        eventLabel = baseLabel;
        favorableOutcomes = totalOutcomes - selectedSum;
        String safeEvent = _cleanTex(eventLabel);

        workings.add(
            "\\text{\\textbf{Method 1 (Subtracting Counts):}}");
        workings.add(
            "\\text{Required Outcomes ($safeEvent)} = $totalOutcomes - $selectedSum = $favorableOutcomes");

        steps.add(ProbFractionStep(
          title:
          "Step ${steps.length + 1}: Find Required Outcomes (Count Subtraction)",
          description:
          "For '$eventLabel', we subtract the count of (${selectedNames.join(' + ')}) = $selectedSum from the total outcomes ($totalOutcomes).",
          mathLaTeX:
          "\\text{Required Outcomes} = $totalOutcomes - $selectedSum = $favorableOutcomes",
        ));
      }

      return _buildSharedFractionResult(
        mode: 'MultiCategory',
        eventName: eventLabel,
        favorable: favorableOutcomes,
        total: totalOutcomes,
        categories: parsedCategories,
        workings: workings,
        steps: steps,
        futureTrialsStr: futureTrialsStr,
        showDualComplement: queryType == 1,
        complementBaseName: selectedNames.join(' or '),
      );
    } catch (e) {
      return ProbFractionResult(
        mode: 'MultiCategory',
        eventName: '',
        favorableCount: 0,
        totalCount: 0,
        simplifiedNum: 0,
        simplifiedDen: 1,
        probabilityDecimal: 0,
        categories: [],
        finalAnswers: {},
        workingsLaTeX: [],
        steps: [],
        valid: false,
        errorMessage: e is FormatException
            ? e.message
            : "Please check your category counts and try again.",
      );
    }
  }

  // ===========================================================================
  // MODE B: DIRECT FRACTION, COMPLEMENT (1 - P) & REVERSE ALGEBRA SOLVER
  // ===========================================================================
  static ProbFractionResult solveDirectAndComplement({
    required int subMode, // 0: Direct n/T, 1: Given P find 1-P, 2: Reverse Solver
    required String eventNameStr,
    // SubMode 0 inputs
    required String favExprStr,
    required String totalExprStr,
    required bool findComplement,
    required String futureTrialsStr,
    // SubMode 1 inputs
    required String givenProbStr,
    // SubMode 2 inputs
    required bool reverseFindTotal, // true: Find Total T = n/P, false: Find Required n = P*T
    required String reverseKnownCountStr,
    required String reverseGivenProbStr,
  }) {
    try {
      String eventLabel =
      eventNameStr.trim().isEmpty ? "Target Event" : eventNameStr.trim();
      String safeEvent = _cleanTex(eventLabel);

      List<ProbFractionStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};

      if (subMode == 0) {
        // ---------------------------------------------------------------------
        // SUB-MODE 0: Standard Fraction & WASSCE Multi-Year Sum Solver
        // ---------------------------------------------------------------------
        var favParsed = _parseCountExpression(favExprStr);
        var totParsed = _parseCountExpression(totalExprStr);

        int rawFav = favParsed['sum'];
        int total = totParsed['sum'];
        String? favBreak = favParsed['breakdown'];
        String? totBreak = totParsed['breakdown'];

        if (total <= 0) {
          throw const FormatException("Total outcomes must be greater than zero.");
        }
        if (rawFav < 0 || rawFav > total) {
          throw FormatException(
              "Required outcomes ($rawFav) must be between 0 and the total outcomes ($total).");
        }

        workings.add("\\text{\\textbf{Probability as a Fraction Formula}}");
        workings.add(
            "\\text{Probability} = \\frac{\\text{Number of required outcomes}}{\\text{Number of possible outcomes}}");
        workings.add("");

        steps.add(ProbFractionStep(
          title: "Step 1: State the Probability Formula",
          description:
          "Start by writing the probability formula comparing required outcomes to total possible outcomes.",
          mathLaTeX:
          "P(\\text{Event}) = \\frac{\\text{Number of required outcomes}}{\\text{Number of possible outcomes}}",
        ));

        if (favBreak != null || totBreak != null) {
          workings.add("\\text{\\textbf{Sum the Given Records:}}");
          List<String> sumMath = [];
          if (favBreak != null) {
            String l1 = "\\text{Required ($safeEvent)} = $favBreak = $rawFav";
            workings.add(l1);
            sumMath.add(l1);
          } else {
            workings.add("\\text{Required ($safeEvent)} = $rawFav");
          }
          if (totBreak != null) {
            String l2 = "\\text{Total Outcomes} = $totBreak = $total";
            workings.add(l2);
            sumMath.add(l2);
          } else {
            workings.add("\\text{Total Outcomes} = $total");
          }
          workings.add("");

          steps.add(ProbFractionStep(
            title: "Step 2: Add Up the Multi-Year / Multi-Group Totals",
            description:
            "Add the individual figures across the columns to find the total number of required outcomes ($rawFav) and total possible outcomes ($total).",
            mathLaTeX: sumMath.join(" \\quad ; \\quad "),
          ));
        }

        int effectiveFav = findComplement ? (total - rawFav) : rawFav;
        String effectiveEventName =
        findComplement ? "NOT ($eventLabel)" : eventLabel;

        if (findComplement) {
          String safeComp = _cleanTex(effectiveEventName);
          workings.add(
              "\\text{\\textbf{Method 1: Subtracting Counts}}");
          workings.add(
              "\\text{Number of ($safeComp)} = $total - $rawFav = $effectiveFav");

          steps.add(ProbFractionStep(
            title:
            "Step ${steps.length + 1}: Find the Complement Count (Method 1)",
            description:
            "Since $rawFav out of $total outcomes are '$eventLabel', the remaining $total - $rawFav = $effectiveFav outcomes are '$effectiveEventName'.",
            mathLaTeX:
            "\\text{Required Outcomes} = $total - $rawFav = $effectiveFav",
          ));
        }

        List<ParsedCategoryItem> cats = [
          ParsedCategoryItem(
            name: effectiveEventName,
            rawCount: effectiveFav,
            effectiveCount: effectiveFav,
            isTarget: true,
          ),
          ParsedCategoryItem(
            name: findComplement ? eventLabel : "NOT ($eventLabel)",
            rawCount: total - effectiveFav,
            effectiveCount: total - effectiveFav,
            isTarget: false,
          ),
        ];

        return _buildSharedFractionResult(
          mode: 'DirectAndComplement',
          eventName: effectiveEventName,
          favorable: effectiveFav,
          total: total,
          categories: cats,
          workings: workings,
          steps: steps,
          futureTrialsStr: futureTrialsStr,
          showDualComplement: findComplement,
          complementBaseName: eventLabel,
          includeSigFigs: true,
        );
      } else if (subMode == 1) {
        // ---------------------------------------------------------------------
        // SUB-MODE 1: Given P = x, Find P(NOT) = 1 - x (Ex. 21c #1a, 1b, 1c)
        // ---------------------------------------------------------------------
        var parsedP = _parseProbabilityValue(givenProbStr);
        double pDec = parsedP['decimal'];
        int pNum = parsedP['num'];
        int pDen = parsedP['den'];

        double compDec = 1.0 - pDec;
        int compNum = pDen - pNum;
        int compDen = pDen;
        int g = _gcd(compNum, compDen);
        int sNum = compNum ~/ g;
        int sDen = compDen ~/ g;

        String compEvent = "NOT ($eventLabel)";
        String safeComp = _cleanTex(compEvent);

        workings.add("\\text{\\textbf{Complementary Probability Rule}}");
        workings.add(
            "\\text{If the probability of an event happening is } x, \\text{ the probability of it NOT happening is } 1 - x.");
        workings.add("");

        steps.add(ProbFractionStep(
          title: "Step 1: State the '1 - x' Complement Rule",
          description:
          "Total probability for certainty is 1. If the probability of '$eventLabel' happening is x, then the probability of it NOT happening is 1 - x.",
          mathLaTeX: "P(\\text{Not happening}) = 1 - x",
        ));

        if (parsedP['type'] == 'fraction') {
          int rN = parsedP['rawNum'];
          int rD = parsedP['rawDen'];
          int diffN = rD - rN;
          String fracAns = sNum == 0
              ? "0"
              : (sNum == sDen ? "1" : "\\frac{$sNum}{$sDen}");

          workings.add("P(\\text{$safeEvent}) = \\frac{$rN}{$rD}");
          workings.add(
              "P(\\text{$safeComp}) = 1 - \\frac{$rN}{$rD} = \\frac{$rD}{$rD} - \\frac{$rN}{$rD} = \\frac{$diffN}{$rD}");
          if (g > 1 && diffN != sNum) {
            workings.add("\\text{Simplify: } \\frac{$diffN}{$rD} = $fracAns");
          }

          steps.add(ProbFractionStep(
            title: "Step 2: Subtract the Fraction from 1",
            description:
            "Rewrite 1 as $rD/$rD so both fractions share the same denominator, then subtract the numerators: $rD - $rN = $diffN.",
            mathLaTeX:
            "P(\\text{$safeComp}) = 1 - \\frac{$rN}{$rD} = \\frac{$diffN}{$rD}${diffN != sNum ? ' = $fracAns' : ''}",
          ));
        } else {
          workings.add("P(\\text{$safeEvent}) = ${_fmt(pDec)}");
          workings.add(
              "P(\\text{$safeComp}) = 1 - ${_fmt(pDec)} = ${_fmt(compDec)}");
          if (sNum > 0 && sNum < sDen) {
            workings.add(
                "\\text{As a Simplified Fraction: } ${_fmt(compDec)} = \\frac{$sNum}{$sDen}");
          }

          steps.add(ProbFractionStep(
            title: "Step 2: Subtract the Probability from 1",
            description:
            "Subtract the given probability (${_fmt(pDec)}) from 1 whole to find the probability of '$compEvent'.",
            mathLaTeX:
            "P(\\text{$safeComp}) = 1 - ${_fmt(pDec)} = ${_fmt(compDec)}",
          ));
        }

        String fracAns = sNum == 0
            ? "0"
            : (sNum == sDen ? "1" : "\\frac{$sNum}{$sDen}");
        answers["P(NOT) Decimal"] = _fmt(compDec);
        answers["P(NOT) Fraction"] = fracAns;
        answers["P(NOT) Percentage"] = "${_fmt(compDec * 100)}\\%";

        List<ParsedCategoryItem> cats = [
          ParsedCategoryItem(
            name: compEvent,
            rawCount: sNum,
            effectiveCount: sNum,
            isTarget: true,
          ),
          ParsedCategoryItem(
            name: eventLabel,
            rawCount: sDen - sNum,
            effectiveCount: sDen - sNum,
            isTarget: false,
          ),
        ];

        return ProbFractionResult(
          mode: 'DirectAndComplement',
          eventName: compEvent,
          favorableCount: sNum,
          totalCount: sDen,
          simplifiedNum: sNum,
          simplifiedDen: sDen,
          probabilityDecimal: compDec,
          categories: cats,
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps,
        );
      } else {
        // ---------------------------------------------------------------------
        // SUB-MODE 2: Reverse Solver (Find Unknown Total T = n/P or n = P*T)
        // Matches Ex. 21c #16 (35 nurses, P = 0.25 -> Find total participants)
        // ---------------------------------------------------------------------
        int? knownCount =
        int.tryParse(reverseKnownCountStr.replaceAll(RegExp(r'[^\d]'), ''));
        if (knownCount == null || knownCount <= 0) {
          throw const FormatException(
              "Enter a positive whole number for the known count.");
        }

        var parsedP = _parseProbabilityValue(reverseGivenProbStr);
        double pDec = parsedP['decimal'];
        int pNum = parsedP['num'];
        int pDen = parsedP['den'];

        if (pDec <= 0) {
          throw const FormatException(
              "Probability must be greater than 0 for reverse solving.");
        }

        workings.add("\\text{\\textbf{Reverse Probability Equation}}");
        workings.add(
            "P(\\text{$safeEvent}) = \\frac{\\text{Number of required outcomes } (n)}{\\text{Total possible outcomes } (T)}");
        workings.add("");

        steps.add(ProbFractionStep(
          title: "Step 1: Set Up the Probability Equation",
          description:
          "Start with the standard probability formula and substitute the values we know.",
          mathLaTeX: "P = \\frac{n}{T}",
        ));

        if (reverseFindTotal) {
          // Given Required Count (n) and Probability (P), Find Total (T)
          double calcTotal = knownCount / pDec;
          int roundedTotal = calcTotal.round();
          int otherCount = math.max(0, roundedTotal - knownCount);

          workings.add("\\text{Given: } n = $knownCount, \\quad P = ${_fmt(pDec)} \\left(\\text{or } \\frac{$pNum}{$pDen}\\right)");
          workings.add("${_fmt(pDec)} = \\frac{$knownCount}{T}");
          workings.add(
              "T = \\frac{$knownCount}{${_fmt(pDec)}} = $knownCount \\div \\frac{$pNum}{$pDen} = $knownCount \\times \\frac{$pDen}{$pNum} = ${_fmt(calcTotal)}");

          steps.add(ProbFractionStep(
            title: "Step 2: Substitute Known Values into the Formula",
            description:
            "We know there are $knownCount required outcomes ($eventLabel) and the probability is ${_fmt(pDec)} (which is $pNum/$pDen). Let T be the unknown total number of people/items.",
            mathLaTeX: "${_fmt(pDec)} = \\frac{$knownCount}{T}",
          ));

          steps.add(ProbFractionStep(
            title: "Step 3: Solve for the Unknown Total (T)",
            description:
            "Multiply both sides by T and divide by ${_fmt(pDec)} (or multiply $knownCount by $pDen/$pNum) to find the total number of possible outcomes.",
            mathLaTeX:
            "T = \\frac{$knownCount}{${_fmt(pDec)}} = $roundedTotal",
          ));

          answers["Total Number (T)"] = "$roundedTotal";
          answers["Required Count (n)"] = "$knownCount";
          answers["Probability (Fraction)"] = "\\frac{$pNum}{$pDen}";

          List<ParsedCategoryItem> cats = [
            ParsedCategoryItem(
              name: eventLabel,
              rawCount: knownCount,
              effectiveCount: knownCount,
              isTarget: true,
            ),
            ParsedCategoryItem(
              name: "Other Outcomes",
              rawCount: otherCount,
              effectiveCount: otherCount,
              isTarget: false,
            ),
          ];

          return ProbFractionResult(
            mode: 'DirectAndComplement',
            eventName: eventLabel,
            favorableCount: knownCount,
            totalCount: roundedTotal,
            simplifiedNum: pNum,
            simplifiedDen: pDen,
            probabilityDecimal: pDec,
            categories: cats,
            finalAnswers: answers,
            workingsLaTeX: workings,
            steps: steps,
          );
        } else {
          // Given Total (T) and Probability (P), Find Expected/Required Count (n)
          double calcFav = pDec * knownCount;
          int roundedFav = calcFav.round();
          int otherCount = math.max(0, knownCount - roundedFav);

          workings.add("\\text{Given: } T = $knownCount, \\quad P = \\frac{$pNum}{$pDen}");
          workings.add(
              "n = P \\times T = \\frac{$pNum}{$pDen} \\times $knownCount = ${_fmt(calcFav)}");

          steps.add(ProbFractionStep(
            title: "Step 2: Multiply Probability by Total Trials (T)",
            description:
            "To find how many times '$eventLabel' is expected out of $knownCount, multiply the probability ($pNum/$pDen) by $knownCount.",
            mathLaTeX:
            "n = \\frac{$pNum}{$pDen} \\times $knownCount = ${_fmt(calcFav)}",
          ));

          answers["Expected Count (n)"] = _fmt(calcFav);
          answers["Total Outcomes (T)"] = "$knownCount";
          answers["Probability (Fraction)"] = "\\frac{$pNum}{$pDen}";

          List<ParsedCategoryItem> cats = [
            ParsedCategoryItem(
              name: eventLabel,
              rawCount: roundedFav,
              effectiveCount: roundedFav,
              isTarget: true,
            ),
            ParsedCategoryItem(
              name: "Other Outcomes",
              rawCount: otherCount,
              effectiveCount: otherCount,
              isTarget: false,
            ),
          ];

          return ProbFractionResult(
            mode: 'DirectAndComplement',
            eventName: eventLabel,
            favorableCount: roundedFav,
            totalCount: knownCount,
            simplifiedNum: pNum,
            simplifiedDen: pDen,
            probabilityDecimal: pDec,
            categories: cats,
            finalAnswers: answers,
            workingsLaTeX: workings,
            steps: steps,
          );
        }
      }
    } catch (e) {
      return ProbFractionResult(
        mode: 'DirectAndComplement',
        eventName: '',
        favorableCount: 0,
        totalCount: 0,
        simplifiedNum: 0,
        simplifiedDen: 1,
        probabilityDecimal: 0,
        categories: [],
        finalAnswers: {},
        workingsLaTeX: [],
        steps: [],
        valid: false,
        errorMessage: e is FormatException
            ? e.message
            : "Please check your numbers and probability values.",
      );
    }
  }

  // ===========================================================================
  // MODE C: NUMBERED RANGE, DICE & CARDS ANALYZER (Ex. 21c #2, #9, #18)
  // ===========================================================================
  static bool _isPrime(int n) {
    if (n < 2) return false;
    for (int i = 2; i * i <= n; i++) {
      if (n % i == 0) return false;
    }
    return true;
  }

  static ProbFractionResult solveRangeAnalyzer({
    required int sourceType, // 0: Range (Start to End), 1: Custom List
    required String startNumStr,
    required String endNumStr,
    required String customListStr,
    required String conditionType,
    // 'equals', 'not_equals', 'not_contains_digit', 'contains_digit',
    // 'even', 'odd', 'prime', 'multiple', 'greater', 'less'
    required String targetValStr,
    required String futureTrialsStr,
  }) {
    try {
      List<int> sampleSpace = [];
      String sourceDesc = "";

      if (sourceType == 0) {
        int? start = int.tryParse(startNumStr.trim());
        int? end = int.tryParse(endNumStr.trim());
        if (start == null || end == null || end < start) {
          throw const FormatException(
              "Enter a valid whole number range (e.g. from 1 to 20).");
        }
        if (end - start > 500) {
          throw const FormatException(
              "Range is too large (maximum 500 items for visual listing).");
        }
        for (int i = start; i <= end; i++) {
          sampleSpace.add(i);
        }
        sourceDesc = "Numbers from $start to $end";
      } else {
        List<String> tokens = customListStr
            .trim()
            .split(RegExp(r'[,;\s]+'))
            .where((t) => t.trim().isNotEmpty)
            .toList();
        if (tokens.isEmpty) {
          throw const FormatException(
              "Enter a comma-separated list of numbers (e.g. 26, 26, 27, 27).");
        }
        for (String tok in tokens) {
          int? v = int.tryParse(tok.replaceAll(RegExp(r'[^\d\-]'), ''));
          if (v == null) {
            throw FormatException("Could not parse '$tok' as a whole number.");
          }
          sampleSpace.add(v);
        }
        sourceDesc = "Recorded list (${sampleSpace.length} items)";
      }

      int total = sampleSpace.length;
      String cleanTarget = targetValStr.trim();

      // Parse target set for 'equals' / 'not_equals'
      Set<int> targetSet = {};
      if (conditionType == 'equals' || conditionType == 'not_equals') {
        for (String p in cleanTarget.split(RegExp(r'[,;\s]+'))) {
          if (p.trim().isNotEmpty) {
            int? tv = int.tryParse(p.trim());
            if (tv != null) targetSet.add(tv);
          }
        }
        if (targetSet.isEmpty) {
          throw const FormatException(
              "Enter at least one target number (e.g. 6, or 1, 2, 3).");
        }
      }

      int? singleTargetInt = int.tryParse(cleanTarget);
      if (['multiple', 'greater', 'less'].contains(conditionType) &&
          singleTargetInt == null) {
        throw const FormatException("Enter a valid target number.");
      }
      if (['contains_digit', 'not_contains_digit'].contains(conditionType) &&
          cleanTarget.isEmpty) {
        throw const FormatException("Enter a target digit (e.g. 1).");
      }

      List<int> matched = [];
      List<int> unmatched = [];
      String eventLabel = "";

      for (int n in sampleSpace) {
        bool ok = false;
        switch (conditionType) {
          case 'equals':
            ok = targetSet.contains(n);
            break;
          case 'not_equals':
            ok = !targetSet.contains(n);
            break;
          case 'not_contains_digit':
            ok = !n.toString().contains(cleanTarget);
            break;
          case 'contains_digit':
            ok = n.toString().contains(cleanTarget);
            break;
          case 'even':
            ok = n % 2 == 0;
            break;
          case 'odd':
            ok = n % 2 != 0;
            break;
          case 'prime':
            ok = _isPrime(n);
            break;
          case 'multiple':
            ok = singleTargetInt! != 0 && n % singleTargetInt == 0;
            break;
          case 'greater':
            ok = n > singleTargetInt!;
            break;
          case 'less':
            ok = n < singleTargetInt!;
            break;
        }
        if (ok) {
          matched.add(n);
        } else {
          unmatched.add(n);
        }
      }

      switch (conditionType) {
        case 'equals':
          eventLabel = "Getting ${targetSet.join(' or ')}";
          break;
        case 'not_equals':
          eventLabel = "NOT getting ${targetSet.join(' or ')}";
          break;
        case 'not_contains_digit':
          eventLabel = "No digit '$cleanTarget'";
          break;
        case 'contains_digit':
          eventLabel = "Has digit '$cleanTarget'";
          break;
        case 'even':
          eventLabel = "Even number";
          break;
        case 'odd':
          eventLabel = "Odd number";
          break;
        case 'prime':
          eventLabel = "Prime number";
          break;
        case 'multiple':
          eventLabel = "Multiple of $singleTargetInt";
          break;
        case 'greater':
          eventLabel = "Greater than $singleTargetInt";
          break;
        case 'less':
          eventLabel = "Less than $singleTargetInt";
          break;
      }

      List<ProbFractionStep> steps = [];
      List<String> workings = [];

      workings.add("\\text{\\textbf{Probability as a Fraction Formula}}");
      workings.add(
          "\\text{Probability} = \\frac{\\text{Number of required outcomes}}{\\text{Number of possible outcomes}}");
      workings.add("");

      steps.add(ProbFractionStep(
        title: "Step 1: State the Probability Formula",
        description:
        "Write down the probability formula comparing the number of required outcomes to the total number of possible outcomes.",
        mathLaTeX:
        "P(\\text{Event}) = \\frac{\\text{Number of required outcomes}}{\\text{Number of possible outcomes}}",
      ));

      String samplePreview = sampleSpace.length <= 25
          ? sampleSpace.join(', ')
          : "${sampleSpace.take(20).join(', ')}, ... (${sampleSpace.length} items)";

      workings.add("\\text{\\textbf{Count Possible Outcomes:}}");
      workings.add("\\text{Total possible outcomes} = $total");

      steps.add(ProbFractionStep(
        title: "Step 2: Count the Total Possible Outcomes",
        description:
        "$sourceDesc: [$samplePreview]. There are $total possible outcomes in total.",
        mathLaTeX: "\\text{Total Possible Outcomes} = $total",
      ));

      String matchedPreview = matched.isEmpty
          ? "None (0 items)"
          : (matched.length <= 25
          ? matched.join(', ')
          : "${matched.take(20).join(', ')}, ... (${matched.length} items)");

      workings.add(
          "\\text{\\textbf{Count Required Outcomes (${_cleanTex(eventLabel)}):}}");
      workings.add(
          "\\text{Matching numbers: } [$matchedPreview] \\implies ${matched.length}");

      steps.add(ProbFractionStep(
        title: "Step 3: List and Count the Required Outcomes",
        description:
        "Check each number in the sample space for the condition '$eventLabel'. Matching numbers: [$matchedPreview]. This gives ${matched.length} required outcome(s).",
        mathLaTeX: "\\text{Required Outcomes} = ${matched.length}",
      ));

      List<ParsedCategoryItem> cats = [
        ParsedCategoryItem(
          name: eventLabel,
          rawCount: matched.length,
          effectiveCount: matched.length,
          isTarget: true,
        ),
        ParsedCategoryItem(
          name: "Other Numbers",
          rawCount: unmatched.length,
          effectiveCount: unmatched.length,
          isTarget: false,
        ),
      ];

      return _buildSharedFractionResult(
        mode: 'RangeAnalyzer',
        eventName: eventLabel,
        favorable: matched.length,
        total: total,
        categories: cats,
        workings: workings,
        steps: steps,
        futureTrialsStr: futureTrialsStr,
      );
    } catch (e) {
      return ProbFractionResult(
        mode: 'RangeAnalyzer',
        eventName: '',
        favorableCount: 0,
        totalCount: 0,
        simplifiedNum: 0,
        simplifiedDen: 1,
        probabilityDecimal: 0,
        categories: [],
        finalAnswers: {},
        workingsLaTeX: [],
        steps: [],
        valid: false,
        errorMessage: e is FormatException
            ? e.message
            : "Please check your number range and condition.",
      );
    }
  }

  // ===========================================================================
  // SHARED CORE: FRACTION SIMPLIFICATION, 1 - P DUAL CHECK, SIG FIGS & PREDICTION
  // ===========================================================================
  static ProbFractionResult _buildSharedFractionResult({
    required String mode,
    required String eventName,
    required int favorable,
    required int total,
    required List<ParsedCategoryItem> categories,
    required List<String> workings,
    required List<ProbFractionStep> steps,
    required String futureTrialsStr,
    bool showDualComplement = false,
    String? complementBaseName,
    bool includeSigFigs = false,
  }) {
    String safeEvent = _cleanTex(eventName);
    Map<String, String> answers = {};

    int hcf = _gcd(favorable, total);
    int simpNum = favorable == 0 ? 0 : favorable ~/ hcf;
    int simpDen = favorable == 0 ? 1 : total ~/ hcf;
    double probDec = favorable / total;
    double probPct = probDec * 100.0;

    workings.add("");
    workings.add("\\text{\\textbf{Form and Simplify the Probability Fraction:}}");

    String fracStr = "";
    if (favorable == 0) {
      fracStr = "0";
      workings.add("P(\\text{$safeEvent}) = \\frac{0}{$total} = 0 \\text{ (Impossible)}");
      steps.add(ProbFractionStep(
        title:
        "Step ${steps.length + 1}: Form the Probability Fraction (Impossible = 0)",
        description:
        "Since there are 0 required outcomes out of $total possible outcomes, the probability is 0/$total = 0. When we are sure something cannot happen, its probability is 0.",
        mathLaTeX: "P(\\text{$safeEvent}) = \\frac{0}{$total} = 0",
      ));
    } else if (favorable == total) {
      fracStr = "1";
      workings.add(
          "P(\\text{$safeEvent}) = \\frac{$total}{$total} = 1 \\text{ (Certain)}");
      steps.add(ProbFractionStep(
        title:
        "Step ${steps.length + 1}: Form the Probability Fraction (Certain = 1)",
        description:
        "Every single possible outcome ($total out of $total) satisfies '$eventName'. When we are certain that something will happen, its probability is $total/$total = 1.",
        mathLaTeX: "P(\\text{$safeEvent}) = \\frac{$total}{$total} = 1",
      ));
    } else if (hcf > 1) {
      fracStr = "\\frac{$simpNum}{$simpDen}";
      workings.add("P(\\text{$safeEvent}) = \\frac{$favorable}{$total}");
      workings.add(
          "\\text{Divide numerator and denominator by HCF ($hcf):}");
      workings.add(
          "P(\\text{$safeEvent}) = \\frac{$favorable \\div $hcf}{$total \\div $hcf} = \\frac{$simpNum}{$simpDen}");

      steps.add(ProbFractionStep(
        title:
        "Step ${steps.length + 1}: Simplify the Probability Fraction (HCF = $hcf)",
        description:
        "Substitute $favorable and $total into the formula to get $favorable/$total. Divide both the top and bottom numbers by their Highest Common Factor (HCF = $hcf) to express the fraction in its lowest terms.",
        mathLaTeX:
        "P(\\text{$safeEvent}) = \\frac{$favorable \\div $hcf}{$total \\div $hcf} = \\frac{$simpNum}{$simpDen}",
      ));
    } else {
      fracStr = "\\frac{$simpNum}{$simpDen}";
      workings.add("P(\\text{$safeEvent}) = \\frac{$favorable}{$total}");

      steps.add(ProbFractionStep(
        title: "Step ${steps.length + 1}: Form the Probability Fraction",
        description:
        "Substitute $favorable and $total into the formula. Since the Highest Common Factor (HCF) of $favorable and $total is 1, the fraction $favorable/$total is already in its simplest form.",
        mathLaTeX: "P(\\text{$safeEvent}) = \\frac{$favorable}{$total}",
      ));
    }

    // Show Method 2 (Subtracting Probability from 1) as taught in Example 3
    if (showDualComplement &&
        complementBaseName != null &&
        favorable > 0 &&
        favorable < total) {
      int baseCount = total - favorable;
      int baseHcf = _gcd(baseCount, total);
      int bNum = baseCount ~/ baseHcf;
      int bDen = total ~/ baseHcf;
      String safeBase = _cleanTex(complementBaseName);

      workings.add("");
      workings.add(
          "\\text{\\textbf{Method 2: Subtracting Probability from 1 (Example 3 Rule)}}");
      workings.add(
          "P(\\text{$safeBase}) = \\frac{$baseCount}{$total} = \\frac{$bNum}{$bDen}");
      workings.add(
          "P(\\text{$safeEvent}) = 1 - \\frac{$bNum}{$bDen} = \\frac{$bDen - $bNum}{$bDen} = \\frac{$simpNum}{$simpDen}");

      steps.add(ProbFractionStep(
        title:
        "Step ${steps.length + 1}: Alternative Method Using '1 - P' (Example 3)",
        description:
        "Instead of subtracting the counts first, you can also find the probability of '$complementBaseName' ($bNum/$bDen) and subtract that fraction from 1!",
        mathLaTeX:
        "P(\\text{$safeEvent}) = 1 - \\frac{$bNum}{$bDen} = \\frac{$simpNum}{$simpDen}",
      ));
    }

    // Decimal, Percentage & Significant Figures (Matches Example 5 & Ex. 21c #19)
    String decStr = _fmt(probDec);
    String pctStr = "${_fmt(probPct, maxDecimals: 2)}\\%";
    String dec2SF = _fmtSF(probDec, 2);
    String dec1SF = _fmtSF(probDec, 1);

    workings.add("");
    workings.add("\\text{\\textbf{Decimal and Percentage Conversions:}}");
    workings.add("\\text{Decimal} = $decStr \\quad ; \\quad \\text{Percentage} = $pctStr");

    if (includeSigFigs || (decStr.length > 4 && favorable > 0 && favorable < total)) {
      workings.add(
          "\\text{Approximations: } \\approx $dec2SF \\text{ (to 2 s.f.)} \\quad ; \\quad \\approx $dec1SF \\text{ (to 1 s.f.)}");
      steps.add(ProbFractionStep(
        title:
        "Step ${steps.length + 1}: Convert to Decimal (2 s.f. & 1 s.f.) and Percentage",
        description:
        "Divide $simpNum by $simpDen to get the decimal ($decStr). As shown in Example 5, we can round this to 2 significant figures ($dec2SF) or 1 significant figure ($dec1SF), and multiply by 100% to get the percentage rate.",
        mathLaTeX:
        "$fracStr \\approx $dec2SF \\text{ (2 s.f.)} \\approx $dec1SF \\text{ (1 s.f.)} \\quad (\\text{or } $pctStr)",
      ));
    } else {
      steps.add(ProbFractionStep(
        title: "Step ${steps.length + 1}: Express as Decimal and Percentage",
        description:
        "Convert the simplified fraction to a decimal and multiply by 100% to express the probability as a percentage.",
        mathLaTeX: "$fracStr = $decStr = $pctStr",
      ));
    }

    answers["Probability (Fraction)"] = fracStr;
    answers["Probability (Decimal)"] = decStr;
    answers["Probability (Percentage)"] = pctStr;
    if (includeSigFigs || (decStr.length > 4 && favorable > 0 && favorable < total)) {
      answers["Approx. (2 s.f. / 1 s.f.)"] = "$dec2SF \\; / \\; $dec1SF";
    }

    // Future Prediction / Expected Count (e.g. Ex. 21c #12, #13d, #20e)
    String cleanFuture = futureTrialsStr.trim();
    if (cleanFuture.isNotEmpty) {
      int? futureN =
      int.tryParse(cleanFuture.replaceAll(RegExp(r'[^\d]'), ''));
      if (futureN != null && futureN > 0) {
        double expectedExact = probDec * futureN;
        int expectedRound = expectedExact.round();

        workings.add("");
        workings.add(
            "\\text{\\textbf{Expected Number out of $futureN Trials:}}");
        String expLatex = (expectedExact - expectedRound).abs() < 1e-9
            ? "$fracStr \\times $futureN = $expectedRound"
            : "$fracStr \\times $futureN = ${_fmt(expectedExact)} \\approx $expectedRound";
        workings.add("\\text{Expected Count} = $expLatex");

        steps.add(ProbFractionStep(
          title:
          "Step ${steps.length + 1}: Predict Out of $futureN Random Selections",
          description:
          "Multiply the probability fraction ($simpNum/$simpDen) by the sample size ($futureN) to find the expected number of outcomes.",
          mathLaTeX: "\\text{Expected Number} = $expLatex",
        ));

        answers["Expected out of $futureN"] =
        (expectedExact - expectedRound).abs() < 1e-9
            ? "$expectedRound"
            : "${_fmt(expectedExact)} (\\approx $expectedRound)";
      }
    }

    return ProbFractionResult(
      mode: mode,
      eventName: eventName,
      favorableCount: favorable,
      totalCount: total,
      simplifiedNum: simpNum,
      simplifiedDen: simpDen,
      probabilityDecimal: probDec,
      categories: categories,
      finalAnswers: answers,
      workingsLaTeX: workings,
      steps: steps,
    );
  }
}