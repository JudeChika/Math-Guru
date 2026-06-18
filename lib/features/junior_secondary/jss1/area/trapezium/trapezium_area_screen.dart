// lib/features/junior_secondary/jss1/area/trapezium/trapezium_area_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'trapezium_area_solver.dart';
import 'trapezium_area_models.dart';

class TrapeziumAreaScreen extends StatefulWidget {
  const TrapeziumAreaScreen({super.key});

  @override
  State<TrapeziumAreaScreen> createState() => _TrapeziumAreaScreenState();
}

class _TrapeziumAreaScreenState extends State<TrapeziumAreaScreen> {
  // Standard Controllers
  final TextEditingController _sideAController = TextEditingController();
  final TextEditingController _sideBController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

  // Word Problem Controller
  final TextEditingController _multiplierController = TextEditingController();

  TrapeziumAreaResult? _result;

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
      final areaText = _areaController.text.trim();
      final hText = _heightController.text.trim();
      final multText = _multiplierController.text.trim();

      if (areaText.isNotEmpty && hText.isNotEmpty && multText.isNotEmpty) {
        setState(() => _result = TrapeziumAreaSolver.solveWithRelationship(
            areaText, hText, multText, _isAMultipleOfB, _selectedUnit));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Area, Height, and Multiplier.')));
      }
    } else {
      // STANDARD SOLVING LOGIC
      final aText = _sideAController.text.trim();
      final bText = _sideBController.text.trim();
      final hText = _heightController.text.trim();
      final areaText = _areaController.text.trim();

      if (aText.isNotEmpty && bText.isNotEmpty && hText.isNotEmpty) {
        setState(() => _result = TrapeziumAreaSolver.solveForArea(aText, bText, hText, _selectedUnit));
      } else if (areaText.isNotEmpty && aText.isNotEmpty && bText.isNotEmpty) {
        setState(() => _result = TrapeziumAreaSolver.solveForHeight(areaText, aText, bText, _selectedUnit));
      } else if (areaText.isNotEmpty && hText.isNotEmpty && bText.isNotEmpty) {
        setState(() => _result = TrapeziumAreaSolver.solveForSide(areaText, bText, hText, _selectedUnit, true));
      } else if (areaText.isNotEmpty && hText.isNotEmpty && aText.isNotEmpty) {
        setState(() => _result = TrapeziumAreaSolver.solveForSide(areaText, aText, hText, _selectedUnit, false));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter any THREE values to solve.')));
      }
    }
  }

  @override
  void dispose() {
    _sideAController.dispose();
    _sideBController.dispose();
    _heightController.dispose();
    _areaController.dispose();
    _multiplierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    int filledCount = 0;
    if (_sideAController.text.trim().isNotEmpty) filledCount++;
    if (_sideBController.text.trim().isNotEmpty) filledCount++;
    if (_heightController.text.trim().isNotEmpty) filledCount++;
    if (_areaController.text.trim().isNotEmpty) filledCount++;

    final bool isSideAEnabled = _sideAController.text.trim().isNotEmpty || filledCount < 3;
    final bool isSideBEnabled = _sideBController.text.trim().isNotEmpty || filledCount < 3;
    final bool isHeightEnabled = _heightController.text.trim().isNotEmpty || filledCount < 3;
    final bool isAreaEnabled = _areaController.text.trim().isNotEmpty || filledCount < 3;

    return Scaffold(
      appBar: AppBar(title: const Text('Area of a Trapezium')),
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
                subtitle: const Text("Enable if one parallel side is a multiple of the other.", style: TextStyle(fontSize: 12)),
                value: _isWordProblemMode,
                activeThumbColor: Colors.deepPurple,
                onChanged: (bool value) {
                  setState(() {
                    _isWordProblemMode = value;
                    _result = null;
                    _sideAController.clear();
                    _sideBController.clear();
                    _heightController.clear();
                    _areaController.clear();
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
                        labelText: "Parallel Side 1 (a)",
                        hintText: "e.g. 5",
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
                  labelText: "Parallel Side 2 (b)",
                  hintText: "e.g. 7",
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
            // Height is needed in both standard and word-problem modes for a trapezium
            TextField(
              controller: _heightController,
              enabled: _isWordProblemMode ? true : isHeightEnabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onInputChanged,
              decoration: InputDecoration(
                labelText: "Height (h)",
                hintText: "e.g. 4",
                filled: !_isWordProblemMode && !isHeightEnabled,
                fillColor: (!_isWordProblemMode && !isHeightEnabled) ? Colors.grey.shade200 : Colors.transparent,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _areaController,
              enabled: _isWordProblemMode ? true : isAreaEnabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onInputChanged,
              decoration: InputDecoration(
                labelText: "Enter Area (A) in $_selectedUnit²",
                hintText: "e.g. 24",
                filled: !_isWordProblemMode && !isAreaEnabled,
                fillColor: (!_isWordProblemMode && !isAreaEnabled) ? Colors.grey.shade200 : Colors.transparent,
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