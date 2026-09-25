import 'household_arithmetic_models.dart';

class HouseholdLogic {

  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  static String _escapeLatex(String text) {
    return text.replaceAll('\$', '\\\$').replaceAll('%', '\\%').replaceAll('£', '\\text{£}');
  }

  /// Intelligently extracts the currency symbol, value, and whether it's a percentage
  static Map<String, dynamic> _parseInput(String input) {
    String clean = input.trim();
    bool isPct = clean.endsWith('%');
    String sym = '₦'; // Default

    if (isPct) {
      clean = clean.replaceAll('%', '').trim();
      sym = '%';
    } else {
      var match = RegExp(r'^([^\d\.\s]+)').firstMatch(clean);
      if (match != null) {
        sym = match.group(1)!.trim();
      }
    }

    double val = 0.0;
    String numPart = clean.replaceAll(RegExp(r'[^\d\.]'), '');
    if (numPart.isNotEmpty) {
      val = double.parse(numPart);
    }
    return {'symbol': sym, 'value': val, 'isPercentage': isPct};
  }

  static HouseholdResult solveDiscountSale(String originalStr, String discountPctStr) {
    try {
      var orig = _parseInput(originalStr);
      double p = orig['value'];
      String sym = orig['symbol'];
      String symL = _escapeLatex(sym);

      double dPct = double.parse(discountPctStr.replaceAll(RegExp(r'[^\d\.]'), ''));

      if (p <= 0 || dPct < 0 || dPct > 100) throw const FormatException();

      List<HouseholdStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};

      double discountAmt = (dPct / 100) * p;
      double salePrice = p - discountAmt;

      // Method 1
      workings.add("\\text{\\textbf{Method 1: Calculate the Discount First}}");
      workings.add("\\text{Discount} = ${_fmt(dPct)}\\% \\text{ of } \\text{$symL}${_fmt(p)}");
      workings.add("= \\frac{${_fmt(dPct)}}{100} \\times \\text{$symL}${_fmt(p)} = \\text{$symL}${_fmt(discountAmt)}");

      steps.add(HouseholdStep(
          title: "Method 1: Find the Discount Amount",
          description: "First, find out exactly how much money is being taken off the price. We do this by calculating ${_fmt(dPct)}% of the original price.",
          mathLaTeX: "\\frac{${_fmt(dPct)}}{100} \\times \\text{$symL}${_fmt(p)} = \\text{$symL}${_fmt(discountAmt)}"
      ));

      workings.add("\\text{Sale Price} = \\text{$symL}${_fmt(p)} - \\text{$symL}${_fmt(discountAmt)} = \\text{$symL}${_fmt(salePrice)}");
      workings.add("");

      steps.add(HouseholdStep(
          title: "Method 1: Subtract from Original Price",
          description: "Now subtract the discount amount from the original price to find the final cash price.",
          mathLaTeX: "\\text{$symL}${_fmt(p)} - \\text{$symL}${_fmt(discountAmt)} = \\text{$symL}${_fmt(salePrice)}"
      ));

      // Method 2
      double remainingPct = 100 - dPct;
      workings.add("\\text{\\textbf{Method 2: Calculate the Payable Percentage}}");
      workings.add("\\text{Percentage to Pay} = 100\\% - ${_fmt(dPct)}\\% = ${_fmt(remainingPct)}\\%");
      workings.add("\\text{Sale Price} = ${_fmt(remainingPct)}\\% \\text{ of } \\text{$symL}${_fmt(p)}");
      workings.add("= \\frac{${_fmt(remainingPct)}}{100} \\times \\text{$symL}${_fmt(p)} = \\text{$symL}${_fmt(salePrice)}");

      steps.add(HouseholdStep(
          title: "Method 2: Use the Payable Percentage",
          description: "If you get a ${_fmt(dPct)}% discount, it means you only have to pay the remaining ${_fmt(remainingPct)}%. You can multiply the original price directly by this remaining percentage!",
          mathLaTeX: "\\frac{${_fmt(remainingPct)}}{100} \\times \\text{$symL}${_fmt(p)} = \\text{$symL}${_fmt(salePrice)}"
      ));

      answers["Discount Amount"] = "$sym${_fmt(discountAmt)}";
      answers["Final Sale Price"] = "$sym${_fmt(salePrice)}";

      return HouseholdResult(topic: 'Discount', subTopic: 'Sale Price', finalAnswers: answers, workingsLaTeX: workings, steps: steps);
    } catch (e) {
      return HouseholdResult(topic: 'Discount', subTopic: 'Sale Price', finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Ensure price and discount percentage are valid numbers.");
    }
  }

