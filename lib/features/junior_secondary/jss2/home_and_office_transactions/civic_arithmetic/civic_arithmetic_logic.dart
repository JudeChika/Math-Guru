import 'civic_arithmetic_models.dart';

class CivicLogic {

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

  static CivicResult solveVAT({
    required String amountStr,
    required String vatRateStr,
    required bool isExtraction,
  }) {
    try {
      var parsedAmt = _parseCurrency(amountStr);
      double amount = parsedAmt['value'];
      String sym = parsedAmt['symbol'];
      String symL = _escapeLatex(sym);

      double rate = double.parse(vatRateStr.replaceAll(RegExp(r'[^\d\.]'), ''));

      if (amount <= 0 || rate < 0) throw const FormatException();

      List<CivicStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};

      double totalPct = 100 + rate;

      if (!isExtraction) {
        // --- ADD VAT TO PRICE (Example 7) ---
        double vatAmt = (rate / 100) * amount;
        double finalPrice = amount + vatAmt;

        workings.add("\\text{\\textbf{Method: The Multiplier}}");
        workings.add("\\text{Total Percentage} = 100\\% + ${_fmtMoney(rate)}\\% = ${_fmtMoney(totalPct)}\\%");
        steps.add(CivicStep(
            title: "Step 1: Find the Total Percentage",
            description: "The original price represents 100%. Adding a VAT of ${_fmtMoney(rate)}% means the final price will be ${_fmtMoney(totalPct)}% of the original amount.",
            mathLaTeX: "100\\% + ${_fmtMoney(rate)}\\% = ${_fmtMoney(totalPct)}\\%"
        ));

        workings.add("\\text{Amount Paid} = ${_fmtMoney(totalPct)}\\% \\text{ of } \\text{$symL}${_fmtMoney(amount)}");
        workings.add("= \\frac{${_fmtMoney(totalPct)}}{100} \\times \\text{$symL}${_fmtMoney(amount)} = \\text{$symL}${_fmtMoney(finalPrice)}");

        steps.add(CivicStep(
            title: "Step 2: Calculate the Final Amount",
            description: "Multiply the original price by the total percentage fraction.",
            mathLaTeX: "\\frac{${_fmtMoney(totalPct)}}{100} \\times \\text{$symL}${_fmtMoney(amount)} = \\text{$symL}${_fmtMoney(finalPrice)}"
        ));

        workings.add("");
        workings.add("\\text{VAT Amount} = \\text{$symL}${_fmtMoney(finalPrice)} - \\text{$symL}${_fmtMoney(amount)} = \\text{$symL}${_fmtMoney(vatAmt)}");

        answers["Original Price"] = "$sym${_fmtMoney(amount)}";
        answers["VAT Charged"] = "$sym${_fmtMoney(vatAmt)}";
        answers["Total Amount to Pay"] = "$sym${_fmtMoney(finalPrice)}";

      } else {
        // --- EXTRACT VAT FROM TOTAL (Example 8) ---
        workings.add("\\text{\\textbf{Method: Unitary Extraction}}");
        workings.add("\\text{Since the bill includes VAT, it represents } 100\\% + ${_fmtMoney(rate)}\\% = ${_fmtMoney(totalPct)}\\%");

        steps.add(CivicStep(
            title: "Step 1: Understand the Total",
            description: "Because the total bill *already* includes the ${_fmtMoney(rate)}% VAT, the given amount ($sym${_fmtMoney(amount)}) actually represents ${_fmtMoney(totalPct)}% of the original cost.",
            mathLaTeX: "100\\% + ${_fmtMoney(rate)}\\% = ${_fmtMoney(totalPct)}\\%"
        ));

        workings.add("${_fmtMoney(totalPct)}\\% \\text{ of actual bill} = \\text{$symL}${_fmtMoney(amount)}");

        double onePct = amount / totalPct;
        workings.add("1\\% \\text{ of actual bill} = \\frac{\\text{$symL}${_fmtMoney(amount)}}{${_fmtMoney(totalPct)}} = \\text{$symL}${_fmtMoney(onePct)}");

        steps.add(CivicStep(
            title: "Step 2: Find 1% (Unitary Method)",
            description: "Divide the total bill by ${_fmtMoney(totalPct)} to find out exactly how much money 1% represents.",
            mathLaTeX: "1\\% = \\frac{\\text{$symL}${_fmtMoney(amount)}}{${_fmtMoney(totalPct)}} = \\text{$symL}${_fmtMoney(onePct)}"
        ));

        double vatAmt = onePct * rate;
        workings.add("${_fmtMoney(rate)}\\% \\text{ (VAT amount)} = \\text{$symL}${_fmtMoney(onePct)} \\times ${_fmtMoney(rate)} = \\text{$symL}${_fmtMoney(vatAmt)}");

        steps.add(CivicStep(
            title: "Step 3: Calculate the VAT",
            description: "Multiply the 1% value by the VAT rate (${_fmtMoney(rate)}) to find the exact amount of money that goes to the government.",
            mathLaTeX: "\\text{VAT} = \\text{$symL}${_fmtMoney(onePct)} \\times ${_fmtMoney(rate)} = \\text{$symL}${_fmtMoney(vatAmt)}"
        ));

        double originalCost = amount - vatAmt;
        workings.add("\\text{Original Bill} = \\text{$symL}${_fmtMoney(amount)} - \\text{$symL}${_fmtMoney(vatAmt)} = \\text{$symL}${_fmtMoney(originalCost)}");

        answers["Total Paid (Incl. VAT)"] = "$sym${_fmtMoney(amount)}";
        answers["Original Price (Pre-tax)"] = "$sym${_fmtMoney(originalCost)}";
        answers["Government Receives (VAT)"] = "$sym${_fmtMoney(vatAmt)}";
      }

      return CivicResult(topic: 'VAT', finalAnswers: answers, workingsLaTeX: workings, steps: steps);

    } catch (e) {
      return CivicResult(topic: 'VAT', finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Ensure inputs are valid numbers.");
    }
  }

