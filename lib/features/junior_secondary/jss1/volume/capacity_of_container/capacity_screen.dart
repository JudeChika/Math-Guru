// lib/features/junior_secondary/jss1/volume/capacity/capacity_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'capacity_solver.dart';
import 'capacity_models.dart';

class CapacityScreen extends StatefulWidget {
  const CapacityScreen({super.key});

  @override
  State<CapacityScreen> createState() => _CapacityScreenState();
}

class _CapacityScreenState extends State<CapacityScreen> {
  // Input Controllers
  final TextEditingController _lController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _hController = TextEditingController();
  final TextEditingController _capController = TextEditingController();
  final TextEditingController _baController = TextEditingController(); // Base Area

  // Unit States
  String _lUnit = 'cm';
  String _bUnit = 'cm';
  String _hUnit = 'cm';
  String _baUnit = 'cm²';
  String _capUnit = 'l';

  final List<String> _linearUnits = ['mm', 'cm', 'm', 'km'];
  final List<String> _areaUnits = ['mm²', 'cm²', 'm²', 'km²'];
  final List<String> _capUnits = ['ml', 'cl', 'l', 'mm³', 'cm³', 'm³'];

  String _targetUnit = 'l';
  String _missingType = 'capacity'; // Tracks what the user wants to solve for

  CapacityResult? _result;
  bool _isBaseAreaMode = false;

  void _onInputChanged(String value) {
    // Dynamically update target unit dropdown based on what is missing
    String newMissingType = _isBaseAreaMode
        ? (_capController.text.isEmpty ? 'capacity' : (_hController.text.isEmpty ? 'linear' : 'area'))
        : (_capController.text.isEmpty ? 'capacity' : 'linear');

    if (newMissingType != _missingType) {
      setState(() {
        _missingType = newMissingType;
        if (_missingType == 'capacity') _targetUnit = 'l';
        else if (_missingType == 'linear') _targetUnit = 'cm';
        else if (_missingType == 'area') _targetUnit = 'cm²';
      });
    } else {
      setState(() {});
    }
  }

