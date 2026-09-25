import 'commercial_transactions_model.dart';

class CommercialLogic {

  /// Formats decimals to drop trailing .0 and adds commas for thousands
  static String _fmt(double v) {
    String str;
    if (v == v.toInt()) {
      str = v.toInt().toString();
    } else {
      str = v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    }

    // Split into integer and decimal parts
    List<String> parts = str.split('.');
    // Regular expression to add commas every 3 digits
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    parts[0] = parts[0].replaceAllMapped(reg, (Match match) => '${match[1]},');

    return parts.join('.');
  }

  /// Extracts the currency symbol securely
  static Map<String, dynamic> _parseCurrency(String input) {
    String clean = input.trim();
    String sym = '₦'; // Default

    var match = RegExp(r'^([^\d.\s]+)').firstMatch(clean);
    if (match != null) {
      sym = match.group(1)!.trim();
      if (sym.toLowerCase() == 'n' || sym.toLowerCase() == 'naira') sym = '₦';
    }

    double val = 0.0;
    String numPart = clean.replaceAll(RegExp(r'[^\d.]'), '');
    if (numPart.isNotEmpty) {
      val = double.parse(numPart);
    }
    return {'symbol': sym, 'value': val};
  }

  static String _escapeLatex(String text) {
    return text.replaceAll('\$', '\\\$').replaceAll('%', '\\%').replaceAll('£', '\\text{£}');
  }

