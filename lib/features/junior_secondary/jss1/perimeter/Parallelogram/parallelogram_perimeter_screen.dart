// lib/features/junior_secondary/jss1/perimeter/Parallelogram/parallelogram_perimeter_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'parallelogram_perimeter_solver.dart';
import 'parallelogram_perimeter_models.dart';

class ParallelogramPerimeterScreen extends StatefulWidget {
  const ParallelogramPerimeterScreen({super.key});

  @override
  State<ParallelogramPerimeterScreen> createState() => _ParallelogramPerimeterScreenState();
}

class _ParallelogramPerimeterScreenState extends State<ParallelogramPerimeterScreen> {
  // Standard Controllers
  final TextEditingController _sideAController = TextEditingController();
  final TextEditingController _sideBController = TextEditingController();
  final TextEditingController _perimeterController = TextEditingController();

  // Word Problem Controller
  final TextEditingController _multiplierController = TextEditingController();

  GeometryResult? _result;

  String _selectedUnit = 'cm';
  final List<String> _units = ['mm', 'cm', 'm', 'km'];

  // Mode Toggles
  bool _isWordProblemMode = false;
  bool _isAMultipleOfB = true;

  void _onInputChanged(String value) {
    setState(() {}); // Trigger rebuild
  }

  void _solve() {
    FocusScope.of(context).unfocus();

    if (_isWordProblemMode) {
      final pText = _perimeterController.text.trim();
      final multText = _multiplierController.text.trim();

      if (pText.isNotEmpty && multText.isNotEmpty) {
        setState(() => _result = ParallelogramPerimeterSolver.solveWithRelationship(
            pText, multText, _isAMultipleOfB, _selectedUnit));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Perimeter and the Multiplier.')));
      }
    } else {
      // STANDARD SOLVING LOGIC
      final aText = _sideAController.text.trim();
      final bText = _sideBController.text.trim();
      final pText = _perimeterController.text.trim();

      if (aText.isNotEmpty && bText.isNotEmpty) {
        setState(() => _result = ParallelogramPerimeterSolver.solveForPerimeter(aText, bText, _selectedUnit));
      } else if (pText.isNotEmpty && bText.isNotEmpty) {
        setState(() => _result = ParallelogramPerimeterSolver.solveForSide(pText, bText, _selectedUnit, true));
      } else if (pText.isNotEmpty && aText.isNotEmpty) {
        setState(() => _result = ParallelogramPerimeterSolver.solveForSide(pText, aText, _selectedUnit, false));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter any TWO values to solve.')));
      }
    }
  }

  @override
  void dispose() {
    _sideAController.dispose();
    _sideBController.dispose();
    _perimeterController.dispose();
    _multiplierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool isSideAEnabled = !(_perimeterController.text.isNotEmpty && _sideBController.text.isNotEmpty);
    final bool isSideBEnabled = !(_perimeterController.text.isNotEmpty && _sideAController.text.isNotEmpty);
    final bool isPerimeterEnabled = !(_sideAController.text.isNotEmpty && _sideBController.text.isNotEmpty);

    return Scaffold(
      appBar: AppBar(title: const Text('Perimeter of a Parallelogram')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode Toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: SwitchListTile(
                title: Text("Algebra Word Problem Mode", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade800, fontFamily: 'Poppins')),
                subtitle: const Text("Enable if one side is a multiple of the other.", style: TextStyle(fontSize: 12)),
                value: _isWordProblemMode,
                activeThumbColor: Colors.deepPurple,
                onChanged: (bool value) {
                  setState(() {
                    _isWordProblemMode = value;
                    _result = null;
                    _sideAController.clear();
                    _sideBController.clear();
                    _perimeterController.clear();
                    _multiplierController.clear();
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            if (!_isWordProblemMode) ...[
              // STANDARD UI
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _sideAController,
                      enabled: isSideAEnabled,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: _onInputChanged,
                      decoration: InputDecoration(
                        labelText: "Enter Side (a)",
                        filled: !isSideAEnabled,
                        fillColor: isSideAEnabled ? Colors.transparent : Colors.grey.shade200,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedUnit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      items: _units.map((String unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
                      onChanged: (val) { if (val != null) setState(() { _selectedUnit = val; _result = null; }); },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _sideBController,
                enabled: isSideBEnabled,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: _onInputChanged,
                decoration: InputDecoration(
                  labelText: "Enter Side (b)",
                  filled: !isSideBEnabled,
                  fillColor: isSideBEnabled ? Colors.transparent : Colors.grey.shade200,
                ),
              ),
            ] else ...[
              // WORD PROBLEM UI
              DropdownButtonFormField<bool>(
                initialValue: _isAMultipleOfB,
                decoration: const InputDecoration(labelText: 'Select Relationship'),
                items: const [
                  DropdownMenuItem(value: true, child: Text("Side 'a' is a multiple of 'b' (a = x·b)")),
                  DropdownMenuItem(value: false, child: Text("Side 'b' is a multiple of 'a' (b = x·a)")),
                ],
                onChanged: (val) { if (val != null) setState(() { _isAMultipleOfB = val; _result = null; }); },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _multiplierController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: _onInputChanged,
                      decoration: const InputDecoration(labelText: "Enter Multiplier (x)", hintText: "e.g. 2"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedUnit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      items: _units.map((String unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
                      onChanged: (val) { if (val != null) setState(() { _selectedUnit = val; _result = null; }); },
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),
            TextField(
              controller: _perimeterController,
              enabled: _isWordProblemMode ? true : isPerimeterEnabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onInputChanged,
              decoration: InputDecoration(
                labelText: "Enter Perimeter (P) in $_selectedUnit",
                filled: !_isWordProblemMode && !isPerimeterEnabled,
                fillColor: (!_isWordProblemMode && !isPerimeterEnabled) ? Colors.grey.shade200 : Colors.transparent,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _solve, child: const Text("Solve"))),
            const SizedBox(height: 24),
            if (_result != null && _result!.valid) _buildResultView(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Final Answer:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              // THE FIX: Automatically splits the LaTeX using CrNode lines
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _result!.finalAnswerLaTeX
                    .split(r'\\')
                    .map((line) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Math.tex(
                      line.trim(),
                      textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade800, fontFamily: 'Poppins')
                  ),
                ))
                    .toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text("Workings:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        Card(
          color: Colors.deepPurple.shade50,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: _result!.steps.map((s) => Center(
                  child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Math.tex(s.workingLaTeX, textStyle: TextStyle(fontSize: 18, color: Colors.deepPurple.shade900))
                  )
              )).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text("Step-by-step Breakdown:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        ..._result!.steps.asMap().entries.map((entry) {
          int idx = entry.key;
          var step = entry.value;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(child: Text('${idx + 1}')),
              title: Text(step.explanation, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
              subtitle: Padding(padding: const EdgeInsets.only(top: 8.0), child: Math.tex(step.workingLaTeX)),
            ),
          );
        }),
      ],
    );
  }
}