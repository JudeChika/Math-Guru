import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'square_area_solver.dart';
import 'square_area_models.dart';

class SquareAreaScreen extends StatefulWidget {
  const SquareAreaScreen({super.key});

  @override
  State<SquareAreaScreen> createState() => _SquareAreaScreenState();
}

class _SquareAreaScreenState extends State<SquareAreaScreen> {
  final TextEditingController _sideController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  AreaResult? _result;

  String _selectedUnit = 'cm';
  final List<String> _units = ['mm', 'cm', 'm', 'km'];

  void _onSideChanged(String value) {
    // Trigger a rebuild to lock/unlock the Area field dynamically
    setState(() {});
  }

  void _onAreaChanged(String value) {
    // Trigger a rebuild to lock/unlock the Side field dynamically
    setState(() {});
  }

  void _solve() {
    FocusScope.of(context).unfocus();
    if (_sideController.text.trim().isNotEmpty) {
      setState(() => _result = SquareAreaSolver.solveForArea(
          _sideController.text.trim(), _selectedUnit));
    } else if (_areaController.text.trim().isNotEmpty) {
      setState(() => _result = SquareAreaSolver.solveForSide(
          _areaController.text.trim(), _selectedUnit));
    }
  }

  @override
  void dispose() {
    _sideController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine if fields should be enabled based on whether the OTHER field is empty
    final bool isSideEnabled = _areaController.text.trim().isEmpty;
    final bool isAreaEnabled = _sideController.text.trim().isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Area of a Square')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _sideController,
                    enabled: isSideEnabled,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: _onSideChanged,
                    decoration: InputDecoration(
                      labelText: "Enter Length (a)",
                      hintText: "e.g. 5",
                      filled: !isSideEnabled,
                      fillColor: isSideEnabled ? Colors.transparent : Colors.grey.shade200,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                    ),
                    items: _units.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedUnit = newValue;
                          _result = null; // Clear previous result on unit change
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _areaController,
              enabled: isAreaEnabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onAreaChanged,
              decoration: InputDecoration(
                labelText: "Enter Area (A) in $_selectedUnit²",
                hintText: "e.g. 25",
                filled: !isAreaEnabled,
                fillColor: isAreaEnabled ? Colors.transparent : Colors.grey.shade200,
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
              child: Math.tex(
                  _result!.finalAnswerLaTeX,
                  textStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green.shade800, fontFamily: 'Poppins')
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
              subtitle: Math.tex(step.workingLaTeX),
            ),
          );
        }),
      ],
    );
  }
}