  static CivicResult solveUtilityBill({
    required String prevStr,
    required String currStr,
    required String unitsStr,
    required String rateStr,
    required String chargeStr,
    required String periodsStr,
    required String vatRateStr,
  }) {
    try {
      var rateData = _parseCurrency(rateStr);
      String sym = rateData['symbol'];
      String symL = _escapeLatex(sym);
      double rate = rateData['value'];

      double charge = _parseCurrency(chargeStr)['value'];

      double prev = double.tryParse(prevStr.replaceAll(RegExp(r'[^\d\.]'), '')) ?? 0;
      double curr = double.tryParse(currStr.replaceAll(RegExp(r'[^\d\.]'), '')) ?? 0;
      double directUnits = double.tryParse(unitsStr.replaceAll(RegExp(r'[^\d\.]'), '')) ?? 0;

      double periods = double.tryParse(periodsStr.replaceAll(RegExp(r'[^\d\.]'), '')) ?? 1;
      double vatRate = double.tryParse(vatRateStr.replaceAll(RegExp(r'[^\d\.]'), '')) ?? 0;

      double unitsUsed = directUnits > 0 ? directUnits : (curr > prev ? curr - prev : 0);
      if (unitsUsed <= 0) throw const FormatException("Invalid units.");

      List<CivicStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};

      // 1. Meter Reading Difference
      if (directUnits <= 0 && curr > prev) {
        workings.add("\\text{Units Used} = ${_fmtMoney(curr)} - ${_fmtMoney(prev)} = ${_fmtMoney(unitsUsed)}");
        steps.add(CivicStep(
            title: "Step 1: Calculate Units Used",
            description: "Subtract the previous meter reading from the current meter reading.",
            mathLaTeX: "${_fmtMoney(curr)} - ${_fmtMoney(prev)} = ${_fmtMoney(unitsUsed)}"
        ));
      } else {
        workings.add("\\text{Units Used} = ${_fmtMoney(unitsUsed)} \\text{ units}");
      }

      // 2. Cost of Units
      double usageCost = unitsUsed * rate;
      workings.add("\\text{Cost of Units} = ${_fmtMoney(unitsUsed)} \\times \\text{$symL}${_fmtMoney(rate)} = \\text{$symL}${_fmtMoney(usageCost)}");
      steps.add(CivicStep(
          title: "Step 2: Calculate Usage Cost",
          description: "Multiply the total units used by the cost per unit.",
          mathLaTeX: "${_fmtMoney(unitsUsed)} \\times \\text{$symL}${_fmtMoney(rate)} = \\text{$symL}${_fmtMoney(usageCost)}"
      ));

      // 3. Standing Charge
      double totalCharge = charge * periods;
      if (periods > 1) {
        workings.add("\\text{Total Standing Charge} = \\text{$symL}${_fmtMoney(charge)} \\times ${_fmtMoney(periods)} \\text{ periods} = \\text{$symL}${_fmtMoney(totalCharge)}");
        steps.add(CivicStep(
            title: "Step 3: Calculate Standing Charge",
            description: "Since the bill covers ${_fmtMoney(periods)} periods (e.g. 3 months in a quarter), multiply the single standing charge by ${_fmtMoney(periods)}.",
            mathLaTeX: "\\text{$symL}${_fmtMoney(charge)} \\times ${_fmtMoney(periods)} = \\text{$symL}${_fmtMoney(totalCharge)}"
        ));
      } else {
        workings.add("\\text{Standing Charge} = \\text{$symL}${_fmtMoney(totalCharge)}");
      }

      // 4. Subtotal
      double subtotal = usageCost + totalCharge;
      workings.add("\\text{Total Bill (Before VAT)} = \\text{$symL}${_fmtMoney(usageCost)} + \\text{$symL}${_fmtMoney(totalCharge)} = \\text{$symL}${_fmtMoney(subtotal)}");
      steps.add(CivicStep(
          title: "Step ${periods > 1 ? '4' : '3'}: Find Subtotal",
          description: "Add the usage cost and the standing charge together.",
          mathLaTeX: "\\text{$symL}${_fmtMoney(usageCost)} + \\text{$symL}${_fmtMoney(totalCharge)} = \\text{$symL}${_fmtMoney(subtotal)}"
      ));

      answers["Units Used"] = "${_fmtMoney(unitsUsed)} units";
      answers["Subtotal"] = "$sym${_fmtMoney(subtotal)}";

      // 5. VAT
      double finalTotal = subtotal;
      if (vatRate > 0) {
        double vatAmt = (vatRate / 100) * subtotal;
        finalTotal += vatAmt;
        workings.add("\\text{VAT (}${_fmtMoney(vatRate)}\\%\\text{)} = \\frac{${_fmtMoney(vatRate)}}{100} \\times \\text{$symL}${_fmtMoney(subtotal)} = \\text{$symL}${_fmtMoney(vatAmt)}");
        workings.add("\\text{Final Bill} = \\text{$symL}${_fmtMoney(subtotal)} + \\text{$symL}${_fmtMoney(vatAmt)} = \\text{$symL}${_fmtMoney(finalTotal)}");

        steps.add(CivicStep(
            title: "Final Step: Add VAT",
            description: "Calculate ${_fmtMoney(vatRate)}% of the subtotal and add it to find the absolute final bill.",
            mathLaTeX: "\\text{$symL}${_fmtMoney(subtotal)} + \\text{$symL}${_fmtMoney(vatAmt)} = \\text{$symL}${_fmtMoney(finalTotal)}"
        ));
        answers["VAT Applied"] = "$sym${_fmtMoney(vatAmt)}";
      }

      answers["Final Total Bill"] = "$sym${_fmtMoney(finalTotal)}";

      return CivicResult(topic: 'Utility Bills', finalAnswers: answers, workingsLaTeX: workings, steps: steps);

    } catch (e) {
      return CivicResult(topic: '', finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Ensure rates and units are valid numbers.");
    }
  }

