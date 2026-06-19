import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'triangular_prism_solver.dart';
import 'triangular_prism_models.dart';

class TriangularPrismScreen extends StatefulWidget {
  const TriangularPrismScreen({super.key});

  @override
  State<TriangularPrismScreen> createState() => _TriangularPrismScreenState();
}

class _TriangularPrismScreenState extends State<TriangularPrismScreen> {
  // Input Controllers
  final TextEditingController _bController = TextEditingController(); // Triangle Base
  final TextEditingController _hController = TextEditingController(); // Triangle Height
  final TextEditingController _lController = TextEditingController(); // Prism Length
  final TextEditingController _vController = TextEditingController(); // Volume
  final TextEditingController _baController = TextEditingController(); // Base Area

  // Unit States
  String _targetUnit = 'cm';
  String _bUnit = 'cm';
  String _hUnit = 'cm';
  String _lUnit = 'cm';
  String _vUnit = 'cm';
  String _baUnit = 'cm';

  final List<String> _units = ['mm', 'cm', 'm', 'km'];

  TriangularPrismResult? _result;
  bool _isBaseAreaMode = false;

  void _onInputChanged(String value) {
    setState(() {}); // Trigger rebuild
  }

  void _solve() {
    FocusScope.of(context).unfocus();

    final bText = _bController.text.trim();
    final hText = _hController.text.trim();
    final lText = _lController.text.trim();
    final vText = _vController.text.trim();
    final baText = _baController.text.trim();

    if (_isBaseAreaMode) {
      // Base Area Mode: Need 2 out of 3 fields
      int count = (baText.isNotEmpty ? 1 : 0) + (lText.isNotEmpty ? 1 : 0) + (vText.isNotEmpty ? 1 : 0);
      if (count == 2) {
        setState(() => _result = TriangularPrismSolver.solveBaseArea(
            baText, _baUnit, lText, _lUnit, vText, _vUnit, _targetUnit));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter exactly TWO values to solve.')));
      }
    } else {
      // Standard Mode: Need 3 out of 4 fields
      int count = (bText.isNotEmpty ? 1 : 0) + (hText.isNotEmpty ? 1 : 0) + (lText.isNotEmpty ? 1 : 0) + (vText.isNotEmpty ? 1 : 0);
      if (count == 3) {
        setState(() => _result = TriangularPrismSolver.solveStandard(
            bText, _bUnit, hText, _hUnit, lText, _lUnit, vText, _vUnit, _targetUnit));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter exactly THREE values to solve.')));
      }
    }
  }

  @override
  void dispose() {
    _bController.dispose();
    _hController.dispose();
    _lController.dispose();
    _vController.dispose();
    _baController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Standard Mode Locking
    int stdCount = (_bController.text.isNotEmpty ? 1 : 0) + (_hController.text.isNotEmpty ? 1 : 0) + (_lController.text.isNotEmpty ? 1 : 0) + (_vController.text.isNotEmpty ? 1 : 0);
    final bool isBEnabled = _bController.text.isNotEmpty || stdCount < 3;
    final bool isHEnabled = _hController.text.isNotEmpty || stdCount < 3;
    final bool isLStdEnabled = _lController.text.isNotEmpty || stdCount < 3;
    final bool isVStdEnabled = _vController.text.isNotEmpty || stdCount < 3;

    // Base Area Mode Locking
    int baCount = (_baController.text.isNotEmpty ? 1 : 0) + (_lController.text.isNotEmpty ? 1 : 0) + (_vController.text.isNotEmpty ? 1 : 0);
    final bool isBAEnabled = _baController.text.isNotEmpty || baCount < 2;
    final bool isLBaEnabled = _lController.text.isNotEmpty || baCount < 2;
    final bool isVBaEnabled = _vController.text.isNotEmpty || baCount < 2;

    return Scaffold(
      appBar: AppBar(title: const Text('Volume: Triangular Prism', style: TextStyle(fontSize: 18))),
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
                title: Text("Use Base Area Mode", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade800, fontFamily: 'Poppins')),
                subtitle: const Text("Enable this if the question gives you the triangular cross-sectional Area directly.", style: TextStyle(fontSize: 12)),
                value: _isBaseAreaMode,
                activeColor: Colors.deepPurple,
                onChanged: (bool value) {
                  setState(() {
                    _isBaseAreaMode = value;
                    _result = null;
                    _bController.clear(); _hController.clear(); _lController.clear(); _vController.clear(); _baController.clear();
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Master Target Unit
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

            if (!_isBaseAreaMode) ...[
              // STANDARD UI
              _buildInputRow("Triangle Base (b)", _bController, isBEnabled, _bUnit, "", (val) => setState(() => _bUnit = val)),
              const SizedBox(height: 16),
              _buildInputRow("Triangle Height (h)", _hController, isHEnabled, _hUnit, "", (val) => setState(() => _hUnit = val)),
              const SizedBox(height: 16),
              _buildInputRow("Prism Length (l)", _lController, isLStdEnabled, _lUnit, "", (val) => setState(() => _lUnit = val)),
            ] else ...[
              // BASE AREA UI
              _buildInputRow("Triangular Base Area", _baController, isBAEnabled, _baUnit, "²", (val) => setState(() => _baUnit = val)),
              const SizedBox(height: 16),
              _buildInputRow("Prism Length (l)", _lController, isLBaEnabled, _lUnit, "", (val) => setState(() => _lUnit = val)),
            ],

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: Text("— OR —", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
            ),

            // VOLUME INPUT
            _buildInputRow(
                "Volume (V)",
                _vController,
                _isBaseAreaMode ? isVBaEnabled : isVStdEnabled,
                _vUnit,
                "³",
                    (val) => setState(() => _vUnit = val)
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

  // Dynamic Input Row Widget
  Widget _buildInputRow(String label, TextEditingController ctrl, bool isEnabled, String currentUnit, String appendMark, Function(String) onUnitChange) {
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
            items: _units.map((String unit) => DropdownMenuItem(value: unit, child: Text("$unit$appendMark"))).toList(),
            onChanged: (val) { if (val != null) { onUnitChange(val); _result = null; } },
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _result!.finalAnswerLaTeX.split(r'\\').map((line) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Math.tex(
                      line.trim(),
                      textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade800, fontFamily: 'Poppins')
                  ),
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