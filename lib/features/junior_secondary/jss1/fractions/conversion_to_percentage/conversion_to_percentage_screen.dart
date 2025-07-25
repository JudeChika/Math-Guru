import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../conversion_to_decimal/conversion_to_decimal_models.dart';
import '../conversion_to_decimal/long_division_decimal_logic.dart';
import '../conversion_to_decimal/long_division_decimal_widget.dart';
import 'fraction_decimal_to_percentage_logic.dart';
import 'percentage_to_fraction_logic.dart';
import 'percentage_conversion_models.dart';

enum PercentageConversionOutputType { fraction, decimal }

class ConversionToPercentageScreen extends StatefulWidget {
  const ConversionToPercentageScreen({super.key});

  @override
  State<ConversionToPercentageScreen> createState() => _ConversionToPercentageScreenState();
}

class _ConversionToPercentageScreenState extends State<ConversionToPercentageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Tab 1: Fraction/Decimal -> Percentage
  final _fracDecController = TextEditingController();
  String? _errorMsg1;
  String? _result1;
  List<String> _workingsLatex1 = [];
  List<PercentageConversionExplanationStep> _explanations1 = [];
  bool _hasConverted1 = false;

  /// Tab 2: Percentage -> Fraction/Decimal
  final _percController = TextEditingController();
  String? _errorMsg2;
  String? _result2;
  List<String> _workingsLatex2 = [];
  List<PercentageConversionExplanationStep> _explanations2 = [];
  bool _hasConverted2 = false;
  PercentageConversionOutputType _outputType = PercentageConversionOutputType.fraction;

  /// For decimal output
  String? _decimalResult2;
  List<DecimalConversionExplanationStep> _decimalExplanations2 = [];
  List<String> _decimalWorkingsLatex2 = [];
  List _longDivisionSteps2 = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  /// Tab 1
  void _convertFracDecToPerc() {
    final input = _fracDecController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _errorMsg1 = "Please enter a fraction or decimal number.";
        _result1 = null;
        _workingsLatex1 = [];
        _explanations1 = [];
        _hasConverted1 = false;
      });
      return;
    }
    setState(() {
      _errorMsg1 = null;
      _result1 = null;
      _workingsLatex1 = [];
      _explanations1 = [];
    });

    var solution = FractionDecimalToPercentageLogic.convert(input);
    if (solution == null) {
      setState(() {
        _errorMsg1 = "Invalid input. Enter a valid fraction (e.g. 2/5) or decimal (e.g. 0.25).";
        _hasConverted1 = false;
      });
      return;
    }
    setState(() {
      _result1 = solution.finalLatex;
      _workingsLatex1 = solution.workingLatex;
      _explanations1 = solution.explanations;
      _hasConverted1 = true;
    });
  }

  /// Tab 2
  void _convertPercToFracOrDecimal() {
    final input = _percController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _errorMsg2 = "Please enter a percentage (e.g. 15%, 4 1/2%, 10.5%).";
        _result2 = null;
        _workingsLatex2 = [];
        _explanations2 = [];
        _hasConverted2 = false;
        _decimalResult2 = null;
        _decimalExplanations2 = [];
        _decimalWorkingsLatex2 = [];
        _longDivisionSteps2 = [];
      });
      return;
    }
    setState(() {
      _errorMsg2 = null;
      _result2 = null;
      _workingsLatex2 = [];
      _explanations2 = [];
      _decimalResult2 = null;
      _decimalExplanations2 = [];
      _decimalWorkingsLatex2 = [];
      _longDivisionSteps2 = [];
    });

    var solution = PercentageToFractionLogic.convert(input);
    if (solution == null) {
      setState(() {
        _errorMsg2 = "Invalid input. Enter a valid percentage (e.g. 15%, 4 1/2%, 10.5%).";
        _hasConverted2 = false;
      });
      return;
    }

    setState(() {
      _result2 = solution.finalLatex;
      _workingsLatex2 = solution.workingLatex;
      _explanations2 = solution.explanations;
      _hasConverted2 = true;
    });

    // If user wants decimal, perform long division on the final fraction
    if (_outputType == PercentageConversionOutputType.decimal) {
      final frac = PercentageToFractionLogic.extractFraction(input);
      if (frac != null) {
        final numerator = frac['numerator'];
        final denominator = frac['denominator'];
        final longDiv = LongDivisionDecimalLogic.perform(
          numeratorRaw: numerator.toString(),
          denominatorRaw: denominator.toString(),
          maxDecimalPlaces: 6,
        );
        if (longDiv != null) {
          setState(() {
            _decimalResult2 = longDiv.answer;
            _decimalWorkingsLatex2 = longDiv.workingsLatex;
            _decimalExplanations2 = longDiv.explanations;
            _longDivisionSteps2 = longDiv.steps;
          });
        }
      }
    }
  }

  void _onOutputTypeChanged(PercentageConversionOutputType? type) {
    if (type == null) return;
    setState(() {
      _outputType = type;
    });
    if (_hasConverted2) {
      _convertPercToFracOrDecimal();
    }
  }

  @override
  void dispose() {
    _fracDecController.dispose();
    _percController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputStyle = GoogleFonts.poppins(fontSize: 16);
    final labelStyle = GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.deepPurple);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Conversion to Percentage',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.deepPurple,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: "Frac/Dec to %"),
              Tab(text: "% to Fraction"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            /// Tab 1: Fraction/Decimal -> Percentage
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter a fraction (e.g. 3/5) or decimal (e.g. 0.25) to convert to percentage:",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _fracDecController,
                    keyboardType: TextInputType.text,
                    style: inputStyle,
                    decoration: InputDecoration(
                      labelText: "Fraction or Decimal",
                      labelStyle: labelStyle,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      onPressed: _convertFracDecToPerc,
                      child: const Text("Convert", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_errorMsg1 != null)
                    Text(
                      _errorMsg1!,
                      style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
                    ),
                  if (_result1 != null)
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "Percentage Value:",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                          Math.tex(
                            _result1!,
                            textStyle: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: Colors.green[700],
                            ),
                            mathStyle: MathStyle.display,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 18),
                  if (_workingsLatex1.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Working:",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          color: Colors.purple.shade50,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final step in _workingsLatex1)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Math.tex(
                                          step,
                                          textStyle: GoogleFonts.poppins(
                                            fontSize: 21,
                                            color: Colors.deepPurple,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          mathStyle: MathStyle.display,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (_explanations1.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          "Step-by-step Solution:",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (int i = 0; i < _explanations1.length; i++)
                          Card(
                            color: Colors.purple.shade50,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepPurple.shade100,
                                child: Text(
                                  '${i + 1}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _explanations1[i].description,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.deepPurple[800],
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (_explanations1[i].latexMath != null)
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Math.tex(
                                        _explanations1[i].latexMath!,
                                        textStyle: GoogleFonts.poppins(
                                            fontSize: 20, color: Colors.deepPurple),
                                        mathStyle: MathStyle.display,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            /// Tab 2: Percentage -> Fraction/Decimal
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter a percentage (e.g. 15%, 4 1/2%, 10.5%) to convert to a fraction or decimal:",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _percController,
                    keyboardType: TextInputType.text,
                    style: inputStyle,
                    decoration: InputDecoration(
                      labelText: "Percentage (with or without % sign)",
                      labelStyle: labelStyle,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text("Fraction"),
                        selected: _outputType == PercentageConversionOutputType.fraction,
                        onSelected: (_) => _onOutputTypeChanged(PercentageConversionOutputType.fraction),
                        selectedColor: Colors.deepPurple.shade100,
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text("Decimal (Long Division)"),
                        selected: _outputType == PercentageConversionOutputType.decimal,
                        onSelected: (_) => _onOutputTypeChanged(PercentageConversionOutputType.decimal),
                        selectedColor: Colors.deepPurple.shade100,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      onPressed: _convertPercToFracOrDecimal,
                      child: const Text("Convert", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_errorMsg2 != null)
                    Text(
                      _errorMsg2!,
                      style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
                    ),
                  if (_outputType == PercentageConversionOutputType.fraction && _result2 != null)
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "Fraction Value:",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                          Math.tex(
                            _result2!,
                            textStyle: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: Colors.green[700],
                            ),
                            mathStyle: MathStyle.display,
                          ),
                        ],
                      ),
                    ),
                  if (_outputType == PercentageConversionOutputType.decimal && _decimalResult2 != null)
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "Decimal Value:",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                          Text(
                            _decimalResult2!,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 18),

                  // === WORKING / LONG DIVISION VISUAL ===
                  if (_outputType == PercentageConversionOutputType.fraction && _workingsLatex2.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Working:",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          color: Colors.purple.shade50,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final step in _workingsLatex2)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Math.tex(
                                          step,
                                          textStyle: GoogleFonts.poppins(
                                            fontSize: 21,
                                            color: Colors.deepPurple,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          mathStyle: MathStyle.display,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  // === LONG DIVISION VISUAL (when decimal is selected) ===
                  if (_outputType == PercentageConversionOutputType.decimal && _longDivisionSteps2.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Long Division Visual:",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          color: Colors.purple.shade50,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            child: LongDivisionDecimalWidget(
                              numerator: PercentageToFractionLogic.lastNumerator ?? 0,
                              denominator: PercentageToFractionLogic.lastDenominator ?? 1,
                              steps: _longDivisionSteps2,
                              decimalQuotient: _decimalResult2 ?? "",
                            ),
                          ),
                        ),
                      ],
                    ),

                  // === STEP BY STEP SOLUTION ===
                  if (_outputType == PercentageConversionOutputType.fraction && _explanations2.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          "Step-by-step Solution:",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (int i = 0; i < _explanations2.length; i++)
                          Card(
                            color: Colors.purple.shade50,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepPurple.shade100,
                                child: Text(
                                  '${i + 1}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _explanations2[i].description,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.deepPurple[800],
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (_explanations2[i].latexMath != null)
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Math.tex(
                                        _explanations2[i].latexMath!,
                                        textStyle: GoogleFonts.poppins(
                                            fontSize: 20, color: Colors.deepPurple),
                                        mathStyle: MathStyle.display,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  if (_outputType == PercentageConversionOutputType.decimal && _decimalExplanations2.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          "Step-by-step Solution:",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (int i = 0; i < _decimalExplanations2.length; i++)
                          Card(
                            color: Colors.purple.shade50,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepPurple.shade100,
                                child: Text(
                                  '${i + 1}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _decimalExplanations2[i].description,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.deepPurple[800],
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (_decimalExplanations2[i].latexMath != null)
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Math.tex(
                                        _decimalExplanations2[i].latexMath!,
                                        textStyle: GoogleFonts.poppins(
                                            fontSize: 20, color: Colors.deepPurple),
                                        mathStyle: MathStyle.display,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}