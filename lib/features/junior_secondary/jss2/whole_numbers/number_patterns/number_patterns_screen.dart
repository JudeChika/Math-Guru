import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'number_patterns_logic.dart';
import 'number_patterns_models.dart';

class NumberPatternsScreen extends StatefulWidget {
  const NumberPatternsScreen({super.key});

  @override
  State<NumberPatternsScreen> createState() => _NumberPatternsScreenState();
}

class _NumberPatternsScreenState extends State<NumberPatternsScreen> {
  int _selectedMode = 0; // 0: Multiples, 1: Nth Term, 2: Pascal

  // Controllers for Multiples
  final _rangeController = TextEditingController();
  final _multipleOfController = TextEditingController();

  // Controllers for Nth Term
  final _sequenceController = TextEditingController();
  final _nthTermController = TextEditingController();

  // Controller for Pascal
  final _pascalRowsController = TextEditingController();

  MultiplesResult? _multiplesResult;
  SequenceResult? _sequenceResult;
  PascalResult? _pascalResult;
  String? _errorMessage;

  @override
  void dispose() {
    _rangeController.dispose();
    _multipleOfController.dispose();
    _sequenceController.dispose();
    _nthTermController.dispose();
    _pascalRowsController.dispose();
    super.dispose();
  }

  void _clearResults() {
    _multiplesResult = null;
    _sequenceResult = null;
    _pascalResult = null;
    _errorMessage = null;
  }

  void _solve() {
    FocusScope.of(context).unfocus();
    setState(_clearResults);

    if (_selectedMode == 0) {
      if (_rangeController.text.isEmpty || _multipleOfController.text.isEmpty) {
        setState(() => _errorMessage = "Please fill in all fields.");
        return;
      }
      final res = NumberPatternsLogic.calculateMultiples(_rangeController.text, _multipleOfController.text);
      setState(() {
        if (!res.valid) _errorMessage = res.errorMessage;
        else _multiplesResult = res;
      });
    } else if (_selectedMode == 1) {
      if (_sequenceController.text.isEmpty || _nthTermController.text.isEmpty) {
        setState(() => _errorMessage = "Please enter the sequence and how many next terms.");
        return;
      }
      final res = NumberPatternsLogic.calculateNextTerms(_sequenceController.text, _nthTermController.text);
      setState(() {
        if (!res.valid) {
          _errorMessage = res.errorMessage;
        } else {
          _sequenceResult = res;
        }
      });
    } else {
      if (_pascalRowsController.text.isEmpty) {
        setState(() => _errorMessage = "Please enter the number of rows.");
        return;
      }
      final res = NumberPatternsLogic.generatePascal(_pascalRowsController.text);
      setState(() {
        if (!res.valid) {
          _errorMessage = res.errorMessage;
        } else {
          _pascalResult = res;
        }
      });
    }
  }

  Widget _buildInputForms(ThemeData theme) {
    if (_selectedMode == 0) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _rangeController,
              decoration: InputDecoration(
                labelText: "Range",
                hintText: "e.g. 10-50",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.straighten, color: Colors.deepPurple),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: TextField(
              controller: _multipleOfController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Multiple of",
                hintText: "e.g. 4",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _solve(),
            ),
          ),
        ],
      );
    } else if (_selectedMode == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _sequenceController,
            decoration: InputDecoration(
              labelText: "Enter Sequence (comma separated)",
              hintText: "e.g. 1, 2, 4, 7, 11",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.pattern, color: Colors.deepPurple),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nthTermController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "How many next terms?",
              hintText: "e.g. 4",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
            ),
            onSubmitted: (_) => _solve(),
          ),
        ],
      );
    } else {
      return TextField(
        controller: _pascalRowsController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: "Number of Rows",
          hintText: "e.g. 7",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.change_history, color: Colors.deepPurple),
        ),
        onSubmitted: (_) => _solve(),
      );
    }
  }

  Widget _buildStepsList(List<PatternSolutionStep> steps, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text("Step-by-step Breakdown:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: steps.length,
          itemBuilder: (context, idx) {
            final step = steps[idx];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                leading: CircleAvatar(
                  backgroundColor: step.isFinalAnswer ? Colors.green.shade100 : Colors.deepPurple.shade50,
                  foregroundColor: step.isFinalAnswer ? Colors.green.shade800 : Colors.deepPurple,
                  child: step.isFinalAnswer ? const Icon(Icons.check) : Text('${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                title: _buildExplanationText(step.description),
                subtitle: step.workingLaTeX != null
                    ? Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(
                      step.workingLaTeX!,
                      textStyle: TextStyle(
                          fontSize: step.isFinalAnswer ? 22 : 18,
                          color: step.isFinalAnswer ? Colors.green.shade700 : Colors.deepPurple,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                )
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildExplanationText(String text) {
    final parts = text.split('\$');
    if (parts.length <= 1) {
      return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500));
    }

    List<Widget> children = [];
    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Math.tex(parts[i], textStyle: const TextStyle(fontSize: 15, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
        ));
      } else if (parts[i].isNotEmpty) {
        children.add(Text(parts[i], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)));
      }
    }
    return Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: children);
  }

  Widget _buildPascalTriangle(PascalResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Text("Pascal's Triangle (Rows: ${result.numberOfRows})", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.deepPurple.shade200),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: result.triangleRows.map((row) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row.map((number) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(1, 1))],
                        ),
                        child: Text(
                          number.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        _buildStepsList(result.steps, theme),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Number Patterns')),
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
                  0: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Multiples", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  1: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Next Terms", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  2: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Pascal's", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                },
                onValueChanged: (int? value) {
                  if (value != null) {
                    setState(() {
                      _selectedMode = value;
                      _clearResults();
                    });
                  }
                },
                thumbColor: Colors.deepPurple.shade100,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 24),

            _buildInputForms(theme),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _solve,
              icon: const Icon(Icons.calculate_outlined),
              label: const Text("Calculate & Explain", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            if (_multiplesResult != null) _buildStepsList(_multiplesResult!.steps, theme),
            if (_sequenceResult != null) _buildStepsList(_sequenceResult!.steps, theme),
            if (_pascalResult != null) _buildPascalTriangle(_pascalResult!, theme),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}