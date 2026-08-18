import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'squares_roots_logic.dart';
import 'squares_roots_models.dart';

class SquaresAndRootsScreen extends StatefulWidget {
  const SquaresAndRootsScreen({super.key});

  @override
  State<SquaresAndRootsScreen> createState() => _SquaresAndRootsScreenState();
}

class _SquaresAndRootsScreenState extends State<SquaresAndRootsScreen> {
  int _selectedMode = 0; // 0: Square Root, 1: Find n

  final _rootController = TextEditingController();
  final _findNController = TextEditingController();

  String _selectedMethod = 'Prime Numbers';
  final List<String> _methods = ['Prime Numbers', 'Divisibility Rules', 'Perfect Square'];

  SquaresRootsResult? _result;

  @override
  void dispose() {
    _rootController.dispose();
    _findNController.dispose();
    super.dispose();
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    setState(() => _result = null);

    if (_selectedMode == 0) {
      if (_rootController.text.isEmpty) {
        _showError("Please enter a number.");
        return;
      }
      final res = SquaresRootsLogic.calculateSquareRoot(_rootController.text, _selectedMethod);
      setState(() => _result = res);
    } else {
      if (_findNController.text.isEmpty) {
        _showError("Please enter an expression.");
        return;
      }
      final res = SquaresRootsLogic.solveFindN(_findNController.text);
      setState(() => _result = res);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildInputForms() {
    if (_selectedMode == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _rootController,
            decoration: InputDecoration(
              labelText: "Enter Number, Fraction, or Mixed Fraction",
              hintText: "e.g. 144, 16/25, or 2 1/4",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.calculate, color: Colors.deepPurple),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedMethod,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                items: _methods.map((String m) {
                  return DropdownMenuItem(value: m, child: Text("$m Method", style: const TextStyle(fontWeight: FontWeight.w600)));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedMethod = val);
                },
              ),
            ),
          ),
        ],
      );
    } else {
      return TextField(
        controller: _findNController,
        decoration: InputDecoration(
          labelText: "Enter Expression",
          hintText: "e.g. 2^3 x 5^2 x 11 x n or 24",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
        ),
        onSubmitted: (_) => _calculate(),
      );
    }
  }

  Widget _buildResultView(ThemeData theme) {
    if (_result == null) return const SizedBox.shrink();
    if (!_result!.valid) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Center(
          child: Text(
            _result!.errorMessage ?? "Error",
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    String finalLabel = _selectedMode == 0 ? "Square Root" : "Smallest value of n";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Text("Final Answer ($finalLabel):", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
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
                    _selectedMode == 0 ? _result!.finalAnswerLaTeX : "n = ${_result!.finalAnswerLaTeX}",
                    textStyle: const TextStyle(fontSize: 32, color: Colors.green, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
        Text("Workings:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
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
                      // Smart formatting: Prevents rendering "= n = 6" by checking for existing text/equal signs.
                      child: Math.tex(
                          (i == 0 || _result!.workingsLaTeX[i].contains('=') || _result!.workingsLaTeX[i].contains('\\text'))
                              ? _result!.workingsLaTeX[i]
                              : "= ${_result!.workingsLaTeX[i]}",
                          textStyle: const TextStyle(fontSize: 20, color: Colors.deepPurple)
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        Text("Step-by-step Explanation:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
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
              child: Text('${e.key+1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(e.value.explanation, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            subtitle: e.value.mathLaTeX != null
                ? Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                    e.value.mathLaTeX!,
                    textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)
                ),
              ),
            )
                : null,
          ),
        )),
        const SizedBox(height: 40),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Squares & Square Roots')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _selectedMode,
                children: const {
                  0: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("Square Root", style: TextStyle(fontWeight: FontWeight.bold))),
                  1: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("Find 'n'", style: TextStyle(fontWeight: FontWeight.bold))),
                },
                onValueChanged: (int? value) {
                  if (value != null) {
                    setState(() {
                      _selectedMode = value;
                      _result = null;
                    });
                  }
                },
                thumbColor: Colors.deepPurple.shade100,
                backgroundColor: Colors.grey.shade200,
              ),
            ),

            const SizedBox(height: 24),
            _buildInputForms(),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate_outlined),
              label: const Text("Calculate & Explain", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            _buildResultView(theme),
          ],
        ),
      ),
    );
  }
}