  // ==========================================
  // PROFIT & LOSS ENGINE
  // ==========================================
  static CommercialResult solveProfitLoss({
    required String cpStr,
    required String spStr,
    required String pctStr,
    required bool isProfitPct, // Defines if the provided percentage is Profit or Loss
  }) {
    try {
      var cpData = _parseCurrency(cpStr);
      var spData = _parseCurrency(spStr);

      double cp = cpData['value'];
      double sp = spData['value'];
      double pct = double.tryParse(pctStr.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;

      String sym = cp > 0 ? cpData['symbol'] : (sp > 0 ? spData['symbol'] : '₦');
      String symL = _escapeLatex(sym);

      List<CommercialStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};

      int givenCount = (cp > 0 ? 1 : 0) + (sp > 0 ? 1 : 0) + (pct > 0 ? 1 : 0);
      if (givenCount < 2) throw const FormatException("Provide at least 2 values.");

      // SCENARIO 1: Given CP and SP (Find Actual & %)
      if (cp > 0 && sp > 0) {
        double diff = sp - cp;
        bool isProfit = diff >= 0;
        double amt = diff.abs();

        String typeStr = isProfit ? "Profit" : "Loss";
        String math1 = isProfit ? "\\text{$symL}${_fmt(sp)} - \\text{$symL}${_fmt(cp)}" : "\\text{$symL}${_fmt(cp)} - \\text{$symL}${_fmt(sp)}";

        workings.add("\\text{Actual $typeStr} = $math1 = \\text{$symL}${_fmt(amt)}");
        steps.add(CommercialStep(
            title: "Step 1: Calculate Actual $typeStr",
            description: isProfit
                ? "To find out if we made a profit or loss, we compare the Cost Price (how much we bought it for) with the Selling Price (how much we sold it for). Since the Selling Price ($sym${_fmt(sp)}) is GREATER than the Cost Price ($sym${_fmt(cp)}), we made a profit! We subtract the smaller number from the bigger number to find the exact amount."
                : "To find out if we made a profit or loss, we compare the Cost Price with the Selling Price. Since the Cost Price ($sym${_fmt(cp)}) is GREATER than the Selling Price ($sym${_fmt(sp)}), we made a loss. We subtract the selling price from the cost price to see exactly how much money was lost.",
            mathLaTeX: "\\text{Actual $typeStr} = \\text{$symL}${_fmt(amt)}"
        ));
        answers["Actual $typeStr"] = "$sym${_fmt(amt)}";

        double calcPct = (amt / cp) * 100;
        workings.add("\\text{Percentage $typeStr} = \\frac{\\text{$typeStr}}{\\text{Cost Price}} \\times 100\\%");
        workings.add("= \\frac{\\text{$symL}${_fmt(amt)}}{\\text{$symL}${_fmt(cp)}} \\times 100\\% = ${_fmt(calcPct)}\\%");

        steps.add(CommercialStep(
            title: "Step 2: Calculate Percentage $typeStr",
            description: "A very important rule in business mathematics is that Percentage Profit or Loss is ALWAYS calculated based on the original Cost Price, never the selling price. We write the actual $typeStr as a fraction over the Cost Price, and multiply by 100 to convert it into a percentage.",
            mathLaTeX: "\\frac{\\text{$symL}${_fmt(amt)}}{\\text{$symL}${_fmt(cp)}} \\times 100\\% = ${_fmt(calcPct)}\\%"
        ));
        answers["Percentage $typeStr"] = "${_fmt(calcPct)}%";
      }
      // SCENARIO 2: Given CP and % (Find SP & Actual)
      else if (cp > 0 && pct > 0) {
        String typeStr = isProfitPct ? "Profit" : "Loss";
        double amt = (pct / 100) * cp;

        workings.add("\\text{Actual $typeStr} = ${_fmt(pct)}\\% \\text{ of } \\text{$symL}${_fmt(cp)}");
        workings.add("= \\frac{${_fmt(pct)}}{100} \\times \\text{$symL}${_fmt(cp)} = \\text{$symL}${_fmt(amt)}");

        steps.add(CommercialStep(
            title: "Step 1: Find the Actual $typeStr Amount",
            description: "We are given the percentage rate (${_fmt(pct)}%). To find out exactly how much money that represents, we calculate ${_fmt(pct)}% of the original Cost Price ($sym${_fmt(cp)}). We do this by changing the percentage to a fraction (over 100) and multiplying.",
            mathLaTeX: "\\frac{${_fmt(pct)}}{100} \\times \\text{$symL}${_fmt(cp)} = \\text{$symL}${_fmt(amt)}"
        ));
        answers["Actual $typeStr"] = "$sym${_fmt(amt)}";

        double calcSp = isProfitPct ? cp + amt : cp - amt;
        String sign = isProfitPct ? "+" : "-";

        workings.add("\\text{Selling Price} = \\text{Cost Price} $sign \\text{$typeStr}");
        workings.add("= \\text{$symL}${_fmt(cp)} $sign \\text{$symL}${_fmt(amt)} = \\text{$symL}${_fmt(calcSp)}");

        steps.add(CommercialStep(
            title: "Step 2: Find the Selling Price",
            description: isProfitPct
                ? "Since a profit was made, it means the item was sold for MORE than it was bought. We ADD the profit amount ($sym${_fmt(amt)}) to the original Cost Price to find the final Selling Price."
                : "Since a loss was made, it means the item was sold for LESS than it was bought. We SUBTRACT the loss amount ($sym${_fmt(amt)}) from the original Cost Price to find the final Selling Price.",
            mathLaTeX: "\\text{SP} = \\text{$symL}${_fmt(cp)} $sign \\text{$symL}${_fmt(amt)} = \\text{$symL}${_fmt(calcSp)}"
        ));
        answers["Selling Price"] = "$sym${_fmt(calcSp)}";
      }
      // SCENARIO 3: Given SP and % (REVERSE CALCULATION - Find CP & Actual)
      else if (sp > 0 && pct > 0) {
        String typeStr = isProfitPct ? "Profit" : "Loss";
        double effectivePct = isProfitPct ? 100 + pct : 100 - pct;

        workings.add("\\text{\\textbf{Reverse Percentage Calculation}}");
        workings.add("\\text{Let Original Cost Price (CP)} = 100\\%");
        workings.add("\\text{Selling Price} = 100\\% ${isProfitPct ? '+' : '-'} ${_fmt(pct)}\\% = ${_fmt(effectivePct)}\\% \\text{ of CP}");

        steps.add(CommercialStep(
            title: "Step 1: Understand the Reverse Percentage Rule",
            description: "This is a reverse calculation! We DO NOT know the Cost Price, so in mathematics, we always assume the original unknown value is exactly 100%. Because the trader made a ${_fmt(pct)}% $typeStr, the Selling Price actually represents ${_fmt(effectivePct)}% (100% ${isProfitPct ? '+' : '-'} ${_fmt(pct)}%) of the original cost.",
            mathLaTeX: "100\\% ${isProfitPct ? '+' : '-'} ${_fmt(pct)}\\% = ${_fmt(effectivePct)}\\%"
        ));

        workings.add("${_fmt(effectivePct)}\\% \\text{ of CP} = \\text{$symL}${_fmt(sp)}");

        double onePct = sp / effectivePct;
        workings.add("1\\% \\text{ of CP} = \\frac{\\text{$symL}${_fmt(sp)}}{${_fmt(effectivePct)}} = \\text{$symL}${_fmt(onePct)}");

        double cpCalc = onePct * 100;
        workings.add("100\\% \\text{ (CP)} = \\text{$symL}${_fmt(onePct)} \\times 100 = \\text{$symL}${_fmt(cpCalc)}");
        workings.add("");

        steps.add(CommercialStep(
            title: "Step 2: Find the Original Cost Price (Unitary Method)",
            description: "We now know that ${_fmt(effectivePct)}% is equal to $sym${_fmt(sp)}. We use the Unitary Method: first, we divide the money by ${_fmt(effectivePct)} to find out exactly how much 1% is worth. Then, we multiply that 1% value by 100 to reveal the full 100% original Cost Price.",
            mathLaTeX: "\\text{CP} = \\frac{\\text{$symL}${_fmt(sp)}}{${_fmt(effectivePct)}} \\times 100 = \\text{$symL}${_fmt(cpCalc)}"
        ));
        answers["Cost Price"] = "$sym${_fmt(cpCalc)}";

        double amt = isProfitPct ? sp - cpCalc : cpCalc - sp;
        workings.add("\\text{Actual $typeStr} = |\\text{SP} - \\text{CP}|");
        workings.add("= |\\text{$symL}${_fmt(sp)} - \\text{$symL}${_fmt(cpCalc)}| = \\text{$symL}${_fmt(amt)}");

        steps.add(CommercialStep(
            title: "Step 3: Find the Actual $typeStr",
            description: "Now that we know both the Cost Price ($sym${_fmt(cpCalc)}) and the Selling Price ($sym${_fmt(sp)}), we simply find the difference between them to see the exact amount of money gained or lost.",
            mathLaTeX: "\\text{Actual $typeStr} = \\text{$symL}${_fmt(amt)}"
        ));
        answers["Actual $typeStr"] = "$sym${_fmt(amt)}";
      }

      return CommercialResult(mode: 'ProfitLoss', finalAnswers: answers, workings: workings, steps: steps);

    } catch (e) {
      return CommercialResult(mode: 'ProfitLoss', finalAnswers: {}, workings: [], steps: [], valid: false, errorMessage: "Ensure at least two fields contain valid numbers.");
    }
  }