  static CivicResult solveCompositeBill({
    required List<BillItem> items,
    required String chargeStr,
    required String vatRateStr,
    required String currencySymbol,
  }) {
    try {
      if (items.isEmpty) throw const FormatException("No items added.");

      String sym = currencySymbol.trim().isEmpty ? '₦' : currencySymbol.trim();
      String symL = _escapeLatex(sym);

      double charge = double.tryParse(chargeStr.replaceAll(RegExp(r'[^\d\.]'), '')) ?? 0;
      double vatRate = double.tryParse(vatRateStr.replaceAll(RegExp(r'[^\d\.]'), '')) ?? 0;

      List<CivicStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};

      double subtotal = 0;

      workings.add("\\text{\\textbf{Itemized Breakdown:}}");
      for (var item in items) {
        double cost = item.quantity * item.unitPrice;
        subtotal += cost;
        workings.add("\\text{${item.name}: } ${_fmtMoney(item.quantity)} \\times \\text{$symL}${_fmtMoney(item.unitPrice)} = \\text{$symL}${_fmtMoney(cost)}");
      }

      steps.add(CivicStep(
          title: "Step 1: Calculate Item Costs",
          description: "Multiply the quantity of each item by its unit price.",
          mathLaTeX: "\\text{Sum of items} = \\text{$symL}${_fmtMoney(subtotal)}"
      ));

      if (charge > 0) {
        workings.add("");
        workings.add("\\text{Standing / Service Charge: } \\text{$symL}${_fmtMoney(charge)}");
        subtotal += charge;
        steps.add(CivicStep(
            title: "Step 2: Add Fixed Charges",
            description: "Add the mandatory fixed/standing charge to the item subtotal.",
            mathLaTeX: "\\text{New Subtotal} = \\text{$symL}${_fmtMoney(subtotal)}"
        ));
      }

      workings.add("\\text{Total Before VAT} = \\text{$symL}${_fmtMoney(subtotal)}");
      answers["Total Before VAT"] = "$sym${_fmtMoney(subtotal)}";

      double finalTotal = subtotal;
      if (vatRate > 0) {
        workings.add("");
        double vatAmt = (vatRate / 100) * subtotal;
        finalTotal += vatAmt;
        workings.add("\\text{VAT (}${_fmtMoney(vatRate)}\\%\\text{)} = \\frac{${_fmtMoney(vatRate)}}{100} \\times \\text{$symL}${_fmtMoney(subtotal)} = \\text{$symL}${_fmtMoney(vatAmt)}");
        workings.add("\\text{Final Bill} = \\text{$symL}${_fmtMoney(subtotal)} + \\text{$symL}${_fmtMoney(vatAmt)} = \\text{$symL}${_fmtMoney(finalTotal)}");

        steps.add(CivicStep(
            title: "Final Step: Add VAT",
            description: "Calculate ${_fmtMoney(vatRate)}% of the subtotal and add it to find the absolute final bill.",
            mathLaTeX: "\\text{$symL}${_fmtMoney(subtotal)} + \\text{$symL}${_fmtMoney(vatAmt)} = \\text{$symL}${_fmtMoney(finalTotal)}"
        ));
        answers["VAT Amount"] = "$sym${_fmtMoney(vatAmt)}";
      }

      answers["Final Total Bill"] = "$sym${_fmtMoney(finalTotal)}";

      return CivicResult(topic: 'Composite Bills', finalAnswers: answers, workingsLaTeX: workings, steps: steps);

    } catch (e) {
      return CivicResult(topic: '', finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Ensure all fields are valid numbers.");
    }
  }
}