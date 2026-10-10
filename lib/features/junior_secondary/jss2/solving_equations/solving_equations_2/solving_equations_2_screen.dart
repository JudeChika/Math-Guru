import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'solving_equations_2_logic.dart';
import 'solving_equations_2_models.dart';

class SolvingEquations2Screen extends StatefulWidget {
  const SolvingEquations2Screen({super.key});

  @override
  State<SolvingEquations2Screen> createState() => _SolvingEquations2ScreenState();
}

class _SolvingEquations2ScreenState extends State<SolvingEquations2Screen> {
  final TextEditingController _equationController = TextEditingController();
  Equation2Result? _result;

  @override
  void dispose() {
    _equationController.dispose();
    super.dispose();
  }

  void _insertText(String text) {
    final currentText = _equationController.text;
    final selection = _equationController.selection;

    if (selection.start >= 0) {
      final newText = currentText.replaceRange(selection.start, selection.end, text);
      _equationController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + text.length),
      );
    } else {
      _equationController.text += text;
    }
  }

  void _solve() {
    FocusScope.of(context).unfocus();
    if (_equationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an equation.')));
      return;
    }
    setState(() {
      _result = SolvingEquations2Logic.solve(_equationController.text);
    });
  }

  Widget _buildMathBtn(String text, String tooltip) {
    return ActionChip(
      label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      tooltip: tooltip,
      backgroundColor: Colors.grey.shade200,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onPressed: () => _insertText(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solving Equations (2)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber),
                  SizedBox(width: 12),
                  Expanded(child: Text("Advanced Equations! We will strictly follow the order: Clear Fractions (LCM) → Expand Brackets → Collect Terms.", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _equationController,
              keyboardType: TextInputType.text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: "Complex Equation",
                hintText: "e.g. (3x - 2)/6 - (2x + 7)/9 = 0",
                prefixIcon: const Icon(Icons.balance, color: Colors.deepPurple),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _solve(),
            ),

            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildMathBtn('+', 'Add'),
                _buildMathBtn('-', 'Subtract / Negative'),
                _buildMathBtn('=', 'Equals (Required)'),
                _buildMathBtn('(', 'Open Bracket'),
                _buildMathBtn(')', 'Close Bracket'),
                _buildMathBtn('/', 'Fraction / Divide'),
                _buildMathBtn('x', 'Variable X'),
                _buildMathBtn('m', 'Variable M'),
              ],
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _solve,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Solve & Check", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            if (_result != null && !_result!.valid)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                  child: Text(
                    _result!.errorMessage ?? 'Invalid format.',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

            if (_result != null && _result!.valid) ...[
              const SizedBox(height: 32),
              const Text("Final Answer:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
              const SizedBox(height: 8),
              Card(
                color: Colors.green.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Math.tex(
                          _result!.finalAnswerLaTeX,
                          textStyle: const TextStyle(fontSize: 42, color: Colors.green, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text("Mathematical Workings:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
              const SizedBox(height: 8),
              Card(
                color: Colors.deepPurple.shade50,
                elevation: 0.5,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < _result!.workingsLaTeX.length; i++)
                        if (_result!.workingsLaTeX[i].isEmpty)
                          const SizedBox(height: 12)
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Math.tex(
                                  i == 0 || _result!.workingsLaTeX[i].contains('\\text{') || _result!.workingsLaTeX[i].contains('=')
                                      ? _result!.workingsLaTeX[i]
                                      : "\\Rightarrow ${_result!.workingsLaTeX[i]}",
                                  textStyle: const TextStyle(fontSize: 20, color: Colors.deepPurple)
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text("Step-by-Step Breakdown:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
              const SizedBox(height: 8),
              ..._result!.steps.asMap().entries.map((e) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    foregroundColor: Colors.deepPurple,
                    child: Text('${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  title: Text(e.value.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(e.value.description, style: TextStyle(color: Colors.grey.shade800, fontSize: 14, height: 1.4)),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Math.tex(
                              e.value.mathLaTeX,
                              textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)
                          ),
                        )
                      ]
                  ),
                ),
              )),
              const SizedBox(height: 40),
            ]
          ],
        ),
      ),
    );
  }
}