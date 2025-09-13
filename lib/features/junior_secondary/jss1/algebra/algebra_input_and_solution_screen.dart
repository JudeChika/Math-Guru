import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_fonts/google_fonts.dart';

import 'algebra_models.dart';
import 'algebra_solver.dart';

class AlgebraInputAndSolutionScreen extends StatefulWidget {
  const AlgebraInputAndSolutionScreen({super.key});

  @override
  State<AlgebraInputAndSolutionScreen> createState() => _AlgebraInputAndSolutionScreenState();
}

class _AlgebraInputAndSolutionScreenState extends State<AlgebraInputAndSolutionScreen> {
  final TextEditingController _equationController = TextEditingController();
  final TextEditingController _variableController = TextEditingController();
  String _selectedOperator = '+';
  List<String> operators = ['+', '-', '×', '÷', '='];
  AlgebraSolution? _solution;
  String? _error;

  void _solveEquation() {
    setState(() {
      _error = null;
      final equation = _equationController.text.trim();
      final variable = _variableController.text.trim();
      if (equation.isEmpty) {
        _error = "Please enter an equation.";
        _solution = null;
        return;
      }
      final solution = AlgebraSolver.solve(equation, solveFor: variable.isEmpty ? null : variable);
      if (solution != null) {
        _solution = solution;
      } else {
        _error = "Solver could not process this equation.";
        _solution = null;
      }
    });
  }

  void _clearAll() {
    setState(() {
      _equationController.text = '';
      _variableController.text = '';
      _solution = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final inputStyle = GoogleFonts.poppins(fontSize: 16);
    final labelStyle = GoogleFonts.poppins(
        fontWeight: FontWeight.w600, color: Colors.deepPurple);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Algebra: World Problems',
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
              "Enter your algebraic equation:",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _equationController,
              style: inputStyle,
              decoration: InputDecoration(
                labelText: "Equation (e.g. x + 4 = 7, 5x = 45, 3x - 40 = 10 - 2x)",
                labelStyle: labelStyle,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Which variable to solve for? (optional):",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _variableController,
              style: inputStyle,
              decoration: InputDecoration(
                labelText: "Variable (e.g. x, w, p, y, z)",
                labelStyle: labelStyle,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Select an operator for your equation:",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: operators
                  .map((op) => Row(
                children: [
                  Radio<String>(
                    value: op,
                    groupValue: _selectedOperator,
                    activeColor: Colors.deepPurple,
                    onChanged: (v) {
                      setState(() {
                        _selectedOperator = v!;
                      });
                    },
                  ),
                  Text(
                    op,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  textStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 17),
                ),
                onPressed: _solveEquation,
                child: const Text("Solve Equation", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _clearAll,
              icon: const Icon(Icons.add, color: Colors.deepPurple),
              label: Text(
                "Add Another Equation",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  _error!,
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (_solution != null)
              ...[
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Final Solution:",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                      Math.tex(
                        _solution!.finalLatex,
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
                if (_solution!.workings.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Workings:",
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
                            children: _solution!.workings
                                .map((step) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Math.tex(
                                step.latex,
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
                if (_solution!.explanations.isNotEmpty)
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
                      ..._solution!.explanations.asMap().entries.map((entry) {
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
                                Math.tex(
                                  explanation.latex,
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
              ]
          ],
        ),
      ),
    );
  }
}