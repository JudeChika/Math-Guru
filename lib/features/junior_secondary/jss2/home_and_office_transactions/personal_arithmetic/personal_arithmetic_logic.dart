import 'dart:math' as math;
import 'personal_arithmetic_models.dart';

class PersonalArithmeticLogic {

  /// Helper to format money safely
  static String _fmtMoney(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// Safely escapes symbols for LaTeX rendering
  static String _escapeLatex(String text) {
    return text.replaceAll('\$', '\\\$').replaceAll('%', '\\%').replaceAll('£', '\\text{£}');
  }

  /// Intelligently extracts the currency symbol and numeric value
  static Map<String, dynamic> _parseCurrency(String input) {
    String clean = input.trim();
    String sym = '₦'; // Default currency
    var match = RegExp(r'^([^\d\.\s]+)').firstMatch(clean);
    if (match != null) {
      sym = match.group(1)!.trim();
    }
    double val = 0.0;
    String numPart = clean.replaceAll(RegExp(r'[^\d\.]'), '');
    if (numPart.isNotEmpty) {
      val = double.parse(numPart);
    }
    return {'symbol': sym, 'value': val};
  }

  static PersonalArithmeticResult solveSimpleInterest({
    required int solveMode,
    required String principalStr,
    required String rateStr,
    required String timeStr,
    required String interestStr,
    required String timeUnit,
    required String instalmentsStr,
  }) {
    try {
      var parsedPrincipal = _parseCurrency(principalStr);
      double p = parsedPrincipal['value'];
      String symPlain = parsedPrincipal['symbol'];
      String symLaTeX = _escapeLatex(symPlain);

      double r = double.tryParse(rateStr.replaceAll(RegExp(r'[^\d\.]'), '')) ?? 0;
      double tRaw = double.tryParse(timeStr.replaceAll(RegExp(r'[^\d\.]'), '')) ?? 0;

      var parsedInterest = _parseCurrency(interestStr);
      double iAmt = parsedInterest['value'];
      if (parsedInterest['symbol'] != '₦' && symPlain == '₦') {
        symPlain = parsedInterest['symbol'];
        symLaTeX = _escapeLatex(symPlain);
      }

      int? instalments = instalmentsStr.trim().isNotEmpty ? int.parse(instalmentsStr.replaceAll(RegExp(r'[^\d]'), '')) : null;

      List<PersonalArithmeticStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};

      double tYears = timeUnit == 'Months' ? tRaw / 12 : (timeUnit == 'Weeks' ? tRaw / 52 : tRaw);
      String timeSubLaTeX = timeUnit == 'Months' ? "\\frac{${_fmtMoney(tRaw)}}{12}" : (timeUnit == 'Weeks' ? "\\frac{${_fmtMoney(tRaw)}}{52}" : _fmtMoney(tRaw));
      String timeSubPlain = timeUnit == 'Months' ? "${_fmtMoney(tRaw)}/12" : (timeUnit == 'Weeks' ? "${_fmtMoney(tRaw)}/52" : _fmtMoney(tRaw));

      if (solveMode == 0) {
        // --- FIND INTEREST ---
        if (p <= 0 || r <= 0 || tRaw <= 0) throw const FormatException("Values must be greater than zero.");

        double interest = (p * r * tYears) / 100;

        workings.add("\\text{\\textbf{Method 1: The Formula}}");
        workings.add("\\text{Interest (I)} = \\frac{P \\times R \\times T}{100}");
        workings.add("I = \\frac{${_fmtMoney(p)} \\times ${_fmtMoney(r)} \\times $timeSubLaTeX}{100}");
        workings.add("I = \\text{$symLaTeX}${_fmtMoney(interest)}");
        workings.add("");

        steps.add(PersonalArithmeticStep(
            title: "Method 1: Use the Interest Formula",
            description: "Use the standard formula I = (P × R × T) / 100. Remember that Time (T) must be in years. ${timeUnit == 'Months' ? "Since time is given in months, we divide it by 12." : (timeUnit == 'Weeks' ? "Since time is given in weeks, we divide it by 52." : "")}",
            mathLaTeX: "I = \\frac{${_fmtMoney(p)} \\times ${_fmtMoney(r)} \\times $timeSubLaTeX}{100} = \\text{$symLaTeX}${_fmtMoney(interest)}"
        ));

        workings.add("\\text{\\textbf{Method 2: Step-by-Step (Textbook)}}");
        workings.add("\\text{Interest for 1 year} = ${_fmtMoney(r)}\\% \\text{ of $symLaTeX}${_fmtMoney(p)}");

        double oneYearInterest = (p * r) / 100;
        workings.add("= \\frac{${_fmtMoney(r)}}{100} \\times ${_fmtMoney(p)} = \\text{$symLaTeX}${_fmtMoney(oneYearInterest)}");

        steps.add(PersonalArithmeticStep(
            title: "Method 2: Find Interest for 1 Year First",
            description: "Instead of jumping straight to the formula, the textbook teaches us to first find out how much interest is paid for exactly 1 year. We do this by finding ${_fmtMoney(r)}% of the principal.",
            mathLaTeX: "\\frac{${_fmtMoney(r)}}{100} \\times \\text{$symLaTeX}${_fmtMoney(p)} = \\text{$symLaTeX}${_fmtMoney(oneYearInterest)}"
        ));

        if (tYears != 1.0) {
          workings.add("\\text{Interest for ${_fmtMoney(tRaw)} $timeUnit} = \\text{$symLaTeX}${_fmtMoney(oneYearInterest)} \\times $timeSubLaTeX");
          workings.add("= \\text{$symLaTeX}${_fmtMoney(interest)}");
          workings.add("");

          steps.add(PersonalArithmeticStep(
              title: "Method 2: Multiply by the Time",
              description: "Now that we know the interest for 1 year is $symPlain${_fmtMoney(oneYearInterest)}, we multiply it by the given time ($timeSubPlain years) to get the total interest.",
              mathLaTeX: "\\text{$symLaTeX}${_fmtMoney(oneYearInterest)} \\times $timeSubLaTeX = \\text{$symLaTeX}${_fmtMoney(interest)}"
          ));
        } else {
          workings.add("");
        }

        answers["Simple Interest"] = "$symPlain${_fmtMoney(interest)}";

        double amount = p + interest;
        workings.add("\\text{Total Amount (A)} = P + I");
        workings.add("A = \\text{$symLaTeX}${_fmtMoney(p)} + \\text{$symLaTeX}${_fmtMoney(interest)} = \\text{$symLaTeX}${_fmtMoney(amount)}");

        steps.add(PersonalArithmeticStep(
            title: "Calculate Total Amount to be Paid Back",
            description: "The total amount is the original Principal plus the calculated Simple Interest.",
            mathLaTeX: "\\text{Amount} = \\text{$symLaTeX}${_fmtMoney(p)} + \\text{$symLaTeX}${_fmtMoney(interest)} = \\text{$symLaTeX}${_fmtMoney(amount)}"
        ));

        answers["Total Amount"] = "$symPlain${_fmtMoney(amount)}";

        if (instalments != null && instalments > 0) {
          double monthly = amount / instalments;
          workings.add("");
          workings.add("\\text{Instalment} = \\frac{\\text{Total Amount}}{\\text{Number of Instalments}}");
          workings.add("= \\frac{\\text{$symLaTeX}${_fmtMoney(amount)}}{$instalments} = \\text{$symLaTeX}${_fmtMoney(monthly)}");

          steps.add(PersonalArithmeticStep(
              title: "Calculate Instalments",
              description: "Divide the total amount by the number of instalments to find out how much must be paid each time.",
              mathLaTeX: "\\frac{\\text{$symLaTeX}${_fmtMoney(amount)}}{$instalments} = \\text{$symLaTeX}${_fmtMoney(monthly)}"
          ));
          answers["Payment per Instalment"] = "$symPlain${_fmtMoney(monthly)}";
        }
      } else if (solveMode == 1) {
        // --- FIND RATE ---
        if (p <= 0 || iAmt <= 0 || tRaw <= 0) throw const FormatException();
        double rate = (100 * iAmt) / (p * tYears);

        workings.add("\\text{Rate (R)} = \\frac{100 \\times I}{P \\times T}");
        workings.add("R = \\frac{100 \\times \\text{$symLaTeX}${_fmtMoney(iAmt)}}{\\text{$symLaTeX}${_fmtMoney(p)} \\times $timeSubLaTeX}");
        workings.add("R = ${_fmtMoney(rate)}\\%");

        steps.add(PersonalArithmeticStep(
            title: "Find the Rate (%)",
            description: "Use the transposed formula: R = (100 × I) / (P × T). Multiply the interest by 100, then divide by the principal times the time (in years).",
            mathLaTeX: "R = \\frac{100 \\times ${_fmtMoney(iAmt)}}{${_fmtMoney(p)} \\times $timeSubLaTeX} = ${_fmtMoney(rate)}\\%"
        ));
        answers["Percentage Rate"] = "${_fmtMoney(rate)}%";

      } else if (solveMode == 2) {
        // --- FIND PRINCIPAL ---
        if (r <= 0 || iAmt <= 0 || tRaw <= 0) throw const FormatException();
        double principal = (100 * iAmt) / (r * tYears);

        workings.add("\\text{Principal (P)} = \\frac{100 \\times I}{R \\times T}");
        workings.add("P = \\frac{100 \\times \\text{$symLaTeX}${_fmtMoney(iAmt)}}{${_fmtMoney(r)} \\times $timeSubLaTeX}");
        workings.add("P = \\text{$symLaTeX}${_fmtMoney(principal)}");

        steps.add(PersonalArithmeticStep(
            title: "Find the Principal",
            description: "Use the transposed formula: P = (100 × I) / (R × T).",
            mathLaTeX: "P = \\frac{100 \\times ${_fmtMoney(iAmt)}}{${_fmtMoney(r)} \\times $timeSubLaTeX} = \\text{$symLaTeX}${_fmtMoney(principal)}"
        ));
        answers["Principal"] = "$symPlain${_fmtMoney(principal)}";

      } else if (solveMode == 3) {
        // --- FIND TIME ---
        if (p <= 0 || r <= 0 || iAmt <= 0) throw const FormatException();
        double time = (100 * iAmt) / (p * r);

        workings.add("\\text{Time (T)} = \\frac{100 \\times I}{P \\times R}");
        workings.add("T = \\frac{100 \\times \\text{$symLaTeX}${_fmtMoney(iAmt)}}{\\text{$symLaTeX}${_fmtMoney(p)} \\times ${_fmtMoney(r)}}");
        workings.add("T = ${_fmtMoney(time)} \\text{ Years}");

        steps.add(PersonalArithmeticStep(
            title: "Find the Time",
            description: "Use the transposed formula: T = (100 × I) / (P × R). The result is always in Years.",
            mathLaTeX: "T = \\frac{100 \\times ${_fmtMoney(iAmt)}}{${_fmtMoney(p)} \\times ${_fmtMoney(r)}} = ${_fmtMoney(time)} \\text{ Years}"
        ));
        answers["Time Taken"] = "${_fmtMoney(time)} Years";
      }

      return PersonalArithmeticResult(topic: "Simple Interest", finalAnswers: answers, workingsLaTeX: workings, steps: steps);

    } catch (e) {
      return PersonalArithmeticResult(topic: "Simple Interest", finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Ensure all required inputs are valid numbers.");
    }
  }

  static PersonalArithmeticResult solveIncomeTax({
    required String incomeStr,
    required String childrenStr,
    required String dependentStr,
    required String personalAllowanceStr,
    required String childAllowanceStr,
    required List<TaxBand> taxBands,
  }) {
    try {
      var parsedIncome = _parseCurrency(incomeStr);
      double income = parsedIncome['value'];
      String symPlain = parsedIncome['symbol'];
      String symLaTeX = _escapeLatex(symPlain);

      int children = childrenStr.trim().isEmpty ? 0 : int.parse(childrenStr.replaceAll(RegExp(r'[^\d]'), ''));
      double dependent = dependentStr.trim().isEmpty ? 0 : double.parse(dependentStr.replaceAll(RegExp(r'[^\d\.]'), ''));

      double personalAllowanceRate = personalAllowanceStr.trim().isEmpty ? 0 : double.parse(personalAllowanceStr.replaceAll(RegExp(r'[^\d\.]'), ''));
      double childAllowanceRate = childAllowanceStr.trim().isEmpty ? 0 : double.parse(childAllowanceStr.replaceAll(RegExp(r'[^\d\.]'), ''));

      if (children > 4) children = 4; // Statutory rule: maximum of 4 children

      List<PersonalArithmeticStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};

      // Step 1: Allowances
      double totalChildAllowance = children * childAllowanceRate;
      double totalAllowance = personalAllowanceRate + totalChildAllowance + dependent;

      workings.add("\\text{\\textbf{First: Calculate the tax-free allowances.}}");

      String allowMath = "";
      if (personalAllowanceRate > 0) {
        workings.add("\\text{Personal} = \\text{$symLaTeX}${_fmtMoney(personalAllowanceRate)}");
        allowMath += "\\text{Personal: $symLaTeX}${_fmtMoney(personalAllowanceRate)} \\\\ ";
      }
      if (children > 0 && childAllowanceRate > 0) {
        workings.add("\\text{Child} = $children \\times \\text{$symLaTeX}${_fmtMoney(childAllowanceRate)} = \\text{$symLaTeX}${_fmtMoney(totalChildAllowance)}");
        allowMath += "\\text{Child ($children): $symLaTeX}${_fmtMoney(totalChildAllowance)} \\\\ ";
      }
      if (dependent > 0) {
        workings.add("\\text{Dependent} = \\text{$symLaTeX}${_fmtMoney(dependent)}");
        allowMath += "\\text{Dependent: $symLaTeX}${_fmtMoney(dependent)} \\\\ ";
      }

      if (totalAllowance == 0) {
        workings.add("\\text{Total Allowances} = \\text{$symLaTeX}0");
      } else {
        workings.add("\\text{Total Allowances} = \\text{$symLaTeX}${_fmtMoney(totalAllowance)}");
      }
      workings.add("");

      steps.add(PersonalArithmeticStep(
          title: "First: Find the Allowances",
          description: "Allowances are portions of your income that the government does not tax. We add up all valid allowances (remember, child allowance is capped at 4 children).",
          mathLaTeX: totalAllowance > 0 ? "\\begin{matrix} $allowMath \\hline \\text{Total Allowances = $symLaTeX}${_fmtMoney(totalAllowance)} \\end{matrix}" : "\\text{No Allowances}"
      ));

      answers["Total Allowances"] = "$symPlain${_fmtMoney(totalAllowance)}";

      // Step 2: Taxable Income
      double taxableIncome = income - totalAllowance;
      if (taxableIncome < 0) taxableIncome = 0;

      workings.add("\\text{\\textbf{Second: Calculate the taxable income.}}");
      workings.add("\\text{Taxable Income} = \\text{Total Income} - \\text{Allowances}");
      workings.add("= \\text{$symLaTeX}${_fmtMoney(income)} - \\text{$symLaTeX}${_fmtMoney(totalAllowance)}");
      workings.add("= \\text{$symLaTeX}${_fmtMoney(taxableIncome)}");
      workings.add("");

      steps.add(PersonalArithmeticStep(
          title: "Second: Calculate Taxable Income",
          description: "Subtract the total allowances from the total income. This leaves us with the 'Taxable Income'. This is the actual amount of money we will calculate the tax on.",
          mathLaTeX: "\\text{$symLaTeX}${_fmtMoney(income)} - \\text{$symLaTeX}${_fmtMoney(totalAllowance)} = \\text{$symLaTeX}${_fmtMoney(taxableIncome)}"
      ));

      answers["Taxable Income"] = "$symPlain${_fmtMoney(taxableIncome)}";

      // Step 3: Tax Bands via Ranges
      double remainingToTax = taxableIncome;
      double totalTax = 0;

      workings.add("\\text{\\textbf{Third: Calculate the tax.}}");

      if (remainingToTax <= 0) {
        workings.add("\\text{Taxable income is 0, so no tax is paid.}");
        steps.add(PersonalArithmeticStep(
            title: "Third: Calculate the Tax",
            description: "Because the taxable income is 0 or less, no tax is owed to the government.",
            mathLaTeX: "\\text{Total Tax = $symLaTeX}0"
        ));
      } else {
        for (int i = 0; i < taxBands.length; i++) {
          if (remainingToTax <= 0) break;

          TaxBand band = taxBands[i];

          // Calculate max chunk from range (Upper Limit - Lower Limit)
          double maxChunk = band.upper == null ? double.infinity : (band.upper! - band.lower);
          if (maxChunk <= 0 && band.upper != null) continue; // Skip invalid ranges safely

          double chunk = band.upper == null ? remainingToTax : math.min(remainingToTax, maxChunk);
          double taxForBand = chunk * (band.rate / 100);

          totalTax += taxForBand;
          remainingToTax -= chunk;

          // Plain text descriptions (fixing the LaTeX bleed error)
          String bandStrPlain = band.upper == null
              ? "Over $symPlain${_fmtMoney(band.lower)}"
              : "$symPlain${_fmtMoney(band.lower)} up to $symPlain${_fmtMoney(band.upper!)}";

          String chunkDesc = band.upper == null ? 'everything else' : '$symPlain${_fmtMoney(maxChunk)}';

          workings.add("\\text{Band } ${i+1}: ${_fmtMoney(band.rate)}\\% \\text{ of } \\text{$symLaTeX}${_fmtMoney(chunk)} = \\text{$symLaTeX}${_fmtMoney(taxForBand)}");

          steps.add(PersonalArithmeticStep(
              title: "Tax Band ${i+1} (${_fmtMoney(band.rate)}%)",
              description: "Range: $bandStrPlain.\nWe have $symPlain${_fmtMoney(remainingToTax + chunk)} left to tax. This band can tax a maximum chunk of $chunkDesc. We apply ${_fmtMoney(band.rate)}% to the $symPlain${_fmtMoney(chunk)} that fits in this band.",
              mathLaTeX: "\\frac{${_fmtMoney(band.rate)}}{100} \\times \\text{$symLaTeX}${_fmtMoney(chunk)} = \\text{$symLaTeX}${_fmtMoney(taxForBand)}"
          ));
        }
      }

      workings.add("\\text{Total Tax} = \\text{$symLaTeX}${_fmtMoney(totalTax)}");

      if (totalTax > 0) {
        steps.add(PersonalArithmeticStep(
            title: "Sum the Tax Bands",
            description: "Add up the tax amounts calculated from all the individual tax bands to find the total tax payable.",
            mathLaTeX: "\\text{Total Tax = $symLaTeX}${_fmtMoney(totalTax)}"
        ));
      }

      answers["Total Tax Payable"] = "$symPlain${_fmtMoney(totalTax)}";

      // Step 4: Net Income
      double netIncome = income - totalTax;
      workings.add("");
      workings.add("\\text{\\textbf{Fourth: Calculate Net Income}}");
      workings.add("\\text{Net Income} = \\text{Total Income} - \\text{Total Tax}");
      workings.add("= \\text{$symLaTeX}${_fmtMoney(income)} - \\text{$symLaTeX}${_fmtMoney(totalTax)}");
      workings.add("= \\text{$symLaTeX}${_fmtMoney(netIncome)}");

      steps.add(PersonalArithmeticStep(
          title: "Fourth: Calculate Net Income",
          description: "Net income (or take-home pay) is the amount of money left over after all income tax has been deducted from the total gross income.",
          mathLaTeX: "\\text{$symLaTeX}${_fmtMoney(income)} - \\text{$symLaTeX}${_fmtMoney(totalTax)} = \\text{$symLaTeX}${_fmtMoney(netIncome)}"
      ));

      answers["Net Income (Take-home)"] = "$symPlain${_fmtMoney(netIncome)}";

      return PersonalArithmeticResult(topic: "Income Tax", finalAnswers: answers, workingsLaTeX: workings, steps: steps);

    } catch (e) {
      return PersonalArithmeticResult(topic: "Income Tax", finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Ensure all tax inputs are valid numbers.");
    }
  }
}