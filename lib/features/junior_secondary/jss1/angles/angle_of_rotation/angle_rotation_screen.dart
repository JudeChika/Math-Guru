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
  // Mode State
  String _currentMode = 'Intervals'; // 'Intervals', 'TimeAngle', 'DMS'

  // Controllers
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _angleController = TextEditingController();

  final TextEditingController _degDMSController = TextEditingController();
  final TextEditingController _minDMSController = TextEditingController();
  final TextEditingController _decimalController = TextEditingController();

  // Context Toggles
  String _handType = 'Minute'; // 'Second', 'Minute', 'Hour'

  AngleRotationResult? _result;

  void _onInputChanged(String value) {
    setState(() {}); // Trigger rebuild
  }

  void _solve() {
    FocusScope.of(context).unfocus();

    if (_currentMode == 'Intervals') {
      final sText = _startController.text.trim();
      final eText = _endController.text.trim();
      if (sText.isNotEmpty && eText.isNotEmpty) {
        setState(() => _result = AngleRotationSolver.solveInterval(sText, eText));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Start and End times.')));
      }
    }
    else if (_currentMode == 'TimeAngle') {
      final tText = _timeController.text.trim();
      final aText = _angleController.text.trim();
      if (tText.isNotEmpty) {
        setState(() => _result = AngleRotationSolver.solveTimeAndAngle(tText, _handType, true));
      } else if (aText.isNotEmpty) {
        setState(() => _result = AngleRotationSolver.solveTimeAndAngle(aText, _handType, false));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Time OR Angle.')));
      }
    }
    else if (_currentMode == 'DMS') {
      final dText = _degDMSController.text.trim();
      final mText = _minDMSController.text.trim();
      final decText = _decimalController.text.trim();

      if (dText.isNotEmpty || mText.isNotEmpty) {
        setState(() => _result = AngleRotationSolver.solveDMS(dText, mText, ""));
      } else if (decText.isNotEmpty) {
        setState(() => _result = AngleRotationSolver.solveDMS("", "", decText));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Degrees/Minutes OR Decimal Degrees.')));
      }
    }
  }

  @override
  void dispose() {
    _startController.dispose(); _endController.dispose();
    _timeController.dispose(); _angleController.dispose();
    _degDMSController.dispose(); _minDMSController.dispose(); _decimalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dynamic Locks
    final bool isTimeEnabled = _angleController.text.isEmpty;
    final bool isAngleEnabled = _timeController.text.isEmpty;

    final bool isDMSEnabled = _decimalController.text.isEmpty;
    final bool isDecEnabled = _degDMSController.text.isEmpty && _minDMSController.text.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Angle of Rotation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode Selector
            DropdownButtonFormField<String>(
              value: _currentMode,
              decoration: InputDecoration(
                labelText: 'Select Topic Type',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'Intervals', child: Text("Clock Intervals (e.g. 4.00 to 9.00)")),
                DropdownMenuItem(value: 'TimeAngle', child: Text("Time ↔ Angle (Hands of a Clock)")),
                DropdownMenuItem(value: 'DMS', child: Text("Degrees & Minutes Conversions")),
              ],
              onChanged: (String? val) {
                if (val != null) {
                  setState(() {
                    _currentMode = val;
                    _result = null;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // === MODE 1: INTERVALS ===
            if (_currentMode == 'Intervals') ...[
              Card(
                elevation: 0, color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.blue.shade200)),
                child: const Padding(padding: EdgeInsets.all(16), child: Text("💡 Enter the numbers the hand points to on the clock face (e.g. 4 and 9).", style: TextStyle(color: Colors.blue))),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextField(controller: _startController, keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: _onInputChanged, decoration: const InputDecoration(labelText: "From (Start)", hintText: "e.g. 4"))),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(controller: _endController, keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: _onInputChanged, decoration: const InputDecoration(labelText: "To (End)", hintText: "e.g. 9"))),
                ],
              ),
            ],

            // === MODE 2: TIME AND ANGLE ===
            if (_currentMode == 'TimeAngle') ...[
              DropdownButtonFormField<String>(
                value: _handType,
                decoration: const InputDecoration(labelText: 'Which Hand?'),
                items: const [
                  DropdownMenuItem(value: 'Second', child: Text("Second Hand")),
                  DropdownMenuItem(value: 'Minute', child: Text("Minute Hand")),
                  DropdownMenuItem(value: 'Hour', child: Text("Hour Hand")),
                ],
                onChanged: (val) { if (val != null) setState(() { _handType = val; _result = null; }); },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _timeController, enabled: isTimeEnabled,
                keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: _onInputChanged,
                decoration: InputDecoration(labelText: "Time Elapsed (in ${_handType == 'Hour' ? 'hours' : (_handType == 'Minute' ? 'minutes' : 'seconds')})", filled: !isTimeEnabled, fillColor: isTimeEnabled ? Colors.transparent : Colors.grey.shade200),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: Text("— OR FIND TIME FROM ANGLE —", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)))),
              TextField(
                controller: _angleController, enabled: isAngleEnabled,
                keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: _onInputChanged,
                decoration: InputDecoration(labelText: "Angle Rotated (in Degrees °)", filled: !isAngleEnabled, fillColor: isAngleEnabled ? Colors.transparent : Colors.grey.shade200),
              ),
            ],

            // === MODE 3: DMS CONVERSIONS ===
            if (_currentMode == 'DMS') ...[
              Row(
                children: [
                  Expanded(child: TextField(controller: _degDMSController, enabled: isDMSEnabled, keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: _onInputChanged, decoration: InputDecoration(labelText: "Degrees (°)", filled: !isDMSEnabled, fillColor: isDMSEnabled ? Colors.transparent : Colors.grey.shade200))),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(controller: _minDMSController, enabled: isDMSEnabled, keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: _onInputChanged, decoration: InputDecoration(labelText: "Minutes (')", filled: !isDMSEnabled, fillColor: isDMSEnabled ? Colors.transparent : Colors.grey.shade200))),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: Text("— OR CONVERT FROM DECIMAL —", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)))),
              TextField(
                controller: _decimalController, enabled: isDecEnabled,
                keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: _onInputChanged,
                decoration: InputDecoration(labelText: "Decimal Degrees (e.g. 53.8°)", filled: !isDecEnabled, fillColor: isDecEnabled ? Colors.transparent : Colors.grey.shade200),
              ),
            ],

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
        // 1. FINAL ANSWER
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

        // 2. WORKINGS (Restored Section!)
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

        // 3. STEP-BY-STEP BREAKDOWN
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