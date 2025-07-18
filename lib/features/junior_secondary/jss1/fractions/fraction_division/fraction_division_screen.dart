import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fraction_models.dart';
import 'fraction_division_logic.dart';

class FractionDivisionScreen extends StatefulWidget {
  const FractionDivisionScreen({super.key});

  @override
  State<FractionDivisionScreen> createState() => _FractionDivisionScreenState();
}

class _FractionDivisionScreenState extends State<FractionDivisionScreen> {
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController()
  ];

  String? _result;
  List<FractionWorkingStep> _workings = [];
  List<FractionExplanation> _explanations = [];

  void _addInput() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _calculate() {
    final inputs = _controllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    if (inputs.length < 2) return;

    final solution = FractionDivisionLogic.solve(inputs);

    setState(() {
      _result = solution?.finalLatex;
      _workings = solution?.workings ?? [];
      _explanations = solution?.explanations ?? [];
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputStyle = GoogleFonts.poppins(fontSize: 16);
    final labelStyle = GoogleFonts.poppins(
        fontWeight: FontWeight.w600, color: Colors.deepPurple);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Division of Fractions",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter numbers to divide (e.g. 8 ÷ 1/3 or 1/2 ÷ 1 1/4):",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            ..._controllers.map((controller) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: controller,
                style: inputStyle,
                decoration: InputDecoration(
                  labelText: "Number or Fraction",
                  labelStyle: labelStyle,
                  border: const OutlineInputBorder(),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                ),
              ),
            )),
            Center(
              child: TextButton.icon(
                onPressed: _addInput,
                icon: const Icon(Icons.add, color: Colors.deepPurple),
                label: Text(
                  "Add More Inputs",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  textStyle:
                  GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                onPressed: _calculate,
                child: const Text(
                  "Divide Fractions",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_result != null)
              Center(
                child: Column(
                  children: [
                    Text(
                      "Result:",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                    Math.tex(
                      _result!,
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
            const SizedBox(height: 20),
            if (_workings.isNotEmpty)
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _workings
                            .map((step) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Math.tex(
                            step.latexMath,
                            textStyle: GoogleFonts.poppins(
                                fontSize: 20,
                                color: Colors.deepPurple),
                            mathStyle: MathStyle.display,
                          ),
                        ))
                            .toList(),
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
                  ..._explanations.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final explanation = entry.value;
                    return Card(
                      color: Colors.purple.shade50,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade100,
                          child: Text(
                            '$index',
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
                              explanation.description,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.deepPurple[800],
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (explanation.latexMath != null)
                              Math.tex(
                                explanation.latexMath!,
                                textStyle: GoogleFonts.poppins(
                                    fontSize: 20, color: Colors.deepPurple),
                                mathStyle: MathStyle.display,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
