// lib/features/junior_secondary/jss1/angles/angle_of_rotation/angle_rotation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'angle_rotation_solver.dart';
import 'angle_rotation_models.dart';

class AngleRotationScreen extends StatefulWidget {
  const AngleRotationScreen({super.key});

  @override
  State<AngleRotationScreen> createState() => _AngleRotationScreenState();
}

class _AngleRotationScreenState extends State<AngleRotationScreen> {
  String _currentMode = 'Intervals'; // 'Intervals', 'TimeAngle', 'DMS', 'Arithmetic'

  // Controllers
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _angleController = TextEditingController();

  final TextEditingController _degDMSController = TextEditingController();
  final TextEditingController _minDMSController = TextEditingController();
  final TextEditingController _decimalController = TextEditingController();

  // Arithmetic Controllers
  final TextEditingController _deg1Controller = TextEditingController();
  final TextEditingController _min1Controller = TextEditingController();
  final TextEditingController _deg2Controller = TextEditingController();
  final TextEditingController _min2Controller = TextEditingController();
  final TextEditingController _scalarController = TextEditingController();
  String _arithmeticOp = 'add'; // 'add', 'sub', 'mul', 'div'

  final String _handType = 'Minute';
  AngleRotationResult? _result;

  void _onInputChanged(String value) { setState(() {}); }

  void _solve() {
    FocusScope.of(context).unfocus();

    if (_currentMode == 'Arithmetic') {
      final d1 = _deg1Controller.text.trim();
      final m1 = _min1Controller.text.trim();
      final d2 = _deg2Controller.text.trim();
      final m2 = _min2Controller.text.trim();
      final scalar = _scalarController.text.trim();

      if ((_arithmeticOp == 'add' || _arithmeticOp == 'sub') && (d1.isNotEmpty || m1.isNotEmpty) && (d2.isNotEmpty || m2.isNotEmpty)) {
        setState(() => _result = AngleRotationSolver.solveArithmetic(d1, m1, _arithmeticOp, d2, m2, ""));
      } else if ((_arithmeticOp == 'mul' || _arithmeticOp == 'div') && (d1.isNotEmpty || m1.isNotEmpty) && scalar.isNotEmpty) {
        setState(() => _result = AngleRotationSolver.solveArithmetic(d1, m1, _arithmeticOp, "", "", scalar));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
      }
    }
    // ... [Keep existing solve calls for Intervals, TimeAngle, DMS here] ...
    else if (_currentMode == 'Intervals') {
      if (_startController.text.isNotEmpty && _endController.text.isNotEmpty) setState(() => _result = AngleRotationSolver.solveInterval(_startController.text.trim(), _endController.text.trim()));
    } else if (_currentMode == 'TimeAngle') {
      if (_timeController.text.isNotEmpty) {
        setState(() => _result = AngleRotationSolver.solveTimeAndAngle(_timeController.text.trim(), _handType, true));
      } else if (_angleController.text.isNotEmpty) setState(() => _result = AngleRotationSolver.solveTimeAndAngle(_angleController.text.trim(), _handType, false));
    } else if (_currentMode == 'DMS') {
      if (_degDMSController.text.isNotEmpty || _minDMSController.text.isNotEmpty) {
        setState(() => _result = AngleRotationSolver.solveDMS(_degDMSController.text.trim(), _minDMSController.text.trim(), ""));
      } else if (_decimalController.text.isNotEmpty) setState(() => _result = AngleRotationSolver.solveDMS("", "", _decimalController.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Angle of Rotation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode Selector
            DropdownButtonFormField<String>(
              initialValue: _currentMode,
              decoration: InputDecoration(labelText: 'Select Topic Type', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              items: const [
                DropdownMenuItem(value: 'Intervals', child: Text("Clock Intervals (e.g. 4 to 9)")),
                DropdownMenuItem(value: 'TimeAngle', child: Text("Time ↔ Angle")),
                DropdownMenuItem(value: 'DMS', child: Text("Degrees/Minutes Conversions")),
                DropdownMenuItem(value: 'Arithmetic', child: Text("Add/Subtract/Multiply/Divide", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
              ],
              onChanged: (String? val) { if (val != null) setState(() { _currentMode = val; _result = null; }); },
            ),
            const SizedBox(height: 24),

            // === MODE 4: ARITHMETIC ===
            if (_currentMode == 'Arithmetic') ...[
              DropdownButtonFormField<String>(
                initialValue: _arithmeticOp,
                decoration: const InputDecoration(labelText: 'Operation'),
                items: const [
                  DropdownMenuItem(value: 'add', child: Text("Addition (+)")),
                  DropdownMenuItem(value: 'sub', child: Text("Subtraction (-)")),
                  DropdownMenuItem(value: 'mul', child: Text("Multiplication (×)")),
                  DropdownMenuItem(value: 'div', child: Text("Division (÷)")),
                ],
                onChanged: (val) { if (val != null) setState(() { _arithmeticOp = val; _result = null; }); },
              ),
              const SizedBox(height: 16),

              Text("Angle 1:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700)),
              Row(
                children: [
                  Expanded(child: TextField(controller: _deg1Controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: "Degrees (°)", filled: true, fillColor: Colors.grey.shade50))),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(controller: _min1Controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: "Minutes (')", filled: true, fillColor: Colors.grey.shade50))),
                ],
              ),
              const SizedBox(height: 16),

              if (_arithmeticOp == 'add' || _arithmeticOp == 'sub') ...[
                Text("Angle 2:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700)),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _deg2Controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: "Degrees (°)", filled: true, fillColor: Colors.grey.shade50))),
                    const SizedBox(width: 16),
                    Expanded(child: TextField(controller: _min2Controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: "Minutes (')", filled: true, fillColor: Colors.grey.shade50))),
                  ],
                ),
              ] else ...[
                Text("Number:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700)),
                TextField(controller: _scalarController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: _arithmeticOp == 'mul' ? "Multiply By" : "Divide By", filled: true, fillColor: Colors.grey.shade50)),
              ],
            ],

            // ... [KEEP REMAINDER OF UI MODES (Intervals, TimeAngle, DMS) AND RESULT VIEW EXACTLY THE SAME] ...

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _result!.finalAnswerLaTeX.split(r'\\').map((line) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Math.tex(line.trim(), textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade800, fontFamily: 'Poppins'))
                )).toList(),
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
                      padding: const EdgeInsets.symmetric(vertical: 4),
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