  void _solve() {
    FocusScope.of(context).unfocus();

    final lText = _lController.text.trim();
    final bText = _bController.text.trim();
    final hText = _hController.text.trim();
    final capText = _capController.text.trim();
    final baText = _baController.text.trim();

    if (_isBaseAreaMode) {
      int count = (baText.isNotEmpty ? 1 : 0) + (hText.isNotEmpty ? 1 : 0) + (capText.isNotEmpty ? 1 : 0);
      if (count == 2) {
        if (capText.isEmpty) {
          setState(() => _result = CapacitySolver.solveForCapacity("", "", "", "", hText, _hUnit, baText, _baUnit, true, _targetUnit));
        } else {
          setState(() => _result = CapacitySolver.solveForSide(capText, _capUnit, "", "", "", "", hText, _hUnit, baText, _baUnit, true, _targetUnit, baText.isEmpty ? 'Base Area' : 'h'));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter exactly TWO values to solve.')));
      }
    } else {
      int count = (lText.isNotEmpty ? 1 : 0) + (bText.isNotEmpty ? 1 : 0) + (hText.isNotEmpty ? 1 : 0) + (capText.isNotEmpty ? 1 : 0);
      if (count == 3) {
        if (capText.isEmpty) {
          setState(() => _result = CapacitySolver.solveForCapacity(lText, _lUnit, bText, _bUnit, hText, _hUnit, "", "", false, _targetUnit));
        } else {
          String missingVar = lText.isEmpty ? 'l' : (bText.isEmpty ? 'b' : 'h');
          setState(() => _result = CapacitySolver.solveForSide(capText, _capUnit, lText, _lUnit, bText, _bUnit, hText, _hUnit, "", "", false, _targetUnit, missingVar));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter exactly THREE values to solve.')));
      }
    }
  }

  @override
  void dispose() {
    _lController.dispose();
    _bController.dispose();
    _hController.dispose();
    _capController.dispose();
    _baController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dynamic List for Target Dropdown
    List<String> currentTargetList = _missingType == 'capacity' ? _capUnits : (_missingType == 'area' ? _areaUnits : _linearUnits);

    // Locking Logic
    int baCount = (_baController.text.isNotEmpty ? 1 : 0) + (_hController.text.isNotEmpty ? 1 : 0) + (_capController.text.isNotEmpty ? 1 : 0);
    int stdCount = (_lController.text.isNotEmpty ? 1 : 0) + (_bController.text.isNotEmpty ? 1 : 0) + (_hController.text.isNotEmpty ? 1 : 0) + (_capController.text.isNotEmpty ? 1 : 0);

    bool baLock = _isBaseAreaMode ? baCount < 2 : false;
    bool stdLock = !_isBaseAreaMode ? stdCount < 3 : false;

    return Scaffold(
      appBar: AppBar(title: const Text('Capacity of a Container')),
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
                subtitle: const Text("Enable this if the question gives you the Base Area of the tank.", style: TextStyle(fontSize: 12)),
                value: _isBaseAreaMode,
                activeColor: Colors.deepPurple,
                onChanged: (bool value) {
                  setState(() {
                    _isBaseAreaMode = value;
                    _result = null;
                    _lController.clear(); _bController.clear(); _hController.clear(); _capController.clear(); _baController.clear();
                    _onInputChanged("");
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Smart Master Target Unit
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
                  const Expanded(
                    child: Text(
                      "Calculate Target Answer In:",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 85,
                    child: DropdownButtonFormField<String>(
                      value: currentTargetList.contains(_targetUnit) ? _targetUnit : currentTargetList.first,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      ),
                      items: currentTargetList.map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 14)))).toList(),
                      onChanged: (val) { if (val != null) setState(() { _targetUnit = val; _result = null; }); },
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (!_isBaseAreaMode) ...[
              _buildInputRow("Length (l)", _lController, _lController.text.isNotEmpty || stdLock, _lUnit, _linearUnits, (val) => setState(() => _lUnit = val)),
              const SizedBox(height: 16),
              _buildInputRow("Breadth (b)", _bController, _bController.text.isNotEmpty || stdLock, _bUnit, _linearUnits, (val) => setState(() => _bUnit = val)),
              const SizedBox(height: 16),
              _buildInputRow("Height/Depth (h)", _hController, _hController.text.isNotEmpty || stdLock, _hUnit, _linearUnits, (val) => setState(() => _hUnit = val)),
            ] else ...[
              _buildInputRow("Base Area", _baController, _baController.text.isNotEmpty || baLock, _baUnit, _areaUnits, (val) => setState(() => _baUnit = val)),
              const SizedBox(height: 16),
              _buildInputRow("Height/Depth (h)", _hController, _hController.text.isNotEmpty || baLock, _hUnit, _linearUnits, (val) => setState(() => _hUnit = val)),
            ],

            const Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Center(child: Text("— OR —", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))),

            // CAPACITY INPUT
            _buildInputRow("Capacity/Volume", _capController, _capController.text.isNotEmpty || (_isBaseAreaMode ? baLock : stdLock), _capUnit, _capUnits, (val) => setState(() => _capUnit = val)),

            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _solve, child: const Text("Solve"))),
            const SizedBox(height: 24),

            if (_result != null && _result!.valid) _buildResultView(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController ctrl, bool isEnabled, String currentUnit, List<String> units, Function(String) onUnitChange) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: TextField(controller: ctrl, enabled: isEnabled, keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: _onInputChanged, decoration: InputDecoration(labelText: label, filled: !isEnabled, fillColor: isEnabled ? Colors.transparent : Colors.grey.shade200))),
        const SizedBox(width: 16),
        Expanded(flex: 1, child: DropdownButtonFormField<String>(value: currentUnit, decoration: const InputDecoration(labelText: 'Unit'), items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(), onChanged: (val) { if (val != null) { onUnitChange(val); _result = null; } })),
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
                children: _result!.finalAnswerLaTeX.split(r'\\').map((line) => Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: Math.tex(line.trim(), textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade800, fontFamily: 'Poppins')))).toList(),
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
            child: Column(children: _result!.steps.map((s) => Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Math.tex(s.workingLaTeX, textStyle: TextStyle(fontSize: 18, color: Colors.deepPurple.shade900))))).toList()),
          ),
        ),
        const SizedBox(height: 24),
        Text("Step-by-step Breakdown:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 8),
        ..._result!.steps.asMap().entries.map((entry) {
          int idx = entry.key; var step = entry.value;
          return Card(margin: const EdgeInsets.symmetric(vertical: 4), child: ListTile(leading: CircleAvatar(child: Text('${idx + 1}')), title: Text(step.explanation, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)), subtitle: Padding(padding: const EdgeInsets.only(top: 8.0), child: Math.tex(step.workingLaTeX))));
        }),
      ],
    );
  }
}