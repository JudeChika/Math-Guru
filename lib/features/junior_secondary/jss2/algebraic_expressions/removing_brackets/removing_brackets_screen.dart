import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'removing_brackets_logic.dart';
import 'removing_brackets_models.dart';

class RemovingBracketsScreen extends StatefulWidget {
  const RemovingBracketsScreen({super.key});

  @override
  State<RemovingBracketsScreen> createState() => _RemovingBracketsScreenState();
}

class _RemovingBracketsScreenState extends State<RemovingBracketsScreen> {
  final TextEditingController _inputController = TextEditingController();
  RemovingBracketsResult? _result;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _insertText(String text) {
    final currentText = _inputController.text;
    final selection = _inputController.selection;

    if (selection.start >= 0) {
      final newText = currentText.replaceRange(selection.start, selection.end, text);
      _inputController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + text.length),
      );
    } else {
      _inputController.text += text;
    }
  }

  void _solve() {
    FocusScope.of(context).unfocus();
    if (_inputController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an expression.')));
      return;
    }
    setState(() {
      _result = RemovingBracketsLogic.solve(_inputController.text);
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Removing Brackets')),
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
                  Icon(Icons.lightbulb, color: Colors.amber),
                  SizedBox(width: 12),
                  Expanded(child: Text("Expand algebraic expressions using the distributive law. Use fractions like 1/2(x+4) if needed!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _inputController,
              keyboardType: TextInputType.text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: "Expression with Brackets",
                hintText: "e.g. 3x(2x - 5) - 4(x + 2)",
                prefixIcon: const Icon(Icons.calculate, color: Colors.deepPurple),
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
                _buildMathBtn('(', 'Open Bracket'),
                _buildMathBtn(')', 'Close Bracket'),
                _buildMathBtn('x', 'Variable X'),
                _buildMathBtn('y', 'Variable Y'),
                _buildMathBtn('^2', 'Squared'),
                _buildMathBtn('/', 'Fraction / Divide'),
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
              child: const Text("Expand & Simplify", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Math.tex(
                                i == 0 ? _result!.workingsLaTeX[i] : "= ${_result!.workingsLaTeX[i]}",
                                textStyle: const TextStyle(fontSize: 20, color: Colors.deepPurple)
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text("Step-by-step Breakdown:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
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
                        _buildExplanationText(e.value.description),
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

  Widget _buildExplanationText(String text) {
    final parts = text.split('\$');
    if (parts.length <= 1) {
      return Text(text, style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4));
    }

    List<Widget> children = [];
    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Math.tex(parts[i], textStyle: const TextStyle(fontSize: 15, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
        ));
      } else if (parts[i].isNotEmpty) {
        children.add(Text(parts[i], style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4)));
      }
    }
    return Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: children);
  }
}