  static HouseholdResult solveDiscountPct(String originalStr, String saleStr) {
    try {
      var orig = _parseInput(originalStr);
      var sale = _parseInput(saleStr);

      double o = orig['value'];
      double s = sale['value'];
      String sym = orig['symbol'];
      String symL = _escapeLatex(sym);

      if (o <= 0 || s < 0 || s > o) throw const FormatException("Sale price must be less than original.");

      List<HouseholdStep> steps = [];
      List<String> workings = [];

      double diff = o - s;
      workings.add("\\text{Discount Amount} = \\text{$symL}${_fmt(o)} - \\text{$symL}${_fmt(s)} = \\text{$symL}${_fmt(diff)}");
      steps.add(HouseholdStep(
          title: "Step 1: Find the Discount Amount",
          description: "Subtract the final sale price from the original price to see how much money was saved.",
          mathLaTeX: "\\text{$symL}${_fmt(o)} - \\text{$symL}${_fmt(s)} = \\text{$symL}${_fmt(diff)}"
      ));

      double pct = (diff / o) * 100;
      workings.add("\\text{Discount \\%} = \\frac{\\text{Discount}}{\\text{Original Price}} \\times 100\\%");
      workings.add("= \\frac{\\text{$symL}${_fmt(diff)}}{\\text{$symL}${_fmt(o)}} \\times 100\\%");
      workings.add("= ${_fmt(pct)}\\%");

      steps.add(HouseholdStep(
          title: "Step 2: Express as a Percentage",
          description: "To find the percentage, write the discount amount as a fraction of the ORIGINAL price, then multiply by 100.",
          mathLaTeX: "\\frac{${_fmt(diff)}}{${_fmt(o)}} \\times 100\\% = ${_fmt(pct)}\\%"
      ));

      return HouseholdResult(
          topic: 'Discount', subTopic: 'Find Percentage',
          finalAnswers: {"Money Saved": "$sym${_fmt(diff)}", "Discount Percentage": "${_fmt(pct)}%"},
          workingsLaTeX: workings, steps: steps
      );
    } catch (e) {
      return HouseholdResult(topic: 'Discount', subTopic: '', finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Ensure original price is greater than sale price.");
    }
  }

  static HouseholdResult solveBulkSavings(String unitStr, String bulkStr, String bulkQtyStr, String targetQtyStr) {
    try {
      var unit = _parseInput(unitStr);
      var bulk = _parseInput(bulkStr);
      double uPrice = unit['value'];
      double bPrice = bulk['value'];
      String sym = unit['symbol'];
      String symL = _escapeLatex(sym);

      double bQty = double.parse(bulkQtyStr.replaceAll(RegExp(r'[^\d\.]'), ''));
      double tQty = double.parse(targetQtyStr.replaceAll(RegExp(r'[^\d\.]'), ''));

      if (bQty <= 0 || tQty <= 0 || uPrice <= 0 || bPrice <= 0) throw const FormatException();

      List<HouseholdStep> steps = [];
      List<String> workings = [];

      double normalCost = tQty * uPrice;
      workings.add("\\text{Cost buying separately} = ${_fmt(tQty)} \\times \\text{$symL}${_fmt(uPrice)} = \\text{$symL}${_fmt(normalCost)}");
      steps.add(HouseholdStep(
          title: "Step 1: Calculate Normal Cost",
          description: "First, find out how much it would cost to buy the target quantity (${_fmt(tQty)}) one by one at the individual unit price.",
          mathLaTeX: "${_fmt(tQty)} \\times \\text{$symL}${_fmt(uPrice)} = \\text{$symL}${_fmt(normalCost)}"
      ));

      double packsNeeded = tQty / bQty;
      double bulkCost = packsNeeded * bPrice;

      workings.add("\\text{Bulk packs needed} = \\frac{${_fmt(tQty)}}{${_fmt(bQty)}} = ${_fmt(packsNeeded)} \\text{ packs}");
      workings.add("\\text{Cost buying in bulk} = ${_fmt(packsNeeded)} \\times \\text{$symL}${_fmt(bPrice)} = \\text{$symL}${_fmt(bulkCost)}");

      steps.add(HouseholdStep(
          title: "Step 2: Calculate Bulk Cost",
          description: "Find out how many bulk packs are needed to get ${_fmt(tQty)} items, then multiply by the bulk price.",
          mathLaTeX: "${_fmt(packsNeeded)} \\times \\text{$symL}${_fmt(bPrice)} = \\text{$symL}${_fmt(bulkCost)}"
      ));

      double savings = normalCost - bulkCost;
      workings.add("\\text{Total Savings} = \\text{$symL}${_fmt(normalCost)} - \\text{$symL}${_fmt(bulkCost)} = \\text{$symL}${_fmt(savings)}");

      steps.add(HouseholdStep(
          title: "Step 3: Calculate Savings",
          description: "Subtract the cheaper bulk cost from the expensive normal cost to find the total savings.",
          mathLaTeX: "\\text{$symL}${_fmt(normalCost)} - \\text{$symL}${_fmt(bulkCost)} = \\text{$symL}${_fmt(savings)}"
      ));

      return HouseholdResult(
          topic: 'Discount', subTopic: 'Bulk Savings',
          finalAnswers: {"Cost Separately": "$sym${_fmt(normalCost)}", "Cost in Bulk": "$sym${_fmt(bulkCost)}", "Total Savings": "$sym${_fmt(savings)}"},
          workingsLaTeX: workings, steps: steps
      );
    } catch (e) {
      return HouseholdResult(topic: 'Discount', subTopic: '', finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Ensure all fields are valid numbers.");
    }
  }

  static HouseholdResult solveInstalmentTotal(String cashStr, String depositStr, String instAmtStr, String numInstStr) {
    try {
      var cash = _parseInput(cashStr);
      var dep = _parseInput(depositStr);
      var instAmt = _parseInput(instAmtStr);

      double cPrice = cash['value'];
      String sym = cash['symbol'];
      String symL = _escapeLatex(sym);

      double depVal = dep['value'];
      bool depIsPct = dep['isPercentage'];
      double iAmt = instAmt['value'];
      double nInst = double.parse(numInstStr.replaceAll(RegExp(r'[^\d\.]'), ''));

      List<HouseholdStep> steps = [];
      List<String> workings = [];

      double depositCalculated = depVal;
      if (depIsPct) {
        depositCalculated = (depVal / 100) * cPrice;
        workings.add("\\text{Deposit Amount} = ${_fmt(depVal)}\\% \\text{ of } \\text{$symL}${_fmt(cPrice)}");
        workings.add("= \\frac{${_fmt(depVal)}}{100} \\times \\text{$symL}${_fmt(cPrice)} = \\text{$symL}${_fmt(depositCalculated)}");

        steps.add(HouseholdStep(
            title: "Step 1: Calculate the Deposit",
            description: "Since the deposit is given as a percentage, we calculate ${_fmt(depVal)}% of the cash price first.",
            mathLaTeX: "\\frac{${_fmt(depVal)}}{100} \\times \\text{$symL}${_fmt(cPrice)} = \\text{$symL}${_fmt(depositCalculated)}"
        ));
      } else {
        workings.add("\\text{Deposit Amount} = \\text{$symL}${_fmt(depositCalculated)}");
        steps.add(HouseholdStep(title: "Step 1: State the Deposit", description: "The initial deposit paid is $sym${_fmt(depositCalculated)}.", mathLaTeX: "\\text{Deposit} = \\text{$symL}${_fmt(depositCalculated)}"));
      }

      double totalInstalments = nInst * iAmt;
      workings.add("\\text{Total Instalments} = ${_fmt(nInst)} \\times \\text{$symL}${_fmt(iAmt)} = \\text{$symL}${_fmt(totalInstalments)}");
      steps.add(HouseholdStep(
          title: "Step 2: Total the Instalment Payments",
          description: "Multiply the number of payments by the amount paid each time.",
          mathLaTeX: "${_fmt(nInst)} \\times \\text{$symL}${_fmt(iAmt)} = \\text{$symL}${_fmt(totalInstalments)}"
      ));

      double hpPrice = depositCalculated + totalInstalments;
      workings.add("\\text{Hire Purchase Price} = \\text{Deposit} + \\text{Total Instalments}");
      workings.add("= \\text{$symL}${_fmt(depositCalculated)} + \\text{$symL}${_fmt(totalInstalments)} = \\text{$symL}${_fmt(hpPrice)}");
      steps.add(HouseholdStep(
          title: "Step 3: Find Total Hire Purchase Price",
          description: "Add the deposit to the total instalments to find the absolute total cost of buying the item on credit.",
          mathLaTeX: "\\text{$symL}${_fmt(depositCalculated)} + \\text{$symL}${_fmt(totalInstalments)} = \\text{$symL}${_fmt(hpPrice)}"
      ));

      double diff = hpPrice - cPrice;
      workings.add("\\text{Price Difference (Extra Cost)} = \\text{HP Price} - \\text{Cash Price}");
      workings.add("= \\text{$symL}${_fmt(hpPrice)} - \\text{$symL}${_fmt(cPrice)} = \\text{$symL}${_fmt(diff)}");
      steps.add(HouseholdStep(
          title: "Step 4: Calculate the Price Difference",
          description: "Subtract the original cash price from the Hire Purchase price to see exactly how much extra you are paying for the convenience of instalments.",
          mathLaTeX: "\\text{$symL}${_fmt(hpPrice)} - \\text{$symL}${_fmt(cPrice)} = \\text{$symL}${_fmt(diff)}"
      ));

      return HouseholdResult(
          topic: 'Instalment', subTopic: 'Find Total HP',
          finalAnswers: {"Hire Purchase Price": "$sym${_fmt(hpPrice)}", "Extra Cost (Difference)": "$sym${_fmt(diff)}"},
          workingsLaTeX: workings, steps: steps
      );

    } catch (e) {
      return HouseholdResult(topic: '', subTopic: '', finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Ensure all fields are valid numbers.");
    }
  }

  static HouseholdResult solveInstalmentFindAmt(String hpPriceStr, String depositStr, String numInstStr) {
    try {
      var hp = _parseInput(hpPriceStr);
      var dep = _parseInput(depositStr);

      double hpPrice = hp['value'];
      String sym = hp['symbol'];
      String symL = _escapeLatex(sym);

      double depVal = dep['value'];
      bool depIsPct = dep['isPercentage'];
      double nInst = double.parse(numInstStr.replaceAll(RegExp(r'[^\d\.]'), ''));

      List<HouseholdStep> steps = [];
      List<String> workings = [];

      double depositCalculated = depVal;
      if (depIsPct) {
        depositCalculated = (depVal / 100) * hpPrice; // Usually deposit % is on the HP or Cash. Assuming HP if Cash not given.
        workings.add("\\text{Deposit} = ${_fmt(depVal)}\\% \\text{ of } \\text{$symL}${_fmt(hpPrice)} = \\text{$symL}${_fmt(depositCalculated)}");
      }

      double remainder = hpPrice - depositCalculated;
      workings.add("\\text{Remainder to be paid} = \\text{Total HP Price} - \\text{Deposit}");
      workings.add("= \\text{$symL}${_fmt(hpPrice)} - \\text{$symL}${_fmt(depositCalculated)} = \\text{$symL}${_fmt(remainder)}");

      steps.add(HouseholdStep(
          title: "Step 1: Find the Remaining Balance",
          description: "Subtract the deposit paid from the total Hire Purchase price to see how much money is left to spread across the instalments.",
          mathLaTeX: "\\text{$symL}${_fmt(hpPrice)} - \\text{$symL}${_fmt(depositCalculated)} = \\text{$symL}${_fmt(remainder)}"
      ));

      double iAmt = remainder / nInst;
      workings.add("\\text{Monthly Instalment} = \\frac{\\text{Remainder}}{\\text{Number of Instalments}}");
      workings.add("= \\frac{\\text{$symL}${_fmt(remainder)}}{${_fmt(nInst)}} = \\text{$symL}${_fmt(iAmt)}");

      steps.add(HouseholdStep(
          title: "Step 2: Calculate Instalment Amount",
          description: "Divide the remaining balance by the number of instalments to find the payment required for each period.",
          mathLaTeX: "\\frac{\\text{$symL}${_fmt(remainder)}}{${_fmt(nInst)}} = \\text{$symL}${_fmt(iAmt)}"
      ));

      return HouseholdResult(
          topic: 'Instalment', subTopic: 'Find Instalment Amount',
          finalAnswers: {"Amount per Instalment": "$sym${_fmt(iAmt)}"},
          workingsLaTeX: workings, steps: steps
      );

    } catch (e) {
      return HouseholdResult(topic: '', subTopic: '', finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Ensure inputs are valid.");
    }
  }
}