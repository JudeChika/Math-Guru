import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_fonts/google_fonts.dart';

import 'rounding_logic.dart';

class RoundingScreen extends StatefulWidget {
  const RoundingScreen({super.key});

  @override
  State<RoundingScreen> createState() => _RoundingScreenState();
}

class _RoundingScreenState extends State<RoundingScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedMode = 'Nearest Ten';
  List<RoundingStep> _steps = [];
  List<String> _workingLatex = [];
  String? _finalResult;
  String? _receivedInputLatex;

  final List<String> _roundingModes = [
    'Nearest Unit',
    'Nearest Ten',
    'Nearest Hundred',
    'Nearest Tenth',
    'Nearest Hundredth',
    'Nearest Thousandth',
    '1dp',
    '2dp',
    '3dp',
    '1sf',
    '2sf',
    '3sf',
  ];

  void _calculateRounding() {
    final input = _controller.text.trim();
    final result = RoundingLogic.roundOff(input, _selectedMode);

    if (result.isNotEmpty) {
      // Separate final result and workings
      final finalStep = result.last;
      final roundedValue = finalStep.latexMath?.split('≈').last.trim();

      List<String> workings = result
          .map((step) => step.latexMath)
          .where((latex) => latex != null)
          .map((latex) => latex!)
          .toList();

      setState(() {
        _steps = result;
        _workingLatex = workings;
        _finalResult = roundedValue;
        // Always display the original input as formatted LaTeX
        _receivedInputLatex = RoundingLogic.inputToLatex(input);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
              "Enter a number (e.g. 1947.6, 2/3, 2 1/4):",
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
                child: const Text("Round Off", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),

            /// Display Received Input in Math.tex
            if (_receivedInputLatex != null && _receivedInputLatex!.trim().isNotEmpty)
              Center(
                child: Column(
                  children: [
                    Text(
                      "Received Input:",
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple[800],
                      ),
                    ),
                    Math.tex(
                      _receivedInputLatex!,
                      textStyle: GoogleFonts.poppins(
                          fontSize: 28, color: Colors.deepPurple[700]),
                      mathStyle: MathStyle.display,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            /// Final Result
            if (_finalResult != null)
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
                      _finalResult!,
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

            /// Working Section
            if (_workingLatex.isNotEmpty)
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
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _workingLatex
                            .map((latex) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Math.tex(
                            latex,
                            textStyle: GoogleFonts.poppins(
                                fontSize: 20, color: Colors.deepPurple),
                            mathStyle: MathStyle.display,
                          ),
                        ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),

            /// Step-by-step Explanation Section
            if (_steps.isNotEmpty)
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
                            Text(
                              step.description,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.deepPurple[800],
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (step.latexMath != null)
                              Math.tex(
                                step.latexMath!,
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