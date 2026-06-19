import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'cube_volume_solver.dart';
import 'cube_volume_models.dart';

class CubeVolumeScreen extends StatefulWidget {
  const CubeVolumeScreen({super.key});

  @override
  State<CubeVolumeScreen> createState() => _CubeVolumeScreenState();
}

class _CubeVolumeScreenState extends State<CubeVolumeScreen> {
  final TextEditingController _sideController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();

  CubeVolumeResult? _result;

  String _inputUnit = 'cm';
  String _targetUnit = 'cm';
  final List<String> _units = ['mm', 'cm', 'm', 'km'];

  void _onInputChanged(String value) {
    setState(() {}); // Trigger rebuild to lock/unlock fields
  }

  void _solve() {
    FocusScope.of(context).unfocus();

    final sText = _sideController.text.trim();
    final vText = _volumeController.text.trim();

    if (sText.isNotEmpty) {
      setState(() => _result = CubeVolumeSolver.solveForVolume(sText, _inputUnit, _targetUnit));
    } else if (vText.isNotEmpty) {
      setState(() => _result = CubeVolumeSolver.solveForSide(vText, _inputUnit, _targetUnit));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter ONE value to solve.')),
      );
    }
  }

  @override
  void dispose() {
    _sideController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // A field is enabled if the OTHER field is empty.
    final bool isSideEnabled = _volumeController.text.trim().isEmpty;
    final bool isVolumeEnabled = _sideController.text.trim().isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Volume of a Cube')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informational Card
            Card(
              elevation: 0,
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.blue.shade200),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '💡 A cube has equal sides. The Volume (V) is the side length (a) multiplied by itself three times. Enter one value to find the other!',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Conversion Dropdowns
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _inputUnit,
                    decoration: InputDecoration(
                      labelText: 'Input Unit',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _units.map((String unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
                    onChanged: (val) { if (val != null) setState(() { _inputUnit = val; _result = null; }); },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _targetUnit,
                    decoration: InputDecoration(
                      labelText: 'Convert Answer To',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _units.map((String unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
                    onChanged: (val) { if (val != null) setState(() { _targetUnit = val; _result = null; }); },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _sideController,
              enabled: isSideEnabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onInputChanged,
              decoration: InputDecoration(
                labelText: "Enter Side Length (a) in $_inputUnit",
                hintText: "e.g. 5",
                filled: !isSideEnabled,
                fillColor: isSideEnabled ? Colors.transparent : Colors.grey.shade200,
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: Text("— OR —", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
            ),

            TextField(
              controller: _volumeController,
              enabled: isVolumeEnabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onInputChanged,
              decoration: InputDecoration(
                labelText: "Enter Volume (V) in $_inputUnit³",
                hintText: "e.g. 125",
                filled: !isVolumeEnabled,
                fillColor: isVolumeEnabled ? Colors.transparent : Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _solve, child: const Text("Solve")),
            ),
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
              // Handles standard multi-line crash fix
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