  // ==========================================
  // COMMISSION & BANK DRAFT ENGINE
  // ==========================================
  static CommercialResult solveCommission({
    required List<CommItem> items,
    required bool isPct,
    required String rateStr,
    required String flatAmtStr,
    required String flatQtyStr,
    required bool isBankDraft,
    required String currencySymbol,
  }) {
    try {
      if (items.isEmpty) throw const FormatException("Add at least one item.");

      String sym = currencySymbol.trim().isEmpty ? '₦' : currencySymbol.trim();
      String symL = _escapeLatex(sym);

      List<CommercialStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};

      // Step 1: Calculate Total Value
      double totalValue = 0;
      if (items.length == 1 && items[0].quantity == 1) {
        totalValue = items[0].unitPrice;
        workings.add("\\text{Total Value} = \\text{$symL}${_fmt(totalValue)}");
      } else {
        workings.add("\\text{\\textbf{Calculate Total Value:}}");
        for (var item in items) {
          double lineTotal = item.quantity * item.unitPrice;
          totalValue += lineTotal;
          workings.add("\\text{${item.name}: } ${_fmt(item.quantity)} \\times \\text{$symL}${_fmt(item.unitPrice)} = \\text{$symL}${_fmt(lineTotal)}");
        }
        workings.add("\\text{Total Sales Value} = \\text{$symL}${_fmt(totalValue)}");
        workings.add("");

        steps.add(CommercialStep(
            title: "Step 1: Calculate Total Value of Goods",
            description: "Before calculating any commission, we need to know the total value of everything sold. We multiply the quantity of each item by its unit price, and then add all the totals together.",
            mathLaTeX: "\\text{Total Value} = \\text{$symL}${_fmt(totalValue)}"
        ));
      }
      answers[isBankDraft ? "Draft Face Value" : "Total Sales Value"] = "$sym${_fmt(totalValue)}";

      // Step 2: Calculate Commission
      double commAmount = 0;

      if (isPct) {
        double rate = double.tryParse(rateStr.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
        commAmount = (rate / 100) * totalValue;

        workings.add("\\text{Commission} = ${_fmt(rate)}\\% \\text{ of } \\text{$symL}${_fmt(totalValue)}");
        workings.add("= \\frac{${_fmt(rate)}}{100} \\times \\text{$symL}${_fmt(totalValue)} = \\text{$symL}${_fmt(commAmount)}");

        steps.add(CommercialStep(
            title: "Step 2: Calculate Percentage Commission",
            description: "Commission is a reward payment for selling items or a service fee charged by a bank. Here, the rate is ${_fmt(rate)}%. We calculate this by taking ${_fmt(rate)}% of the total value we found in Step 1.",
            mathLaTeX: "\\frac{${_fmt(rate)}}{100} \\times \\text{$symL}${_fmt(totalValue)} = \\text{$symL}${_fmt(commAmount)}"
        ));
      } else {
        // Flat Rate (e.g. ₦100 for every 5 items)
        double fAmt = double.tryParse(flatAmtStr.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
        double fQty = double.tryParse(flatQtyStr.replaceAll(RegExp(r'[^\d.]'), '')) ?? 1;

        double totalItems = items.fold(0.0, (sum, item) => sum + item.quantity);
        double groups = totalItems / fQty;
        commAmount = groups * fAmt;

        workings.add("\\text{Total Items Sold} = ${_fmt(totalItems)}");
        workings.add("\\text{Commission Rate} = \\text{$symL}${_fmt(fAmt)} \\text{ for every } ${_fmt(fQty)} \\text{ items}");

        if (fQty == 1) {
          workings.add("\\text{Commission} = ${_fmt(totalItems)} \\times \\text{$symL}${_fmt(fAmt)} = \\text{$symL}${_fmt(commAmount)}");
          steps.add(CommercialStep(
              title: "Step 2: Calculate Flat Commission",
              description: "Instead of a percentage, the commission is a flat reward of $sym${_fmt(fAmt)} per item. We simply multiply the total number of items sold (${_fmt(totalItems)}) by this reward amount.",
              mathLaTeX: "${_fmt(totalItems)} \\times \\text{$symL}${_fmt(fAmt)} = \\text{$symL}${_fmt(commAmount)}"
          ));
        } else {
          workings.add("\\text{Groups of } ${_fmt(fQty)} = \\frac{${_fmt(totalItems)}}{${_fmt(fQty)}} = ${_fmt(groups)}");
          workings.add("\\text{Commission} = ${_fmt(groups)} \\times \\text{$symL}${_fmt(fAmt)} = \\text{$symL}${_fmt(commAmount)}");
          steps.add(CommercialStep(
              title: "Step 2: Calculate Grouped Commission",
              description: "The commission is paid in batches (e.g., $sym${_fmt(fAmt)} for every ${_fmt(fQty)} items). First, we divide the total items (${_fmt(totalItems)}) by ${_fmt(fQty)} to see how many 'groups' were sold. Then we multiply the number of groups by the reward amount.",
              mathLaTeX: "\\frac{${_fmt(totalItems)}}{${_fmt(fQty)}} \\times \\text{$symL}${_fmt(fAmt)} = \\text{$symL}${_fmt(commAmount)}"
          ));
        }
      }
      answers["Commission Paid"] = "$sym${_fmt(commAmount)}";

      // Step 3: Total Cost (For Bank Drafts)
      if (isBankDraft) {
        double finalCost = totalValue + commAmount;
        workings.add("");
        workings.add("\\text{Total Cost of Draft} = \\text{Face Value} + \\text{Commission}");
        workings.add("= \\text{$symL}${_fmt(totalValue)} + \\text{$symL}${_fmt(commAmount)} = \\text{$symL}${_fmt(finalCost)}");

        steps.add(CommercialStep(
            title: "Step 3: Calculate the Total Cost of the Bank Draft",
            description: "A Bank Draft is like a secure cheque you buy from a bank. You must pay the bank the actual value of the money you want to send (Face Value), PLUS the bank's fee (Commission). We add them together to find your total cost.",
            mathLaTeX: "\\text{$symL}${_fmt(totalValue)} + \\text{$symL}${_fmt(commAmount)} = \\text{$symL}${_fmt(finalCost)}"
        ));
        answers["Total Cost to Customer"] = "$sym${_fmt(finalCost)}";
      }

      return CommercialResult(mode: 'Commission', finalAnswers: answers, workings: workings, steps: steps);

    } catch (e) {
      return CommercialResult(mode: 'Commission', finalAnswers: {}, workings: [], steps: [], valid: false, errorMessage: "Check your inputs. Ensure all values are valid numbers.");
    }
  }
}