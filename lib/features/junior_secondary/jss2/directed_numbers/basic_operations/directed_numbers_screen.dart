import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'directed_numbers_logic.dart';
import 'directed_numbers_models.dart';
import 'directed_numbers_painter.dart';

class DirectedNumbersScreen extends StatefulWidget {
  const DirectedNumbersScreen({super.key});

  @override
  State<DirectedNumbersScreen> createState() => _DirectedNumbersScreenState();
}

class _DirectedNumbersScreenState extends State<DirectedNumbersScreen> {
  final TextEditingController _inputController = TextEditingController();
  DirectedResult? _result;

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
      _result = DirectedNumbersLogic.solve(_inputController.text);
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

  Widget _buildNumberLine(List<NumberLineJump> jumps) {
    if (jumps.isEmpty) return const SizedBox.shrink();

    // Dynamically calculate canvas range to fit the jumps
    double minVal = 0;
    double maxVal = 0;
    for (var j in jumps) {
      if (j.start < minVal) minVal = j.start;
      if (j.end < minVal) minVal = j.end;
      if (j.start > maxVal) maxVal = j.start;
      if (j.end > maxVal) maxVal = j.end;
    }

    // Add padding
    minVal = (minVal - 2).floorToDouble();
    maxVal = (maxVal + 2).ceilToDouble();

    // Ensure a decent minimum viewing window
    if (maxVal - minVal < 10) {
      double center = (maxVal + minVal) / 2;
      minVal = (center - 5).floorToDouble();
      maxVal = (center + 5).ceilToDouble();
    }

    double range = maxVal - minVal;
    // Ensure the number line is readable, stretching horizontally if necessary.
    double canvasWidth = range * 40.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Number Line Visualization:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: canvasWidth < MediaQuery.of(context).size.width - 64 ? MediaQuery.of(context).size.width - 64 : canvasWidth,
              height: 160,
              child: CustomPaint(
                painter: NumberLinePainter(jumps: jumps, minVal: minVal, maxVal: maxVal),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Directed Numbers')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Evaluate operations involving positive and negative numbers. Use brackets for grouped signs.",
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _inputController,
              keyboardType: TextInputType.text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: "Mathematical Expression",
                hintText: "e.g. -5 + (-3) - 4  or  1/2 * (-4)",
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
                _buildMathBtn('*', 'Multiply'),
                _buildMathBtn('/', 'Divide / Fraction'),
                _buildMathBtn('(', 'Open Bracket'),
                _buildMathBtn(')', 'Close Bracket'),
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
              child: const Text("Solve & Explain", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Math.tex(
                          _result!.finalValueLaTeX,
                          textStyle: const TextStyle(fontSize: 42, color: Colors.green, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text("Workings:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
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
              _buildNumberLine(_result!.jumps),

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
                  title: Text(e.value.description, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                          e.key == 0 ? e.value.workingLaTeX : '= ${e.value.workingLaTeX}',
                          textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)
                      ),
                    ),
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