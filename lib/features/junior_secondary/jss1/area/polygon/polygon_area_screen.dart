import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'polygon_area_solver.dart';
import 'polygon_area_models.dart';

class PolygonAreaScreen extends StatefulWidget {
  const PolygonAreaScreen({super.key});

  @override
  State<PolygonAreaScreen> createState() => _PolygonAreaScreenState();
}

class _PolygonAreaScreenState extends State<PolygonAreaScreen> {
  final TextEditingController _sidesController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _apothemController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

  PolygonAreaResult? _result;

  String _selectedUnit = 'cm';
  final List<String> _units = ['mm', 'cm', 'm', 'km'];

  void _onInputChanged(String value) {
    setState(() {}); // Trigger rebuild to handle locking/unlocking fields
  }

  void _solve() {
    FocusScope.of(context).unfocus();

    final nText = _sidesController.text.trim();
    final lText = _lengthController.text.trim();
    final aText = _apothemController.text.trim();
    final areaText = _areaController.text.trim();

    if (nText.isNotEmpty && lText.isNotEmpty && aText.isNotEmpty) {
      setState(() => _result = PolygonAreaSolver.solveForArea(nText, lText, aText, _selectedUnit));
    } else if (areaText.isNotEmpty && nText.isNotEmpty && aText.isNotEmpty) {
      setState(() => _result = PolygonAreaSolver.solveForSideLength(areaText, nText, aText, _selectedUnit));
    } else if (areaText.isNotEmpty && nText.isNotEmpty && lText.isNotEmpty) {
      setState(() => _result = PolygonAreaSolver.solveForApothem(areaText, nText, lText, _selectedUnit));
    } else if (areaText.isNotEmpty && lText.isNotEmpty && aText.isNotEmpty) {
      setState(() => _result = PolygonAreaSolver.solveForSides(areaText, lText, aText, _selectedUnit));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter any THREE values to solve.')),
      );
    }
  }

  @override
  void dispose() {
    _sidesController.dispose();
    _lengthController.dispose();
    _apothemController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Count how many fields have text
    int filledCount = 0;
    if (_sidesController.text.trim().isNotEmpty) filledCount++;
    if (_lengthController.text.trim().isNotEmpty) filledCount++;
    if (_apothemController.text.trim().isNotEmpty) filledCount++;
    if (_areaController.text.trim().isNotEmpty) filledCount++;

    // A field is enabled if it already has text OR if we haven't reached 3 filled fields yet
    final bool isSidesEnabled = _sidesController.text.trim().isNotEmpty || filledCount < 3;
    final bool isLengthEnabled = _lengthController.text.trim().isNotEmpty || filledCount < 3;
    final bool isApothemEnabled = _apothemController.text.trim().isNotEmpty || filledCount < 3;
    final bool isAreaEnabled = _areaController.text.trim().isNotEmpty || filledCount < 3;

    return Scaffold(
      appBar: AppBar(title: const Text('Area of a Polygon')),
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
                  '💡 For a regular polygon, Area is calculated using the number of sides (n), the length of one side (l), and the apothem (a) - which is the distance from the center to the middle of any side!',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _sidesController,
                    enabled: isSidesEnabled,
                    keyboardType: TextInputType.number,
                    onChanged: _onInputChanged,
                    decoration: InputDecoration(
                      labelText: "Number of Sides (n)",
                      hintText: "e.g. 6",
                      filled: !isSidesEnabled,
                      fillColor: isSidesEnabled ? Colors.transparent : Colors.grey.shade200,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedUnit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: _units.map((String unit) {
                      return DropdownMenuItem<String>(value: unit, child: Text(unit));
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedUnit = newValue;
                          _result = null;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lengthController,
              enabled: isLengthEnabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onInputChanged,
              decoration: InputDecoration(
                labelText: "Side Length (l)",
                hintText: "e.g. 5",
                filled: !isLengthEnabled,
                fillColor: isLengthEnabled ? Colors.transparent : Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apothemController,
              enabled: isApothemEnabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onInputChanged,
              decoration: InputDecoration(
                labelText: "Apothem (a)",
                hintText: "e.g. 4.3",
                filled: !isApothemEnabled,
                fillColor: isApothemEnabled ? Colors.transparent : Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _areaController,
              enabled: isAreaEnabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onInputChanged,
              decoration: InputDecoration(
                labelText: "Enter Area (A) in $_selectedUnit²",
                hintText: "e.g. 64.5",
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
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Math.tex(step.workingLaTeX),
              ),
            ),
          );
        }),
      ],
    );
  }
}