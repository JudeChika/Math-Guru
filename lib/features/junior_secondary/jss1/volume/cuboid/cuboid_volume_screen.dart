import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'cuboid_volume_solver.dart';
import 'cuboid_volume_models.dart';

class CuboidVolumeScreen extends StatefulWidget {
  const CuboidVolumeScreen({super.key});

  @override
  State<CuboidVolumeScreen> createState() => _CuboidVolumeScreenState();
}

class _CuboidVolumeScreenState extends State<CuboidVolumeScreen> {
  // Input Controllers
  final TextEditingController _lController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _hController = TextEditingController();
  final TextEditingController _vController = TextEditingController();

  // Unit States
  String _targetUnit = 'cm';
  String _lUnit = 'cm';
  String _bUnit = 'cm';
  String _hUnit = 'cm';
  String _vUnit = 'cm';

  final List<String> _units = ['mm', 'cm', 'm', 'km'];

  CuboidVolumeResult? _result;

  void _onInputChanged(String value) {
    setState(() {}); // Trigger rebuild to handle locking/unlocking fields
  }

  void _solve() {
    FocusScope.of(context).unfocus();

    final lText = _lController.text.trim();
    final bText = _bController.text.trim();
    final hText = _hController.text.trim();
    final vText = _vController.text.trim();

    if (lText.isNotEmpty && bText.isNotEmpty && hText.isNotEmpty) {
      // Solving for Volume
      setState(() => _result = CuboidVolumeSolver.solveForVolume(
          lText, _lUnit, bText, _bUnit, hText, _hUnit, _targetUnit));
    } else if (vText.isNotEmpty && bText.isNotEmpty && hText.isNotEmpty) {
      // Solving for Length
      setState(() => _result = CuboidVolumeSolver.solveForSide(
          vText, _vUnit, bText, _bUnit, hText, _hUnit, _targetUnit, 'l'));
    } else if (vText.isNotEmpty && lText.isNotEmpty && hText.isNotEmpty) {
      // Solving for Breadth
      setState(() => _result = CuboidVolumeSolver.solveForSide(
          vText, _vUnit, lText, _lUnit, hText, _hUnit, _targetUnit, 'b'));
    } else if (vText.isNotEmpty && lText.isNotEmpty && bText.isNotEmpty) {
      // Solving for Height
      setState(() => _result = CuboidVolumeSolver.solveForSide(
          vText, _vUnit, lText, _lUnit, bText, _bUnit, _targetUnit, 'h'));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter any THREE values to solve.')),
      );
    }
  }

  @override
  void dispose() {
    _lController.dispose();
    _bController.dispose();
    _hController.dispose();
    _vController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Count filled fields to lock the 4th
    int filledCount = 0;
    if (_lController.text.trim().isNotEmpty) filledCount++;
    if (_bController.text.trim().isNotEmpty) filledCount++;
    if (_hController.text.trim().isNotEmpty) filledCount++;
    if (_vController.text.trim().isNotEmpty) filledCount++;

    final bool isLEnabled = _lController.text.trim().isNotEmpty || filledCount < 3;
    final bool isBEnabled = _bController.text.trim().isNotEmpty || filledCount < 3;
    final bool isHEnabled = _hController.text.trim().isNotEmpty || filledCount < 3;
    final bool isVEnabled = _vController.text.trim().isNotEmpty || filledCount < 3;

    return Scaffold(
      appBar: AppBar(title: const Text('Volume of a Cuboid')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Target Answer Unit
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.settings_suggest, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Expanded(child: Text("Calculate Target Answer In:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<String>(
                      value: _targetUnit,
                      decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                      items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (val) { if (val != null) setState(() { _targetUnit = val; _result = null; }); },
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Dimension Rows
            _buildInputRow("Length (l)", _lController, isLEnabled, _lUnit, (val) => setState(() => _lUnit = val)),
            const SizedBox(height: 16),
            _buildInputRow("Breadth (b)", _bController, isBEnabled, _bUnit, (val) => setState(() => _bUnit = val)),
            const SizedBox(height: 16),
            _buildInputRow("Height (h)", _hController, isHEnabled, _hUnit, (val) => setState(() => _hUnit = val)),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: Text("— OR —", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
            ),

            // Volume Input uses ³ visually but stores base unit
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _vController,
                    enabled: isVEnabled,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: _onInputChanged,
                    decoration: InputDecoration(
                      labelText: "Volume (V)",
                      filled: !isVEnabled,
                      fillColor: isVEnabled ? Colors.transparent : Colors.grey.shade200,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _vUnit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: _units.map((u) => DropdownMenuItem(value: u, child: Text("$u³"))).toList(),
                    onChanged: (val) { if (val != null) setState(() { _vUnit = val; _result = null; }); },
                  ),
                ),
              ],
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

  // Helper widget for input rows
  Widget _buildInputRow(String label, TextEditingController ctrl, bool isEnabled, String currentUnit, Function(String) onUnitChange) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: ctrl,
            enabled: isEnabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: _onInputChanged,
            decoration: InputDecoration(
              labelText: label,
              filled: !isEnabled,
              fillColor: isEnabled ? Colors.transparent : Colors.grey.shade200,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            value: currentUnit,
            decoration: const InputDecoration(labelText: 'Unit'),
            items: _units.map((String unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
            onChanged: (val) { if (val != null) onUnitChange(val); _result = null; },
          ),
        ),
      ],
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
              // CrNode fix for multi-line LaTeX (handles standard returns gracefully)
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