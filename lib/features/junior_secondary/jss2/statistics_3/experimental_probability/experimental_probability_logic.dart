import 'experimental_probability_models.dart';

class ExperimentalProbabilityLogic {
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
  static String _fmt(double v) {
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// Sanitizes user labels so they don't break LaTeX \text{...} blocks
  static String _cleanTex(String s) {
    return s
        .replaceAll('\\', '')
        .replaceAll('{', '(')
        .replaceAll('}', ')')
        .replaceAll('\$', '')
        .replaceAll('%', '\\%')
        .replaceAll('&', '\\&')
        .replaceAll('_', ' ')
        .trim();
  }

  /// Parses a count string that may be a single integer ("36")
  /// or a multi-row sum ("2 + 6 + 4 + 5 + 7" or "2, 6, 4, 5, 7")
  static Map<String, dynamic> _parseCountExpression(String expr) {
    String clean = expr.trim();
    if (clean.isEmpty) {
      throw const FormatException("Frequency/count cannot be empty.");
    }

    List<String> parts = clean
        .split(RegExp(r'[+,;\s]+'))
        .where((p) => p.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      throw const FormatException("Enter valid whole numbers for frequencies.");
    }

    List<int> nums = [];
    int sum = 0;
    for (String p in parts) {
      int? val = int.tryParse(p.trim());
      if (val == null || val < 0) {
        throw const FormatException(
            "Frequencies must be whole numbers greater than or equal to 0.");
      }
      nums.add(val);
      sum += val;
    }

    return {
      'sum': sum,
      'breakdown': nums.length > 1 ? nums.join(' + ') : null,
    };
  }

  // ===========================================================================
  // MODE A: FREQUENCY & TALLY TABLE SOLVER
  // ===========================================================================
  static ExperimentalProbResult solveTable({
    required List<OutcomeRowInput> rows,
    required Set<int> selectedIndices,
    required bool isComplement,
    required String futureTrialsStr,
  }) {
    try {
      if (rows.isEmpty) {
        throw const FormatException("Add at least one outcome row.");
      }
      if (selectedIndices.isEmpty) {
        throw const FormatException(
            "Select at least one target outcome from the selector.");
      }

      List<ParsedOutcomeItem> parsedOutcomes = [];
      List<ExperimentalProbStep> steps = [];
      List<String> workings = [];

      // 1. State the Foundational Formula First
      workings.add("\\text{\\textbf{Experimental Probability Formula}}");
      workings.add(
          "\\text{Probability} = \\frac{\\text{Number of required outcomes}}{\\text{Total number of possible outcomes}}");
      workings.add("");

      steps.add(ExperimentalProbStep(
        title: "Step 1: State the Experimental Probability Formula",
        description:
        "Experimental probability uses past records or tally counts. We always start by writing down the probability formula.",
        mathLaTeX:
        "P(\\text{Event}) = \\frac{\\text{Number of required outcomes}}{\\text{Total number of possible outcomes}}",
      ));

      // 2. Parse each row and check for multi-row sums (like Example 1's family table)
      bool hasMultiRowSums = false;
      int totalOutcomes = 0;
      int favorableOutcomes = 0;
      List<String> selectedNames = [];

      for (int i = 0; i < rows.length; i++) {
        String rName = rows[i].name.trim().isEmpty
            ? "Outcome ${i + 1}"
            : rows[i].name.trim();
        var parsed = _parseCountExpression(rows[i].countExpression);
        int count = parsed['sum'];
        String? breakdown = parsed['breakdown'];
        if (breakdown != null) hasMultiRowSums = true;

        bool isRowSelected = selectedIndices.contains(i);
        bool isRowTarget = isComplement ? !isRowSelected : isRowSelected;

        if (isRowSelected) {
          selectedNames.add(rName);
        }

        totalOutcomes += count;
        if (isRowTarget) {
          favorableOutcomes += count;
        }

        parsedOutcomes.add(ParsedOutcomeItem(
          name: rName,
          count: count,
          isTarget: isRowTarget,
          sumBreakdown: breakdown,
        ));
      }

      if (totalOutcomes <= 0) {
        throw const FormatException(
            "Total number of outcomes must be greater than zero.");
      }

      // If any row had a list of numbers (e.g., 2 + 6 + 4 + 5 + 7), show that addition step explicitly!
      if (hasMultiRowSums) {
        workings.add("\\text{\\textbf{Sum Each Category Column/Row:}}");
        List<String> sumMathLines = [];
        for (var item in parsedOutcomes) {
          String safeName = _cleanTex(item.name);
          if (item.sumBreakdown != null) {
            String line =
                "\\text{$safeName} = ${item.sumBreakdown} = ${item.count}";
            workings.add(line);
            sumMathLines.add(line);
          } else {
            String line = "\\text{$safeName} = ${item.count}";
            workings.add(line);
            sumMathLines.add(line);
          }
        }
        workings.add("");

        steps.add(ExperimentalProbStep(
          title: "Step 2: Add Up the Records for Each Outcome",
          description:
          "Before finding the grand total, we add the individual records for each category in the table.",
          mathLaTeX: sumMathLines.join(" \\quad ; \\quad "),
        ));
      }

      // 3. Explicitly show how the Total Possible Outcomes (Denominator) is formed
      String totalAdditionStr =
      parsedOutcomes.map((e) => e.count.toString()).join(' + ');
      workings.add("\\text{\\textbf{Total Possible Outcomes:}}");
      if (parsedOutcomes.length > 1) {
        workings.add("\\text{Total} = $totalAdditionStr = $totalOutcomes");
      } else {
        workings.add("\\text{Total} = $totalOutcomes");
      }

      steps.add(ExperimentalProbStep(
        title:
        "Step ${hasMultiRowSums ? '3' : '2'}: Find the Total Number of Possible Outcomes",
        description:
        "Add the frequencies of all categories together to find the total number of trials (the denominator).",
        mathLaTeX: parsedOutcomes.length > 1
            ? "\\text{Total Outcomes} = $totalAdditionStr = $totalOutcomes"
            : "\\text{Total Outcomes} = $totalOutcomes",
      ));

      // 4. Identify Required (Favorable) Outcomes
      String baseSelectionLabel = selectedNames.join(" or ");
      String eventLabel =
      isComplement ? "NOT ($baseSelectionLabel)" : baseSelectionLabel;
      String safeEventTex = _cleanTex(eventLabel);

      List<ParsedOutcomeItem> targetItems =
      parsedOutcomes.where((e) => e.isTarget).toList();
      String favAdditionStr =
      targetItems.map((e) => e.count.toString()).join(' + ');

      workings.add("");
      workings.add("\\text{\\textbf{Required Outcomes ($safeEventTex):}}");
      if (isComplement) {
        int selectedSum = totalOutcomes - favorableOutcomes;
        workings.add(
            "\\text{Number of ($safeEventTex)} = $totalOutcomes - $selectedSum = $favorableOutcomes");
      } else if (targetItems.length > 1) {
        workings.add(
            "\\text{Required Outcomes} = $favAdditionStr = $favorableOutcomes");
      } else {
        workings.add("\\text{Required Outcomes} = $favorableOutcomes");
      }

      steps.add(ExperimentalProbStep(
        title:
        "Step ${hasMultiRowSums ? '4' : '3'}: Identify the Number of Required Outcomes",
        description: isComplement
            ? "We are looking for the complement event: $eventLabel. We subtract the count of ($baseSelectionLabel) from the total outcomes ($totalOutcomes)."
            : (targetItems.length > 1
            ? "Add the frequencies of the selected target outcomes ($eventLabel) together to get the numerator."
            : "Read the frequency for '$eventLabel' from the table. This is our numerator."),
        mathLaTeX: isComplement
            ? "\\text{Required Outcomes} = $totalOutcomes - ${totalOutcomes - favorableOutcomes} = $favorableOutcomes"
            : (targetItems.length > 1
            ? "\\text{Required Outcomes} = $favAdditionStr = $favorableOutcomes"
            : "\\text{Required Outcomes} = $favorableOutcomes"),
      ));

      return _buildSharedProbabilityResult(
        mode: 'Table',
        eventName: eventLabel,
        favorable: favorableOutcomes,
        total: totalOutcomes,
        outcomes: parsedOutcomes,
        workings: workings,
        steps: steps,
        futureTrialsStr: futureTrialsStr,
        isComplement: isComplement,
        baseComplementName: baseSelectionLabel,
      );
    } catch (e) {
      return ExperimentalProbResult(
        mode: 'Table',
        eventName: '',
        favorableCount: 0,
        totalCount: 0,
        simplifiedNum: 0,
        simplifiedDen: 1,
        probabilityDecimal: 0,
        outcomes: [],
        finalAnswers: {},
        workingsLaTeX: [],
        steps: [],
        valid: false,
        errorMessage: e is FormatException
            ? e.message
            : "Please check your table numbers and try again.",
      );
    }
  }

  // ===========================================================================
  // MODE B: RAW OBSERVATION DATA SOLVER (e.g., Ibadan Rainfall)
  // ===========================================================================
  static ExperimentalProbResult solveRawData({
    required String rawListStr,
    required String conditionOp, // '>', '=', '<', '>=', '<=', '!=', 'contains'
    required String targetValStr,
    required String customEventName,
    required String futureTrialsStr,
  }) {
    try {
      List<String> tokens = rawListStr
          .trim()
          .split(RegExp(r'[,;\s]+'))
          .where((s) => s.trim().isNotEmpty)
          .toList();

      if (tokens.isEmpty) {
        throw const FormatException(
            "Enter a list of recorded numbers separated by commas.");
      }

      String targetClean = targetValStr.trim();
      if (targetClean.isEmpty) {
        throw const FormatException(
            "Enter a target value for the condition filter.");
      }

      List<double> values = [];
      for (String t in tokens) {
        double? v = double.tryParse(t.replaceAll(RegExp(r'[^\d\.\-]'), ''));
        if (v == null) {
          throw FormatException("Could not read '$t' as a valid number.");
        }
        values.add(v);
      }

      double? targetNum =
      double.tryParse(targetClean.replaceAll(RegExp(r'[^\d\.\-]'), ''));
      if (conditionOp != 'contains' && targetNum == null) {
        throw const FormatException("Target value must be a valid number.");
      }

      List<String> matchedTokens = [];
      List<String> unmatchedTokens = [];

      for (int i = 0; i < values.length; i++) {
        double v = values[i];
        String disp = _fmt(v);
        bool matches = false;

        switch (conditionOp) {
          case '>':
            matches = v > targetNum!;
            break;
          case '=':
            matches = (v - targetNum!).abs() < 1e-9;
            break;
          case '<':
            matches = v < targetNum!;
            break;
          case '>=':
            matches = v >= targetNum! - 1e-9;
            break;
          case '<=':
            matches = v <= targetNum! + 1e-9;
            break;
          case '!=':
            matches = (v - targetNum!).abs() >= 1e-9;
            break;
          case 'contains':
            matches = disp.contains(targetClean);
            break;
        }

        if (matches) {
          matchedTokens.add(disp);
        } else {
          unmatchedTokens.add(disp);
        }
      }

      String condDesc = "";
      switch (conditionOp) {
        case '>':
          condDesc = "Greater than ${_fmt(targetNum!)}";
          break;
        case '=':
          condDesc = "Equal to ${_fmt(targetNum!)}";
          break;
        case '<':
          condDesc = "Less than ${_fmt(targetNum!)}";
          break;
        case '>=':
          condDesc = "At least ${_fmt(targetNum!)}";
          break;
        case '<=':
          condDesc = "At most ${_fmt(targetNum!)}";
          break;
        case '!=':
          condDesc = "Not equal to ${_fmt(targetNum!)}";
          break;
        case 'contains':
          condDesc = "Contains digit '$targetClean'";
          break;
      }

      String eventLabel =
      customEventName.trim().isNotEmpty ? customEventName.trim() : condDesc;
      String safeEventTex = _cleanTex(eventLabel);

      int total = values.length;
      int favorable = matchedTokens.length;

      List<ExperimentalProbStep> steps = [];
      List<String> workings = [];

      // 1. Formula
      workings.add("\\text{\\textbf{Experimental Probability Formula}}");
      workings.add(
          "\\text{Probability} = \\frac{\\text{Number of required outcomes}}{\\text{Total number of possible outcomes}}");
      workings.add("");

      steps.add(ExperimentalProbStep(
        title: "Step 1: State the Experimental Probability Formula",
        description:
        "We start with the experimental probability formula comparing the number of times the event happened to the total number of recorded observations.",
        mathLaTeX:
        "P(\\text{Event}) = \\frac{\\text{Number of required outcomes}}{\\text{Total number of possible outcomes}}",
      ));

      // 2. Count Total Observations
      workings.add("\\text{\\textbf{Count the Observations:}}");
      workings.add("\\text{Total recorded observations} = $total");

      steps.add(ExperimentalProbStep(
        title: "Step 2: Count the Total Number of Observations",
        description:
        "Count all the numbers in the dataset (${values.map(_fmt).join(', ')}). There are $total recorded observations in total.",
        mathLaTeX: "\\text{Total Possible Outcomes} = $total",
      ));

      // 3. Filter for Favorable Observations
      String matchedListStr =
      matchedTokens.isEmpty ? "None" : matchedTokens.join(', ');
      workings.add(
          "\\text{Observations matching ($safeEventTex)} = $favorable \\text{ out of } $total");

      steps.add(ExperimentalProbStep(
        title: "Step 3: Count Observations Matching '$eventLabel'",
        description:
        "Check each recorded value against the condition ($condDesc). The matching values are: [$matchedListStr]. This gives $favorable favorable outcomes.",
        mathLaTeX: "\\text{Required Outcomes} = $favorable",
      ));

      List<ParsedOutcomeItem> outcomes = [
        ParsedOutcomeItem(
          name: eventLabel,
          count: favorable,
          isTarget: true,
        ),
        ParsedOutcomeItem(
          name: "Other Outcomes",
          count: total - favorable,
          isTarget: false,
        ),
      ];

      return _buildSharedProbabilityResult(
        mode: 'RawData',
        eventName: eventLabel,
        favorable: favorable,
        total: total,
        outcomes: outcomes,
        workings: workings,
        steps: steps,
        futureTrialsStr: futureTrialsStr,
      );
    } catch (e) {
      return ExperimentalProbResult(
        mode: 'RawData',
        eventName: '',
        favorableCount: 0,
        totalCount: 0,
        simplifiedNum: 0,
        simplifiedDen: 1,
        probabilityDecimal: 0,
        outcomes: [],
        finalAnswers: {},
        workingsLaTeX: [],
        steps: [],
        valid: false,
        errorMessage: e is FormatException
            ? e.message
            : "Ensure your data list contains valid numbers.",
      );
    }
  }

  // ===========================================================================
  // MODE C: QUICK DIRECT SOLVER (Favorable vs. Total)
  // ===========================================================================
  static ExperimentalProbResult solveDirect({
    required String eventNameStr,
    required String favorableStr,
    required String totalStr,
    required String futureTrialsStr,
  }) {
    try {
      String eventLabel =
      eventNameStr.trim().isEmpty ? "Target Event" : eventNameStr.trim();
      int? favorable =
      int.tryParse(favorableStr.replaceAll(RegExp(r'[^\d\-]'), ''));
      int? total = int.tryParse(totalStr.replaceAll(RegExp(r'[^\d\-]'), ''));

      if (favorable == null || total == null) {
        throw const FormatException(
            "Enter whole numbers for both Successful Outcomes and Total Trials.");
      }
      if (total <= 0) {
        throw const FormatException(
            "Total number of trials must be greater than zero.");
      }
      if (favorable < 0 || favorable > total) {
        throw const FormatException(
            "Successful outcomes must be between 0 and the total number of trials.");
      }

      List<ExperimentalProbStep> steps = [];
      List<String> workings = [];
      String safeEventTex = _cleanTex(eventLabel);

      workings.add("\\text{\\textbf{Experimental Probability Formula}}");
      workings.add(
          "\\text{Probability} = \\frac{\\text{Number of required outcomes}}{\\text{Total number of possible outcomes}}");
      workings.add("");
      workings.add("\\text{Required Outcomes ($safeEventTex)} = $favorable");
      workings.add("\\text{Total Possible Outcomes} = $total");

      steps.add(ExperimentalProbStep(
        title: "Step 1: State the Formula and Given Values",
        description:
        "Write down the experimental probability formula and identify the number of required outcomes ($favorable) and total possible outcomes ($total).",
        mathLaTeX:
        "P(\\text{$safeEventTex}) = \\frac{\\text{Required Outcomes}}{\\text{Total Outcomes}} = \\frac{$favorable}{$total}",
      ));

      List<ParsedOutcomeItem> outcomes = [
        ParsedOutcomeItem(
          name: eventLabel,
          count: favorable,
          isTarget: true,
        ),
        ParsedOutcomeItem(
          name: "Other Outcomes",
          count: total - favorable,
          isTarget: false,
        ),
      ];

      return _buildSharedProbabilityResult(
        mode: 'Direct',
        eventName: eventLabel,
        favorable: favorable,
        total: total,
        outcomes: outcomes,
        workings: workings,
        steps: steps,
        futureTrialsStr: futureTrialsStr,
      );
    } catch (e) {
      return ExperimentalProbResult(
        mode: 'Direct',
        eventName: '',
        favorableCount: 0,
        totalCount: 0,
        simplifiedNum: 0,
        simplifiedDen: 1,
        probabilityDecimal: 0,
        outcomes: [],
        finalAnswers: {},
        workingsLaTeX: [],
        steps: [],
        valid: false,
        errorMessage:
        e is FormatException ? e.message : "Invalid input numbers.",
      );
    }
  }

  // ===========================================================================
  // SHARED PEDAGOGICAL CORE: HCF REDUCTION, FORMATS, COMPLEMENT & PREDICTION
  // ===========================================================================
  static ExperimentalProbResult _buildSharedProbabilityResult({
    required String mode,
    required String eventName,
    required int favorable,
    required int total,
    required List<ParsedOutcomeItem> outcomes,
    required List<String> workings,
    required List<ExperimentalProbStep> steps,
    required String futureTrialsStr,
    bool isComplement = false,
    String? baseComplementName,
  }) {
    String safeEventTex = _cleanTex(eventName);
    Map<String, String> answers = {};

    int hcf = _gcd(favorable, total);
    int simpNum = favorable == 0 ? 0 : favorable ~/ hcf;
    int simpDen = favorable == 0 ? 1 : total ~/ hcf;
    double probDec = favorable / total;
    double probPct = probDec * 100.0;

    workings.add("");
    workings.add("\\text{\\textbf{Calculate & Simplify the Probability:}}");

    String fracStr = "";
    if (favorable == 0) {
      fracStr = "0";
      workings.add("P(\\text{$safeEventTex}) = \\frac{0}{$total} = 0");
      steps.add(ExperimentalProbStep(
        title: "Step ${steps.length + 1}: Form the Probability Fraction",
        description:
        "Since the required outcome happened 0 times out of $total trials, the numerator is 0. Zero divided by any positive number is 0 (an impossible event in the record).",
        mathLaTeX: "P(\\text{$safeEventTex}) = \\frac{0}{$total} = 0",
      ));
    } else if (favorable == total) {
      fracStr = "1";
      workings.add("P(\\text{$safeEventTex}) = \\frac{$total}{$total} = 1");
      steps.add(ExperimentalProbStep(
        title: "Step ${steps.length + 1}: Form the Probability Fraction",
        description:
        "Every single trial resulted in '$eventName' ($total out of $total). Dividing $total by $total gives 1 (a certain event based on the record).",
        mathLaTeX: "P(\\text{$safeEventTex}) = \\frac{$total}{$total} = 1",
      ));
    } else if (hcf > 1) {
      fracStr = "\\frac{$simpNum}{$simpDen}";
      workings.add("P(\\text{$safeEventTex}) = \\frac{$favorable}{$total}");
      workings.add(
          "\\text{Divide top and bottom by HCF ($hcf): } P = \\frac{$favorable \\div $hcf}{$total \\div $hcf} = \\frac{$simpNum}{$simpDen}");

      steps.add(ExperimentalProbStep(
        title:
        "Step ${steps.length + 1}: Simplify the Probability Fraction (HCF = $hcf)",
        description:
        "Substitute $favorable and $total into the formula to get $favorable/$total. To reduce this fraction to its lowest terms, divide both the numerator and denominator by their Highest Common Factor (HCF), which is $hcf.",
        mathLaTeX:
        "P(\\text{$safeEventTex}) = \\frac{$favorable \\div $hcf}{$total \\div $hcf} = \\frac{$simpNum}{$simpDen}",
      ));
    } else {
      fracStr = "\\frac{$simpNum}{$simpDen}";
      workings.add("P(\\text{$safeEventTex}) = \\frac{$favorable}{$total}");

      steps.add(ExperimentalProbStep(
        title: "Step ${steps.length + 1}: Form the Probability Fraction",
        description:
        "Substitute $favorable and $total into the formula. Since the Highest Common Factor (HCF) of $favorable and $total is 1, the fraction $favorable/$total is already in its simplest form!",
        mathLaTeX: "P(\\text{$safeEventTex}) = \\frac{$favorable}{$total}",
      ));
    }

    // Optional Proactive Teaching Note for Complement Rule (1 - P) as shown in Example 1b
    if (isComplement &&
        baseComplementName != null &&
        favorable > 0 &&
        favorable < total) {
      int compFav = total - favorable;
      int compHcf = _gcd(compFav, total);
      int cNum = compFav ~/ compHcf;
      int cDen = total ~/ compHcf;
      String safeBaseTex = _cleanTex(baseComplementName);

      workings.add("");
      workings.add("\\text{\\textbf{Alternative Method (Complement Rule):}}");
      workings.add(
          "P(\\text{$safeEventTex}) = 1 - P(\\text{$safeBaseTex}) = 1 - \\frac{$cNum}{$cDen} = \\frac{$cDen - $cNum}{$cDen} = \\frac{$simpNum}{$simpDen}");

      steps.add(ExperimentalProbStep(
        title: "Step ${steps.length + 1}: Alternative Check Using the '1 - P' Rule",
        description:
        "Because total probability always adds up to 1, you can also find '$eventName' by subtracting the probability of '$baseComplementName' ($cNum/$cDen) from 1!",
        mathLaTeX:
        "P(\\text{$safeEventTex}) = 1 - \\frac{$cNum}{$cDen} = \\frac{$simpNum}{$simpDen}",
      ));
    }

    // Convert to Decimal and Percentage (matching the Ibadan Rainfall example: 3/4 or 0.75 or 75%)
    String decStr = _fmt(probDec);
    String pctStr = "${_fmt(probPct)}\\%";

    workings.add("");
    workings.add("\\text{\\textbf{Express as Decimal and Percentage:}}");
    workings.add("\\text{As a Decimal: } $fracStr = $decStr");
    workings.add(
        "\\text{As a Percentage: } $decStr \\times 100\\% = ${_fmt(probPct)}\\%");

    steps.add(ExperimentalProbStep(
      title: "Step ${steps.length + 1}: Convert to Decimal and Percentage",
      description:
      "Probabilities can be written as a fraction between 0 and 1, as a decimal, or as a percentage (by multiplying by 100%).",
      mathLaTeX: "$fracStr = $decStr = $pctStr",
    ));

    answers["Probability (Fraction)"] = fracStr;
    answers["Probability (Decimal)"] = decStr;
    answers["Probability (Percentage)"] = pctStr;

    // Future Prediction / Expectation (e.g., "Out of 5 children, how many are likely to be male?")
    String cleanFuture = futureTrialsStr.trim();
    if (cleanFuture.isNotEmpty) {
      int? futureN =
      int.tryParse(cleanFuture.replaceAll(RegExp(r'[^\d]'), ''));
      if (futureN != null && futureN > 0) {
        double expectedExact = probDec * futureN;
        int expectedRounded = expectedExact.round();

        workings.add("");
        workings.add(
            "\\text{\\textbf{Prediction for $futureN Future Trials:}}");
        workings.add(
            "\\text{Expected Number} = \\text{Probability} \\times \\text{Number of Trials}");

        String predMath = "";
        if ((expectedExact - expectedRounded).abs() < 1e-9) {
          predMath =
          "$fracStr \\text{ of } $futureN = $fracStr \\times $futureN = $expectedRounded";
          workings.add("\\text{Expected Number} = $predMath");
          answers["Expected out of $futureN"] = "$expectedRounded";
        } else {
          predMath =
          "$fracStr \\times $futureN = ${_fmt(expectedExact)} \\approx $expectedRounded";
          workings.add("\\text{Expected Number} = $predMath");
          answers["Expected out of $futureN"] =
          "${_fmt(expectedExact)} (\\approx $expectedRounded)";
        }

        steps.add(ExperimentalProbStep(
          title:
          "Step ${steps.length + 1}: Predict Out of $futureN Future Trials",
          description:
          "Assuming future events follow the pattern of the past, we multiply our experimental probability by the number of future trials ($futureN).",
          mathLaTeX: "\\text{Expected Number} = $predMath",
        ));
      }
    }

    return ExperimentalProbResult(
      mode: mode,
      eventName: eventName,
      favorableCount: favorable,
      totalCount: total,
      simplifiedNum: simpNum,
      simplifiedDen: simpDen,
      probabilityDecimal: probDec,
      outcomes: outcomes,
      finalAnswers: answers,
      workingsLaTeX: workings,
      steps: steps,
    );
  }
}