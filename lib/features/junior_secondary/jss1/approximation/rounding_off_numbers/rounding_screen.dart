import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_guru/features/junior_secondary/jss1/approximation/rounding_off_numbers/rounding_logic.dart';

class RoundingScreen extends StatefulWidget {
  const RoundingScreen({super.key});

  @override
  State<RoundingScreen> createState() => _RoundingScreenState();
}

class _RoundingScreenState extends State<RoundingScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedMode = 'Nearest Unit';
  List<SolutionStep> _steps = [];
  String? _finalResultLatex;
  String? _finalResultExplanation;
  String? _receivedInputLatex;

  final List<String> _roundingModes = [
    'Nearest Unit',
    'Nearest Ten',
    'Nearest Hundred',
    'Nearest Thousand',
    'Nearest Tenth',
    'Nearest Hundredth',
    'Nearest Thousandth',
    '1dp',
    '2dp',
    '3dp',
    '4dp',
    '5dp',
    '1sf',
    '2sf',
    '3sf',
    '4sf',
    '5sf',
  ];

  void _calculateRounding() {
    final input = _controller.text.trim();
    final result = RoundingSolver.solve(input, _selectedMode);

    // Separate math and explanation for the final result
    String mathResult = result.finalLatex.split(r'\text').first.trim();
    String? explanation;
    final expMatch = RegExp(r'\\text\{(.+?)\}').firstMatch(result.finalLatex);
    if (expMatch != null) {
      explanation = expMatch.group(1);
    }

    setState(() {
      _steps = result.steps;
      _finalResultLatex = mathResult;
      _finalResultExplanation = explanation;
      _receivedInputLatex = result.inputLatex;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildMathOrText(String latex) {
    try {
      // Only render as Math.tex if it looks like a formula, not plain text
      if (latex.trim().startsWith(r"\") ||
          latex.contains(r"_") ||
          latex.contains(r"frac") ||
          latex.contains('=') ||
          latex.contains(r"\text")) {
        return Math.tex(
          latex,
          textStyle: GoogleFonts.poppins(fontSize: 20, color: Colors.deepPurple),
          mathStyle: MathStyle.display,
        );
      } else {
        return Text(
          latex,
          style: GoogleFonts.poppins(fontSize: 20, color: Colors.deepPurple),
          softWrap: true,
        );
      }
    } catch (_) {
      return Text(
        latex,
        style: GoogleFonts.poppins(fontSize: 20, color: Colors.deepPurple),
        softWrap: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputStyle = GoogleFonts.poppins(fontSize: 16);
    final labelStyle = GoogleFonts.poppins(
        fontWeight: FontWeight.w600, color: Colors.deepPurple);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rounding Off Numbers',
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
              "Enter a number (e.g. 1947.6, 2/3, 2 1/4, 225 1/2, 24874):",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _controller,
              style: inputStyle,
              decoration: InputDecoration(
                labelText: "Input Number",
                labelStyle: labelStyle,
                border: const OutlineInputBorder(),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: _selectedMode,
              items: _roundingModes
                  .map((mode) => DropdownMenuItem(
                value: mode,
                child: Text(mode),
              ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedMode = val;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: "Select Rounding Mode",
                labelStyle: labelStyle,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  textStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 17),
                ),
                onPressed: _calculateRounding,
                child: const Text("Round Off",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 28),

            // Final Result
            if (_finalResultLatex != null)
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Math.tex(
                        _finalResultLatex!,
                        textStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                          color: Colors.green[700],
                        ),
                        mathStyle: MathStyle.display,
                      ),
                    ),
                    if (_finalResultExplanation != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _finalResultExplanation!,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.green[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Solution Section (Working)
            if (_steps.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Solution:",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Card(
                    color: Colors.purple.shade50,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _steps
                            .map((step) => Padding(
                          padding:
                          const EdgeInsets.symmetric(vertical: 6),
                          child: _buildMathOrText(step.latex),
                        ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),

            // Step-by-step Section
            if (_steps.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Step-by-step Explanation:",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.deepPurple,
                    ),
                  ),
                  ..._steps.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final step = entry.value;
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
                            if (step.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  step.description,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.deepPurple[800],
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            _buildMathOrText(step.latex),
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