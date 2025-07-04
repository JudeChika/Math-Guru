import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../conversion_to_decimal/conversion_to_decimal_logic.dart';
import '../conversion_to_decimal/conversion_to_decimal_models.dart';
import '../conversion_to_decimal/long_division_decimal_logic.dart';
import '../conversion_to_decimal/long_division_step.dart';
import '../conversion_to_decimal/long_division_decimal_widget.dart';
import 'decimal_to_fraction_logic.dart';
import 'decimal_to_fraction_models.dart';

class ConversionToDecimalAndFractionScreen extends StatefulWidget {
  const ConversionToDecimalAndFractionScreen({super.key});

  @override
  State<ConversionToDecimalAndFractionScreen> createState() => _ConversionToDecimalAndFractionScreenState();
}

class _ConversionToDecimalAndFractionScreenState extends State<ConversionToDecimalAndFractionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Fraction to Decimal State
  final _numController = TextEditingController();
  final _denController = TextEditingController();
  String? _errorMsgDec;
  String? _resultDec;
  List<String> _workingsLatexDec = [];
  List<DecimalConversionExplanationStep> _explanationsDec = [];
  DecimalConversionMethod _methodDec = DecimalConversionMethod.knownFacts;
  List<LongDivisionStep> _longDivisionSteps = [];
  String _longDivisionQuotient = "";
  bool _hasConvertedDec = false;

  // --- Decimal to Fraction State
  final _decimalController = TextEditingController();
  String? _errorMsgFrac;
  String? _resultFrac;
  List<String> _workingsLatexFrac = [];
  List<DecimalToFractionExplanationStep> _explanationsFrac = [];
  bool _hasConvertedFrac = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // =========================
  // Fraction to Decimal Logic
  // =========================
  void _convertFractionToDecimal({bool triggeredByToggle = false}) {
    final numerator = _numController.text.trim();
    final denominator = _denController.text.trim();

    if (numerator.isEmpty || denominator.isEmpty) {
      setState(() {
        _errorMsgDec = "Please enter both numerator and denominator.";
        _resultDec = null;
        _workingsLatexDec = [];
        _explanationsDec = [];
        _longDivisionSteps = [];
        _longDivisionQuotient = "";
        _hasConvertedDec = false;
      });
      return;
    }

    setState(() {
      _errorMsgDec = null;
      _resultDec = null;
      _workingsLatexDec = [];
      _explanationsDec = [];
      _longDivisionSteps = [];
      _longDivisionQuotient = "";
    });

    if (_methodDec == DecimalConversionMethod.knownFacts) {
      var solution = ConversionToDecimalLogic.knownFactsMethod(
        numeratorRaw: numerator,
        denominatorRaw: denominator,
      );
      if (solution == null) {
        setState(() {
          _errorMsgDec = "Invalid input. Make sure both fields are numbers and denominator is not zero.";
          _hasConvertedDec = false;
        });
        return;
      }
      setState(() {
        _resultDec = solution.answer;
        _workingsLatexDec = solution.workingsLatex;
        _explanationsDec = solution.explanations;
        _hasConvertedDec = true;
      });
    } else {
      var solution = LongDivisionDecimalLogic.perform(
        numeratorRaw: numerator,
        denominatorRaw: denominator,
        maxDecimalPlaces: 6,
      );
      if (solution == null) {
        setState(() {
          _errorMsgDec = "Invalid input. Make sure both fields are numbers and denominator is not zero.";
          _hasConvertedDec = false;
        });
        return;
      }
      setState(() {
        _resultDec = solution.answer;
        _explanationsDec = solution.explanations;
        _longDivisionSteps = solution.steps;
        _longDivisionQuotient = solution.answer;
        _hasConvertedDec = true;
      });
    }
  }

  void _onDecMethodToggled(DecimalConversionMethod method) {
    setState(() {
      _methodDec = method;
    });
    if (_hasConvertedDec) {
      _convertFractionToDecimal(triggeredByToggle: true);
    }
  }

  // =========================
  // Decimal to Fraction Logic
  // =========================
  void _convertDecimalToFraction() {
    final decimalInput = _decimalController.text.trim();

    if (decimalInput.isEmpty) {
      setState(() {
        _errorMsgFrac = "Please enter a decimal number.";
        _resultFrac = null;
        _workingsLatexFrac = [];
        _explanationsFrac = [];
        _hasConvertedFrac = false;
      });
      return;
    }

    setState(() {
      _errorMsgFrac = null;
      _resultFrac = null;
      _workingsLatexFrac = [];
      _explanationsFrac = [];
    });

    var solution = DecimalToFractionLogic.convert(decimalInput);
    if (solution == null) {
      setState(() {
        _errorMsgFrac = "Invalid input. Enter a valid decimal number.";
        _hasConvertedFrac = false;
      });
      return;
    }
    setState(() {
      _resultFrac = solution.finalLatex;
      _workingsLatexFrac = solution.workingLatex;
      _explanationsFrac = solution.explanations;
      _hasConvertedFrac = true;
    });
  }

  @override
  void dispose() {
    _numController.dispose();
    _denController.dispose();
    _decimalController.dispose();
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
            'Conversion to Decimal & Fraction',
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
              Tab(text: "Fraction to Decimal"),
              Tab(text: "Decimal to Fraction"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // ==== Tab 1: Fraction to Decimal ====
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter the numerator and denominator of the fraction to convert to decimal:",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _fractionInput(
                          controller: _numController,
                          label: 'Numerator',
                          style: inputStyle,
                          labelStyle: labelStyle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text("/", style: inputStyle.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: _fractionInput(
                          controller: _denController,
                          label: 'Denominator',
                          style: inputStyle,
                          labelStyle: labelStyle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ChoiceChip(
                        label: Text("Known Facts"),
                        selected: _methodDec == DecimalConversionMethod.knownFacts,
                        onSelected: (_) {
                          _onDecMethodToggled(DecimalConversionMethod.knownFacts);
                        },
                        selectedColor: Colors.deepPurple.shade100,
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: Text("Long Division"),
                        selected: _methodDec == DecimalConversionMethod.longDivision,
                        onSelected: (_) {
                          _onDecMethodToggled(DecimalConversionMethod.longDivision);
                        },
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
                      onPressed: _convertFractionToDecimal,
                      child: const Text("Convert", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_errorMsgDec != null)
                    Text(
                      _errorMsgDec!,
                      style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
                    ),
                  if (_resultDec != null)
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
                            _resultDec!,
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
                  // "Working" only for Known Facts
                  if (_methodDec == DecimalConversionMethod.knownFacts && _workingsLatexDec.isNotEmpty)
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
                                  for (final step in _workingsLatexDec)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Math.tex(
                                          step,
                                          textStyle: GoogleFonts.poppins(fontSize: 21, color: Colors.deepPurple, fontWeight: FontWeight.w600),
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
                  // Long Division Visual only for Long Division
                  if (_methodDec == DecimalConversionMethod.longDivision && _longDivisionSteps.isNotEmpty)
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
                              numerator: int.tryParse(_numController.text) ?? 0,
                              denominator: int.tryParse(_denController.text) ?? 1,
                              steps: _longDivisionSteps,
                              decimalQuotient: _longDivisionQuotient,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (_explanationsDec.isNotEmpty)
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
                        for (int i = 0; i < _explanationsDec.length; i++)
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
                                    _explanationsDec[i].description,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.deepPurple[800],
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (_explanationsDec[i].latexMath != null)
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Math.tex(
                                        _explanationsDec[i].latexMath!,
                                        textStyle: GoogleFonts.poppins(fontSize: 20, color: Colors.deepPurple),
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
            // ==== Tab 2: Decimal to Fraction ====
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter the decimal number to convert to a fraction in its lowest term:",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _decimalController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    style: inputStyle,
                    decoration: InputDecoration(
                      labelText: "Decimal Number",
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
                      onPressed: _convertDecimalToFraction,
                      child: const Text("Convert", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_errorMsgFrac != null)
                    Text(
                      _errorMsgFrac!,
                      style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
                    ),
                  if (_resultFrac != null)
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
                            _resultFrac!,
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
                  if (_workingsLatexFrac.isNotEmpty)
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
                                  for (final step in _workingsLatexFrac)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Math.tex(
                                          step,
                                          textStyle: GoogleFonts.poppins(fontSize: 21, color: Colors.deepPurple, fontWeight: FontWeight.w600),
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
                  if (_explanationsFrac.isNotEmpty)
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
                        for (int i = 0; i < _explanationsFrac.length; i++)
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
                                    _explanationsFrac[i].description,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.deepPurple[800],
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (_explanationsFrac[i].latexMath != null)
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Math.tex(
                                        _explanationsFrac[i].latexMath!,
                                        textStyle: GoogleFonts.poppins(fontSize: 20, color: Colors.deepPurple),
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

  Widget _fractionInput({
    required TextEditingController controller,
    required String label,
    required TextStyle style,
    required TextStyle labelStyle,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: style,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: labelStyle,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      ),
    );
  }
}