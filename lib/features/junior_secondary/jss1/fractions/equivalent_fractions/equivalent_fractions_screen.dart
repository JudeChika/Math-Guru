import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_fonts/google_fonts.dart';
import 'equivalent_fractions_logic.dart';
import 'equivalent_fractions_models.dart';

class EquivalentFractionsScreen extends StatefulWidget {
  const EquivalentFractionsScreen({super.key});

  @override
  State<EquivalentFractionsScreen> createState() => _EquivalentFractionsScreenState();
}

class _EquivalentFractionsScreenState extends State<EquivalentFractionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _num1Controller = TextEditingController();
  final _den1Controller = TextEditingController();
  final _num2Controller = TextEditingController();
  final _den2Controller = TextEditingController();

  String? _errorMsg;
  String? _result;
  List<String> _workingsLatex = [];
  List<EquivalentFractionExplanationStep> _explanations = [];

  void _solve() {
    setState(() {
      _errorMsg = null;
      _result = null;
      _workingsLatex = [];
      _explanations = [];
    });

    final n1 = _num1Controller.text.trim();
    final d1 = _den1Controller.text.trim();
    final n2 = _num2Controller.text.trim();
    final d2 = _den2Controller.text.trim();

    final solution = EquivalentFractionsLogic.solve(
      n1Raw: n1,
      d1Raw: d1,
      n2Raw: n2,
      d2Raw: d2,
    );

    if (solution == null) {
      setState(() {
        _errorMsg =
        "Invalid input. Ensure exactly one field is 'x', denominators are not zero, and all entries are valid numbers where required.";
      });
      return;
    }

    setState(() {
      _result = solution.answerSimple;
      _workingsLatex = solution.workingsLatex;
      _explanations = solution.explanations;
    });
  }

  Widget _workingMathLine(String latex) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Math.tex(
      latex,
      textStyle: GoogleFonts.poppins(fontSize: 21, color: Colors.deepPurple, fontWeight: FontWeight.w600),
      mathStyle: MathStyle.display,
    ),
  );

  Widget _explanationCard(int step, EquivalentFractionExplanationStep s) {
    return Card(
      color: Colors.purple.shade50,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade100,
          child: Text(
            '$step',
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
              s.description,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple[800],
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            if (s.latexMath != null)
              Math.tex(
                s.latexMath!,
                textStyle: GoogleFonts.poppins(fontSize: 20, color: Colors.deepPurple),
                mathStyle: MathStyle.display,
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _num1Controller.dispose();
    _den1Controller.dispose();
    _num2Controller.dispose();
    _den2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputStyle = GoogleFonts.poppins(fontSize: 16);
    final labelStyle = GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.deepPurple);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Equivalent Fractions',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Fill in the values for three fields, leave one blank for 'x':",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Both layouts now use Expanded so that fields fill the row
                  if (constraints.maxWidth < 430) {
                    // Small screen: stack vertically
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _fractionInput(
                                controller: _num1Controller,
                                label: 'Numerator 1',
                                style: inputStyle,
                                labelStyle: labelStyle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text("/", style: inputStyle.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 5),
                            Expanded(
                              child: _fractionInput(
                                controller: _den1Controller,
                                label: 'Denominator 1',
                                style: inputStyle,
                                labelStyle: labelStyle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text("=", style: inputStyle.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _fractionInput(
                                controller: _num2Controller,
                                label: 'Numerator 2',
                                style: inputStyle,
                                labelStyle: labelStyle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text("/", style: inputStyle.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 5),
                            Expanded(
                              child: _fractionInput(
                                controller: _den2Controller,
                                label: 'Denominator 2',
                                style: inputStyle,
                                labelStyle: labelStyle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    // Large screen: show in a row
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _fractionInput(
                            controller: _num1Controller,
                            label: 'Numerator 1',
                            style: inputStyle,
                            labelStyle: labelStyle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text("/", style: inputStyle.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: _fractionInput(
                            controller: _den1Controller,
                            label: 'Denominator 1',
                            style: inputStyle,
                            labelStyle: labelStyle,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text("=", style: inputStyle.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _fractionInput(
                            controller: _num2Controller,
                            label: 'Numerator 2',
                            style: inputStyle,
                            labelStyle: labelStyle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text("/", style: inputStyle.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: _fractionInput(
                            controller: _den2Controller,
                            label: 'Denominator 2',
                            style: inputStyle,
                            labelStyle: labelStyle,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMsg != null)
              Text(
                _errorMsg!,
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
              ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                onPressed: _solve,
                child: const Text("Solve", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
            if (_result != null)
              Center(
                child: Column(
                  children: [
                    Text(
                      "Final Answer:",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                    Text(
                      _result!,
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
            if (_workingsLatex.isNotEmpty)
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
                            for (final step in _workingsLatex)
                              _workingMathLine(step),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (_explanations.isNotEmpty)
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
                  for (int i = 0; i < _explanations.length; i++)
                    _explanationCard(i + 1, _explanations[i]),
                ],
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
      keyboardType: TextInputType.text,
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