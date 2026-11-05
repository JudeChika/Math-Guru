import 'dart:math' as math;
import 'simple_interest_models.dart';

class SimpleInterestLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 45–47: Examples 1–4 & Exercise 4.1 #1–20)
  // ===========================================================================
  static const List<SimpleInterestPreset> textbookPresets = [
    SimpleInterestPreset(
      chipLabel: "Example 1 (Page 45): Simple interest on ₦15,000 for 3 yrs at 10%",
      mode: 0,
      currency: '₦',
      input1: '15000',
      input2: '3',
      input3: '10',
    ),
    SimpleInterestPreset(
      chipLabel: "Example 2 (Page 45–46): Amount of ₦65,200 in 3 ½ yrs at 7%",
      mode: 0,
      currency: '₦',
      input1: '65200',
      input2: '3 1/2',
      input3: '7',
    ),
    SimpleInterestPreset(
      chipLabel: "Example 3 (Page 46): Borrowed ₦180,000, paid back ₦216,000 after 4 yrs (Find R%)",
      mode: 1,
      subMode: 0, // Given Amount paid back A = 216,000
      currency: '₦',
      input1: '180000',
      input2: '4',
      input3: '216000',
    ),
    SimpleInterestPreset(
      chipLabel: "Example 4 (Page 46): Borrowed ₦1,600,000 at 6%, paid back ₦1,888,000 (Find Time T)",
      mode: 2,
      subMode: 0, // Given Amount paid back A = 1,888,000
      currency: '₦',
      input1: '1600000',
      input2: '6',
      input3: '1888000',
    ),
    SimpleInterestPreset(
      chipLabel: "Ex 4.1 #2: ₦9,200 for 3 ½ years at 7% per annum",
      mode: 0,
      currency: '₦',
      input1: '9200',
      input2: '3 1/2',
      input3: '7',
    ),
    SimpleInterestPreset(
      chipLabel: "Ex 4.1 #3: ₦10,500 for 6 years at 2 ½% per annum",
      mode: 0,
      currency: '₦',
      input1: '10500',
      input2: '6',
      input3: '2 1/2',
    ),
    SimpleInterestPreset(
      chipLabel: "Ex 4.1 #4: ₦21,400 for 3 ½ years at 3 ½% per annum",
      mode: 0,
      currency: '₦',
      input1: '21400',
      input2: '3 1/2',
      input3: '3 1/2',
    ),
    SimpleInterestPreset(
      chipLabel: "Ex 4.1 #6: £376 for 3 years at 2 ½% per annum",
      mode: 0,
      currency: '£',
      input1: '376',
      input2: '3',
      input3: '2 1/2',
    ),
    SimpleInterestPreset(
      chipLabel: "Ex 4.1 #7: \$680 for 2 ½ years at 5% per annum",
      mode: 0,
      currency: '\$',
      input1: '680',
      input2: '2 1/2',
      input3: '5',
    ),
    SimpleInterestPreset(
      chipLabel: "Ex 4.1 #9: £820 for 3 ½ years at 3 ½% per annum",
      mode: 0,
      currency: '£',
      input1: '820',
      input2: '3 1/2',
      input3: '3 1/2',
    ),
    SimpleInterestPreset(
      chipLabel: "Ex 4.1 #11 (Femi's Loan): ₦500,000 for 1 yr at 20% (Amount paid back)",
      mode: 0,
      currency: '₦',
      input1: '500000',
      input2: '1',
      input3: '20',
    ),
    SimpleInterestPreset(
      chipLabel: "Ex 4.1 #12 (Nkechi): ₦600,000 at 21% for 3 years",
      mode: 0,
      currency: '₦',
      input1: '600000',
      input2: '3',
      input3: '21',
    ),
    SimpleInterestPreset(
      chipLabel: "Ex 4.1 #15 (Table): ₦4.3 m at 5/2% for 3 years (Amount paid back)",
      mode: 0,
      currency: '₦',
      input1: '4.3m',
      input2: '3',
      input3: '5/2',
    ),
    SimpleInterestPreset(
      chipLabel: "Ex 4.1 #18: Time for ₦800,000 to earn ₦15,000 interest at 10%",
      mode: 2,
      subMode: 1, // Given Interest I = 15,000
      currency: '₦',
      input1: '800000',
      input2: '10',
      input3: '15000',
    ),
    SimpleInterestPreset(
      chipLabel: "Ex 4.1 #19 (Kabir): ₦1,012,500 at 8 ½% for 4 years",
      mode: 0,
      currency: '₦',
      input1: '1012500',
      input2: '4',
      input3: '8 1/2',
    ),
    SimpleInterestPreset(
      chipLabel: "Ex 4.1 #20 (Sherifat): ₦1,620,000 earned ₦486,000 interest after 4 yrs (Find R%)",
      mode: 1,
      subMode: 1, // Given Interest I = 486,000
      currency: '₦',
      input1: '1620000',
      input2: '4',
      input3: '486000',
    ),
  ];

  // ===========================================================================
  // UNIVERSAL CURRENCY, MILLION SHORTHAND & FRACTION HELPERS (Math.tex Safe!)
  // ===========================================================================
  static int gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final int t = b;
      b = a % b;
      a = t;
    }
    return a == 0 ? 1 : a;
  }

  static String fmt(double v, {int maxDecimals = 2}) {
    if (v.abs() < 1e-9) return '0';
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return _groupInt(v.round());
    }
    final String fixed = v.toStringAsFixed(maxDecimals);
    final List<String> parts = fixed.split('.');
    final int whole = int.parse(parts[0]);
    final String dec = parts[1].replaceAll(RegExp(r'0*$'), '');
    if (dec.isEmpty) return _groupInt(whole);
    return '${_groupInt(whole)}.${parts[1]}';
  }

  static String fmtLaTeXNum(double v, {int maxDecimals = 2}) {
    return fmt(v, maxDecimals: maxDecimals).replaceAll(',', '\\,');
  }

  static String _groupInt(int n) {
    final bool neg = n < 0;
    final String s = n.abs().toString();
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        buf.write(',');
      }
      buf.write(s[i]);
    }
    return neg ? '-${buf.toString()}' : buf.toString();
  }

  /// Formats currency symbol safely inside Math.tex (`\text{N}`, `\text{£}`, `\$`)
  static String currLaTeX(String curr) {
    final String c = curr.trim();
    if (c == '£') return '\\text{£}';
    if (c == '\$') return '\\\$';
    return '\\text{N}';
  }

  static String formatMoneyLaTeX(double val, String curr) {
    return '${currLaTeX(curr)}${fmtLaTeXNum(val)}';
  }

  static String formatMoneyPlain(double val, String curr) {
    return '${curr.trim()}${fmt(val)}';
  }

  /// Parses numbers, fractions ("5/2", "7/2"), mixed numbers ("3 1/2", "8 1/2"),
  /// and million shorthand ("1m", "2.5m", "4.3 m")
  static ParsedSIParam parseParam(
      String raw, {
        String fieldName = 'value',
      }) {
    String s = raw
        .trim()
        .replaceAll('−', '-')
        .replaceAll('½', ' 1/2')
        .replaceAll('¼', ' 1/4')
        .replaceAll('¾', ' 3/4')
        .replaceAll(',', '')
        .replaceAll('₦', '')
        .replaceAll('£', '')
        .replaceAll('\$', '')
        .replaceAll('%', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (s.isEmpty) {
      throw FormatException(
        "Please enter a valid $fieldName (e.g. 15000, 3 1/2, 5/2, or 2.5m).",
      );
    }

    // Check for "m" / "million" shorthand (Exercise 4.1 #13–17: "1 m", "2.5 m", "4.3 m")
    final RegExp milReg =
    RegExp(r'^(\d+\.?\d*)\s*(?:m|million)$', caseSensitive: false);
    final Match? milM = milReg.firstMatch(s);
    if (milM != null) {
      final double baseMil = double.parse(milM.group(1)!);
      final double fullVal = baseMil * 1000000.0;
      final int fullInt = fullVal.round();
      return ParsedSIParam(
        rawInput: raw.trim(),
        value: fullVal,
        num: fullInt,
        den: 1,
        hadMillionShorthand: true,
        displayPlain: '${fmt(baseMil)} m (${fmt(fullVal)})',
        displayLaTeX: fmtLaTeXNum(fullVal),
        improperLaTeX: fmtLaTeXNum(fullVal),
      );
    }

    if (s.contains('/')) {
      final List<String> parts = s.split(' ');
      if (parts.length == 2) {
        final int whole = int.parse(parts[0]);
        final List<String> fp = parts[1].split('/');
        final int fN = int.parse(fp[0]);
        final int fD = int.parse(fp[1]);
        if (fD <= 0) {
          throw const FormatException("Denominator must be greater than zero.");
        }
        final int impN = whole * fD + fN;
        final int g = gcd(impN, fD);
        return ParsedSIParam(
          rawInput: raw.trim(),
          value: impN / fD,
          num: impN ~/ g,
          den: fD ~/ g,
          isFractionOrMixed: true,
          isMixedInput: true,
          displayPlain: '$whole $fN/$fD',
          displayLaTeX: '$whole\\frac{$fN}{$fD}',
          improperLaTeX: '\\frac{${impN ~/ g}}{${fD ~/ g}}',
        );
      } else if (parts.length == 1) {
        final List<String> fp = parts[0].split('/');
        final int fN = int.parse(fp[0]);
        final int fD = int.parse(fp[1]);
        if (fD <= 0) {
          throw const FormatException("Denominator must be greater than zero.");
        }
        final int g = gcd(fN, fD);
        final int redN = fN ~/ g;
        final int redD = fD ~/ g;
        return ParsedSIParam(
          rawInput: raw.trim(),
          value: fN / fD,
          num: redN,
          den: redD,
          isFractionOrMixed: true,
          isMixedInput: false,
          displayPlain: '$redN/$redD',
          displayLaTeX: '\\frac{$redN}{$redD}',
          improperLaTeX: '\\frac{$redN}{$redD}',
        );
      }
    }

    final String noSpace = s.replaceAll(' ', '');
    final double? val = double.tryParse(noSpace);
    if (val == null || val <= 0) {
      throw FormatException("Please enter a positive number for $fieldName.");
    }

    int decPlaces = 0;
    if (noSpace.contains('.')) {
      decPlaces = noSpace.split('.')[1].length.clamp(0, 6);
    }
    final int scaleDen = math.pow(10, decPlaces).round();
    final int scaledNum = (val * scaleDen).round();
    final int g = gcd(scaledNum, scaleDen);
    final int redN = scaledNum ~/ g;
    final int redD = scaleDen ~/ g;

    return ParsedSIParam(
      rawInput: raw.trim(),
      value: val,
      num: redN,
      den: redD,
      isFractionOrMixed: false,
      isMixedInput: false,
      displayPlain: fmt(val),
      displayLaTeX: fmtLaTeXNum(val),
      improperLaTeX: fmtLaTeXNum(val),
    );
  }

  // ===========================================================================
  // MODE 0: FIND SIMPLE INTEREST (I) & FINAL AMOUNT (A = P + I)
  // Covers Examples 1 & 2 (Pages 45–46) and Exercise 4.1 #1–17, #19
  // ===========================================================================
  static SimpleInterestResult solveInterestAndAmount({
    required String principalStr,
    required String timeStr,
    required String rateStr,
    required String currency,
  }) {
    try {
      final ParsedSIParam p =
      parseParam(principalStr, fieldName: 'Principal (P)');
      final ParsedSIParam t =
      parseParam(timeStr, fieldName: 'Time in Years (T)');
      final ParsedSIParam r =
      parseParam(rateStr, fieldName: 'Rate % per annum (R)');

      final String cTex = currLaTeX(currency);
      final double interestVal = (p.value * t.value * r.value) / 100.0;
      final double amountVal = p.value + interestVal;

      // STEP 1: Formula & Given Parameters (Example 1 & 2 Style on Pages 45–46!)
      final List<String> step1Lines = [
        "\\text{Formula for Simple Interest (Page 45):}",
        "I = \\frac{PTR}{100} \\qquad \\left(\\text{or } I = \\frac{PRT}{100}\\right)",
        "\\text{We have:}",
        if (p.hadMillionShorthand)
          "P = ${p.rawInput.replaceAll('₦', 'N')} = $cTex${p.displayLaTeX}, \\quad T = ${t.displayLaTeX}\\text{ years}, \\quad R = ${r.displayLaTeX}\\%"
        else
          "P = $cTex${p.displayLaTeX}, \\quad T = ${t.displayLaTeX}\\text{ years}, \\quad R = ${r.displayLaTeX}\\%",
      ];

      // STEP 2: Substitute into I = PTR / 100 (Replicating Example 2's Exact Denominator-Dropping Method!)
      final List<String> step2Lines = [
        "\\text{So, } I = \\frac{$cTex${p.displayLaTeX} \\times ${t.displayLaTeX} \\times ${r.displayLaTeX}}{100}",
      ];

      final bool hasFractionTR = t.isFractionOrMixed || r.isFractionOrMixed;
      if (hasFractionTR) {
        final String topNumT = t.isFractionOrMixed ? "${t.num}" : t.displayLaTeX;
        final String topNumR = r.isFractionOrMixed ? "${r.num}" : r.displayLaTeX;
        final List<String> botFactors = ["100"];
        if (t.isFractionOrMixed && t.den > 1) botFactors.add("${t.den}");
        if (r.isFractionOrMixed && r.den > 1) botFactors.add("${r.den}");

        final int totalDen = 100 *
            (t.isFractionOrMixed ? t.den : 1) *
            (r.isFractionOrMixed ? r.den : 1);
        final double totalNum = p.value *
            (t.isFractionOrMixed ? t.num : t.value) *
            (r.isFractionOrMixed ? r.num : r.value);

        step2Lines.add(
            "\\text{Convert fraction(s) to improper form and drop denominator(s) to multiply } 100 \\text{ (Example 2, Page 46):}");
        step2Lines.add(
            "= \\frac{$cTex${p.displayLaTeX} \\times $topNumT \\times $topNumR}{${botFactors.join(' \\times ')}}");
        step2Lines.add(
            "= \\frac{$cTex${fmtLaTeXNum(totalNum)}}{${fmtLaTeXNum(totalDen.toDouble())}}");
      } else {
        final double topProd = p.value * t.value * r.value;
        step2Lines.add(
            "= \\frac{$cTex${fmtLaTeXNum(topProd)}}{100}");
      }

      step2Lines.add(
          "\\therefore \\; \\text{Simple Interest } (I) = \\mathbf{${formatMoneyLaTeX(interestVal, currency)}}");

      // STEP 3: Final Amount Paid Back / Saved (Amount = Principal + Interest — Example 2!)
      final List<String> step3Lines = [
        "\\text{Amount} = \\text{Principal} + \\text{Interest}",
        "= ${formatMoneyLaTeX(p.value, currency)} + ${formatMoneyLaTeX(interestVal, currency)}",
        "= \\mathbf{${formatMoneyLaTeX(amountVal, currency)}}",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Write Down the Simple Interest Formula and Given Values}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Step 2: Calculate the Simple Interest (}}I\\text{\\textbf{)}}",
        ...step2Lines,
        "",
        "\\text{\\textbf{Step 3: Calculate the Total Amount (Principal + Interest)}}",
        ...step3Lines,
      ];

      final List<SimpleInterestStep> steps = [
        SimpleInterestStep(
          title:
          "Step 1: Identify Principal (P), Time (T), and Rate (R) (Pages 45–46)",
          description:
          "• Principal (P) = ${formatMoneyPlain(p.value, currency)} (the sum of money saved or borrowed).\n"
              "• Time (T) = ${t.displayPlain} years (the duration).\n"
              "• Rate (R) = ${r.displayPlain}% per annum (the percentage charged per year).",
          mathLinesLaTeX: step1Lines,
        ),
        SimpleInterestStep(
          title:
          "Step 2: Substitute into I = PTR / 100${hasFractionTR ? ' & Drop Fraction Denominators' : ''}",
          description: hasFractionTR
              ? "• Following Example 2 on Page 46, convert any mixed number into an improper fraction and place its denominator in the bottom to multiply 100.\n"
              "• Evaluating gives Simple Interest (I) = ${formatMoneyPlain(interestVal, currency)}."
              : "• Multiply P × T × R and divide by 100 to find Simple Interest (I) = ${formatMoneyPlain(interestVal, currency)}.",
          mathLinesLaTeX: step2Lines,
        ),
        SimpleInterestStep(
          title: "Step 3: Add Principal + Interest to Find the Final Amount",
          description:
          "• Note from Page 45: 'The amount is the sum of the interest and the principal.'\n"
              "• Amount = ${formatMoneyPlain(p.value, currency)} + ${formatMoneyPlain(interestVal, currency)} = ${formatMoneyPlain(amountVal, currency)}.",
          mathLinesLaTeX: step3Lines,
        ),
      ];

      return SimpleInterestResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Principal (P)": formatMoneyLaTeX(p.value, currency),
          "Simple Interest (I)": formatMoneyLaTeX(interestVal, currency),
          "Total Amount (P + I)": formatMoneyLaTeX(amountVal, currency),
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SimpleInterestCanvasData(
          headerLaTeX:
          "\\text{Simple Interest: } I = \\frac{PTR}{100} = \\mathbf{${formatMoneyLaTeX(interestVal, currency)}}",
          subHeaderLaTeX:
          "\\text{Total Amount } (A = P + I) = ${formatMoneyLaTeX(p.value, currency)} + ${formatMoneyLaTeX(interestVal, currency)} = \\mathbf{${formatMoneyLaTeX(amountVal, currency)}}",
          card1Title: "Principal (P)",
          card1LaTeX: formatMoneyLaTeX(p.value, currency),
          card2Title: "Time (T) & Rate (R)",
          card2LaTeX: "T = ${t.displayLaTeX}\\text{ yrs},\\; R = ${r.displayLaTeX}\\%",
          card3Title: "Simple Interest (I)",
          card3LaTeX: "\\mathbf{${formatMoneyLaTeX(interestVal, currency)}}",
          formulaBridgeLaTeX: hasFractionTR
              ? "I = \\frac{$cTex${p.displayLaTeX} \\times ${t.isFractionOrMixed ? t.num : t.displayLaTeX} \\times ${r.isFractionOrMixed ? r.num : r.displayLaTeX}}{100${t.isFractionOrMixed && t.den > 1 ? ' \\times ${t.den}' : ''}${r.isFractionOrMixed && r.den > 1 ? ' \\times ${r.den}' : ''}} = \\mathbf{${formatMoneyLaTeX(interestVal, currency)}}"
              : "I = \\frac{$cTex${p.displayLaTeX} \\times ${t.displayLaTeX} \\times ${r.displayLaTeX}}{100} = \\mathbf{${formatMoneyLaTeX(interestVal, currency)}}",
          amountBarLaTeX:
          "\\text{Amount } (${formatMoneyLaTeX(amountVal, currency)}) = \\text{Principal } (${formatMoneyLaTeX(p.value, currency)}) + \\text{Interest } (${formatMoneyLaTeX(interestVal, currency)})",
          principalProportion:
          amountVal > 0 ? (p.value / amountVal).clamp(0.25, 0.85) : 0.75,
          interestProportion:
          amountVal > 0 ? (interestVal / amountVal).clamp(0.15, 0.75) : 0.25,
          bottomSummaryLaTeX:
          "I = \\mathbf{${formatMoneyLaTeX(interestVal, currency)}}, \\qquad \\text{Amount} = \\mathbf{${formatMoneyLaTeX(amountVal, currency)}}",
        ),
      );
    } catch (e) {
      return SimpleInterestResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers or fractions for P, T, and R.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: FIND UNKNOWN RATE (R%) GIVEN PRINCIPAL, TIME & AMOUNT OR INTEREST
  // Covers Example 3 (Page 46: Kadri borrowed ₦180,000, paid back ₦216,000 after 4 yrs)
  // and Exercise 4.1 #20 (Sherifat invested ₦1,620,000, earned ₦486,000 after 4 yrs)
  // Shows BOTH the Example 3 Unitary Method AND the Formula R = 100I / (PT)!
  // ===========================================================================
  static SimpleInterestResult solveUnknownRate({
    required int subMode, // 0: Given Amount Paid Back (A), 1: Given Interest Earned (I)
    required String principalStr,
    required String timeStr,
    required String amountOrInterestStr,
    required String currency,
  }) {
    try {
      final ParsedSIParam p =
      parseParam(principalStr, fieldName: 'Principal (P)');
      final ParsedSIParam t =
      parseParam(timeStr, fieldName: 'Time in Years (T)');
      final ParsedSIParam givenVal = parseParam(
        amountOrInterestStr,
        fieldName: subMode == 0 ? 'Amount Paid Back (A)' : 'Interest Earned (I)',
      );

      final String cTex = currLaTeX(currency);
      double interestVal = givenVal.value;
      double amountVal = p.value + interestVal;

      if (subMode == 0) {
        amountVal = givenVal.value;
        if (amountVal <= p.value) {
          throw FormatException(
            "The total Amount paid back (${formatMoneyPlain(amountVal, currency)}) must be greater than the Principal borrowed (${formatMoneyPlain(p.value, currency)}).",
          );
        }
        interestVal = amountVal - p.value;
      }

      final double interestOneYear = interestVal / t.value;
      final double rateVal = (100.0 * interestVal) / (p.value * t.value);

      final List<String> step1Lines = [
        "\\text{Principal } (P) = ${formatMoneyLaTeX(p.value, currency)}, \\qquad \\text{Time } (T) = ${t.displayLaTeX}\\text{ years}",
        if (subMode == 0) ...[
          "\\text{Amount paid back } (A) = ${formatMoneyLaTeX(amountVal, currency)}",
          "\\text{Interest paid back } (I) = \\text{Amount} - \\text{Principal}",
          "I = ${formatMoneyLaTeX(amountVal, currency)} - ${formatMoneyLaTeX(p.value, currency)} = \\mathbf{${formatMoneyLaTeX(interestVal, currency)}}",
        ] else
          "\\text{Interest earned } (I) = \\mathbf{${formatMoneyLaTeX(interestVal, currency)}}",
      ];

      // METHOD A: Textbook Example 3 Unitary Method (Page 46 Top Left!)
      final List<String> methodALines = [
        "\\text{Interest on } ${formatMoneyLaTeX(p.value, currency)} \\text{ in } 1\\text{ year} = ${fmtLaTeXNum(interestVal)} \\div ${t.displayLaTeX} = \\mathbf{${formatMoneyLaTeX(interestOneYear, currency)}}",
        "\\text{Rate per cent } (R) = \\frac{100 \\times ${formatMoneyLaTeX(interestOneYear, currency)}}{${fmtLaTeXNum(p.value)}}",
        "= \\frac{${fmtLaTeXNum(100.0 * interestOneYear)}}{${fmtLaTeXNum(p.value)}} = \\mathbf{${fmtLaTeXNum(rateVal)}\\%}",
      ];

      // METHOD B: Direct Formula R = 100I / (PT) (Page 45 Top Right!)
      final List<String> methodBLines = [
        "R = \\frac{100I}{PT}",
        "= \\frac{100 \\times ${formatMoneyLaTeX(interestVal, currency)}}{${formatMoneyLaTeX(p.value, currency)} \\times ${t.displayLaTeX}}",
        "= \\frac{${fmtLaTeXNum(100.0 * interestVal)}}{${fmtLaTeXNum(p.value * t.value)}} = \\mathbf{${fmtLaTeXNum(rateVal)}\\%}",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Find the Total Simple Interest (}}I\\text{\\textbf{)}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Step 2: Method 1 — Unitary Method (Example 3, Page 46)}}",
        ...methodALines,
        "",
        "\\text{\\textbf{Step 3: Method 2 — Formula Method }} \\left(R = \\frac{100I}{PT}\\right)",
        ...methodBLines,
      ];

      final List<SimpleInterestStep> steps = [
        SimpleInterestStep(
          title:
          "Step 1: Determine the Total Simple Interest (I)",
          description: subMode == 0
              ? "• Subtract the Principal (${formatMoneyPlain(p.value, currency)}) from the Amount paid back (${formatMoneyPlain(amountVal, currency)}) to find the total interest charged:\n"
              "  I = ${formatMoneyPlain(amountVal, currency)} − ${formatMoneyPlain(p.value, currency)} = ${formatMoneyPlain(interestVal, currency)}."
              : "• The total interest earned over ${t.displayPlain} years is I = ${formatMoneyPlain(interestVal, currency)}.",
          mathLinesLaTeX: step1Lines,
        ),
        SimpleInterestStep(
          title:
          "Step 2: Method 1 — Example 3 Unitary Method (Interest in 1 Year)",
          description:
          "1. Divide the total interest (${formatMoneyPlain(interestVal, currency)}) by ${t.displayPlain} years to find the interest for 1 single year: ${formatMoneyPlain(interestOneYear, currency)}.\n"
              "2. Express ${formatMoneyPlain(interestOneYear, currency)} as a percentage of the Principal (${formatMoneyPlain(p.value, currency)}): (100 × ${fmt(interestOneYear)}) ÷ ${fmt(p.value)} = ${fmt(rateVal)}%.",
          mathLinesLaTeX: methodALines,
        ),
        SimpleInterestStep(
          title:
          "Step 3: Method 2 — Formula Method (R = 100I / PT)",
          description:
          "Substitute I = ${fmt(interestVal)}, P = ${fmt(p.value)}, and T = ${t.displayPlain} directly into the formula R = 100I / (PT) on Page 45 to get R = ${fmt(rateVal)}% per annum.",
          mathLinesLaTeX: methodBLines,
        ),
      ];

      return SimpleInterestResult(
        mode: 1,
        subMode: subMode,
        finalAnswersLaTeX: {
          "Total Interest (I)": formatMoneyLaTeX(interestVal, currency),
          "Interest in 1 Year": formatMoneyLaTeX(interestOneYear, currency),
          "Rate per Annum (R)": "${fmtLaTeXNum(rateVal)}\\%",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SimpleInterestCanvasData(
          headerLaTeX:
          "\\text{Example 3 Find Rate } (R): \\quad R = \\frac{100I}{PT} = \\mathbf{${fmtLaTeXNum(rateVal)}\\%}",
          subHeaderLaTeX:
          "I = ${formatMoneyLaTeX(interestVal, currency)}, \\quad \\text{1-Year Interest} = ${formatMoneyLaTeX(interestOneYear, currency)}",
          card1Title: "Principal (P)",
          card1LaTeX: formatMoneyLaTeX(p.value, currency),
          card2Title: "Total Interest (I)",
          card2LaTeX: formatMoneyLaTeX(interestVal, currency),
          card3Title: "Rate per Annum (R)",
          card3LaTeX: "\\mathbf{${fmtLaTeXNum(rateVal)}\\%}",
          formulaBridgeLaTeX:
          "R = \\frac{100 \\times ${formatMoneyLaTeX(interestOneYear, currency)}}{${fmtLaTeXNum(p.value)}} = \\frac{100 \\times ${fmtLaTeXNum(interestVal)}}{${fmtLaTeXNum(p.value)} \\times ${t.displayLaTeX}} = \\mathbf{${fmtLaTeXNum(rateVal)}\\%}",
          amountBarLaTeX:
          "\\text{Amount } (${formatMoneyLaTeX(amountVal, currency)}) = \\text{Principal } (${formatMoneyLaTeX(p.value, currency)}) + \\text{Interest } (${formatMoneyLaTeX(interestVal, currency)})",
          principalProportion:
          amountVal > 0 ? (p.value / amountVal).clamp(0.25, 0.85) : 0.75,
          interestProportion:
          amountVal > 0 ? (interestVal / amountVal).clamp(0.15, 0.75) : 0.25,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Rate Charged } (R) = \\mathbf{${fmtLaTeXNum(rateVal)}\\% \\text{ per annum}}",
        ),
      );
    } catch (e) {
      return SimpleInterestResult.error(
        mode: 1,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers for Principal, Time, and Amount/Interest.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: FIND UNKNOWN TIME (T) GIVEN PRINCIPAL, RATE & AMOUNT OR INTEREST
  // Covers Example 4 (Page 46: Leke borrowed ₦1,600,000 at 6%, paid back ₦1,888,000)
  // and Exercise 4.1 #18 (Time for ₦800,000 to earn ₦15,000 at 10%)
  // ===========================================================================
  static SimpleInterestResult solveUnknownTime({
    required int subMode, // 0: Given Amount Paid Back (A), 1: Given Interest Earned (I)
    required String principalStr,
    required String rateStr,
    required String amountOrInterestStr,
    required String currency,
  }) {
    try {
      final ParsedSIParam p =
      parseParam(principalStr, fieldName: 'Principal (P)');
      final ParsedSIParam r =
      parseParam(rateStr, fieldName: 'Rate % per annum (R)');
      final ParsedSIParam givenVal = parseParam(
        amountOrInterestStr,
        fieldName: subMode == 0 ? 'Amount Paid Back (A)' : 'Interest Earned (I)',
      );

      double interestVal = givenVal.value;
      double amountVal = p.value + interestVal;

      if (subMode == 0) {
        amountVal = givenVal.value;
        if (amountVal <= p.value) {
          throw FormatException(
            "The total Amount paid back (${formatMoneyPlain(amountVal, currency)}) must be greater than the Principal borrowed (${formatMoneyPlain(p.value, currency)}).",
          );
        }
        interestVal = amountVal - p.value;
      }

      // Exact rational fraction for Time T = (100 * I) / (P * R)
      final int topInt = (100.0 * interestVal * 100).round();
      final int botInt = (p.value * r.value * 100).round();
      final int g = gcd(topInt, botInt);
      final int redN = topInt ~/ g;
      final int redD = botInt ~/ g;
      final double timeYears = (100.0 * interestVal) / (p.value * r.value);
      final double timeMonths = timeYears * 12.0;

      String timeLaTeX = "${fmtLaTeXNum(timeYears)}\\text{ years}";
      if (redD > 1 && redD <= 24) {
        if (redN > redD) {
          final int w = redN ~/ redD;
          final int rem = redN % redD;
          timeLaTeX =
          "$w\\frac{$rem}{$redD}\\text{ years} \\quad (${fmtLaTeXNum(timeYears)}\\text{ yrs})";
        } else {
          timeLaTeX =
          "\\frac{$redN}{$redD}\\text{ year} \\quad (${fmtLaTeXNum(timeMonths)}\\text{ months})";
        }
      }

      final List<String> step1Lines = [
        "\\text{Money borrowed (Principal } P\\text{)} = ${formatMoneyLaTeX(p.value, currency)}, \\qquad \\text{Rate } (R) = ${r.displayLaTeX}\\%",
        if (subMode == 0) ...[
          "\\text{Amount paid back } (A) = ${formatMoneyLaTeX(amountVal, currency)}",
          "\\text{Interest } (I) = \\text{Amount} - \\text{Principal}",
          "I = ${formatMoneyLaTeX(amountVal, currency)} - ${formatMoneyLaTeX(p.value, currency)} = \\mathbf{${formatMoneyLaTeX(interestVal, currency)}}",
        ] else
          "\\text{Interest earned } (I) = \\mathbf{${formatMoneyLaTeX(interestVal, currency)}}",
      ];

      final List<String> step2Lines = [
        "\\text{Formula for Time (Example 4, Page 46):}",
        "\\text{Time } (T) = \\frac{100 \\times I}{P \\times R}",
        "\\therefore \\; T = \\frac{100 \\times ${formatMoneyLaTeX(interestVal, currency)}}{${formatMoneyLaTeX(p.value, currency)} \\times ${r.displayLaTeX}}",
        "= \\frac{${fmtLaTeXNum(100.0 * interestVal)}}{${fmtLaTeXNum(p.value * r.value)}}",
        "= \\mathbf{$timeLaTeX}",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Find the Simple Interest (}}I\\text{\\textbf{) (Example 4 Method, Page 46)}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Step 2: Calculate the Time Period }} T = \\frac{100 \\times I}{P \\times R}",
        ...step2Lines,
      ];

      final List<SimpleInterestStep> steps = [
        SimpleInterestStep(
          title: "Step 1: Determine the Simple Interest (I)",
          description: subMode == 0
              ? "• Following Example 4 on Page 46, first subtract the Principal (${formatMoneyPlain(p.value, currency)}) from the Amount paid back (${formatMoneyPlain(amountVal, currency)}) to get Interest I = ${formatMoneyPlain(interestVal, currency)}."
              : "• The interest to be earned is I = ${formatMoneyPlain(interestVal, currency)}.",
          mathLinesLaTeX: step1Lines,
        ),
        SimpleInterestStep(
          title: "Step 2: Substitute into T = (100 × I) / (P × R)",
          description:
          "• Multiply 100 × ${fmt(interestVal)} = ${fmt(100.0 * interestVal)} in the numerator.\n"
              "• Multiply ${fmt(p.value)} × ${r.displayPlain} = ${fmt(p.value * r.value)} in the denominator.\n"
              "• Dividing gives T = ${fmt(timeYears, maxDecimals: 4)} years${redD > 1 ? ' ($redN/$redD year = ${fmt(timeMonths)} months)' : ''}.",
          mathLinesLaTeX: step2Lines,
        ),
      ];

      return SimpleInterestResult(
        mode: 2,
        subMode: subMode,
        finalAnswersLaTeX: {
          "Simple Interest (I)": formatMoneyLaTeX(interestVal, currency),
          "Time Period (T)": timeLaTeX,
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SimpleInterestCanvasData(
          headerLaTeX:
          "\\text{Example 4 Find Time } (T): \\quad T = \\frac{100 \\times I}{P \\times R} = \\mathbf{$timeLaTeX}",
          subHeaderLaTeX:
          "P = ${formatMoneyLaTeX(p.value, currency)}, \\quad I = ${formatMoneyLaTeX(interestVal, currency)}, \\quad R = ${r.displayLaTeX}\\%",
          card1Title: "Principal (P)",
          card1LaTeX: formatMoneyLaTeX(p.value, currency),
          card2Title: "Simple Interest (I)",
          card2LaTeX: formatMoneyLaTeX(interestVal, currency),
          card3Title: "Time Period (T)",
          card3LaTeX: "\\mathbf{$timeLaTeX}",
          formulaBridgeLaTeX:
          "T = \\frac{100 \\times ${formatMoneyLaTeX(interestVal, currency)}}{${formatMoneyLaTeX(p.value, currency)} \\times ${r.displayLaTeX}} = \\mathbf{$timeLaTeX}",
          amountBarLaTeX:
          "\\text{Amount } (${formatMoneyLaTeX(amountVal, currency)}) = \\text{Principal } (${formatMoneyLaTeX(p.value, currency)}) + \\text{Interest } (${formatMoneyLaTeX(interestVal, currency)})",
          principalProportion:
          amountVal > 0 ? (p.value / amountVal).clamp(0.25, 0.85) : 0.75,
          interestProportion:
          amountVal > 0 ? (interestVal / amountVal).clamp(0.15, 0.75) : 0.25,
          bottomSummaryLaTeX: "\\therefore \\; \\text{Time } (T) = \\mathbf{$timeLaTeX}",
        ),
      );
    } catch (e) {
      return SimpleInterestResult.error(
        mode: 2,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers for Principal, Rate, and Amount/Interest.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: FIND UNKNOWN PRINCIPAL (P = 100I / RT  or  Given Final Amount A)
  // Covers Page 45 Formula P = 100I / (RT)
  // ===========================================================================
  static SimpleInterestResult solveUnknownPrincipal({
    required int subMode, // 0: Given Simple Interest (I), 1: Given Total Amount (A)
    required String interestOrAmountStr,
    required String timeStr,
    required String rateStr,
    required String currency,
  }) {
    try {
      final ParsedSIParam givenVal = parseParam(
        interestOrAmountStr,
        fieldName: subMode == 0 ? 'Simple Interest (I)' : 'Total Amount (A)',
      );
      final ParsedSIParam t =
      parseParam(timeStr, fieldName: 'Time in Years (T)');
      final ParsedSIParam r =
      parseParam(rateStr, fieldName: 'Rate % per annum (R)');

      double principalVal = 0.0;
      double interestVal = 0.0;
      double amountVal = 0.0;

      final List<String> lines = [];

      if (subMode == 0) {
        interestVal = givenVal.value;
        principalVal = (100.0 * interestVal) / (r.value * t.value);
        amountVal = principalVal + interestVal;

        lines.addAll([
          "\\text{Formula for Principal (Page 45):}",
          "P = \\frac{100I}{RT}",
          "\\text{Substitute } I = ${formatMoneyLaTeX(interestVal, currency)}, \\; R = ${r.displayLaTeX}\\%, \\; T = ${t.displayLaTeX}\\text{ years}:",
          "P = \\frac{100 \\times ${formatMoneyLaTeX(interestVal, currency)}}{${r.displayLaTeX} \\times ${t.displayLaTeX}}",
          "= \\frac{${fmtLaTeXNum(100.0 * interestVal)}}{${fmtLaTeXNum(r.value * t.value)}}",
          "\\therefore \\; \\text{Principal } (P) = \\mathbf{${formatMoneyLaTeX(principalVal, currency)}}",
        ]);
      } else {
        amountVal = givenVal.value;
        final double rtProd = r.value * t.value;
        principalVal = (100.0 * amountVal) / (100.0 + rtProd);
        interestVal = amountVal - principalVal;

        lines.addAll([
          "\\text{Since } A = P + I = P + \\frac{PRT}{100} = P\\left(1 + \\frac{RT}{100}\\right) = P\\left(\\frac{100 + RT}{100}\\right):",
          "P = \\frac{100A}{100 + RT}",
          "\\text{Substitute } A = ${formatMoneyLaTeX(amountVal, currency)}, \\; R = ${r.displayLaTeX}\\%, \\; T = ${t.displayLaTeX}\\text{ years}:",
          "P = \\frac{100 \\times ${formatMoneyLaTeX(amountVal, currency)}}{100 + (${r.displayLaTeX} \\times ${t.displayLaTeX})} = \\frac{${fmtLaTeXNum(100.0 * amountVal)}}{${fmtLaTeXNum(100.0 + rtProd)}}",
          "\\therefore \\; \\text{Principal } (P) = \\mathbf{${formatMoneyLaTeX(principalVal, currency)}}",
        ]);
      }

      return SimpleInterestResult(
        mode: 3,
        subMode: subMode,
        finalAnswersLaTeX: {
          "Principal (P)": formatMoneyLaTeX(principalVal, currency),
          "Simple Interest (I)": formatMoneyLaTeX(interestVal, currency),
          "Total Amount (A)": formatMoneyLaTeX(amountVal, currency),
        },
        workingsLaTeX: [
          "\\text{\\textbf{Calculate Unknown Principal (}}P\\text{\\textbf{)}}",
          ...lines,
        ],
        steps: [
          SimpleInterestStep(
            title:
            "Step 1: Find the Unknown Principal (P) Using the Page 45 Formula",
            description: subMode == 0
                ? "• Using P = 100I / (RT), multiply 100 × ${fmt(interestVal)} and divide by (${r.displayPlain} × ${t.displayPlain}) to get P = ${formatMoneyPlain(principalVal, currency)}."
                : "• Using P = 100A / (100 + RT), substitute A = ${fmt(amountVal)}, R = ${r.displayPlain}%, and T = ${t.displayPlain} years to get P = ${formatMoneyPlain(principalVal, currency)}.",
            mathLinesLaTeX: lines,
          ),
        ],
        canvasData: SimpleInterestCanvasData(
          headerLaTeX:
          "\\text{Find Principal } (P): \\quad P = \\mathbf{${formatMoneyLaTeX(principalVal, currency)}}",
          subHeaderLaTeX:
          "R = ${r.displayLaTeX}\\%, \\quad T = ${t.displayLaTeX}\\text{ yrs}, \\quad I = ${formatMoneyLaTeX(interestVal, currency)}",
          card1Title: "Found Principal (P)",
          card1LaTeX: "\\mathbf{${formatMoneyLaTeX(principalVal, currency)}}",
          card2Title: "Simple Interest (I)",
          card2LaTeX: formatMoneyLaTeX(interestVal, currency),
          card3Title: "Total Amount (A)",
          card3LaTeX: formatMoneyLaTeX(amountVal, currency),
          formulaBridgeLaTeX: subMode == 0
              ? "P = \\frac{100I}{RT} = \\frac{100 \\times ${fmtLaTeXNum(interestVal)}}{${r.displayLaTeX} \\times ${t.displayLaTeX}} = \\mathbf{${formatMoneyLaTeX(principalVal, currency)}}"
              : "P = \\frac{100A}{100 + RT} = \\mathbf{${formatMoneyLaTeX(principalVal, currency)}}",
          amountBarLaTeX:
          "\\text{Amount } (${formatMoneyLaTeX(amountVal, currency)}) = \\text{Principal } (${formatMoneyLaTeX(principalVal, currency)}) + \\text{Interest } (${formatMoneyLaTeX(interestVal, currency)})",
          principalProportion:
          amountVal > 0 ? (principalVal / amountVal).clamp(0.25, 0.85) : 0.75,
          interestProportion:
          amountVal > 0 ? (interestVal / amountVal).clamp(0.15, 0.75) : 0.25,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Principal } (P) = \\mathbf{${formatMoneyLaTeX(principalVal, currency)}}",
        ),
      );
    } catch (e) {
      return SimpleInterestResult.error(
        mode: 3,
        subMode: subMode,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers.",
      );
    }
  }
}